import { useEffect, useState } from 'react'
import api from '../api/client'

const TARGETS = ['developer', 'investor', 'ipp', 'family_office']
const TARGET_LABELS = {
  developer: '👷 Développeurs',
  investor: '🏦 Investisseurs',
  ipp: '⚡ IPP',
  family_office: '👨‍👩‍👧‍👦 Family Office',
}
const TARGET_COLORS = {
  developer: { bg: '#d1fae5', color: '#065f46', border: '#a7f3d0' },
  investor: { bg: '#fef3c7', color: '#92400e', border: '#fde68a' },
  ipp: { bg: '#cffafe', color: '#155e75', border: '#a5f3fc' },
  family_office: { bg: '#ede9fe', color: '#5b21b6', border: '#ddd6fe' },
}

export default function Templates() {
  const [data, setData] = useState([])
  const [activeTarget, setActiveTarget] = useState('developer')
  const [search, setSearch] = useState('')
  const [selected, setSelected] = useState(null)
  const [showAdd, setShowAdd] = useState(false)

  const load = () => {
    api.get('/templates/', {}).then(r => setData(r.data))
  }
  useEffect(() => { load() }, [])

  const filtered = data.filter(d =>
    !search || d.name.toLowerCase().includes(search.toLowerCase()) ||
    d.body.toLowerCase().includes(search.toLowerCase()) ||
    (d.target || '').includes(search.toLowerCase())
  )

  const byTarget = {}
  TARGETS.forEach(t => {
    byTarget[t] = filtered.filter(d => d.target === t)
  })

  const typeColors = { email: { bg: '#dbeafe', color: '#1e40af' }, linkedin: { bg: '#ede9fe', color: '#5b21b6' } }
  const langLabels = { en: '🇬🇧 EN', fr: '🇫🇷 FR' }

  const copyToClipboard = async (text) => {
    try {
      await navigator.clipboard.writeText(text)
      return true
    } catch { return false }
  }

  const active = byTarget[activeTarget] || []
  const linkedinStep1 = active.filter(d => d.type === 'linkedin' && d.step === 1)
  const linkedinStep2 = active.filter(d => d.type === 'linkedin' && d.step === 2)
  const emails = active.filter(d => d.type === 'email')

  const card = (tp) => ({
    padding: '14px 16px', borderRadius: 8, border: '1px solid #e5e7eb',
    marginBottom: 8, cursor: 'pointer', background: selected?.id === tp.id ? '#f0fdf4' : '#fff',
    transition: 'all 0.15s',
  })
  const badge = (bg, color, label) => ({
    padding: '2px 8px', borderRadius: 8, fontSize: 10, fontWeight: 600, background: bg, color,
  })
  const stepLabel = (step) => step === 1 ? '1ère connexion' : '2ème connexion'
  const stepColor = (step) => step === 1 ? { bg: '#f0fdf4', color: '#065f46' } : { bg: '#fffbeb', color: '#92400e' }

  const TemplateCard = ({ tp }) => {
    const [copied, setCopied] = useState(false)
    const tc = typeColors[tp.type] || {}
    const sc = stepColor(tp.step)
    const handleCopy = async () => {
      let text = tp.body
      if (tp.type === 'email' && tp.subject) text = `Objet : ${tp.subject}\n\n${tp.body}`
      await copyToClipboard(text)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    }
    return (
      <div style={card(tp)}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
          <div style={{ fontWeight: 600, fontSize: 13, color: '#1f2937', flex: 1 }}>{tp.name}</div>
          <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
            <span style={badge(tc.bg, tc.color, tc.label || tp.type)}>{tp.type}</span>
            {tp.step && <span style={badge(sc.bg, sc.color, stepLabel(tp.step))}>{stepLabel(tp.step)}</span>}
            {tp.language && <span style={badge('#f3f4f6', '#4b5563', langLabels[tp.language] || tp.language)}>{langLabels[tp.language] || tp.language}</span>}
          </div>
        </div>
        <div style={{ fontSize: 12, color: '#4b5563', lineHeight: 1.5, marginBottom: 8, whiteSpace: 'pre-wrap', maxHeight: 50, overflow: 'hidden' }}>
          {tp.body.slice(0, 120)}{tp.body.length > 120 ? '...' : ''}
        </div>
        <div style={{ display: 'flex', gap: 6 }}>
          <button onClick={(e) => { e.stopPropagation(); setSelected(tp) }}
            style={{ padding: '4px 10px', borderRadius: 5, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer', fontSize: 11, fontWeight: 600, color: '#374151' }}>
            👁️ Voir
          </button>
          <button onClick={handleCopy}
            style={{ padding: '4px 10px', borderRadius: 5, border: 'none', cursor: 'pointer', fontSize: 11, fontWeight: 600, background: copied ? '#d1fae5' : '#1f2937', color: copied ? '#065f46' : '#fff' }}>
            {copied ? '✅ Copié' : '📋 Copier'}
          </button>
        </div>
      </div>
    )
  }

  return (
    <div style={{ display: 'flex', gap: 16, height: 'calc(100vh - 100px)' }}>
      {/* Sidebar - category tabs */}
      <div style={{ width: 220, flexShrink: 0, display: 'flex', flexDirection: 'column', gap: 8 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
          <h2 style={{ fontSize: 16, fontWeight: 700, color: '#1f2937', margin: 0 }}>📝 Templates</h2>
          <button onClick={() => { setShowAdd(true); setSelected(null) }}
            style={{ padding: '4px 10px', background: '#2563eb', color: '#fff', border: 'none', borderRadius: 6, cursor: 'pointer', fontSize: 12, fontWeight: 600 }}>+</button>
        </div>
        <input placeholder="🔍 Rechercher..." value={search} onChange={e => setSearch(e.target.value)}
          style={{ width: '100%', padding: '7px 10px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 12, boxSizing: 'border-box' }} />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
          {TARGETS.map(t => {
            const tc = TARGET_COLORS[t]
            const count = byTarget[t]?.length || 0
            return (
              <button key={t} onClick={() => { setActiveTarget(t); setSelected(null) }}
                style={{
                  padding: '10px 14px', borderRadius: 8, border: `2px solid ${activeTarget === t ? tc.color : 'transparent'}`,
                  background: activeTarget === t ? tc.bg : '#fff', cursor: 'pointer', textAlign: 'left',
                  fontWeight: 600, fontSize: 13, color: activeTarget === t ? tc.color : '#6b7280',
                }}>
                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                  <span>{TARGET_LABELS[t]}</span>
                  <span style={{ background: tc.border, borderRadius: 10, padding: '0 8px', fontSize: 11, fontWeight: 700 }}>{count}</span>
                </div>
              </button>
            )
          })}
        </div>
      </div>

      {/* Main content */}
      <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
        {selected ? (
          <div style={{ flex: 1, overflowY: 'auto', background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8, padding: 24 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 20 }}>
              <div>
                <h2 style={{ fontSize: 20, fontWeight: 700, color: '#1f2937', marginBottom: 8 }}>{selected.name}</h2>
                <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                  <span style={{ padding: '3px 10px', borderRadius: 8, fontSize: 11, fontWeight: 600, ...typeColors[selected.type] }}>{selected.type}</span>
                  <span style={{ padding: '3px 10px', borderRadius: 8, fontSize: 11, fontWeight: 600, ...TARGET_COLORS[selected.target] }}>{TARGET_LABELS[selected.target]}</span>
                  {selected.step && <span style={{ padding: '3px 10px', borderRadius: 8, fontSize: 11, fontWeight: 600, background: '#fff3cd', color: '#856404' }}>{selected.step === 1 ? '1ère connexion' : '2ème connexion'}</span>}
                  <span style={{ padding: '3px 10px', borderRadius: 8, fontSize: 11, fontWeight: 600, background: '#f3f4f6', color: '#4b5563' }}>{langLabels[selected.language] || selected.language}</span>
                </div>
              </div>
              <div style={{ display: 'flex', gap: 8 }}>
                <button onClick={async () => {
                  let text = selected.body
                  if (selected.type === 'email' && selected.subject) text = `Objet : ${selected.subject}\n\n${text}`
                  await copyToClipboard(text)
                }} style={{ padding: '8px 14px', background: '#1f2937', color: '#fff', border: 'none', borderRadius: 6, cursor: 'pointer', fontSize: 13, fontWeight: 600 }}>
                  📋 Copier
                </button>
                <button onClick={() => setSelected(null)} style={{ padding: '8px 14px', background: '#f3f4f6', border: '1px solid #d1d5db', borderRadius: 6, cursor: 'pointer', fontSize: 13 }}>Retour</button>
              </div>
            </div>
            {selected.subject && (
              <div style={{ background: '#f9fafb', borderRadius: 6, padding: '10px 14px', marginBottom: 12, fontSize: 13 }}>
                <span style={{ fontWeight: 600, color: '#6b7280' }}>Objet : </span>{selected.subject}
              </div>
            )}
            <div style={{ background: '#f9fafb', borderRadius: 8, padding: 16, fontSize: 14, lineHeight: 1.8, whiteSpace: 'pre-wrap', color: '#1f2937', fontFamily: 'monospace' }}>
              {selected.body}
            </div>
          </div>
        ) : (
          <div style={{ flex: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: 16 }}>
            {/* Section: LinkedIn 1ère connexion */}
            {linkedinStep1.length > 0 && (
              <div>
                <h3 style={{ fontSize: 14, fontWeight: 700, color: '#1f2937', marginBottom: 10 }}>🔗 LinkedIn — 1ère connexion</h3>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 8 }}>
                  {linkedinStep1.map(tp => <TemplateCard key={tp.id} tp={tp} />)}
                </div>
              </div>
            )}
            {/* Section: LinkedIn 2ème connexion */}
            {linkedinStep2.length > 0 && (
              <div>
                <h3 style={{ fontSize: 14, fontWeight: 700, color: '#1f2937', marginBottom: 10 }}>🔗 LinkedIn — 2ème connexion</h3>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 8 }}>
                  {linkedinStep2.map(tp => <TemplateCard key={tp.id} tp={tp} />)}
                </div>
              </div>
            )}
            {/* Section: Email */}
            {emails.length > 0 && (
              <div>
                <h3 style={{ fontSize: 14, fontWeight: 700, color: '#1f2937', marginBottom: 10 }}>📧 Email</h3>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 8 }}>
                  {emails.map(tp => <TemplateCard key={tp.id} tp={tp} />)}
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Add modal */}
      {showAdd && (
        <AddModal onClose={() => setShowAdd(false)} onSave={() => { setShowAdd(false); load() }} />
      )}
    </div>
  )
}

function AddModal({ onClose, onSave }) {
  const [form, setForm] = useState({
    name: '', type: 'linkedin', target: 'developer', subject: '', body: '',
    language: 'fr', step: 1, notes: '',
  })
  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))
  const inp = { width: '100%', padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13, boxSizing: 'border-box' }
  const lbl = { display: 'block', fontSize: 11, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 4, marginTop: 12 }

  const handleSave = async () => {
    if (!form.name || !form.body) return alert('Nom et contenu obligatoires')
    await api.post('/templates/', form)
    onSave()
  }

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100, padding: 16 }}
      onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={{ background: '#fff', borderRadius: 12, padding: 24, width: 520, maxHeight: '90vh', overflowY: 'auto', boxShadow: '0 25px 60px rgba(0,0,0,0.2)' }}>
        <h2 style={{ fontSize: 17, fontWeight: 700, marginBottom: 16 }}>Nouveau template</h2>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          <div><label style={{ ...lbl, marginTop: 0 }}>Nom *</label><input style={inp} value={form.name} onChange={e => set('name', e.target.value)} autoFocus /></div>
          <div><label style={{ ...lbl, marginTop: 0 }}>Type</label>
            <select style={inp} value={form.type} onChange={e => set('type', e.target.value)}>
              <option value="linkedin">LinkedIn</option>
              <option value="email">Email</option>
            </select>
          </div>
          <div><label style={{ ...lbl, marginTop: 0 }}>Cible</label>
            <select style={inp} value={form.target} onChange={e => set('target', e.target.value)}>
              <option value="developer">Développeurs</option>
              <option value="investor">Investisseurs</option>
              <option value="ipp">IPP</option>
              <option value="family_office">Family Office</option>
            </select>
          </div>
          <div><label style={{ ...lbl, marginTop: 0 }}>Langue</label>
            <select style={inp} value={form.language} onChange={e => set('language', e.target.value)}>
              <option value="fr">🇫🇷 FR</option>
              <option value="en">🇬🇧 EN</option>
            </select>
          </div>
          <div><label style={{ ...lbl, marginTop: 0 }}>Étape</label>
            <select style={inp} value={form.step} onChange={e => set('step', parseInt(e.target.value))}>
              <option value={1}>1ère connexion</option>
              <option value={2}>2ème connexion</option>
            </select>
          </div>
        </div>
        {form.type === 'email' && (
          <><label style={lbl}>Objet</label><input style={inp} value={form.subject} onChange={e => set('subject', e.target.value)} /></>
        )}
        <label style={lbl}>Message *</label>
        <textarea style={{ ...inp, height: 180, resize: 'vertical' }} value={form.body} onChange={e => set('body', e.target.value)} placeholder="Utilisez [Prénom] pour personnaliser..." />
        <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end', marginTop: 16 }}>
          <button onClick={onClose} style={{ padding: '8px 16px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer' }}>Annuler</button>
          <button onClick={handleSave} style={{ padding: '8px 18px', borderRadius: 6, border: 'none', background: '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 700 }}>💾 Sauvegarder</button>
        </div>
      </div>
    </div>
  )
}
