"""Better weekly tasks model for structured meeting prep"""
from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, Date, ForeignKey
from sqlalchemy.sql import func
from database import Base


class WeeklyTask(Base):
    __tablename__ = "weekly_tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(500), nullable=False)
    description = Column(Text)
    category = Column(String(50), default="general")  # general, prospect, action, question
    related_company = Column(String(255))
    prospect_id = Column(Integer, ForeignKey("prospects.id"), nullable=True, index=True)
    outcome = Column(Text)  # result/suivi note a la cloture
    priority = Column(String(20), default="moyenne")
    assignee = Column(String(50), default="")  # Zein, Mariella, Les deux
    status = Column(String(20), default="a_faire")  # a_faire, en_cours, fait
    week_start = Column(Date, index=True)
    done = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
