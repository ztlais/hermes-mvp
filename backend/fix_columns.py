"""Fix column types in projects table"""
from database import engine
from sqlalchemy import text

c = engine.connect()
try:
    c.execute(text("ALTER TABLE projects ALTER COLUMN cod_date TYPE TEXT"))
    c.execute(text("ALTER TABLE projects ALTER COLUMN rtb_date TYPE TEXT"))
    c.execute(text("ALTER TABLE projects ALTER COLUMN status_detail TYPE TEXT"))
    c.execute(text("ALTER TABLE projects ALTER COLUMN offtake_type TYPE TEXT"))
    c.execute(text("ALTER TABLE projects ALTER COLUMN developer_name TYPE TEXT"))
    c.execute(text("ALTER TABLE projects ALTER COLUMN technology_detail TYPE TEXT"))
    c.execute(text("ALTER TABLE projects ALTER COLUMN commune TYPE TEXT"))
    c.execute(text("ALTER TABLE projects ALTER COLUMN region TYPE TEXT"))
    c.execute(text("ALTER TABLE projects ALTER COLUMN department TYPE TEXT"))
    c.execute(text("ALTER TABLE projects ALTER COLUMN notes TYPE TEXT"))
    c.commit()
    print("✅ Column types fixed")
except Exception as e:
    print(f"Error: {e}")
finally:
    c.close()
