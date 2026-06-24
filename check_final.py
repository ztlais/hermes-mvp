from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

draft_id = 'r4936094277981261891'
draft = service.users().drafts().get(userId='me', id=draft_id, format='full').execute()
msg = draft['message']
headers = msg['payload']['headers']

print("=== DRAFT STATE ===")
for h in headers:
    if h['name'] in ('To', 'Cc', 'Subject', 'From'):
        print(f"{h['name']}: {h['value']}")
