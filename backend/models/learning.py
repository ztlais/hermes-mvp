from sqlalchemy import Column, Integer, String, Text, DateTime, Enum, Boolean
from sqlalchemy.sql import func
from database import Base
import enum


class LearningCategory(str, enum.Enum):
    vocabulary = "vocabulary"
    concept = "concept"
    regulation = "regulation"
    market = "market"
    finance = "finance"
    technical = "technical"
    other = "other"


class Learning(Base):
    __tablename__ = "learning"

    id = Column(Integer, primary_key=True, index=True)
    term = Column(String(255), nullable=False)
    definition = Column(Text, nullable=False)
    category = Column(Enum(LearningCategory), default=LearningCategory.vocabulary)
    example = Column(Text)
    source = Column(String(500))
    language = Column(String(10), default="fr")
    active = Column(Boolean, default=True)
    created_at = Column(DateTime, server_default=func.now())
