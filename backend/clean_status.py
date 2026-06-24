from sqlalchemy import text
from database import SessionLocal
import re

db = SessionLocal()
try:
    updates = {
        153: "✅ PC déposé",
        154: "✅ PC obtenu / ⚖️ Recours",
        155: "✅ PC purgé",
        156: "✅ PC déposé",
        157: "✅ PC déposé / ✅ PPA signé",
        158: "✅ PC déposé",
        159: "✅ PC purgé",
        160: "✅ PC déposé",
        161: "✅ PC obtenu / ⚖️ Recours",
        162: "✅ PC déposé",
        183: "✅ PC déposé",
        184: "✅ PC déposé",
    }
    for pid, sf in updates.items():
        db.execute(text("UPDATE projects SET status_fr = :s WHERE id = :pid"),
                   {"s": sf, "pid": pid})
    db.commit()
    
    # Verify
    rows = db.execute(text('SELECT id, code, name, status_fr FROM projects ORDER BY code')).fetchall()
    for r in rows:
        print(f'{r[1]:5} {r[2]:30} {r[3]}')
finally:
    db.close()
