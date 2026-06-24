from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from sqlalchemy import or_
from datetime import datetime
from typing import Optional

from database import get_db
from models.prospect import Prospect
from models.opportunity import Opportunity, OpportunityType
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

    # 2b. Matching opportunities (from general pool, based on prospect's needs)
    matching_opps = []
    if prospect and prospect.notes:
        notes_lower = prospect.notes.lower()
        words = set(notes_lower.split())

        # Detect prospect intent from notes
        wants_acquisition = any(w in notes_lower for w in ['acquisition', 'acquerir', 'achat', 'racheter', 'cession', 'acquérir'])
        wants_financement = any(w in notes_lower for w in ['financement', 'investir', 'investissement', 'levée', 'fonds', 'equity'])
        wants_development = any(w in notes_lower for w in ['développement', 'development', 'développer'])

        # Filter opportunities by type and keywords
        opp_query = db.query(Opportunity)
        opp_filters = []

        # Match by intent
        if wants_acquisition:
            opp_filters.append(Opportunity.type == OpportunityType.cession)
        elif wants_financement:
            opp_filters.append(Opportunity.type.in_([OpportunityType.financement, OpportunityType.levee]))

        # Match by country
        if prospect.country and prospect.country.lower() != 'n/a':
            opp_filters.append(Opportunity.country.ilike(f"%{prospect.country}%"))

        # Keyword match in title
        tech_keywords = ['solaire', 'pv', 'solar', 'photovoltaique', 'c&i', 'toiture',
                         'rooftop', 'sol', 'rtb', 'cod', 'bess', 'stockage', 'eolien',
                         'wind', 'agrivoltaique', 'agripv', 'portefeuille', 'portefolio']
        keyword_match = [Opportunity.title.ilike(f"%{k}%") for k in tech_keywords if k in notes_lower]

        if opp_filters or keyword_match:
            for f in opp_filters:
                opp_query = opp_query.filter(f)
            if keyword_match:
                opp_query = opp_query.filter(or_(*keyword_match))
        else:
            # Fallback: broad keyword search (exclude common words)
            stop_words = {'pour', 'dans', 'avec', 'sur', 'cette', 'nous', 'vous', 'leur', 'qui',
                          'que', 'pas', 'sont', 'peut', 'être', 'fait', 'faire', 'bien', 'tres',
                          'merci', 'bonjour', 'cordiales', 'cordialement', 'acquisition', 'projets',
                          'contact', 'developpement', 'monsieur', 'madame', 'madame'}
            sig_words = [w.strip('.,;:!?()[]{}""''')
                         for w in words if len(w) > 3 and w not in stop_words]
            if sig_words:
                kw_filters = []
                for w in sig_words[:10]:
                    kw_filters.append(Opportunity.title.ilike(f"%{w}%"))
                    kw_filters.append(Opportunity.notes.ilike(f"%{w}%"))
                opp_query = opp_query.filter(or_(*kw_filters))

        matching_opps = opp_query.order_by(Opportunity.deadline.asc().nullslast()).limit(5).all()

        # If still no match, show latest diverse opportunities
        if not matching_opps:
            matching_opps = db.query(Opportunity).limit(3).all()

    result["matching_opportunities"] = [
        {
            "id": o.id,
            "title": o.title,
            "type": o.type.value if o.type else None,
            "size_eur": o.size_eur,
            "size_mw": o.size_mw,
            "status": o.status.value if o.status else None,
            "deadline": o.deadline.isoformat()[:10] if o.deadline else None,
            "country": o.country,
            "notes": o.notes,
        }
        for o in matching_opps
    ]

    # 2c. Matching projects from BDD
    matching_projects = []
    if prospect and prospect.notes:
        from models.project import Project, ProjectStage
        notes_lower = prospect.notes.lower()

        # Detect what the prospect is looking for
        wants_solar = any(w in notes_lower for w in ['solaire', 'pv', 'photovolta', 'solar', 'sol'])
        wants_wind = any(w in notes_lower for w in ['eolien', 'éolien', 'wind'])
        wants_agripv = any(w in notes_lower for w in ['agri', 'agricole', 'agriculture'])

        # Base query: all projects in France (most common context)
        q = db.query(Project)

        # Filter by technology
        tech_filters = []
        if wants_solar:
            tech_filters.append(Project.technology == 'solar')
        if wants_wind:
            tech_filters.append(Project.technology == 'wind')
        if tech_filters:
            q = q.filter(or_(*tech_filters))
        else:
            # Default: show solar (most common)
            q = q.filter(Project.technology == 'solar')

        # Stage: if they mention development keywords, show development + permitting
        if any(w in notes_lower for w in ['developpement', 'development', 'cours']):
            q = q.filter(Project.stage.in_(['development', 'permitting']))
        if any(w in notes_lower for w in ['rtb', 'construction']):
            q = q.filter(Project.stage.in_(['ready_to_build', 'construction']))

        # Get all matching projects sorted by capacity desc
        matching_projects = q.order_by(
            Project.capacity_mw.desc().nullslast()
        ).limit(20).all()

        # If solar with no specific filter, get ALL solar to show variety
        if wants_solar and not matching_projects:
            matching_projects = db.query(Project).filter(
                Project.technology == 'solar'
            ).order_by(Project.capacity_mw.desc().nullslast()).limit(15).all()

        # Fallback: top 5 projects
        if not matching_projects:
            matching_projects = db.query(Project).order_by(
                Project.capacity_mw.desc().nullslast()
            ).limit(5).all()

    result["matching_projects"] = [
        {
            "id": p.id,
            "name": p.name,
            "developer": p.developer_name,
            "technology": p.technology.value if p.technology else None,
            "technology_detail": p.technology_detail or (p.technology.value if p.technology else None),
            "stage": p.stage.value if p.stage else None,
            "capacity_mw": p.capacity_mw,
            "country": p.country,
            "region": p.region,
            "department": p.department,
            "rtb_date": p.rtb_date,
            "cod_date": p.cod_date,
            "description": p.description[:300] if p.description else None,
        }
        for p in matching_projects
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

    # ── Questions ciblées match ──
    # Objectif : tout savoir sur les projets pour matcher avec une partie prenante
    questions = []

    # ── CHECKLIST RAPIDE ──
    # Petites questions factuelles à cocher vite avec le client
    checklist = []

    p_type = p.get("type", "") if p else ""
    p_status = p.get("status", "") if p else ""

    if p_type in ("developer", "ipp") or (not inv and not p_type):
        checklist.append({"label": "Type de projet", "options": ["Solaire sol", "Toiture", "AgriPV", "Éolien", "BESS standalone", "BESS couplé", "Mixte"], "value": ""})
        checklist.append({"label": "Avec ou sans BESS ?", "options": ["Avec BESS", "Sans BESS", "Optionnel"], "value": ""})
        checklist.append({"label": "Capacité par projet (MW)", "options": None, "value": ""})
        checklist.append({"label": "Pipeline total recherché (MW)", "options": None, "value": ""})
        checklist.append({"label": "Nombre de projets visé", "options": None, "value": ""})
        checklist.append({"label": "Stade cible", "options": ["Greenfield", "Développement", "Permis", "RTB", "Construction", "Exploitation"], "value": ""})
        checklist.append({"label": "Zone géographique", "options": ["France Nord", "France Sud", "France Est", "France Ouest", "France entière", "Europe", "Afrique"], "value": ""})
        checklist.append({"label": "Régions / départements précis", "options": None, "value": ""})
        checklist.append({"label": "Raccordement - ID RTE", "options": ["Oui", "Non", "En cours", "N/A"], "value": ""})
        checklist.append({"label": "Foncier", "options": ["Sécurisé", "Option signée", "En recherche", "N/A"], "value": ""})
        checklist.append({"label": "Permis", "options": ["Obtenus", "Déposés", "À déposer", "N/A"], "value": ""})
        checklist.append({"label": "Type de deal souhaité", "options": ["Acquisition", "Co-invest", "JV", "Sell-down", "Co-développement"], "value": ""})
        checklist.append({"label": "Budget / Ticket par MW (€/MW)", "options": None, "value": ""})
        checklist.append({"label": "Timeline pour finaliser", "options": ["3 mois", "6 mois", "1 an", "+1 an"], "value": ""})
        checklist.append({"label": "NDA", "options": ["Signé", "En cours", "À faire"], "value": ""})
    elif p_type == "investor" or inv:
        checklist.append({"label": "Techno cible", "options": ["Solaire sol", "Toiture", "AgriPV", "Éolien", "BESS standalone", "BESS couplé", "Mixte"], "value": ""})
        checklist.append({"label": "Avec ou sans BESS ?", "options": ["Avec BESS", "Sans BESS", "Optionnel"], "value": ""})
        checklist.append({"label": "Stade cible", "options": ["Greenfield", "Développement", "Permis", "RTB", "Construction", "Exploitation"], "value": ""})
        checklist.append({"label": "Capacité min-max (MW)", "options": None, "value": ""})
        checklist.append({"label": "Ticket min-max (M€)", "options": None, "value": ""})
        checklist.append({"label": "Zones géographiques", "options": ["France Nord", "France Sud", "France Est", "France Ouest", "France entière", "Europe", "Afrique", "International"], "value": ""})
        checklist.append({"label": "Type d'investissement", "options": ["Equity", "Dette senior", "Mezzanine", "Co-invest", "Fonds"], "value": ""})
        checklist.append({"label": "TRI attendu (%)", "options": None, "value": ""})
        checklist.append({"label": "Levier dette visé (%)", "options": None, "value": ""})
        checklist.append({"label": "Horizon de détention", "options": ["5 ans", "7 ans", "10 ans", "Long terme"], "value": ""})
        checklist.append({"label": "Deals en vue actuellement ?", "options": ["Oui", "Non"], "value": ""})
        checklist.append({"label": "Timeline pour investir", "options": ["3 mois", "6 mois", "1 an"], "value": ""})
        checklist.append({"label": "NDA avec les prospects", "options": ["Signé", "En cours", "À faire"], "value": ""})
    elif p_type == "family_office":
        checklist.append({"label": "Type de projet", "options": ["Solaire sol", "Toiture", "AgriPV", "Éolien", "BESS couplé", "BESS standalone", "Mixte"], "value": ""})
        checklist.append({"label": "Avec ou sans BESS ?", "options": ["Avec BESS", "Sans BESS", "Optionnel"], "value": ""})
        checklist.append({"label": "Mandat", "options": ["Direct", "Via conseil", "Club deal"], "value": ""})
        checklist.append({"label": "Stade cible", "options": ["Exploitation (safe)", "RTB/Construction (value-add)", "Développement", "Indifférent"], "value": ""})
        checklist.append({"label": "Ticket min-max (M€)", "options": None, "value": ""})
        checklist.append({"label": "Capacité par projet (MW)", "options": None, "value": ""})
        checklist.append({"label": "Zones géographiques", "options": ["France", "Europe", "International"], "value": ""})
        checklist.append({"label": "TRI attendu (%)", "options": None, "value": ""})
        checklist.append({"label": "Horizon de détention", "options": ["5 ans", "10 ans", "Long terme"], "value": ""})
        checklist.append({"label": "Timeline pour investir", "options": ["3 mois", "6 mois", "1 an", "+1 an"], "value": ""})
    else:
        checklist.append({"label": "Type de projet", "options": ["Solaire sol", "Toiture", "AgriPV", "Éolien", "BESS", "Mixte"], "value": ""})
        checklist.append({"label": "Capacité (MW)", "options": None, "value": ""})
        checklist.append({"label": "Stade", "options": ["Greenfield", "Développement", "Permis", "RTB", "Construction", "Exploitation"], "value": ""})
        checklist.append({"label": "Zone géographique", "options": ["France", "Europe", "Afrique", "Autre"], "value": ""})
        checklist.append({"label": "Type de deal", "options": ["Acquisition", "Co-invest", "JV", "Sell-down"], "value": ""})
        checklist.append({"label": "Timeline", "options": ["3 mois", "6 mois", "1 an", "+1 an"], "value": ""})

    prep["checklist"] = checklist

    # ── 1. PIPELINE (vision d'ensemble) ──
    if p and p_status in ("to_contact", "contacted"):
        questions.append("Quel est votre pipeline total en MW aujourd'hui ? (par techno : sol, éolien, BESS, agriPV ?)")
        questions.append("Quels sont les stades de vos projets — greenfield, développement, RTB, construction ?")
        questions.append("Combien de MW avez-vous à chaque stade ?")
    else:
        questions.append("Où en est votre pipeline aujourd'hui ? Des entrées/sorties depuis notre dernier échange ?")
        questions.append("Quels sont les MW dispo pour un partenariat immédiatement ?")

    # ── 2. GÉOGRAPHIE & RACCORDEMENT ──
    questions.append("Dans quelles régions / départements sont vos projets ?")
    questions.append("Quel est le statut raccordement ? Avez-vous déjà des identifiants RTE ou des réservations de capacité ?")
    if not inv:
        questions.append("Y a-t-il des projets avec un raccordement déjà sécurisé ? (c'est un critère clé pour les investisseurs)")

    # ── 3. STRUCTURE FINANCIÈRE & BESOIN ──
    questions.append("Quelle est la structure visée pour chaque projet ? (full equity, co-invest, JV, sell-down ?)")
    questions.append("Quel est le ticket moyen par projet / par partenariat ? (en M€)")
    if not inv:
        questions.append("Quel type de partenaire cherchez-vous ? (investisseur financier, industriel, co-développeur, off-taker ?)")
    questions.append("Quels sont vos objectifs de rendement / TRI cible sur ces projets ?")

    # ── 4. TIMELINE ──
    questions.append("À quelle échéance voulez-vous signer un premier deal / trouver un partenaire ? (3 mois, 6 mois, 1 an ?)")
    questions.append("Quels sont les jalons clés à venir sur vos projets les plus avancés ? (COD visé, obtention permis, etc.)")

    # ── 5. DEAL SPÉCIFIQUE ──
    if opps:
        questions.append("Parlons du deal en cours — quel est le statut exact ? Des blocages ? Des évolutions depuis la dernière fois ?")
        for o in opps:
            if o.get("deadline"):
                questions.append(f"La deadline du {o['deadline'][:10]} est-elle toujours tenable ?")
                break

    # ── 6. NDA (si applicable) ──
    if p and p.get("nda_signed") == "Non" and p.get("status") not in ("to_contact", "contacted"):
        questions.append("Où en est le NDA ? On avance ou on attend ?")

    # ── 7. INVESTISSEUR (questions miroir) ──
    if inv:
        questions.append("Quels sont vos critères exacts d'investissement actuels ? (techno, stade, ticket, zone)")
        questions.append("Quel niveau de rendement attendez-vous ? Quel levier de dette ?")
        questions.append("Avez-vous des projets déjà identifiés qui matchent vos critères ?")

    # ── 8. CONTACT(S) ──
    questions.append("Y a-t-il d'autres personnes chez vous avec qui je devrais échanger pour avancer plus vite ?")

    prep["questions"] = questions[:12]

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
        # Retourner la prep sauvegardée, MAIS toujours générer checklist + questions fraîches
        fresh = generate_structured_prep(data)
        data["prep"] = {
            "id": existing.id,
            "context": existing.context,
            "talking_points": existing.talking_points,
            "questions": existing.questions,
            "checklist": fresh["checklist"],
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
            "checklist": prep["checklist"],
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
