from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from database import Base


class Document(Base):
    __tablename__ = "documents"

    id = Column(Integer, primary_key=True, index=True)
    prospect_id = Column(Integer, ForeignKey("prospects.id"), nullable=True, index=True)
    investor_id = Column(Integer, ForeignKey("investors.id"), nullable=True, index=True)
    name = Column(String(255), nullable=False)
    url = Column(String(1000), nullable=False)
    doc_type = Column(String(50), default="other")  # nda, fee_agreement, teaser, presentation, other
    created_at = Column(DateTime, server_default=func.now())
