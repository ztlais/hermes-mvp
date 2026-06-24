from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import json

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('sheets', 'v4', credentials=creds)

SHEET_ID = '1_g5yrRBoTdBY7ozTpZTTT4xgOKrWS64_WtrGa0LjbIE'

# Read all data from available-internal
result = service.spreadsheets().values().get(
    spreadsheetId=SHEET_ID, range='available-internal!1:1000'
).execute()
rows = result.get('values', [])

print(f"Total rows read: {len(rows)}")
print(f"Total columns: {max(len(r) for r in rows) if rows else 0}")

# Print headers (rows 1-2)
print("\n=== HEADERS ===")
headers1 = rows[0] if len(rows) > 0 else []
headers2 = rows[1] if len(rows) > 1 else []
for i in range(52):
    h1 = headers1[i] if i < len(headers1) else ''
    h2 = headers2[i] if i < len(headers2) else ''
    if h1 or h2:
        print(f"  Col {i}: {h1} | {h2}")

# Print first 5 data rows (starting from row 3)
print(f"\n=== DATA (rows 3-10) ===")
for ri in range(2, min(12, len(rows))):
    row = rows[ri]
    print(f"\nRow {ri+1} (code={row[0] if len(row) > 0 else '?'}):")
    for ci in range(min(52, len(row))):
        val = row[ci]
        if val and val.strip():
            h2 = headers2[ci] if ci < len(headers2) else f"Col{ci}"
            print(f"  [{ci}] {h2}: {val[:100]}")

print(f"\nTotal data rows: {len(rows) - 2}")
