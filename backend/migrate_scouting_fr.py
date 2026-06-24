"""
Migration one-off : bascule des entrées Scouting FR vers le nouveau workflow
à 2 colonnes (premiere_connexion / deuxieme_connexion).

À exécuter manuellement une seule fois :
    cd /root/hermes-mvp/backend && python migrate_scouting_fr.py
"""
import json
from sqlalchemy import text

from database import engine, SessionLocal
from models.scouting import Scouting, ScoutingStatus, ScoutingType
from models.prospect import Prospect, ProspectType, ProspectStatus

SCOUTING_TO_PROSPECT_TYPE = {
    ScoutingType.developer: ProspectType.developer,
    ScoutingType.investor: ProspectType.investor,
    ScoutingType.ipp: ProspectType.ipp,
    ScoutingType.family_office: ProspectType.family_office,
}


def add_enum_values():
    with engine.connect() as conn:
        conn.execute(text("ALTER TYPE scoutingstatus ADD VALUE IF NOT EXISTS 'premiere_connexion'"))
        conn.commit()
    with engine.connect() as conn:
        conn.execute(text("ALTER TYPE scoutingstatus ADD VALUE IF NOT EXISTS 'deuxieme_connexion'"))
        conn.commit()
    print("Enum scoutingstatus mis à jour (premiere_connexion, deuxieme_connexion).")


def migrate_data():
    db = SessionLocal()
    fr_rows = db.query(Scouting).filter(Scouting.country == "FR").all()
    print(f"{len(fr_rows)} lignes FR trouvées.")

    counts = {"premiere_connexion": 0, "converted_meeting_done": 0, "already_converted": 0}

    for row in fr_rows:
        if row.status == ScoutingStatus.converted:
            counts["already_converted"] += 1
            continue

        if row.status == ScoutingStatus.meeting_done:
            existing = db.query(Prospect).filter(Prospect.company.ilike(row.company)).first()
            if not existing:
                prospect = Prospect(
                    company=row.company,
                    contact_name=row.contact_name or "",
                    email=row.email or "",
                    linkedin=row.linkedin or "",
                    country=row.country or "FR",
                    type=SCOUTING_TO_PROSPECT_TYPE.get(row.type, ProspectType.other),
                    status=ProspectStatus.contacted,
                    notes=(row.notes or "") + "\n[Migration] RDV déjà effectué avant migration du Scouting FR.",
                )
                db.add(prospect)
            row.status = ScoutingStatus.converted
            counts["converted_meeting_done"] += 1
            print(f"  -> CRM Prospect (meeting_done): {row.company}")
            continue

        # to_contact, email_sent, linkedin_sent, responded -> premiere_connexion
        extra = json.loads(row.data or "{}")
        if row.status == ScoutingStatus.email_sent:
            extra["em_1ere_sent"] = True
        if row.status == ScoutingStatus.linkedin_sent:
            extra["li_1ere_sent"] = True
        row.data = json.dumps(extra)
        row.status = ScoutingStatus.premiere_connexion
        counts["premiere_connexion"] += 1

    db.commit()
    db.close()
    print("Résumé migration:", counts)


if __name__ == "__main__":
    add_enum_values()
    migrate_data()
