from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import base64

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

# Get the draft we created
draft_id = 'r-3632475238113181342'
draft = service.users().drafts().get(userId='me', id=draft_id, format='full').execute()
msg = draft['message']
headers = msg['payload']['headers']

print("=== DRAFT DETAILS ===")
for h in headers:
    if h['name'] in ('To', 'Cc', 'Bcc', 'Subject', 'From'):
        print(f"{h['name']}: {h['value']}")

# Check attachments
parts = msg['payload'].get('parts', [msg['payload']])
print(f"\n=== PARTS ({len(parts)}) ===")
for i, p in enumerate(parts):
    fn = p.get('filename', '')
    mime = p.get('mimeType', '')
    print(f"  Part {i}: {fn} ({mime})")
    # Also check nested parts
    for j, sub in enumerate(p.get('parts', [])):
        fn2 = sub.get('filename', '')
        mime2 = sub.get('mimeType', '')
        print(f"    Sub-part {j}: {fn2} ({mime2})")
