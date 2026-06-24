"""Add weekly tasks for prospects + investors"""
from database import SessionLocal
from sqlalchemy import text
from datetime import datetime, timedelta
import pytz

now = datetime.now(pytz.timezone('Europe/Paris'))
monday = now - timedelta(days=now.weekday())
monday = monday.replace(hour=0, minute=0, second=0, microsecond=0)
ws = monday.date()

db = SessionLocal()

# Tâches à ajouter: (title, category, priority, assignee, prospect_id, related_company, description)
tasks = [
    # 🔴 HAUTE PRIORITÉ - NDA signés à relancer
    ('Relancer Valeco — retour Zakaria & Cyril', 'prospect', 'haute', 'Zein', 1, 'Valeco',
     'NDA signé. Attente retour Zakaria Cherrak et Cyril depuis longtemps.'),
    ('Envoyer projets JC Mont Fort / ecodd à Chint Solar', 'prospect', 'haute', 'Zein', 2, 'JC Mont Fort / ecodd',
     'NDA signé. Patrick Delbos attend. Contacter Fathia Taghozi (Chint Solar) avec les projets.'),
    ('Relancer Stephane Gilli — teasers promis', 'prospect', 'haute', 'Zein', 8, 'Stephane Gilli (ex primosolar)',
     'NDA signé. Doit envoyer ses teasers projets. Relancer.'),
    ('Relancer Novabridge — retour portefeuille Sunrock', 'prospect', 'haute', 'Zein', 9, 'Novabridge',
     'NDA signé. Erwan Bibollet doit revenir avec étude Sunrock portefeuille.'),
    ('Relancer Viridi RE Group — follow up enrocks', 'prospect', 'haute', 'Mariella', 7, 'Viridi RE Group',
     'NDA signé. Marion Bourdais-Massenet. Suivre le dossier enrocks.'),
    ('Relancer Enertrag — 3e tentative ou abandon', 'prospect', 'haute', 'Zein', 17, 'Enertrag',
     'NDA signé. Antoine Pouille. 2 relances 19/05 sans réponse. Décider si on insiste ou on met en pause.'),

    # 🟡 MOYENNE PRIORITÉ - En discussion
    ('Relancer WPD — follow up', 'prospect', 'moyenne', 'Zein', 5, 'WPD',
     'En discussion. EWA Koziolek (project finance). Relancer.'),
    ('Relancer Altarea — retour Thibaut sur projets envoyés', 'prospect', 'moyenne', 'Mariella', 18, 'Altarea',
     'En discussion. Projets envoyés mars 2026 à Thibaut, toujours en attente retour.'),
    ('Relancer Recurrent Energy (Theo Baudry-Sherry)', 'prospect', 'moyenne', 'Zein', 15, 'Recurrent Energy',
     'En discussion. Relancer Theo ou essayer Guillaume Auneau.'),
    ('Suivre Notus Energie — relancé 19/05', 'prospect', 'moyenne', 'Zein', 12, 'Notus Energie',
     'En discussion. Robin Savoye. Relancé 19/05, attente réponse.'),
    ('Vérifier statut NDA Seawind (Sascha Lindemann)', 'prospect', 'moyenne', 'Mariella', 69, 'Seawind',
     'En discussion. Sascha devait reprendre échanges. Vérifier si NDA signé.'),
    ('H2Air — follow up avec Joe', 'prospect', 'moyenne', 'Zein', 27, 'H2Air',
     'En discussion. Ziad Halwani. Follow up avec Joe.'),

    # 🟢 BASSE PRIORITÉ - Contactés/À contacter
    ('Qair — follow up Guirec Dufour LinkedIn', 'prospect', 'basse', 'Zein', 4, 'Qair',
     'Contacté. Alexandra Agredo / Guirec Dufour. Follow up LinkedIn.'),
    ('H2Watt — tenter email Elise Marcellan', 'prospect', 'basse', 'Mariella', 26, 'H2Watt',
     'Contacté. Haig Ghawzalian. Tenter email Elise Marcellan, sinon LinkedIn.'),
    ('Valorem (Jérôme Espinet) — toitures & ombrières', 'prospect', 'basse', 'Zein', 14, 'Valorem',
     'À contacter. Jérôme Espinet (Toiture & Ombrière Commercial). Premier contact.'),

    # INVESTISSEURS
    ('CATL / BESS Broadway — briefs Pologne+Finlande + NDA EIR', 'action', 'moyenne', 'Mariella', None, 'CATL / BESS Broadway',
     'Antonio Sanchez. Mariella envoie briefs Pologne + Finlande. Envoyer NDA EIR.'),
    ('Chint Solar (Fathia Taghozi) — envoyer projets ecodd', 'action', 'moyenne', 'Zein', None, 'Chint Solar',
     'Investisseur actif. Envoyer projets JC Mont Fort / ecodd.'),
    ('Enrocks — projets disponibles pour co-développement', 'action', 'basse', 'Zein', None, 'Enrocks',
     'Investisseur actif. Voir quels projets disponibles pour co-développement PV.'),
]

# Check existing tasks to avoid exact duplicates
existing = set()
rows = db.execute(text('SELECT title FROM weekly_tasks WHERE week_start = :ws'), {'ws': ws}).fetchall()
for r in rows:
    existing.add(r[0].strip().lower())

count = 0
for t in tasks:
    title_lower = t[0].strip().lower()
    if title_lower in existing:
        print(f'  ⏭️  Déjà existant: {t[0]}')
        continue
    db.execute(text('''
        INSERT INTO weekly_tasks (title, category, priority, assignee, prospect_id, related_company, description, week_start, status, done)
        VALUES (:title, :category, :priority, :assignee, :prospect_id, :related_company, :description, :week_start, 'a_faire', false)
    '''), {
        'title': t[0],
        'category': t[1],
        'priority': t[2],
        'assignee': t[3],
        'prospect_id': t[4],
        'related_company': t[5],
        'description': t[6],
        'week_start': ws,
    })
    count += 1
    print(f'  ✅ Ajouté: {t[0]}')

db.commit()

# Verify
print(f'\n=== RÉSULTAT: {count} nouvelles tâches sur {len(tasks)} proposées ===')
rows2 = db.execute(text("""
    SELECT id, title, priority, assignee, prospect_id, related_company
    FROM weekly_tasks
    WHERE week_start = :ws
    ORDER BY CASE priority
        WHEN 'haute' THEN 1
        WHEN 'moyenne' THEN 2
        WHEN 'basse' THEN 3
    END, id
"""), {'ws': ws}).fetchall()
for r in rows2:
    p_str = f"p_id={r[4]}" if r[4] else ""
    print(f'  [{r[0]:2d}] [{r[2]:8s}] {r[1]:50s} | {r[3]:10s} {p_str} | {r[5]}')
print(f'Total: {len(rows2)} tâches cette semaine')

db.close()
