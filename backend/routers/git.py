"""Git push — endpoint pour push le code vers GitHub depuis le dashboard."""
import subprocess
import os
from pathlib import Path
from fastapi import APIRouter, Depends, HTTPException, status
from models.user import User, UserRole
from auth import get_current_user

router = APIRouter(prefix="/git", tags=["git"])

REPO_DIR = Path("/root/hermes-mvp")


@router.post("/push")
def git_push(current_user: User = Depends(get_current_user)):
    """Git add -A, commit, push. Réservé aux admins."""
    if current_user.role != UserRole.admin:
        raise HTTPException(status_code=403, detail="Réservé aux administrateurs")

    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        raise HTTPException(
            status_code=500,
            detail="GITHUB_TOKEN non configuré dans le .env du serveur"
        )

    # Configure credential helper (avoids embedding token in URL)
    subprocess.run(
        ["git", "config", "--local", "credential.helper",
         f'!f() {{ echo "username=ztlais"; echo "password={token}"; }}; f'],
        cwd=REPO_DIR, capture_output=True, text=True, check=True, timeout=10
    )

    try:
        # 1. git add -A (exclut .env via .gitignore)
        subprocess.run(
            ["git", "add", "-A"],
            cwd=REPO_DIR, capture_output=True, text=True, check=True, timeout=30
        )

        # 2. Check if anything to commit
        status_result = subprocess.run(
            ["git", "status", "--porcelain"],
            cwd=REPO_DIR, capture_output=True, text=True, timeout=10
        )

        if not status_result.stdout.strip():
            return {"success": True, "message": "✅ Rien à push — le dépôt est déjà à jour."}

        # 3. git commit
        subprocess.run(
            ["git", "commit", "-m", "Update depuis le dashboard ⚙️", "--allow-empty"],
            cwd=REPO_DIR, capture_output=True, text=True, check=True, timeout=30
        )

        # 4. git push (credential helper gère l'auth)
        subprocess.run(
            ["git", "push", "origin", "main"],
            cwd=REPO_DIR, capture_output=True, text=True, check=True, timeout=120
        )

        return {"success": True, "message": "✅ Push GitHub réussi !"}

    except subprocess.TimeoutExpired:
        raise HTTPException(
            status_code=500,
            detail="⏱ Timeout — l'opération a pris trop de temps"
        )
    except subprocess.CalledProcessError as e:
        error_msg = e.stderr or e.stdout or str(e)
        safe_error = error_msg[:500]
        raise HTTPException(
            status_code=500,
            detail=f"❌ Erreur git : {safe_error}"
        )
