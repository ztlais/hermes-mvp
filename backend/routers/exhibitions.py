from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

from database import get_db
from models.exhibition import Exhibition, ExhibitionCompany

router = APIRouter(prefix="/exhibitions", tags=["exhibitions"])

# ── Pydantic schemas ──

class ExhibitionCreate(BaseModel):
    name: str
    date: str = ""
    location: str = ""

class ExhibitionUpdate(BaseModel):
    name: Optional[str] = None
    date: Optional[str] = None
    location: Optional[str] = None

class ExhibitionCompanyCreate(BaseModel):
    name: str
    type: str = ""
    country: str = ""
    stand: str = ""
    contact_name: str = ""
    contact_email: str = ""
    status: str = "to_contact"
    notes_fr: str = ""
    notes_en: str = ""

class ExhibitionCompanyUpdate(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    country: Optional[str] = None
    stand: Optional[str] = None
    contact_name: Optional[str] = None
    contact_email: Optional[str] = None
    status: Optional[str] = None
    notes_fr: Optional[str] = None
    notes_en: Optional[str] = None

# ── Exhibition CRUD ──

@router.get("")
def list_exhibitions(db: Session = Depends(get_db)):
    exhs = db.query(Exhibition).order_by(Exhibition.created_at.desc()).all()
    result = []
    for e in exhs:
        count = db.query(ExhibitionCompany).filter(ExhibitionCompany.exhibition_id == e.id).count()
        result.append({
            "id": e.id,
            "name": e.name,
            "date": e.date,
            "location": e.location,
            "company_count": count,
            "created_at": str(e.created_at) if e.created_at else None,
        })
    return result

@router.post("")
def create_exhibition(data: ExhibitionCreate, db: Session = Depends(get_db)):
    exh = Exhibition(name=data.name, date=data.date, location=data.location)
    db.add(exh)
    db.commit()
    db.refresh(exh)
    return {"id": exh.id, "name": exh.name, "date": exh.date, "location": exh.location}

@router.put("/{exhibition_id}")
def update_exhibition(exhibition_id: int, data: ExhibitionUpdate, db: Session = Depends(get_db)):
    exh = db.query(Exhibition).filter(Exhibition.id == exhibition_id).first()
    if not exh:
        raise HTTPException(404, "Exhibition not found")
    if data.name is not None: exh.name = data.name
    if data.date is not None: exh.date = data.date
    if data.location is not None: exh.location = data.location
    exh.updated_at = datetime.now()
    db.commit()
    return {"ok": True}

@router.delete("/{exhibition_id}")
def delete_exhibition(exhibition_id: int, db: Session = Depends(get_db)):
    db.query(ExhibitionCompany).filter(ExhibitionCompany.exhibition_id == exhibition_id).delete()
    db.query(Exhibition).filter(Exhibition.id == exhibition_id).delete()
    db.commit()
    return {"ok": True}

# ── Company CRUD ──

@router.get("/{exhibition_id}/companies")
def list_companies(exhibition_id: int, db: Session = Depends(get_db)):
    cos = db.query(ExhibitionCompany).filter(ExhibitionCompany.exhibition_id == exhibition_id).order_by(ExhibitionCompany.name).all()
    return [{
        "id": c.id,
        "name": c.name,
        "type": c.type,
        "country": c.country,
        "stand": c.stand,
        "contact_name": c.contact_name,
        "contact_email": c.contact_email,
        "status": c.status,
        "notes_fr": c.notes_fr,
        "notes_en": c.notes_en,
        "created_at": str(c.created_at) if c.created_at else None,
    } for c in cos]

@router.post("/{exhibition_id}/companies")
def create_company(exhibition_id: int, data: ExhibitionCompanyCreate, db: Session = Depends(get_db)):
    co_data = data.dict(exclude={"exhibition_id"})
    co = ExhibitionCompany(exhibition_id=exhibition_id, **co_data)
    db.add(co)
    db.commit()
    db.refresh(co)
    return {"id": co.id, "name": co.name}

@router.put("/companies/{company_id}")
def update_company(company_id: int, data: ExhibitionCompanyUpdate, db: Session = Depends(get_db)):
    co = db.query(ExhibitionCompany).filter(ExhibitionCompany.id == company_id).first()
    if not co:
        raise HTTPException(404, "Company not found")
    for field, value in data.dict(exclude_unset=True).items():
        setattr(co, field, value)
    db.commit()
    return {"ok": True}

@router.delete("/companies/{company_id}")
def delete_company(company_id: int, db: Session = Depends(get_db)):
    db.query(ExhibitionCompany).filter(ExhibitionCompany.id == company_id).delete()
    db.commit()
    return {"ok": True}
