from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from sqlalchemy import or_
from datetime import datetime
from typing import Optional

from database import get_db
from models.prospect import Prospect
from models.opportunity import Opportunity
from models.investor import Investor
from models.scouting import Scouting
from models.meeting_prep import MeetingPrep

router = APIRouter(prefix="/prep", tags=["prep"])


# ─── Company data aggregation ─────────────────────────────────────────────────


def find_company(company: str, db: Session):
    """Cherche une entreprise dans toutes les tables CRM et retourne les infos agrégées"""
    result = {
        "company": company,
        "prospect": None,
        "opportunities": [],
        "investor": None,
        "scouting": [],
        "matched": False,
    }

    # Nettoyer le nom : enlever les préfixes courants (Call, Follow up, etc.)
    # et la partie personne après "–" ou "—"
    clean = company.strip()
    for sep in [" – ", " — ", " - ", " –", " —"]:
        if sep in clean:
            clean = clean.split(sep)[0].strip()
    prefixes = [
        "call ", "appel ", "rdv ", "meeting with ", "follow up with ",
        "follow-up with ", "follow up ", "follow-up ",
        "in-person @ ", "in person @ ", "meet ", "interview ",
    ]
    clean_lower = clean.lower()
    for p in prefixes:
        if clean_lower.startswith(p):
            clean = clean[len(p):].strip()
            break
    queries = [company, clean] if clean != company else [company]
    # Fallback : tenter chaque mot significatif
    words = clean.split()
    stop_words = {'call', 'appel', 'rdv', 'follow', 'up', 'with', 'meeting', 'meet',
                  'in', 'person', 'interview', 'the', 'pour', 'sur', 'chez', 'et',
                  'de', 'du', 'des', 'au', 'aux', 'en', 'le', 'la', 'les', 'un', 'une',
                  'weekly', 'monthly', 'daily', 'updates', 'internal', 'discussion',
                  'lectures', 'review', 'synced', 'syncing'}
    for w in words:
        if len(w) >= 4 and w.lower() not in stop_words and w[0].isupper():
            queries.append(w)

    # 1. Prospect
    prospect = None
    for q in queries:
        prospect = db.query(Prospect).filter(
            or_(
                Prospect.company.ilike(f"%{q}%"),
                Prospect.contact_name.ilike(f"%{q}%"),
            )
        ).first()
        if prospect:
            break

    if prospect:
        result["prospect"] = {
            "id": prospect.id,
            "company": prospect.company,
            "contact": prospect.contact_name,
            "phone": prospect.phone,
            "email": prospect.email,
            "type": prospect.type.value if prospect.type else None,
            "status": prospect.status.value if prospect.status else None,
            "country": prospect.country,
            "nda_signed": prospect.nda_signed,
            "teaser": prospect.teaser,
            "notes": prospect.notes,
            "next_action": prospect.next_action,
            "source": prospect.source,
        }
        result["matched"] = True

        # 2. Opportunities liées
        opps = db.query(Opportunity).filter(
            Opportunity.prospect_id == prospect.id
        ).order_by(Opportunity.deadline.asc()).all()

        result["opportunities"] = [
            {
                "id": o.id,
                "title": o.title,
                "type": o.type.value if o.type else None,
                "size_eur": o.size_eur,
                "size_mw": o.size_mw,
                "status": o.status.value if o.status else None,
                "deadline": o.deadline.isoformat() if o.deadline else None,
                "country": o.country,
                "notes": o.notes,
            }
            for o in opps
        ]

    # 3. Investor
    investor = None
    for q in queries:
        investor = db.query(Investor).filter(
            Investor.company.ilike(f"%{q}%")
        ).first()
        if investor:
            break

    if investor:
        result["investor"] = {
            "id": investor.id,
            "company": investor.company,
            "type": investor.type,
            "contact": investor.contact_name,
            "status": investor.status,
            "technologies": investor.technologies,
            "countries": investor.countries,
            "stages": investor.deal_stages,
            "deal_types": investor.deal_types,
            "ticket_min": investor.min_ticket,
            "ticket_max": investor.max_ticket,
            "criteria": investor.criteria,
            "notes": investor.notes,
        }
        result["matched"] = True

    # 4. Scouting
    scouts = []
    for q in queries:
        scouts = db.query(Scouting).filter(
            Scouting.company.ilike(f"%{q}%")
        ).order_by(Scouting.created_at.desc()).limit(5).all()
        if scouts:
            break

    if scouts:
        result["scouting"] = [
            {
                "id": s.id,
                "contact": s.contact_name,
                "company": s.company,
                "type": s.type.value if s.type else None,
                "country": s.country,
                "status": s.status.value if s.status else None,
                "notes": s.notes,
            }
            for s in scouts
        ]
        result["matched"] = True

    return result


# ─── Enhanced prep generation ─────────────────────────────────────────────────


def generate_structured_prep(data: dict) -> dict:
    """Génère une préparation structurée complète"""
    prep = {
        "company_summary": "",
        "deal_summary": "",
        "status_overview": "",
        "talking_points": [],
        "questions": [],
        "next_steps": [],
        "risks": [],
        "opportunities": [],
    }

    p = data.get("prospect")
    opps = data.get("opportunities", [])
    inv = data.get("investor")
    scouts = data.get("scouting", [])

    # ── Company summary ──
    parts = []
    if p:
        parts.append(f"Type: {p['type'] or 'N/A'}")
        parts.append(f"Pays: {p['country'] or 'N/A'}")
        parts.append(f"NDA: {p['nda_signed'] or 'Non'}")
        parts.append(f"Source: {p['source'] or 'N/A'}")
    if inv:
        parts.append(f"Investisseur: {inv['company']} ({inv['type'] or 'N/A'})")
    if scouts:
        s_types = ", ".join(set(s["type"] for s in scouts if s.get("type")))
        if s_types:
            parts.append(f"Scouting: {s_types}")
    prep["company_summary"] = " • ".join(parts)

    # ── Deal summary ──
    deal_lines = []
    for o in opps:
        size_parts = []
        if o.get("size_eur"):
            size_parts.append(f"{o['size_eur']}M€")
        if o.get("size_mw"):
            size_parts.append(f"{o['size_mw']} MW")
        size_str = f" ({' | '.join(size_parts)})" if size_parts else ""
        deadline = f" — Deadline: {o['deadline'][:10]}" if o.get("deadline") else ""
        deal_lines.append(f"• {o['title']}{size_str} — {o['status']}{deadline}")
    prep["deal_summary"] = "\n".join(deal_lines) if deal_lines else "Aucun deal en cours"

    # ── Status overview ──
    status_parts = []
    if p:
        status_parts.append(f"Pipeline: {p['status']}")
        if p.get("next_action"):
            status_parts.append(f"Next: {p['next_action']}")
    if inv:
        status_parts.append(f"Investor status: {inv['status']}")
    if scouts:
        active_scouts = [s for s in scouts if s["status"] not in ("no_response", "not_interested")]
        if active_scouts:
            status_parts.append(f"Scouting actif: {len(active_scouts)} entrée(s)")
    prep["status_overview"] = " | ".join(status_parts) if status_parts else ""

    # ── Talking points ──
    talking_points = []

    # From prospect notes
    if p and p.get("notes"):
        # Split notes into logical sections, clean up
        notes_text = p["notes"].strip()
        # Extract structured sections (lines starting with emoji or bullet)
        sections = []
        current_section = []
        for line in notes_text.split("\n"):
            line = line.strip()
            if not line:
                continue
            # Check if this starts a new section (emoji, bold marker, etc.)
            if any(line.startswith(e) for e in ["🏢", "📞", "🎯", "📋", "💼", "💰", "🔥", "✅", "❌", "📈", "📍"]):
                if current_section:
                    sections.append("\n".join(current_section))
                current_section = [line]
            else:
                current_section.append(line)
        if current_section:
            sections.append("\n".join(current_section))

        if sections:
            for s in sections:
                if len(s) > 5:
                    talking_points.append(s)
        else:
            # Plain text - take key lines
            for line in notes_text.split("\n")[:8]:
                line = line.strip()
                if line and len(line) > 10:
                    talking_points.append(line)

    # From opportunities
    for o in opps:
        if o.get("notes"):
            key_info = o["notes"].strip().split("\n")[0]
            if key_info and len(key_info) > 10:
                talking_points.append(f"[Deal] {key_info[:200]}")

    # From investor
    if inv:
        if inv.get("notes"):
            for line in inv["notes"].strip().split("\n")[:3]:
                line = line.strip()
                if line and len(line) > 10:
                    talking_points.append(f"[Investisseur] {line[:200]}")
        if inv.get("criteria"):
            talking_points.append(f"[Critères] {inv['criteria'][:200]}")

    # Deduplicate
    seen = set()
    unique_pts = []
    for pt in talking_points:
        key = pt[:50].lower()
        if key not in seen:
            seen.add(key)
            unique_pts.append(pt)

    prep["talking_points"] = unique_pts[:12]  # Max 12 points

    # ── Questions ──
    questions = []

    # Contextual questions based on status
    if p:
        status = p.get("status", "")
        if status == "to_contact":
            questions.append("Présentation de l'entreprise : quels sont vos projets en développement ?")
            questions.append("Quel type de financement recherchez-vous ?")
        elif status == "contacted":
            questions.append("Avez-vous eu le temps d'échanger en interne suite à notre dernier contact ?")
            questions.append("Quels sont vos critères pour un éventuel partenariat ?")
        elif status == "in_discussion":
            questions.append("Où en êtes-vous dans votre réflexion ? Y a-t-il des avancées depuis notre dernier échange ?")
            questions.append("Quels sont les points bloquants ou les incertitudes actuelles ?")
        elif status == "meeting_scheduled":
            questions.append("Quelles sont vos attentes pour cette réunion ?")
            questions.append("Avez-vous des documents ou informations à partager en amont ?")
        elif status == "nda_signed":
            questions.append("Où en est le processus NDA ? Des contreparties nécessaires ?")
            questions.append("Quels sont les prochains jalons après le NDA ?")
        elif status == "deal_in_progress":
            questions.append("Quel est le statut actuel du deal ? Des blocages ?")
            questions.append("Quels sont les prochaines étapes et le timing visé ?")
        else:
            questions.append("Comment avance le projet ?")
            questions.append("Quels sont les prochains jalons ?")

    # Deal-specific questions
    if opps:
        questions.append("Y a-t-il des évolutions sur le deal en cours ?")
        for o in opps:
            if o.get("deadline"):
                questions.append(f"Le deadline du {o['deadline'][:10]} est-il toujours tenable ?")
                break

    # NDA questions
    if p and p.get("nda_signed") == "Non" and p.get("status") not in ("to_contact", "contacted"):
        questions.append("Où en est-on du NDA ? Souhaitons-nous avancer dessus ?")

    # Investor-specific
    if inv:
        questions.append("Quels sont les critères exacts d'investissement actuels ?")
        questions.append("Y a-t-il des secteurs ou zones géographiques prioritaires ?")

    prep["questions"] = questions[:8]

    # ── Next steps ──
    next_steps = []
    if p and p.get("next_action"):
        for line in p["next_action"].split("\n"):
            line = line.strip()
            if line and len(line) > 3:
                next_steps.append(line)

    if opps:
        for o in opps:
            if o.get("deadline"):
                next_steps.append(f"Suivre deadline deal: {o['deadline'][:10]}")
                break

    next_steps.append("Définir les prochaines étapes et deadlines")
    next_steps.append("Planifier le prochain point dans 2 semaines")

    prep["next_steps"] = next_steps[:6]

    # ── Risks & Opportunities ──
    risks = []
    opportunities_list = []

    if p:
        if p.get("nda_signed") == "Non" and p.get("status") in ("in_discussion", "meeting_scheduled", "deal_in_progress"):
            risks.append("NDA pas encore signé — peut ralentir le processus")
    if opps:
        for o in opps:
            if o.get("deadline"):
                try:
                    d = datetime.fromisoformat(o["deadline"].replace("Z", ""))
                    if d < datetime.now():
                        risks.append(f"Deadline dépassée: {o['title']} ({o['deadline'][:10]})")
                except:
                    pass

    if inv and not p:
        opportunities_list.append("Investisseur identifié — checker s'il y a un prospect lié")
    if scouts:
        converted = [s for s in scouts if s["status"] == "converted"]
        if converted:
            opportunities_list.append(f"Scouting converti: {len(converted)} entrée(s)")

    prep["risks"] = risks
    prep["opportunities"] = opportunities_list

    return prep


# ─── Endpoints ────────────────────────────────────────────────────────────────


@router.get("/{company_name}")
def get_prep(company_name: str, db: Session = Depends(get_db)):
    """Retourne les données CRM + préparation structurée pour une entreprise"""
    data = find_company(company_name, db)
    if not data["matched"]:
        raise HTTPException(status_code=404, detail="Entreprise non trouvée dans le CRM")

    # Vérifier si une prep existe déjà en base
    existing = db.query(MeetingPrep).filter(
        MeetingPrep.company.ilike(f"%{company_name}%")
    ).order_by(MeetingPrep.updated_at.desc()).first()

    if existing and existing.talking_points:
        # Retourner la prep sauvegardée
        data["prep"] = {
            "id": existing.id,
            "context": existing.context,
            "talking_points": existing.talking_points,
            "questions": existing.questions,
            "next_steps": existing.next_steps,
            "personal_notes": existing.personal_notes or "",
            "status": existing.status,
            "saved": True,
        }
    else:
        # Générer une nouvelle prep
        prep = generate_structured_prep(data)
        data["prep"] = {
            "id": None,
            "context": prep["company_summary"],
            "talking_points": prep["talking_points"],
            "questions": prep["questions"],
            "next_steps": prep["next_steps"],
            "personal_notes": "",
            "status": "draft",
            "saved": False,
        }

    return data


@router.post("/{company_name}/save")
def save_prep(
    company_name: str,
    body: dict = Body(...),
    db: Session = Depends(get_db),
):
    """Sauvegarde ou met à jour une préparation"""
    # Chercher une prep existante pour cette entreprise
    existing = db.query(MeetingPrep).filter(
        MeetingPrep.company.ilike(f"%{company_name}%")
    ).order_by(MeetingPrep.updated_at.desc()).first()

    if existing:
        existing.talking_points = body.get("talking_points", existing.talking_points)
        existing.questions = body.get("questions", existing.questions)
        existing.next_steps = body.get("next_steps", existing.next_steps)
        existing.personal_notes = body.get("personal_notes", existing.personal_notes)
        existing.context = body.get("context", existing.context)
        existing.status = body.get("status", existing.status)
        existing.event_title = body.get("event_title")
        db.commit()
        db.refresh(existing)
        return {"id": existing.id, "saved": True, "msg": "Prep mise à jour"}
    else:
        # Récupérer les données CRM pour le contexte
        data = find_company(company_name, db)
        context = data.get("prospect", {})
        prep = MeetingPrep(
            company=company_name,
            event_title=body.get("event_title"),
            context=body.get("context", ""),
            talking_points=body.get("talking_points", []),
            questions=body.get("questions", []),
            next_steps=body.get("next_steps", []),
            personal_notes=body.get("personal_notes", ""),
            status=body.get("status", "draft"),
        )
        db.add(prep)
        db.commit()
        db.refresh(prep)
        return {"id": prep.id, "saved": True, "msg": "Prep créée"}


@router.delete("/{prep_id}")
def delete_prep(prep_id: int, db: Session = Depends(get_db)):
    """Supprime une préparation"""
    prep = db.query(MeetingPrep).filter(MeetingPrep.id == prep_id).first()
    if not prep:
        raise HTTPException(status_code=404, detail="Prep non trouvée")
    db.delete(prep)
    db.commit()
    return {"deleted": True}
