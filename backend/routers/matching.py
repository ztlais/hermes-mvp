from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel

from database import get_db
from models.project import Project, ProjectStage
from models.investor import Investor
from models.prospect import Prospect

router = APIRouter(prefix="/matching", tags=["matching"])

# Mots-clés par technologie de projet
TECH_KEYWORDS = {
    'solar':    ['pv', 'solar', 'solaire', 'photovolt', 'toiture', 'ombri', 'agri', 'agrivolt', 'flottant', 'sol', 'ground', 'c&i', 'rooftop'],
    'wind':     ['wind', 'eolien', 'éolien', 'onshore', 'offshore', 'aeolien'],
    'bess':     ['bess', 'storage', 'stockage', 'batterie', 'battery'],
    'hydrogen': ['hydrogen', 'hydrogène', 'h2'],
    'other':    ['pv', 'solar', 'solaire', 'agri', 'toiture'],  # "other" souvent agrivoltaïque ou toiture
}

# Mots-clés par code pays de projet
COUNTRY_KEYWORDS = {
    'FR': ['france', 'fr', 'french', 'europe', 'européen', 'europeen'],
    'IT': ['italie', 'it', 'italia', 'italy', 'europe', 'européen'],
    'ES': ['espagne', 'es', 'spain', 'españa', 'europe', 'européen'],
    'DE': ['allemagne', 'de', 'germany', 'europe', 'européen'],
    'UK': ['uk', 'royaume', 'angleterre', 'britain', 'europe'],
    'PL': ['pologne', 'pl', 'poland', 'europe'],
    'BE': ['belgique', 'be', 'belgium', 'europe'],
    'NL': ['pays-bas', 'nl', 'netherlands', 'holland', 'europe'],
    'PT': ['portugal', 'pt', 'europe'],
    'GR': ['grèce', 'gr', 'greece', 'europe'],
}

STAGE_MAP = {
    'development':    ['development', 'develop', 'early', 'dev'],
    'permitting':     ['permitting', 'permit', 'autorisation', 'instruction'],
    'ready_to_build': ['rtb', 'ready', 'ready_to_build', 'pret', 'prêt'],
    'construction':   ['construction', 'build', 'cod'],
    'operational':    ['operational', 'operation', 'exploitat'],
}


def tolist(val):
    return [v.strip() for v in val.split(',') if v.strip()] if val else []


def tech_matches(investor_tech_str, proj_tech):
    if not investor_tech_str:
        return None  # pas de filtre
    keywords = TECH_KEYWORDS.get(proj_tech, [])
    text = investor_tech_str.lower()
    return any(kw in text for kw in keywords)


def country_matches(investor_country_str, proj_country):
    if not investor_country_str:
        return None  # pas de filtre
    keywords = COUNTRY_KEYWORDS.get((proj_country or '').upper(), [proj_country.lower() if proj_country else ''])
    text = investor_country_str.lower()
    return any(kw in text for kw in keywords)


def stage_matches(investor_stage_str, proj_stage_value):
    if not investor_stage_str:
        return None  # pas de filtre
    keywords = STAGE_MAP.get(proj_stage_value, [proj_stage_value])
    text = investor_stage_str.lower()
    return any(kw in text for kw in keywords)


def compute_score(investor: Investor, project: Project) -> tuple[int, list[dict]]:
    reasons = []
    score = 0

    proj_tech = project.technology.value if project.technology else ''
    proj_stage = project.stage.value if project.stage else ''

    # Technologie — 35 pts
    tech_match = tech_matches(investor.technologies, proj_tech)
    if tech_match is True:
        score += 35
        reasons.append({'label': 'Technologie ✓', 'key': 'tech_match', 'detail': proj_tech, 'pts': 35, 'match': True})
    elif tech_match is None:
        score += 15
        reasons.append({'label': 'Technologie', 'key': 'tech_no_filter', 'detail': proj_tech, 'pts': 15, 'match': True})
    else:
        reasons.append({'label': 'Technologie ✗', 'key': 'tech_no_match', 'detail': proj_tech, 'pts': 0, 'match': False})

    # Pays — 25 pts
    ctry_match = country_matches(investor.target_countries, project.country)
    if ctry_match is True:
        score += 25
        reasons.append({'label': 'Pays ✓', 'key': 'country_match', 'detail': project.country, 'pts': 25, 'match': True})
    elif ctry_match is None:
        score += 10
        reasons.append({'label': 'Pays', 'key': 'country_no_filter', 'detail': project.country, 'pts': 10, 'match': True})
    else:
        reasons.append({'label': 'Pays ✗', 'key': 'country_no_match', 'detail': project.country, 'pts': 0, 'match': False})

    # Stade — 20 pts
    stade_match = stage_matches(investor.deal_stages, proj_stage)
    if stade_match is True:
        score += 20
        reasons.append({'label': 'Stade ✓', 'key': 'stage_match', 'detail': proj_stage, 'pts': 20, 'match': True})
    elif stade_match is None:
        score += 10
        reasons.append({'label': 'Stade', 'key': 'stage_no_filter', 'detail': proj_stage, 'pts': 10, 'match': True})
    else:
        reasons.append({'label': 'Stade ✗', 'key': 'stage_no_match', 'detail': proj_stage, 'pts': 0, 'match': False})

    # Capacité MW — 15 pts
    if project.capacity_mw:
        if investor.min_mw and investor.max_mw:
            if investor.min_mw <= project.capacity_mw <= investor.max_mw:
                score += 15
                reasons.append({'label': 'Capacité ✓', 'key': 'capacity_match', 'detail': f'{project.capacity_mw} MW [{investor.min_mw}–{investor.max_mw}]', 'pts': 15, 'match': True})
            else:
                reasons.append({'label': 'Capacité ✗', 'key': 'capacity_no_match', 'detail': f'{project.capacity_mw} MW [{investor.min_mw}–{investor.max_mw}]', 'pts': 0, 'match': False})
        elif investor.min_mw and project.capacity_mw >= investor.min_mw:
            score += 10
            reasons.append({'label': 'Capacité ✓', 'key': 'capacity_match', 'detail': f'{project.capacity_mw} MW ≥ {investor.min_mw} MW', 'pts': 10, 'match': True})
        elif investor.max_mw and project.capacity_mw <= investor.max_mw:
            score += 10
            reasons.append({'label': 'Capacité ✓', 'key': 'capacity_match', 'detail': f'{project.capacity_mw} MW ≤ {investor.max_mw} MW', 'pts': 10, 'match': True})
        else:
            score += 5
            reasons.append({'label': 'Capacité', 'key': 'capacity_no_range', 'detail': f'{project.capacity_mw} MW', 'pts': 5, 'match': True})
    else:
        score += 5
        reasons.append({'label': 'Capacité', 'key': 'capacity_no_range', 'detail': '', 'pts': 5, 'match': True})

    # NDA — 5 pts bonus
    if project.nda_signed == 'Oui':
        score += 5
        reasons.append({'label': 'NDA signé ✓', 'key': 'nda_bonus', 'detail': '', 'pts': 5, 'match': True})

    return min(score, 100), reasons


class MatchResult(BaseModel):
    investor_id: int
    investor_company: str
    investor_contact: Optional[str]
    investor_email: Optional[str]
    investor_technologies: Optional[str]
    investor_countries: Optional[str]
    project_id: int
    project_name: str
    project_developer: Optional[str]
    project_technology: Optional[str]
    project_stage: Optional[str]
    project_capacity_mw: Optional[float]
    project_country: Optional[str]
    project_region: Optional[str]
    project_description: Optional[str]
    score: int
    reasons: list


@router.get("/investors")
def get_matching_investors(db: Session = Depends(get_db)):
    investors = db.query(Investor).filter(Investor.status == 'active').all()
    return [{"id": i.id, "company": i.company, "contact_name": i.contact_name} for i in investors]


@router.get("/developers")
def get_matching_developers(db: Session = Depends(get_db)):
    # Collect developers from projects and prospects
    devs = set()
    project_devs = db.query(Project.developer_name).filter(Project.developer_name.isnot(None)).distinct().all()
    for d in project_devs:
        if d[0] and d[0].strip():
            devs.add(d[0].strip())
    # Also from prospects
    prospects = db.query(Prospect.company, Prospect.contact_name).filter(Prospect.type == 'developer').all()
    for p in prospects:
        if p[0] and p[0].strip():
            devs.add(p[0].strip())
    return sorted([{"name": d} for d in devs], key=lambda x: x["name"].lower())


@router.get("/", response_model=List[MatchResult])
def get_matches(
    min_score: int = 30,
    technology: Optional[str] = None,
    country: Optional[str] = None,
    investor_id: Optional[int] = None,
    developer: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Investor).filter(Investor.status == 'active')
    if investor_id:
        query = query.filter(Investor.id == investor_id)
    investors = query.all()

    projects = db.query(Project).all()

    if technology:
        projects = [p for p in projects if p.technology and p.technology.value == technology]
    if country:
        projects = [p for p in projects if p.country and p.country.upper() == country.upper()]
    if developer:
        dl = developer.lower()
        projects = [p for p in projects if (p.developer_name and dl in p.developer_name.lower())
                     or (p.developer_id and dl in str(p.developer_id))]

    # Précharger les prospects pour la résolution des développeurs
    prospects = {p.id: p.company for p in db.query(Prospect).all()}

    results = []
    for investor in investors:
        for project in projects:
            score, reasons = compute_score(investor, project)
            if score >= min_score:
                # Nom du développeur : champ libre d'abord, sinon via FK
                developer = project.developer_name or prospects.get(project.developer_id, None)
                results.append(MatchResult(
                    investor_id=investor.id,
                    investor_company=investor.company,
                    investor_contact=investor.contact_name,
                    investor_email=investor.email,
                    investor_technologies=investor.technologies,
                    investor_countries=investor.target_countries,
                    project_id=project.id,
                    project_name=project.name,
                    project_developer=developer,
                    project_technology=project.technology.value if project.technology else None,
                    project_stage=project.stage.value if project.stage else None,
                    project_capacity_mw=project.capacity_mw,
                    project_country=project.country,
                    project_region=project.region,
                    project_description=project.description,
                    score=score,
                    reasons=reasons,
                ))

    return sorted(results, key=lambda x: x.score, reverse=True)
