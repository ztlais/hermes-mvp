from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

from database import get_db
from models.scouting import Scouting, ScoutingType, ScoutingStatus
from models.investor import Investor, InvestorType
from models.project import Project

router = APIRouter(prefix="/scouting", tags=["scouting"])

INVESTOR_TYPE_TO_SCOUTING_TYPE = {
    InvestorType.fund: ScoutingType.investor,
    InvestorType.corporate: ScoutingType.investor,
    InvestorType.other: ScoutingType.investor,
    InvestorType.family_office: ScoutingType.family_office,
    InvestorType.ipp: ScoutingType.ipp,
}


class ScoutingSchema(BaseModel):
    id: int
    company: str
    contact_name: Optional[str]
    email: Optional[str]
    linkedin: Optional[str]
    type: Optional[str]
    status: Optional[str]
    country: Optional[str]
    template_used: Optional[str]
    contact_date: Optional[datetime]
    response_date: Optional[datetime]
    notes: Optional[str]
    data: Optional[str] = '{}'
    created_at: Optional[datetime]

    class Config:
        from_attributes = True


class ScoutingCreate(BaseModel):
    company: str
    contact_name: Optional[str] = None
    email: Optional[str] = None
    linkedin: Optional[str] = None
    type: Optional[ScoutingType] = ScoutingType.developer
    status: Optional[ScoutingStatus] = ScoutingStatus.to_contact
    country: Optional[str] = "FR"
    template_used: Optional[str] = None
    contact_date: Optional[datetime] = None
    notes: Optional[str] = None
    data: Optional[str] = None


@router.get("/", response_model=List[ScoutingSchema])
def get_scouting(
    status: Optional[str] = None,
    type: Optional[str] = None,
    country: Optional[str] = None,
    q: Optional[str] = None,
    source: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Scouting)
    if status:
        query = query.filter(Scouting.status == status)
    if type:
        query = query.filter(Scouting.type == type)
    if country:
        query = query.filter(Scouting.country == country)
    if q:
        query = query.filter(
            (Scouting.notes.ilike(f"%{q}%")) |
            (Scouting.company.ilike(f"%{q}%")) |
            (Scouting.contact_name.ilike(f"%{q}%"))
        )
    if source:
        query = query.filter(Scouting.notes.ilike(f"%{source}%"))
    return query.order_by(Scouting.created_at.desc()).all()


@router.post("/", response_model=ScoutingSchema)
def create_scouting(data: ScoutingCreate, db: Session = Depends(get_db)):
    s = Scouting(**data.model_dump())
    db.add(s)
    db.commit()
    db.refresh(s)
    return s


@router.put("/{scouting_id}", response_model=ScoutingSchema)
def update_scouting(scouting_id: int, data: ScoutingCreate, db: Session = Depends(get_db)):
    s = db.query(Scouting).filter(Scouting.id == scouting_id).first()
    if not s:
        raise HTTPException(status_code=404, detail="Non trouvé")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(s, key, value)
    db.commit()
    db.refresh(s)
    return s


@router.delete("/{scouting_id}")
def delete_scouting(scouting_id: int, db: Session = Depends(get_db)):
    s = db.query(Scouting).filter(Scouting.id == scouting_id).first()
    if not s:
        raise HTTPException(status_code=404, detail="Non trouvé")
    db.delete(s)
    db.commit()
    return {"message": "Supprimé"}


@router.get("/detect-category")
def detect_category(company: str, db: Session = Depends(get_db)):
    name = company.strip()
    if not name:
        return {"detected_type": None, "matched_via": None}

    inv = db.query(Investor).filter(func.lower(Investor.company) == name.lower()).first()
    if not inv:
        inv = db.query(Investor).filter(Investor.company.ilike(f"%{name}%")).first()
    if inv:
        return {"detected_type": INVESTOR_TYPE_TO_SCOUTING_TYPE[inv.type].value, "matched_via": "investors"}

    proj = db.query(Project).filter(func.lower(Project.developer_name) == name.lower()).first()
    if not proj:
        proj = db.query(Project).filter(Project.developer_name.ilike(f"%{name}%")).first()
    if proj:
        return {"detected_type": ScoutingType.developer.value, "matched_via": "projects"}

    return {"detected_type": None, "matched_via": None}


@router.get("/stats/summary")
def get_stats(db: Session = Depends(get_db)):
    total = db.query(Scouting).count()
    by_status = {}
    for s in ScoutingStatus:
        by_status[s.value] = db.query(Scouting).filter(Scouting.status == s).count()
    return {"total": total, "by_status": by_status}
