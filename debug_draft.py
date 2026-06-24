from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

draft_id = 'r3125813147860643224'
draft = service.users().drafts().get(userId='me', id=draft_id, format='full').execute()
msg = draft['message']
parts = msg['payload'].get('parts', [])

print(f"=== Draft {draft_id} ===")
print(f"Parts count: {len(parts)}")
for i, p in enumerate(parts):
    fn = p.get('filename', 'NONE')
    mime = p.get('mimeType', 'NONE')
    body_size = p.get('body', {}).get('size', 0)
    print(f"  Part {i}: filename='{fn}' mime={mime} size={body_size}")
    
    # Check nested parts
    for j, sub in enumerate(p.get('parts', [])):
        fn2 = sub.get('filename', 'NONE')
        mime2 = sub.get('mimeType', 'NONE')
        body_size2 = sub.get('body', {}).get('size', 0)
        print(f"    Sub {j}: filename='{fn2}' mime={mime2} size={body_size2}")
