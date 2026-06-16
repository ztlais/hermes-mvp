import { useEffect, useState } from 'react'
import api from '../api/client'
import { useLang } from '../context/LanguageContext'

const DOC_TYPES = [
  { value: 'nda',           label: 'NDA',           color: '#7c3aed', bg: '#ede9fe' },
  { value: 'fee_agreement', label: 'Fee Agreement', color: '#1e40af', bg: '#dbeafe' },
  { value: 'teaser',        label: 'Teaser',        color: '#065f46', bg: '#d1fae5' },
  { value: 'presentation',  label: 'Présentation',  color: '#92400e', bg: '#fef3c7' },
  { value: 'compte_rendu',  label: 'Compte Rendu',  color: '#0369a1', bg: '#e0f2fe' },
  { value: 'contract',      label: 'Contrat',       color: '#991b1b', bg: '#fee2e2' },
  { value: 'other',         label: 'Autre',         color: '#4b5563', bg: '#f3f4f6' },
]

function DocStyle(type) {
  return DOC_TYPES.find(d => d.value === type) || DOC_TYPES[DOC_TYPES.length - 1]
}

function DocumentsSection({ investorId }) {
  const { t } = useLang()
  const [docs, setDocs] = useState([])
  const [showForm, setShowForm] = useState(false)
  const [form, setForm] = useState({ name: '', url: '', doc_type: 'nda' })

  const load = () => api.get('/documents/', { params: { investor_id: investorId } }).then(r => setDocs(r.data))
  useEffect(() => { load() }, [investorId])

  const handleAdd = async () => {
    if (!form.name || !form.url) return
    await api.post('/documents/', { ...form, investor_id: investorId })
    setForm({ name: '', url: '', doc_type: 'nda' })
    setShowForm(false)
    load()
  }

  const handleDelete = async (id) => {
    await api.delete(`/documents/${id}`)
    load()
  }

  const inp = { width: '100%', padding: '7px 10px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 12, boxSizing: 'border-box', marginBottom: 6 }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', letterSpacing: 0.5 }}>
          {t('common.documents')}
        </div>
        <button onClick={() => setShowForm(!showForm)} style={{
          padding: '3px 10px', borderRadius: 5, border: '1px solid #d1d5db',
          background: '#fff', fontSize: 11, cursor: 'pointer', fontWeight: 600, color: '#374151',
        }}>{t('docs.add')}</button>
      </div>

      {docs.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginBottom: showForm ? 10 : 0 }}>
          {docs.map(doc => {
            const s = DocStyle(doc.doc_type)
            return (
              <div key={doc.id} style={{ display: 'flex', alignItems: 'center' }}>
                <a href={doc.url} target="_blank" rel="noreferrer" title={doc.name} style={{
                  padding: '4px 10px', borderRadius: '6px 0 0 6px',
                  background: s.bg, color: s.color, fontSize: 11, fontWeight: 700,
                  textDecoration: 'none', border: `1px solid ${s.color}30`, borderRight: 'none',
                  maxWidth: 130, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', display: 'block',
                }}>{doc.name}</a>
                <button onClick={() => handleDelete(doc.id)} style={{
                  padding: '4px 6px', borderRadius: '0 6px 6px 0',
                  background: s.bg, color: s.color, fontSize: 10,
                  border: `1px solid ${s.color}30`, cursor: 'pointer', lineHeight: 1,
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
        <div style={{ background: '#f9fafb', border: '1px solid #e5e7eb', borderRadius: 8, padding: 12, marginTop: 8 }}>
          <select value={form.doc_type} onChange={e => setForm(f => ({ ...f, doc_type: e.target.value }))} style={inp}>
            {DOC_TYPES.map(tp => <option key={tp.value} value={tp.value}>{tp.label}</option>)}
          </select>
          <input style={inp} placeholder="Nom (ex: NDA Electron Green)" value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))} />
          <input style={{ ...inp, marginBottom: 10 }} placeholder={t('docs.urlPH')} value={form.url} onChange={e => setForm(f => ({ ...f, url: e.target.value }))} />
          <div style={{ display: 'flex', gap: 6, justifyContent: 'flex-end' }}>
            <button onClick={() => setShowForm(false)} style={{ padding: '5px 12px', borderRadius: 5, border: '1px solid #d1d5db', background: '#fff', fontSize: 12, cursor: 'pointer' }}>{t('common.cancel')}</button>
            <button onClick={handleAdd} style={{ padding: '5px 12px', borderRadius: 5, border: 'none', background: '#2563eb', color: '#fff', fontSize: 12, cursor: 'pointer', fontWeight: 600 }}>{t('common.add')}</button>
          </div>
        </div>
      )}
    </div>
  )
}

const TECH_VALUES = ['solar','wind','offshore','bess','hydro','biomass','hybrid']
const COUNTRY_OPTIONS = [
  { value: 'FR', label: '🇫🇷 France' },
  { value: 'BE', label: '🇧🇪 Belgique' },
  { value: 'ES', label: '🇪🇸 Espagne' },
  { value: 'MA', label: '🇲🇦 Maroc' },
  { value: 'LU', label: '🇱🇺 Luxembourg' },
  { value: 'IT', label: '🇮🇹 Italie' },
  { value: 'DE', label: '🇩🇪 Allemagne' },
  { value: 'PT', label: '🇵🇹 Portugal' },
]
const STAGE_VALUES = ['development','permitting','rtb','construction','operational']
const DEAL_TYPE_VALUES = ['acquisition','co_development','financing','equity','ppa']
const INVESTOR_TYPE_VALUES = ['fund','family_office','ipp','corporate','other']

const STATUS_VALUES = [
  { value: 'to_contact',    color: '#6b7280', bg: '#f3f4f6' },
  { value: 'contacted',     color: '#1e40af', bg: '#dbeafe' },
  { value: 'in_discussion', color: '#92400e', bg: '#fef3c7' },
  { value: 'active',        color: '#065f46', bg: '#d1fae5' },
  { value: 'inactive',      color: '#4b5563', bg: '#f3f4f6' },
]

function CheckGroup({ options, selected = [], onChange, cols = 2 }) {
  const toggle = (val) => {
    const arr = selected.includes(val) ? selected.filter(v => v !== val) : [...selected, val]
    onChange(arr)
  }
  return (
    <div style={{ display: 'grid', gridTemplateColumns: `repeat(${cols}, 1fr)`, gap: 6 }}>
      {options.map(opt => (
        <label key={opt.value} style={{
          display: 'flex', alignItems: 'center', gap: 8, padding: '7px 10px',
          borderRadius: 6, border: `1.5px solid ${selected.includes(opt.value) ? '#2563eb' : '#e5e7eb'}`,
          background: selected.includes(opt.value) ? '#eff6ff' : '#fff',
          cursor: 'pointer', fontSize: 13, userSelect: 'none',
        }}>
          <input type="checkbox" checked={selected.includes(opt.value)} onChange={() => toggle(opt.value)}
            style={{ width: 14, height: 14, accentColor: '#2563eb' }} />
          {opt.label}
        </label>
      ))}
    </div>
  )
}

function StatusBadge({ value }) {
  const { t } = useLang()
  const s = STATUS_VALUES.find(o => o.value === value) || STATUS_VALUES[0]
  return (
    <span style={{ padding: '3px 10px', borderRadius: 10, fontSize: 11, fontWeight: 600, background: s.bg, color: s.color }}>
      {t('status.' + value)}
    </span>
  )
}

function TypeBadge({ value }) {
  const { t } = useLang()
  return (
    <span style={{ padding: '3px 10px', borderRadius: 10, fontSize: 11, fontWeight: 600, background: '#ede9fe', color: '#5b21b6' }}>
      {t('type.' + value) || value}
    </span>
  )
}

const toArr = (str) => str ? str.split(',').filter(Boolean) : []
const toStr = (arr) => arr.join(',')

function InvestorModal({ investor, onClose, onSave }) {
  const { t } = useLang()

  const TECHNOLOGIES = TECH_VALUES.map(v => ({ value: v, label: t('tech.' + v) }))
  const DEAL_STAGES = STAGE_VALUES.map(v => ({ value: v, label: t('stage.' + v) }))
  const DEAL_TYPES = DEAL_TYPE_VALUES.map(v => ({ value: v, label: t('deal.' + v) }))

  const [form, setForm] = useState({
    company: '', contact_name: '', email: '', phone: '', linkedin: '',
    type: 'fund', status: 'to_contact', country: '',
    technologies: [], target_countries: [], deal_stages: [], deal_types: [],
    min_mw: '', max_mw: '', min_ticket: '', max_ticket: '',
    criteria: '', notes: '', next_action: '',
    ...investor,
    technologies:     toArr(investor?.technologies),
    target_countries: toArr(investor?.target_countries),
    deal_stages:      toArr(investor?.deal_stages),
    deal_types:       toArr(investor?.deal_types),
  })

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))

  const handleSave = async () => {
    try {
      const payload = {
        ...form,
        technologies:     toStr(form.technologies),
        target_countries: toStr(form.target_countries),
        deal_stages:      toStr(form.deal_stages),
        deal_types:       toStr(form.deal_types),
        min_mw:     form.min_mw === '' ? null : Number(form.min_mw),
        max_mw:     form.max_mw === '' ? null : Number(form.max_mw),
        min_ticket: form.min_ticket === '' ? null : Number(form.min_ticket),
        max_ticket: form.max_ticket === '' ? null : Number(form.max_ticket),
      }
      if (investor?.id) await api.put(`/investors/${investor.id}`, payload)
      else await api.post('/investors/', payload)
      onSave()
    } catch { alert('Erreur lors de la sauvegarde') }
  }

  const input = { width: '100%', padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13, boxSizing: 'border-box' }
  const lbl = { display: 'block', fontSize: 12, fontWeight: 700, color: '#374151', marginBottom: 6, marginTop: 16, textTransform: 'uppercase', letterSpacing: 0.4 }
  const section = { background: '#f9fafb', border: '1px solid #e5e7eb', borderRadius: 8, padding: 16, marginTop: 12 }

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100, padding: 16 }}
      onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={{ background: '#fff', borderRadius: 12, padding: 28, width: 680, maxHeight: '92vh', overflowY: 'auto', boxShadow: '0 25px 60px rgba(0,0,0,0.2)' }}>

        <h2 style={{ fontSize: 18, fontWeight: 700, marginBottom: 4, color: '#1f2937' }}>
          {investor?.id ? t('investors.modal.editTitle') : t('investors.modal.newTitle')}
        </h2>
        <p style={{ fontSize: 13, color: '#9ca3af', marginBottom: 16 }}>{t('investors.modal.matchingHint')}</p>

        <div style={section}>
          <div style={{ fontSize: 12, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 12 }}>{t('investors.section.general')}</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <div>
              <label style={{ ...lbl, marginTop: 0 }}>{t('investors.form.company')}</label>
              <input style={input} value={form.company} onChange={e => set('company', e.target.value)} placeholder="ex: Ardian Infrastructure" />
            </div>
            <div>
              <label style={{ ...lbl, marginTop: 0 }}>{t('investors.form.type')}</label>
              <select style={input} value={form.type} onChange={e => set('type', e.target.value)}>
                {INVESTOR_TYPE_VALUES.map(v => <option key={v} value={v}>{t('type.' + v)}</option>)}
              </select>
            </div>
            <div>
              <label style={{ ...lbl, marginTop: 0 }}>{t('investors.form.contact')}</label>
              <input style={input} value={form.contact_name || ''} onChange={e => set('contact_name', e.target.value)} placeholder="Prénom Nom" />
            </div>
            <div>
              <label style={{ ...lbl, marginTop: 0 }}>Email</label>
              <input style={input} type="email" value={form.email || ''} onChange={e => set('email', e.target.value)} />
            </div>
            <div>
              <label style={{ ...lbl, marginTop: 0 }}>{t('investors.form.phone')}</label>
              <input style={input} value={form.phone || ''} onChange={e => set('phone', e.target.value)} />
            </div>
            <div>
              <label style={{ ...lbl, marginTop: 0 }}>{t('investors.form.status')}</label>
              <select style={input} value={form.status} onChange={e => set('status', e.target.value)}>
                {STATUS_VALUES.map(s => <option key={s.value} value={s.value}>{t('status.' + s.value)}</option>)}
              </select>
            </div>
          </div>
          <div style={{ marginTop: 10 }}>
            <label style={{ ...lbl, marginTop: 0 }}>LinkedIn</label>
            <input style={input} value={form.linkedin || ''} onChange={e => set('linkedin', e.target.value)} placeholder="https://linkedin.com/in/..." />
          </div>
        </div>

        <div style={section}>
          <div style={{ fontSize: 12, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 12 }}>{t('investors.section.technologies')}</div>
          <CheckGroup options={TECHNOLOGIES} selected={form.technologies} onChange={v => set('technologies', v)} cols={3} />
        </div>

        <div style={section}>
          <div style={{ fontSize: 12, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 12 }}>{t('investors.section.countries')}</div>
          <CheckGroup options={COUNTRY_OPTIONS} selected={form.target_countries} onChange={v => set('target_countries', v)} cols={4} />
        </div>

        <div style={section}>
          <div style={{ fontSize: 12, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 12 }}>{t('investors.section.stages')}</div>
          <CheckGroup options={DEAL_STAGES} selected={form.deal_stages} onChange={v => set('deal_stages', v)} cols={3} />
        </div>

        <div style={section}>
          <div style={{ fontSize: 12, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 12 }}>{t('investors.section.dealTypes')}</div>
          <CheckGroup options={DEAL_TYPES} selected={form.deal_types} onChange={v => set('deal_types', v)} cols={3} />
        </div>

        <div style={section}>
          <div style={{ fontSize: 12, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 12 }}>{t('investors.section.ticket')}</div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr', gap: 10 }}>
            {[['Min MW', 'min_mw'], ['Max MW', 'max_mw'], ['Min M€', 'min_ticket'], ['Max M€', 'max_ticket']].map(([l, k]) => (
              <div key={k}>
                <label style={{ ...lbl, marginTop: 0 }}>{l}</label>
                <input style={input} type="number" value={form[k] || ''} onChange={e => set(k, e.target.value)} placeholder="0" />
              </div>
            ))}
          </div>
        </div>

        <div style={section}>
          <div style={{ fontSize: 12, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 12 }}>{t('investors.section.notes')}</div>
          <label style={{ ...lbl, marginTop: 0 }}>{t('investors.form.criteria')}</label>
          <textarea style={{ ...input, height: 70, resize: 'vertical' }} value={form.criteria || ''} onChange={e => set('criteria', e.target.value)} placeholder={t('investors.form.criteriaPH')} />
          <label style={lbl}>{t('investors.form.notes')}</label>
          <textarea style={{ ...input, height: 60, resize: 'vertical' }} value={form.notes || ''} onChange={e => set('notes', e.target.value)} />
          <label style={lbl}>{t('investors.form.nextAction')}</label>
          <input style={input} value={form.next_action || ''} onChange={e => set('next_action', e.target.value)} placeholder={t('investors.form.nextActionPH')} />
        </div>

        <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end', marginTop: 20 }}>
          <button onClick={onClose} style={{ padding: '10px 20px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer', fontSize: 14 }}>{t('common.cancel')}</button>
          <button onClick={handleSave} style={{ padding: '10px 20px', borderRadius: 6, border: 'none', background: '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 700, fontSize: 14 }}>
            💾 {t('common.save')}
          </button>
        </div>

        {investor?.id && (
          <div style={{ marginTop: 20, padding: 16, background: '#f9fafb', border: '1px solid #e5e7eb', borderRadius: 8 }}>
            <DocumentsSection investorId={investor.id} />
          </div>
        )}
      </div>
    </div>
  )
}

function InvestorCard({ inv, onClick }) {
  const { t } = useLang()
  const techs = toArr(inv.technologies)
  const countries = toArr(inv.target_countries)
  const stages = toArr(inv.deal_stages)

  const completeness = [
    techs.length > 0,
    countries.length > 0,
    stages.length > 0,
    inv.min_mw || inv.max_mw,
    inv.email,
  ].filter(Boolean).length

  return (
    <div onClick={onClick} style={{
      background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, padding: 18,
      cursor: 'pointer', transition: 'all 0.15s',
    }}
      onMouseEnter={e => e.currentTarget.style.boxShadow = '0 4px 12px rgba(0,0,0,0.08)'}
      onMouseLeave={e => e.currentTarget.style.boxShadow = 'none'}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 }}>
        <div>
          <div style={{ fontWeight: 700, fontSize: 15, color: '#1f2937' }}>{inv.company}</div>
          {inv.contact_name && <div style={{ fontSize: 12, color: '#6b7280', marginTop: 2 }}>{inv.contact_name}</div>}
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 4 }}>
          <StatusBadge value={inv.status} />
          <TypeBadge value={inv.type} />
        </div>
      </div>

      {techs.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4, marginBottom: 8 }}>
          {techs.map(tech => (
            <span key={tech} style={{ padding: '2px 8px', background: '#fef3c7', color: '#92400e', borderRadius: 8, fontSize: 11, fontWeight: 600 }}>
              {t('tech.' + tech) || tech}
            </span>
          ))}
        </div>
      )}

      {countries.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4, marginBottom: 8 }}>
          {countries.map(c => {
            const co = COUNTRY_OPTIONS.find(o => o.value === c)
            return (
              <span key={c} style={{ padding: '2px 8px', background: '#dbeafe', color: '#1e40af', borderRadius: 8, fontSize: 11, fontWeight: 600 }}>
                {co?.label || c}
              </span>
            )
          })}
        </div>
      )}

      <div style={{ display: 'flex', gap: 12, fontSize: 12, color: '#6b7280', marginTop: 8 }}>
        {(inv.min_mw || inv.max_mw) && (
          <span>⚡ {inv.min_mw || '?'}–{inv.max_mw || '?'} MW</span>
        )}
        {stages.length > 0 && (
          <span>📊 {stages.map(s => t('stage.' + s)?.split(' ')[1] || s).join(', ')}</span>
        )}
      </div>

      <div style={{ marginTop: 10 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 10, color: '#9ca3af', marginBottom: 3 }}>
          <span>{t('investors.profileComplete')}</span>
          <span>{completeness * 20}%</span>
        </div>
        <div style={{ height: 4, background: '#f3f4f6', borderRadius: 2 }}>
          <div style={{ height: '100%', borderRadius: 2, width: `${completeness * 20}%`, background: completeness >= 4 ? '#16a34a' : completeness >= 2 ? '#f59e0b' : '#ef4444' }} />
        </div>
      </div>
    </div>
  )
}

export default function Investors() {
  const { t } = useLang()
  const [data, setData] = useState([])
  const [search, setSearch] = useState('')
  const [filterStatus, setFilterStatus] = useState('')
  const [filterType, setFilterType] = useState('')
  const [modal, setModal] = useState(null)
  const [loading, setLoading] = useState(true)
  const [view, setView] = useState('grid')

  const load = () => {
    setLoading(true)
    const params = {}
    if (search) params.search = search
    if (filterStatus) params.status = filterStatus
    if (filterType) params.type = filterType
    api.get('/investors/', { params }).then(r => { setData(r.data); setLoading(false) })
  }

  useEffect(() => { load() }, [search, filterStatus, filterType])

  const handleDelete = async (id) => {
    if (!confirm(t('investors.deleteConfirm') || 'Supprimer cet investisseur ?')) return
    await api.delete(`/investors/${id}`)
    setModal(null)
    load()
  }

  const activeCount = data.filter(i => i.status === 'active').length
  const withTechCount = data.filter(i => i.technologies).length

  const TABLE_HEADERS = [
    t('investors.col.company'), t('investors.col.type'), t('investors.col.status'),
    t('investors.col.technologies'), t('investors.col.countries'), t('investors.col.mw'), t('investors.col.profile'),
  ]

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1f2937' }}>{t('investors.title')}</h1>
          <div style={{ fontSize: 13, color: '#6b7280', marginTop: 2 }}>
            {data.length} {t('nav.investors').toLowerCase()} · {activeCount} {t('status.active').toLowerCase()} · {withTechCount} {t('investors.modal.matchingHint').split(' ').slice(0, 2).join(' ')}...
          </div>
        </div>
        <div style={{ display: 'flex', gap: 10, alignItems: 'center' }}>
          <div style={{ background: '#f3f4f6', borderRadius: 6, display: 'flex', padding: 2 }}>
            {['grid', 'table'].map(v => (
              <button key={v} onClick={() => setView(v)} style={{
                padding: '5px 12px', borderRadius: 4, border: 'none', cursor: 'pointer', fontSize: 13,
                background: view === v ? '#fff' : 'transparent',
                color: view === v ? '#1f2937' : '#6b7280',
                boxShadow: view === v ? '0 1px 3px rgba(0,0,0,0.1)' : 'none',
              }}>
                {v === 'grid' ? t('investors.viewGrid') : t('investors.viewTable')}
              </button>
            ))}
          </div>
          <button onClick={() => setModal({})} style={{ padding: '9px 18px', background: '#2563eb', color: '#fff', border: 'none', borderRadius: 6, fontWeight: 600, cursor: 'pointer' }}>
            {t('investors.new')}
          </button>
        </div>
      </div>

      <div style={{ display: 'flex', gap: 10, marginBottom: 20, flexWrap: 'wrap' }}>
        <input placeholder={`🔍 ${t('common.search').replace('🔍 ', '')}`} value={search} onChange={e => setSearch(e.target.value)}
          style={{ flex: 1, minWidth: 200, padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 14 }} />
        <select value={filterStatus} onChange={e => setFilterStatus(e.target.value)}
          style={{ padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 14 }}>
          <option value="">{t('investors.allStatuses')}</option>
          {STATUS_VALUES.map(s => <option key={s.value} value={s.value}>{t('status.' + s.value)}</option>)}
        </select>
        <select value={filterType} onChange={e => setFilterType(e.target.value)}
          style={{ padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 14 }}>
          <option value="">{t('investors.allTypes')}</option>
          {INVESTOR_TYPE_VALUES.map(v => <option key={v} value={v}>{t('type.' + v)}</option>)}
        </select>
      </div>

      {loading ? (
        <div style={{ padding: 60, textAlign: 'center', color: '#6b7280' }}>{t('common.loading')}</div>
      ) : view === 'grid' ? (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 14 }}>
          {data.length === 0 ? (
            <div style={{ gridColumn: '1/-1', textAlign: 'center', padding: 60, color: '#9ca3af' }}>{t('investors.noData')}</div>
          ) : data.map(inv => (
            <InvestorCard key={inv.id} inv={inv} onClick={() => setModal(inv)} />
          ))}
        </div>
      ) : (
        <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8, overflow: 'hidden' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead style={{ background: '#f9fafb' }}>
              <tr>
                {TABLE_HEADERS.map(h => (
                  <th key={h} style={{ padding: '10px 12px', textAlign: 'left', fontSize: 11, color: '#6b7280', fontWeight: 600, textTransform: 'uppercase', borderBottom: '1px solid #e5e7eb' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {data.map(inv => {
                const techs = toArr(inv.technologies)
                const countries = toArr(inv.target_countries)
                const completeness = [techs.length > 0, countries.length > 0, toArr(inv.deal_stages).length > 0, inv.min_mw || inv.max_mw, inv.email].filter(Boolean).length
                return (
                  <tr key={inv.id} onClick={() => setModal(inv)} style={{ cursor: 'pointer', borderBottom: '1px solid #f3f4f6' }}
                    onMouseEnter={e => e.currentTarget.style.background = '#f9fafb'}
                    onMouseLeave={e => e.currentTarget.style.background = '#fff'}>
                    <td style={{ padding: '12px', fontWeight: 600 }}>{inv.company}</td>
                    <td style={{ padding: '12px' }}><TypeBadge value={inv.type} /></td>
                    <td style={{ padding: '12px' }}><StatusBadge value={inv.status} /></td>
                    <td style={{ padding: '12px', fontSize: 12 }}>{techs.map(t2 => t('tech.' + t2) || t2).join(', ') || '—'}</td>
                    <td style={{ padding: '12px', fontSize: 12 }}>{countries.join(', ') || '—'}</td>
                    <td style={{ padding: '12px', fontSize: 12 }}>{inv.min_mw || inv.max_mw ? `${inv.min_mw || '?'}–${inv.max_mw || '?'}` : '—'}</td>
                    <td style={{ padding: '12px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                        <div style={{ flex: 1, height: 6, background: '#f3f4f6', borderRadius: 3 }}>
                          <div style={{ height: '100%', borderRadius: 3, width: `${completeness * 20}%`, background: completeness >= 4 ? '#16a34a' : '#f59e0b' }} />
                        </div>
                        <span style={{ fontSize: 11, color: '#9ca3af' }}>{completeness * 20}%</span>
                      </div>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      )}

      {modal !== null && (
        <InvestorModal
          investor={modal.id ? modal : null}
          onClose={() => setModal(null)}
          onSave={() => { setModal(null); load() }}
        />
      )}
    </div>
  )
}
