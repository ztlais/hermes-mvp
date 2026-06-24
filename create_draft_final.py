from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import base64
import email
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
import email.encoders
import os

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

USER = 'zein.tlais@enechange.com'

# Delete old empty draft
try:
    service.users().drafts().delete(userId='me', id='r3940876531373913584').execute()
except:
    pass

msg = MIMEMultipart()
msg['From'] = USER
msg['To'] = ''     # vide
msg['Subject'] = '' # vide

# No body - truly empty draft
files = [
    ("/root/hermes-mvp/projets_toiture.xlsx", "projets_toiture.xlsx"),
    ("/root/hermes-mvp/templates/Enechange_Insight_RE_Developpeurs_FR.pdf", "Enechange_Insight_RE (FR).pdf"),
    ("/root/hermes-mvp/templates/Developer_EN_2024.pdf", "Developer_(EN)2024_Enechange_Insight_RE.pdf"),
    ("/root/hermes-mvp/templates/NDA_Dv_form.docx", "NDA_Dv_form.docx"),
    ("/root/hermes-mvp/templates/NDA_form.docx", "【雛形】ENECHANGE_NDA_form_potential subscriber and Developer_template.docx"),
]

for fpath, fname in files:
    if os.path.exists(fpath):
        part = MIMEBase('application', 'octet-stream')
        with open(fpath, 'rb') as f:
            part.set_payload(f.read())
        email.encoders.encode_base64(part)
        part.add_header('Content-Disposition', f'attachment; filename="{fname}"')
        msg.attach(part)
        print(f"✅ {fname}")
    else:
        print(f"❌ NOT FOUND: {fpath}")

raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()
draft = service.users().drafts().create(userId='me', body={'message': {'raw': raw}}).execute()
print(f"\n✅ Draft vierge créé ! ID: {draft['id']}")
print("   Va dans Gmail → Brouillons, tu verras les 5 pièces jointes.")
