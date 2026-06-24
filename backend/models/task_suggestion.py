from sqlalchemy import Column, Integer, String, Text, Float, Boolean, Date, DateTime
from sqlalchemy.sql import func
from database import Base


class TaskSuggestion(Base):
    """Suggestion de tache generee (deterministe + IA) pour la semaine en cours.
    Persistee en base pour survivre a un refresh de page, jusqu'a validation
    (conversion en WeeklyTask) ou suppression explicite par l'utilisateur.
    """
    __tablename__ = "task_suggestions"

    id = Column(Integer, primary_key=True, index=True)
    week_start = Column(Date, index=True, nullable=False)
    source = Column(String(20), nullable=False)  # "prospect" | "investor"
    entity_id = Column(Integer, nullable=False)
    ref = Column(String(50), nullable=False, index=True)
    company = Column(String(255))
    contact_name = Column(String(255))
    status = Column(String(50))
    nda_signed = Column(String(10))
    criteria = Column(Text)
    next_action = Column(Text)
    notes = Column(Text)
    notes_preview = Column(String(200))
    score = Column(Float)
    reason = Column(Text)
    task = Column(Text)
    ai_generated = Column(Boolean, default=False)
    last_update = Column(DateTime)
    created_at = Column(DateTime, server_default=func.now())
