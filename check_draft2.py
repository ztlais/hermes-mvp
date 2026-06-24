from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

draft_id = 'r-3632475238113181342'
draft = service.users().drafts().get(userId='me', id=draft_id, format='full').execute()
msg = draft['message']
headers = msg['payload']['headers']

print("=== CURRENT DRAFT STATE ===")
for h in headers:
    if h['name'] in ('To', 'Cc', 'Subject', 'From', 'Message-ID', 'Date'):
        print(f"{h['name']}: {h['value']}")
        
# Check body
parts = msg['payload'].get('parts', [])
for p in parts:
    if p['mimeType'] == 'text/plain' and 'data' in p.get('body', {}):
        import base64
        body = base64.urlsafe_b64decode(p['body']['data']).decode('utf-8')
        if body.strip():
            print(f"\nBody:\n{body[:500]}")
            break
