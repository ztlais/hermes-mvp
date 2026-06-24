"""Sync sheet data to database - update all available fields for real projects"""
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import sys, os
sys.path.insert(0, '/root/hermes-mvp/backend')
os.chdir('/root/hermes-mvp/backend')

from database import SessionLocal
from models.project import Project, ProjectTechnology, ProjectStage

SHEET_ID = '1_g5yrRBoTdBY7ozTpZTTT4xgOKrWS64_WtrGa0LjbIE'

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('sheets', 'v4', credentials=creds)

result = service.spreadsheets().values().get(
    spreadsheetId=SHEET_ID, range='available-internal!1:1000'
).execute()
rows = result.get('values', [])

headers2 = rows[1] if len(rows) > 1 else []
data_rows = rows[2:] if len(rows) > 2 else []

db = SessionLocal()
updated = 0
created = 0
skipped = 0

for row in data_rows:
    code_str = row[0].strip() if len(row) > 0 and row[0] else ''
    if not code_str.isdigit():
        continue  # skip header/explanation rows
    code = int(code_str)
    
    name = row[2].strip() if len(row) > 2 and row[2] else None
    if not name or name.startswith('ex:'):
        continue  # skip example rows
    
    # Find existing project by code
    proj = db.query(Project).filter(Project.code == code).first()
    if not proj:
        # Skip projects not in DB yet
        skipped += 1
        continue
    
    # Extract values
    dev_name = row[1].strip() if len(row) > 1 and row[1] else None
    etat_dev = row[3].strip() if len(row) > 3 and row[3] else None
    tech_full = row[4].strip() if len(row) > 4 and row[4] else None
    typologie = row[5].strip() if len(row) > 5 and row[5] else None
    rtb = row[6].strip() if len(row) > 6 and row[6] else None
    cod = row[7].strip() if len(row) > 7 and row[7] else None
    commune = row[8].strip() if len(row) > 8 and row[8] else None
    dept_full = row[10].strip() if len(row) > 10 and row[10] else None
    region = row[11].strip() if len(row) > 11 and row[11] else None
    mw_str = row[12].strip() if len(row) > 12 and row[12] else None
    p50_str = row[17].strip() if len(row) > 17 and row[17] else None
    terrain_type = row[18].strip() if len(row) > 18 and row[18] else None
    contrat_sign = row[21].strip() if len(row) > 21 and row[21] else None
    permit_type = row[31].strip() if len(row) > 31 and row[31] else None
    permit_status = row[32].strip() if len(row) > 32 and row[32] else None
    grid_op = row[36].strip() if len(row) > 36 and row[36] else None
    grid_cost_str = row[37].strip() if len(row) > 37 and row[37] else None
    offtake = row[45].strip() if len(row) > 45 and row[45] else None
    teaser = row[49].strip() if len(row) > 49 and row[49] else None
    
    # Update fields
    if dev_name and not proj.developer_name:
        proj.developer_name = dev_name.split('-')[0].strip() if '-' in dev_name else dev_name
    
    if etat_dev:
        proj.status_detail = etat_dev
    
    if typologie and not proj.technology_detail:
        proj.technology_detail = typologie
    
    if rtb:
        proj.rtb_date = rtb.replace('\n', ' ').strip()
    if cod:
        proj.cod_date = cod.replace('\n', ' ').strip()
    
    if commune and not proj.commune:
        proj.commune = commune.replace('\n', ' ').strip()
    
    if dept_full:
        # Parse "Haute-Saône (70)" format
        import re
        m = re.match(r'(.+)\((\d+)\)', dept_full)
        if m:
            proj.department = m.group(1).strip()
            proj.department_code = m.group(2)
    
    if region:
        proj.region = region
    
    if mw_str:
        try:
            mw = float(mw_str)
            if not proj.capacity_mw:
                proj.capacity_mw = mw
        except:
            pass
    
    if p50_str:
        try:
            p50 = float(p50_str.replace(' ', '').replace(',', '.'))
            if not proj.p50_mwh:
                proj.p50_mwh = p50
        except:
            pass
    
    if contrat_sign:
        lower = contrat_sign.lower()
        if 'oui' in lower or 'yes' in lower:
            proj.land_secured = True
    
    if permit_type and not proj.permit_type:
        pt = permit_type.strip(' ()')
        if pt and pt not in ('PC', 'DP', 'ICPE'):
            pt_map = {'pc': 'PC', 'dp': 'DP', 'icpe': 'ICPE'}
            pt = pt_map.get(pt.lower(), pt)
        if pt and len(pt) < 10:
            proj.permit_type = pt
    
    if permit_status and not proj.permit_status:
        ps = permit_status.lower().replace('\n', ' ').strip()
        for keyword, status in [('purge', 'purgé'),('recours','recours'),('déposé','déposé'),
                                ('deposé','déposé'),('déposer','à déposer'),('deposer','à déposer')]:
            if keyword in ps:
                proj.permit_status = status
                break
    
    if grid_op and not proj.grid_operator:
        go = grid_op.strip(' ()')
        if go and go not in ('Enedis', 'RTE'):
            go_map = {'enedis': 'Enedis', 'rte': 'RTE'}
            go = go_map.get(go.lower(), go)
        if go:
            proj.grid_operator = go
    
    if grid_cost_str and not proj.grid_connection_cost:
        # Try to extract number
        import re
        nums = re.findall(r'[\d.]+', grid_cost_str.replace(' ', ''))
        if nums:
            try:
                cost = float(nums[0])
                if 'M' in grid_cost_str:
                    cost *= 1_000_000
                proj.grid_connection_cost = cost
            except:
                pass
    
    if offtake and not proj.offtake_type:
        proj.offtake_type = offtake.replace('\n', ' ').strip()
    
    if teaser and not proj.developer_name:
        proj.developer_name = teaser
    
    db.flush()
    updated += 1
    print(f"  ✅ Code {code}: {proj.name} — updated")

db.commit()
db.close()
print(f"\n=== Done: {updated} updated, {created} created, {skipped} skipped (no DB match)")
