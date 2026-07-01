from fastapi import APIRouter
from datetime import datetime, timedelta
import json
import os

router = APIRouter(prefix="/calendar", tags=["calendar"])

CACHE_FILE = os.path.join(os.path.dirname(__file__), "..", "calendar_cache.json")


@router.get("/events")
def get_calendar_events(limit: int = 10, scope: str = "upcoming", days: int = None):
    try:
        with open(CACHE_FILE, "r") as f:
            data = json.load(f)
        now_dt = datetime.now()
        now = now_dt.strftime("%Y-%m-%dT%H:%M:%S")
        events = data.get("events", [])
        if scope == "past":
            selected = sorted(
                [e for e in events if e["start"] < now],
                key=lambda e: e["start"], reverse=True,
            )
        else:
            upcoming = [e for e in events if e["start"] >= now]
            if days is not None:
                cutoff = (now_dt + timedelta(days=days)).strftime("%Y-%m-%dT%H:%M:%S")
                upcoming = [e for e in upcoming if e["start"] <= cutoff]
            selected = sorted(upcoming, key=lambda e: e["start"])
        return {"events": selected[:limit], "last_synced": data.get("last_synced")}
    except FileNotFoundError:
        return {"events": [], "last_synced": None}
