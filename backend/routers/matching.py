import json
import os

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel

from database import get_db
from models.project import Project, ProjectStage
from models.investor import Investor
from models.prospect import Prospect

router = APIRouter(prefix="/matching", tags=["matching"])

AI_MATCH_MODEL = "claude-sonnet-4-6"
AI_MATCH_CANDIDATE_CAP = 15  # nombre max de paires investisseur/projet envoyees a l'IA par appel

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


def _analyze_matches_with_ai(candidates: List[dict]) -> dict:
    """Demande a l'IA d'affiner le score deterministe en lisant les notes/criteres
    de l'investisseur et la description/notes du projet, pour capter des nuances
    que le matching par mots-cles ne voit pas (ex: un critere d'exclusion mentionne
    dans les notes, un IRR cible non atteint, un developpeur deja connu negativement).

    Chaque candidat doit avoir une cle "ref" unique (ex: "inv:5|proj:12").
    Retourne un dict {ref: {"score": int, "reason": str}}.
    Retourne {} si la cle API est absente ou si l'appel echoue (fallback silencieux
    vers le score deterministe existant).
    """
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key or not candidates:
        return {}

    try:
        import anthropic
    except ImportError:
        return {}

    def _fmt(c):
        return (
            f"[REF={c['ref']}]\n"
            f"Investisseur: {c['investor_company']} | Technologies visees: {c['investor_technologies'] or 'non precise'} | "
            f"Pays cibles: {c['investor_countries'] or 'non precise'} | Stades: {c['investor_stages'] or 'non precise'} | "
            f"Fourchette MW: {c['investor_min_mw'] or '?'}-{c['investor_max_mw'] or '?'}\n"
            f"Criteres investisseur: {(c['investor_criteria'] or 'aucun')[:400]}\n"
            f"Notes investisseur: {(c['investor_notes'] or 'aucune')[:400]}\n"
            f"Projet: {c['project_name']} | {c['project_technology']} | Stade: {c['project_stage']} | "
            f"{c['project_capacity_mw'] or '?'} MW | Pays: {c['project_country']}\n"
            f"Description projet: {(c['project_description'] or 'aucune')[:400]}\n"
            f"Notes projet: {(c['project_notes'] or 'aucune')[:300]}\n"
            f"Score deterministe (mots-cles): {c['deterministic_score']}/100"
        )

    candidates_text = "\n\n".join(_fmt(c) for c in candidates)

    prompt = f"""Tu es l'assistant d'un Entrepreneur in Residence dans le secteur des energies renouvelables qui evalue des paires investisseur/projet pour un matching de deal flow.

Le score ci-dessous pour chaque paire a ete calcule par mots-cles (technologie, pays, stade, MW). Ta tache : lire les notes et criteres en texte libre pour detecter des nuances que les mots-cles ratent (ex: un critere d'exclusion mentionne dans les notes, un developpeur deja connu negativement, un IRR/prix vise non atteint, une raison specifique qui renforce ou affaiblit le match).

Paires a evaluer:
{candidates_text}

Pour CHAQUE paire, propose un score ajuste de 0 a 100 (tu peux confirmer le score deterministe si rien de notable, ou l'ajuster a la hausse/baisse selon les notes) et une phrase courte expliquant ton evaluation.

Reponds UNIQUEMENT avec un JSON valide : une liste d'objets, un par paire recue, avec ces cles exactes :
- "ref": UNIQUEMENT la valeur entre crochets [REF=...] de la paire, sans le reste de la ligne
- "score": le score ajuste (entier 0-100)
- "reason": MAXIMUM 20 mots, en francais, expliquant l'ajustement ou la confirmation

Exemple de format attendu pour deux paires [REF=inv:5|proj:12] et [REF=inv:8|proj:3] :
[{{"ref": "inv:5|proj:12", "score": 75, "reason": "..."}}, {{"ref": "inv:8|proj:3", "score": 40, "reason": "..."}}]

Reste concis. Ne reponds rien d'autre que ce JSON."""

    try:
        client = anthropic.Anthropic(api_key=api_key)
        response = client.messages.create(
            model=AI_MATCH_MODEL,
            max_tokens=4000,
            timeout=45,
            messages=[{"role": "user", "content": prompt}],
        )
        raw = response.content[0].text.strip()
        if raw.startswith("```"):
            raw = raw.strip("`")
            if raw.startswith("json"):
                raw = raw[4:]
        items = json.loads(raw)
        known_refs = {c["ref"] for c in candidates}
        results = {}
        for item in items:
            if not isinstance(item, dict) or "ref" not in item:
                continue
            ref = str(item["ref"])
            if ref not in known_refs:
                continue
            results[ref] = item
        return results
    except Exception:
        return {}


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
    project_department: Optional[str]
    project_description: Optional[str]
    score: int
    reasons: list
    ai_score: Optional[int] = None
    ai_reason: Optional[str] = None
    ai_generated: bool = False


def _find_candidate_pairs(db, min_score, technology, country, investor_id, developer):
    """Calcule le score deterministe pour chaque paire investisseur/projet active
    et renvoie les tuples (investor, project, score, reasons) au-dessus de min_score,
    triees par score decroissant. Partagee par / et /analyze.
    """
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

    pairs = []
    for investor in investors:
        for project in projects:
            score, reasons = compute_score(investor, project)
            if score >= min_score:
                pairs.append((investor, project, score, reasons))

    pairs.sort(key=lambda x: x[2], reverse=True)
    return pairs


def _to_match_result(investor, project, score, reasons, prospects_by_id, ai=None):
    developer_name = project.developer_name or prospects_by_id.get(project.developer_id, None)
    return MatchResult(
        investor_id=investor.id,
        investor_company=investor.company,
        investor_contact=investor.contact_name,
        investor_email=investor.email,
        investor_technologies=investor.technologies,
        investor_countries=investor.target_countries,
        project_id=project.id,
        project_name=project.name,
        project_developer=developer_name,
        project_technology=project.technology.value if project.technology else None,
        project_stage=project.stage.value if project.stage else None,
        project_capacity_mw=project.capacity_mw,
        project_country=project.country,
        project_region=project.region,
        project_department=project.department,
        project_description=project.description,
        score=score,
        reasons=reasons,
        ai_score=ai.get("score") if ai else None,
        ai_reason=ai.get("reason") if ai else None,
        ai_generated=bool(ai),
    )


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
    pairs = _find_candidate_pairs(db, min_score, technology, country, investor_id, developer)
    prospects = {p.id: p.company for p in db.query(Prospect).all()}
    return [_to_match_result(inv, proj, score, reasons, prospects) for inv, proj, score, reasons in pairs]


@router.get("/analyze", response_model=List[MatchResult])
def analyze_matches_with_ai(
    min_score: int = 30,
    technology: Optional[str] = None,
    country: Optional[str] = None,
    investor_id: Optional[int] = None,
    developer: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Comme / mais enrichit les meilleurs candidats (score deterministe le plus haut)
    avec une analyse IA qui lit les notes/criteres en texte libre pour affiner le score.
    """
    pairs = _find_candidate_pairs(db, min_score, technology, country, investor_id, developer)
    prospects = {p.id: p.company for p in db.query(Prospect).all()}

    top_pairs = pairs[:AI_MATCH_CANDIDATE_CAP]
    ai_results = _analyze_matches_with_ai([
        {
            "ref": f"inv:{inv.id}|proj:{proj.id}",
            "investor_company": inv.company,
            "investor_technologies": inv.technologies,
            "investor_countries": inv.target_countries,
            "investor_stages": inv.deal_stages,
            "investor_min_mw": inv.min_mw,
            "investor_max_mw": inv.max_mw,
            "investor_criteria": inv.criteria,
            "investor_notes": inv.notes,
            "project_name": proj.name,
            "project_technology": proj.technology.value if proj.technology else None,
            "project_stage": proj.stage.value if proj.stage else None,
            "project_capacity_mw": proj.capacity_mw,
            "project_country": proj.country,
            "project_description": proj.description,
            "project_notes": proj.notes,
            "deterministic_score": score,
        }
        for inv, proj, score, reasons in top_pairs
    ])

    results = []
    for inv, proj, score, reasons in pairs:
        ref = f"inv:{inv.id}|proj:{proj.id}"
        ai = ai_results.get(ref)
        results.append(_to_match_result(inv, proj, score, reasons, prospects, ai=ai))

    results.sort(key=lambda r: r.ai_score if r.ai_score is not None else r.score, reverse=True)
    return results
