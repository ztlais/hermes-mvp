from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware

from database import init_db
from routers import prospects, investors, matching, scouting, learning, templates, calendar, documents, simulateur, projects, opportunities, prep
from routers import auth as auth_router
from auth import get_current_user

app = FastAPI(title="Hermes MVP API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Public routes (no auth)
app.include_router(auth_router.router)

# Protected routes
protected = {"dependencies": [Depends(get_current_user)]}
app.include_router(prospects.router, **protected)
app.include_router(investors.router, **protected)
app.include_router(matching.router, **protected)
app.include_router(scouting.router, **protected)
app.include_router(learning.router, **protected)
app.include_router(templates.router, **protected)
app.include_router(calendar.router, **protected)
app.include_router(documents.router, **protected)
app.include_router(simulateur.router, **protected)
app.include_router(projects.router, **protected)
app.include_router(opportunities.router, **protected)
app.include_router(prep.router, **protected)


@app.on_event("startup")
def startup():
    init_db()


@app.get("/")
def root():
    return {"status": "ok", "app": "Hermes MVP API"}


@app.get("/health")
def health():
    return {"status": "healthy"}
