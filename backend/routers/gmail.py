from fastapi import APIRouter, Depends, HTTPException
from auth import get_current_user
from models.user import User
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import json
import base64
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email import encoders

router = APIRouter(prefix="/gmail", tags=["gmail"])

FILE_IDS = [
    "1f1CYFkgIaXUcpVaybXTTxeNnDX9abnhs",  # projets_toiture.xlsx
    "1Nytf2_A9kscnMA8M1DmLn6gObG-PIQiY",  # Presentation EIR
    "1bfQ_Wbpk09A0UejSkcima9c60PRMUrNg",  # NDA Standard EIR
    "1g2C2H18SRXD52ggSd6EqYDq8L10s3VGQ",  # Document EIR 1
    "1PE5yaFPfMfjzMyPPPmD5o4evbpF8Us-Q",  # Document EIR 2
]

EXT_MIME = {
    "pdf":  "application/pdf",
    "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "doc":  "application/msword",
    "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
}


@router.get("/compose-draft")
def create_compose_draft(current_user: User = Depends(get_current_user)):
    try:
        with open('/root/.hermes/google_token.json') as f:
            token_data = json.load(f)
        creds = Credentials.from_authorized_user_info(token_data)

        drive = build('drive', 'v3', credentials=creds)
        gmail = build('gmail', 'v1', credentials=creds)

        msg = MIMEMultipart()
        msg['To'] = ''
        msg['Subject'] = ''

        text = MIMEText(
            'Bonjour,\n\n'
            'Veuillez trouver ci-joint les documents.\n\n'
            'Cordialement,\n'
            'Zein Tlais\n',
            'plain', 'utf-8'
        )
        msg.attach(text)

        for file_id in FILE_IDS:
            meta = drive.files().get(fileId=file_id, fields='name,mimeType').execute()
            gdrive_mime = meta['mimeType']
            orig_name = meta['name']

            if gdrive_mime == 'application/vnd.google-apps.document':
                content = drive.files().export(
                    fileId=file_id, mimeType='application/pdf'
                ).execute()
                attach_name = orig_name.rsplit('.', 1)[0] + '.pdf'
                attach_mime = 'application/pdf'
            else:
                content = drive.files().get_media(fileId=file_id).execute()
                attach_name = orig_name
                ext = orig_name.rsplit('.', 1)[-1].lower() if '.' in orig_name else 'bin'
                attach_mime = EXT_MIME.get(ext, gdrive_mime)

            part = MIMEBase('application', 'octet-stream')
            part.set_payload(content)
            encoders.encode_base64(part)
            part['Content-Disposition'] = f'attachment; filename="{attach_name}"'
            part['Content-Type'] = attach_mime
            msg.attach(part)

        raw = base64.urlsafe_b64encode(msg.as_bytes()).decode()
        draft = gmail.users().drafts().create(
            userId='me', body={'message': {'raw': raw}}
        ).execute()

        draft_id = draft['id']
        url = f"https://mail.google.com/mail/#drafts?compose=Draft_{draft_id}"

        return {"url": url, "draft_id": draft_id}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
