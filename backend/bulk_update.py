from sqlalchemy import text
from database import SessionLocal

db = SessionLocal()
try:
    updates = [
        (160, "advanced", "✅ PC déposé (10/2025) / ⏳ Décision 06/2026 / ✅ PRAC signé"),
        (161, "nearly_secured", "✅ PC obtenu / ⚖️ Recours / ⏳ Purge 08/2026 / ✅ PRAC signé"),
        (162, "advanced", "✅ PC déposé (11/2023) / ⏳ Décision 07/2026 / ✅ PRAC signé"),
        (163, "early", "✅ Bail sécurisé / 📝 PC à déposer 07/2026"),
        (164, "early", "✅ Bail sécurisé / 📝 PC à déposer 09/2026"),
        (165, "early", "✅ Bail sécurisé / 📝 PC à déposer 10/2026"),
        (166, "early", "✅ Bail sécurisé / 📝 PC à déposer 04/2027"),
        (167, "secured_and_clean", "✅ PC purgé / ✅ Bail sécurisé"),
        (168, "secured_and_clean", "✅ PC purgé / ✅ Bail sécurisé"),
        (169, "secured_and_clean", "✅ PC purgé / ✅ Bail sécurisé"),
        (170, "secured_and_clean", "✅ PC purgé / ✅ Bail sécurisé"),
        (171, "secured_and_clean", "✅ PC purgé / ✅ Bail sécurisé"),
        (172, "secured_and_clean", "✅ PC purgé / ✅ Bail sécurisé"),
        (173, "secured_and_clean", "✅ PC purgé / ✅ Bail sécurisé"),
        (174, "secured_and_clean", "✅ PC purgé / ✅ Bail sécurisé"),
        (175, "secured_and_clean", "✅ PC purgé / ✅ Bail sécurisé"),
        (176, "secured_and_clean", "✅ PC purgé / ✅ Bail sécurisé"),
        (177, "early", "✅ Bail sécurisé / 📝 EIE & PC à déposer Q2 2027"),
        (178, "early", "✅ Bail sécurisé / 📝 EIE & PC à déposer Q3 2027"),
        (179, "early", "✅ Bail sécurisé / 📝 EIE & PC à déposer Q4 2027"),
        (180, "early", "✅ Bail sécurisé / 📝 EIE & PC à déposer Q4 2027"),
        (181, "early", "✅ Bail sécurisé / 📝 EIE & PC à déposer Q4 2026"),
        (182, "early", "✅ Bail sécurisé / 📝 EIE & PC à déposer Q1 2027"),
        (183, "advanced", "✅ PC déposé (Q1 2026) / ⏳ Instruction"),
        (184, "advanced", "✅ PC déposé (Q4 2025) / ⏳ Instruction"),
        (185, "origination", "🔍 Identification foncier en cours"),
        (186, "origination", "🔍 Identification foncier en cours"),
        (187, "origination", "🔍 Identification foncier en cours"),
        (188, "origination", "🔍 Identification foncier en cours"),
        (189, "origination", "🔍 Identification foncier en cours"),
        (190, "origination", "🔍 Identification foncier en cours"),
        (191, "origination", "🔍 Identification foncier en cours"),
    ]
    for pid, stage, status_fr in updates:
        db.execute(
            text("UPDATE projects SET stage = :stage, status_fr = :status_fr WHERE id = :pid"),
            {"stage": stage, "status_fr": status_fr, "pid": pid}
        )
    db.commit()
    print(f"✅ {len(updates)} projets mis à jour avec succès")
finally:
    db.close()
