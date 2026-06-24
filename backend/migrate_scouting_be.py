"""
Migration Belgique : même méthode que migrate_scouting_fr_v2.py.

1. Reclasse les ~45 lignes du Google Sheet BE (Statut -> à scout / 1ère / 2ème connexion / CRM).
2. Ajoute les entreprises belges trouvées dans le journal personnel de Zein
   ("Scouting Logbook" -> onglet "Zein Tleis") qui ne sont dans aucune des
   tables scouting/prospects/investors, en mappant leur "Scouting Stage".
3. Pour les entreprises déjà présentes (doublons), ne crée rien — si le
   journal indique un stade plus avancé que celui calculé depuis le sheet,
   on prend le plus avancé.

À exécuter manuellement : python migrate_scouting_be.py
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
from migrate_scouting_fr_v2 import norm, classify, classify_deal, build_notes, NOTE_COLS

TOKEN_PATH = "/root/.hermes/google_token.json"
SCOUTING_BE_ID = "1L11r7H2DHvvfv0aTq2Xl0kOsM6b_ehOhFYxtc7sjc18"
LOGBOOK_ID = "1jT05VEQ2_PpOaMPXTKjaB0Io4UkxHOGDcf9AY6fCP4k"

TABS = [
    ("Prospects Investisseurs", ScoutingType.investor, "Investisseur"),
    ("Prospects Développeurs", ScoutingType.developer, "Développeur"),
]

STAGE_RANK = {"to_contact": 0, "premiere_connexion": 1, "deuxieme_connexion": 2}


def build_service():
    creds = Credentials.from_authorized_user_file(TOKEN_PATH)
    return build("sheets", "v4", credentials=creds)


def get_rows(svc, sheet_id, tab, rng="A:Z"):
    values = svc.spreadsheets().values().get(spreadsheetId=sheet_id, range=f"'{tab}'!{rng}").execute().get("values", [])
    if not values or len(values) < 2:
        return []
    header = values[0]
    out = []
    for row in values[1:]:
        if len(row) < len(header):
            row = row + [""] * (len(header) - len(row))
        out.append({header[i]: row[i].strip() for i in range(len(header))})
    return out


def apply_bucket(existing, bucket, info, company, scouting_type, contact, email, notes, db, counts, country):
    """Update existing scouting row or create a new one for a (non-deal) bucket."""
    data = {}
    if existing:
        try:
            data = json.loads(existing.data or "{}")
        except Exception:
            data = {}

    if bucket == "deuxieme":
        status = "deuxieme_connexion"
        data["li_1ere_sent"] = True
    elif bucket == "premiere":
        status = "premiere_connexion"
        if info == "li":
            data["li_1ere_sent"] = True
        else:
            data["em_1ere_sent"] = True
    else:
        status = "to_contact"
        if info in ("pas_interesse", "pas_pertinent", "bounced"):
            data[info] = True

    counts[bucket if bucket != "a_scout" else (info or "a_scout")] += 1

    # Ne jamais régresser un statut déjà plus avancé (ex: doublon avec stade différent)
    if existing and STAGE_RANK.get(existing.status, 0) > STAGE_RANK.get(status, 0):
        status = existing.status

    if existing:
        existing.status = status
        existing.data = json.dumps(data)
        if not existing.contact_name and contact:
            existing.contact_name = contact
        if not existing.email and email:
            existing.email = email
        if notes:
            existing.notes = notes
    else:
        s = Scouting(
            company=company, contact_name=contact, email=email,
            type=scouting_type, status=status, country=country,
            notes=notes, data=json.dumps(data),
        )
        db.add(s)
        db.flush()
        return s
    return existing


def process_row(db, company, scouting_type, statut_raw, contact, email, notes, country, counts):
    existing_prospect = db.query(Prospect).filter(func.lower(Prospect.company) == company.lower()).first()
    existing_scouting = db.query(Scouting).filter(
        func.lower(Scouting.company) == company.lower(),
        Scouting.type == scouting_type,
        Scouting.country == country,
    ).first()

    if existing_prospect:
        counts["already_in_crm"] += 1
        if existing_scouting:
            db.delete(existing_scouting)
        return

    bucket, info = classify(statut_raw)

    if bucket == "deal":
        prospect_status, nda_field = info
        prospect_type = ProspectType.investor if scouting_type == ScoutingType.investor else ProspectType.developer
        p = Prospect(
            company=company, contact_name=contact, email=email,
            type=prospect_type, status=prospect_status, country=country,
            nda_signed=nda_field,
            notes=(notes or "") + f"\n[Migration] Statut d'origine: {statut_raw}",
            source="Scouting BE auto-conversion",
        )
        db.add(p)
        if existing_scouting:
            db.delete(existing_scouting)
        counts["deal_to_crm"] += 1
        print(f"  -> CRM Prospect ({statut_raw}): {company}")
        return

    apply_bucket(existing_scouting, bucket, info, company, scouting_type, contact, email, notes, db, counts, country)


def main():
    svc = build_service()
    db = SessionLocal()
    counts = {"already_in_crm": 0, "deal_to_crm": 0, "deuxieme": 0, "premiere": 0,
              "a_scout": 0, "pas_interesse": 0, "pas_pertinent": 0, "bounced": 0,
              "from_logbook": 0}

    print("=== Reclassement depuis le Google Sheet BE ===")
    for tab, scouting_type, company_col in TABS:
        rows = get_rows(svc, SCOUTING_BE_ID, tab)
        print(f"--- {tab} ({len(rows)} lignes) ---")
        for row in rows:
            company = row.get(company_col, "").strip()
            if not company:
                continue
            process_row(
                db, company, scouting_type, row.get("Statut", ""),
                row.get("Contact", "").strip() or None, row.get("Email", "").strip() or None,
                build_notes(row), "BE", counts,
            )
    db.flush()

    print("\n=== Ajout des entreprises belges du journal Zein (absentes du sheet structuré) ===")
    log_rows = get_rows(svc, LOGBOOK_ID, "Zein Tleis", "A:F")
    seen_companies = set()
    for row in log_rows:
        company = row.get("Company", "").strip()
        country_raw = row.get("Country", "").strip().lower()
        is_belgium = "belg" in country_raw or country_raw == "be"
        if not company or not is_belgium:
            continue
        key = company.lower()
        if key in seen_companies:
            continue
        seen_companies.add(key)

        existing_prospect = db.query(Prospect).filter(func.lower(Prospect.company) == company.lower()).first()
        if existing_prospect:
            continue
        # déjà traité par le sheet structuré ? (developer par défaut si type inconnu)
        existing_scouting = db.query(Scouting).filter(
            func.lower(Scouting.company) == company.lower(),
            Scouting.country == "BE",
        ).first()

        statut_raw = row.get("Scouting Stage", "")
        bucket, info = classify(statut_raw)
        notes = row.get("Notes", "").strip() or None

        if bucket == "deal":
            prospect_status, nda_field = info
            p = Prospect(
                company=company, type=ProspectType.developer, status=prospect_status,
                country="BE", nda_signed=nda_field,
                notes=(notes or "") + f"\n[Migration journal Zein] Stade: {statut_raw}",
                source="Journal scouting Zein (logbook)",
            )
            db.add(p)
            if existing_scouting:
                db.delete(existing_scouting)
            counts["deal_to_crm"] += 1
            print(f"  -> CRM Prospect (journal, {statut_raw}): {company}")
            continue

        if existing_scouting:
            # doublon déjà géré par le sheet structuré : on prend le stade le plus avancé
            apply_bucket(existing_scouting, bucket, info, company, existing_scouting.type,
                         None, None, None, db, counts, "BE")
        else:
            new_row = apply_bucket(None, bucket, info, company, ScoutingType.developer,
                                    None, None, notes, db, counts, "BE")
            counts["from_logbook"] += 1

    db.commit()
    db.close()
    print("\nRésumé:", counts)


if __name__ == "__main__":
    main()
