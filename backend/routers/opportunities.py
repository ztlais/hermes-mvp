from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime
import requests
import re

from database import get_db
from models.opportunity import Opportunity, OpportunityType, OpportunityStatus
from models.prospect import Prospect


def translate_fr_to_en(text: str) -> str:
    """Translate French text to English using Google Translate (free, no API key)"""
    if not text or not text.strip():
        return text
    try:
        url = "https://translate.googleapis.com/translate_a/single"
        params = {"client": "gtx", "sl": "fr", "tl": "en", "dt": "t", "q": text}
        r = requests.get(url, params=params, timeout=10)
        r.raise_for_status()
        result = r.json()
        translated = "".join(part[0] for part in result[0])
        return translated
    except Exception:
        return text

router = APIRouter(prefix="/opportunities", tags=["opportunities"])


class OpportunitySchema(BaseModel):
    id: int
    prospect_id: Optional[int]
    prospect_name: Optional[str] = None
    title: str
    title_en: Optional[str] = None
    type: Optional[str]
    country: Optional[str]
    size_eur: Optional[float]
    size_mw: Optional[float]
    deadline: Optional[datetime]
    status: Optional[str]
    notes: Optional[str]
    notes_en: Optional[str] = None
    created_at: Optional[datetime]
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True


class OpportunityCreate(BaseModel):
    prospect_id: Optional[int] = None
    title: str
    title_en: Optional[str] = None
    type: Optional[OpportunityType] = OpportunityType.financement
    country: Optional[str] = None
    size_eur: Optional[float] = None
    size_mw: Optional[float] = None
    deadline: Optional[datetime] = None
    status: Optional[OpportunityStatus] = OpportunityStatus.en_discussion
    notes: Optional[str] = None
    notes_en: Optional[str] = None


def enrich(opp, db):
    data = OpportunitySchema.model_validate(opp)
    if opp.prospect_id:
        p = db.query(Prospect).filter(Prospect.id == opp.prospect_id).first()
        if p:
            data.prospect_name = p.company
    return data


@router.get("/", response_model=List[OpportunitySchema])
def get_opportunities(
    status: Optional[str] = None,
    type: Optional[str] = None,
    prospect_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Opportunity)
    if status:
        query = query.filter(Opportunity.status == status)
    if type:
        query = query.filter(Opportunity.type == type)
    if prospect_id:
        query = query.filter(Opportunity.prospect_id == prospect_id)
    opps = query.order_by(Opportunity.deadline.asc().nullslast(), Opportunity.updated_at.desc()).all()
    return [enrich(o, db) for o in opps]


@router.get("/stats/summary")
def get_stats(db: Session = Depends(get_db)):
    total = db.query(Opportunity).count()
    by_status = {s.value: db.query(Opportunity).filter(Opportunity.status == s).count() for s in OpportunityStatus}
    by_type = {t.value: db.query(Opportunity).filter(Opportunity.type == t).count() for t in OpportunityType}
    return {"total": total, "by_status": by_status, "by_type": by_type}


@router.get("/{opp_id}", response_model=OpportunitySchema)
def get_opportunity(opp_id: int, db: Session = Depends(get_db)):
    opp = db.query(Opportunity).filter(Opportunity.id == opp_id).first()
    if not opp:
        raise HTTPException(status_code=404, detail="Opportunité non trouvée")
    return enrich(opp, db)


@router.post("/", response_model=OpportunitySchema)
def create_opportunity(data: OpportunityCreate, db: Session = Depends(get_db)):
    opp = Opportunity(**data.model_dump())
    db.add(opp)
    db.commit()
    db.refresh(opp)
    return enrich(opp, db)


@router.put("/{opp_id}", response_model=OpportunitySchema)
def update_opportunity(opp_id: int, data: OpportunityCreate, db: Session = Depends(get_db)):
    opp = db.query(Opportunity).filter(Opportunity.id == opp_id).first()
    if not opp:
        raise HTTPException(status_code=404, detail="Opportunité non trouvée")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(opp, key, value)
    db.commit()
    db.refresh(opp)
    return enrich(opp, db)


@router.delete("/{opp_id}")
def delete_opportunity(opp_id: int, db: Session = Depends(get_db)):
    opp = db.query(Opportunity).filter(Opportunity.id == opp_id).first()
    if not opp:
        raise HTTPException(status_code=404, detail="Opportunité non trouvée")
    db.delete(opp)
    db.commit()
    return {"message": "Supprimé"}


@router.post("/{opp_id}/translate-notes")
def translate_notes(opp_id: int, db: Session = Depends(get_db)):
    """Traduit les notes en anglais et les sauvegarde dans notes_en"""
    opp = db.query(Opportunity).filter(Opportunity.id == opp_id).first()
    if not opp:
        raise HTTPException(status_code=404, detail="Opportunité non trouvée")
    if not opp.notes and not opp.title:
        raise HTTPException(status_code=400, detail="Rien à traduire")
    if opp.notes:
        opp.notes_en = translate_fr_to_en(opp.notes)
    if opp.title:
        opp.title_en = translate_fr_to_en(opp.title)
    db.commit()
    db.refresh(opp)
    return enrich(opp, db)
