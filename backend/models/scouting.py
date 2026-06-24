from sqlalchemy import Column, Integer, String, Text, DateTime, Enum
from sqlalchemy.sql import func
from database import Base
import enum


class ScoutingStatus(str, enum.Enum):
    to_contact = "to_contact"
    email_sent = "email_sent"
    linkedin_sent = "linkedin_sent"
    responded = "responded"
    meeting_done = "meeting_done"
    converted = "converted"
    no_response = "no_response"
    not_interested = "not_interested"
    premiere_connexion = "premiere_connexion"
    deuxieme_connexion = "deuxieme_connexion"


class ScoutingType(str, enum.Enum):
    developer = "developer"
    investor = "investor"
    ipp = "ipp"
    family_office = "family_office"


class Scouting(Base):
    __tablename__ = "scouting"

    id = Column(Integer, primary_key=True, index=True)
    company = Column(String(255), nullable=False)
    contact_name = Column(String(255))
    email = Column(String(255))
    linkedin = Column(String(500))
    type = Column(Enum(ScoutingType), default=ScoutingType.developer)
    status = Column(Enum(ScoutingStatus), default=ScoutingStatus.to_contact)
    country = Column(String(100), default="FR")
    template_used = Column(String(255))
    contact_date = Column(DateTime)
    response_date = Column(DateTime)
    notes = Column(Text)
    data = Column(Text, default='{}')  # JSON: {li_1ere, em_1ere, li_2eme, em_2eme, li_1ere_sent, em_1ere_sent, li_2eme_sent, em_2eme_sent, later, history, person}
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
