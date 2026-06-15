"""
Backup automatique PostgreSQL → Google Drive
Dossier : Dashboard EIR / Backups DB
Garde les 30 derniers jours
"""
import os
import subprocess
from datetime import datetime, timedelta
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

TOKEN_PATH   = "/root/.hermes/google_token.json"
BACKUP_DIR   = "/root/backups"
DRIVE_FOLDER = "1ieEpRL-jPykFRReo8ktmE15pt4Q0DJ79"
DB_NAME      = "hermes_mvp"
DB_USER      = "hermes"
KEEP_DAYS    = 30


def pg_dump(filepath):
    env = os.environ.copy()
    env['PGPASSWORD'] = 'hermes2024'
    result = subprocess.run([
        'pg_dump', '-U', DB_USER, '-h', 'localhost', DB_NAME,
        '-f', filepath, '--format=plain'
    ], env=env, capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"pg_dump failed: {result.stderr}")


def upload_to_drive(filepath, filename):
    creds = Credentials.from_authorized_user_file(TOKEN_PATH)
    svc = build('drive', 'v3', credentials=creds)

    media = MediaFileUpload(filepath, mimetype='application/sql', resumable=False)
    file = svc.files().create(
        body={'name': filename, 'parents': [DRIVE_FOLDER]},
        media_body=media,
        fields='id,name,size'
    ).execute()
    return file


def cleanup_old_backups(svc):
    cutoff = datetime.utcnow() - timedelta(days=KEEP_DAYS)
    cutoff_str = cutoff.isoformat() + 'Z'
    files = svc.files().list(
        q=f"'{DRIVE_FOLDER}' in parents and createdTime < '{cutoff_str}' and trashed=false",
        fields='files(id,name,createdTime)'
    ).execute().get('files', [])
    for f in files:
        svc.files().delete(fileId=f['id']).execute()
        print(f"  🗑️  Supprimé ancien backup: {f['name']}")


def cleanup_local_backups():
    cutoff = datetime.now() - timedelta(days=KEEP_DAYS)
    for fname in os.listdir(BACKUP_DIR):
        if not fname.endswith('.sql'):
            continue
        fpath = os.path.join(BACKUP_DIR, fname)
        mtime = datetime.fromtimestamp(os.path.getmtime(fpath))
        if mtime < cutoff:
            os.remove(fpath)
            print(f"  🗑️  Supprimé local: {fname}")


def main():
    now = datetime.now()
    date_str = now.strftime('%Y-%m-%d_%H-%M')
    filename = f"hermes_backup_{date_str}.sql"
    filepath = os.path.join(BACKUP_DIR, filename)

    print(f"🔄 Backup PostgreSQL — {date_str}")

    # 1. Dump local
    print("  📦 Dump de la base...")
    pg_dump(filepath)
    size_mb = os.path.getsize(filepath) / 1024 / 1024
    print(f"  ✅ Fichier local : {filepath} ({size_mb:.2f} MB)")

    # 2. Upload Drive
    print("  ☁️  Upload vers Google Drive...")
    creds = Credentials.from_authorized_user_file(TOKEN_PATH)
    svc = build('drive', 'v3', credentials=creds)
    result = upload_to_drive(filepath, filename)
    print(f"  ✅ Drive : {result['name']} (ID: {result['id']})")

    # 3. Nettoyage anciens fichiers
    print(f"  🧹 Nettoyage des backups > {KEEP_DAYS} jours...")
    cleanup_old_backups(svc)
    cleanup_local_backups()

    print(f"\n✅ Backup terminé avec succès — {filename}")


if __name__ == '__main__':
    main()
