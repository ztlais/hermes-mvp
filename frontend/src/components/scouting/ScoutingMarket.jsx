import { useEffect, useState } from 'react'
import api from '../../api/client'
import { TypeBadge, Tab, TYPE_VALUES, TYPE_SHORT_LABELS, DEFAULT_TEMPLATES, personalize, parseData } from './shared'

const STATUS_VALUES = ['to_contact', 'premiere_connexion', 'deuxieme_connexion']
const STATUS_STYLES = {
  to_contact:          { color: '#374151', bg: '#f3f4f6', border: '#d1d5db' },
  premiere_connexion:  { color: '#1e40af', bg: '#eff6ff', border: '#bfdbfe' },
  deuxieme_connexion:  { color: '#5b21b6', bg: '#f5f3ff', border: '#ddd6fe' },
}
const STATUS_LABELS = {
  to_contact: 'À scout',
  premiere_connexion: 'Première connexion',
  deuxieme_connexion: 'Deuxième connexion',
}

function buildHistoryEntry(form, extra, outcome) {
  return {
    person: form.contact_name || '',
    email: form.email || '',
    linkedin: form.linkedin || '',
    date: new Date().toLocaleDateString('fr-FR'),
    outcome,
    li_1ere_sent: extra.li_1ere_sent || false,
    em_1ere_sent: extra.em_1ere_sent || false,
    li_2eme_sent: extra.li_2eme_sent || false,
    em_2eme_sent: extra.em_2eme_sent || false,
    li_1ere: extra.li_1ere || '',
    em_1ere: extra.em_1ere || '',
    li_2eme: extra.li_2eme || '',
    em_2eme: extra.em_2eme || '',
  }
}

const OUTCOME_LABELS = {
  no_response: '❌ Pas de réponse',
  wrong_person: '👤 Pas la bonne personne',
  later: '⏰ À recontacter plus tard',
  pas_interesse: '🙅 Pas intéressé',
  pas_pertinent: '🚫 Pas pertinent',
  bounced: '📭 Bounced',
}

function MarketCardModal({ item, market, onClose, onSave, onDelete }) {
  const [form, setForm] = useState({ ...item })
  const [extra, setExtra] = useState(parseData(item))
  const [templates, setTemplates] = useState([])
  const [activeChannel, setActiveChannel] = useState('linkedin')
  const [detecting, setDetecting] = useState(false)
  const [copied, setCopied] = useState(false)

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))
  const setX = (k, v) => setExtra(f => ({ ...f, [k]: v }))
  const step = form.status === 'deuxieme_connexion' ? 2 : 1

  useEffect(() => {
    api.get('/templates/', { params: { target: form.type, language: 'fr', step } })
      .then(r => setTemplates(r.data))
      .catch(() => {})
  }, [form.type, step])

  const channelPrefix = activeChannel === 'linkedin' ? 'li' : 'em'
  const currentTemplate = templates.find(tp => tp.type === activeChannel && tp.step === step)
  const defaultTpl = DEFAULT_TEMPLATES[form.type]?.[step]?.[activeChannel] || ''
  const msgKey = `${channelPrefix}_${step === 1 ? '1ere' : '2eme'}`
  const sentKey = `${msgKey}_sent`
  const msgValue = extra[msgKey] || personalize(currentTemplate?.body || defaultTpl, form)
  const [messageText, setMessageText] = useState(msgValue)

  useEffect(() => { setMessageText(msgValue) }, [activeChannel, step])

  const handleDetect = async () => {
    if (!form.company) return
    setDetecting(true)
    try {
      const r = await api.get('/scouting/detect-category', { params: { company: form.company } })
      if (r.data.detected_type) {
        set('type', r.data.detected_type)
        setX('auto_detected', true)
      } else {
        alert('Aucune correspondance trouvée — sélection manuelle requise.')
      }
    } finally { setDetecting(false) }
  }

  const handleCopy = () => {
    let text = messageText
    if (activeChannel === 'email' && currentTemplate?.subject) {
      text = `${currentTemplate.subject}\n\n${messageText}`
    }
    navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  const handleSave = async () => {
    const updatedExtra = { ...extra, [msgKey]: messageText }
    await api.put(`/scouting/${item.id}`, { ...form, data: JSON.stringify(updatedExtra) })
    onSave()
  }

  const handleDelete = async () => {
    if (!confirm(`Supprimer ${item.company} ?`)) return
    await api.delete(`/scouting/${item.id}`)
    onDelete()
  }

  const handleContacted = async () => {
    const updatedExtra = { ...extra, [msgKey]: messageText }
    await api.put(`/scouting/${item.id}`, { ...form, status: 'premiere_connexion', data: JSON.stringify(updatedExtra) })
    onSave()
  }

  const handleAcceptedConnection = async () => {
    const tpl2 = DEFAULT_TEMPLATES[form.type]?.[2]
    const updatedExtra = {
      ...extra,
      [msgKey]: messageText,
      li_2eme: extra.li_2eme || (tpl2?.linkedin ? personalize(tpl2.linkedin, form) : ''),
      em_2eme: extra.em_2eme || (tpl2?.email ? personalize(tpl2.email, form) : ''),
    }
    await api.put(`/scouting/${item.id}`, { ...form, status: 'deuxieme_connexion', data: JSON.stringify(updatedExtra) })
    onSave()
  }

  const returnToScoutList = async (outcome) => {
    const historyEntry = buildHistoryEntry(form, { ...extra, [msgKey]: messageText }, outcome)
    const history = [...(extra.history || []), historyEntry]
    await api.put(`/scouting/${item.id}`, {
      ...form, contact_name: '', email: '', linkedin: '', status: 'to_contact',
      data: JSON.stringify({
        history, later: false,
        li_1ere: '', em_1ere: '', li_2eme: '', em_2eme: '',
        li_1ere_sent: false, em_1ere_sent: false, li_2eme_sent: false, em_2eme_sent: false,
      })
    })
    onSave()
  }

  const handleLater = async () => {
    await api.put(`/scouting/${item.id}`, {
      ...form, status: 'to_contact',
      data: JSON.stringify({ ...extra, [msgKey]: messageText, later: true })
    })
    onSave()
  }

  const handlePasInteresse = async () => {
    await api.put(`/scouting/${item.id}`, {
      ...form, status: 'to_contact',
      data: JSON.stringify({ ...extra, [msgKey]: messageText, pas_interesse: true })
    })
    onSave()
  }

  const handlePasPertinent = async () => {
    await api.put(`/scouting/${item.id}`, {
      ...form, status: 'to_contact',
      data: JSON.stringify({ ...extra, [msgKey]: messageText, pas_pertinent: true })
    })
    onSave()
  }

  const handleBounced = async () => {
    const historyEntry = buildHistoryEntry(form, { ...extra, [msgKey]: messageText }, 'bounced')
    const history = [...(extra.history || []), historyEntry]
    await api.put(`/scouting/${item.id}`, {
      ...form, contact_name: '', email: '', linkedin: '', status: 'to_contact',
      data: JSON.stringify({
        history, bounced: true, later: false,
        li_1ere: '', em_1ere: '', li_2eme: '', em_2eme: '',
        li_1ere_sent: false, em_1ere_sent: false, li_2eme_sent: false, em_2eme_sent: false,
      })
    })
    onSave()
  }

  const handleInterested = async () => {
    if (!confirm(`Ajouter "${item.company}" aux Prospects et le retirer du Scouting ?`)) return
    try {
      await api.post('/prospects/', {
        company: item.company,
        contact_name: form.contact_name || '',
        email: form.email || '',
        linkedin: form.linkedin || '',
        country: market,
        type: form.type,
        status: 'contacted',
        notes: form.notes || '',
      })
      await api.delete(`/scouting/${item.id}`)
      onDelete()
    } catch { alert('Erreur lors de la conversion') }
  }

  const colStyle = STATUS_STYLES[form.status] || STATUS_STYLES.to_contact
  const inp = { width: '100%', padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13, boxSizing: 'border-box' }
  const lbl = { display: 'block', fontSize: 11, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 4, marginTop: 12 }

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100, padding: 16 }}
      onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={{ background: '#fff', borderRadius: 12, width: 560, maxHeight: '95vh', overflowY: 'auto', boxShadow: '0 25px 60px rgba(0,0,0,0.2)' }}>
        <div style={{ padding: '20px 24px 16px', borderBottom: '1px solid #f3f4f6', position: 'sticky', top: 0, background: '#fff', zIndex: 1 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <h2 style={{ fontSize: 17, fontWeight: 700, color: '#1f2937', margin: 0 }}>{item.company}</h2>
              <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginTop: 6, flexWrap: 'wrap' }}>
                <TypeBadge type={form.type} />
                <span style={{ fontSize: 11, fontWeight: 600, color: colStyle.color, background: colStyle.bg, border: `1px solid ${colStyle.border}`, padding: '1px 8px', borderRadius: 10 }}>
                  {STATUS_LABELS[form.status]}
                </span>
                {extra.later && <span style={{ fontSize: 11, fontWeight: 600, color: '#92400e', background: '#fffbeb', padding: '1px 8px', borderRadius: 10 }}>⏰ À recontacter</span>}
                {extra.pas_interesse && <span style={{ fontSize: 11, fontWeight: 600, color: '#991b1b', background: '#fef2f2', padding: '1px 8px', borderRadius: 10 }}>🙅 Pas intéressé</span>}
                {extra.pas_pertinent && <span style={{ fontSize: 11, fontWeight: 600, color: '#6b7280', background: '#f3f4f6', padding: '1px 8px', borderRadius: 10 }}>🚫 Pas pertinent</span>}
                {extra.bounced && <span style={{ fontSize: 11, fontWeight: 600, color: '#9a3412', background: '#fff7ed', padding: '1px 8px', borderRadius: 10 }}>📭 Bounced</span>}
              </div>
            </div>
            <button onClick={onClose} style={{ background: 'none', border: 'none', fontSize: 20, cursor: 'pointer', color: '#9ca3af' }}>✕</button>
          </div>
        </div>

        <div style={{ padding: '0 24px 24px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginTop: 16 }}>
            <div>
              <label style={{ ...lbl, marginTop: 0 }}>👤 Personne</label>
              <input style={inp} value={form.contact_name || ''} onChange={e => set('contact_name', e.target.value)} placeholder="Prénom Nom" />
            </div>
            <div>
              <label style={{ ...lbl, marginTop: 0 }}>📧 Email</label>
              <input style={inp} value={form.email || ''} onChange={e => set('email', e.target.value)} />
            </div>
          </div>
          <label style={lbl}>🔗 LinkedIn</label>
          <div style={{ display: 'flex', gap: 8 }}>
            <input style={{ ...inp, flex: 1 }} value={form.linkedin || ''} onChange={e => set('linkedin', e.target.value)} placeholder="https://linkedin.com/in/..." />
            {form.linkedin && (
              <a href={form.linkedin} target="_blank" rel="noreferrer" style={{ padding: '8px 12px', background: '#1d4ed8', color: '#fff', borderRadius: 6, textDecoration: 'none', fontSize: 12, fontWeight: 600, display: 'flex', alignItems: 'center' }}>in</a>
            )}
          </div>

          <label style={lbl}>Catégorie</label>
          <div style={{ display: 'flex', gap: 8 }}>
            <select style={{ ...inp, flex: 1 }} value={form.type} onChange={e => { set('type', e.target.value); setX('auto_detected', false) }}>
              {TYPE_VALUES.map(v => <option key={v} value={v}>{TYPE_SHORT_LABELS[v] || v}</option>)}
            </select>
            <button onClick={handleDetect} disabled={detecting} style={{ padding: '8px 12px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer', fontSize: 12, fontWeight: 600, whiteSpace: 'nowrap' }}>
              {detecting ? '...' : '🔍 Détecter'}
            </button>
          </div>
          {extra.auto_detected && <div style={{ fontSize: 11, color: '#059669', marginTop: 4 }}>✓ Catégorie détectée automatiquement</div>}

          <div style={{ marginTop: 16, background: '#f8fafc', borderRadius: 10, border: '1px solid #e5e7eb', padding: 16 }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 10 }}>
              💬 Messages — {STATUS_LABELS[form.status]}
            </div>
            <div style={{ display: 'flex', gap: 6, marginBottom: 12 }}>
              <Tab label="LinkedIn" active={activeChannel === 'linkedin'} onClick={() => setActiveChannel('linkedin')} />
              <Tab label="Email" active={activeChannel === 'email'} onClick={() => setActiveChannel('email')} />
            </div>

            <textarea
              value={messageText}
              onChange={e => setMessageText(e.target.value)}
              style={{
                width: '100%', boxSizing: 'border-box',
                padding: '10px 12px', border: '1px solid #d1d5db',
                borderRadius: 6, fontSize: 12, lineHeight: 1.6,
                resize: 'vertical', minHeight: step === 1 ? 110 : 180,
                fontFamily: 'inherit', background: '#fff',
              }}
            />
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 8 }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 12, cursor: 'pointer' }}>
                <input type="checkbox" checked={extra[sentKey] || false} onChange={e => setX(sentKey, e.target.checked)} />
                ✅ {activeChannel === 'linkedin' ? 'LinkedIn envoyé' : 'Email envoyé'}
              </label>
              <button onClick={handleCopy} style={{
                padding: '5px 14px', borderRadius: 5, border: 'none', cursor: 'pointer',
                fontSize: 12, fontWeight: 600,
                background: copied ? '#d1fae5' : '#1f2937',
                color: copied ? '#065f46' : '#fff',
              }}>
                {copied ? 'Copié ✓' : 'Copier'}
              </button>
            </div>
          </div>

          <label style={lbl}>📝 Notes</label>
          <textarea style={{ ...inp, height: 60, resize: 'vertical' }} value={form.notes || ''} onChange={e => set('notes', e.target.value)} />

          <div style={{ display: 'flex', gap: 8, marginTop: 16, flexWrap: 'wrap' }}>
            {form.status === 'to_contact' && (
              <button onClick={handleContacted} style={{ padding: '7px 12px', borderRadius: 6, border: 'none', background: '#1d4ed8', color: '#fff', cursor: 'pointer', fontSize: 12, fontWeight: 600 }}>
                ✉️ Contacté → Première connexion
              </button>
            )}
            {form.status === 'premiere_connexion' && (
              <button onClick={handleAcceptedConnection} style={{ padding: '7px 12px', borderRadius: 6, border: 'none', background: '#1d4ed8', color: '#fff', cursor: 'pointer', fontSize: 12, fontWeight: 600 }}>
                ✓ Connexion acceptée
              </button>
            )}
            {form.status !== 'to_contact' && (
              <>
                <button onClick={() => returnToScoutList('no_response')} style={{ padding: '7px 12px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer', fontSize: 12, fontWeight: 600 }}>
                  🔄 Remettre à zéro
                </button>
                <button onClick={() => returnToScoutList('wrong_person')} style={{ padding: '7px 12px', borderRadius: 6, border: '1px solid #fecaca', background: '#fff', cursor: 'pointer', fontSize: 12, fontWeight: 600, color: '#dc2626' }}>
                  👤 Pas la bonne personne
                </button>
                <button onClick={handleBounced} style={{ padding: '7px 12px', borderRadius: 6, border: '1px solid #fed7aa', background: '#fff', cursor: 'pointer', fontSize: 12, fontWeight: 600, color: '#9a3412' }}>
                  📭 Bounced
                </button>
              </>
            )}
            <button onClick={handleLater} style={{ padding: '7px 12px', borderRadius: 6, border: '1px solid #fde68a', background: '#fff', cursor: 'pointer', fontSize: 12, fontWeight: 600, color: '#92400e' }}>
              ⏰ À recontacter plus tard
            </button>
            <button onClick={handlePasInteresse} style={{ padding: '7px 12px', borderRadius: 6, border: '1px solid #fecaca', background: '#fff', cursor: 'pointer', fontSize: 12, fontWeight: 600, color: '#991b1b' }}>
              🙅 Pas intéressé
            </button>
            <button onClick={handlePasPertinent} style={{ padding: '7px 12px', borderRadius: 6, border: '1px solid #e5e7eb', background: '#fff', cursor: 'pointer', fontSize: 12, fontWeight: 600, color: '#6b7280' }}>
              🚫 Pas pertinent
            </button>
          </div>

          <button onClick={handleInterested} style={{
            width: '100%', marginTop: 14, padding: '10px', borderRadius: 8, border: 'none',
            background: '#059669', color: '#fff', cursor: 'pointer', fontWeight: 700, fontSize: 13,
          }}>
            🚀 Intéressé → Transférer au CRM Prospect
          </button>

          {extra.history && extra.history.length > 0 && (
            <div style={{ marginTop: 16, background: '#f9fafb', borderRadius: 8, padding: 12, border: '1px solid #e5e7eb' }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 8 }}>📜 Historique des contacts</div>
              {extra.history.slice().reverse().map((h, i) => {
                const icons = []
                if (h.li_1ere_sent) icons.push('✅ LI1')
                if (h.em_1ere_sent) icons.push('✅ EM1')
                if (h.li_2eme_sent) icons.push('✅ LI2')
                if (h.em_2eme_sent) icons.push('✅ EM2')
                return <div key={i} style={{ fontSize: 11, color: '#6b7280', padding: '4px 0', borderBottom: '1px solid #f3f4f6' }}>
                  • {h.person || '?'} ({h.date}) — {OUTCOME_LABELS[h.outcome] || h.outcome} {icons.length > 0 ? `· ${icons.join(' · ')}` : ''}
                </div>
              })}
            </div>
          )}

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 16 }}>
            <button onClick={handleDelete} style={{ padding: '7px 14px', borderRadius: 6, border: 'none', background: '#fee2e2', color: '#991b1b', cursor: 'pointer', fontSize: 12, fontWeight: 600 }}>
              🗑 Supprimer
            </button>
            <div style={{ display: 'flex', gap: 8 }}>
              <button onClick={onClose} style={{ padding: '7px 14px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer', fontSize: 12 }}>Annuler</button>
              <button onClick={handleSave} style={{ padding: '7px 18px', borderRadius: 6, border: 'none', background: '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 600, fontSize: 12 }}>
                💾 Sauvegarder
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

function MarketCard({ item, onClick }) {
  const extra = parseData(item)
  const sentIcons = []
  if (extra.li_1ere_sent) sentIcons.push('✅ LI1')
  if (extra.em_1ere_sent) sentIcons.push('✅ EM1')
  if (extra.li_2eme_sent) sentIcons.push('✅ LI2')
  if (extra.em_2eme_sent) sentIcons.push('✅ EM2')

  return (
    <div onClick={onClick} style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8, padding: 12, marginBottom: 8, cursor: 'pointer' }}
      onMouseEnter={e => e.currentTarget.style.boxShadow = '0 2px 8px rgba(0,0,0,0.08)'}
      onMouseLeave={e => e.currentTarget.style.boxShadow = 'none'}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 6 }}>
        <div style={{ fontWeight: 700, fontSize: 13, color: '#1f2937', flex: 1, paddingRight: 4, lineHeight: 1.3 }}>
          {item.company}
        </div>
        <TypeBadge type={item.type} />
      </div>
      {item.contact_name && (
        <div style={{ fontSize: 11, color: '#9ca3af', marginBottom: 2 }}>👤 {item.contact_name}</div>
      )}
      <div style={{ display: 'flex', gap: 6, marginTop: 2, flexWrap: 'wrap' }}>
        {sentIcons.map(icon => (
          <span key={icon} style={{ fontSize: 10, color: '#6b7280' }}>{icon}</span>
        ))}
        {extra.later && <span style={{ fontSize: 10, fontWeight: 600, color: '#92400e' }}>⏰ Later</span>}
        {extra.pas_interesse && <span style={{ fontSize: 10, fontWeight: 600, color: '#991b1b' }}>🙅 Pas intéressé</span>}
        {extra.pas_pertinent && <span style={{ fontSize: 10, fontWeight: 600, color: '#6b7280' }}>🚫 Pas pertinent</span>}
        {extra.bounced && <span style={{ fontSize: 10, fontWeight: 600, color: '#9a3412' }}>📭 Bounced</span>}
      </div>
      {item.notes && (
        <div style={{ fontSize: 11, color: '#6b7280', marginTop: 4, lineHeight: 1.4,
          display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
          {item.notes}
        </div>
      )}
    </div>
  )
}

function MarketAddModal({ market, marketLabel, onClose, onSave }) {
  const [form, setForm] = useState({
    company: '', contact_name: '', email: '', linkedin: '',
    type: 'developer', status: 'to_contact', country: market, notes: '',
  })
  const [detecting, setDetecting] = useState(false)
  const [autoDetected, setAutoDetected] = useState(false)
  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))
  const inp = { width: '100%', padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13, boxSizing: 'border-box' }
  const lbl = { display: 'block', fontSize: 11, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 4, marginTop: 12 }

  const handleDetectBlur = async () => {
    if (!form.company) return
    setDetecting(true)
    try {
      const r = await api.get('/scouting/detect-category', { params: { company: form.company } })
      if (r.data.detected_type) {
        set('type', r.data.detected_type)
        setAutoDetected(true)
      }
    } finally { setDetecting(false) }
  }

  const handleSave = async () => {
    if (!form.company) return alert('Le nom de l\'entreprise est requis')
    const tpl = DEFAULT_TEMPLATES[form.type]
    const extra = { auto_detected: autoDetected }
    if (tpl?.[1]?.linkedin) extra.li_1ere = personalize(tpl[1].linkedin, form)
    if (tpl?.[1]?.email) extra.em_1ere = personalize(tpl[1].email, form)
    await api.post('/scouting/', { ...form, data: JSON.stringify(extra) })
    onSave()
  }

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100, padding: 16 }}
      onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={{ background: '#fff', borderRadius: 12, padding: 24, width: 460, boxShadow: '0 25px 60px rgba(0,0,0,0.2)' }}>
        <h2 style={{ fontSize: 17, fontWeight: 700, marginBottom: 16 }}>{marketLabel} — Nouveau contact Scouting</h2>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <div>
            <label style={{ ...lbl, marginTop: 0 }}>Entreprise</label>
            <input style={inp} value={form.company} onChange={e => set('company', e.target.value)} onBlur={handleDetectBlur} autoFocus />
          </div>
          <div><label style={{ ...lbl, marginTop: 0 }}>Contact</label><input style={inp} value={form.contact_name} onChange={e => set('contact_name', e.target.value)} /></div>
          <div>
            <label style={{ ...lbl, marginTop: 0 }}>Catégorie {detecting && '(détection...)'}</label>
            <select style={inp} value={form.type} onChange={e => { set('type', e.target.value); setAutoDetected(false) }}>
              {TYPE_VALUES.map(v => <option key={v} value={v}>{TYPE_SHORT_LABELS[v] || v}</option>)}
            </select>
          </div>
        </div>
        {autoDetected && <div style={{ fontSize: 11, color: '#059669', marginTop: 4 }}>✓ Catégorie détectée automatiquement</div>}
        <label style={lbl}>LinkedIn</label>
        <input style={inp} value={form.linkedin} onChange={e => set('linkedin', e.target.value)} placeholder="https://linkedin.com/in/..." />
        <label style={lbl}>Email</label>
        <input style={inp} value={form.email} onChange={e => set('email', e.target.value)} />
        <label style={lbl}>Notes</label>
        <textarea style={{ ...inp, height: 60, resize: 'vertical' }} value={form.notes} onChange={e => set('notes', e.target.value)} />
        <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end', marginTop: 16 }}>
          <button onClick={onClose} style={{ padding: '8px 16px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer' }}>Annuler</button>
          <button onClick={handleSave} style={{ padding: '8px 18px', borderRadius: 6, border: 'none', background: '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 700 }}>Ajouter</button>
        </div>
      </div>
    </div>
  )
}

export default function ScoutingMarket({ market, marketLabel, showAdd, onCloseAdd }) {
  const [data, setData] = useState([])
  const [filterType, setFilterType] = useState('')
  const [onlyLater, setOnlyLater] = useState(false)
  const [onlyPasInteresse, setOnlyPasInteresse] = useState(false)
  const [onlyPasPertinent, setOnlyPasPertinent] = useState(false)
  const [onlyIntersolar, setOnlyIntersolar] = useState(false)
  const [search, setSearch] = useState('')
  const [selectedItem, setSelectedItem] = useState(null)
  const [loading, setLoading] = useState(true)

  const load = () => {
    setLoading(true)
    const params = { country: market }
    if (filterType) params.type = filterType
    if (onlyIntersolar) params.source = 'Stand'
    api.get('/scouting/', { params }).then(r => {
      setData(r.data || [])
      setLoading(false)
    })
  }

  useEffect(() => { load() }, [market, filterType, onlyIntersolar])

  const filtered = data.filter(d => {
    if (!STATUS_VALUES.includes(d.status)) return false
    if (search && !d.company.toLowerCase().includes(search.toLowerCase()) && !(d.contact_name || '').toLowerCase().includes(search.toLowerCase())) return false
    const extra = parseData(d)
    if (onlyLater && !extra.later) return false
    if (onlyPasInteresse && !extra.pas_interesse) return false
    if (onlyPasPertinent && !extra.pas_pertinent) return false
    return true
  })

  const byStatus = {}
  STATUS_VALUES.forEach(status => { byStatus[status] = filtered.filter(d => d.status === status) })

  const laterCount = data.filter(d => STATUS_VALUES.includes(d.status) && parseData(d).later).length
  const pasInteresseCount = data.filter(d => STATUS_VALUES.includes(d.status) && parseData(d).pas_interesse).length
  const pasPertinentCount = data.filter(d => STATUS_VALUES.includes(d.status) && parseData(d).pas_pertinent).length

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12, flexShrink: 0 }}>
        <div style={{ fontSize: 13, color: '#6b7280' }}>
          {byStatus.to_contact.length} à scout · {byStatus.premiere_connexion.length} en 1ère connexion · {byStatus.deuxieme_connexion.length} en 2ème connexion
        </div>
      </div>

      <div style={{ display: 'flex', gap: 8, marginBottom: 12, flexShrink: 0, flexWrap: 'wrap', alignItems: 'center' }}>
        <input placeholder="Rechercher..." value={search} onChange={e => setSearch(e.target.value)}
          style={{ flex: 1, minWidth: 140, padding: '7px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13 }} />
        <div style={{ display: 'flex', background: '#f3f4f6', borderRadius: 6, padding: 2 }}>
          {[{ value: '', label: 'Tous' }, ...TYPE_VALUES.map(v => ({ value: v, label: TYPE_SHORT_LABELS[v] || v }))].map(opt => (
            <button key={opt.value} onClick={() => setFilterType(opt.value)} style={{
              padding: '5px 8px', borderRadius: 4, border: 'none', cursor: 'pointer', fontSize: 12, fontWeight: 600,
              background: filterType === opt.value ? '#fff' : 'transparent',
              color: filterType === opt.value ? '#1f2937' : '#6b7280',
              boxShadow: filterType === opt.value ? '0 1px 3px rgba(0,0,0,0.1)' : 'none',
            }}>{opt.label}</button>
          ))}
        </div>
        <button onClick={() => setOnlyLater(!onlyLater)} style={{
          padding: '5px 10px', borderRadius: 6, border: '1px solid #fde68a', cursor: 'pointer', fontSize: 12, fontWeight: 600,
          background: onlyLater ? '#fffbeb' : '#fff', color: '#92400e',
        }}>
          ⏰ À recontacter plus tard ({laterCount})
        </button>
        <button onClick={() => setOnlyPasInteresse(!onlyPasInteresse)} style={{
          padding: '5px 10px', borderRadius: 6, border: '1px solid #fecaca', cursor: 'pointer', fontSize: 12, fontWeight: 600,
          background: onlyPasInteresse ? '#fef2f2' : '#fff', color: '#991b1b',
        }}>
          🙅 Pas intéressé ({pasInteresseCount})
        </button>
        <button onClick={() => setOnlyPasPertinent(!onlyPasPertinent)} style={{
          padding: '5px 10px', borderRadius: 6, border: '1px solid #e5e7eb', cursor: 'pointer', fontSize: 12, fontWeight: 600,
          background: onlyPasPertinent ? '#f3f4f6' : '#fff', color: '#6b7280',
        }}>
          🚫 Pas pertinent ({pasPertinentCount})
        </button>
        <button onClick={() => setOnlyIntersolar(!onlyIntersolar)} style={{
          padding: '5px 10px', borderRadius: 6, border: '1px solid #3b82f6', cursor: 'pointer', fontSize: 12, fontWeight: 600,
          background: onlyIntersolar ? '#eff6ff' : '#fff', color: '#1d4ed8',
        }}>
          🌍 Intersolar ({data.filter(d => d.notes && d.notes.includes('Stand')).length})
        </button>
      </div>

      {loading ? (
        <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#9ca3af' }}>Chargement...</div>
      ) : (
        <div style={{ flex: 1, overflowX: 'auto', overflowY: 'hidden' }}>
          <div style={{ display: 'flex', gap: 12, height: '100%', minWidth: 'max-content', paddingBottom: 16 }}>
            {STATUS_VALUES.map(status => {
              const colStyle = STATUS_STYLES[status]
              const cards = byStatus[status] || []
              return (
                <div key={status} style={{ width: 280, flexShrink: 0, display: 'flex', flexDirection: 'column', background: colStyle.bg, border: `1px solid ${colStyle.border}`, borderRadius: 10, overflow: 'hidden' }}>
                  <div style={{ padding: '10px 14px', borderBottom: `1px solid ${colStyle.border}`, flexShrink: 0 }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <span style={{ fontWeight: 700, fontSize: 13, color: colStyle.color }}>{STATUS_LABELS[status]}</span>
                      <span style={{ background: colStyle.border, color: colStyle.color, borderRadius: 10, padding: '1px 8px', fontSize: 12, fontWeight: 700 }}>{cards.length}</span>
                    </div>
                  </div>
                  <div style={{ flex: 1, overflowY: 'auto', padding: 10 }}>
                    {cards.length === 0 ? (
                      <div style={{ textAlign: 'center', color: '#d1d5db', fontSize: 12, padding: '20px 0' }}>Aucun</div>
                    ) : (
                      cards.map(item => (
                        <MarketCard key={item.id} item={item} onClick={() => setSelectedItem(item)} />
                      ))
                    )}
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      )}

      {selectedItem && <MarketCardModal item={selectedItem} market={market} onClose={() => setSelectedItem(null)} onSave={() => { setSelectedItem(null); load() }} onDelete={() => { setSelectedItem(null); load() }} />}
      {showAdd && <MarketAddModal market={market} marketLabel={marketLabel} onClose={onCloseAdd} onSave={() => { onCloseAdd(); load() }} />}
    </div>
  )
}
