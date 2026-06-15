"""Import projets depuis bdd_cache.json → PostgreSQL"""
import sys, json
sys.path.insert(0, '/root/hermes-mvp/backend')

from sqlalchemy.orm import Session
from database import engine, init_db
from models.project import Project, ProjectTechnology, ProjectStage


def map_technology(raw: str) -> ProjectTechnology:
    r = raw.lower()
    if any(k in r for k in ['éolien', 'eolien', 'wind']):
        return ProjectTechnology.wind
    if any(k in r for k in ['solaire', 'solar', 'pv']):
        return ProjectTechnology.solar
    if any(k in r for k in ['bess', 'stockage', 'batterie']):
        return ProjectTechnology.bess
    if any(k in r for k in ['hydro', 'hydraulique']):
        return ProjectTechnology.hydro
    if any(k in r for k in ['biomasse', 'biogas']):
        return ProjectTechnology.biomass
    return ProjectTechnology.other


def map_stage(raw: str) -> ProjectStage:
    r = raw.lower()
    if any(k in r for k in ['rtb', 'ready to build', '(7)', 'prêt à construire']):
        return ProjectStage.ready_to_build
    if any(k in r for k in ['construction', '(8)']):
        return ProjectStage.construction
    if any(k in r for k in ['opération', 'operatio', 'cod', '(9)', 'mise en service']):
        return ProjectStage.operational
    if any(k in r for k in ['raccordement', '(5)', '(6)', 'autorisation', 'permis', 'administratif']):
        return ProjectStage.permitting
    return ProjectStage.development


def safe_float(val):
    try:
        return float(str(val).replace(',', '.').strip())
    except:
        return None


def main():
    init_db()
    with open('/root/hermes-dashboard/bdd_cache.json') as f:
        cache = json.load(f)

    count = 0
    with Session(engine) as db:
        for tab_name, content in cache.items():
            rows = content['data']
            headers = rows[0]
            real_rows = [r for r in rows[2:] if len(r) > 2 and r[0] and r[2] and r[2] not in ['Nom du projet', '']]

            for row in real_rows:
                def g(i): return row[i].strip() if i < len(row) and row[i] else ''

                name = g(2)
                if not name:
                    continue

                existing = db.query(Project).filter(Project.name == name).first()
                if existing:
                    continue

                tech_raw = g(4)
                stage_raw = g(3)
                mw_raw = g(12)
                region = g(11) or g(10)
                developer_raw = g(1)

                description_parts = []
                if g(3): description_parts.append(f"Stade: {g(3)[:200]}")
                if g(5): description_parts.append(f"Typologie: {g(5)}")
                if g(6): description_parts.append(f"RTB estimée: {g(6)}")
                if g(7): description_parts.append(f"COD estimée: {g(7)[:100]}")
                if developer_raw: description_parts.append(f"Actionnariat: {developer_raw}")

                p = Project(
                    name=name,
                    technology=map_technology(tech_raw) if tech_raw else ProjectTechnology.solar,
                    stage=map_stage(stage_raw) if stage_raw else ProjectStage.development,
                    capacity_mw=safe_float(mw_raw),
                    country='FR',
                    region=region or None,
                    description='\n'.join(description_parts) or None,
                    nda_signed='Non',
                )
                db.add(p)
                count += 1

        db.commit()

    print(f"✅ {count} projets importés dans PostgreSQL")


if __name__ == '__main__':
    main()
