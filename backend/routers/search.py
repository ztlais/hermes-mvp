from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_, cast, String
from database import get_db
from models.prospect import Prospect
from models.investor import Investor
from models.project import Project
from models.scouting import Scouting
from models.opportunity import Opportunity

router = APIRouter(prefix="/search", tags=["search"])


@router.get("/global")
def global_search(q: str = Query(..., min_length=1), db: Session = Depends(get_db)):
    q = q.strip()
    if not q:
        return {"results": []}

    pattern = f"%{q}%"
    results = []

    # Prospects
    prospects = db.query(Prospect).filter(
        or_(
            Prospect.company.ilike(pattern),
            Prospect.contact_name.ilike(pattern),
            Prospect.email.ilike(pattern),
            Prospect.notes.ilike(pattern),
            Prospect.next_action.ilike(pattern),
        )
    ).limit(8).all()
    for p in prospects:
        results.append({
            "type": "prospect",
            "type_label": "Prospect",
            "type_color": "#2563eb",
            "id": p.id,
            "title": p.company,
            "subtitle": p.contact_name or p.email or "",
            "meta": p.status or "",
            "country": p.country or "",
        })

    # Investors
    investors = db.query(Investor).filter(
        or_(
            Investor.company.ilike(pattern),
            Investor.contact_name.ilike(pattern),
            Investor.email.ilike(pattern),
            Investor.notes.ilike(pattern),
        )
    ).limit(8).all()
    for inv in investors:
        results.append({
            "type": "investor",
            "type_label": "Investisseur",
            "type_color": "#0891b2",
            "id": inv.id,
            "title": inv.company,
            "subtitle": inv.contact_name or inv.email or "",
            "meta": inv.status or "",
            "country": inv.country or "",
        })

    # Projects
    projects = db.query(Project).filter(
        or_(
            Project.name.ilike(pattern),
            Project.developer_name.ilike(pattern),
            Project.region.ilike(pattern),
            Project.notes.ilike(pattern),
            Project.status_detail.ilike(pattern),
        )
    ).limit(8).all()
    for proj in projects:
        results.append({
            "type": "project",
            "type_label": "Projet",
            "type_color": "#d97706",
            "id": proj.id,
            "title": proj.name,
            "subtitle": f"{proj.developer_name or ''}{' · ' + proj.region if proj.region else ''}",
            "meta": f"{proj.capacity_mw or ''} MW · {proj.stage or ''}",
            "country": proj.country or "",
        })

    # Scouting
    scoutings = db.query(Scouting).filter(
        or_(
            Scouting.company.ilike(pattern),
            Scouting.contact_name.ilike(pattern),
            Scouting.email.ilike(pattern),
            Scouting.notes.ilike(pattern),
        )
    ).limit(6).all()
    for s in scoutings:
        results.append({
            "type": "scouting",
            "type_label": "Scouting",
            "type_color": "#7c3aed",
            "id": s.id,
            "title": s.company,
            "subtitle": s.contact_name or s.email or "",
            "meta": s.status or "",
            "country": s.country or "",
        })

    # Opportunities
    opps = db.query(Opportunity).filter(
        or_(
            Opportunity.title.ilike(pattern),
            Opportunity.notes.ilike(pattern),
        )
    ).limit(5).all()
    for o in opps:
        results.append({
            "type": "opportunity",
            "type_label": "Opportunité",
            "type_color": "#059669",
            "id": o.id,
            "title": o.title,
            "subtitle": o.type or "",
            "meta": o.status or "",
            "country": o.country or "",
        })

    return {"query": q, "total": len(results), "results": results}
