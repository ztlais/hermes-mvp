#!/usr/bin/env python3
"""
Hermes Telegram Bot
Commandes: /prospects /investors /matching /hebdo /ajouter_prospect /ajouter_investor /note_prospect /note_investor
"""

import requests
import json
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, ContextTypes, ConversationHandler, MessageHandler, filters

TOKEN = "8655263243:AAGki72yPJbui8yBzeXuorRURMli_1Qvd-I"
API_BASE = "http://localhost:8000"
USERNAME = "zein"
PASSWORD = "Virus291214"

# Conversation states
(ASK_PROSPECT_NAME, ASK_PROSPECT_COUNTRY, ASK_PROSPECT_STATUS,
 ASK_INVESTOR_NAME, ASK_INVESTOR_COUNTRY, ASK_INVESTOR_TYPE,
 ASK_NOTE_PROSPECT_ID, ASK_NOTE_PROSPECT_TEXT,
 ASK_NOTE_INVESTOR_ID, ASK_NOTE_INVESTOR_TEXT) = range(10)

auth_token = None

def get_auth_token():
    global auth_token
    try:
        resp = requests.post(f"{API_BASE}/auth/login",
                           json={"username": USERNAME, "password": PASSWORD},
                           timeout=5)
        if resp.status_code == 200:
            auth_token = resp.json().get("token")
            return True
    except:
        pass
    return False

def api_get(path):
    global auth_token
    if not auth_token:
        get_auth_token()
    headers = {"Authorization": f"Bearer {auth_token}"} if auth_token else {}
    try:
        resp = requests.get(f"{API_BASE}{path}", headers=headers, timeout=10)
        if resp.status_code == 401:
            get_auth_token()
            headers = {"Authorization": f"Bearer {auth_token}"}
            resp = requests.get(f"{API_BASE}{path}", headers=headers, timeout=10)
        if resp.status_code == 200:
            return resp.json()
    except:
        pass
    return None

def api_post(path, data):
    global auth_token
    if not auth_token:
        get_auth_token()
    headers = {"Authorization": f"Bearer {auth_token}", "Content-Type": "application/json"} if auth_token else {}
    try:
        resp = requests.post(f"{API_BASE}{path}", json=data, headers=headers, timeout=10)
        if resp.status_code == 401:
            get_auth_token()
            headers = {"Authorization": f"Bearer {auth_token}", "Content-Type": "application/json"}
            resp = requests.post(f"{API_BASE}{path}", json=data, headers=headers, timeout=10)
        return resp
    except:
        pass
    return None

def api_patch(path, data):
    global auth_token
    if not auth_token:
        get_auth_token()
    headers = {"Authorization": f"Bearer {auth_token}", "Content-Type": "application/json"} if auth_token else {}
    try:
        resp = requests.patch(f"{API_BASE}{path}", json=data, headers=headers, timeout=10)
        return resp
    except:
        pass
    return None

# ── /start ──
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    keyboard = [
        [InlineKeyboardButton("🏢 Prospects", callback_data="prospects"),
         InlineKeyboardButton("💰 Investors", callback_data="investors")],
        [InlineKeyboardButton("🔗 Matching", callback_data="matching"),
         InlineKeyboardButton("📊 Hebdo", callback_data="hebdo")],
        [InlineKeyboardButton("➕ Prospect", callback_data="ajouter_prospect"),
         InlineKeyboardButton("➕ Investor", callback_data="ajouter_investor")],
    ]
    await update.message.reply_text(
        "🌿 *Hermes Dashboard*\nQue veux-tu faire ?",
        reply_markup=InlineKeyboardMarkup(keyboard),
        parse_mode="Markdown"
    )

# ── /prospects ──
async def prospects(update: Update, context: ContextTypes.DEFAULT_TYPE):
    get_auth_token()
    data = api_get("/prospects/?limit=10")
    if not data:
        await update.message.reply_text("❌ API non disponible")
        return
    items = data if isinstance(data, list) else data.get("items", data.get("prospects", []))
    if not items:
        await update.message.reply_text("Aucun prospect.")
        return
    lines = [f"🏢 *Prospects* ({len(items)})\n"]
    for p in items[:10]:
        nom = p.get("company_name") or p.get("contact_name") or "?"
        pays = p.get("country", "")
        statut = p.get("status", "")
        pid = p.get("id", "")
        lines.append(f"• [{pid}] *{nom}* {pays} — {statut}")
    await update.message.reply_text("\n".join(lines), parse_mode="Markdown")

# ── /investors ──
async def investors(update: Update, context: ContextTypes.DEFAULT_TYPE):
    get_auth_token()
    data = api_get("/investors/?limit=10")
    if not data:
        await update.message.reply_text("❌ API non disponible")
        return
    items = data if isinstance(data, list) else data.get("items", data.get("investors", []))
    if not items:
        await update.message.reply_text("Aucun investor.")
        return
    lines = [f"💰 *Investors* ({len(items)})\n"]
    for i in items[:10]:
        nom = i.get("company_name") or i.get("name") or "?"
        pays = i.get("country", "")
        itype = i.get("investor_type", "")
        iid = i.get("id", "")
        lines.append(f"• [{iid}] *{nom}* {pays} — {itype}")
    await update.message.reply_text("\n".join(lines), parse_mode="Markdown")

# ── /matching ──
async def matching(update: Update, context: ContextTypes.DEFAULT_TYPE):
    get_auth_token()
    data = api_get("/matching/")
    if not data:
        await update.message.reply_text("❌ API non disponible")
        return
    items = data if isinstance(data, list) else data.get("items", data.get("matches", []))
    if not items:
        await update.message.reply_text("Aucun matching.")
        return
    lines = [f"🔗 *Matching* ({len(items)})\n"]
    for m in items[:10]:
        dev = m.get("developer_name") or m.get("prospect_name") or "?"
        inv = m.get("investor_name") or "?"
        score = m.get("score") or m.get("match_score") or ""
        score_str = f" — {score}%" if score else ""
        lines.append(f"• {dev} ↔ {inv}{score_str}")
    await update.message.reply_text("\n".join(lines), parse_mode="Markdown")

# ── /hebdo ──
async def hebdo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    get_auth_token()
    p_stats = api_get("/prospects/stats/summary")
    i_stats = api_get("/investors/stats/summary")
    m_data = api_get("/matching/")
    lines = ["📊 *Rapport Hebdomadaire Hermes*\n"]
    if p_stats:
        total_p = p_stats.get("total", p_stats.get("count", "?"))
        lines.append(f"🏢 Prospects: *{total_p}*")
        for k, v in p_stats.get("by_status", {}).items():
            lines.append(f"  - {k}: {v}")
    if i_stats:
        total_i = i_stats.get("total", i_stats.get("count", "?"))
        lines.append(f"\n💰 Investors: *{total_i}*")
    if m_data:
        items = m_data if isinstance(m_data, list) else m_data.get("items", [])
        lines.append(f"\n🔗 Matchings: *{len(items)}*")
    lines.append("\n✅ http://84.46.244.245:3000")
    await update.message.reply_text("\n".join(lines), parse_mode="Markdown")

# ── Ajouter Prospect ──
async def ajouter_prospect_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("🏢 Nom de la société / contact ?")
    return ASK_PROSPECT_NAME

async def prospect_name(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["prospect_name"] = update.message.text
    await update.message.reply_text("🌍 Pays ? (ex: France, Germany...)")
    return ASK_PROSPECT_COUNTRY

async def prospect_country(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["prospect_country"] = update.message.text
    await update.message.reply_text("📋 Statut ? (ex: lead, contacted, qualified, negotiation)")
    return ASK_PROSPECT_STATUS

async def prospect_status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["prospect_status"] = update.message.text
    data = {
        "company_name": context.user_data["prospect_name"],
        "country": context.user_data["prospect_country"],
        "status": context.user_data["prospect_status"],
    }
    resp = api_post("/prospects/", data)
    if resp and resp.status_code in [200, 201]:
        await update.message.reply_text(f"✅ Prospect *{data['company_name']}* ajouté !", parse_mode="Markdown")
    else:
        code = resp.status_code if resp else "?"
        await update.message.reply_text(f"❌ Erreur {code}")
    return ConversationHandler.END

# ── Ajouter Investor ──
async def ajouter_investor_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("💰 Nom de l'investor ?")
    return ASK_INVESTOR_NAME

async def investor_name(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["investor_name"] = update.message.text
    await update.message.reply_text("🌍 Pays ?")
    return ASK_INVESTOR_COUNTRY

async def investor_country(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["investor_country"] = update.message.text
    await update.message.reply_text("📋 Type ? (ex: VC, PE, Family Office, Bank...)")
    return ASK_INVESTOR_TYPE

async def investor_type(update: Update, context: ContextTypes.DEFAULT_TYPE):
    data = {
        "company_name": context.user_data["investor_name"],
        "country": context.user_data["investor_country"],
        "investor_type": update.message.text,
    }
    resp = api_post("/investors/", data)
    if resp and resp.status_code in [200, 201]:
        await update.message.reply_text(f"✅ Investor *{data['company_name']}* ajouté !", parse_mode="Markdown")
    else:
        code = resp.status_code if resp else "?"
        await update.message.reply_text(f"❌ Erreur {code}")
    return ConversationHandler.END

# ── Note Prospect ──
async def note_prospect_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("🏢 ID du prospect ? (utilise /prospects pour voir les IDs)")
    return ASK_NOTE_PROSPECT_ID

async def note_prospect_id(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["note_prospect_id"] = update.message.text.strip()
    await update.message.reply_text("📝 Ta note ?")
    return ASK_NOTE_PROSPECT_TEXT

async def note_prospect_text(update: Update, context: ContextTypes.DEFAULT_TYPE):
    pid = context.user_data["note_prospect_id"]
    note = update.message.text
    resp = api_patch(f"/prospects/{pid}", {"notes": note})
    if resp and resp.status_code in [200, 201]:
        await update.message.reply_text("✅ Note ajoutée !")
    else:
        code = resp.status_code if resp else "?"
        await update.message.reply_text(f"❌ Erreur {code}")
    return ConversationHandler.END

# ── Note Investor ──
async def note_investor_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("💰 ID de l'investor ? (utilise /investors pour voir les IDs)")
    return ASK_NOTE_INVESTOR_ID

async def note_investor_id(update: Update, context: ContextTypes.DEFAULT_TYPE):
    context.user_data["note_investor_id"] = update.message.text.strip()
    await update.message.reply_text("📝 Ta note ?")
    return ASK_NOTE_INVESTOR_TEXT

async def note_investor_text(update: Update, context: ContextTypes.DEFAULT_TYPE):
    iid = context.user_data["note_investor_id"]
    note = update.message.text
    resp = api_patch(f"/investors/{iid}", {"notes": note})
    if resp and resp.status_code in [200, 201]:
        await update.message.reply_text("✅ Note ajoutée !")
    else:
        code = resp.status_code if resp else "?"
        await update.message.reply_text(f"❌ Erreur {code}")
    return ConversationHandler.END

async def cancel(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("❌ Annulé.")
    return ConversationHandler.END

# ── Boutons inline ──
async def button_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()

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
    elif query.data == "ajouter_prospect":
        await query.message.reply_text("Tape /ajouter_prospect pour ajouter un prospect.")
    elif query.data == "ajouter_investor":
        await query.message.reply_text("Tape /ajouter_investor pour ajouter un investor.")

def main():
    get_auth_token()
    app = Application.builder().token(TOKEN).build()

    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("prospects", prospects))
    app.add_handler(CommandHandler("investors", investors))
    app.add_handler(CommandHandler("matching", matching))
    app.add_handler(CommandHandler("hebdo", hebdo))
    app.add_handler(CallbackQueryHandler(button_callback))

    app.add_handler(ConversationHandler(
        entry_points=[CommandHandler("ajouter_prospect", ajouter_prospect_start)],
        states={
            ASK_PROSPECT_NAME: [MessageHandler(filters.TEXT & ~filters.COMMAND, prospect_name)],
            ASK_PROSPECT_COUNTRY: [MessageHandler(filters.TEXT & ~filters.COMMAND, prospect_country)],
            ASK_PROSPECT_STATUS: [MessageHandler(filters.TEXT & ~filters.COMMAND, prospect_status)],
        },
        fallbacks=[CommandHandler("cancel", cancel)],
    ))

    app.add_handler(ConversationHandler(
        entry_points=[CommandHandler("ajouter_investor", ajouter_investor_start)],
        states={
            ASK_INVESTOR_NAME: [MessageHandler(filters.TEXT & ~filters.COMMAND, investor_name)],
            ASK_INVESTOR_COUNTRY: [MessageHandler(filters.TEXT & ~filters.COMMAND, investor_country)],
            ASK_INVESTOR_TYPE: [MessageHandler(filters.TEXT & ~filters.COMMAND, investor_type)],
        },
        fallbacks=[CommandHandler("cancel", cancel)],
    ))

    app.add_handler(ConversationHandler(
        entry_points=[CommandHandler("note_prospect", note_prospect_start)],
        states={
            ASK_NOTE_PROSPECT_ID: [MessageHandler(filters.TEXT & ~filters.COMMAND, note_prospect_id)],
            ASK_NOTE_PROSPECT_TEXT: [MessageHandler(filters.TEXT & ~filters.COMMAND, note_prospect_text)],
        },
        fallbacks=[CommandHandler("cancel", cancel)],
    ))

    app.add_handler(ConversationHandler(
        entry_points=[CommandHandler("note_investor", note_investor_start)],
        states={
            ASK_NOTE_INVESTOR_ID: [MessageHandler(filters.TEXT & ~filters.COMMAND, note_investor_id)],
            ASK_NOTE_INVESTOR_TEXT: [MessageHandler(filters.TEXT & ~filters.COMMAND, note_investor_text)],
        },
        fallbacks=[CommandHandler("cancel", cancel)],
    ))

    print("🤖 Hermes Bot démarré...")
    app.run_polling()

if __name__ == "__main__":
    main()
