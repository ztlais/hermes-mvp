from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

draft_id = 'r4936094277981261891'

try:
    result = service.users().drafts().send(userId='me', body={'id': draft_id}).execute()
    print(f"✅ ENVOYÉ ! Message ID: {result['id']}")
except HttpError as e:
    print(f"❌ Erreur: {e}")
    # Try to get full details
    import json
    details = json.loads(e.content.decode())
    print(f"   Reason: {details.get('error', {}).get('message', 'unknown')}")
