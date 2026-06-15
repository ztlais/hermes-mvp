"""
Script d'import Google Sheets → PostgreSQL
Importe : FR Follow-ups, Investors List, Scouting FR
"""
import sys
import os
import time
import random

sys.path.insert(0, '/root/hermes-dashboard')
sys.path.insert(0, '/root/hermes-mvp/backend')

from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from sqlalchemy.orm import Session

from database import engine, init_db
from models.prospect import Prospect, ProspectStatus, ProspectType
from models.investor import Investor, InvestorStatus, InvestorType
from models.scouting import Scouting, ScoutingStatus, ScoutingType

TOKEN_PATH      = "/root/.hermes/google_token.json"
FR_FOLLOWUPS_ID = "1ZsFcbzY8xIqqmp9OeARIkIqy-2oobQzxXbxn4tHYPQE"
SCOUTING_ID     = "1d6RNjs5whURmDzmPHKcIrELCl0_rC9MRD2BH8Vmte-s"
SCOUTING_BE_ID  = "1L11r7H2DHvvfv0aTq2Xl0kOsM6b_ehOhFYxtc7sjc18"
SCOUTING_ES_ID  = "1M2AmmfVsQGWG2U4IRlyXfiv0JxQxTq8SXjcZkoxCl6s"


def build_service():
    creds = Credentials.from_authorized_user_file(TOKEN_PATH)
    return build("sheets", "v4", credentials=creds)


def get_values(svc, sheet_id, range_name):
    for attempt in range(5):
        try:
            r = svc.spreadsheets().values().get(
                spreadsheetId=sheet_id, range=range_name
            ).execute()
            return r.get("values", [])
        except HttpError as e:
            if e.resp.status in (429, 500, 503) and attempt < 4:
                time.sleep(2 ** attempt + random.uniform(0, 1))
            else:
                raise


def rows_to_dicts(values):
    if not values or len(values) < 2:
        return []
    header = values[0]
    result = []
    for row in values[1:]:
        if len(row) < len(header):
            row = row + [""] * (len(header) - len(row))
        d = {header[i]: row[i].strip() for i in range(len(header))}
        result.append(d)
    return result


def map_prospect_status(row):
    nda = row.get("NDA signed?", "").strip().lower()
    responded = row.get("responded?", "").strip().lower()
    next_steps = row.get("Next steps", "").strip().lower()

    if nda in ("yes", "oui", "✅", "signed"):
        return ProspectStatus.nda_signed
    if any(k in next_steps for k in ["deal", "transaction", "loi", "offre"]):
        return ProspectStatus.deal_in_progress
    if any(k in responded for k in ["yes", "oui", "✅", "replied"]):
        return ProspectStatus.in_discussion
    if row.get("Email", "").strip():
        return ProspectStatus.contacted
    return ProspectStatus.to_contact


def map_scouting_status(statut: str) -> ScoutingStatus:
    s = statut.strip().lower()
    if any(k in s for k in ["linkedin validé", "linkedin envoye", "message linkedin"]):
        return ScoutingStatus.linkedin_sent
    if any(k in s for k in ["envoyé", "envoye", "email envoyé", "mail envoyé"]):
        return ScoutingStatus.email_sent
    if any(k in s for k in ["répondu", "repondu", "replied", "responded"]):
        return ScoutingStatus.responded
    if any(k in s for k in ["rdv", "meeting", "réunion", "call fait"]):
        return ScoutingStatus.meeting_done
    if any(k in s for k in ["converti", "converted", "prospect"]):
        return ScoutingStatus.converted
    if any(k in s for k in ["pas intéressé", "not interested", "no interest", "refus"]):
        return ScoutingStatus.not_interested
    if any(k in s for k in ["pas de réponse", "no response", "silence"]):
        return ScoutingStatus.no_response
    return ScoutingStatus.to_contact


def import_prospects(svc, db: Session):
    print("\n📥 Import FR Follow-ups → prospects...")
    values = get_values(svc, FR_FOLLOWUPS_ID, "Follow-ups!A:O")
    rows = rows_to_dicts(values)

    # Colonnes FR Follow-ups:
    # PS priority CALL | responded? | Priority | Company | POC | NDA signed? |
    # Name + Role | Email | Phone number | Summary / meeting minutes | Next steps |
    # POC_1 | Done? | Contact | Commentaire

    count = 0
    skipped = 0
    for row in rows:
        company = row.get("Company", "").strip()
        if not company:
            skipped += 1
            continue

        # éviter les doublons
        existing = db.query(Prospect).filter(Prospect.company == company).first()
        if existing:
            skipped += 1
            continue

        email = row.get("Email", "").strip()
        phone = row.get("Phone number", "").strip()
        contact = row.get("Name + Role", "").strip()  # vrai contact chez le prospect
        poc = row.get("POC", "").strip()  # Zein ou Mariella (manager EIR)
        nda_raw = row.get("NDA signed?", "").strip().lower()
        nda_signed = "Oui" if nda_raw in ("yes", "oui", "✅", "signed") else "Non"
        notes_parts = []
        if poc:
            notes_parts.append(f"POC EIR: {poc}")
        if row.get("Summary / meeting minutes", "").strip():
            notes_parts.append(row["Summary / meeting minutes"].strip())
        if row.get("Commentaire", "").strip():
            notes_parts.append(row["Commentaire"].strip())

        p = Prospect(
            company=company,
            contact_name=contact or None,
            email=email or None,
            phone=phone or None,
            type=ProspectType.developer,
            status=map_prospect_status(row),
            nda_signed=nda_signed,
            next_action=row.get("Next steps", "").strip() or None,
            notes="\n".join(notes_parts) or None,
            source="FR Follow-ups (import)",
        )
        db.add(p)
        count += 1

    db.commit()
    print(f"   ✅ {count} prospects importés, {skipped} ignorés (vides ou doublons)")
    return count


def import_investors(svc, db: Session):
    print("\n📥 Import Investors List → investors...")
    values = get_values(svc, FR_FOLLOWUPS_ID, "'Investors List'!A:Z")
    rows = rows_to_dicts(values)

    # Colonnes: Relevance | Investisseur | Zone géographique / Projet |
    # Mandat (MW) | Type de projets / Technologies | Préférences / Critères |
    # Remarques | Database FR

    count = 0
    skipped = 0
    for row in rows:
        company = row.get("Investisseur", "").strip()
        if not company:
            skipped += 1
            continue

        existing = db.query(Investor).filter(Investor.company == company).first()
        if existing:
            skipped += 1
            continue

        mandat = row.get("Mandat (MW)", "").strip()
        min_mw, max_mw = None, None
        if mandat:
            parts = mandat.replace("MW", "").replace("mw", "").strip()
            if "-" in parts:
                try:
                    a, b = parts.split("-")
                    min_mw = float(a.strip())
                    max_mw = float(b.strip())
                except:
                    pass
            else:
                try:
                    min_mw = float(parts.replace("+", "").strip())
                except:
                    pass

        inv = Investor(
            company=company,
            type=InvestorType.fund,
            status=InvestorStatus.active,
            target_countries=row.get("Zone géographique / Projet", "").strip() or None,
            technologies=row.get("Type de projets / Technologies", "").strip() or None,
            criteria=row.get("Préférences / Critères", "").strip() or None,
            notes=row.get("Remarques", "").strip() or None,
            min_mw=min_mw,
            max_mw=max_mw,
        )
        db.add(inv)
        count += 1

    db.commit()
    print(f"   ✅ {count} investisseurs importés, {skipped} ignorés")
    return count


def import_scouting_tab(svc, db: Session, sheet_id, tab_name, scouting_type: ScoutingType, company_col, country):
    values = get_values(svc, sheet_id, f"'{tab_name}'!A:Z")
    rows = rows_to_dicts(values)

    count = 0
    skipped = 0
    for row in rows:
        company = row.get(company_col, "").strip()
        if not company:
            skipped += 1
            continue

        existing = db.query(Scouting).filter(
            Scouting.company == company,
            Scouting.type == scouting_type
        ).first()
        if existing:
            skipped += 1
            continue

        statut_raw = row.get("Statut", "").strip()
        notes_parts = []
        for col in ["Zone géographique", "Portefeuille (MW)", "Mandat (MW)", "Technologies", "Stade projets", "Critères", "Notes"]:
            v = row.get(col, "").strip()
            if v:
                notes_parts.append(f"{col}: {v}")

        s = Scouting(
            company=company,
            contact_name=row.get("Contact", "").strip() or None,
            email=row.get("Email", "").strip() or None,
            type=scouting_type,
            status=map_scouting_status(statut_raw),
            country=country,
            notes="\n".join(notes_parts) or None,
        )
        db.add(s)
        count += 1

    db.commit()
    return count, skipped


def import_scouting(svc, db: Session):
    print("\n📥 Import Scouting → scouting...")
    total = 0

    sheets_config = [
        (SCOUTING_ID,    "Prospects Investisseurs", ScoutingType.investor,  "Investisseur", "FR"),
        (SCOUTING_ID,    "Prospects Développeurs",  ScoutingType.developer, "Développeur",  "FR"),
        (SCOUTING_BE_ID, "Prospects Investisseurs", ScoutingType.investor,  "Investisseur", "BE"),
        (SCOUTING_BE_ID, "Prospects Développeurs",  ScoutingType.developer, "Développeur",  "BE"),
        (SCOUTING_ES_ID, "Prospects Investisseurs", ScoutingType.investor,  "Investisseur", "ES"),
        (SCOUTING_ES_ID, "Prospects Développeurs",  ScoutingType.developer, "Développeur",  "ES"),
    ]

    for sheet_id, tab_name, s_type, company_col, country in sheets_config:
        try:
            count, skipped = import_scouting_tab(svc, db, sheet_id, tab_name, s_type, company_col, country)
            print(f"   ✅ Scouting {country} / {tab_name} : {count} importés, {skipped} ignorés")
            total += count
            time.sleep(0.5)
        except Exception as e:
            print(f"   ⚠️  Scouting {country} / {tab_name} : erreur — {e}")

    return total


def main():
    print("🚀 Import Google Sheets → PostgreSQL")
    print("=" * 50)

    init_db()
    svc = build_service()

    with Session(engine) as db:
        p = import_prospects(svc, db)
        time.sleep(1)
        i = import_investors(svc, db)
        time.sleep(1)
        s = import_scouting(svc, db)

    print("\n" + "=" * 50)
    print(f"✅ Import terminé !")
    print(f"   • {p} prospects")
    print(f"   • {i} investisseurs")
    print(f"   • {s} entrées scouting")


if __name__ == "__main__":
    main()
