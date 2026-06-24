from sqlalchemy import text
from database import SessionLocal

db = SessionLocal()
try:
    updates = [
        (147, "Purgé (30/04/2025)"),
        (148, "À déposer (Q2 2026)"),
        (149, "À déposer (Q2 2027)"),
        (150, "À déposer (Q2 2027)"),
        (151, "À déposer (Q1 2026)"),
        (152, "À déposer (Q4 2026)"),
        (153, "Submitted (12/10/2025)"),
        (154, "Obtenu (recours) - purge prévue 8/30/2026"),
        (155, "Purgé (10/14/2024)"),
        (156, "Submitted (4/15/2025)"),
        (157, "Submitted (12/17/2024)"),
        (158, "Submitted"),
        (159, "Purgé (12/9/2025)"),
        (160, "Submitted (10/30/2025)"),
        (161, "Obtenu (recours) - purge prévue 8/30/2026"),
        (162, "Submitted (11/10/2023)"),
        (163, "À déposer (07/2026)"),
        (164, "À déposer (09/2026)"),
        (165, "À déposer (10/2026)"),
        (166, "À déposer (04/2027)"),
        (167, "Purgé"),
        (168, "Purgé"),
        (169, "Purgé"),
        (170, "Purgé"),
        (171, "Purgé"),
        (172, "Purgé"),
        (173, "Purgé"),
        (174, "Purgé"),
        (175, "Purgé"),
        (176, "Purgé"),
        (177, "À déposer (Q2 2027)"),
        (178, "À déposer (Q3 2027)"),
        (179, "À déposer (Q4 2027)"),
        (180, "À déposer (Q4 2027)"),
        (181, "À déposer (Q4 2026)"),
        (182, "À déposer (Q1 2027)"),
        (183, "Submitted (Q1 2026)"),
        (184, "Submitted (Q4 2025)"),
        (185, "Pas d'info"),
        (186, "Pas d'info"),
        (187, "Pas d'info"),
        (188, "Pas d'info"),
        (189, "Pas d'info"),
        (190, "Pas d'info"),
        (191, "Pas d'info"),
    ]
    for pid, status in updates:
        db.execute(text("UPDATE projects SET permis_status = :s WHERE id = :pid"),
                   {"s": status, "pid": pid})
    db.commit()
    
    rows = db.execute(text('SELECT id, code, name, permis_status FROM projects ORDER BY code')).fetchall()
    for r in rows:
        print(f"  {r[1]:5} {r[2]:30} {r[3]}")
finally:
    db.close()
