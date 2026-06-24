"""
Sync FR Follow-ups sheet → Prospects CRM
Reads all data from sheet, matches to DB, fills missing fields.
"""
import sys, re, json, os
sys.path.insert(0, '/root/hermes-mvp/backend')
sys.path.insert(0, '/root/hermes-dashboard')

from dotenv import load_dotenv
load_dotenv('/root/hermes-mvp/backend/.env')

from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from database import SessionLocal
from models.prospect import Prospect, ProspectStatus, ProspectType
from datetime import datetime

SHEET_ID = "1ZsFcbzY8xIqqmp9OeARIkIqy-2oobQzxXbxn4tHYPQE"

def build_service():
    token_path = os.environ.get('GOOGLE_TOKEN_PATH', '/root/.hermes/google_token.json')
    creds = Credentials.from_authorized_user_file(token_path)
    return build("sheets", "v4", credentials=creds)

def get_values(service, range_name):
    r = service.spreadsheets().values().get(
        spreadsheetId=SHEET_ID, range=range_name
    ).execute()
    return r.get("values", [])

def find_best_match(company_name, db_prospects):
    """Find best matching prospect in DB by normalized name"""
    def norm(s):
        s = s.strip().lower()
        s = re.sub(r'[^\w\s]', ' ', s)
        s = re.sub(r'\s+', ' ', s).strip()
        for a, b in [('energies', 'energie'), ('developpement', 'developpement'),
                      ('groupe', 'groupe'), ('sas', ''), ('france', '')]:
            s = s.replace(a, b).strip()
        return s
    
    cn = norm(company_name)
    best, best_score = None, 0
    
    for p in db_prospects:
        pn = norm(p.company)
        if pn == cn:
            return p, 100
        if cn in pn or pn in cn:
            score = min(len(cn), len(pn)) / max(len(cn), len(pn)) if len(cn) > 0 and len(pn) > 0 else 0
            if score > best_score:
                best_score, best = score, p
        first_cn = cn.split()[0] if cn.split() else ''
        first_pn = pn.split()[0] if pn.split() else ''
        if first_cn and first_pn and first_cn == first_pn and len(first_cn) > 3:
            best_score, best = 0.6, p
    
    return best, best_score

def map_status(responded, nda, next_steps):
    nda_l = (nda or '').strip().lower()
    resp_l = (responded or '').strip().lower()
    next_l = (next_steps or '').strip().lower()
    if nda_l in ('yes', 'oui', 'signed', '✅'):
        return 'nda_signed'
    if 'deal' in next_l or 'transaction' in next_l or 'offre' in next_l:
        return 'deal_in_progress'
    if resp_l in ('yes', 'oui', '✅', 'replied'):
        return 'in_discussion'
    if nda_l == 'pending':
        return 'in_discussion'
    return None

def build_notes(row):
    parts = []
    poc = row.get('POC', '').strip()
    summary = row.get('Summary / meeting minutes', '').strip()
    next_steps = row.get('Next steps', '').strip()
    comments = row.get('Commentaire', '').strip()
    nda = row.get('NDA signed?', '').strip()
    priority = row.get('Priority', '').strip()
    contact = row.get('Contact', '').strip()
    name_role = row.get('Name + Role', '').strip()
    
    # Header metadata
    meta = []
    if poc: meta.append(f"POC: {poc}")
    if nda: meta.append(f"NDA: {nda}")
    if priority: meta.append(f"Priorité: {priority}")
    if meta:
        parts.append(" | ".join(meta))
    
    # Contact info
    if name_role or contact:
        cparts = []
        if name_role: cparts.append(f"👤 {name_role}")
        if contact and contact.lower() != name_role.lower():
            cparts.append(f"📎 Ref: {contact}")
        if cparts:
            parts.append("\n".join(cparts))
    
    # Meeting summary
    if summary:
        parts.append(f"\n📋 Résumé:\n{summary}")
    
    # Next steps
    if next_steps:
        parts.append(f"\n⏭ Actions:\n{next_steps}")
    
    # Comments
    if comments:
        parts.append(f"\n💬 Notes:\n{comments}")
    
    return '\n'.join(parts)

def extract_first_email(email_str):
    if not email_str:
        return None
    first = email_str.split('/')[0].split(',')[0].strip()
    return first if '@' in first else None

def extract_first_phone(phone_str):
    if not phone_str or phone_str == '#ERROR!':
        return None
    first = phone_str.split('/')[0].split(',')[0].strip()
    if len(first) >= 8 and any(c.isdigit() for c in first):
        return first
    return None

def main():
    print("📥 Lecture du sheet FR Follow-ups...")
    svc = build_service()
    values = get_values(svc, "Follow-ups!A:O")
    
    if not values or len(values) < 2:
        print("❌ Pas de données")
        return
    
    header = values[0]
    rows = []
    for row in values[1:]:
        d = dict(zip(header, row + [''] * (len(header) - len(row))))
        company = d.get('Company', '').strip()
        if company:
            rows.append(d)
    
    print(f"✅ {len(rows)} entreprises dans le sheet")
    
    db = SessionLocal()
    db_prospects = db.query(Prospect).all()
    print(f"📋 {len(db_prospects)} prospects en BDD")
    
    matched, updated, skipped = 0, 0, 0
    
    for row in rows:
        company = row.get('Company', '').strip()
        best, score = find_best_match(company, db_prospects)
        
        if not best or score < 0.4:
            skipped += 1
            print(f"  ⚠️  {company} → pas trouvé")
            continue
        
        matched += 1
        changed = False
        
        # Email
        email = extract_first_email(row.get('Email', ''))
        if email and not best.email:
            best.email = email
            changed = True
        
        # Phone
        phone = extract_first_phone(row.get('Phone number', ''))
        if phone and not best.phone:
            best.phone = phone
            changed = True
        
        # Contact name
        contact = row.get('Name + Role', '').strip()
        if contact and not best.contact_name:
            name_part = contact.split('-')[0].split(',')[0].strip()
            # Clean up
            name_part = re.sub(r'\b(CEO|President|Directeur|Directrice|DG|Responsable|Manager|Head of|Chargé)\b', '', name_part, flags=re.I).strip()
            name_part = re.sub(r'\S+@\S+', '', name_part).strip()
            name_part = re.sub(r'[\d\s\.\+\-]{8,}', '', name_part).strip()
            if len(name_part) > 4 and ' ' in name_part:
                best.contact_name = name_part.strip()
                changed = True
        
        # Country
        if not best.country:
            best.country = 'FR'
            changed = True
        
        # Status
        new_status = map_status(row.get('responded?', ''), row.get('NDA signed?', ''), row.get('Next steps', ''))
        if new_status:
            try:
                best.status = ProspectStatus(new_status)
                changed = True
            except:
                pass
        
        # NDA
        nda_raw = row.get('NDA signed?', '').strip().lower()
        if nda_raw in ('yes', 'oui', 'signed', '✅'):
            if best.nda_signed != 'Oui':
                best.nda_signed = 'Oui'
                changed = True
        elif nda_raw in ('no', 'non'):
            if not best.nda_signed:
                best.nda_signed = 'Non'
                changed = True
        elif nda_raw == 'pending':
            if not best.nda_signed:
                best.nda_signed = 'Pending'
                changed = True
        
        # Notes - only if existing notes are short
        new_notes = build_notes(row)
        existing_notes = best.notes or ''
        if new_notes and (len(existing_notes) < 30 or existing_notes == best.company):
            best.notes = new_notes
            changed = True
        elif new_notes and 'Synthèse CRM' not in existing_notes and len(existing_notes) < 80:
            best.notes = new_notes
            changed = True
        
        # Next action
        next_steps = row.get('Next steps', '').strip()
        if next_steps and not best.next_action:
            best.next_action = next_steps[:300]
            changed = True
        
        if changed:
            best.updated_at = datetime.utcnow()
            updated += 1
            print(f"  ✏️  {company} → mis à jour")
        else:
            print(f"  ✓  {company} → déjà complet")
    
    db.commit()
    db.close()
    
    print(f"\n📊 Résultat: {matched} trouvés, {updated} mis à jour, {skipped} non matchés")

if __name__ == '__main__':
    main()
