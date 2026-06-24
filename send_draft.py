from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import json

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

# List drafts to find the one we created
results = service.users().drafts().list(userId='me').execute()
drafts = results.get('drafts', [])

print(f"Found {len(drafts)} draft(s):")
for d in drafts:
    msg = service.users().drafts().get(userId='me', id=d['id'], format='metadata').execute()
    headers = msg['message']['payload']['headers']
    subject = next((h['value'] for h in headers if h['name'] == 'Subject'), 'No subject')
    to = next((h['value'] for h in headers if h['name'] == 'To'), 'No to')
    print(f"  ID: {d['id']} → To: {to} | Subject: {subject}")

# Send it
if drafts:
    draft_id = drafts[-1]['id']  # most recent
    print(f"\nSending draft: {draft_id}")
    result = service.users().drafts().send(userId='me', body={'id': draft_id}).execute()
    print(f"✅ Sent! Message ID: {result.get('id', 'unknown')}")
else:
    print("❌ No drafts found")
