from sqlalchemy import Column, Integer, String, Text, DateTime, Enum
from sqlalchemy.sql import func
from database import Base
import enum


class TemplateType(str, enum.Enum):
    email = "email"
    linkedin = "linkedin"


class TemplateTarget(str, enum.Enum):
    developer = "developer"
    investor = "investor"
    ipp = "ipp"
    family_office = "family_office"


class Template(Base):
    __tablename__ = "templates"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    type = Column(Enum(TemplateType), default=TemplateType.email)
    target = Column(Enum(TemplateTarget), default=TemplateTarget.developer)
    subject = Column(String(500))
    body = Column(Text, nullable=False)
    language = Column(String(10), default="fr")
    step = Column(Integer, default=1)
    notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
