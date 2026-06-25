#!/usr/bin/env python3
"""
Hermes Telegram Bot
Commandes: /prospects /investors /matching /hebdo
"""

import requests
import json
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, ContextTypes

TOKEN = "8655263243:AAGki72yPJbui8yBzeXuorRURMli_1Qvd-I"
API_BASE = "http://localhost:8000"

# Auth token (on le récupère au démarrage)
auth_token = None

def get_auth_token():
    """Login pour obtenir le token JWT"""
    global auth_token
    try:
        resp = requests.post(f"{API_BASE}/auth/login", 
                           json={"username": "admin", "password": "admin"},
                           timeout=5)
        if resp.status_code == 200:
            auth_token = resp.json().get("access_token")
    except:
        auth_token = None

def api_get(path):
    """Appel API avec auth"""
    headers = {}
    if auth_token:
        headers["Authorization"] = f"Bearer {auth_token}"
    try:
        resp = requests.get(f"{API_BASE}{path}", headers=headers, timeout=10)
        if resp.status_code == 200:
            return resp.json()
    except Exception as e:
        return None
    return None

def format_prospect(p):
    nom = p.get("company_name") or p.get("contact_name") or "?"
    pays = p.get("country", "")
    statut = p.get("status", "")
    return f"• *{nom}* {pays} — {statut}"

def format_investor(i):
    nom = i.get("company_name") or i.get("name") or "?"
    type_ = i.get("investor_type", "")
    pays = i.get("country", "")
    return f"• *{nom}* {pays} — {type_}"

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    keyboard = [
        [InlineKeyboardButton("🏢 Prospects", callback_data="prospects"),
         InlineKeyboardButton("💰 Investors", callback_data="investors")],
        [InlineKeyboardButton("🔗 Matching", callback_data="matching"),
         InlineKeyboardButton("📊 Hebdo", callback_data="hebdo")],
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text(
        "🌿 *Hermes Dashboard*\nQue veux-tu consulter ?",
        reply_markup=reply_markup,
        parse_mode="Markdown"
    )

async def prospects(update: Update, context: ContextTypes.DEFAULT_TYPE):
    get_auth_token()
    data = api_get("/prospects/?limit=10")
    if not data:
        await update.message.reply_text("❌ API non disponible")
        return
    
    items = data if isinstance(data, list) else data.get("items", data.get("prospects", []))
    total = len(items)
    
    if total == 0:
        await update.message.reply_text("Aucun prospect trouvé.")
        return
    
    lines = [f"🏢 *Prospects* ({total} derniers)\n"]
    for p in items[:10]:
        lines.append(format_prospect(p))
    
    await update.message.reply_text("\n".join(lines), parse_mode="Markdown")

async def investors(update: Update, context: ContextTypes.DEFAULT_TYPE):
    get_auth_token()
    data = api_get("/investors/?limit=10")
    if not data:
        await update.message.reply_text("❌ API non disponible")
        return
    
    items = data if isinstance(data, list) else data.get("items", data.get("investors", []))
    total = len(items)
    
    if total == 0:
        await update.message.reply_text("Aucun investor trouvé.")
        return
    
    lines = [f"💰 *Investors* ({total} derniers)\n"]
    for i in items[:10]:
        lines.append(format_investor(i))
    
    await update.message.reply_text("\n".join(lines), parse_mode="Markdown")

async def matching(update: Update, context: ContextTypes.DEFAULT_TYPE):
    get_auth_token()
    data = api_get("/matching/")
    if not data:
        await update.message.reply_text("❌ API non disponible")
        return
    
    items = data if isinstance(data, list) else data.get("items", data.get("matches", []))
    total = len(items)
    
    if total == 0:
        await update.message.reply_text("Aucun matching trouvé.")
        return
    
    lines = [f"🔗 *Matching* ({total})\n"]
    for m in items[:10]:
        dev = m.get("developer_name") or m.get("prospect_name") or "?"
        inv = m.get("investor_name") or "?"
        score = m.get("score") or m.get("match_score") or ""
        score_str = f" — Score: {score}%" if score else ""
        lines.append(f"• {dev} ↔ {inv}{score_str}")
    
    await update.message.reply_text("\n".join(lines), parse_mode="Markdown")

async def hebdo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    get_auth_token()
    
    # Stats prospects
    p_stats = api_get("/prospects/stats/summary")
    i_stats = api_get("/investors/stats/summary")
    m_data = api_get("/matching/")
    
    lines = ["📊 *Rapport Hebdomadaire Hermes*\n"]
    
    if p_stats:
        total_p = p_stats.get("total", p_stats.get("count", "?"))
        lines.append(f"🏢 Prospects: *{total_p}*")
        by_status = p_stats.get("by_status", {})
        for k, v in by_status.items():
            lines.append(f"  - {k}: {v}")
    
    if i_stats:
        total_i = i_stats.get("total", i_stats.get("count", "?"))
        lines.append(f"\n💰 Investors: *{total_i}*")
    
    if m_data:
        items = m_data if isinstance(m_data, list) else m_data.get("items", [])
        lines.append(f"\n🔗 Matchings actifs: *{len(items)}*")
    
    lines.append("\n✅ Dashboard: http://84.46.244.245:3000")
    
    await update.message.reply_text("\n".join(lines), parse_mode="Markdown")

async def button_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()
    
    # Créer un faux update pour réutiliser les handlers
    class FakeMsg:
        async def reply_text(self, *args, **kwargs):
            await query.message.reply_text(*args, **kwargs)
    
    class FakeUpdate:
        message = FakeMsg()
    
    fake = FakeUpdate()
    
    if query.data == "prospects":
        await prospects(fake, context)
    elif query.data == "investors":
        await investors(fake, context)
    elif query.data == "matching":
        await matching(fake, context)
    elif query.data == "hebdo":
        await hebdo(fake, context)

def main():
    get_auth_token()
    app = Application.builder().token(TOKEN).build()
    
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("prospects", prospects))
    app.add_handler(CommandHandler("investors", investors))
    app.add_handler(CommandHandler("matching", matching))
    app.add_handler(CommandHandler("hebdo", hebdo))
    app.add_handler(CallbackQueryHandler(button_callback))
    
    print("🤖 Hermes Bot démarré...")
    app.run_polling()

if __name__ == "__main__":
    main()
