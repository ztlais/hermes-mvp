from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('sheets', 'v4', credentials=creds)

SHEET_ID = '1_g5yrRBoTdBY7ozTpZTTT4xgOKrWS64_WtrGa0LjbIE'

result = service.spreadsheets().values().get(
    spreadsheetId=SHEET_ID, range='available-internal!1:1000'
).execute()
rows = result.get('values', [])

headers2 = rows[1] if len(rows) > 1 else []

# Count how many data rows
data_rows = rows[2:] if len(rows) > 2 else []
print(f"Data rows: {len(data_rows)}")

# Build column summary: for each col, list sample values
print("\n=== COLUMN SUMMARY ===")
for ci in range(52):
    h2 = headers2[ci] if ci < len(headers2) else f"Col{ci}"
    # Get non-empty values
    vals = []
    for row in data_rows:
        if ci < len(row) and row[ci] and row[ci].strip():
            vals.append(row[ci].strip()[:80])
    if vals:
        unique_vals = list(dict.fromkeys(vals))  # unique, preserve order
        print(f"\n  [{ci:2d}] {h2}")
        print(f"        count={len(vals)}, unique={len(unique_vals)}")
        print(f"        samples: {unique_vals[:4]}")
    else:
        print(f"\n  [{ci:2d}] {h2} — NO DATA")
