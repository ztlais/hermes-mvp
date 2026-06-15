from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime
import random

from database import get_db
from models.learning import Learning, LearningCategory

router = APIRouter(prefix="/learning", tags=["learning"])


class LearningSchema(BaseModel):
    id: int
    term: str
    definition: str
    category: Optional[str]
    example: Optional[str]
    source: Optional[str]
    language: Optional[str]
    active: Optional[bool]
    created_at: Optional[datetime]

    class Config:
        from_attributes = True


class LearningCreate(BaseModel):
    term: str
    definition: str
    category: Optional[LearningCategory] = LearningCategory.vocabulary
    example: Optional[str] = None
    source: Optional[str] = None
    language: Optional[str] = "fr"


class QuizQuestion(BaseModel):
    id: int
    term: str
    correct_definition: str
    choices: List[str]


@router.get("/", response_model=List[LearningSchema])
def get_learning(
    category: Optional[str] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Learning).filter(Learning.active == True)
    if category:
        query = query.filter(Learning.category == category)
    if search:
        query = query.filter(
            Learning.term.ilike(f"%{search}%") |
            Learning.definition.ilike(f"%{search}%")
        )
    return query.order_by(Learning.term).all()


@router.post("/", response_model=LearningSchema)
def create_learning(data: LearningCreate, db: Session = Depends(get_db)):
    item = Learning(**data.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


@router.delete("/{item_id}")
def delete_learning(item_id: int, db: Session = Depends(get_db)):
    item = db.query(Learning).filter(Learning.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Non trouvé")
    db.delete(item)
    db.commit()
    return {"message": "Supprimé"}


@router.get("/quiz", response_model=List[QuizQuestion])
def get_quiz(count: int = 5, db: Session = Depends(get_db)):
    all_items = db.query(Learning).filter(Learning.active == True).all()
    if len(all_items) < 4:
        raise HTTPException(status_code=400, detail="Pas assez de termes pour un quiz (minimum 4)")

    selected = random.sample(all_items, min(count, len(all_items)))
    questions = []

    for item in selected:
        wrong = [x for x in all_items if x.id != item.id]
        wrong_choices = random.sample(wrong, min(3, len(wrong)))
        choices = [item.definition] + [w.definition for w in wrong_choices]
        random.shuffle(choices)
        questions.append(QuizQuestion(
            id=item.id,
            term=item.term,
            correct_definition=item.definition,
            choices=choices,
        ))

    return questions
