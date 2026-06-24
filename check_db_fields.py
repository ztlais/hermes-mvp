from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import os, sys

# Read DB to see what fields have data
sys.path.insert(0, '/root/hermes-mvp/backend')
os.chdir('/root/hermes-mvp/backend')
from database import SessionLocal
from models.project import Project

db = SessionLocal()
projects = db.query(Project).order_by(Project.code).limit(3).all()
db.close()

print("=== Database fields filled for first 3 projects ===")
for p in projects:
    print(f"\n--- Project {p.code}: {p.name} ---")
    for col in Project.__table__.columns:
        val = getattr(p, col.name)
        if val is not None and val != '':
            print(f"  {col.name}: {repr(val)}")
