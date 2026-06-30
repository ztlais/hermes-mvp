from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime, date

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
    job_title: Optional[str]
    address: Optional[str]
    fax: Optional[str]
    notes_en: Optional[str]
    raw_transcript: Optional[str]
    email_draft: Optional[str]
    transcript_processed: Optional[bool]
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
    job_title: Optional[str] = None
    address: Optional[str] = None
    fax: Optional[str] = None
    raw_transcript: Optional[str] = None
    email_draft: Optional[str] = None
    transcript_processed: Optional[bool] = None


@router.get("/", response_model=List[ProspectSchema])
def get_prospects(
    status: Optional[str] = None,
    type: Optional[str] = None,
    search: Optional[str] = None,
    source: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Prospect)
    if status:
        query = query.filter(Prospect.status == status)
    if type:
        query = query.filter(Prospect.type == type)
    if source:
        query = query.filter(Prospect.source.ilike(f"%{source}%"))
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


@router.post("/{prospect_id}/sync-to-crm")
def sync_prospect_to_crm(prospect_id: int, db: Session = Depends(get_db)):
    """Sync prospect notes to Google Sheet CRM and create weekly task."""
    p = db.query(Prospect).filter(Prospect.id == prospect_id).first()
    if not p:
        raise HTTPException(404, "Prospect non trouvé")

    results = {"sheets": False, "task": False, "errors": []}

    # 1. Sync to Google Sheets CRM
    try:
        from google.oauth2.credentials import Credentials
        from googleapiclient.discovery import build
        creds = Credentials.from_authorized_user_file('/root/.hermes/google_token.json')
        sheets = build('sheets', 'v4', credentials=creds)

        CRM_ID = '1ZsFcbzY8xIqqmp9OeARIkIqy-2oobQzxXbxn4tHYPQE'
        result = sheets.spreadsheets().values().get(
            spreadsheetId=CRM_ID, range="Follow-ups!A:O"
        ).execute()
        rows = result.get('values', [])

        # Find Valeco row by company name
        target_row = None
        for i, row in enumerate(rows[1:], start=2):
            if len(row) > 3 and p.company.lower() in str(row[3]).lower():
                target_row = i
                break

        if target_row:
            notes_col = f"Follow-ups!O{target_row}"
            sheets.spreadsheets().values().update(
                spreadsheetId=CRM_ID, range=notes_col,
                valueInputOption='USER_ENTERED',
                body={'values': [[p.notes or ""]]}
            ).execute()
            results["sheets"] = True
        else:
            results["errors"].append(f"{p.company} non trouvé dans le CRM Google Sheets")
    except Exception as e:
        results["errors"].append(f"Erreur Google Sheets: {str(e)[:100]}")

    # 2. Create/update weekly task
    try:
        from models.weekly_task import WeeklyTask
        from sqlalchemy import text

        today = date.today()
        monday = today.__class__.fromordinal(today.toordinal() - today.weekday())

        # Check if task exists for this company this week
        existing = db.query(WeeklyTask).filter(
            WeeklyTask.related_company.ilike(f"%{p.company}%"),
            WeeklyTask.week_start == monday
        ).first()

        title = f"Suivi {p.company}"
        if p.next_action:
            title += f" — {p.next_action[:40]}" 

        if existing:
            existing.title = title
            existing.description = p.notes or ""
            existing.priority = "haute" if p.status == "nda_signed" else "moyenne"
        else:
            task = WeeklyTask(
                title=title,
                description=p.notes or "",
                category="prospect",
                priority="haute" if p.status == "nda_signed" else "moyenne",
                assignee="",
                related_company=p.company,
                prospect_id=p.id,
                week_start=monday,
            )
            db.add(task)
        db.commit()
        results["task"] = True
    except Exception as e:
        results["errors"].append(f"Erreur tâche: {str(e)[:100]}")

    return {
        "ok": True,
        "prospect": p.company,
        "sheets_updated": results["sheets"],
        "task_created": results["task"],
        "errors": results["errors"],
    }
