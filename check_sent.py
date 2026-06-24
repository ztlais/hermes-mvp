from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

msg_id = '19ed763182e82951'
msg = service.users().messages().get(userId='me', id=msg_id, format='full').execute()
headers = msg['payload']['headers']

print("=== EMAIL SENT ===")
for h in headers:
    if h['name'] in ('To', 'From', 'Subject', 'Date', 'Cc'):
        print(f"{h['name']}: {h['value']}")

# Check body
import base64
parts = msg['payload'].get('parts', [])
for p in parts:
    if p['mimeType'] == 'text/plain' and 'data' in p.get('body', {}):
        body = base64.urlsafe_b64decode(p['body']['data']).decode('utf-8')
        print(f"\nBody:\n{body[:1000]}")
        break
    # Check nested
    for sub in p.get('parts', []):
        if sub['mimeType'] == 'text/plain' and 'data' in sub.get('body', {}):
            body = base64.urlsafe_b64decode(sub['body']['data']).decode('utf-8')
            print(f"\nBody:\n{body[:1000]}")
            break

# Also check attachments
print(f"\nAttachments:")
for p in parts:
    fn = p.get('filename', '')
    if fn:
        print(f"  - {fn}")
    for sub in p.get('parts', []):
        fn2 = sub.get('filename', '')
        if fn2:
            print(f"  - {fn2}")
