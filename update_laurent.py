"""Update Laurent Cligny / Electron Green with meeting notes"""
import sys
sys.path.insert(0, '/root/hermes-mvp/backend')
from database import SessionLocal
from models.prospect import Prospect
from datetime import datetime

notes = """POC: Mariella Mansour | NDA: Oui | Priorite: High

Contact: Laurent Cligny - FR country manager, Electron Green. Independant prospecteur ENR.

Reunion 11/06/2026 ✅
Participants: Zein, Mariella, Laurent

Contexte:
- Laurent a parle a plusieurs investisseurs de la liste EIR - attend leurs retours
- Frein principal: reseau francais paye moins bien -> autoconsommation individuelle/collective et PPA avec industriels privilegies
- Projets en vente totale au reseau = difficulte mais pas bloquant
- Pour ses propres projets: doit identifier des consommateurs voisins (industrie, supermarche, station epuration) pouvant prendre 80% production
- Discussion avancee sur un projet ou on lui demande de nommer un premier consommateur potentiel

Projets specifiques:
- Projets #33-42 (toitures agricoles - 5e developpeur): pas de tarif securise, pas de contact avec communes. Zein a les communes (Genouak, Creuse, Ardeche...) -> envoyer a Laurent
- Projet #20/15/13 (6e developpeur): besoin de plus d'infos
- Incoherence tableau: permis obtenu mais bail non signe -> clarifie par Mariella

Finances:
- Virement facture envoye le 04/06 - verifier reception avec equipe Japon
- Suggestion Mariella: regrouper paiements 2 mois pour reduire frais

Actions:
1. Envoyer communes des projets #33-42 a Laurent
2. Recontacter 5e developpeur pour tarif + communes
3. Plus d infos sur 6e developpeur
4. Envoyer DB EIR a jour
5. Check reception virement Laurent avec equipe Japon
6. Laurent attend retours investisseurs cette semaine"""

db = SessionLocal()
l = db.query(Prospect).filter(Prospect.id == 85).first()
l.notes = notes
l.next_action = "1. Envoyer communes projets #33-42 + DB a jour 2. Recontact 5e dev 3. Check virement Laurent"
l.last_contact = datetime(2026, 6, 11)
db.commit()
db.close()
print("OK")
