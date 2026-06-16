import { useEffect, useState } from 'react'
import api from '../api/client'
import { useLang } from '../context/LanguageContext'

const STAGE_COLORS = {
  development:   { color: '#6b7280', bg: '#f3f4f6' },
  permitting:    { color: '#d97706', bg: '#fffbeb' },
  ready_to_build:{ color: '#059669', bg: '#f0fdf4' },
  construction:  { color: '#2563eb', bg: '#eff6ff' },
  operational:   { color: '#7c3aed', bg: '#f5f3ff' },
}

const PERMIT_CONFIG = {
  'purgé':      { color: '#059669', bg: '#d1fae5' },
  'purged':     { color: '#059669', bg: '#d1fae5' },
  'déposé':     { color: '#d97706', bg: '#fef3c7' },
  'filed':      { color: '#d97706', bg: '#fef3c7' },
  'à déposer':  { color: '#6b7280', bg: '#f3f4f6' },
  'to file':    { color: '#6b7280', bg: '#f3f4f6' },
  'recours':    { color: '#dc2626', bg: '#fee2e2' },
  'appeal':     { color: '#dc2626', bg: '#fee2e2' },
}

const TECH_COLORS = {
  solar: '#d97706',
  wind:  '#2563eb',
  bess:  '#7c3aed',
  other: '#6b7280',
}

const STAGES = ['development', 'permitting', 'ready_to_build']

function StageBadge({ stage, t }) {
  const cfg = STAGE_COLORS[stage] || { color: '#6b7280', bg: '#f3f4f6' }
  return (
    <span style={{ fontSize: 11, fontWeight: 700, padding: '3px 8px', borderRadius: 20,
      color: cfg.color, background: cfg.bg, whiteSpace: 'nowrap' }}>
      {t(`proj.stage.${stage}`) || stage}
    </span>
  )
}

function PermitBadge({ status, t }) {
  if (!status) return null
  const cfg = PERMIT_CONFIG[status] || { color: '#6b7280', bg: '#f3f4f6' }
  const label = t(`proj.permit.${status}`) || status
  return (
    <span style={{ fontSize: 11, fontWeight: 600, padding: '2px 7px', borderRadius: 10,
      color: cfg.color, background: cfg.bg }}>
      {label}
    </span>
  )
}

function DetailPanel({ project, onClose, onSave, t }) {
  const [notes, setNotes] = useState(project.notes || '')
  const [nda, setNda] = useState(project.nda_signed || 'Non')
  const [saving, setSaving] = useState(false)

  const handleSave = async () => {
    setSaving(true)
    await api.put(`/projects/${project.id}`, { notes, nda_signed: nda })
    setSaving(false)
    onSave()
  }

  const fmt = (n) => n ? new Intl.NumberFormat('fr-FR').format(Math.round(n)) : '—'

  return (
    <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 12,
      padding: 24, alignSelf: 'start', position: 'sticky', top: 20, minWidth: 340 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
        <div>
          <div style={{ fontSize: 11, color: '#9ca3af', fontWeight: 600, marginBottom: 3 }}>
            #{project.code} · {project.developer_name}
          </div>
          <h3 style={{ fontSize: 15, fontWeight: 700, color: '#1f2937', margin: 0, lineHeight: 1.3 }}>
            {project.name}
          </h3>
        </div>
        <button onClick={onClose} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#9ca3af', fontSize: 18, marginLeft: 8 }}>✕</button>
      </div>

      <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', marginBottom: 16 }}>
        <StageBadge stage={project.stage} t={t} />
        <PermitBadge status={project.permit_status} t={t} />
        {project.nda_signed === 'Oui' && (
          <span style={{ fontSize: 11, fontWeight: 600, padding: '3px 8px', borderRadius: 20, color: '#059669', background: '#d1fae5' }}>
            {t('proj.detail.ndaSigned')}
          </span>
        )}
      </div>

      {project.status_detail && (
        <div style={{ background: '#f8fafc', borderRadius: 8, padding: '10px 12px', fontSize: 12,
          color: '#374151', lineHeight: 1.5, marginBottom: 14, border: '1px solid #e5e7eb' }}>
          {project.status_detail}
        </div>
      )}

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 14 }}>
        <Stat label={t('proj.detail.power')} value={project.capacity_mw ? `${project.capacity_mw} MWc` : '—'} />
        <Stat label={t('proj.detail.p50')} value={project.p50_mwh ? `${fmt(project.p50_mwh)} MWh/yr` : '—'} />
        <Stat label={t('proj.table.rtb')} value={project.rtb_date || '—'} />
        <Stat label={t('proj.table.cod')} value={project.cod_date || '—'} />
        <Stat label={t('proj.detail.tech')} value={project.technology_detail || project.technology || '—'} />
        <Stat label={t('proj.detail.permit')} value={project.permit_type || '—'} />
      </div>

      {(project.department || project.commune) && (
        <div style={{ marginBottom: 14 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 6 }}>
            {t('proj.detail.location')}
          </div>
          <div style={{ fontSize: 13, color: '#374151' }}>
            {[project.commune, project.department && `${project.department} (${project.department_code})`, project.region].filter(Boolean).join(', ')}
          </div>
        </div>
      )}

      {project.offtake_type && (
        <div style={{ marginBottom: 14 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 4 }}>
            {t('proj.detail.offtake')}
          </div>
          <div style={{ fontSize: 13, color: '#374151' }}>{project.offtake_type}</div>
        </div>
      )}

      {(project.grid_operator || project.grid_connection_cost) && (
        <div style={{ marginBottom: 14 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 4 }}>
            {t('proj.detail.grid')}
          </div>
          <div style={{ fontSize: 13, color: '#374151' }}>
            {[project.grid_operator, project.grid_connection_cost && `${fmt(project.grid_connection_cost)} €`].filter(Boolean).join(' · ')}
          </div>
        </div>
      )}

      <div style={{ marginBottom: 14 }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 4 }}>
          {t('proj.detail.nda')}
        </div>
        <div style={{ display: 'flex', gap: 6 }}>
          {['Non', 'Oui'].map(v => (
            <button key={v} onClick={() => setNda(v)} style={{
              padding: '5px 14px', borderRadius: 6, border: `2px solid ${nda === v ? (v === 'Oui' ? '#059669' : '#d1d5db') : '#e5e7eb'}`,
              background: nda === v ? (v === 'Oui' ? '#d1fae5' : '#f3f4f6') : '#fff',
              color: nda === v ? (v === 'Oui' ? '#059669' : '#374151') : '#9ca3af',
              cursor: 'pointer', fontSize: 13, fontWeight: 600,
            }}>{v}</button>
          ))}
        </div>
      </div>

      <div style={{ marginBottom: 16 }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 4 }}>
          {t('proj.detail.notes')}
        </div>
        <textarea value={notes} onChange={e => setNotes(e.target.value)} rows={3}
          style={{ width: '100%', boxSizing: 'border-box', padding: '8px 10px', border: '1px solid #d1d5db',
            borderRadius: 6, fontSize: 13, resize: 'vertical', fontFamily: 'inherit' }} />
      </div>

      <button onClick={handleSave} disabled={saving} style={{
        width: '100%', padding: '10px', borderRadius: 8, border: 'none',
        background: saving ? '#a7f3d0' : '#059669', color: '#fff',
        fontWeight: 700, fontSize: 14, cursor: saving ? 'not-allowed' : 'pointer',
      }}>
        {saving ? t('proj.detail.saving') : t('proj.detail.save')}
      </button>
    </div>
  )
}

function Stat({ label, value }) {
  return (
    <div>
      <div style={{ fontSize: 10, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 2 }}>{label}</div>
      <div style={{ fontSize: 13, color: '#1f2937', fontWeight: 500 }}>{value}</div>
    </div>
  )
}

export default function Projects() {
  const { t } = useLang()
  const [projects, setProjects] = useState([])
  const [loading, setLoading] = useState(true)
  const [selected, setSelected] = useState(null)
  const [search, setSearch] = useState('')
  const [filterStage, setFilterStage] = useState('')
  const [filterDev, setFilterDev] = useState('')
  const [filterTech, setFilterTech] = useState('')

  const load = () => {
    setLoading(true)
    const params = {}
    if (filterStage) params.stage = filterStage
    if (filterDev) params.developer = filterDev
    if (filterTech) params.technology = filterTech
    api.get('/projects/', { params }).then(r => {
      setProjects(r.data)
      setLoading(false)
    })
  }

  useEffect(() => { load() }, [filterStage, filterDev, filterTech])

  const filtered = projects.filter(p =>
    !search ||
    p.name.toLowerCase().includes(search.toLowerCase()) ||
    (p.developer_name || '').toLowerCase().includes(search.toLowerCase()) ||
    (p.department || '').toLowerCase().includes(search.toLowerCase()) ||
    (p.commune || '').toLowerCase().includes(search.toLowerCase())
  )

  const totalMw = filtered.reduce((s, p) => s + (p.capacity_mw || 0), 0)
  const rtbCount = filtered.filter(p => p.stage === 'ready_to_build').length
  const sel = selected ? projects.find(p => p.id === selected) : null
  const devs = [...new Set(projects.map(p => p.developer_name).filter(Boolean))].sort()

  const TABLE_HEADERS = [
    t('proj.table.code'), t('proj.table.name'), t('proj.table.developer'),
    t('proj.table.tech'), t('proj.table.mw'), t('proj.table.stage'),
    t('proj.table.permit'), t('proj.table.rtb'), t('proj.table.cod'), t('proj.table.dept'),
  ]

  return (
    <div style={{ maxWidth: 1400 }}>
      <div style={{ marginBottom: 20 }}>
        <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1f2937', marginBottom: 4 }}>
          {t('proj.title')}
        </h1>
        <div style={{ fontSize: 13, color: '#6b7280' }}>
          {filtered.length} {t('proj.subtitle').split('·')[0].trim()} · {totalMw.toFixed(1)} MWc · {rtbCount} RTB
        </div>
      </div>

      {/* Filters */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 16, flexWrap: 'wrap' }}>
        <input value={search} onChange={e => setSearch(e.target.value)}
          placeholder={t('proj.filter.search')}
          style={{ flex: 1, minWidth: 180, padding: '8px 12px', border: '1px solid #e5e7eb', borderRadius: 8, fontSize: 13 }} />

        <select value={filterDev} onChange={e => setFilterDev(e.target.value)}
          style={{ padding: '8px 12px', border: '1px solid #e5e7eb', borderRadius: 8, fontSize: 13, background: '#fff' }}>
          <option value="">{t('proj.filter.allDev')}</option>
          {devs.map(d => <option key={d} value={d}>{d}</option>)}
        </select>

        <select value={filterStage} onChange={e => setFilterStage(e.target.value)}
          style={{ padding: '8px 12px', border: '1px solid #e5e7eb', borderRadius: 8, fontSize: 13, background: '#fff' }}>
          <option value="">{t('proj.filter.allStages')}</option>
          {STAGES.map(s => <option key={s} value={s}>{t(`proj.stage.${s}`)}</option>)}
        </select>

        <select value={filterTech} onChange={e => setFilterTech(e.target.value)}
          style={{ padding: '8px 12px', border: '1px solid #e5e7eb', borderRadius: 8, fontSize: 13, background: '#fff' }}>
          <option value="">{t('proj.filter.allTech')}</option>
          <option value="solar">{t('proj.filter.solar')}</option>
          <option value="wind">{t('proj.filter.wind')}</option>
        </select>

        {(filterStage || filterDev || filterTech || search) && (
          <button onClick={() => { setFilterStage(''); setFilterDev(''); setFilterTech(''); setSearch('') }}
            style={{ padding: '8px 12px', borderRadius: 8, border: '1px solid #e5e7eb', background: '#fff', fontSize: 13, cursor: 'pointer', color: '#6b7280' }}>
            {t('proj.filter.clear')}
          </button>
        )}
      </div>

      {/* Stats cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(140px, 1fr))', gap: 10, marginBottom: 20 }}>
        {STAGES.map(stage => {
          const cfg = STAGE_COLORS[stage]
          const count = projects.filter(p => p.stage === stage).length
          const mw = projects.filter(p => p.stage === stage).reduce((s, p) => s + (p.capacity_mw || 0), 0)
          return (
            <div key={stage} onClick={() => setFilterStage(filterStage === stage ? '' : stage)}
              style={{ background: '#fff', border: `1px solid ${filterStage === stage ? cfg.color : '#e5e7eb'}`,
                borderRadius: 10, padding: '12px 16px', cursor: 'pointer',
                borderLeft: `4px solid ${cfg.color}` }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: cfg.color, textTransform: 'uppercase', marginBottom: 4 }}>
                {t(`proj.stage.${stage}`)}
              </div>
              <div style={{ fontSize: 20, fontWeight: 700, color: '#1f2937' }}>{count}</div>
              <div style={{ fontSize: 11, color: '#9ca3af' }}>{mw.toFixed(1)} MWc</div>
            </div>
          )
        })}
        <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, padding: '12px 16px', borderLeft: '4px solid #1f2937' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: '#1f2937', textTransform: 'uppercase', marginBottom: 4 }}>
            {t('proj.stat.total')}
          </div>
          <div style={{ fontSize: 20, fontWeight: 700, color: '#1f2937' }}>{projects.length}</div>
          <div style={{ fontSize: 11, color: '#9ca3af' }}>
            {projects.reduce((s, p) => s + (p.capacity_mw || 0), 0).toFixed(1)} MWc
          </div>
        </div>
      </div>

      {/* Table + detail panel */}
      <div style={{ display: 'grid', gridTemplateColumns: sel ? '1fr 380px' : '1fr', gap: 16, alignItems: 'start' }}>
        <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 12, overflow: 'hidden' }}>
          {loading ? (
            <div style={{ padding: 40, textAlign: 'center', color: '#9ca3af' }}>{t('proj.loading')}</div>
          ) : filtered.length === 0 ? (
            <div style={{ padding: 40, textAlign: 'center', color: '#9ca3af' }}>{t('proj.empty')}</div>
          ) : (
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13 }}>
              <thead>
                <tr style={{ background: '#f8fafc', borderBottom: '1px solid #e5e7eb' }}>
                  {TABLE_HEADERS.map(h => (
                    <th key={h} style={{ padding: '10px 12px', textAlign: 'left', fontSize: 11, fontWeight: 700,
                      color: '#6b7280', textTransform: 'uppercase', whiteSpace: 'nowrap' }}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((p, i) => {
                  const isActive = selected === p.id
                  const techColor = TECH_COLORS[p.technology] || TECH_COLORS.other
                  return (
                    <tr key={p.id} onClick={() => setSelected(isActive ? null : p.id)}
                      style={{ borderBottom: '1px solid #f3f4f6', cursor: 'pointer',
                        background: isActive ? '#f0fdf4' : i % 2 === 0 ? '#fff' : '#fafafa' }}>
                      <td style={{ padding: '10px 12px', color: '#9ca3af', fontSize: 11, fontWeight: 600 }}>
                        {p.code || p.id}
                      </td>
                      <td style={{ padding: '10px 12px', fontWeight: 600, color: '#1f2937', maxWidth: 200 }}>
                        <div style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{p.name}</div>
                      </td>
                      <td style={{ padding: '10px 12px', color: '#374151', whiteSpace: 'nowrap' }}>{p.developer_name}</td>
                      <td style={{ padding: '10px 12px' }}>
                        <span style={{ fontSize: 11, fontWeight: 600, color: techColor }}>
                          {p.technology_detail || t(`proj.filter.${p.technology}`) || p.technology}
                        </span>
                      </td>
                      <td style={{ padding: '10px 12px', fontWeight: 600, color: '#1f2937', whiteSpace: 'nowrap' }}>
                        {p.capacity_mw ?? '—'}
                      </td>
                      <td style={{ padding: '10px 12px' }}><StageBadge stage={p.stage} t={t} /></td>
                      <td style={{ padding: '10px 12px' }}><PermitBadge status={p.permit_status} t={t} /></td>
                      <td style={{ padding: '10px 12px', color: '#374151', whiteSpace: 'nowrap', fontSize: 12 }}>{p.rtb_date || '—'}</td>
                      <td style={{ padding: '10px 12px', color: '#374151', whiteSpace: 'nowrap', fontSize: 12 }}>{p.cod_date || '—'}</td>
                      <td style={{ padding: '10px 12px', color: '#6b7280', fontSize: 12 }}>
                        {p.department_code ? `(${p.department_code})` : '—'}
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          )}
        </div>

        {sel && (
          <DetailPanel
            project={sel}
            t={t}
            onClose={() => setSelected(null)}
            onSave={() => { load(); setSelected(null) }}
          />
        )}
      </div>
    </div>
  )
}
