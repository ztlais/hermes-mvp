from sqlalchemy import Column, Integer, String, Text, DateTime, Float, ForeignKey, Enum
from sqlalchemy.sql import func
from database import Base
import enum


class OpportunityType(str, enum.Enum):
    financement = "financement"
    levee = "levee"
    co_dev = "co_dev"
    cession = "cession"
    ppa = "ppa"
    autre = "autre"


class OpportunityStatus(str, enum.Enum):
    en_discussion = "en_discussion"
    offre_envoyee = "offre_envoyee"
    term_sheet = "term_sheet"
    signe = "signe"
    perdu = "perdu"


class Opportunity(Base):
    __tablename__ = "opportunities"

    id = Column(Integer, primary_key=True, index=True)
    prospect_id = Column(Integer, ForeignKey("prospects.id"), nullable=True)
    title = Column(String(255), nullable=False)
    title_en = Column(Text)
    type = Column(Enum(OpportunityType), default=OpportunityType.financement)
    country = Column(String(100))
    size_eur = Column(Float)
    size_mw = Column(Float)
    deadline = Column(DateTime)
    status = Column(Enum(OpportunityStatus), default=OpportunityStatus.en_discussion)
    notes = Column(Text)
    notes_en = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
