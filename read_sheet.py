from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('sheets', 'v4', credentials=creds)

SHEET_ID = '1_g5yrRBoTdBY7ozTpZTTT4xgOKrWS64_WtrGa0LjbIE'

# Read headers from available-internal
result = service.spreadsheets().values().get(
    spreadsheetId=SHEET_ID, range='available-internal!1:2'
).execute()
rows = result.get('values', [])

print("=== Row 1 (header 1) ===")
cols1 = rows[0] if len(rows) > 0 else []
for i, h in enumerate(cols1):
    print(f"  Col {i}: {h}")

print(f"\n=== Row 2 (header 2) ===")
cols2 = rows[1] if len(rows) > 1 else []
for i, h in enumerate(cols2):
    if h:
        print(f"  Col {i}: {h}")
