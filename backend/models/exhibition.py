from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, JSON
from sqlalchemy.sql import func
from database import Base

class Exhibition(Base):
    __tablename__ = "exhibitions"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)  # e.g. "Intersolar 2026"
    date = Column(String(100), default="")
    location = Column(String(255), default="")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class ExhibitionCompany(Base):
    __tablename__ = "exhibition_companies"

    id = Column(Integer, primary_key=True, index=True)
    exhibition_id = Column(Integer, nullable=False, index=True)
    name = Column(String(255), nullable=False)
    type = Column(String(100), default="")  # IPP, Developer, Investor, Manufacturer, etc.
    country = Column(String(100), default="")
    stand = Column(String(100), default="")
    contact_name = Column(String(255), default="")
    contact_email = Column(String(255), default="")
    status = Column(String(50), default="to_contact")  # to_contact, contacted, meeting_scheduled, meeting_done, not_interested
    notes_fr = Column(Text, default="")
    notes_en = Column(Text, default="")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
