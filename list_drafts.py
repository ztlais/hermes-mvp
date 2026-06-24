from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

results = service.users().drafts().list(userId='me', maxResults=10).execute()
drafts = results.get('drafts', [])

print(f"Found {len(drafts)} drafts")
for d in drafts:
    msg = service.users().drafts().get(userId='me', id=d['id'], format='metadata').execute()
    headers = msg['message']['payload']['headers']
    to = next((h['value'] for h in headers if h['name'] == 'To'), '')
    subj = next((h['value'] for h in headers if h['name'] == 'Subject'), '')
    # Count attachments
    parts = msg['message']['payload'].get('parts', [])
    attach_count = sum(1 for p in parts if p.get('filename', ''))
    print(f"  [{d['id']}] To: {to or '(empty)'} | Subject: {subj or '(empty)'} | Attachments: {attach_count}")
