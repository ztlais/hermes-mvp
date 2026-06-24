from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

# Get ALL drafts
results = service.users().drafts().list(userId='me', maxResults=50).execute()
drafts = results.get('drafts', [])

print(f"Total: {len(drafts)} drafts")

for d in drafts:
    draft = service.users().drafts().get(userId='me', id=d['id'], format='full').execute()
    msg = draft['message']
    headers = {h['name']: h['value'] for h in msg['payload']['headers']}
    
    parts = msg['payload'].get('parts', [])
    fns = [p.get('filename', '') for p in parts if p.get('filename', '')]
    
    has_5 = len(fns) >= 5
    marker = " <<<" if has_5 else ""
    
    print(f"  [{d['id']}] From: {headers.get('From','?')[:30]} | Attachments: {len(fns)} {fns}{marker}")
