from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

from database import get_db
from models.scouting import Scouting, ScoutingType, ScoutingStatus

router = APIRouter(prefix="/scouting", tags=["scouting"])


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


@router.get("/", response_model=List[ScoutingSchema])
def get_scouting(
    status: Optional[str] = None,
    type: Optional[str] = None,
    country: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Scouting)
    if status:
        query = query.filter(Scouting.status == status)
    if type:
        query = query.filter(Scouting.type == type)
    if country:
        query = query.filter(Scouting.country == country)
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


@router.get("/stats/summary")
def get_stats(db: Session = Depends(get_db)):
    total = db.query(Scouting).count()
    by_status = {}
    for s in ScoutingStatus:
        by_status[s.value] = db.query(Scouting).filter(Scouting.status == s).count()
    return {"total": total, "by_status": by_status}
