from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

# Get user profile to verify account
profile = service.users().getProfile(userId='me').execute()
print(f"Connected as: {profile.get('emailAddress', '?')}")

# Check specific draft
draft_id = 'r-768029481214201942'
try:
    draft = service.users().drafts().get(userId='me', id=draft_id, format='full').execute()
    headers = {h['name']: h['value'] for h in draft['message']['payload']['headers']}
    print(f"Draft exists!\n  From: {headers.get('From', '?')}\n  To: '{headers.get('To', '')}'\n  Subject: '{headers.get('Subject', '')}'")
    parts = draft['message']['payload'].get('parts', [])
    print(f"  Attachments: {len(parts)}")
    
    # Generate direct Gmail link to this draft
    print(f"\n  Direct link: https://mail.google.com/mail/#drafts?compose=Draft_{draft_id}")
except Exception as e:
    print(f"Error: {e}")
    # Maybe it was saved differently, try listing most recent
    results = service.users().drafts().list(userId='me', maxResults=5).execute()
    for d in results.get('drafts', []):
        print(f"Draft: {d['id']}")
