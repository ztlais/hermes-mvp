from sqlalchemy import Column, Integer, String, Text, DateTime, Enum, Boolean
from sqlalchemy.sql import func
from database import Base
import enum


class ProspectType(str, enum.Enum):
    developer = "developer"
    investor = "investor"
    ipp = "ipp"
    family_office = "family_office"
    other = "other"


class ProspectStatus(str, enum.Enum):
    to_contact = "to_contact"
    contacted = "contacted"
    in_discussion = "in_discussion"
    meeting_scheduled = "meeting_scheduled"
    nda_signed = "nda_signed"
    deal_in_progress = "deal_in_progress"
    closed = "closed"
    rejected = "rejected"


class Prospect(Base):
    __tablename__ = "prospects"

    id = Column(Integer, primary_key=True, index=True)
    company = Column(String(255), nullable=False)
    contact_name = Column(String(255))
    email = Column(String(255))
    phone = Column(String(50))
    linkedin = Column(String(500))
    type = Column(Enum(ProspectType), default=ProspectType.other)
    status = Column(Enum(ProspectStatus), default=ProspectStatus.to_contact)
    country = Column(String(100))
    notes = Column(Text)
    teaser = Column(Text)
    nda_signed = Column(String(10), default="Non")
    last_contact = Column(DateTime)
    next_action = Column(Text)
    source = Column(String(100))
    job_title = Column(String(200))
    address = Column(String(500))
    fax = Column(String(50))
    notes_en = Column(Text)
    raw_transcript = Column(Text)
    email_draft = Column(Text)
    transcript_processed = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
