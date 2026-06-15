from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

from database import get_db
from models.prospect import Prospect, ProspectType, ProspectStatus

router = APIRouter(prefix="/prospects", tags=["prospects"])


class ProspectSchema(BaseModel):
    id: int
    company: str
    contact_name: Optional[str]
    email: Optional[str]
    phone: Optional[str]
    linkedin: Optional[str]
    type: Optional[str]
    status: Optional[str]
    country: Optional[str]
    notes: Optional[str]
    teaser: Optional[str]
    nda_signed: Optional[str]
    last_contact: Optional[datetime]
    next_action: Optional[str]
    source: Optional[str]
    created_at: Optional[datetime]

    class Config:
        from_attributes = True


class ProspectCreate(BaseModel):
    company: str
    contact_name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    linkedin: Optional[str] = None
    type: Optional[ProspectType] = ProspectType.other
    status: Optional[ProspectStatus] = ProspectStatus.to_contact
    country: Optional[str] = None
    notes: Optional[str] = None
    teaser: Optional[str] = None
    nda_signed: Optional[str] = "Non"
    next_action: Optional[str] = None
    source: Optional[str] = None


@router.get("/", response_model=List[ProspectSchema])
def get_prospects(
    status: Optional[str] = None,
    type: Optional[str] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Prospect)
    if status:
        query = query.filter(Prospect.status == status)
    if type:
        query = query.filter(Prospect.type == type)
    if search:
        query = query.filter(
            Prospect.company.ilike(f"%{search}%") |
            Prospect.contact_name.ilike(f"%{search}%") |
            Prospect.email.ilike(f"%{search}%")
        )
    return query.order_by(Prospect.updated_at.desc()).all()


@router.get("/{prospect_id}", response_model=ProspectSchema)
def get_prospect(prospect_id: int, db: Session = Depends(get_db)):
    p = db.query(Prospect).filter(Prospect.id == prospect_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Prospect non trouvé")
    return p


@router.post("/", response_model=ProspectSchema)
def create_prospect(data: ProspectCreate, db: Session = Depends(get_db)):
    p = Prospect(**data.model_dump())
    db.add(p)
    db.commit()
    db.refresh(p)
    return p


@router.put("/{prospect_id}", response_model=ProspectSchema)
def update_prospect(prospect_id: int, data: ProspectCreate, db: Session = Depends(get_db)):
    p = db.query(Prospect).filter(Prospect.id == prospect_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Prospect non trouvé")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(p, key, value)
    db.commit()
    db.refresh(p)
    return p


@router.delete("/{prospect_id}")
def delete_prospect(prospect_id: int, db: Session = Depends(get_db)):
    p = db.query(Prospect).filter(Prospect.id == prospect_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Prospect non trouvé")
    db.delete(p)
    db.commit()
    return {"message": "Supprimé"}


@router.get("/stats/summary")
def get_stats(db: Session = Depends(get_db)):
    total = db.query(Prospect).count()
    by_status = {}
    for status in ProspectStatus:
        by_status[status.value] = db.query(Prospect).filter(Prospect.status == status).count()
    nda_count = db.query(Prospect).filter(Prospect.nda_signed == "Oui").count()
    return {"total": total, "by_status": by_status, "nda_signed": nda_count}
