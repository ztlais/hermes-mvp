from sqlalchemy import Column, Integer, String, Text, DateTime, Float, ForeignKey, Enum, Boolean
from sqlalchemy.sql import func
from database import Base
import enum


class ProjectStage(str, enum.Enum):
    development = "development"
    permitting = "permitting"
    ready_to_build = "ready_to_build"
    construction = "construction"
    operational = "operational"
    origination = "origination"
    early = "early"
    submit = "submit"
    mid = "mid"
    advanced = "advanced"
    nearly_secured = "nearly_secured"
    secured_and_clean = "secured_and_clean"
    refused = "refused"


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
    code = Column(Integer, unique=True, nullable=True)
    name = Column(String(255), nullable=False)
    developer_name = Column(String(255))
    developer_id = Column(Integer, ForeignKey("prospects.id"), nullable=True)
    technology = Column(Enum(ProjectTechnology), default=ProjectTechnology.solar)
    technology_detail = Column(String(100))
    stage = Column(Enum(ProjectStage), default=ProjectStage.development)
    status_detail = Column(Text)
    capacity_mw = Column(Float)
    p50_mwh = Column(Float)
    country = Column(String(100))
    region = Column(String(100))
    commune = Column(String(200))
    department = Column(String(100))
    department_code = Column(String(10))
    rtb_date = Column(String(20))
    cod_date = Column(String(20))
    permit_status = Column(String(50))
    permis_status = Column(Text)
    permit_type = Column(String(20))
    land_secured = Column(Boolean, default=False)
    grid_operator = Column(String(50))
    grid_connection_cost = Column(Float)
    offtake_type = Column(String(100))
    asking_price = Column(Float)
    irr = Column(Float)
    lcoe = Column(Float)
    description = Column(Text)
    teaser_path = Column(String(500))
    nda_signed = Column(String(10), default="Non")
    notes = Column(Text)
    raw_data = Column(Text)  # JSON: all extra columns from the sheet
    custom_stage = Column(String(50))
    status_fr = Column(String(200))
    status_en = Column(String(200))
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
