import api from '../api/client'
import { useEffect, useState, useRef } from 'react'
import { useLang } from '../context/LanguageContext'

const DOC_TYPES = [
  { value: 'nda',           label: 'NDA',            color: '#7c3aed', bg: '#ede9fe' },
  { value: 'fee_agreement', label: 'Fee Agreement',  color: '#1e40af', bg: '#dbeafe' },
  { value: 'teaser',        label: 'Teaser',         color: '#065f46', bg: '#d1fae5' },
  { value: 'presentation',  label: 'Présentation',   color: '#92400e', bg: '#fef3c7' },
  { value: 'compte_rendu',  label: 'Compte Rendu',   color: '#92400e', bg: '#fef3c7' },
  { value: 'contract',      label: 'Contrat',        color: '#991b1b', bg: '#fee2e2' },
  { value: 'other',         label: 'Autre',          color: '#4b5563', bg: '#f3f4f6' },
]

function DocTypeStyle(type) {
  return DOC_TYPES.find(d => d.value === type) || DOC_TYPES[DOC_TYPES.length - 1]
}

function DocumentsSection({ prospectId }) {
  const { t } = useLang()
  const [docs, setDocs] = useState([])
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ name: '', url: '', doc_type: 'nda' })

  const load = () => api.get('/documents/', { params: { prospect_id: prospectId } }).then(r => setDocs(r.data))
  useEffect(() => { load() }, [prospectId])

  const handleAdd = async () => {
    if (!form.name || !form.url) return
    await api.post('/documents/', { ...form, prospect_id: prospectId })
    setForm({ name: '', url: '', doc_type: 'nda' })
    setShowForm(false)
    load()
  }

  const handleDelete = async (id) => {
    await api.delete(`/documents/${id}`)
    load()
  }

  const inp = { width: '100%', padding: '7px 10px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 12, boxSizing: 'border-box' }

  return (
    <div style={{ margin: '16px 0' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
        <div style={{ fontSize: 10, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: 0.5 }}>
          {t('common.documents')}
        </div>
        <button onClick={() => setShowForm(!showForm)} style={{
          padding: '3px 10px', borderRadius: 5, border: '1px solid #d1d5db',
          background: '#fff', fontSize: 11, cursor: 'pointer', fontWeight: 600, color: '#374151',
        }}>
          {t('docs.add')}
        </button>
      </div>

      {docs.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginBottom: showForm ? 10 : 0 }}>
          {docs.map(doc => {
            const style = DocTypeStyle(doc.doc_type)
            return (
              <div key={doc.id} style={{ display: 'flex', alignItems: 'center', gap: 0 }}>
                <a href={doc.url} target="_blank" rel="noreferrer" title={doc.name} style={{
                  padding: '4px 10px', borderRadius: '6px 0 0 6px',
                  background: style.bg, color: style.color,
                  fontSize: 11, fontWeight: 700, textDecoration: 'none',
                  border: `1px solid ${style.color}30`,
                  borderRight: 'none',
                  whiteSpace: 'nowrap', maxWidth: 120,
                  overflow: 'hidden', textOverflow: 'ellipsis',
                  display: 'block',
                }}>
                  {doc.name}
                </a>
                <button onClick={() => handleDelete(doc.id)} style={{
                  padding: '4px 6px', borderRadius: '0 6px 6px 0',
                  background: style.bg, color: style.color,
                  fontSize: 10, border: `1px solid ${style.color}30`,
                  cursor: 'pointer', lineHeight: 1,
                }}>✕</button>
              </div>
            )
          })}
        </div>
      )}

      {docs.length === 0 && !showForm && (
        <div style={{ fontSize: 12, color: '#d1d5db', fontStyle: 'italic' }}>{t('common.noDocuments')}</div>
      )}

      {showForm && (
        <div style={{ background: '#f9fafb', border: '1px solid #e5e7eb', borderRadius: 8, padding: 12 }}>
          <div style={{ marginBottom: 8 }}>
            <select value={form.doc_type} onChange={e => setForm(f => ({ ...f, doc_type: e.target.value }))} style={{ ...inp, marginBottom: 6 }}>
              {DOC_TYPES.map(t => <option key={t.value} value={t.value}>{t.label}</option>)}
            </select>
            <input style={{ ...inp, marginBottom: 6 }} placeholder="Nom (ex: NDA Viridi)" value={form.name}
              onChange={e => setForm(f => ({ ...f, name: e.target.value }))} />
            <input style={inp} placeholder={t('docs.urlPH')} value={form.url}
              onChange={e => setForm(f => ({ ...f, url: e.target.value }))} />
          </div>
          <div style={{ display: 'flex', gap: 6, justifyContent: 'flex-end' }}>
            <button onClick={() => setShowForm(false)} style={{ padding: '5px 12px', borderRadius: 5, border: '1px solid #d1d5db', background: '#fff', fontSize: 12, cursor: 'pointer' }}>{t('common.cancel')}</button>
            <button onClick={handleAdd} style={{ padding: '5px 12px', borderRadius: 5, border: 'none', background: '#2563eb', color: '#fff', fontSize: 12, cursor: 'pointer', fontWeight: 600 }}>{t('common.add')}</button>
          </div>
        </div>
      )}
    </div>
  )
}

const STATUS_VALUES = [
  { value: 'to_contact',        color: '#6b7280', bg: '#f3f4f6' },
  { value: 'contacted',         color: '#1e40af', bg: '#dbeafe' },
  { value: 'in_discussion',     color: '#92400e', bg: '#fef3c7' },
  { value: 'meeting_scheduled', color: '#5b21b6', bg: '#ede9fe' },
  { value: 'nda_signed',        color: '#065f46', bg: '#d1fae5' },
  { value: 'deal_in_progress',  color: '#155e75', bg: '#cffafe' },
  { value: 'closed',            color: '#065f46', bg: '#d1fae5' },
  { value: 'rejected',          color: '#991b1b', bg: '#fee2e2' },
]

const TYPE_VALUES = [
  { value: 'developer' },
  { value: 'investor' },
  { value: 'ipp' },
  { value: 'family_office' },
  { value: 'other' },
]

function StatusBadge({ value }) {
  const { t } = useLang()
  const s = STATUS_VALUES.find(o => o.value === value) || STATUS_VALUES[0]
  return (
    <span style={{ padding: '3px 10px', borderRadius: 10, fontSize: 11, fontWeight: 700, background: s.bg, color: s.color }}>
      {t('status.' + value)}
    </span>
  )
}

function InfoRow({ icon, label, value, href }) {
  if (!value) return null
  return (
    <div style={{ display: 'flex', gap: 10, padding: '8px 0', borderBottom: '1px solid #f3f4f6', alignItems: 'flex-start' }}>
      <span style={{ fontSize: 14, flexShrink: 0, width: 20 }}>{icon}</span>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 10, color: '#9ca3af', textTransform: 'uppercase', fontWeight: 700, letterSpacing: 0.4 }}>{label}</div>
        {href ? (
          <a href={href} target="_blank" rel="noreferrer" style={{ fontSize: 13, color: '#2563eb', wordBreak: 'break-all' }}>{value}</a>
        ) : (
          <div style={{ fontSize: 13, color: '#1f2937', lineHeight: 1.5, whiteSpace: 'pre-wrap', wordBreak: 'break-word' }}>{value}</div>
        )}
      </div>
    </div>
  )
}

function ProspectDetail({ prospect, onEdit, onClose, onDelete }) {
  const { t } = useLang()
  const statusStyle = STATUS_VALUES.find(s => s.value === prospect.status)

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{ padding: '20px 20px 16px', borderBottom: '1px solid #e5e7eb' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div style={{ flex: 1, paddingRight: 8 }}>
            <h2 style={{ fontSize: 17, fontWeight: 800, color: '#1f2937', lineHeight: 1.3, marginBottom: 6 }}>
              {prospect.company}
            </h2>
            <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
              <StatusBadge value={prospect.status} />
              {prospect.type && (
                <span style={{ padding: '3px 10px', borderRadius: 10, fontSize: 11, fontWeight: 700, background: '#f3f4f6', color: '#4b5563' }}>
                  {t('type.' + prospect.type)}
                </span>
              )}
              {prospect.nda_signed === 'Oui' && (
                <span style={{ padding: '3px 10px', borderRadius: 10, fontSize: 11, fontWeight: 700, background: '#d1fae5', color: '#065f46' }}>
                  ✅ {t('status.nda_signed')}
                </span>
              )}
            </div>
          </div>
          <button onClick={onClose} style={{ background: 'none', border: 'none', fontSize: 18, cursor: 'pointer', color: '#9ca3af', flexShrink: 0 }}>✕</button>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '0 20px' }}>
        <div style={{ marginTop: 12, marginBottom: 4 }}>
          <div style={{ fontSize: 10, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 4 }}>
            {t('prospects.detail.contact')}
          </div>
          <InfoRow icon="👤" label={t('prospects.detail.name')} value={prospect.contact_name} />
          <InfoRow icon="✉️" label="Email" value={prospect.email} href={prospect.email ? `mailto:${prospect.email}` : null} />
          <InfoRow icon="📞" label={t('prospects.detail.phone')} value={prospect.phone} href={prospect.phone ? `tel:${prospect.phone}` : null} />
          <InfoRow icon="🔗" label="LinkedIn" value={prospect.linkedin} href={prospect.linkedin} />
          <InfoRow icon="🌍" label={t('prospects.detail.country')} value={prospect.country} />
          <InfoRow icon="📌" label={t('prospects.detail.source')} value={prospect.source} />
        </div>

        {prospect.notes && (
          <div style={{ margin: '16px 0' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
              <div style={{ fontSize: 10, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: 0.5 }}>
                {t('prospects.detail.notes')}
              </div>
              <button onClick={async () => {
                const btn = document.getElementById(`sync-btn-${prospect.id}`)
                if (btn) { btn.textContent = '⏳ Sync...'; btn.disabled = true }
                try {
                  const r = await api.post(`/prospects/${prospect.id}/sync-to-crm`)
                  if (r.data.ok) {
                    btn.textContent = '✅ Synced'
                    btn.style.background = '#059669'
                    setTimeout(() => {
                      btn.textContent = '🔄 Sync CRM'
                      btn.style.background = '#2563eb'
                      btn.disabled = false
                    }, 2000)
                  }
                } catch {
                  if (btn) { btn.textContent = '❌ Error'; btn.disabled = false }
                }
              }}
                id={`sync-btn-${prospect.id}`}
                style={{
                  padding: '4px 12px', borderRadius: 6, border: 'none', cursor: 'pointer',
                  fontSize: 11, fontWeight: 600, background: '#2563eb', color: '#fff',
                  whiteSpace: 'nowrap',
                }}>
                🔄 Sync CRM
              </button>
            </div>
            <div style={{
              background: '#f9fafb', border: '1px solid #e5e7eb', borderRadius: 8,
              padding: 14, fontSize: 13, color: '#374151', lineHeight: 1.7, whiteSpace: 'pre-wrap',
            }}>
              {prospect.notes}
            </div>
          </div>
        )}

        {prospect.next_action && (
          <div style={{ margin: '16px 0' }}>
            <div style={{ fontSize: 10, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 8 }}>
              {t('prospects.detail.nextAction')}
            </div>
            <div style={{
              background: '#fffbeb', border: '1px solid #fde68a', borderRadius: 8,
              padding: 14, fontSize: 13, color: '#92400e', lineHeight: 1.6, fontWeight: 500, whiteSpace: 'pre-wrap',
            }}>
              {prospect.next_action}
            </div>
          </div>
        )}

        {prospect.teaser && (
          <div style={{ margin: '16px 0' }}>
            <div style={{ fontSize: 10, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 8 }}>
              {t('prospects.detail.teaser')}
            </div>
            <div style={{
              background: '#eff6ff', border: '1px solid #bfdbfe', borderRadius: 8,
              padding: 14, fontSize: 13, color: '#1e40af', lineHeight: 1.6, whiteSpace: 'pre-wrap',
            }}>
              {prospect.teaser}
            </div>
          </div>
        )}

        {prospect.raw_transcript && (
          <div style={{ margin: '16px 0' }}>
            <div style={{ fontSize: 10, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 8 }}>
              📝 Compte-rendu brut
            </div>
            <div style={{
              background: '#fffbeb', border: '1px solid #fde68a', borderRadius: 8,
              padding: 14, fontSize: 12, color: '#92400e', lineHeight: 1.5, whiteSpace: 'pre-wrap', fontStyle: 'italic', maxHeight: 200, overflowY: 'auto',
            }}>
              {prospect.raw_transcript}
            </div>
          </div>
        )}

        {prospect.email_draft && (
          <div style={{ margin: '16px 0' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
                <div style={{ fontSize: 10, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: 0.5 }}>
                  📧 Brouillon email
                </div>
                <div style={{ display: 'flex', gap: 4, alignItems: 'center' }}>
                  <span style={{ fontSize: 10, color: '#9ca3af', fontStyle: 'italic', marginRight: 4 }}>vouvoiement</span>
                <a href="https://mail.google.com"
                  target="_blank" rel="noreferrer"
                  style={{
                    padding: '3px 8px', borderRadius: 5, border: '1px solid #d1d5db',
                    background: '#fff', fontSize: 11, cursor: 'pointer', fontWeight: 600,
                    color: '#374151', textDecoration: 'none',
                  }}>
                  📤 Envoyer
                </a>
                <button onClick={async () => {
                if (!confirm('Supprimer le brouillon ?')) return
                await api.put(`/prospects/${prospect.id}`, { email_draft: '' })
                window.location.reload()
              }} style={{
                background: 'none', border: 'none', color: '#ef4444', cursor: 'pointer',
                fontSize: 13, padding: '2px 6px', opacity: 0.6,
              }}>🗑️</button>
              </div>
            </div>
            <div style={{
              background: '#f0fdf4', border: '1px solid #bbf7d0', borderRadius: 8,
              padding: 14, fontSize: 13, color: '#166534', lineHeight: 1.6, whiteSpace: 'pre-wrap',
            }}>
              {prospect.email_draft}
            </div>
          </div>
        )}

        {!prospect.email_draft && prospect.notes && (
          <div style={{ margin: '16px 0' }}>
            <button onClick={() => alert('Dis-moi "prépare un draft email pour ' + prospect.company + '" et je le fais !')} style={{
              width: '100%', padding: '10px', borderRadius: 8,
              border: '1px dashed #d1d5db', background: '#fff',
              fontSize: 12, fontWeight: 600, color: '#6b7280',
              cursor: 'pointer',
            }}>
              ✏️ Préparer un draft email
            </button>
          </div>
        )}

        <div style={{ borderTop: '1px solid #f3f4f6', paddingTop: 16, marginTop: 8 }}>
          <DocumentsSection prospectId={prospect.id} />
        </div>

        <div style={{ height: 16 }} />
      </div>

      <div style={{ padding: '14px 20px', borderTop: '1px solid #e5e7eb', display: 'flex', gap: 8 }}>
        <button onClick={onEdit} style={{
          flex: 1, padding: '9px', borderRadius: 6, border: 'none',
          background: '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 700, fontSize: 13,
        }}>
          ✏️ {t('common.edit')}
        </button>
        {prospect.email && (
          <a href={`mailto:${prospect.email}`} style={{
            padding: '9px 14px', borderRadius: 6, border: '1px solid #e5e7eb',
            background: '#fff', color: '#374151', cursor: 'pointer', fontWeight: 600, fontSize: 13,
            textDecoration: 'none', display: 'flex', alignItems: 'center',
          }}>
            📧
          </a>
        )}
        <button onClick={onDelete} style={{
          padding: '9px 14px', borderRadius: 6, border: 'none',
          background: '#fee2e2', color: '#991b1b', cursor: 'pointer', fontSize: 13,
        }}>
          🗑️
        </button>
      </div>
    </div>
  )
}

function EditModal({ prospect, onClose, onSave }) {
  const { t } = useLang()
  const [form, setForm] = useState(prospect || {
    company: '', contact_name: '', email: '', phone: '', linkedin: '',
    type: 'developer', status: 'to_contact', country: 'FR',
    notes: '', teaser: '', nda_signed: 'Non', next_action: '', source: '',
    raw_transcript: '', email_draft: ''
  })
  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))

  const handleSave = async () => {
    try {
      if (prospect?.id) await api.put(`/prospects/${prospect.id}`, form)
      else await api.post('/prospects/', form)
      onSave(form)
    } catch { alert(t('prospects.saveError') || 'Erreur lors de la sauvegarde') }
  }

  const input = { width: '100%', padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13, boxSizing: 'border-box' }
  const label = { display: 'block', fontSize: 11, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 4, marginTop: 12 }

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 200, padding: 16 }}
      onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={{ background: '#fff', borderRadius: 12, padding: 28, width: 560, maxHeight: '92vh', overflowY: 'auto', boxShadow: '0 25px 60px rgba(0,0,0,0.2)' }}>
        <h2 style={{ fontSize: 17, fontWeight: 700, marginBottom: 16 }}>
          {prospect?.id ? t('prospects.modal.editTitle') : t('prospects.modal.newTitle')}
        </h2>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <div><label style={{ ...label, marginTop: 0 }}>{t('prospects.form.company')}</label><input style={input} value={form.company} onChange={e => set('company', e.target.value)} /></div>
          <div><label style={{ ...label, marginTop: 0 }}>{t('prospects.form.contact')}</label><input style={input} value={form.contact_name || ''} onChange={e => set('contact_name', e.target.value)} /></div>
          <div><label style={{ ...label, marginTop: 0 }}>Email</label><input style={input} type="email" value={form.email || ''} onChange={e => set('email', e.target.value)} /></div>
          <div><label style={{ ...label, marginTop: 0 }}>{t('prospects.form.phone')}</label><input style={input} value={form.phone || ''} onChange={e => set('phone', e.target.value)} /></div>
          <div>
            <label style={{ ...label, marginTop: 0 }}>{t('prospects.form.type')}</label>
            <select style={input} value={form.type} onChange={e => set('type', e.target.value)}>
              {TYPE_VALUES.map(tp => <option key={tp.value} value={tp.value}>{t('type.' + tp.value)}</option>)}
            </select>
          </div>
          <div>
            <label style={{ ...label, marginTop: 0 }}>{t('prospects.form.status')}</label>
            <select style={input} value={form.status} onChange={e => set('status', e.target.value)}>
              {STATUS_VALUES.map(s => <option key={s.value} value={s.value}>{t('status.' + s.value)}</option>)}
            </select>
          </div>
          <div>
            <label style={{ ...label, marginTop: 0 }}>{t('prospects.form.country')}</label>
            <input style={input} value={form.country || ''} onChange={e => set('country', e.target.value)} />
          </div>
          <div>
            <label style={{ ...label, marginTop: 0 }}>{t('prospects.form.ndaSigned')}</label>
            <select style={input} value={form.nda_signed} onChange={e => set('nda_signed', e.target.value)}>
              <option value="Non">{t('common.no')}</option>
              <option value="Oui">{t('common.yes')}</option>
            </select>
          </div>
        </div>

        <label style={label}>LinkedIn</label>
        <input style={input} value={form.linkedin || ''} onChange={e => set('linkedin', e.target.value)} placeholder="https://linkedin.com/in/..." />

        <label style={label}>{t('prospects.form.notes')}</label>
        <textarea style={{ ...input, height: 100, resize: 'vertical' }} value={form.notes || ''} onChange={e => set('notes', e.target.value)} placeholder={t('prospects.form.notesPH')} />

        <label style={label}>{t('prospects.form.nextAction')}</label>
        <input style={input} value={form.next_action || ''} onChange={e => set('next_action', e.target.value)} placeholder={t('prospects.form.nextActionPH')} />

        <label style={label}>{t('prospects.form.teaser')}</label>
        <textarea style={{ ...input, height: 80, resize: 'vertical' }} value={form.teaser || ''} onChange={e => set('teaser', e.target.value)} placeholder={t('prospects.form.teaserPH')} />

        <label style={label}>{t('prospects.form.source')}</label>
        <input style={input} value={form.source || ''} onChange={e => set('source', e.target.value)} placeholder={t('prospects.form.sourcePH')} />

        <label style={label}>📝 Compte-rendu brut</label>
        <textarea style={{ ...input, height: 120, resize: 'vertical' }} value={form.raw_transcript || ''} onChange={e => set('raw_transcript', e.target.value)} placeholder="Colle le transcript de la réunion ici..." />

        <label style={label}>📧 Brouillon email</label>
        <textarea style={{ ...input, height: 120, resize: 'vertical' }} value={form.email_draft || ''} onChange={e => set('email_draft', e.target.value)} placeholder="Le draft apparaîtra ici quand tu me demanderas de le préparer..." />

        <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end', marginTop: 20 }}>
          <button onClick={onClose} style={{ padding: '9px 18px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer' }}>{t('common.cancel')}</button>
          <button onClick={handleSave} style={{ padding: '9px 18px', borderRadius: 6, border: 'none', background: '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 700 }}>
            💾 {t('common.save')}
          </button>
        </div>
      </div>
    </div>
  )
}

export default function Prospects() {
  const { t } = useLang()
  const [data, setData] = useState([])
  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('')
  const [filterType, setFilterType] = useState('')
  const [selected, setSelected] = useState(null)
  const [editing, setEditing] = useState(null)
  const [loading, setLoading] = useState(true)

  const load = () => {
    setLoading(true)
    const params = {}
    if (search) params.search = search
    if (filterStatus) params.status = filterStatus
    if (filterType) params.type = filterType
    api.get('/prospects/', { params }).then(r => {
      setData(r.data)
      setLoading(false)
    })
  }

  useEffect(() => { load() }, [search, filterStatus, filterType])

  const handleDelete = async () => {
    if (!confirm(`${t('common.delete')} ${selected.company} ?`)) return
    await api.delete(`/prospects/${selected.id}`)
    setSelected(null)
    load()
  }

  const ndaCount = data.filter(d => d.nda_signed === 'Oui').length
  const inDiscussion = data.filter(d => ['in_discussion', 'meeting_scheduled', 'nda_signed', 'deal_in_progress'].includes(d.status)).length

  const th = { padding: '10px 12px', textAlign: 'left', fontSize: 11, color: '#6b7280', fontWeight: 700, textTransform: 'uppercase', borderBottom: '1px solid #e5e7eb', letterSpacing: 0.4 }
  const td = { padding: '12px', fontSize: 13, color: '#1f2937', borderBottom: '1px solid #f3f4f6' }

  return (
    <div style={{ display: 'flex', gap: 16, height: 'calc(100vh - 64px)' }}>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12, flexShrink: 0 }}>
          <div>
            <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1f2937' }}>{t('prospects.title')}</h1>
            <div style={{ fontSize: 13, color: '#6b7280', marginTop: 2 }}>
              {data.length} contacts · {inDiscussion} {t('status.in_discussion').toLowerCase()} · {ndaCount} NDA {t('status.nda_signed').toLowerCase()}
            </div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            <button onClick={async () => {
              const res = await api.get('/gmail/compose-draft')
              window.open(res.data.url, '_blank')
            }} style={{ padding: '9px 14px', background: '#fff', color: '#374151', border: '1px solid #d1d5db', borderRadius: 6, fontWeight: 600, cursor: 'pointer', flexShrink: 0, fontSize: 13 }}>
              📤
            </button>
            <button onClick={() => setEditing({})} style={{ padding: '9px 18px', background: '#2563eb', color: '#fff', border: 'none', borderRadius: 6, fontWeight: 700, cursor: 'pointer', flexShrink: 0 }}>
              {t('common.new')}
            </button>
          </div>
        </div>

        <div style={{ display: 'flex', gap: 8, marginBottom: 12, flexShrink: 0, flexWrap: 'wrap' }}>
          <input placeholder={t('common.search')} value={search} onChange={e => setSearch(e.target.value)}
            style={{ flex: 1, minWidth: 160, padding: '7px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13 }} />
          <select value={filterStatus} onChange={e => setFilterStatus(e.target.value)}
            style={{ padding: '7px 10px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13 }}>
            <option value="">{t('prospects.allStatuses')}</option>
            {STATUS_VALUES.map(s => <option key={s.value} value={s.value}>{t('status.' + s.value)}</option>)}
          </select>
          <select value={filterType} onChange={e => setFilterType(e.target.value)}
            style={{ padding: '7px 10px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13 }}>
            <option value="">{t('prospects.allTypes')}</option>
            {TYPE_VALUES.map(tp => <option key={tp.value} value={tp.value}>{t('type.' + tp.value)}</option>)}
          </select>
        </div>

        <div style={{ flex: 1, overflowY: 'auto', background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8 }}>
          {loading ? (
            <div style={{ padding: 60, textAlign: 'center', color: '#9ca3af' }}>{t('common.loading')}</div>
          ) : (
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead style={{ background: '#f9fafb', position: 'sticky', top: 0, zIndex: 1 }}>
                <tr>
                  <th style={th}>{t('prospects.col.company')}</th>
                  <th style={th}>{t('prospects.col.contact')}</th>
                  <th style={th}>{t('prospects.col.status')}</th>
                  <th style={th}>{t('prospects.col.nda')}</th>
                  <th style={th}>{t('prospects.col.nextAction')}</th>
                </tr>
              </thead>
              <tbody>
                {data.length === 0 ? (
                  <tr><td colSpan={5} style={{ ...td, textAlign: 'center', color: '#9ca3af', padding: 40 }}>{t('prospects.noData')}</td></tr>
                ) : data.map(p => (
                  <tr key={p.id}
                    onClick={() => setSelected(p)}
                    style={{ cursor: 'pointer', background: selected?.id === p.id ? '#eff6ff' : '#fff' }}
                    onMouseEnter={e => { if (selected?.id !== p.id) e.currentTarget.style.background = '#f9fafb' }}
                    onMouseLeave={e => { if (selected?.id !== p.id) e.currentTarget.style.background = '#fff' }}
                  >
                    <td style={{ ...td, fontWeight: 700 }}>{p.company}</td>
                    <td style={{ ...td, color: '#6b7280' }}>{p.contact_name || '—'}</td>
                    <td style={td}><StatusBadge value={p.status} /></td>
                    <td style={{ ...td, textAlign: 'center' }}>
                      {p.nda_signed === 'Oui' ? '✅' : <span style={{ color: '#d1d5db' }}>—</span>}
                    </td>
                    <td style={{ ...td, color: '#92400e', fontSize: 12, maxWidth: 200 }}>
                      {p.next_action ? (
                        <span style={{ display: '-webkit-box', WebkitLineClamp: 1, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                          {p.next_action}
                        </span>
                      ) : <span style={{ color: '#d1d5db' }}>—</span>}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {selected && (
        <div style={{
          width: 340, flexShrink: 0, background: '#fff', border: '1px solid #e5e7eb',
          borderRadius: 8, display: 'flex', flexDirection: 'column', overflow: 'hidden',
        }}>
          <ProspectDetail
            prospect={selected}
            onClose={() => setSelected(null)}
            onEdit={() => setEditing(selected)}
            onDelete={handleDelete}
          />
        </div>
      )}

      {editing !== null && (
        <EditModal
          prospect={editing.id ? editing : null}
          onClose={() => setEditing(null)}
          onSave={(updated) => {
            setEditing(null)
            load()
            if (selected?.id === updated?.id || !editing.id) setSelected(null)
          }}
        />
      )}
    </div>
  )
}
