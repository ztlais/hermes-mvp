from sqlalchemy import Column, Integer, String, Text, DateTime, Float, Enum
from sqlalchemy.sql import func
from database import Base
import enum


class InvestorType(str, enum.Enum):
    fund = "fund"
    family_office = "family_office"
    ipp = "ipp"
    corporate = "corporate"
    other = "other"


class InvestorStatus(str, enum.Enum):
    to_contact = "to_contact"
    contacted = "contacted"
    in_discussion = "in_discussion"
    active = "active"
    inactive = "inactive"


class Investor(Base):
    __tablename__ = "investors"

    id = Column(Integer, primary_key=True, index=True)
    company = Column(String(255), nullable=False)
    contact_name = Column(String(255))
    email = Column(String(255))
    phone = Column(String(50))
    linkedin = Column(String(500))
    type = Column(Enum(InvestorType), default=InvestorType.other)
    status = Column(Enum(InvestorStatus), default=InvestorStatus.to_contact)
    country = Column(String(100))
    target_countries = Column(String(500))   # "FR,BE,ES,MA"
    technologies = Column(String(500))       # "solar,wind,bess"
    deal_stages = Column(String(500))        # "development,rtb,construction"
    deal_types = Column(String(500))         # "acquisition,co_development"
    min_mw = Column(Float)
    max_mw = Column(Float)
    min_ticket = Column(Float)
    max_ticket = Column(Float)
    criteria = Column(Text)
    notes = Column(Text)
    last_contact = Column(DateTime)
    next_action = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
