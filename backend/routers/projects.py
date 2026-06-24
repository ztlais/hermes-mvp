from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

from database import get_db
from models.project import Project, ProjectTechnology, ProjectStage

router = APIRouter(prefix="/projects", tags=["projects"])


class ProjectSchema(BaseModel):
    id: int
    code: Optional[int] = None
    name: str
    developer_name: Optional[str] = None
    technology: Optional[str] = None
    technology_detail: Optional[str] = None
    stage: Optional[str] = None
    status_detail: Optional[str] = None
    capacity_mw: Optional[float] = None
    p50_mwh: Optional[float] = None
    country: Optional[str] = None
    region: Optional[str] = None
    commune: Optional[str] = None
    department: Optional[str] = None
    department_code: Optional[str] = None
    rtb_date: Optional[str] = None
    cod_date: Optional[str] = None
    permit_status: Optional[str] = None
    permit_type: Optional[str] = None
    land_secured: Optional[bool] = None
    grid_operator: Optional[str] = None
    grid_connection_cost: Optional[float] = None
    offtake_type: Optional[str] = None
    asking_price: Optional[float] = None
    irr: Optional[float] = None
    notes: Optional[str] = None
    nda_signed: Optional[str] = None
    raw_data: Optional[str] = None
    custom_stage: Optional[str] = None
    status_fr: Optional[str] = None
    status_en: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    permis_status: Optional[str] = None

    class Config:
        from_attributes = True


class ProjectUpdate(BaseModel):
    name: Optional[str] = None
    developer_name: Optional[str] = None
    technology: Optional[ProjectTechnology] = None
    technology_detail: Optional[str] = None
    stage: Optional[ProjectStage] = None
    status_detail: Optional[str] = None
    capacity_mw: Optional[float] = None
    p50_mwh: Optional[float] = None
    country: Optional[str] = None
    region: Optional[str] = None
    commune: Optional[str] = None
    department: Optional[str] = None
    department_code: Optional[str] = None
    rtb_date: Optional[str] = None
    cod_date: Optional[str] = None
    permit_status: Optional[str] = None
    permit_type: Optional[str] = None
    land_secured: Optional[bool] = None
    grid_operator: Optional[str] = None
    grid_connection_cost: Optional[float] = None
    offtake_type: Optional[str] = None
    asking_price: Optional[float] = None
    irr: Optional[float] = None
    notes: Optional[str] = None
    nda_signed: Optional[str] = None


@router.get("/", response_model=List[ProjectSchema])
def list_projects(
    stage: Optional[str] = None,
    technology: Optional[str] = None,
    developer: Optional[str] = None,
    department_code: Optional[str] = None,
    db: Session = Depends(get_db)
):
    q = db.query(Project)
    if stage:
        q = q.filter(Project.stage == stage)
    if technology:
        q = q.filter(Project.technology == technology)
    if developer:
        q = q.filter(Project.developer_name == developer)
    if department_code:
        q = q.filter(Project.department_code == department_code)
    return q.order_by(Project.code.asc().nullslast(), Project.name.asc()).all()


@router.get("/stats/analytics")
def get_analytics(db: Session = Depends(get_db)):
    total = db.query(Project).count()
    total_mw = db.query(func.sum(Project.capacity_mw)).scalar() or 0

    by_technology = []
    for tech in ProjectTechnology:
        count = db.query(Project).filter(Project.technology == tech).count()
        mw = db.query(func.sum(Project.capacity_mw)).filter(Project.technology == tech).scalar() or 0
        by_technology.append({"technology": tech.value, "count": count, "total_mw": round(float(mw), 1)})

    by_stage = []
    for stage in ProjectStage:
        count = db.query(Project).filter(Project.stage == stage).count()
        mw = db.query(func.sum(Project.capacity_mw)).filter(Project.stage == stage).scalar() or 0
        by_stage.append({"stage": stage.value, "count": count, "total_mw": round(float(mw), 1)})

    developers = db.query(Project.developer_name, func.count(Project.id), func.sum(Project.capacity_mw))\
        .group_by(Project.developer_name).all()
    by_developer = [{"developer": d, "count": c, "total_mw": round(float(mw or 0), 1)} for d, c, mw in developers]

    return {
        "total": total,
        "total_mw": round(float(total_mw), 1),
        "by_technology": by_technology,
        "by_stage": by_stage,
        "by_developer": by_developer,
    }


@router.get("/{project_id}", response_model=ProjectSchema)
def get_project(project_id: int, db: Session = Depends(get_db)):
    p = db.query(Project).filter(Project.id == project_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Projet non trouvé")
    return p


@router.put("/{project_id}", response_model=ProjectSchema)
def update_project(project_id: int, data: ProjectUpdate, db: Session = Depends(get_db)):
    p = db.query(Project).filter(Project.id == project_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Projet non trouvé")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(p, key, value)
    db.commit()
    db.refresh(p)
    return p
