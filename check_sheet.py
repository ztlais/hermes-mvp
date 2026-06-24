from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('sheets', 'v4', credentials=creds)

SHEET_ID = '1_g5yrRBoTdBY7ozTpZTTT4xgOKrWS64_WtrGa0LjbIE'

# Get metadata to see sheets/tabs
meta = service.spreadsheets().get(spreadsheetId=SHEET_ID).execute()
print(f"Title: {meta['properties']['title']}")
for s in meta['sheets']:
    print(f"  Tab: '{s['properties']['title']}' (rows={s['properties'].get('gridProperties',{}).get('rowCount','?')}, cols={s['properties'].get('gridProperties',{}).get('columnCount','?')})")
