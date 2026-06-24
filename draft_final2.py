from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import base64
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
import email.encoders
import os

creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
service = build('gmail', 'v1', credentials=creds)

USER = 'zein.tlais@enechange.com'

# Clean up ALL old drafts I created
old_ids = [
    'r-768029481214201942', 'r3125813147860643224', 'r4936094277981261891',
    'r3940876531373913584', 'r-3632475238113181342', 'r4652357632771582430'
]
for old_id in old_ids:
    try:
        service.users().drafts().delete(userId='me', id=old_id).execute()
    except:
        pass

msg = MIMEMultipart('mixed')
msg['From'] = USER
msg['To'] = ''
msg['Subject'] = ''

# Empty body (needed for Gmail to show attachments)
body = MIMEText('', 'plain')
msg.attach(body)

files = [
    ("/root/hermes-mvp/projets_toiture.xlsx", "projets_toiture.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
    ("/root/hermes-mvp/templates/Enechange_Insight_RE_Developpeurs_FR.pdf", "Enechange_Insight_RE (FR).pdf", "application/pdf"),
    ("/root/hermes-mvp/templates/Developer_EN_2024.pdf", "Developer_(EN)2024_Enechange_Insight_RE.pdf", "application/pdf"),
    ("/root/hermes-mvp/templates/NDA_Dv_form.docx", "NDA_Dv_form.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"),
    ("/root/hermes-mvp/templates/NDA_form.docx", "ENECHANGE_NDA_form_potential_subscriber_and_Developer_template.docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"),
]

for fpath, fname, mime_type in files:
    if os.path.exists(fpath):
        part = MIMEBase('application', 'octet-stream')
        with open(fpath, 'rb') as f:
            part.set_payload(f.read())
        email.encoders.encode_base64(part)
        part.add_header('Content-Disposition', f'attachment; filename="{fname}"')
        part.add_header('Content-Type', mime_type)
        msg.attach(part)
        print(f"✅ {fname} ({mime_type})")
    else:
        print(f"❌ NOT FOUND: {fpath}")

raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()
draft = service.users().drafts().create(userId='me', body={'message': {'raw': raw}}).execute()
draft_id = draft['id']

# Verify
verify = service.users().drafts().get(userId='me', id=draft_id, format='full').execute()
parts = verify['message']['payload'].get('parts', [])
print(f"\n✅ Draft créé ! {len(parts)} partie(s)")
for p in parts:
    fn = p.get('filename', '')
    mime = p.get('mimeType', '')
    sz = p.get('body', {}).get('size', 0)
    if fn:
        print(f"  📎 {fn} ({mime}, {sz} bytes)")
    else:
        print(f"  📝 Corps vide ({mime})")

print(f"\n🔗 https://mail.google.com/mail/#drafts?compose=Draft_{draft_id}")
