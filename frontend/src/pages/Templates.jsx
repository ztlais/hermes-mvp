import { useEffect, useState } from 'react'
import api from '../api/client'

const TYPE_OPTIONS = ['email','linkedin']
const TARGET_OPTIONS = ['developer','investor','ipp','family_office']

export default function Templates() {
  const [data, setData] = useState([])
  const [selected, setSelected] = useState(null)
  const [showAdd, setShowAdd] = useState(false)
  const [filterType, setFilterType] = useState('')
  const [filterTarget, setFilterTarget] = useState('')
  const [form, setForm] = useState({ name: '', type: 'email', target: 'developer', subject: '', body: '', language: 'fr', notes: '' })
  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))
  const [copied, setCopied] = useState(false)

  const load = () => {
    const params = {}
    if (filterType) params.type = filterType
    if (filterTarget) params.target = filterTarget
    api.get('/templates/', { params }).then(r => setData(r.data))
  }

  useEffect(() => { load() }, [filterType, filterTarget])

  const handleSave = async () => {
    await api.post('/templates/', form)
    setShowAdd(false)
    setForm({ name: '', type: 'email', target: 'developer', subject: '', body: '', language: 'fr', notes: '' })
    load()
  }

  const handleDelete = async (id) => {
    if (!confirm('Supprimer ce template ?')) return
    await api.delete(`/templates/${id}`)
    setSelected(null)
    load()
  }

  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  const input = { width: '100%', padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 14 }
  const label = { display: 'block', fontSize: 12, fontWeight: 600, color: '#374151', marginBottom: 4, marginTop: 12 }

  const typeColors = { email: { bg: '#dbeafe', color: '#1e40af' }, linkedin: { bg: '#ede9fe', color: '#5b21b6' } }
  const targetColors = { developer: { bg: '#d1fae5', color: '#065f46' }, investor: { bg: '#fef3c7', color: '#92400e' }, ipp: { bg: '#cffafe', color: '#155e75' }, family_office: { bg: '#f3e8ff', color: '#6b21a8' } }

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '280px 1fr', gap: 16, height: 'calc(100vh - 100px)' }}>
      <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
        <div style={{ padding: 16, borderBottom: '1px solid #e5e7eb' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
            <h2 style={{ fontSize: 16, fontWeight: 700, color: '#1f2937' }}>📝 Templates</h2>
            <button onClick={() => { setShowAdd(true); setSelected(null) }} style={{ padding: '4px 10px', background: '#2563eb', color: '#fff', border: 'none', borderRadius: 6, cursor: 'pointer', fontSize: 12, fontWeight: 600 }}>+</button>
          </div>
          <select value={filterType} onChange={e => setFilterType(e.target.value)} style={{ ...input, marginBottom: 6 }}>
            <option value="">Email + LinkedIn</option>
            {TYPE_OPTIONS.map(t => <option key={t} value={t}>{t}</option>)}
          </select>
          <select value={filterTarget} onChange={e => setFilterTarget(e.target.value)} style={input}>
            <option value="">Tous les types</option>
            {TARGET_OPTIONS.map(t => <option key={t} value={t}>{t}</option>)}
          </select>
        </div>
        <div style={{ overflowY: 'auto', flex: 1 }}>
          {data.map(t => (
            <div key={t.id} onClick={() => { setSelected(t); setShowAdd(false) }}
              style={{ padding: 14, borderBottom: '1px solid #f3f4f6', cursor: 'pointer', background: selected?.id === t.id ? '#eff6ff' : '#fff' }}>
              <div style={{ fontWeight: 600, fontSize: 13, color: '#1f2937', marginBottom: 6 }}>{t.name}</div>
              <div style={{ display: 'flex', gap: 6 }}>
                <span style={{ padding: '2px 8px', borderRadius: 8, fontSize: 10, fontWeight: 600, ...typeColors[t.type] }}>{t.type}</span>
                <span style={{ padding: '2px 8px', borderRadius: 8, fontSize: 10, fontWeight: 600, ...targetColors[t.target] }}>{t.target}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8, padding: 24, overflowY: 'auto' }}>
        {showAdd ? (
          <>
            <h3 style={{ fontSize: 16, fontWeight: 700, marginBottom: 16 }}>Nouveau template</h3>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 }}>
              <div><label style={label}>Nom *</label><input style={input} value={form.name} onChange={e => set('name', e.target.value)} /></div>
              <div><label style={label}>Type</label>
                <select style={input} value={form.type} onChange={e => set('type', e.target.value)}>
                  {TYPE_OPTIONS.map(t => <option key={t} value={t}>{t}</option>)}
                </select></div>
              <div><label style={label}>Cible</label>
                <select style={input} value={form.target} onChange={e => set('target', e.target.value)}>
                  {TARGET_OPTIONS.map(t => <option key={t} value={t}>{t}</option>)}
                </select></div>
            </div>
            {form.type === 'email' && (
              <><label style={label}>Objet</label><input style={input} value={form.subject} onChange={e => set('subject', e.target.value)} /></>
            )}
            <label style={label}>Corps du message *</label>
            <textarea style={{ ...input, height: 200, resize: 'vertical' }} value={form.body} onChange={e => set('body', e.target.value)} />
            <div style={{ display: 'flex', gap: 10, marginTop: 16, justifyContent: 'flex-end' }}>
              <button onClick={() => setShowAdd(false)} style={{ padding: '8px 16px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer' }}>Annuler</button>
              <button onClick={handleSave} style={{ padding: '8px 16px', borderRadius: 6, border: 'none', background: '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 600 }}>Sauvegarder</button>
            </div>
          </>
        ) : selected ? (
          <>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 20 }}>
              <div>
                <h2 style={{ fontSize: 20, fontWeight: 700, color: '#1f2937' }}>{selected.name}</h2>
                <div style={{ display: 'flex', gap: 6, marginTop: 6 }}>
                  <span style={{ padding: '2px 10px', borderRadius: 8, fontSize: 11, fontWeight: 600, ...typeColors[selected.type] }}>{selected.type}</span>
                  <span style={{ padding: '2px 10px', borderRadius: 8, fontSize: 11, fontWeight: 600, ...targetColors[selected.target] }}>{selected.target}</span>
                  <span style={{ padding: '2px 10px', borderRadius: 8, fontSize: 11, fontWeight: 600, background: '#f3f4f6', color: '#4b5563' }}>{selected.language}</span>
                </div>
              </div>
              <div style={{ display: 'flex', gap: 8 }}>
                <button onClick={() => copyToClipboard(selected.body)} style={{ padding: '8px 14px', background: copied ? '#d1fae5' : '#f9fafb', border: '1px solid #e5e7eb', borderRadius: 6, cursor: 'pointer', fontSize: 13, fontWeight: 600, color: copied ? '#065f46' : '#374151' }}>
                  {copied ? '✅ Copié' : '📋 Copier'}
                </button>
                <button onClick={() => handleDelete(selected.id)} style={{ padding: '8px 14px', background: '#fee2e2', border: 'none', borderRadius: 6, cursor: 'pointer', fontSize: 13, color: '#991b1b', fontWeight: 600 }}>
                  Supprimer
                </button>
              </div>
            </div>
            {selected.subject && (
              <div style={{ background: '#f9fafb', borderRadius: 6, padding: '10px 14px', marginBottom: 12, fontSize: 13 }}>
                <span style={{ fontWeight: 600, color: '#6b7280' }}>Objet : </span>{selected.subject}
              </div>
            )}
            <div style={{ background: '#f9fafb', borderRadius: 8, padding: 16, fontSize: 14, lineHeight: 1.8, whiteSpace: 'pre-wrap', color: '#1f2937' }}>
              {selected.body}
            </div>
          </>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%', color: '#9ca3af', flexDirection: 'column', gap: 12 }}>
            <div style={{ fontSize: 48 }}>📝</div>
            <div>Sélectionne un template</div>
          </div>
        )}
      </div>
    </div>
  )
}
