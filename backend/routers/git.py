"""Backup — sauvegarde locale + notification Telegram."""
import subprocess
import glob
from datetime import datetime
from pathlib import Path
from fastapi import APIRouter, Depends, HTTPException, status
from models.user import User, UserRole
from auth import get_current_user

router = APIRouter(prefix="/backup", tags=["backup"])

BACKUP_SCRIPT = Path("/root/.hermes/scripts/backup_code.sh")
BACKUP_DIR = Path("/root/backups")


@router.post("/local")
def backup_local(current_user: User = Depends(get_current_user)):
    """Sauvegarde le code localement dans /root/backups/. Réservé aux admins."""
    if current_user.role != UserRole.admin:
        raise HTTPException(status_code=403, detail="Réservé aux administrateurs")

    if not BACKUP_SCRIPT.exists():
        raise HTTPException(status_code=500, detail="Script de backup introuvable")

    try:
        result = subprocess.run(
            ["bash", str(BACKUP_SCRIPT)],
            capture_output=True, text=True, timeout=120
        )
        if result.returncode != 0:
            raise HTTPException(
                status_code=500,
                detail=f"❌ Erreur backup : {result.stderr[:300]}"
            )

        today = datetime.now().strftime("%Y-%m-%d")
        backups = sorted(glob.glob(str(BACKUP_DIR / f"hermes-*-{today}.tar.gz")))

        if backups:
            files = "\n".join([f"  • {Path(f).name}" for f in backups])
            return {
                "success": True,
                "message": f"✅ Backup local réussi ! Fichiers créés :\n{files}",
                "backup_files": [str(f) for f in backups]
            }
        else:
            return {"success": True, "message": "✅ Backup local réussi !"}

    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=500, detail="⏱ Timeout — le backup a pris trop de temps")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"❌ Erreur : {str(e)[:300]}")
