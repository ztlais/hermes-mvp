import { useEffect, useState } from 'react'
import api from '../api/client'
import { useLang } from '../context/LanguageContext'

const TYPE_KEYS = ['financement', 'levee', 'co_dev', 'cession', 'ppa', 'autre']
const STATUS_KEYS = ['en_discussion', 'offre_envoyee', 'term_sheet', 'signe', 'perdu']

const TYPE_COLORS = {
  financement: '#2563eb', levee: '#7c3aed', co_dev: '#0891b2',
  cession: '#16a34a', ppa: '#d97706', autre: '#6b7280',
}
const STATUS_COLORS = {
  en_discussion: { bg: '#eff6ff', text: '#2563eb' },
  offre_envoyee: { bg: '#f5f3ff', text: '#7c3aed' },
  term_sheet:    { bg: '#fff7ed', text: '#d97706' },
  signe:         { bg: '#f0fdf4', text: '#16a34a' },
  perdu:         { bg: '#fef2f2', text: '#dc2626' },
}

const EMPTY_FORM = {
  title: '', type: 'financement', status: 'en_discussion',
  country: '', size_eur: '', size_mw: '', deadline: '', notes: '', notes_en: '', title_en: '', prospect_id: '',
}

function StatusBadge({ status, t }) {
  const c = STATUS_COLORS[status] || { bg: '#f3f4f6', text: '#6b7280' }
  return (
    <span style={{ fontSize: 11, fontWeight: 600, padding: '3px 8px', borderRadius: 20, background: c.bg, color: c.text }}>
      {t(`opp.status.${status}`) || status}
    </span>
  )
}

function TypeDot({ type, t }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, fontSize: 12, color: TYPE_COLORS[type] || '#6b7280', fontWeight: 600 }}>
      {t(`opp.type.${type}`) || type}
    </span>
  )
}

function formatDeadline(iso, t) {
  if (!iso) return null
  const d = new Date(iso)
  const now = new Date()
  const diff = Math.ceil((d - now) / (1000 * 60 * 60 * 24))
  const label = d.toLocaleDateString(t('opp.deadline.locale'), { day: 'numeric', month: 'short', year: 'numeric' })
  const prefix = t('opp.deadline.prefix')
  let urgency = null
  if (diff < 0) urgency = { text: t('opp.deadline.overdue'), color: '#dc2626' }
  else if (diff <= 30) urgency = { text: `${prefix}${diff}`, color: '#d97706' }
  else if (diff <= 90) urgency = { text: `${prefix}${diff}`, color: '#2563eb' }
  return { label, urgency }
}

export default function Opportunities() {
  const { t, lang } = useLang()
  const [opps, setOpps] = useState([])
  const [prospects, setProspects] = useState([])
  const [loading, setLoading] = useState(true)
  const [modal, setModal] = useState(null)
  const [form, setForm] = useState(EMPTY_FORM)
  const [saving, setSaving] = useState(false)
  const [filterStatus, setFilterStatus] = useState('')
  const [filterType, setFilterType] = useState('')
  const [filterCountry, setFilterCountry] = useState('')
  const [selected, setSelected] = useState(null)

  const load = () => {
    setLoading(true)
    Promise.all([
      api.get('/opportunities/'),
      api.get('/prospects/'),
    ]).then(([o, p]) => {
      setOpps(o.data)
      setProspects(p.data)
    }).finally(() => setLoading(false))
  }

  useEffect(() => { load() }, [])

  const openNew = () => { setForm(EMPTY_FORM); setModal('new') }

  const openEdit = (opp) => {
    setForm({
      title: opp.title || '',
      title_en: opp.title_en || '',
      type: opp.type || 'financement',
      status: opp.status || 'en_discussion',
      country: opp.country || '',
      size_eur: opp.size_eur ?? '',
      size_mw: opp.size_mw ?? '',
      deadline: opp.deadline ? opp.deadline.slice(0, 10) : '',
      notes: opp.notes || '',
      notes_en: opp.notes_en || '',
      prospect_id: opp.prospect_id ?? '',
    })
    setModal(opp)
  }

  const handleSave = async () => {
    if (!form.title.trim()) return
    setSaving(true)
    const { notes_en: _, title_en: __, ...formData } = form
    const payload = {
      ...formData,
      notes_en: null,
      title_en: null,
      size_eur: form.size_eur !== '' ? parseFloat(form.size_eur) : null,
      size_mw: form.size_mw !== '' ? parseFloat(form.size_mw) : null,
      prospect_id: form.prospect_id !== '' ? parseInt(form.prospect_id) : null,
      deadline: form.deadline || null,
    }
    try {
      if (modal === 'new') await api.post('/opportunities/', payload)
      else await api.put(`/opportunities/${modal.id}`, payload)
      setModal(null)
      load()
    } finally {
      setSaving(false)
    }
  }

  const handleDelete = async (id) => {
    if (!confirm(t('opp.delete.confirm'))) return
    await api.delete(`/opportunities/${id}`)
    setSelected(null)
    load()
  }

  const countries = [...new Set(opps.map(o => o.country).filter(Boolean))].sort()

  const filtered = opps.filter(o =>
    (!filterStatus || o.status === filterStatus) &&
    (!filterType || o.type === filterType) &&
    (!filterCountry || o.country === filterCountry)
  )

  const signedCount = opps.filter(o => o.status === 'signe').length
  const sel = selected ? opps.find(o => o.id === selected) : null

  return (
    <div key={lang} style={{ maxWidth: 1200 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
        <div>
          <h1 style={{ fontSize: 20, fontWeight: 700, color: '#1f2937', marginBottom: 2 }}>{t('opp.title')}</h1>
          <p style={{ fontSize: 13, color: '#6b7280' }}>
            {opps.length} {opps.length !== 1 ? t('opp.subtitle.other') : t('opp.subtitle.one')} · {signedCount} {signedCount !== 1 ? t('opp.subtitle.signed.other') : t('opp.subtitle.signed')}
          </p>
        </div>
        <button onClick={openNew} style={{ background: '#059669', color: '#fff', border: 'none', borderRadius: 8, padding: '9px 18px', fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>
          {t('opp.new')}
        </button>
      </div>

      {/* Filters */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 16, flexWrap: 'wrap' }}>
        <select value={filterStatus} onChange={e => setFilterStatus(e.target.value)}
          style={{ padding: '7px 12px', borderRadius: 8, border: '1px solid #e5e7eb', fontSize: 13, background: '#fff', cursor: 'pointer' }}>
          <option value="">{t('opp.allStatuses')}</option>
          {STATUS_KEYS.map(k => <option key={k} value={k}>{t(`opp.status.${k}`)}</option>)}
        </select>
        <select value={filterType} onChange={e => setFilterType(e.target.value)}
          style={{ padding: '7px 12px', borderRadius: 8, border: '1px solid #e5e7eb', fontSize: 13, background: '#fff', cursor: 'pointer' }}>
          <option value="">{t('opp.allTypes')}</option>
          {TYPE_KEYS.map(k => <option key={k} value={k}>{t(`opp.type.${k}`)}</option>)}
        </select>
        <select value={filterCountry} onChange={e => setFilterCountry(e.target.value)}
          style={{ padding: '7px 12px', borderRadius: 8, border: '1px solid #e5e7eb', fontSize: 13, background: '#fff', cursor: 'pointer' }}>
          <option value="">🌍 {t('opp.allCountries')}</option>
          {countries.map(c => <option key={c} value={c}>📍 {c}</option>)}
        </select>
        {(filterStatus || filterType || filterCountry) && (
          <button onClick={() => { setFilterStatus(''); setFilterType(''); setFilterCountry('') }}
            style={{ padding: '7px 12px', borderRadius: 8, border: '1px solid #e5e7eb', fontSize: 13, background: '#fff', cursor: 'pointer', color: '#6b7280' }}>
            {t('opp.clearFilters')}
          </button>
        )}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: sel ? '1fr 380px' : '1fr', gap: 16 }}>
        {/* List */}
        <div>
          {loading ? (
            <div style={{ color: '#9ca3af', fontSize: 14, padding: 20 }}>{t('opp.loading')}</div>
          ) : filtered.length === 0 ? (
            <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, padding: 40, textAlign: 'center', color: '#9ca3af', fontSize: 14 }}>
              {t('opp.empty')}
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              {filtered.map(opp => {
                const dl = formatDeadline(opp.deadline, t)
                const isActive = selected === opp.id
                return (
                  <div key={opp.id} onClick={() => setSelected(isActive ? null : opp.id)}
                    style={{
                      background: '#fff', border: `1px solid ${isActive ? '#059669' : '#e5e7eb'}`,
                      borderLeft: `4px solid ${TYPE_COLORS[opp.type] || '#9ca3af'}`,
                      borderRadius: 10, padding: '14px 18px', cursor: 'pointer',
                      transition: 'all 0.15s',
                    }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 12 }}>
                      <div style={{ flex: 1, minWidth: 0 }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 5, flexWrap: 'wrap' }}>
                          <span style={{ fontSize: 14, fontWeight: 600, color: '#1f2937' }}>{lang === 'en' ? (opp.title_en || opp.title) : opp.title}</span>
                          <StatusBadge status={opp.status} t={t} />
                        </div>
                        <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', alignItems: 'center' }}>
                          <TypeDot type={opp.type} t={t} />
                          {opp.prospect_name && <span style={{ fontSize: 12, color: '#6b7280' }}>👤 {opp.prospect_name}</span>}
                          {opp.country && <span style={{ fontSize: 12, color: '#6b7280' }}>📍 {opp.country}</span>}
                        </div>
                      </div>
                      <div style={{ textAlign: 'right', flexShrink: 0 }}>
                        {opp.size_eur && <div style={{ fontSize: 15, fontWeight: 700, color: '#1f2937' }}>{opp.size_eur}M€</div>}
                        {opp.size_mw && <div style={{ fontSize: 12, color: '#6b7280' }}>{opp.size_mw} MW</div>}
                        {dl && (
                          <div style={{ fontSize: 11, marginTop: 3 }}>
                            <span style={{ color: dl.urgency?.color || '#9ca3af', fontWeight: dl.urgency ? 700 : 400 }}>
                              {dl.urgency ? dl.urgency.text + ' · ' : ''}{dl.label}
                            </span>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </div>

        {/* Detail panel */}
        {sel && (
          <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, padding: 20, alignSelf: 'start', position: 'sticky', top: 20 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
              <h3 style={{ fontSize: 15, fontWeight: 700, color: '#1f2937', margin: 0 }}>{lang === 'en' ? (sel.title_en || sel.title) : sel.title}</h3>
              <button onClick={() => setSelected(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#9ca3af', fontSize: 18 }}>✕</button>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginBottom: 16 }}>
              <Row label={t('opp.detail.status')}><StatusBadge status={sel.status} t={t} /></Row>
              <Row label={t('opp.detail.type')}><TypeDot type={sel.type} t={t} /></Row>
              {sel.prospect_name && <Row label={t('opp.detail.prospect')}>{sel.prospect_name}</Row>}
              {sel.country && <Row label={t('opp.detail.country')}>📍 {sel.country}</Row>}
              {sel.size_eur && <Row label={t('opp.detail.amount')}><b>{sel.size_eur}M€</b></Row>}
              {sel.size_mw && <Row label={t('opp.detail.capacity')}>{sel.size_mw} MW</Row>}
              {sel.deadline && (() => {
                const dl = formatDeadline(sel.deadline, t)
                return <Row label={t('opp.detail.deadline')}><span style={{ color: dl?.urgency?.color }}>{dl?.label}{dl?.urgency ? ` (${dl.urgency.text})` : ''}</span></Row>
              })()}
            </div>
            {(() => {
              const displayNotes = lang === 'en' ? (sel.notes_en || sel.notes) : sel.notes
              const needsTranslation = lang === 'en' && !sel.notes_en && sel.notes
              const wasTranslated = lang === 'en' && sel.notes_en
              return displayNotes && (
                <div>
                  <div style={{ background: '#f9fafb', borderRadius: 8, padding: 12, fontSize: 13, color: '#374151', lineHeight: 1.6, marginBottom: 8, whiteSpace: 'pre-wrap' }}>
                    {displayNotes}
                  </div>
                  {needsTranslation && (
                    <button onClick={async () => {
                      try {
                        await api.post(`/opportunities/${sel.id}/translate-notes`)
                        load()
                      } catch(e) {}
                    }}
                      style={{ padding: '6px 14px', borderRadius: 8, border: '1px solid #e5e7eb', background: '#eff6ff', fontSize: 12, cursor: 'pointer', color: '#2563eb', marginBottom: 8, fontWeight: 500 }}>
                      🌐 Traduire en anglais
                    </button>
                  )}
                  {wasTranslated && (
                    <div style={{ fontSize: 11, color: '#9ca3af', marginBottom: 8, fontStyle: 'italic' }}>
                      🇫🇷→🇬🇧 Traduit automatiquement
                    </div>
                  )}
                </div>
              )
            })()}
            <div style={{ display: 'flex', gap: 8 }}>
              <button onClick={() => openEdit(sel)}
                style={{ flex: 1, padding: '8px', borderRadius: 8, border: '1px solid #e5e7eb', background: '#fff', fontSize: 13, cursor: 'pointer', fontWeight: 500 }}>
                {t('opp.detail.edit')}
              </button>
              <button onClick={() => handleDelete(sel.id)}
                style={{ padding: '8px 14px', borderRadius: 8, border: '1px solid #fecaca', background: '#fef2f2', fontSize: 13, cursor: 'pointer', color: '#dc2626' }}>
                🗑
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Modal */}
      {modal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)', zIndex: 200, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 16 }}>
          <div style={{ background: '#fff', borderRadius: 12, padding: 28, width: '100%', maxWidth: 520, maxHeight: '90vh', overflowY: 'auto' }}>
            <h2 style={{ fontSize: 16, fontWeight: 700, marginBottom: 20, color: '#1f2937' }}>
              {modal === 'new' ? t('opp.modal.new') : t('opp.modal.edit')}
            </h2>
            <Field label={t('opp.form.title')}>
              <input value={form.title} onChange={e => setForm(f => ({ ...f, title: e.target.value }))}
                placeholder={t('opp.form.title.ph')} style={inputStyle} />
            </Field>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              <Field label={t('opp.form.type')}>
                <select value={form.type} onChange={e => setForm(f => ({ ...f, type: e.target.value }))} style={inputStyle}>
                  {TYPE_KEYS.map(k => <option key={k} value={k}>{t(`opp.type.${k}`)}</option>)}
                </select>
              </Field>
              <Field label={t('opp.form.status')}>
                <select value={form.status} onChange={e => setForm(f => ({ ...f, status: e.target.value }))} style={inputStyle}>
                  {STATUS_KEYS.map(k => <option key={k} value={k}>{t(`opp.status.${k}`)}</option>)}
                </select>
              </Field>
            </div>
            <Field label={t('opp.form.prospect')}>
              <select value={form.prospect_id} onChange={e => setForm(f => ({ ...f, prospect_id: e.target.value }))} style={inputStyle}>
                <option value="">{t('opp.form.prospect.none')}</option>
                {prospects.map(p => <option key={p.id} value={p.id}>{p.company}</option>)}
              </select>
            </Field>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 }}>
              <Field label={t('opp.form.country')}>
                <input value={form.country} onChange={e => setForm(f => ({ ...f, country: e.target.value }))}
                  placeholder={t('opp.form.country.ph')} style={inputStyle} />
              </Field>
              <Field label={t('opp.form.sizeEur')}>
                <input type="number" value={form.size_eur} onChange={e => setForm(f => ({ ...f, size_eur: e.target.value }))}
                  placeholder="1.7" style={inputStyle} />
              </Field>
              <Field label={t('opp.form.sizeMw')}>
                <input type="number" value={form.size_mw} onChange={e => setForm(f => ({ ...f, size_mw: e.target.value }))}
                  placeholder="5" style={inputStyle} />
              </Field>
            </div>
            <Field label={t('opp.form.deadline')}>
              <input type="date" value={form.deadline} onChange={e => setForm(f => ({ ...f, deadline: e.target.value }))} style={inputStyle} />
            </Field>
            <Field label={t('opp.form.notes')}>
              <textarea value={form.notes} onChange={e => setForm(f => ({ ...f, notes: e.target.value }))}
                rows={4} placeholder={t('opp.form.notes.ph')}
                style={{ ...inputStyle, resize: 'vertical' }} />
            </Field>
            <div style={{ display: 'flex', gap: 10, marginTop: 20 }}>
              <button onClick={() => setModal(null)}
                style={{ flex: 1, padding: '10px', borderRadius: 8, border: '1px solid #e5e7eb', background: '#fff', fontSize: 14, cursor: 'pointer' }}>
                {t('common.cancel')}
              </button>
              <button onClick={handleSave} disabled={saving || !form.title.trim()}
                style={{ flex: 2, padding: '10px', borderRadius: 8, border: 'none', background: saving || !form.title.trim() ? '#a7f3d0' : '#059669', color: '#fff', fontSize: 14, fontWeight: 600, cursor: saving || !form.title.trim() ? 'not-allowed' : 'pointer' }}>
                {saving ? t('opp.form.saving') : t('opp.form.save')}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function Row({ label, children }) {
  return (
    <div style={{ display: 'flex', gap: 8, alignItems: 'center', fontSize: 13 }}>
      <span style={{ color: '#9ca3af', minWidth: 70 }}>{label}</span>
      <span style={{ color: '#1f2937' }}>{children}</span>
    </div>
  )
}

function Field({ label, children }) {
  return (
    <div style={{ marginBottom: 14 }}>
      <label style={{ display: 'block', fontSize: 12, fontWeight: 600, color: '#374151', marginBottom: 5 }}>{label}</label>
      {children}
    </div>
  )
}

const inputStyle = {
  width: '100%', padding: '9px 12px', border: '1px solid #e5e7eb',
  borderRadius: 8, fontSize: 13, boxSizing: 'border-box', outline: 'none',
}
