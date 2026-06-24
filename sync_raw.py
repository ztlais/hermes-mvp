"""Quick sync using raw SQL to avoid ORM issues"""
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import sys, os, re
sys.path.insert(0, '/root/hermes-mvp/backend')
os.chdir('/root/hermes-mvp/backend')

from database import SessionLocal, engine
from sqlalchemy import text

SHEET_ID = '1_g5yrRBoTdBY7ozTpZTTT4xgOKrWS64_WtrGa0LjbIE'

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('sheets', 'v4', credentials=creds)

result = service.spreadsheets().values().get(
    spreadsheetId=SHEET_ID, range='available-internal!1:1000'
).execute()
rows = result.get('values', [])

data_rows = rows[2:] if len(rows) > 2 else []

conn = engine.connect()
updated = 0

for row in data_rows:
    code_str = row[0].strip() if len(row) > 0 and row[0] else ''
    if not code_str.isdigit():
        continue
    code = int(code_str)
    name = row[2].strip() if len(row) > 2 and row[2] else None
    if not name or name.startswith('ex:'):
        continue
    
    # Check project exists
    result = conn.execute(text(f"SELECT id FROM projects WHERE code = {code}"))
    proj_row = result.fetchone()
    if not proj_row:
        continue
    
    proj_id = proj_row[0]
    
    # Build update dict
    updates = {}
    
    # Col 1: Actionnariat SPV (%) → developer_name
    v = row[1].strip() if len(row) > 1 and row[1] else ''
    if v and v not in ('Explication', ''):
        dev = v.split('-')[0].strip() if '-' in v else v
        updates['developer_name'] = dev
    
    # Col 3: État de développement → status_detail
    v = row[3].strip() if len(row) > 3 and row[3] else ''
    if v:
        updates['status_detail'] = v.replace('\n', ' | ')
    
    # Col 5: Typologie → technology_detail
    v = row[5].strip() if len(row) > 5 and row[5] else ''
    if v:
        updates['technology_detail'] = v.replace('\n', ' ')
    
    # Col 6: RTB
    v = row[6].strip() if len(row) > 6 and row[6] else ''
    if v and v != 'ex: Q4 2027':
        updates['rtb_date'] = v.replace('\n', ' ').strip()
    
    # Col 7: COD
    v = row[7].strip() if len(row) > 7 and row[7] else ''
    if v and v != 'prévisionnelle /  contractuelle Date':
        updates['cod_date'] = v.replace('\n', ' ').strip()
    
    # Col 8: Commune
    v = row[8].strip() if len(row) > 8 and row[8] else ''
    if v and v != 'ex: Bordeaux':
        updates['commune'] = v.replace('\n', ' ').strip()
    
    # Col 10: Département
    v = row[10].strip() if len(row) > 10 and row[10] else ''
    if v:
        m = re.match(r'(.+)\((\d+)\)', v)
        if m:
            updates['department'] = m.group(1).strip()
            updates['department_code'] = m.group(2)
    
    # Col 11: Région
    v = row[11].strip() if len(row) > 11 and row[11] else ''
    if v:
        updates['region'] = v
    
    # Col 12: MWc
    v = row[12].strip() if len(row) > 12 and row[12] else ''
    if v and v != 'ex: 5':
        try:
            updates['capacity_mw'] = float(v)
        except: pass
    
    # Col 17: P50
    v = row[17].strip() if len(row) > 17 and row[17] else ''
    if v and v != 'ex: 15 600':
        try:
            updates['p50_mwh'] = float(v.replace(' ', '').replace(',', '.'))
        except: pass
    
    # Col 21: Contrat signé → land_secured
    v = row[21].strip() if len(row) > 21 and row[21] else ''
    if v.lower().startswith('oui') or v.lower().startswith('yes'):
        updates['land_secured'] = True
    
    # Col 31: Type permis
    v = row[31].strip() if len(row) > 31 and row[31] else ''
    if v and v not in ('(PC / DP / ICPE)', ''):
        pt = v.strip(' ()')
        updates['permit_type'] = pt
    
    # Col 32: Statut permis
    v = row[32].strip() if len(row) > 32 and row[32] else ''
    if v and v not in ('(À déposer / Déposé / Accepté / Recours / Purge)', ''):
        ps = v.lower().replace('\n', ' ').strip()
        for kw, status in [('purge','purgé'),('recours','recours'),('déposé','déposé'),
                          ('déposer','à déposer'),('deposer','à déposer')]:
            if kw in ps:
                updates['permit_status'] = status
                break
    
    # Col 36: GRD
    v = row[36].strip() if len(row) > 36 and row[36] else ''
    if v and v not in ('(Enedis / RTE / Autre)', ''):
        updates['grid_operator'] = v.strip(' ()')
    
    # Col 37: Prix raccordement
    v = row[37].strip() if len(row) > 37 and row[37] else ''
    if v and v != '-':
        nums = re.findall(r'[\d.]+', v.replace(' ', ''))
        if nums:
            try:
                cost = float(nums[0])
                if 'M' in v:
                    cost *= 1_000_000
                updates['grid_connection_cost'] = cost
            except: pass
    
    # Col 45: Offtake
    v = row[45].strip() if len(row) > 45 and row[45] else ''
    if v and v not in ('(PPA / OA / AO CRE / Autre)', ''):
        updates['offtake_type'] = v.replace('\n', ' ').strip()
    
    # Col 49: Developer name fallback
    v = row[49].strip() if len(row) > 49 and row[49] else ''
    if v and 'developer_name' not in updates:
        updates['developer_name'] = v
    
    if updates:
        set_clause = ', '.join(f"{k} = :{k}" for k in updates)
        updates['id'] = proj_id
        conn.execute(text(f"UPDATE projects SET {set_clause} WHERE id = :id"), updates)
        print(f"  ✅ Code {code}: {name[:40]} — {len(updates)-1} fields")
        updated += 1

conn.commit()
conn.close()
print(f"\n=== Done: {updated} projects updated ===")
