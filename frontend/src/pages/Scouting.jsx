import { useEffect, useState } from 'react'
import api from '../api/client'
import { useLang } from '../context/LanguageContext'

const STATUS_VALUES = ['to_contact','email_sent','linkedin_sent','responded','meeting_done','converted','no_response','not_interested']
const STATUS_STYLES = {
  to_contact:     { color: '#6b7280', bg: '#f9fafb', border: '#e5e7eb' },
  email_sent:     { color: '#1e40af', bg: '#eff6ff', border: '#bfdbfe' },
  linkedin_sent:  { color: '#5b21b6', bg: '#f5f3ff', border: '#ddd6fe' },
  responded:      { color: '#065f46', bg: '#f0fdf4', border: '#bbf7d0' },
  meeting_done:   { color: '#92400e', bg: '#fffbeb', border: '#fde68a' },
  converted:      { color: '#065f46', bg: '#d1fae5', border: '#6ee7b7' },
  no_response:    { color: '#c2410c', bg: '#fff7ed', border: '#fed7aa' },
  not_interested: { color: '#991b1b', bg: '#fff1f2', border: '#fecdd3' },
}

const TYPE_BADGE_STYLES = {
  developer:    { bg: '#dbeafe', color: '#1e40af' },
  investor:     { bg: '#fef3c7', color: '#92400e' },
  ipp:          { bg: '#cffafe', color: '#155e75' },
  family_office:{ bg: '#ede9fe', color: '#5b21b6' },
}
const TYPE_VALUES = ['developer', 'investor', 'ipp', 'family_office']
const COUNTRY_OPTIONS = ['FR', 'BE', 'ES']

const getLang = (country) => ['FR', 'BE'].includes(country?.toUpperCase()) ? 'fr' : 'en'
const getFirstName = (name) => name?.split(' ')[0] || ''
const personalize = (body, item) => {
  const prenom = getFirstName(item.contact_name)
  return (body || '')
    .replace(/\[Prénom\]/g, prenom)
    .replace(/\[Name\]/g, prenom)
    .replace(/\[Société\]/g, item.company || '')
    .replace(/\[Company\]/g, item.company || '')
}

function TypeBadge({ type }) {
  const { t } = useLang()
  const styles = TYPE_BADGE_STYLES[type] || { bg: '#f3f4f6', color: '#4b5563' }
  const shortLabels = { developer: 'Dev', investor: 'Invest.', ipp: 'IPP', family_office: 'Family' }
  return (
    <span style={{ padding: '2px 7px', borderRadius: 8, fontSize: 10, fontWeight: 700, background: styles.bg, color: styles.color }}>
      {shortLabels[type] || type}
    </span>
  )
}

function Tab({ label, active, onClick, count }) {
  return (
    <button onClick={onClick} style={{
      padding: '6px 14px', border: 'none', borderRadius: 6, cursor: 'pointer',
      fontSize: 12, fontWeight: 600,
      background: active ? '#1f2937' : '#f3f4f6',
      color: active ? '#fff' : '#6b7280',
    }}>
      {label}{count != null ? ` (${count})` : ''}
    </button>
  )
}

function CardModal({ item, onClose, onSave, onDelete }) {
  const { t } = useLang()
  const [form, setForm] = useState({ ...item })
  const [templates, setTemplates] = useState([])
  const [activeStep, setActiveStep] = useState(
    ['responded', 'meeting_done', 'converted'].includes(item.status) ? 2 : 1
  )
  const [activeChannel, setActiveChannel] = useState('linkedin')
  const [messageText, setMessageText] = useState('')
  const [copied, setCopied] = useState(false)

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))
  const lang = getLang(form.country)

  useEffect(() => {
    api.get('/templates/', { params: { target: form.type, language: lang, step: activeStep } })
      .then(r => setTemplates(r.data))
      .catch(() => {})
  }, [form.type, lang, activeStep])

  const currentTemplate = templates.find(tp => tp.type === activeChannel && tp.step === activeStep)

  useEffect(() => {
    if (currentTemplate) {
      setMessageText(personalize(currentTemplate.body, form))
    } else {
      setMessageText('')
    }
  }, [currentTemplate?.id, form.contact_name, form.company])

  const handleCopy = () => {
    let text = messageText
    if (activeChannel === 'email' && currentTemplate?.subject) {
      const subj = personalize(currentTemplate.subject, form)
      text = `${t('scouting.subject')} ${subj}\n\n${messageText}`
    }
    navigator.clipboard.writeText(text)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  const handleSave = async () => {
    await api.put(`/scouting/${item.id}`, form)
    onSave()
  }

  const handleDelete = async () => {
    if (!confirm(`${t('common.delete')} ${item.company} ?`)) return
    await api.delete(`/scouting/${item.id}`)
    onDelete()
  }

  const handleConvertToProspect = async () => {
    if (!confirm(`${t('scouting.addToProspects').replace('🚀 ', '')} "${item.company}" ?`)) return
    try {
      await api.post('/prospects/', {
        company: item.company,
        contact_name: item.contact_name || '',
        email: item.email || '',
        linkedin: item.linkedin || '',
        country: item.country || 'FR',
        type: item.type === 'ipp' ? 'ipp' : item.type === 'investor' ? 'investor' : item.type === 'family_office' ? 'family_office' : 'developer',
        status: 'contacted',
        notes: item.notes || '',
      })
      await api.put(`/scouting/${item.id}`, { ...form, status: 'converted' })
      onSave()
    } catch {
      alert(t('scouting.convertError') || 'Erreur lors de la conversion')
    }
  }

  const hasStep2 = templates.some(tp => tp.step === 2)
  const charCount = messageText.length
  const charLimit = lang === 'fr' ? 300 : 280
  const isStep1LinkedIn = activeChannel === 'linkedin' && activeStep === 1
  const charOverLimit = isStep1LinkedIn && charCount > charLimit
  const colStyle = STATUS_STYLES[form.status] || STATUS_STYLES.to_contact

  const inp = { width: '100%', padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13, boxSizing: 'border-box' }
  const lbl = { display: 'block', fontSize: 11, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 4, marginTop: 14 }

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100, padding: 16 }}
      onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={{ background: '#fff', borderRadius: 12, width: 520, maxHeight: '92vh', overflowY: 'auto', boxShadow: '0 25px 60px rgba(0,0,0,0.2)', display: 'flex', flexDirection: 'column' }}>

        <div style={{ padding: '20px 24px 16px', borderBottom: '1px solid #f3f4f6', flexShrink: 0 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div style={{ flex: 1 }}>
              <h2 style={{ fontSize: 17, fontWeight: 700, color: '#1f2937', margin: 0 }}>{item.company}</h2>
              <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginTop: 6 }}>
                <TypeBadge type={item.type} />
                <span style={{ fontSize: 12, color: '#9ca3af' }}>{item.country}</span>
                <span style={{ fontSize: 11, fontWeight: 600, color: colStyle.color, background: colStyle.bg, border: `1px solid ${colStyle.border}`, padding: '1px 8px', borderRadius: 10 }}>
                  {t('status.' + form.status)}
                </span>
              </div>
            </div>
            <button onClick={onClose} style={{ background: 'none', border: 'none', fontSize: 20, cursor: 'pointer', color: '#9ca3af', lineHeight: 1 }}>✕</button>
          </div>
        </div>

        <div style={{ padding: '0 24px 24px', overflowY: 'auto' }}>

          <div style={{ marginTop: 16, background: '#f8fafc', borderRadius: 10, border: '1px solid #e5e7eb', padding: 16 }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 10 }}>
              {t('scouting.messages')}
            </div>

            <div style={{ display: 'flex', gap: 6, marginBottom: 10 }}>
              <Tab label={t('scouting.step1')} active={activeStep === 1} onClick={() => setActiveStep(1)} />
              {hasStep2 && <Tab label={t('scouting.step2')} active={activeStep === 2} onClick={() => setActiveStep(2)} />}
            </div>

            <div style={{ display: 'flex', gap: 6, marginBottom: 12 }}>
              <Tab label="LinkedIn" active={activeChannel === 'linkedin'} onClick={() => setActiveChannel('linkedin')} />
              <Tab label="Email" active={activeChannel === 'email'} onClick={() => setActiveChannel('email')} />
            </div>

            {activeChannel === 'email' && currentTemplate?.subject && (
              <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 6, padding: '8px 12px', marginBottom: 8, fontSize: 12 }}>
                <span style={{ color: '#6b7280', fontWeight: 600 }}>{t('scouting.subject')} </span>
                <span style={{ color: '#1f2937' }}>{personalize(currentTemplate.subject, form)}</span>
              </div>
            )}

            {currentTemplate ? (
              <>
                <textarea
                  value={messageText}
                  onChange={e => setMessageText(e.target.value)}
                  style={{
                    width: '100%', boxSizing: 'border-box',
                    padding: '10px 12px', border: `1px solid ${charOverLimit ? '#ef4444' : '#d1d5db'}`,
                    borderRadius: 6, fontSize: 12, lineHeight: 1.6,
                    resize: 'vertical', minHeight: activeStep === 1 ? 110 : 200,
                    fontFamily: 'inherit', background: '#fff',
                  }}
                />
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 8 }}>
                  {isStep1LinkedIn ? (
                    <span style={{ fontSize: 11, color: charCount > charLimit ? '#ef4444' : '#9ca3af' }}>
                      {charCount} / {charLimit}{charCount > charLimit ? t('scouting.tooLong') : ''}
                    </span>
                  ) : <span />}
                  <button onClick={handleCopy} style={{
                    padding: '6px 16px', borderRadius: 6, border: 'none', cursor: 'pointer',
                    fontSize: 12, fontWeight: 600,
                    background: copied ? '#d1fae5' : '#1f2937',
                    color: copied ? '#065f46' : '#fff',
                  }}>
                    {copied ? t('scouting.copied') : t('scouting.copy')}
                  </button>
                </div>
              </>
            ) : (
              <div style={{ padding: '20px 0', textAlign: 'center', color: '#9ca3af', fontSize: 13 }}>
                {t('scouting.noTemplate')}
              </div>
            )}
          </div>

          <label style={lbl}>{t('scouting.contactName')}</label>
          <input style={inp} value={form.contact_name || ''} onChange={e => set('contact_name', e.target.value)} placeholder="Prénom Nom" />

          <label style={lbl}>Email</label>
          <input style={inp} value={form.email || ''} onChange={e => set('email', e.target.value)} />

          <label style={lbl}>LinkedIn</label>
          <div style={{ display: 'flex', gap: 8 }}>
            <input style={{ ...inp, flex: 1 }} value={form.linkedin || ''} onChange={e => set('linkedin', e.target.value)} placeholder="https://linkedin.com/in/..." />
            {form.linkedin && (
              <a href={form.linkedin} target="_blank" rel="noreferrer" style={{ padding: '8px 12px', background: '#1d4ed8', color: '#fff', borderRadius: 6, textDecoration: 'none', fontSize: 12, fontWeight: 600, display: 'flex', alignItems: 'center' }}>
                in
              </a>
            )}
          </div>

          <label style={lbl}>{t('scouting.status')}</label>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 6 }}>
            {STATUS_VALUES.map(status => {
              const cs = STATUS_STYLES[status]
              return (
                <button key={status} onClick={() => set('status', status)} style={{
                  padding: '7px 10px', borderRadius: 6, cursor: 'pointer', fontSize: 12, fontWeight: 600, textAlign: 'left',
                  border: `2px solid ${form.status === status ? cs.color : '#e5e7eb'}`,
                  background: form.status === status ? cs.bg : '#fff',
                  color: form.status === status ? cs.color : '#6b7280',
                }}>
                  {t('status.' + status)}
                </button>
              )
            })}
          </div>

          <label style={lbl}>{t('scouting.notes')}</label>
          <textarea style={{ ...inp, height: 80, resize: 'vertical' }} value={form.notes || ''} onChange={e => set('notes', e.target.value)} />

          {form.status !== 'converted' && (
            <button onClick={handleConvertToProspect} style={{
              width: '100%', marginTop: 20, padding: '11px', borderRadius: 8, border: 'none',
              background: '#059669', color: '#fff', cursor: 'pointer', fontWeight: 700, fontSize: 14,
            }}>
              {t('scouting.addToProspects')}
            </button>
          )}
          {form.status === 'converted' && (
            <div style={{ marginTop: 20, padding: '10px 14px', background: '#d1fae5', borderRadius: 8, fontSize: 13, color: '#065f46', fontWeight: 600, textAlign: 'center' }}>
              {t('scouting.alreadyConverted')}
            </div>
          )}

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 12 }}>
            <button onClick={handleDelete} style={{ padding: '8px 14px', borderRadius: 6, border: 'none', background: '#fee2e2', color: '#991b1b', cursor: 'pointer', fontSize: 13, fontWeight: 600 }}>
              🗑 {t('common.delete')}
            </button>
            <div style={{ display: 'flex', gap: 8 }}>
              <button onClick={onClose} style={{ padding: '8px 16px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer', fontSize: 13 }}>{t('common.cancel')}</button>
              <button onClick={handleSave} style={{ padding: '8px 18px', borderRadius: 6, border: 'none', background: '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 700, fontSize: 13 }}>
                💾 {t('common.save')}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

function KanbanCard({ item, onClick, onAdvance, isLast }) {
  const { t } = useLang()
  const idx = STATUS_VALUES.indexOf(item.status)
  const nextStatus = STATUS_VALUES[idx + 1]
  return (
    <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8, padding: 12, marginBottom: 8, cursor: 'pointer' }}
      onMouseEnter={e => e.currentTarget.style.boxShadow = '0 2px 8px rgba(0,0,0,0.08)'}
      onMouseLeave={e => e.currentTarget.style.boxShadow = 'none'}>
      <div onClick={onClick}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 6 }}>
          <div style={{ fontWeight: 700, fontSize: 13, color: '#1f2937', flex: 1, paddingRight: 4, lineHeight: 1.3 }}>
            {item.company}
          </div>
          <TypeBadge type={item.type} />
        </div>
        {item.contact_name && (
          <div style={{ fontSize: 11, color: '#9ca3af', marginBottom: 3 }}>👤 {item.contact_name}</div>
        )}
        {item.linkedin && (
          <div style={{ fontSize: 11, color: '#3b82f6', marginBottom: 3, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            🔗 LinkedIn
          </div>
        )}
        {item.notes && (
          <div style={{ fontSize: 11, color: '#6b7280', marginTop: 4, lineHeight: 1.4,
            display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
            {item.notes}
          </div>
        )}
      </div>
      {!isLast && nextStatus && (
        <button onClick={e => { e.stopPropagation(); onAdvance(item) }} style={{
          marginTop: 8, width: '100%', padding: '4px', borderRadius: 5,
          border: '1px dashed #d1d5db', background: 'transparent', cursor: 'pointer',
          fontSize: 11, color: '#9ca3af', fontWeight: 600,
        }}>
          → {t('status.' + nextStatus)}
        </button>
      )}
    </div>
  )
}

function AddModal({ onClose, onSave, defaultType, defaultCountry }) {
  const { t } = useLang()
  const [form, setForm] = useState({
    company: '', contact_name: '', email: '', linkedin: '',
    type: defaultType || 'developer', status: 'to_contact',
    country: defaultCountry || 'FR', notes: '',
  })
  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))
  const inp = { width: '100%', padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13, boxSizing: 'border-box' }
  const lbl = { display: 'block', fontSize: 11, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 4, marginTop: 12 }

  const handleSave = async () => {
    if (!form.company) return alert(t('scouting.companyRequired'))
    await api.post('/scouting/', form)
    onSave()
  }

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100, padding: 16 }}
      onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={{ background: '#fff', borderRadius: 12, padding: 24, width: 460, boxShadow: '0 25px 60px rgba(0,0,0,0.2)' }}>
        <h2 style={{ fontSize: 17, fontWeight: 700, marginBottom: 16 }}>{t('scouting.newContact')}</h2>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <div><label style={{ ...lbl, marginTop: 0 }}>{t('scouting.form.company')}</label><input style={inp} value={form.company} onChange={e => set('company', e.target.value)} autoFocus /></div>
          <div><label style={{ ...lbl, marginTop: 0 }}>{t('scouting.form.contact')}</label><input style={inp} value={form.contact_name} onChange={e => set('contact_name', e.target.value)} /></div>
          <div><label style={{ ...lbl, marginTop: 0 }}>{t('scouting.form.type')}</label>
            <select style={inp} value={form.type} onChange={e => set('type', e.target.value)}>
              {TYPE_VALUES.map(v => {
                const shortLabels = { developer: 'Dev', investor: 'Invest.', ipp: 'IPP', family_office: 'Family' }
                return <option key={v} value={v}>{shortLabels[v] || v}</option>
              })}
            </select>
          </div>
          <div><label style={{ ...lbl, marginTop: 0 }}>{t('scouting.form.country')}</label>
            <select style={inp} value={form.country} onChange={e => set('country', e.target.value)}>
              {COUNTRY_OPTIONS.map(c => <option key={c} value={c}>{c}</option>)}
            </select>
          </div>
        </div>
        <label style={lbl}>{t('scouting.form.linkedin')}</label>
        <input style={inp} value={form.linkedin} onChange={e => set('linkedin', e.target.value)} placeholder="https://linkedin.com/in/..." />
        <label style={lbl}>Email</label>
        <input style={inp} value={form.email} onChange={e => set('email', e.target.value)} />
        <label style={lbl}>{t('scouting.form.notes')}</label>
        <textarea style={{ ...inp, height: 60, resize: 'vertical' }} value={form.notes} onChange={e => set('notes', e.target.value)} />
        <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end', marginTop: 16 }}>
          <button onClick={onClose} style={{ padding: '8px 16px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer' }}>{t('common.cancel')}</button>
          <button onClick={handleSave} style={{ padding: '8px 18px', borderRadius: 6, border: 'none', background: '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 700 }}>{t('common.add')}</button>
        </div>
      </div>
    </div>
  )
}

export default function Scouting() {
  const { t } = useLang()
  const [data, setData] = useState([])
  const [filterType, setFilterType]       = useState('')
  const [filterCountry, setFilterCountry] = useState('FR')
  const [search, setSearch]               = useState('')
  const [selectedItem, setSelectedItem]   = useState(null)
  const [showAdd, setShowAdd]             = useState(false)
  const [loading, setLoading]             = useState(true)
  const [visibleCount, setVisibleCount]   = useState({})

  const load = () => {
    setLoading(true)
    const params = {}
    if (filterType) params.type = filterType
    if (filterCountry) params.country = filterCountry
    api.get('/scouting/', { params }).then(r => {
      setData(r.data)
      setLoading(false)
    })
  }

  useEffect(() => { load() }, [filterType, filterCountry])

  const advance = async (item) => {
    const idx = STATUS_VALUES.indexOf(item.status)
    if (idx < STATUS_VALUES.length - 1) {
      await api.put(`/scouting/${item.id}`, { ...item, status: STATUS_VALUES[idx + 1] })
      load()
    }
  }

  const filtered = data.filter(d =>
    !search || d.company.toLowerCase().includes(search.toLowerCase()) ||
    (d.contact_name || '').toLowerCase().includes(search.toLowerCase())
  )

  const byStatus = {}
  STATUS_VALUES.forEach(status => { byStatus[status] = filtered.filter(d => d.status === status) })

  const totalContacted = data.filter(d => d.status !== 'to_contact').length
  const converted = data.filter(d => d.status === 'converted').length
  const convRate = data.length > 0 ? Math.round((converted / data.length) * 100) : 0

  const shortTypeLabels = { developer: 'Dev', investor: 'Invest.', ipp: 'IPP', family_office: 'Family' }

  return (
    <div style={{ height: 'calc(100vh - 64px)', display: 'flex', flexDirection: 'column' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16, flexShrink: 0 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1f2937' }}>{t('scouting.title')}</h1>
          <div style={{ fontSize: 13, color: '#6b7280', marginTop: 2 }}>
            {data.length} contacts · {totalContacted} {t('status.contacted').toLowerCase()} · {converted} {t('status.converted').replace(' ✓','').toLowerCase()} ({convRate}%)
          </div>
        </div>
        <button onClick={() => setShowAdd(true)} style={{ padding: '9px 18px', background: '#2563eb', color: '#fff', border: 'none', borderRadius: 6, fontWeight: 700, cursor: 'pointer' }}>
          {t('scouting.new')}
        </button>
      </div>

      <div style={{ display: 'flex', gap: 8, marginBottom: 16, flexShrink: 0, flexWrap: 'wrap' }}>
        <input placeholder={t('common.search')} value={search} onChange={e => setSearch(e.target.value)}
          style={{ flex: 1, minWidth: 160, padding: '7px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 13 }} />
        <div style={{ display: 'flex', background: '#f3f4f6', borderRadius: 6, padding: 2 }}>
          {[{ value: '', label: t('scouting.allCountries') }, ...COUNTRY_OPTIONS.map(c => ({ value: c, label: c }))].map(opt => (
            <button key={opt.value} onClick={() => setFilterCountry(opt.value)} style={{
              padding: '5px 12px', borderRadius: 4, border: 'none', cursor: 'pointer', fontSize: 13, fontWeight: 600,
              background: filterCountry === opt.value ? '#fff' : 'transparent',
              color: filterCountry === opt.value ? '#1f2937' : '#6b7280',
              boxShadow: filterCountry === opt.value ? '0 1px 3px rgba(0,0,0,0.1)' : 'none',
            }}>{opt.label}</button>
          ))}
        </div>
        <div style={{ display: 'flex', background: '#f3f4f6', borderRadius: 6, padding: 2 }}>
          {[{ value: '', label: t('scouting.all') }, ...TYPE_VALUES.map(v => ({ value: v, label: shortTypeLabels[v] || v }))].map(opt => (
            <button key={opt.value} onClick={() => setFilterType(opt.value)} style={{
              padding: '5px 10px', borderRadius: 4, border: 'none', cursor: 'pointer', fontSize: 12, fontWeight: 600,
              background: filterType === opt.value ? '#fff' : 'transparent',
              color: filterType === opt.value ? '#1f2937' : '#6b7280',
              boxShadow: filterType === opt.value ? '0 1px 3px rgba(0,0,0,0.1)' : 'none',
            }}>{opt.label}</button>
          ))}
        </div>
      </div>

      {loading ? (
        <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#9ca3af' }}>{t('common.loading')}</div>
      ) : (
        <div style={{ flex: 1, overflowX: 'auto', overflowY: 'hidden' }}>
          <div style={{ display: 'flex', gap: 12, height: '100%', minWidth: 'max-content', paddingBottom: 16 }}>
            {STATUS_VALUES.map((status, colIdx) => {
              const colStyle = STATUS_STYLES[status]
              const cards = byStatus[status] || []
              const limit = visibleCount[status] || 15
              const visible = cards.slice(0, limit)
              const isLast = colIdx === STATUS_VALUES.length - 1
              return (
                <div key={status} style={{ width: 220, flexShrink: 0, display: 'flex', flexDirection: 'column', background: colStyle.bg, border: `1px solid ${colStyle.border}`, borderRadius: 10, overflow: 'hidden' }}>
                  <div style={{ padding: '12px 14px', borderBottom: `1px solid ${colStyle.border}`, flexShrink: 0 }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <span style={{ fontWeight: 700, fontSize: 13, color: colStyle.color }}>{t('status.' + status)}</span>
                      <span style={{ background: colStyle.border, color: colStyle.color, borderRadius: 10, padding: '1px 8px', fontSize: 12, fontWeight: 700 }}>{cards.length}</span>
                    </div>
                  </div>
                  <div style={{ flex: 1, overflowY: 'auto', padding: 10 }}>
                    {visible.length === 0 ? (
                      <div style={{ textAlign: 'center', color: '#d1d5db', fontSize: 12, padding: '20px 0' }}>{t('scouting.noContacts')}</div>
                    ) : (
                      visible.map(item => (
                        <KanbanCard key={item.id} item={item} isLast={isLast}
                          onClick={() => setSelectedItem(item)} onAdvance={advance} />
                      ))
                    )}
                    {cards.length > limit && (
                      <button onClick={() => setVisibleCount(v => ({ ...v, [status]: limit + 15 }))}
                        style={{ width: '100%', padding: 8, borderRadius: 6, border: '1px dashed #d1d5db', background: 'transparent', cursor: 'pointer', fontSize: 12, color: '#9ca3af' }}>
                        + {cards.length - limit}
                      </button>
                    )}
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      )}

      {selectedItem && (
        <CardModal
          item={selectedItem}
          onClose={() => setSelectedItem(null)}
          onSave={() => { setSelectedItem(null); load() }}
          onDelete={() => { setSelectedItem(null); load() }}
        />
      )}

      {showAdd && (
        <AddModal defaultType={filterType} defaultCountry={filterCountry}
          onClose={() => setShowAdd(false)}
          onSave={() => { setShowAdd(false); load() }} />
      )}
    </div>
  )
}
