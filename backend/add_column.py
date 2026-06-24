"""Add raw_data column to projects table"""
from database import engine
from sqlalchemy import text

c = engine.connect()
try:
    c.execute(text("ALTER TABLE projects ADD COLUMN IF NOT EXISTS raw_data TEXT"))
    c.commit()
    print("✅ Column raw_data added to projects table")
except Exception as e:
    print(f"Error: {e}")
finally:
    c.close()
