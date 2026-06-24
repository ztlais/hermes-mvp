from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('sheets', 'v4', credentials=creds)

SHEET_ID = '1_g5yrRBoTdBY7ozTpZTTT4xgOKrWS64_WtrGa0LjbIE'

# Read headers + first 3 rows of data from available-internal
result = service.spreadsheets().values().get(
    spreadsheetId=SHEET_ID, range='available-internal!1:5'
).execute()
rows = result.get('values', [])

for ri, row in enumerate(rows):
    print(f"\n=== Row {ri+1} ===")
    for ci, val in enumerate(row):
        if ri < 2 or val:  # show headers always, data only non-empty
            print(f"  Col {ci}: {val}")
