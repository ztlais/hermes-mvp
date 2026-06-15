from fastapi import APIRouter
from datetime import datetime
import json
import os

router = APIRouter(prefix="/calendar", tags=["calendar"])

CACHE_FILE = os.path.join(os.path.dirname(__file__), "..", "calendar_cache.json")


@router.get("/events")
def get_calendar_events(limit: int = 10):
    try:
        with open(CACHE_FILE, "r") as f:
            data = json.load(f)
        now = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
        future = [e for e in data.get("events", []) if e["start"] >= now]
        return {"events": future[:limit], "last_synced": data.get("last_synced")}
    except FileNotFoundError:
        return {"events": [], "last_synced": None}
