"""
Sync projects from Google Sheet cache to PostgreSQL using raw SQL.
Bypasses SQLAlchemy FK issues.
"""
import sys
sys.path.insert(0, '/root/hermes-mvp/backend')

import json
import re
from database import engine, SessionLocal
from models.project import Project, ProjectStage, ProjectTechnology
from stage_classifier import classify
from sqlalchemy import text

# Load cache
with open('/root/hermes-dashboard/bdd_cache.json') as f:
    cache = json.load(f)

content = cache['available-internal']
header = content['header']
rows = content['data']

def get(row, name):
    try:
        idx = header.index(name)
        val = row[idx] if idx < len(row) else ''
        return val.strip() if val else ''
    except (ValueError, IndexError):
        return ''

def get_float(row, name):
    v = get(row, name)
    if not v:
        return None
    # Handle French format: "1 500,50" or "1500.50"
    v = v.replace(',', '.').replace(' ', '')
    # Remove thousand separators (only if more than 3 digits after)
    if v.count('.') > 1:
        parts = v.split('.')
        v = ''.join(parts[:-1]) + '.' + parts[-1]
    m = re.search(r'-?[\d.]+', v)
    if m:
        try:
            return float(m.group())
        except ValueError:
            return None
    return None

def map_tech(tech_str):
    t = tech_str.lower()
    if 'éolien' in t or 'wind' in t or 'eolien' in t:
        return 'wind'
    if 'agri' in t or 'pv' in t or 'solaire' in t or 'solar' in t:
        return 'solar'
    if 'bess' in t or 'stockage' in t or 'battery' in t:
        return 'bess'
    if 'hydro' in t:
        return 'hydro'
    if 'biomasse' in t or 'biomass' in t:
        return 'biomass'
    return 'solar'

conn = engine.connect()
# Truncate
conn.execute(text("TRUNCATE TABLE projects CASCADE"))
conn.commit()

inserted = 0
for row in rows:
    name = get(row, 'Nom du projet')
    if not name or name == 'nan':
        continue

    code_str = get(row, 'Code')
    code = int(code_str) if code_str and code_str.isdigit() else None
    etat = get(row, 'État de développement')
    tech_str = get(row, 'Technologie')
    code_postal = get(row, 'Code postal')

    # Classement automatique (custom_stage est la source de vérité, stage en dérive)
    classified = classify(etat)
    custom_stage = classified['custom_stage']
    stage = classified['stage']
    status_fr = classified['status_fr']
    status_en = classified['status_en']

    # Build raw_data JSON
    raw_data = {}
    for j, h in enumerate(header):
        val = row[j] if j < len(row) else ''
        if val and val.strip() and val.strip() != 'nan':
            raw_data[h] = val.strip()

    tech = map_tech(tech_str)

    conn.execute(
        text("""
        INSERT INTO projects (
            code, name, developer_name, developer_id,
            technology, technology_detail, stage, status_detail,
            capacity_mw, p50_mwh, country, region, commune, department, department_code,
            rtb_date, cod_date, permit_status, permit_type, land_secured,
            grid_operator, grid_connection_cost, offtake_type,
            notes, raw_data, custom_stage, status_fr, status_en
        ) VALUES (
            :code, :name, :dev, :dev_id,
            :tech, :tech_detail, :stage, :status_detail,
            :mw, :p50, :country, :region, :commune, :dept, :dept_code,
            :rtb, :cod, :permit_status, :permit_type, :land_secured,
            :grid_op, :grid_cost, :offtake,
            :notes, :raw_data, :custom_stage, :status_fr, :status_en
        )
        """),
        {
            "code": code,
            "name": name,
            "dev": get(row, 'Actionnariat SPV (%)') or None,
            "dev_id": None,
            "tech": tech,
            "tech_detail": get(row, 'Typologie') or tech_str or None,
            "stage": stage,
            "status_detail": etat or None,
            "mw": get_float(row, 'Puissance installée (MWc)'),
            "p50": get_float(row, 'Production annuelle / P50 (MWh)'),
            "country": 'FR',
            "region": get(row, 'Région') or None,
            "commune": get(row, 'Ville / Commune') or None,
            "dept": get(row, 'Département') or None,
            "dept_code": code_postal[:2] if code_postal else None,
            "rtb": get(row, 'Date RTB estimée') or None,
            "cod": get(row, 'Date COD estimée') or None,
            "permit_status": None,
            "permit_type": None,
            "land_secured": 'land secured' in etat.lower() or 'sécuris' in etat.lower() or get(row, 'Contrat foncier signé ?').lower().startswith('oui'),
            "grid_op": get(row, 'Gestionnaire réseau') or None,
            "grid_cost": get_float(row, 'Prix raccordement (€)'),
            "offtake": get(row, "Type d'offtake") or None,
            "notes": get(row, 'Notes') or None,
            "raw_data": json.dumps(raw_data, ensure_ascii=False),
            "custom_stage": custom_stage,
            "status_fr": status_fr,
            "status_en": status_en,
        }
    )
    inserted += 1
    if inserted % 20 == 0:
        print(f"  {inserted}...")
        conn.commit()

conn.commit()
conn.close()
print(f"\n✅ {inserted} projets synchronisés depuis la Google Sheet.")
