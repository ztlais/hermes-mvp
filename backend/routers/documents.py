from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

from database import get_db
from models.document import Document

router = APIRouter(prefix="/documents", tags=["documents"])


class DocumentSchema(BaseModel):
    id: int
    prospect_id: Optional[int]
    investor_id: Optional[int]
    name: str
    url: str
    doc_type: Optional[str]
    created_at: Optional[datetime]

    class Config:
        from_attributes = True


class DocumentCreate(BaseModel):
    prospect_id: Optional[int] = None
    investor_id: Optional[int] = None
    name: str
    url: str
    doc_type: Optional[str] = "other"


@router.get("/", response_model=List[DocumentSchema])
def get_documents(
    prospect_id: Optional[int] = None,
    investor_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    q = db.query(Document)
    if prospect_id:
        q = q.filter(Document.prospect_id == prospect_id)
    if investor_id:
        q = q.filter(Document.investor_id == investor_id)
    return q.order_by(Document.created_at).all()


@router.post("/", response_model=DocumentSchema)
def create_document(data: DocumentCreate, db: Session = Depends(get_db)):
    doc = Document(**data.model_dump())
    db.add(doc)
    db.commit()
    db.refresh(doc)
    return doc


@router.delete("/{doc_id}")
def delete_document(doc_id: int, db: Session = Depends(get_db)):
    doc = db.query(Document).filter(Document.id == doc_id).first()
    if not doc:
        raise HTTPException(status_code=404, detail="Document non trouvé")
    db.delete(doc)
    db.commit()
    return {"message": "Supprimé"}
