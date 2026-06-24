from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

msg_id = '19ed763182e82951'
service.users().messages().trash(userId='me', id=msg_id).execute()
print(f"✅ Message {msg_id} trashed")
