#!/bin/bash
echo "🚀 Démarrage Hermes MVP..."

# Nettoyage des instances précédentes (évite l'accumulation de process orphelins)
kill $(lsof -t -i:3000) 2>/dev/null
kill $(lsof -t -i:8000) 2>/dev/null

# PostgreSQL
service postgresql start 2>/dev/null
echo "✅ PostgreSQL démarré"

# Backend FastAPI
cd /root/hermes-mvp/backend
/usr/local/lib/hermes-agent/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --reload &
echo "✅ Backend FastAPI démarré sur :8000"

# Frontend React
cd /root/hermes-mvp/frontend
npm run dev &
echo "✅ Frontend React démarré sur :3000"

echo ""
echo "📍 Dashboard → http://localhost:3000"
echo "📍 API docs  → http://localhost:8000/docs"
echo ""
echo "Pour arrêter : kill \$(lsof -t -i:3000) \$(lsof -t -i:8000)"
