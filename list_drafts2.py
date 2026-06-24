from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

# List drafts
results = service.users().drafts().list(userId='me', maxResults=10).execute()
drafts = results.get('drafts', [])

print(f"Found {len(drafts)} drafts:")
for d in drafts:
    draft = service.users().drafts().get(userId='me', id=d['id'], format='full').execute()
    msg = draft['message']
    headers = {h['name']: h['value'] for h in msg['payload']['headers']}
    
    # Count attachments
    parts = msg['payload'].get('parts', [])
    fns = []
    for p in parts:
        fn = p.get('filename', '')
        if fn:
            fns.append(fn)
        for sub in p.get('parts', []):
            fn2 = sub.get('filename', '')
            if fn2:
                fns.append(fn2)
    
    print(f"\n  Draft ID: {d['id']}")
    print(f"  From: {headers.get('From', '')}")
    print(f"  To: {headers.get('To', '(empty)')}")
    print(f"  Subject: {headers.get('Subject', '(empty)')}")
    print(f"  Attachments ({len(fns)}): {fns}")
