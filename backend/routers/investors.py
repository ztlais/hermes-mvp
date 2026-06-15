from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

from database import get_db
from models.investor import Investor, InvestorType, InvestorStatus

router = APIRouter(prefix="/investors", tags=["investors"])


class InvestorSchema(BaseModel):
    id: int
    company: str
    contact_name: Optional[str]
    email: Optional[str]
    phone: Optional[str]
    linkedin: Optional[str]
    type: Optional[str]
    status: Optional[str]
    country: Optional[str]
    target_countries: Optional[str]
    technologies: Optional[str]
    deal_stages: Optional[str]
    deal_types: Optional[str]
    min_mw: Optional[float]
    max_mw: Optional[float]
    min_ticket: Optional[float]
    max_ticket: Optional[float]
    criteria: Optional[str]
    notes: Optional[str]
    last_contact: Optional[datetime]
    next_action: Optional[str]
    created_at: Optional[datetime]

    class Config:
        from_attributes = True


class InvestorCreate(BaseModel):
    company: str
    contact_name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    linkedin: Optional[str] = None
    type: Optional[InvestorType] = InvestorType.other
    status: Optional[InvestorStatus] = InvestorStatus.to_contact
    country: Optional[str] = None
    target_countries: Optional[str] = None
    technologies: Optional[str] = None
    deal_stages: Optional[str] = None
    deal_types: Optional[str] = None
    min_mw: Optional[float] = None
    max_mw: Optional[float] = None
    min_ticket: Optional[float] = None
    max_ticket: Optional[float] = None
    criteria: Optional[str] = None
    notes: Optional[str] = None
    next_action: Optional[str] = None


@router.get("/", response_model=List[InvestorSchema])
def get_investors(
    status: Optional[str] = None,
    type: Optional[str] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Investor)
    if status:
        query = query.filter(Investor.status == status)
    if type:
        query = query.filter(Investor.type == type)
    if search:
        query = query.filter(
            Investor.company.ilike(f"%{search}%") |
            Investor.contact_name.ilike(f"%{search}%")
        )
    return query.order_by(Investor.updated_at.desc()).all()


@router.get("/{investor_id}", response_model=InvestorSchema)
def get_investor(investor_id: int, db: Session = Depends(get_db)):
    inv = db.query(Investor).filter(Investor.id == investor_id).first()
    if not inv:
        raise HTTPException(status_code=404, detail="Investisseur non trouvé")
    return inv


@router.post("/", response_model=InvestorSchema)
def create_investor(data: InvestorCreate, db: Session = Depends(get_db)):
    inv = Investor(**data.model_dump())
    db.add(inv)
    db.commit()
    db.refresh(inv)
    return inv


@router.put("/{investor_id}", response_model=InvestorSchema)
def update_investor(investor_id: int, data: InvestorCreate, db: Session = Depends(get_db)):
    inv = db.query(Investor).filter(Investor.id == investor_id).first()
    if not inv:
        raise HTTPException(status_code=404, detail="Investisseur non trouvé")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(inv, key, value)
    db.commit()
    db.refresh(inv)
    return inv


@router.delete("/{investor_id}")
def delete_investor(investor_id: int, db: Session = Depends(get_db)):
    inv = db.query(Investor).filter(Investor.id == investor_id).first()
    if not inv:
        raise HTTPException(status_code=404, detail="Investisseur non trouvé")
    db.delete(inv)
    db.commit()
    return {"message": "Supprimé"}


@router.get("/stats/summary")
def get_stats(db: Session = Depends(get_db)):
    total = db.query(Investor).count()
    by_type = {}
    for t in InvestorType:
        by_type[t.value] = db.query(Investor).filter(Investor.type == t).count()
    by_status = {}
    for s in InvestorStatus:
        by_status[s.value] = db.query(Investor).filter(Investor.status == s).count()
    return {"total": total, "by_type": by_type, "by_status": by_status}
