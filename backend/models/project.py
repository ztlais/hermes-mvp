from sqlalchemy import Column, Integer, String, Text, DateTime, Float, ForeignKey, Enum
from sqlalchemy.sql import func
from database import Base
import enum


class ProjectStage(str, enum.Enum):
    development = "development"
    permitting = "permitting"
    ready_to_build = "ready_to_build"
    construction = "construction"
    operational = "operational"


class ProjectTechnology(str, enum.Enum):
    solar = "solar"
    wind = "wind"
    bess = "bess"
    hydro = "hydro"
    biomass = "biomass"
    other = "other"


class Project(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    developer_name = Column(String(255))
    developer_id = Column(Integer, ForeignKey("prospects.id"), nullable=True)
    technology = Column(Enum(ProjectTechnology), default=ProjectTechnology.solar)
    stage = Column(Enum(ProjectStage), default=ProjectStage.development)
    capacity_mw = Column(Float)
    country = Column(String(100))
    region = Column(String(100))
    asking_price = Column(Float)
    irr = Column(Float)
    lcoe = Column(Float)
    description = Column(Text)
    teaser_path = Column(String(500))
    nda_signed = Column(String(10), default="Non")
    notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
