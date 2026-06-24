import sys, os, json
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import subprocess
import json

# ── Lire vocab depuis Google Sheet ──
creds = Credentials.from_authorized_user_file("/root/.hermes/google_token.json", ["https://www.googleapis.com/auth/spreadsheets"])
svc = build("sheets", "v4", credentials=creds)

LEARNING_ID = "1tPID1-i1HO2XDjVo3ILm2jVCSMQwzwElfXvhIjGF1zI"
raw = svc.spreadsheets().values().get(
    spreadsheetId=LEARNING_ID, range="Vocabulary!A:F"
).execute().get('values', [])

print(f"📖 {len(raw)-1} lignes dans le sheet")

# ── Récupérer les termes existants ──
result = subprocess.run(
    ["su", "-", "postgres", "-c", "psql -d hermes_mvp -At -c \"SELECT LOWER(term) FROM learning;\""],
    capture_output=True, text=True, timeout=10
)
existing = set(line.strip() for line in result.stdout.strip().split("\n") if line.strip())
print(f"📚 {len(existing)} termes déjà en base")

# ── Cat mapping ──
cat_map = {
    "Technique": "technical",
    "Finance": "finance",
    "Juridique": "regulation",
    "Business": "market",
    "Environnement": "other",
    "Autre": "other",
    "⚡ EIR": "vocabulary",
    "EIR": "vocabulary",
}

added = 0
skipped = 0

for i, row in enumerate(raw[1:], 2):
    eng = (row[1] if len(row) > 1 else "").strip()
    fr = (row[2] if len(row) > 2 else "").strip()
    ar = (row[3] if len(row) > 3 else "").strip()
    cat_raw = (row[4] if len(row) > 4 else "").strip()
    notes = (row[5] if len(row) > 5 else "").strip()

    term = fr or eng
    if not term:
        skipped += 1
        continue

    if term.lower().strip() in existing:
        skipped += 1
        continue

    # Build definition
    eng_part = f"EN: {eng}" if eng and eng != term else ""
    ar_part = f"AR: {ar}" if ar else ""
    def_parts = [p for p in [eng_part, ar_part] if p]
    definition = " | ".join(def_parts) if def_parts else term

    cat = cat_map.get(cat_raw, "vocabulary")
    example = notes.replace("'", "''") if notes else "NULL"
    term_escaped = term.replace("'", "''")
    def_escaped = definition.replace("'", "''")

    sql = f"""INSERT INTO learning (term, definition, category, example, source, language, active, created_at)
VALUES ('{term_escaped}', '{def_escaped}', '{cat}', {'NULL' if example == 'NULL' else f"'{example}'"}, 'sheet-vocab-import', 'fr', true, NOW());"""

    subprocess.run(
        ["su", "-", "postgres", "-c", f"psql -d hermes_mvp -c \"{sql}\""],
        capture_output=True, text=True, timeout=10
    )
    existing.add(term.lower().strip())
    added += 1

print(f"\n✅ {added} termes importés, {skipped} déjà existants")
