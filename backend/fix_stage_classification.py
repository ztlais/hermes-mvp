"""
Recalcule stage / custom_stage / status_detail / status_fr / status_en pour tous
les projets existants à partir de raw_data, sans toucher au reste (pas de TRUNCATE).
"""
import sys, json
sys.path.insert(0, '/root/hermes-mvp/backend')

from database import engine
from stage_classifier import classify
from sqlalchemy import text

conn = engine.connect()
rows = conn.execute(text("SELECT id, code, name, raw_data, custom_stage, stage FROM projects")).fetchall()

updated = 0
for r in rows:
    raw_data = json.loads(r.raw_data) if r.raw_data else {}
    etat = raw_data.get('État de développement', '')
    classified = classify(etat)

    if classified['custom_stage'] != r.custom_stage or classified['stage'] != r.stage:
        print(f"  Code {r.code} ({r.name}): {r.custom_stage}/{r.stage} -> {classified['custom_stage']}/{classified['stage']}")

    conn.execute(
        text("""
            UPDATE projects SET stage = :stage, custom_stage = :custom_stage,
                status_detail = :status_detail, status_fr = :status_fr, status_en = :status_en
            WHERE id = :id
        """),
        {**classified, "id": r.id}
    )
    updated += 1

conn.commit()
conn.close()
print(f"\n✅ {updated} projets re-classifiés.")
