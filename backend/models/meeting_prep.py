from sqlalchemy import Column, Integer, String, Text, DateTime, JSON
from sqlalchemy.sql import func
from database import Base


class MeetingPrep(Base):
    __tablename__ = "meeting_preps"

    id = Column(Integer, primary_key=True, index=True)
    company = Column(String(255), nullable=False, index=True)
    event_title = Column(String(500))
    event_date = Column(DateTime)

    # Structured content
    context = Column(Text)  # Company description, type, status summary
    talking_points = Column(JSON, default=list)  # ["pt1", "pt2", ...]
    questions = Column(JSON, default=list)       # ["q1", "q2", ...]
    next_steps = Column(JSON, default=list)      # ["ns1", "ns2", ...]
    personal_notes = Column(Text)                # User's own notes

    # Metadata
    status = Column(String(20), default="draft")  # draft, finalized
    source_event_id = Column(String(100))         # Calendar event ID if linked
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
