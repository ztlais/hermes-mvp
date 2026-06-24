from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import base64
import email
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
import os

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

USER = 'zein.tlais@enechange.com'

# Delete the existing draft with the body text
try:
    # Delete the old draft
    service.users().drafts().delete(userId='me', id='r-3632475238113181342').execute()
    print("✅ Old draft deleted")
except Exception as e:
    print(f"Note: {e}")

# Create a completely empty draft with just attachments
msg = MIMEMultipart()
msg['From'] = USER
msg['To'] = ''  # empty
msg['Subject'] = ''  # empty

# No body text - just attachments

files = [
    ("/root/hermes-mvp/projets_toiture.xlsx", "projets_toiture.xlsx"),
    ("/root/hermes-mvp/templates/Enechange_Insight_RE (FR).pdf", "Enechange_Insight_RE (FR).pdf"),
    ("/root/hermes-mvp/templates/Developer_(EN)2024_Enechange_Insight_RE.pdf", "Developer_(EN)2024_Enechange_Insight_RE.pdf"),
    ("/root/hermes-mvp/templates/NDA_Dv_form.docx", "NDA_Dv_form.docx"),
    ("/root/hermes-mvp/templates/NDA_form_potential subscriber and Developer_template.docx", "NDA_form_potential subscriber and Developer_template.docx"),
]

for fpath, fname in files:
    if os.path.exists(fpath):
        part = MIMEBase('application', 'octet-stream')
        with open(fpath, 'rb') as f:
            part.set_payload(f.read())
        import email.encoders
        email.encoders.encode_base64(part)
        part.add_header('Content-Disposition', f'attachment; filename="{fname}"')
        msg.attach(part)
        print(f"  ✅ Attached: {fname}")
    else:
        print(f"  ⚠️ Not found: {fpath}")

# Create the draft (no body at all — just attachments)
raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()
draft_body = {'message': {'raw': raw}}
draft = service.users().drafts().create(userId='me', body=draft_body).execute()
print(f"\n✅ Draft created! ID: {draft['id']}")
print(f"   Open Gmail → Brouillons to see it")
