from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

from database import get_db
from models.template import Template, TemplateType, TemplateTarget

router = APIRouter(prefix="/templates", tags=["templates"])


class TemplateSchema(BaseModel):
    id: int
    name: str
    type: Optional[str]
    target: Optional[str]
    subject: Optional[str]
    body: str
    language: Optional[str]
    step: Optional[int]
    notes: Optional[str]
    created_at: Optional[datetime]

    class Config:
        from_attributes = True


class TemplateCreate(BaseModel):
    name: str
    type: Optional[TemplateType] = TemplateType.email
    target: Optional[TemplateTarget] = TemplateTarget.developer
    subject: Optional[str] = None
    body: str
    language: Optional[str] = "fr"
    step: Optional[int] = 1
    notes: Optional[str] = None


@router.get("/", response_model=List[TemplateSchema])
def get_templates(
    type: Optional[str] = None,
    target: Optional[str] = None,
    language: Optional[str] = None,
    step: Optional[int] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Template)
    if type:
        query = query.filter(Template.type == type)
    if target:
        query = query.filter(Template.target == target)
    if language:
        query = query.filter(Template.language == language)
    if step is not None:
        query = query.filter(Template.step == step)
    return query.order_by(Template.name).all()


@router.post("/", response_model=TemplateSchema)
def create_template(data: TemplateCreate, db: Session = Depends(get_db)):
    t = Template(**data.model_dump())
    db.add(t)
    db.commit()
    db.refresh(t)
    return t


@router.put("/{template_id}", response_model=TemplateSchema)
def update_template(template_id: int, data: TemplateCreate, db: Session = Depends(get_db)):
    t = db.query(Template).filter(Template.id == template_id).first()
    if not t:
        raise HTTPException(status_code=404, detail="Template non trouvé")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(t, key, value)
    db.commit()
    db.refresh(t)
    return t


@router.delete("/{template_id}")
def delete_template(template_id: int, db: Session = Depends(get_db)):
    t = db.query(Template).filter(Template.id == template_id).first()
    if not t:
        raise HTTPException(status_code=404, detail="Template non trouvé")
    db.delete(t)
    db.commit()
    return {"message": "Supprimé"}
