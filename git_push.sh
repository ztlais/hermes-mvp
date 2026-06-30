#!/bin/bash
# Push automatique du code Hermes vers GitHub

cd /root/hermes-mvp || exit 1

git add -A

if git diff --cached --quiet; then
    echo "[$(date '+%Y-%m-%d %H:%M')] Aucun changement, pas de commit."
    exit 0
fi

DATE=$(date '+%Y-%m-%d')
git commit -m "Auto-backup $DATE"
git push origin main

echo "[$(date '+%Y-%m-%d %H:%M')] Push GitHub OK."
