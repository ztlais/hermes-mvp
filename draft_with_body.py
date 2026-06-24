from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import base64
import email
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
import email.encoders
import os

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

USER = 'zein.tlais@enechange.com'

# Delete old drafts
for old_id in ['r-768029481214201942', 'r3125813147860643224']:
    try:
        service.users().drafts().delete(userId='me', id=old_id).execute()
    except:
        pass

msg = MIMEMultipart()
msg['From'] = USER
msg['To'] = ''
msg['Subject'] = ''

# Add an empty text body so Gmail displays properly
msg.attach(MIMEText('', 'plain', 'utf-8'))
msg.attach(MIMEText('', 'html', 'utf-8'))

files = [
    ("/root/hermes-mvp/projets_toiture.xlsx", "projets_toiture.xlsx"),
    ("/root/hermes-mvp/templates/Enechange_Insight_RE_Developpeurs_FR.pdf", "Enechange_Insight_RE (FR).pdf"),
    ("/root/hermes-mvp/templates/Developer_EN_2024.pdf", "Developer_(EN)2024_Enechange_Insight_RE.pdf"),
    ("/root/hermes-mvp/templates/NDA_Dv_form.docx", "NDA_Dv_form.docx"),
    ("/root/hermes-mvp/templates/NDA_form.docx", "ENECHANGE_NDA_form_potential_subscriber_and_Developer_template.docx"),
]

for fpath, fname in files:
    if os.path.exists(fpath):
        part = MIMEBase('application', 'octet-stream')
        with open(fpath, 'rb') as f:
            part.set_payload(f.read())
        email.encoders.encode_base64(part)
        part.add_header('Content-Disposition', 'attachment', filename=fname)
        msg.attach(part)
        print(f"✅ {fname}")
    else:
        print(f"❌ NOT FOUND: {fpath}")

raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()
draft = service.users().drafts().create(userId='me', body={'message': {'raw': raw}}).execute()
print(f"\n✅ Draft créé ! ID: {draft['id']}")

# Verify
verify = service.users().drafts().get(userId='me', id=draft['id'], format='full').execute()
parts = verify['message']['payload'].get('parts', [])
print(f"Vérification : {len(parts)} parties")
for p in parts:
    fn = p.get('filename', '')
    mime = p.get('mimeType', '')
    sz = p.get('body', {}).get('size', 0)
    print(f"  - '{fn}' ({mime}, {sz} bytes)")

print(f"\n🔗 https://mail.google.com/mail/#drafts?compose=Draft_{draft['id']}")
