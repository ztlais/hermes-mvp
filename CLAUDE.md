# Hermes MVP — Contexte projet

## Utilisateur
**Zein Tlais** — EIR (Entrepreneur in Residence) chez Enechange, secteur énergies renouvelables.
Communication en **français**.

## Projet
Dashboard CRM pour gérer le deal flow EnR (énergies renouvelables).

- **Frontend** : React (Vite), port 3000 — `/root/hermes-mvp/frontend/`
- **Backend** : FastAPI, port 8000 — `/root/hermes-mvp/backend/`
- **Base de données** : PostgreSQL
- **Démarrage** : `bash /root/hermes-mvp/start.sh`

## Modules
| Module | Description |
|--------|-------------|
| Prospects | Développeurs / IPP / acheteurs à contacter |
| Investisseurs | Fonds, family offices, corporates |
| Scouting | Prospection cold outreach |
| Matching | Matching prospects ↔ investisseurs |
| Learning | Base de connaissances |
| Templates | Modèles d'emails |

## Pipeline prospects
`to_contact → contacted → in_discussion → meeting_scheduled → nda_signed → deal_in_progress → closed`

## Notes importantes
- Les statuts investisseurs : `to_contact, contacted, in_discussion, active, inactive`
- Les types prospects : `developer, investor, ipp, family_office, other`
- API docs disponibles sur http://localhost:8000/docs
