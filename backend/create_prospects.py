"""Create prospects table to satisfy FK"""
from database import SessionLocal
from sqlalchemy import text

db = SessionLocal()
db.execute(text("""
CREATE TABLE IF NOT EXISTS prospects (
    id SERIAL PRIMARY KEY,
    company VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
)
"""))
db.commit()
db.close()
print("Prospects table ready")
