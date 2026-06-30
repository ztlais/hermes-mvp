import json
import os

from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional, List

from database import get_db
from models.weekly_task import WeeklyTask
from models.prospect import Prospect
from models.task_suggestion import TaskSuggestion

router = APIRouter(prefix="/weekly-tasks", tags=["weekly-tasks"])

AI_SUGGESTION_MODEL = "claude-sonnet-4-6"
AI_CANDIDATE_CAP_PROSPECTS = 15  # nombre max de prospects envoyes a l'IA par appel
AI_CANDIDATE_CAP_INVESTORS = 15  # nombre max d'investisseurs envoyes a l'IA par appel
URGENCY_BOOST = {
    "haute": 5, "moyenne": 2, "basse": 0,
    "high": 5, "medium": 2, "low": 0,  # tolerance si le modele repond en anglais malgre la consigne
}


def _analyze_prospects_with_ai(candidates: List[dict]) -> dict:
    """Demande a l'IA de lire les notes de chaque candidat (prospect OU investisseur)
    et de proposer une tache concrete + un niveau d'urgence base sur le contenu reel
    des notes (relances en attente, promesses non tenues, incoherences statut/notes,
    criteres d'investissement non adresses, etc).

    Chaque candidat doit avoir une cle "ref" unique (ex: "prospect:12", "investor:4").
    Retourne un dict {ref: {"task": str, "urgency": str, "reason": str}}.
    Retourne {} si la cle API est absente ou si l'appel echoue (fallback silencieux
    vers les suggestions deterministes existantes).
    """
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key or not candidates:
        return {}

    try:
        import anthropic
    except ImportError:
        return {}

    def _fmt(c):
        if c["source"] == "investor":
            extra = f"Criteres: {(c.get('criteria') or 'non precise')[:300]}"
        else:
            extra = f"NDA signe: {c['nda_signed']}"
        return (
            f"[REF={c['ref']}] {c['type_label']} {c['company']} ({c['contact_name'] or 'contact inconnu'})\n"
            f"Statut: {c['status']} | {extra} | Action prevue: {c['next_action'] or 'aucune'}\n"
            f"Derniere mise a jour: il y a {c['days_since']} jours\n"
            f"Notes: {(c['notes'] or '(aucune note)')[:800]}"
        )

    candidates_text = "\n\n".join(_fmt(c) for c in candidates)

    prompt = f"""Tu es l'assistant d'un Entrepreneur in Residence dans le secteur des energies renouvelables. Voici une liste de contacts (prospects developpeurs/IPP a faire avancer dans le pipeline, ET investisseurs/fonds a relancer pour du financement) avec leur statut et leurs notes de suivi.

Pour CHAQUE contact, analyse les notes pour comprendre ou en est la relation et propose UNE tache concrete et actionnable a faire cette semaine (en francais, formulee comme une action). Adapte le type de tache au type de contact :
- Pour un prospect : "Relancer X pour...", "Envoyer le NDA a...", "Confirmer le rendez-vous avec..."
- Pour un investisseur : "Relancer le fonds X sur le dossier...", "Envoyer le teaser correspondant aux criteres de...", "Faire le point sur l'avancement du ticket avec..."

Detecte particulierement : les relances en attente depuis longtemps, les promesses de retour non tenues, les actions mentionnees dans les notes mais pas encore faites, les incoherences entre le champ "Action prevue" et ce que disent les notes, et pour les investisseurs les criteres d'investissement non encore adresses.

Contacts:
{candidates_text}

Reponds UNIQUEMENT avec un JSON valide : une liste d'objets, un par contact recu, avec ces cles exactes :
- "ref": UNIQUEMENT la valeur entre crochets [REF=...] du contact, sans le reste de la ligne (ex "prospect:12" ou "investor:4")
- "task": la tache concrete proposee — MAXIMUM 15 mots, en francais
- "urgency": "haute", "moyenne" ou "basse" (en francais, jamais en anglais)
- "reason": pourquoi cette tache est pertinente — MAXIMUM 12 mots

Exemple de format attendu pour deux contacts [REF=prospect:12] et [REF=investor:4] :
[{{"ref": "prospect:12", "task": "...", "urgency": "haute", "reason": "..."}}, {{"ref": "investor:4", "task": "...", "urgency": "basse", "reason": "..."}}]

Reste concis : chaque "task" et "reason" doit etre courte pour que la reponse complete tienne dans la limite de tokens. Ne reponds rien d'autre que ce JSON."""

    try:
        client = anthropic.Anthropic(api_key=api_key)
        response = client.messages.create(
            model=AI_SUGGESTION_MODEL,
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
                # fallback: le modele a renvoye l'id nu (ex "8") sans le prefixe source:
                matches = [r for r in known_refs if r.endswith(f":{ref}")]
                if len(matches) == 1:
                    ref = matches[0]
                else:
                    continue
            results[ref] = item
        return results
    except Exception:
        return {}


class TaskResponse(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    category: str
    related_company: Optional[str] = None
    prospect_id: Optional[int] = None
    outcome: Optional[str] = None
    priority: str
    assignee: str
    status: str
    week_start: Optional[date] = None
    done: bool
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    category: str = "general"
    related_company: Optional[str] = None
    prospect_id: Optional[int] = None
    priority: str = "moyenne"
    assignee: str = ""
    week_start: Optional[date] = None
    suggestion_id: Optional[int] = None  # si cree depuis une suggestion : la supprime de la liste


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    related_company: Optional[str] = None
    prospect_id: Optional[int] = None
    outcome: Optional[str] = None
    priority: Optional[str] = None
    assignee: Optional[str] = None
    status: Optional[str] = None
    done: Optional[bool] = None


def sync_outcome_to_crm(task: WeeklyTask, outcome: str, db: Session):
    """Répercute le résultat d'une tâche terminée sur la fiche prospect liée."""
    if not task.prospect_id or not outcome or not outcome.strip():
        return
    prospect = db.query(Prospect).filter(Prospect.id == task.prospect_id).first()
    if not prospect:
        return
    stamp = date.today().strftime("%d/%m/%Y")
    entry = f"\n[{stamp}] (Tâche: {task.title}) {outcome.strip()}"
    prospect.notes = (prospect.notes or "") + entry
    prospect.last_contact = datetime.utcnow()
    db.add(prospect)


def get_current_week():
    today = date.today()
    return today.__class__.fromordinal(today.toordinal() - today.weekday())


@router.get("/", response_model=List[TaskResponse])
def list_tasks(
    week_start: Optional[date] = None,
    status: Optional[str] = None,
    category: Optional[str] = None,
    db: Session = Depends(get_db),
):
    query = db.query(WeeklyTask)
    if week_start:
        query = query.filter(WeeklyTask.week_start == week_start)
    if status:
        query = query.filter(WeeklyTask.status == status)
    if category:
        query = query.filter(WeeklyTask.category == category)
    query = query.order_by(WeeklyTask.created_at.desc())
    return query.all()


@router.post("/", response_model=TaskResponse)
def create_task(data: TaskCreate, db: Session = Depends(get_db)):
    task = WeeklyTask(
        title=data.title,
        description=data.description,
        category=data.category,
        related_company=data.related_company,
        prospect_id=data.prospect_id,
        priority=data.priority,
        assignee=data.assignee,
        week_start=data.week_start or get_current_week(),
    )
    db.add(task)
    if data.suggestion_id:
        db.query(TaskSuggestion).filter(TaskSuggestion.id == data.suggestion_id).delete()
    db.commit()
    db.refresh(task)
    return task


@router.put("/{task_id}", response_model=TaskResponse)
def update_task(task_id: int, data: TaskUpdate, db: Session = Depends(get_db)):
    task = db.query(WeeklyTask).filter(WeeklyTask.id == task_id).first()
    if not task:
        raise HTTPException(404, "Tâche non trouvée")
    update_data = data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(task, key, value)
    db.commit()
    db.refresh(task)
    return task


@router.put("/{task_id}/done")
def mark_done(task_id: int, body: dict = Body(default={}), db: Session = Depends(get_db)):
    task = db.query(WeeklyTask).filter(WeeklyTask.id == task_id).first()
    if not task:
        raise HTTPException(404, "Tâche non trouvée")
    outcome = body.get("outcome")
    task.done = True
    task.status = "fait"
    if outcome:
        task.outcome = outcome
        sync_outcome_to_crm(task, outcome, db)
    db.commit()
    return {"ok": True}


@router.put("/{task_id}/undone")
def mark_undone(task_id: int, db: Session = Depends(get_db)):
    task = db.query(WeeklyTask).filter(WeeklyTask.id == task_id).first()
    if not task:
        raise HTTPException(404, "Tâche non trouvée")
    task.done = False
    if task.status == "fait":
        task.status = "a_faire"
    db.commit()
    return {"ok": True}


@router.delete("/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(WeeklyTask).filter(WeeklyTask.id == task_id).first()
    if not task:
        raise HTTPException(404, "Tâche non trouvée")
    db.delete(task)
    db.commit()
    return {"deleted": True}


@router.post("/{task_id}/sync-to-crm")
def sync_task_to_crm(task_id: int, db: Session = Depends(get_db)):
    """Sync task description/outcome to prospect CRM + Google Sheets."""
    task = db.query(WeeklyTask).filter(WeeklyTask.id == task_id).first()
    if not task:
        raise HTTPException(404, "Tâche non trouvée")

    results = {"sheets": False, "prospect_db": False, "errors": []}
    company = task.related_company or ""

    # 1. Find linked prospect and update notes
    if task.prospect_id:
        try:
            prospect = db.query(Prospect).filter(Prospect.id == task.prospect_id).first()
            if prospect:
                stamp = date.today().strftime("%d/%m/%Y")
                update = f"\n[{stamp}] (Tâche: {task.title})"
                if task.outcome:
                    update += f" ✅ {task.outcome}"
                elif task.description:
                    update += f" {task.description[:200]}"
                prospect.notes = (prospect.notes or "") + update
                prospect.last_contact = datetime.utcnow()
                db.commit()
                results["prospect_db"] = True
        except Exception as e:
            results["errors"].append(f"Erreur prospect: {str(e)[:100]}")

    # 2. Sync to Google Sheets CRM
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

        search = company or (db.query(Prospect).filter(Prospect.id == task.prospect_id).first().company if task.prospect_id else None)
        target_row = None
        if search:
            for i, row in enumerate(rows[1:], start=2):
                if len(row) > 3 and search.lower() in str(row[3]).lower():
                    target_row = i
                    break

        if target_row:
            notes = f"[{date.today().strftime('%d/%m/%Y')}] (Tâche: {task.title})"
            if task.outcome:
                notes += f" Resultat: {task.outcome}"
            elif task.description:
                notes += f" {task.description[:200]}"
            
            existing = rows[target_row - 1][14] if len(rows[target_row - 1]) > 14 else ""
            updated = (existing + "\n" + notes) if existing else notes
            sheets.spreadsheets().values().update(
                spreadsheetId=CRM_ID,
                range=f"Follow-ups!O{target_row}",
                valueInputOption='USER_ENTERED',
                body={'values': [[updated]]}
            ).execute()
            results["sheets"] = True
        else:
            results["errors"].append(f"{search} non trouvé dans le CRM Google Sheets")
    except Exception as e:
        results["errors"].append(f"Erreur Sheets: {str(e)[:100]}")

    return {
        "ok": True,
        "company": company,
        "prospect_db_updated": results["prospect_db"],
        "sheets_updated": results["sheets"],
        "errors": results["errors"],
    }


def _score_stale_and_action(score, reasons, next_action, updated_at, now):
    if next_action:
        score += 2
        if "action" not in " ".join(reasons):
            reasons.append("Action planifiee")

    days_since = (now - updated_at).days if updated_at else None
    if days_since is not None:
        if days_since > 90:
            score += 3
            reasons.append(f"Pas de suivi depuis {days_since}j")
        elif days_since > 30:
            score += 1
            reasons.append(f"Pas de suivi depuis {days_since}j")

    return score, days_since


def _format_suggestion(row: TaskSuggestion) -> dict:
    return {
        "id": row.id,
        "ref": row.ref,
        "source": row.source,
        "prospect_id": row.entity_id if row.source == "prospect" else None,
        "company": row.company,
        "contact_name": row.contact_name,
        "status": row.status,
        "nda_signed": row.nda_signed,
        "criteria": row.criteria,
        "next_action": row.next_action,
        "notes": row.notes,
        "notes_preview": row.notes_preview,
        "score": row.score,
        "reason": row.reason,
        "task": row.task,
        "ai_generated": row.ai_generated,
        "last_update": row.last_update.isoformat() if row.last_update else None,
        "created_at": row.created_at.isoformat() if row.created_at else None,
    }


def _load_persisted_suggestions(db: Session, week: date):
    rows = db.query(TaskSuggestion).filter(TaskSuggestion.week_start == week).all()
    # Sort: most recently generated batch first, then by score within same batch
    def sort_key(x):
        return (x["created_at"] or "", x["score"])
    prospects = sorted(
        [_format_suggestion(r) for r in rows if r.source == "prospect"],
        key=sort_key, reverse=True,
    )
    investors = sorted(
        [_format_suggestion(r) for r in rows if r.source == "investor"],
        key=sort_key, reverse=True,
    )
    return prospects, investors


def _compute_and_persist_suggestions(db: Session, week: date):
    """Calcule les suggestions deterministes + IA et persiste en base uniquement
    les nouvelles (refs absentes de la semaine). Les anciennes sont conservees.
    Renvoie (prospects, investors) tries par created_at DESC puis score DESC.
    """
    from models.investor import Investor
    now = datetime.utcnow()

    # Prospects already tasked this week
    existing_prospect_ids = {
        t[0] for t in db.query(WeeklyTask.prospect_id).filter(
            WeeklyTask.week_start == week,
            WeeklyTask.prospect_id.isnot(None),
        ).all()
    }
    # Investisseurs already tasked this week (pas de FK dediee, on matche sur le nom)
    existing_investor_companies = {
        t[0] for t in db.query(WeeklyTask.related_company).filter(
            WeeklyTask.week_start == week,
            WeeklyTask.prospect_id.is_(None),
            WeeklyTask.related_company.isnot(None),
        ).all()
    }

    prospect_suggestions = []
    investor_suggestions = []

    # --- Prospects ---
    prospect_status_map = {
        "in_discussion": 3, "meeting_scheduled": 3,
        "nda_signed": 2, "contacted": 1, "to_contact": 0,
    }
    for p in db.query(Prospect).order_by(Prospect.updated_at.desc()).all():
        if p.id in existing_prospect_ids:
            continue
        raw_status = p.status.value if hasattr(p.status, 'value') else p.status
        if raw_status in ("closed", "rejected"):
            continue

        score = 0
        reasons = []
        if p.nda_signed == "Oui" and p.next_action:
            score += 4
            reasons.append("NDA signe + action en attente")

        s = prospect_status_map.get(raw_status, 0)
        if s:
            score += s
            reasons.append(f"Statut: {raw_status.replace('_', ' ')}")

        score, days_since = _score_stale_and_action(score, reasons, p.next_action, p.updated_at, now)
        if p.notes:
            score += 0.5

        prospect_suggestions.append({
            "source": "prospect",
            "entity_id": p.id,
            "ref": f"prospect:{p.id}",
            "prospect_id": p.id,
            "company": p.company,
            "contact_name": p.contact_name,
            "status": raw_status,
            "nda_signed": p.nda_signed,
            "criteria": None,
            "next_action": p.next_action,
            "notes": p.notes,
            "notes_preview": (p.notes or "")[:150],
            "score": round(score, 1),
            "reason": " · ".join(reasons) if reasons else "A suivre",
            "task": None,
            "ai_generated": False,
            "last_update": p.updated_at,
            "days_since": days_since,
        })

    # --- Investisseurs ---
    investor_status_map = {"in_discussion": 3, "active": 2, "contacted": 1, "to_contact": 0}
    for inv in db.query(Investor).order_by(Investor.updated_at.desc()).all():
        if inv.company in existing_investor_companies:
            continue
        raw_status = inv.status.value if hasattr(inv.status, 'value') else inv.status
        if raw_status == "inactive":
            continue

        score = 0
        reasons = []
        s = investor_status_map.get(raw_status, 0)
        if s:
            score += s
            reasons.append(f"Statut: {raw_status.replace('_', ' ')}")

        score, days_since = _score_stale_and_action(score, reasons, inv.next_action, inv.updated_at, now)
        if inv.notes:
            score += 0.5

        investor_suggestions.append({
            "source": "investor",
            "entity_id": inv.id,
            "ref": f"investor:{inv.id}",
            "prospect_id": None,
            "company": inv.company,
            "contact_name": inv.contact_name,
            "status": raw_status,
            "nda_signed": None,
            "criteria": inv.criteria,
            "next_action": inv.next_action,
            "notes": inv.notes,
            "notes_preview": (inv.notes or "")[:150],
            "score": round(score, 1),
            "reason": " · ".join(reasons) if reasons else "A suivre",
            "task": None,
            "ai_generated": False,
            "last_update": inv.updated_at,
            "days_since": days_since,
        })

    # Sort by deterministic score descending
    prospect_suggestions.sort(key=lambda x: x["score"], reverse=True)
    investor_suggestions.sort(key=lambda x: x["score"], reverse=True)

    # Pre-filtrage: on reserve des places aux deux types pour que les investisseurs
    # (scores generalement plus bas car next_action est rarement rempli) soient
    # quand meme analyses par l'IA, plutot que d'etre noyes par les prospects.
    candidates = prospect_suggestions[:AI_CANDIDATE_CAP_PROSPECTS] + investor_suggestions[:AI_CANDIDATE_CAP_INVESTORS]
    ai_results = _analyze_prospects_with_ai([
        {
            "ref": s["ref"],
            "source": s["source"],
            "type_label": "investisseur" if s["source"] == "investor" else "prospect",
            "company": s["company"],
            "contact_name": s["contact_name"],
            "status": s["status"],
            "nda_signed": s["nda_signed"],
            "criteria": s["criteria"],
            "next_action": s["next_action"],
            "notes": s["notes"],
            "days_since": s["days_since"],
        }
        for s in candidates
    ])

    for s in prospect_suggestions + investor_suggestions:
        s.pop("days_since", None)
        ai = ai_results.get(s["ref"])
        if ai:
            s["task"] = ai.get("task")
            s["reason"] = ai.get("reason") or s["reason"]
            s["ai_generated"] = True
            s["score"] = round(s["score"] + URGENCY_BOOST.get(ai.get("urgency"), 0), 1)

    # Re-tri final (score deterministe + boost d'urgence IA)
    prospect_suggestions.sort(key=lambda x: x["score"], reverse=True)
    investor_suggestions.sort(key=lambda x: x["score"], reverse=True)

    # On ne persiste que ce qui sera reellement affiche (top 20 prospects + top 15 investisseurs)
    to_persist = prospect_suggestions[:20] + investor_suggestions[:15]

    # Garder les anciennes suggestions — n'insérer que les nouvelles refs
    existing_refs = {
        r.ref for r in db.query(TaskSuggestion.ref).filter(TaskSuggestion.week_start == week).all()
    }
    for s in to_persist:
        if s["ref"] in existing_refs:
            continue
        db.add(TaskSuggestion(
            week_start=week,
            source=s["source"],
            entity_id=s["entity_id"],
            ref=s["ref"],
            company=s["company"],
            contact_name=s["contact_name"],
            status=s["status"],
            nda_signed=s["nda_signed"],
            criteria=s["criteria"],
            next_action=s["next_action"],
            notes=s["notes"],
            notes_preview=s["notes_preview"],
            score=s["score"],
            reason=s["reason"],
            task=s["task"],
            ai_generated=s["ai_generated"],
            last_update=s["last_update"],
        ))
    db.commit()

    return _load_persisted_suggestions(db, week)


@router.get("/suggestions")
def get_task_suggestions(db: Session = Depends(get_db)):
    """Renvoie les suggestions persistees pour la semaine en cours. Si aucune
    n'existe encore (premiere visite de la semaine), les calcule et les persiste.
    """
    week = get_current_week()
    prospects, investors = _load_persisted_suggestions(db, week)
    if not prospects and not investors:
        prospects, investors = _compute_and_persist_suggestions(db, week)

    return {
        "week_start": week.isoformat(),
        "total_prospects": len(prospects),
        "total_investors": len(investors),
        "prospects": prospects,
        "investors": investors,
    }


@router.post("/suggestions/regenerate")
def regenerate_task_suggestions(db: Session = Depends(get_db)):
    """Force le recalcul des suggestions pour la semaine en cours (ecrase les
    suggestions existantes non validees pour cette semaine)."""
    week = get_current_week()
    prospects, investors = _compute_and_persist_suggestions(db, week)
    return {
        "week_start": week.isoformat(),
        "total_prospects": len(prospects),
        "total_investors": len(investors),
        "prospects": prospects,
        "investors": investors,
    }


@router.delete("/suggestions/{suggestion_id}")
def dismiss_task_suggestion(suggestion_id: int, db: Session = Depends(get_db)):
    """Supprime une suggestion (l'utilisateur l'ignore, sans creer de tache)."""
    row = db.query(TaskSuggestion).filter(TaskSuggestion.id == suggestion_id).first()
    if not row:
        raise HTTPException(404, "Suggestion non trouvée")
    db.delete(row)
    db.commit()
    return {"deleted": True}


@router.get("/current-week")
def current_week_tasks(db: Session = Depends(get_db)):
    week = get_current_week()
    tasks = db.query(WeeklyTask).filter(
        WeeklyTask.week_start == week
    ).order_by(WeeklyTask.created_at.asc()).all()

    a_faire = [t for t in tasks if t.status == "a_faire"]
    en_cours = [t for t in tasks if t.status == "en_cours"]
    fait = [t for t in tasks if t.status == "fait"]

    return {
        "week_start": week.isoformat(),
        "total": len(tasks),
        "fait": len(fait),
        "en_cours": len(en_cours),
        "a_faire": len(a_faire),
        "tasks": [
            {
                "id": t.id,
                "title": t.title,
                "description": t.description,
                "category": t.category,
                "related_company": t.related_company,
                "prospect_id": t.prospect_id,
                "outcome": t.outcome,
                "priority": t.priority,
                "assignee": t.assignee,
                "status": t.status,
                "done": t.done,
                "created_at": t.created_at.isoformat() if t.created_at else None,
            }
            for t in tasks
        ],
    }


@router.get("/all-weeks")
def all_weeks_tasks(db: Session = Depends(get_db)):
    """Retourne toutes les tâches non faites de toutes les semaines."""
    tasks = db.query(WeeklyTask).filter(
        WeeklyTask.status != "fait"
    ).order_by(WeeklyTask.week_start.desc(), WeeklyTask.created_at.asc()).all()

    return {
        "total": len(tasks),
        "fait": 0,
        "en_cours": len([t for t in tasks if t.status == "en_cours"]),
        "a_faire": len([t for t in tasks if t.status == "a_faire"]),
        "tasks": [
            {
                "id": t.id,
                "title": t.title,
                "description": t.description,
                "category": t.category,
                "related_company": t.related_company,
                "prospect_id": t.prospect_id,
                "outcome": t.outcome,
                "priority": t.priority,
                "assignee": t.assignee,
                "status": t.status,
                "done": t.done,
                "week_start": t.week_start.isoformat() if t.week_start else None,
                "created_at": t.created_at.isoformat() if t.created_at else None,
            }
            for t in tasks
        ],
    }
