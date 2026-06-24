"""
Migration v2 : reconstruit le statut FR du Scouting à partir du Google Sheet
source (colonne "Statut"), qui contient une granularité perdue lors de
l'import initial (Accepté LinkedIn, Preliminary discussions, NDA Executed...).

Structure cible (3 colonnes Kanban FR) :
    to_contact           -> "À scout" (liste principale, pas encore contacté)
    premiere_connexion   -> 1er message envoyé, en attente d'acceptation LinkedIn
    deuxieme_connexion   -> connexion LinkedIn acceptée

Règles :
- Si l'entreprise existe déjà dans `prospects` -> on retire la ligne scouting (déjà au CRM).
- NDA Executed/Sent, Meeting Done, Preparing meeting, Call confirmé -> transféré
  vers `prospects` (créé si absent) puis retiré de scouting.
- Accepté LinkedIn / Preliminary discussions -> deuxieme_connexion.
- Invitation sent / 1ère connexion LinkedIn / Message LinkedIn / Contacté par Zein (LinkedIn)
  -> premiere_connexion (li_1ere_sent=true).
- Email envoyé (variantes) -> premiere_connexion (em_1ere_sent=true).
- Not Interrested / Pas intéressé -> to_contact + flag pas_interesse.
- Pas pertinent -> to_contact + flag pas_pertinent.
- Bounced -> to_contact + flag bounced (contact vidé pour en chercher un autre).
- À scout / À scouter / vide / autre texte non reconnu -> to_contact (texte brut
  conservé dans les notes si non reconnu).

À exécuter manuellement : python migrate_scouting_fr_v2.py
"""
import json
import re
import sys
import unicodedata

sys.path.insert(0, '/root/hermes-dashboard')

from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from sqlalchemy import func

from database import SessionLocal
from models.scouting import Scouting, ScoutingType
from models.prospect import Prospect, ProspectType, ProspectStatus

TOKEN_PATH = "/root/.hermes/google_token.json"
SCOUTING_ID = "1d6RNjs5whURmDzmPHKcIrELCl0_rC9MRD2BH8Vmte-s"

TABS = [
    ("Prospects Investisseurs", ScoutingType.investor, "Investisseur"),
    ("Prospects Développeurs", ScoutingType.developer, "Développeur"),
]

NOTE_COLS = ["Zone géographique", "Portefeuille (MW)", "Mandat (MW)", "Technologies", "Stade projets", "Critères", "Notes"]


def norm(s):
    s = unicodedata.normalize("NFKD", s or "").encode("ascii", "ignore").decode().lower()
    return re.sub(r"\s+", " ", s).strip()


def build_service():
    creds = Credentials.from_authorized_user_file(TOKEN_PATH)
    return build("sheets", "v4", credentials=creds)


def get_rows(svc, sheet_id, tab):
    values = svc.spreadsheets().values().get(spreadsheetId=sheet_id, range=f"'{tab}'!A:Z").execute().get("values", [])
    if not values or len(values) < 2:
        return []
    header = values[0]
    out = []
    for row in values[1:]:
        if len(row) < len(header):
            row = row + [""] * (len(header) - len(row))
        out.append({header[i]: row[i].strip() for i in range(len(header))})
    return out


def classify_deal(s):
    if "nda executed" in s:
        return ProspectStatus.nda_signed, "Oui"
    if "nda sent" in s:
        return ProspectStatus.in_discussion, "Non"
    if "meeting done" in s:
        return ProspectStatus.in_discussion, "Non"
    if "preparing meeting" in s or "call confirm" in s or "fixer call" in s:
        return ProspectStatus.meeting_scheduled, "Non"
    return None


def classify(statut_raw):
    s = norm(statut_raw)
    deal = classify_deal(s)
    if deal:
        return ("deal", deal)
    if "accepte linkedin" in s or "preliminary discussion" in s:
        return ("deuxieme", None)
    if any(k in s for k in ["invitation sent", "1ere connexion linkedin", "message linkedin",
                             "contact linkedin", "contacte par zein", "linkedin envoy",
                             "message envoy"]):
        return ("premiere", "li")
    if "email envoy" in s or "mail envoye" in s:
        return ("premiere", "em")
    if "not interrested" in s or "not interested" in s or "pas interess" in s:
        return ("a_scout", "pas_interesse")
    if "pas pertinent" in s:
        return ("a_scout", "pas_pertinent")
    if "bounced" in s:
        return ("a_scout", "bounced")
    return ("a_scout", None)


def build_notes(row):
    parts = []
    for col in NOTE_COLS:
        v = row.get(col, "").strip()
        if v:
            parts.append(f"{col}: {v}")
    return "\n".join(parts) or None


def main():
    svc = build_service()
    db = SessionLocal()

    counts = {"already_in_crm": 0, "deal_to_crm": 0, "deuxieme": 0, "premiere": 0, "a_scout": 0,
              "pas_interesse": 0, "pas_pertinent": 0, "bounced": 0, "created_scouting": 0}

    for tab, scouting_type, company_col in TABS:
        rows = get_rows(svc, SCOUTING_ID, tab)
        print(f"\n=== {tab} ({len(rows)} lignes) ===")
        for row in rows:
            company = row.get(company_col, "").strip()
            if not company:
                continue
            statut_raw = row.get("Statut", "")
            contact = row.get("Contact", "").strip() or None
            email = row.get("Email", "").strip() or None
            notes = build_notes(row)

            existing_prospect = db.query(Prospect).filter(func.lower(Prospect.company) == company.lower()).first()
            existing_scouting = db.query(Scouting).filter(
                func.lower(Scouting.company) == company.lower(),
                Scouting.type == scouting_type,
                Scouting.country == "FR",
            ).first()

            if existing_prospect:
                counts["already_in_crm"] += 1
                if existing_scouting:
                    db.delete(existing_scouting)
                continue

            bucket, info = classify(statut_raw)

            if bucket == "deal":
                prospect_status, nda_field = info
                prospect_type = ProspectType.investor if scouting_type == ScoutingType.investor else ProspectType.developer
                p = Prospect(
                    company=company, contact_name=contact, email=email,
                    type=prospect_type, status=prospect_status, country="FR",
                    nda_signed=nda_field,
                    notes=(notes or "") + f"\n[Migration] Statut Sheet d'origine: {statut_raw}",
                    source="Scouting FR (sheet) auto-conversion",
                )
                db.add(p)
                if existing_scouting:
                    db.delete(existing_scouting)
                counts["deal_to_crm"] += 1
                print(f"  -> CRM Prospect ({statut_raw}): {company}")
                continue

            data = {}
            if existing_scouting:
                try:
                    data = json.loads(existing_scouting.data or "{}")
                except Exception:
                    data = {}

            if bucket == "deuxieme":
                status = "deuxieme_connexion"
                data["li_1ere_sent"] = True
                counts["deuxieme"] += 1
            elif bucket == "premiere":
                status = "premiere_connexion"
                if info == "li":
                    data["li_1ere_sent"] = True
                else:
                    data["em_1ere_sent"] = True
                counts["premiere"] += 1
            else:
                status = "to_contact"
                if info == "pas_interesse":
                    data["pas_interesse"] = True
                    counts["pas_interesse"] += 1
                elif info == "pas_pertinent":
                    data["pas_pertinent"] = True
                    counts["pas_pertinent"] += 1
                elif info == "bounced":
                    data["bounced"] = True
                    contact, email = None, None
                    counts["bounced"] += 1
                else:
                    counts["a_scout"] += 1

            if existing_scouting:
                existing_scouting.status = status
                existing_scouting.data = json.dumps(data)
                if not existing_scouting.contact_name and contact:
                    existing_scouting.contact_name = contact
                if not existing_scouting.email and email:
                    existing_scouting.email = email
                existing_scouting.notes = notes
            else:
                s = Scouting(
                    company=company, contact_name=contact, email=email,
                    type=scouting_type, status=status, country="FR",
                    notes=notes, data=json.dumps(data),
                )
                db.add(s)
                counts["created_scouting"] += 1

    db.commit()
    db.close()
    print("\nRésumé:", counts)


if __name__ == "__main__":
    main()
