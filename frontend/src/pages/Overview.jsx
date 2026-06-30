import { useEffect, useState, useRef, useCallback } from 'react'
import {
  PieChart, Pie, Cell, Tooltip, ResponsiveContainer,
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
} from 'recharts'
import api from '../api/client'
import { useLang } from '../context/LanguageContext'

// ─── Constants ───────────────────────────────────────────────────────────────

const TECH_COLORS = {
  solar: '#fbbf24', wind: '#60a5fa', bess: '#34d399',
  hydro: '#38bdf8', biomass: '#a3e635', other: '#9ca3af',
}
const TECH_LABEL_KEYS = {
  solar: 'tech.solar_short', wind: 'tech.wind_short', bess: 'tech.bess_short',
  hydro: 'tech.hydro_short', biomass: 'tech.biomass_short', other: 'tech.other_short',
}
const STAGE_COLORS = {
  development: '#93c5fd', permitting: '#818cf8', ready_to_build: '#a78bfa',
  construction: '#fbbf24', operational: '#34d399',
}
const STAGE_LABEL_KEYS = {
  development: 'stage.development_short', permitting: 'stage.permitting_short',
  ready_to_build: 'stage.ready_to_build_short', construction: 'stage.construction_short',
  operational: 'stage.operational_short',
}
const EVENT_COLORS = {
  external: { dot: '#2563eb' },
  internal: { dot: '#7c3aed' },
  personal: { dot: '#ea580c' },
}
const PIPELINE_STAGES = [
  { key: 'to_contact', color: '#9ca3af' },
  { key: 'contacted', color: '#60a5fa' },
  { key: 'in_discussion', color: '#818cf8' },
  { key: 'meeting_scheduled', color: '#a78bfa' },
  { key: 'nda_signed', color: '#34d399' },
  { key: 'deal_in_progress', color: '#fbbf24' },
  { key: 'closed', color: '#10b981' },
  { key: 'rejected', color: '#f87171' },
]
const INVESTOR_STATUSES = [
  { key: 'to_contact', color: '#9ca3af' },
  { key: 'contacted', color: '#60a5fa' },
  { key: 'in_discussion', color: '#818cf8' },
  { key: 'active', color: '#34d399' },
  { key: 'inactive', color: '#f87171' },
]
const SCOUTING_STATUSES = [
  { key: 'to_contact', color: '#9ca3af' },
  { key: 'email_sent', color: '#60a5fa' },
  { key: 'linkedin_sent', color: '#38bdf8' },
  { key: 'responded', color: '#a78bfa' },
  { key: 'meeting_done', color: '#818cf8' },
  { key: 'converted', color: '#34d399' },
  { key: 'no_response', color: '#fb923c' },
  { key: 'not_interested', color: '#f87171' },
  { key: 'premiere_connexion', color: '#1e40af' },
  { key: 'deuxieme_connexion', color: '#5b21b6' },
]
const OPP_TYPE_COLORS = {
  financement: '#2563eb', levee: '#7c3aed', co_dev: '#0891b2',
  cession: '#16a34a', ppa: '#d97706', autre: '#9ca3af',
}
const OPP_TYPE_LABEL_KEYS = {
  financement: 'opp.type.financement', levee: 'opp.type.levee',
  co_dev: 'opp.type.co_dev', cession: 'opp.type.cession',
  ppa: 'opp.type.ppa', autre: 'opp.type.autre',
}
const OPP_STATUS_LIST = [
  { key: 'en_discussion', color: '#60a5fa' },
  { key: 'offre_envoyee', color: '#818cf8' },
  { key: 'term_sheet', color: '#fbbf24' },
  { key: 'signe', color: '#10b981' },
  { key: 'perdu', color: '#f87171' },
]

const FR_STAGES = [
  {
    id: 'origination',
    label: 'Origination',
    color: '#9ca3af',
    secured: 'Rien de sécurisé',
    ongoing: 'Prospection foncière — Real estate: Possible',
    detail: 'Projet identifié. Aucun terrain signé, aucune démarche engagée.',
  },
  {
    id: 'early',
    label: 'Early',
    color: '#60a5fa',
    secured: 'Real estate — Secured',
    ongoing: 'Environmental — Ongoing',
    detail: 'Foncier sécurisé (promesse de bail). Études environnement en cours. Permis pas encore déposé.',
  },
  {
    id: 'submit',
    label: 'Submit',
    color: '#818cf8',
    secured: 'Env — Done · Authorities — Secured',
    ongoing: 'Permitting — Near apply',
    detail: 'Autorisations locales obtenues. Études terminées. Dépôt du permis de construire imminent.',
  },
  {
    id: 'mid',
    label: 'Mid',
    color: '#a78bfa',
    secured: 'Easements — Secured · Permitting — Submitted',
    ongoing: 'PC en instruction',
    detail: 'Servitudes foncières sécurisées. PC déposé (date passée). En attente de la décision administrative.',
  },
  {
    id: 'advanced',
    label: 'Advanced',
    color: '#f59e0b',
    secured: 'Permitting — Deemed completed',
    ongoing: 'En attente de la décision finale',
    detail: 'Instruction terminée. PC considéré comme complet. Décision finale imminente.',
  },
  {
    id: 'nearly-secured',
    label: 'Nearly secured',
    color: '#fb923c',
    secured: 'Permitting — Obtained',
    ongoing: 'Grid — Nearly secured · Tariff — Nearly secured',
    detail: 'PC obtenu (sous recours ou purgé). Raccordement réseau et contrat d\'achat en cours de finalisation.',
  },
  {
    id: 'secured-clean',
    label: 'Secured & clean',
    color: '#10b981',
    secured: 'Grid — Secured · Tariff — Secured',
    ongoing: '— Prêt à construire (RTB) ✅',
    detail: 'Tout sécurisé. PC purgé de tout recours. Raccordement + contrat d\'achat signés.',
  },
  {
    id: 'refused',
    label: 'Refused',
    color: '#ef4444',
    secured: '❌ Projet arrêté',
    ongoing: '',
    detail: 'Permis de construire refusé définitivement. Projet abandonné.',
  },
]

const DE_STAGES = [
  {
    id: 'b-plan',
    label: 'B-Plan',
    color: '#9ca3af',
    secured: 'Pachtvertrag — signé (foncier)',
    ongoing: 'Bebauungsplan en cours de modification municipale',
    detail: 'La commune adapte le plan d\'urbanisme (Bebauungsplan) pour autoriser le projet solaire.',
  },
  {
    id: 'bauantrag',
    label: 'Bauantrag',
    color: '#60a5fa',
    secured: 'B-Plan — approuvé',
    ongoing: 'Demande de permis de construire déposée (Baubehörde)',
    detail: 'Bauantrag déposé auprès de l\'autorité de construction. En attente d\'instruction.',
  },
  {
    id: 'baugenehmigung',
    label: 'Baugenehmigung',
    color: '#818cf8',
    secured: 'Permis de construire — Erteilt (obtenu)',
    ongoing: 'EEG-Ausschreibung + Netzanschluss lancés en parallèle',
    detail: 'Permis obtenu. Appel d\'offres EEG et raccordement réseau démarrés simultanément.',
  },
  {
    id: 'eeg-netz',
    label: 'EEG + Netzanschluss',
    color: '#f59e0b',
    secured: 'EEG-Zuschlag — obtenu (tarif garanti)',
    ongoing: 'Netzanschluss — Nearly secured',
    detail: 'Appel d\'offres EEG remporté. Raccordement réseau en cours de finalisation.',
  },
  {
    id: 'bau',
    label: 'Bau',
    color: '#fb923c',
    secured: 'Netzanschluss — Secured · EEG — Secured',
    ongoing: 'Construction en cours (Bau)',
    detail: 'Tous permis et contrats sécurisés. Construction lancée.',
  },
  {
    id: 'betrieb',
    label: 'Betrieb',
    color: '#10b981',
    secured: 'Tout sécurisé ✅ — En exploitation (COD)',
    ongoing: '—',
    detail: 'Projet en opération. Raccordé au réseau, production sous contrat EEG.',
  },
  {
    id: 'ablehnung',
    label: 'Ablehnung',
    color: '#ef4444',
    secured: '❌ Projet arrêté',
    ongoing: '',
    detail: 'Permis de construire refusé (Ablehnung). Projet abandonné.',
  },
]

const COUNTRY_STAGES = { fr: FR_STAGES, de: DE_STAGES }
const COUNTRIES = [
  { id: 'fr', label: '🇫🇷 France', refused: 'refused' },
  { id: 'de', label: '🇩🇪 Allemagne', refused: 'ablehnung' },
]

// ─── Sub-components ───────────────────────────────────────────────────────────

function DevStageBar() {
  const [open, setOpen] = useState(true)
  const [country, setCountry] = useState('fr')
  const [selected, setSelected] = useState(null)

  const countryMeta = COUNTRIES.find(c => c.id === country)
  const allStages = COUNTRY_STAGES[country]
  const mainStages = allStages.filter(s => s.id !== countryMeta.refused)
  const refusedStage = allStages.find(s => s.id === countryMeta.refused)
  const stage = allStages.find(s => s.id === selected)

  const switchCountry = (c) => { setCountry(c); setSelected(null) }

  return (
    <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, marginBottom: 16, overflow: 'hidden' }}>
      <div onClick={() => setOpen(o => !o)}
        style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '10px 16px', cursor: 'pointer', userSelect: 'none' }}>
        <span style={{ fontSize: 13 }}>📊</span>
        <span style={{ flex: 1, fontWeight: 600, fontSize: 13, color: '#1f2937' }}>
          Stades de développement — Origination → RTB
        </span>
        <span style={{ fontSize: 11, color: '#6b7280', background: '#f3f4f6', borderRadius: 6, padding: '2px 8px', fontWeight: 500 }}>
          {countryMeta.label}
        </span>
        <span style={{ fontSize: 11, color: '#9ca3af', display: 'inline-block', transform: open ? 'rotate(180deg)' : 'rotate(0deg)', transition: 'transform 0.2s' }}>▼</span>
      </div>

      {open && (
        <div style={{ borderTop: '1px solid #f3f4f6', padding: '12px 16px' }}>
          {/* Country tabs */}
          <div style={{ display: 'flex', gap: 6, marginBottom: 12 }}>
            {COUNTRIES.map(c => (
              <button key={c.id} onClick={(e) => { e.stopPropagation(); switchCountry(c.id) }}
                style={{
                  padding: '4px 12px', borderRadius: 8,
                  border: `1.5px solid ${country === c.id ? '#2563eb' : '#e5e7eb'}`,
                  background: country === c.id ? '#eff6ff' : '#f9fafb',
                  color: country === c.id ? '#2563eb' : '#6b7280',
                  fontSize: 12, fontWeight: country === c.id ? 700 : 500,
                  cursor: 'pointer', transition: 'all 0.15s',
                }}>
                {c.label}
              </button>
            ))}
          </div>

          {/* Stage pills */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 4, flexWrap: 'wrap', marginBottom: stage ? 12 : 0 }}>
            {mainStages.map((s, i) => {
              const isSelected = selected === s.id
              return (
                <div key={s.id} style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                  <button onClick={() => setSelected(isSelected ? null : s.id)}
                    style={{
                      padding: '4px 11px', borderRadius: 14,
                      border: `1.5px solid ${isSelected ? s.color : '#e5e7eb'}`,
                      background: isSelected ? s.color : '#f9fafb',
                      color: isSelected ? '#fff' : '#374151',
                      fontSize: 11, fontWeight: isSelected ? 700 : 500,
                      cursor: 'pointer', transition: 'all 0.15s', whiteSpace: 'nowrap',
                    }}>
                    {i + 1}. {s.label}
                  </button>
                  {i < mainStages.length - 1 && (
                    <span style={{ color: '#d1d5db', fontSize: 11 }}>→</span>
                  )}
                </div>
              )
            })}
            {refusedStage && (
              <>
                <span style={{ color: '#d1d5db', fontSize: 11, marginLeft: 4 }}>|</span>
                <button onClick={() => setSelected(selected === refusedStage.id ? null : refusedStage.id)}
                  style={{
                    padding: '4px 11px', borderRadius: 14,
                    border: `1.5px solid ${selected === refusedStage.id ? refusedStage.color : '#e5e7eb'}`,
                    background: selected === refusedStage.id ? refusedStage.color : '#f9fafb',
                    color: selected === refusedStage.id ? '#fff' : '#ef4444',
                    fontSize: 11, fontWeight: selected === refusedStage.id ? 700 : 500,
                    cursor: 'pointer', transition: 'all 0.15s',
                  }}>
                  ❌ {refusedStage.label}
                </button>
              </>
            )}
          </div>

          {/* Detail panel */}
          {stage && (
            <div style={{
              background: '#fafafa', borderLeft: `3px solid ${stage.color}`,
              borderRadius: '0 8px 8px 0', padding: '10px 14px',
              display: 'flex', flexDirection: 'column', gap: 5,
            }}>
              <div style={{ display: 'flex', gap: 8, alignItems: 'baseline' }}>
                <span style={{ fontWeight: 700, color: '#059669', fontSize: 12, minWidth: 80 }}>✅ Sécurisé</span>
                <span style={{ fontSize: 12, color: '#374151' }}>{stage.secured}</span>
              </div>
              {stage.ongoing && stage.ongoing !== '—' && (
                <div style={{ display: 'flex', gap: 8, alignItems: 'baseline' }}>
                  <span style={{ fontWeight: 700, color: '#d97706', fontSize: 12, minWidth: 80 }}>📝 En cours</span>
                  <span style={{ fontSize: 12, color: '#374151' }}>{stage.ongoing}</span>
                </div>
              )}
              <div style={{ display: 'flex', gap: 8, alignItems: 'baseline' }}>
                <span style={{ fontWeight: 700, color: '#6b7280', fontSize: 12, minWidth: 80 }}>💬 Note</span>
                <span style={{ fontSize: 12, color: '#6b7280' }}>{stage.detail}</span>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  )
}

function KPI({ label, value, color, sub, icon }) {
  return (
    <div style={{
      background: '#fff',
      border: '1px solid #e5e7eb',
      borderTop: `3px solid ${color}`,
      borderRadius: 10,
      padding: '14px 18px',
      flex: 1,
      minWidth: 120,
    }}>
      <div style={{ fontSize: 11, color: '#6b7280', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 5 }}>
        {icon} {label}
      </div>
      <div style={{ fontSize: 26, fontWeight: 700, color, lineHeight: 1.2 }}>{value ?? '—'}</div>
      {sub && <div style={{ fontSize: 11, color: '#9ca3af', marginTop: 3 }}>{sub}</div>}
    </div>
  )
}

function Panel({ title, children, style = {} }) {
  return (
    <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, padding: 18, ...style }}>
      <h3 style={{ fontSize: 13, fontWeight: 600, color: '#1f2937', marginBottom: 14 }}>{title}</h3>
      {children}
    </div>
  )
}

function StatusBar({ label, count, max, color, total }) {
  const barPct = max > 0 ? Math.round((count / max) * 100) : 0
  const ofTotal = total > 0 ? Math.round((count / total) * 100) : 0
  return (
    <div style={{ marginBottom: 10 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 4, fontSize: 12 }}>
        <span style={{ color: '#374151', display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ width: 7, height: 7, borderRadius: '50%', background: color, display: 'inline-block', flexShrink: 0 }} />
          {label}
        </span>
        <span style={{ color: '#6b7280', fontWeight: 600, minWidth: 36, textAlign: 'right' }}>
          {count}{total ? <span style={{ fontWeight: 400, color: '#9ca3af' }}> · {ofTotal}%</span> : ''}
        </span>
      </div>
      <div style={{ background: '#f3f4f6', borderRadius: 4, height: 5, overflow: 'hidden' }}>
        <div style={{ background: color, width: `${barPct}%`, height: '100%', borderRadius: 4, transition: 'width 0.5s ease' }} />
      </div>
    </div>
  )
}

function formatEventDate(isoStr, t) {
  const d = new Date(isoStr)
  const today = new Date()
  const tomorrow = new Date(today)
  tomorrow.setDate(today.getDate() + 1)
  const sameDay = (a, b) => a.getDate() === b.getDate() && a.getMonth() === b.getMonth() && a.getFullYear() === b.getFullYear()
  const days = t('overview.calendar.days').split(',')
  const time = d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
  if (sameDay(d, today)) return { badge: t('overview.calendar.today'), badgeColor: '#16a34a', time }
  if (sameDay(d, tomorrow)) return { badge: t('overview.calendar.tomorrow'), badgeColor: '#2563eb', time }
  return { badge: `${days[d.getDay()]} ${d.getDate()}/${String(d.getMonth() + 1).padStart(2, '0')}`, badgeColor: '#6b7280', time }
}

function AgendaRow({ event, t, onPrep }) {
  const { badge, badgeColor, time } = formatEventDate(event.start, t)
  const dot = (EVENT_COLORS[event.type] || EVENT_COLORS.internal).dot
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '7px 0', borderBottom: '1px solid #f3f4f6', fontSize: 12 }}>
      <span style={{ minWidth: 52, fontSize: 10, fontWeight: 600, color: badgeColor, background: badgeColor + '18', borderRadius: 4, padding: '2px 5px', textAlign: 'center' }}>{badge}</span>
      <span style={{ minWidth: 38, color: '#9ca3af', fontSize: 11 }}>{time}</span>
      <span style={{ width: 7, height: 7, borderRadius: '50%', background: dot, flexShrink: 0 }} />
      <span style={{ flex: 1, color: '#1f2937', fontWeight: 500, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{event.title}</span>
      {event.meet_url && (
        <a href={event.meet_url} target="_blank" rel="noreferrer" style={{ fontSize: 10, color: '#2563eb', background: '#eff6ff', borderRadius: 4, padding: '2px 6px', textDecoration: 'none', border: '1px solid #bfdbfe', flexShrink: 0 }}>
          {event.meet_url.includes('teams') ? 'Teams' : 'Meet'}
        </a>
      )}
      <button onClick={() => onPrep(event.title)}
        style={{ fontSize: 10, padding: '2px 6px', borderRadius: 4, border: '1px solid #d1d5db', background: '#f9fafb', cursor: 'pointer', color: '#374151', flexShrink: 0 }}>
        📋 Prep
      </button>
    </div>
  )
}

function TechDonut({ data, total, t }) {
  const chartData = data.filter(d => d.count > 0).map(d => ({
    name: t(TECH_LABEL_KEYS[d.technology] || d.technology),
    value: d.count,
    mw: d.total_mw,
    color: TECH_COLORS[d.technology] || '#9ca3af',
  }))

  if (chartData.length === 0) {
    return <div style={{ color: '#9ca3af', fontSize: 13, textAlign: 'center', padding: '40px 0' }}>{t('overview.analytics.empty')}</div>
  }

  return (
    <div>
      <div style={{ position: 'relative', height: 180 }}>
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie data={chartData} cx="50%" cy="50%" innerRadius={58} outerRadius={78} dataKey="value" paddingAngle={2} startAngle={90} endAngle={-270}>
              {chartData.map((entry, i) => <Cell key={i} fill={entry.color} stroke="none" />)}
            </Pie>
            <Tooltip
              formatter={(value, name, props) => [
                `${value} ${value > 1 ? t('overview.tooltip.projects') : t('overview.tooltip.project')}${props.payload.mw ? ` · ${props.payload.mw} MW` : ''}`,
                name,
              ]}
              contentStyle={{ fontSize: 12, borderRadius: 8, border: '1px solid #e5e7eb' }}
            />
          </PieChart>
        </ResponsiveContainer>
        <div style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', textAlign: 'center', pointerEvents: 'none' }}>
          <div style={{ fontSize: 24, fontWeight: 700, color: '#1f2937', lineHeight: 1 }}>{total}</div>
          <div style={{ fontSize: 11, color: '#6b7280', marginTop: 2 }}>{t('overview.tooltip.projects')}</div>
        </div>
      </div>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px 12px', marginTop: 10 }}>
        {chartData.map((d, i) => (
          <span key={i} style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 11, color: '#374151' }}>
            <span style={{ width: 8, height: 8, borderRadius: '50%', background: d.color, display: 'inline-block' }} />
            {d.name} <span style={{ color: '#9ca3af' }}>({d.value})</span>
          </span>
        ))}
      </div>
    </div>
  )
}

function OppTypeDonut({ byType, total, t }) {
  const chartData = Object.entries(byType)
    .filter(([, v]) => v > 0)
    .map(([key, value]) => ({
      name: t(OPP_TYPE_LABEL_KEYS[key] || key),
      value,
      color: OPP_TYPE_COLORS[key] || '#9ca3af',
    }))

  if (chartData.length === 0) {
    return <div style={{ color: '#9ca3af', fontSize: 13, textAlign: 'center', padding: '40px 0' }}>{t('overview.opportunities.empty')}</div>
  }

  return (
    <div>
      <div style={{ position: 'relative', height: 160 }}>
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie data={chartData} cx="50%" cy="50%" innerRadius={50} outerRadius={68} dataKey="value" paddingAngle={2} startAngle={90} endAngle={-270}>
              {chartData.map((entry, i) => <Cell key={i} fill={entry.color} stroke="none" />)}
            </Pie>
            <Tooltip
              formatter={(value, name) => [`${value} opportunité${value > 1 ? 's' : ''}`, name]}
              contentStyle={{ fontSize: 12, borderRadius: 8, border: '1px solid #e5e7eb' }}
            />
          </PieChart>
        </ResponsiveContainer>
        <div style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', textAlign: 'center', pointerEvents: 'none' }}>
          <div style={{ fontSize: 22, fontWeight: 700, color: '#1f2937', lineHeight: 1 }}>{total}</div>
          <div style={{ fontSize: 10, color: '#6b7280', marginTop: 2 }}>total</div>
        </div>
      </div>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px 14px', marginTop: 10 }}>
        {chartData.map((d, i) => (
          <span key={i} style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 11, color: '#374151' }}>
            <span style={{ width: 8, height: 8, borderRadius: '50%', background: d.color, display: 'inline-block' }} />
            {d.name} <span style={{ color: '#9ca3af' }}>({d.value})</span>
          </span>
        ))}
      </div>
    </div>
  )
}

function StageBarChart({ data, t }) {
  const chartData = data.map(d => ({
    name: t(STAGE_LABEL_KEYS[d.stage] || d.stage),
    count: d.count,
    mw: d.total_mw,
    color: STAGE_COLORS[d.stage] || '#9ca3af',
  }))

  const hasData = chartData.some(d => d.count > 0)
  if (!hasData) {
    return <div style={{ color: '#9ca3af', fontSize: 13, textAlign: 'center', padding: '40px 0' }}>{t('overview.analytics.empty')}</div>
  }

  return (
    <ResponsiveContainer width="100%" height={210}>
      <BarChart data={chartData} layout="vertical" margin={{ top: 0, right: 30, left: 0, bottom: 0 }}>
        <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#f3f4f6" />
        <XAxis type="number" tick={{ fontSize: 11, fill: '#9ca3af' }} tickLine={false} axisLine={false} />
        <YAxis
          type="category"
          dataKey="name"
          tick={{ fontSize: 11, fill: '#374151' }}
          tickLine={false}
          axisLine={false}
          width={90}
        />
        <Tooltip
          formatter={(value, _name, props) => [
            `${value} ${value > 1 ? t('overview.tooltip.projects') : t('overview.tooltip.project')}${props.payload.mw ? ` · ${props.payload.mw} MW` : ''}`,
            t('overview.tooltip.projects'),
          ]}
          contentStyle={{ fontSize: 12, borderRadius: 8, border: '1px solid #e5e7eb' }}
        />
        <Bar dataKey="count" radius={[0, 6, 6, 0]} maxBarSize={22}>
          {chartData.map((entry, i) => <Cell key={i} fill={entry.color} />)}
        </Bar>
      </BarChart>
    </ResponsiveContainer>
  )
}

// ─── Main component ───────────────────────────────────────────────────────────

const TYPE_ROUTE = {
  prospect: '/prospects',
  investor: '/investors',
  project: '/projects',
  scouting: '/scouting',
  opportunity: '/opportunities',
}

function GlobalSearch() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [loading, setLoading] = useState(false)
  const [open, setOpen] = useState(false)
  const inputRef = useRef(null)
  const wrapRef = useRef(null)
  const debounceRef = useRef(null)

  const search = useCallback((q) => {
    if (!q.trim() || q.trim().length < 2) { setResults([]); setOpen(false); return }
    setLoading(true)
    api.get('/search/global', { params: { q: q.trim() } })
      .then(r => { setResults(r.data.results || []); setOpen(true) })
      .catch(() => setResults([]))
      .finally(() => setLoading(false))
  }, [])

  const handleChange = (e) => {
    const v = e.target.value
    setQuery(v)
    clearTimeout(debounceRef.current)
    if (v.trim().length < 2) { setResults([]); setOpen(false); return }
    debounceRef.current = setTimeout(() => search(v), 280)
  }

  useEffect(() => {
    const handler = (e) => {
      if (wrapRef.current && !wrapRef.current.contains(e.target)) setOpen(false)
    }
    document.addEventListener('mousedown', handler)
    return () => document.removeEventListener('mousedown', handler)
  }, [])

  const handleKey = (e) => {
    if (e.key === 'Escape') { setOpen(false); inputRef.current?.blur() }
  }

  return (
    <div ref={wrapRef} style={{ position: 'relative', marginBottom: 18 }}>
      <div style={{
        display: 'flex', alignItems: 'center', gap: 10,
        background: '#fff', border: '2px solid ' + (open ? '#2563eb' : '#e5e7eb'),
        borderRadius: 12, padding: '10px 16px',
        boxShadow: open ? '0 0 0 3px #2563eb22' : '0 1px 4px rgba(0,0,0,0.06)',
        transition: 'border-color 0.15s, box-shadow 0.15s',
      }}>
        <span style={{ fontSize: 18, opacity: 0.4 }}>🔍</span>
        <input
          ref={inputRef}
          value={query}
          onChange={handleChange}
          onKeyDown={handleKey}
          onFocus={() => { if (results.length > 0) setOpen(true) }}
          placeholder="Rechercher partout — prospects, investisseurs, projets, scouting, opportunités..."
          style={{
            flex: 1, border: 'none', outline: 'none', fontSize: 14,
            fontFamily: 'inherit', color: '#1f2937', background: 'transparent',
          }}
        />
        {loading && <span style={{ fontSize: 12, color: '#9ca3af' }}>…</span>}
        {query && !loading && (
          <button onClick={() => { setQuery(''); setResults([]); setOpen(false) }}
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#9ca3af', fontSize: 16, padding: 0 }}>✕</button>
        )}
      </div>

      {open && results.length > 0 && (
        <div style={{
          position: 'absolute', top: '100%', left: 0, right: 0, zIndex: 999,
          background: '#fff', border: '1px solid #e5e7eb', borderRadius: 12,
          boxShadow: '0 8px 30px rgba(0,0,0,0.12)', marginTop: 6,
          maxHeight: 420, overflowY: 'auto',
        }}>
          {results.map((r, i) => (
            <a key={i} href={TYPE_ROUTE[r.type] || '/'}
              onClick={() => setOpen(false)}
              style={{
                display: 'flex', alignItems: 'center', gap: 10,
                padding: '10px 16px', textDecoration: 'none',
                borderBottom: i < results.length - 1 ? '1px solid #f3f4f6' : 'none',
                cursor: 'pointer',
              }}
              onMouseEnter={e => e.currentTarget.style.background = '#f9fafb'}
              onMouseLeave={e => e.currentTarget.style.background = '#fff'}
            >
              <span style={{
                fontSize: 10, fontWeight: 700, padding: '2px 7px', borderRadius: 10,
                background: r.type_color + '18', color: r.type_color,
                minWidth: 72, textAlign: 'center', flexShrink: 0,
              }}>
                {r.type_label}
              </span>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 600, color: '#1f2937', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  {r.title}
                </div>
                {r.subtitle && (
                  <div style={{ fontSize: 11, color: '#6b7280', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                    {r.subtitle}
                  </div>
                )}
              </div>
              <div style={{ display: 'flex', gap: 6, flexShrink: 0, alignItems: 'center' }}>
                {r.country && <span style={{ fontSize: 10, color: '#9ca3af' }}>{r.country}</span>}
                {r.meta && <span style={{ fontSize: 10, color: '#9ca3af', background: '#f3f4f6', borderRadius: 6, padding: '1px 6px' }}>{r.meta}</span>}
              </div>
            </a>
          ))}
          <div style={{ padding: '8px 16px', fontSize: 11, color: '#9ca3af', borderTop: '1px solid #f3f4f6', background: '#fafafa', borderRadius: '0 0 12px 12px' }}>
            {results.length} résultat{results.length > 1 ? 's' : ''} pour « {query} »
          </div>
        </div>
      )}

      {open && query.trim().length >= 2 && results.length === 0 && !loading && (
        <div style={{
          position: 'absolute', top: '100%', left: 0, right: 0, zIndex: 999,
          background: '#fff', border: '1px solid #e5e7eb', borderRadius: 12,
          boxShadow: '0 8px 30px rgba(0,0,0,0.12)', marginTop: 6,
          padding: '20px 16px', textAlign: 'center', color: '#9ca3af', fontSize: 13,
        }}>
          Aucun résultat pour « {query} »
        </div>
      )}
    </div>
  )
}

export default function Overview() {
  const { t } = useLang()
  const [stats, setStats] = useState({})
  const [agenda, setAgenda] = useState({ events: [], last_synced: null })
  const [projectStats, setProjectStats] = useState({ total: 0, total_mw: 0, by_technology: [], by_stage: [] })
  const [oppStats, setOppStats] = useState({ total: 0, by_type: {}, by_status: {} })
  const [prep, setPrep] = useState(null) // { company, loading, data, error }

  const handlePrep = async (title) => {
    setPrep({ company: title, loading: true, data: null, error: null, saving: false })
    try {
      const company = title.split('—')[0].split('–')[0].trim()
      const r = await api.get(`/prep/${encodeURIComponent(company)}`)
      const prepData = r.data
      setPrep({
        company: title,
        companyName: prepData.company || company,
        loading: false,
        data: prepData,
        error: null,
        saving: false,
        // Editable state
        editTalkingPoints: prepData.prep?.talking_points || [],
        editQuestions: prepData.prep?.questions || [],
        editChecklist: (prepData.prep?.checklist || []).map(c => ({ ...c })),
        editNextSteps: prepData.prep?.next_steps || [],
        editPersonalNotes: prepData.prep?.personal_notes || '',
        prepId: prepData.prep?.id,
        hasChanges: false,
      })
    } catch (e) {
      setPrep({ company: title, loading: false, data: null, error: e.response?.data?.detail || 'Entreprise non trouvée', saving: false })
    }
  }

  const handleSavePrep = async () => {
    if (!prep || !prep.data) return
    setPrep({ ...prep, saving: true })
    try {
      const company = prep.company.split('—')[0].split('–')[0].trim()
      await api.post(`/prep/${encodeURIComponent(company)}/save`, {
        talking_points: prep.editTalkingPoints,
        questions: prep.editQuestions,
        next_steps: prep.editNextSteps,
        personal_notes: prep.editPersonalNotes,
        context: prep.data.prep?.context || '',
        event_title: prep.company,
      })
      setPrep({ ...prep, saving: false, hasChanges: false, prepId: prep.prepId || 'saved' })
    } catch (e) {
      setPrep({ ...prep, saving: false })
      alert('Erreur lors de la sauvegarde')
    }
  }

  const handleRegeneratePrep = async () => {
    if (!prep || !prep.data) return
    setPrep({ ...prep, loading: true })
    try {
      const company = prep.company.split('—')[0].split('–')[0].trim()
      const r = await api.get(`/prep/${encodeURIComponent(company)}`)
      const prepData = r.data
      setPrep({
        ...prep,
        loading: false,
        data: prepData,
        editTalkingPoints: prepData.prep?.talking_points || [],
        editQuestions: prepData.prep?.questions || [],
        editChecklist: (prepData.prep?.checklist || []).map(c => ({ ...c })),
        editNextSteps: prepData.prep?.next_steps || [],
        editPersonalNotes: prepData.prep?.personal_notes || '',
        hasChanges: false,
      })
    } catch (e) {
      setPrep({ ...prep, loading: false })
    }
  }

  useEffect(() => {
    Promise.all([
      api.get('/prospects/stats/summary'),
      api.get('/investors/stats/summary'),
      api.get('/scouting/stats/summary'),
    ]).then(([p, inv, sc]) => {
      setStats({ prospects: p.data, investors: inv.data, scouting: sc.data })
    }).catch(() => {})

    api.get('/calendar/events?limit=8').then(r => setAgenda(r.data)).catch(() => {})
    api.get('/projects/stats/analytics').then(r => setProjectStats(r.data)).catch(() => {})
    api.get('/opportunities/stats/summary').then(r => setOppStats(r.data)).catch(() => {})
  }, [])

  const p   = stats.prospects || {}
  const inv = stats.investors || {}
  const sc  = stats.scouting  || {}

  const pByStatus   = p.by_status   || {}
  const invByStatus = inv.by_status || {}
  const scByStatus  = sc.by_status  || {}

  const hotPipeline = ['in_discussion', 'meeting_scheduled', 'nda_signed', 'deal_in_progress']
    .reduce((sum, k) => sum + (pByStatus[k] || 0), 0)

  const pMax   = Math.max(...PIPELINE_STAGES.map(s => pByStatus[s.key]   || 0), 1)
  const invMax = Math.max(...INVESTOR_STATUSES.map(s => invByStatus[s.key] || 0), 1)
  const scMax  = Math.max(...SCOUTING_STATUSES.map(s => scByStatus[s.key]  || 0), 1)

  return (
    <div style={{ maxWidth: 1200 }}>
      <h1 style={{ fontSize: 20, fontWeight: 700, marginBottom: 16, color: '#1f2937' }}>
        {t('overview.title')}
      </h1>

      <GlobalSearch />

      <DevStageBar />

      {/* KPI Row */}
      <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', marginBottom: 16 }}>
        <KPI label={t('overview.kpi.prospects')}       value={p.total}               color="#2563eb" icon="🏢" />
        <KPI label={t('overview.kpi.hotPipeline')}     value={hotPipeline}           color="#7c3aed" icon="🔥" sub={t('overview.kpi.hotPipelineSub')} />
        <KPI label={t('overview.kpi.ndaSigned')}       value={p.nda_signed}          color="#16a34a" icon="✍️" />
        <KPI label={t('overview.kpi.activeInvestors')} value={invByStatus['active']} color="#0891b2" icon="💼" />
        <KPI label={t('overview.kpi.projects')}        value={projectStats.total}    color="#d97706" icon="⚡" />
        <KPI label={t('overview.kpi.capacity')}        value={projectStats.total_mw ? `${projectStats.total_mw} MW` : '—'} color="#059669" icon="📊" />
        <KPI label={t('overview.kpi.opportunities')}   value={oppStats.total}        color="#0891b2" icon="🎯" />
      </div>

      {/* Analytics Row */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 14, marginBottom: 14 }}>
        <Panel title={t('overview.analytics.tech')}>
          <TechDonut data={projectStats.by_technology} total={projectStats.total} t={t} />
        </Panel>

        <Panel title={t('overview.analytics.stage')}>
          <StageBarChart data={projectStats.by_stage} t={t} />
        </Panel>

        <Panel title={t('overview.opportunities.byType')}>
          <OppTypeDonut byType={oppStats.by_type || {}} total={oppStats.total} t={t} />
        </Panel>
      </div>

      {/* Calendar Row */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: 14, marginBottom: 14 }}>
        <Panel title={
          <span style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', width: '100%' }}>
            <span>{t('overview.calendar.title')}</span>
            {agenda.last_synced && (
              <span style={{ fontSize: 10, color: '#9ca3af', fontWeight: 400 }}>
                {t('overview.calendar.synced')} {new Date(agenda.last_synced).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })}
              </span>
            )}
          </span>
        }>
          <div style={{ display: 'flex', gap: 10, marginBottom: 10, fontSize: 10, color: '#9ca3af' }}>
            <span><span style={{ display: 'inline-block', width: 7, height: 7, borderRadius: '50%', background: '#2563eb', marginRight: 3 }} />{t('overview.calendar.external')}</span>
            <span><span style={{ display: 'inline-block', width: 7, height: 7, borderRadius: '50%', background: '#7c3aed', marginRight: 3 }} />{t('overview.calendar.internal')}</span>
            <span><span style={{ display: 'inline-block', width: 7, height: 7, borderRadius: '50%', background: '#ea580c', marginRight: 3 }} />{t('overview.calendar.personal')}</span>
          </div>
          {agenda.events.length === 0
            ? <div style={{ color: '#9ca3af', fontSize: 13 }}>{t('overview.calendar.empty')}</div>
            : agenda.events.map(ev => <AgendaRow key={ev.id} event={ev} t={t} onPrep={handlePrep} />)
          }
        </Panel>
      </div>

      {/* CRM Status Row */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: 14 }}>
        <Panel title={t('overview.pipeline.title')}>
          {(p.total || 0) === 0
            ? <div style={{ color: '#9ca3af', fontSize: 13 }}>{t('overview.pipeline.empty')}</div>
            : PIPELINE_STAGES.map(({ key, color }) => (
              <StatusBar key={key} label={t('status.' + key)} count={pByStatus[key] || 0} max={pMax} color={color} total={p.total} />
            ))
          }
        </Panel>
      </div>
      {prep && <PrepPanel prep={prep} onClose={() => setPrep(null)} onSave={handleSavePrep} onRegenerate={handleRegeneratePrep} setPrep={setPrep} t={t} />}
    </div>
  )
}



function PrepPanel({ prep, onClose, onSave, onRegenerate, setPrep, t }) {
  if (!prep) return null

  const updateItem = (field, index, value) => {
    const items = [...(prep[field] || [])]
    items[index] = value
    setPrep({ ...prep, [field]: items, hasChanges: true })
  }

  const removeItem = (field, index) => {
    const items = [...(prep[field] || [])]
    items.splice(index, 1)
    setPrep({ ...prep, [field]: items, hasChanges: true })
  }

  const addItem = (field) => {
    const items = [...(prep[field] || []), '']
    setPrep({ ...prep, [field]: items, hasChanges: true })
  }

  const p = prep.data?.prospect
  const inv = prep.data?.investor
  const prepData = prep.data?.prep || {}

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)', zIndex: 200, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 16 }}
      onClick={onClose}>
      <div onClick={e => e.stopPropagation()} style={{ background: '#fff', borderRadius: 12, width: '100%', maxWidth: 640, maxHeight: '90vh', overflowY: 'auto' }}>
        {/* Header */}
        <div style={{ position: 'sticky', top: 0, background: '#fff', zIndex: 10, borderBottom: '1px solid #e5e7eb', padding: '16px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <div style={{ fontSize: 10, fontWeight: 700, color: '#059669', letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 2 }}>📋 Meeting Prep</div>
            <h2 style={{ fontSize: 17, fontWeight: 700, color: '#1f2937', margin: 0 }}>{prep.company}</h2>
          </div>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <button onClick={onRegenerate}
              style={{ fontSize: 11, padding: '6px 12px', borderRadius: 6, border: '1px solid #d1d5db', background: '#f9fafb', cursor: 'pointer', color: '#374151' }}>
              🔄 Régénérer
            </button>
            <button onClick={onSave} disabled={prep.saving}
              style={{
                fontSize: 11, padding: '6px 14px', borderRadius: 6, border: 'none', cursor: 'pointer',
                background: prep.hasChanges ? '#059669' : '#9ca3af', color: '#fff', fontWeight: 600,
              }}>
              {prep.saving ? '💾...' : '💾 Sauvegarder'}
            </button>
            <button onClick={onClose} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#9ca3af', fontSize: 18, padding: '0 4px' }}>✕</button>
          </div>
        </div>

        <div style={{ padding: '16px 20px' }}>
          {prep.loading && <div style={{ color: '#9ca3af', fontSize: 14, padding: 30, textAlign: 'center' }}>Chargement...</div>}

          {prep.error && (
            <div style={{ background: '#fef2f2', borderRadius: 8, padding: 16, color: '#dc2626', fontSize: 13 }}>
              ❌ {prep.error}
              <div style={{ marginTop: 8, color: '#6b7280', fontSize: 12 }}>Aucune donnée CRM trouvée pour cette entreprise.</div>
            </div>
          )}

          {prep.data && (
            <>
              {/* Company Info */}
              {p && (
                <div style={{ background: '#f0fdf4', borderRadius: 8, padding: '10px 14px', marginBottom: 14, fontSize: 12, color: '#374151', display: 'flex', flexWrap: 'wrap', gap: '4px 16px' }}>
                  <span><strong>🏢</strong> {p.company}</span>
                  <span><strong>📌</strong> {p.status?.replace(/_/g, ' ')}</span>
                  <span><strong>✍️</strong> NDA: {p.nda_signed === 'Oui' ? '✅ Signé' : '❌ Non'}</span>
                  {p.country && <span><strong>📍</strong> {p.country}</span>}
                  {p.contact && <span><strong>👤</strong> {p.contact}</span>}
                </div>
              )}

              {/* Context summary */}
              {prepData.context && (
                <div style={{ background: '#f9fafb', borderRadius: 8, padding: '10px 14px', marginBottom: 14, fontSize: 12, color: '#6b7280' }}>
                  {prepData.context}
                </div>
              )}

              {/* Deal info */}
              {prep.data.opportunities?.length > 0 && (
                <div style={{ background: '#fffbeb', borderRadius: 8, padding: '10px 14px', marginBottom: 14, fontSize: 12, color: '#92400e' }}>
                  <strong>💰 Deal(s) en cours:</strong>
                  {prep.data.opportunities.map((o, i) => (
                    <div key={i} style={{ marginTop: 4 }}>
                      • {o.title} — {o.size_eur ? `${o.size_eur}M€` : ''}{o.size_mw ? ` | ${o.size_mw} MW` : ''} ({o.status})
                    </div>
                  ))}
                </div>
              )}

              {/* Matching opportunities from BDD */}
              {prep.data.matching_opportunities?.length > 0 && (
                <div style={{ background: '#eff6ff', borderRadius: 8, padding: '10px 14px', marginBottom: 14, fontSize: 12, color: '#1e40af' }}>
                  <strong>🔍 Opportunités BDD qui matchent</strong>
                  {prep.data.matching_opportunities.map((o, i) => (
                    <div key={i} style={{ marginTop: 4 }}>
                      • {o.title}{o.size_mw ? ` — ${o.size_mw} MW` : ''}{o.country ? ` (${o.country})` : ''}
                    </div>
                  ))}
                </div>
              )}

              {/* Matching projects from BDD */}
              {prep.data.matching_projects?.length > 0 && (
                <div style={{ background: '#f5f3ff', borderRadius: 8, padding: '10px 14px', marginBottom: 14, fontSize: 12, color: '#5b21b6' }}>
                  <strong>📋 Projets BDD qui matchent</strong>

                  {(() => {
                    const projects = prep.data.matching_projects;

                    // Summary by stage
                    const stageSummary = {};
                    const stageLabels = {'development': 'Développement', 'permitting': 'Permis', 'ready_to_build': 'RTB', 'construction': 'Construction', 'operational': 'Exploitation'};
                    projects.forEach(p => {
                      const s = stageLabels[p.stage] || p.stage;
                      if (!stageSummary[s]) stageSummary[s] = { count: 0, mw: 0 };
                      stageSummary[s].count++;
                      stageSummary[s].mw += p.capacity_mw || 0;
                    });

                    // Group by clean type
                    const groups = {};
                    const getLabel = (p) => {
                      const raw = (p.technology_detail || p.technology || '').toLowerCase();
                      if (raw.includes('agripv')) return 'AgriPV';
                      if (raw.includes('sol')) return 'Solaire au sol';
                      if (raw.includes('eolien')) return 'Éolien';
                      if (raw.includes('bess')) return 'Stockage';
                      return p.technology_detail || p.technology || 'Autre';
                    };
                    projects.forEach(p => {
                      const l = getLabel(p);
                      if (!groups[l]) groups[l] = [];
                      groups[l].push(p);
                    });

                    return (
                      <>
                        {/* Stage summary */}
                        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 8, marginBottom: 10 }}>
                          {Object.entries(stageSummary).map(([stage, info]) => (
                            <div key={stage} style={{
                              background: '#ede9fe', borderRadius: 6, padding: '4px 10px',
                              fontSize: 11, color: '#5b21b6', fontWeight: 600,
                            }}>
                              {stage}: {info.count} projets ({Math.round(info.mw)} MW)
                            </div>
                          ))}
                        </div>

                        {/* Detail by type */}
                        {Object.entries(groups).map(([type, projs]) => (
                          <div key={type} style={{ marginTop: 8 }}>
                            <div style={{ fontWeight: 600, color: '#7c3aed', marginBottom: 3 }}>
                              {type} — {projs.reduce((s, p) => s + (p.capacity_mw || 0), 0)} MW ({projs.length} projets)
                            </div>
                            {projs.map((p, i) => {
                              const stageLabel = stageLabels[p.stage] || p.stage;
                              const isOpen = prep.expandedProject === (type + '_' + i);
                              return (
                              <div key={i}>
                                <div
                                  onClick={() => setPrep({ ...prep, expandedProject: isOpen ? null : type + '_' + i })}
                                  style={{
                                    marginTop: 2, padding: '4px 8px', cursor: 'pointer', borderRadius: 4,
                                    background: isOpen ? '#f0e6ff' : 'transparent',
                                  }}
                                >
                                  • <strong>{p.name}</strong> — {p.capacity_mw} MW ({stageLabel}){p.region ? ` — ${p.region}` : p.department ? ` — ${p.department}` : ''}
                                </div>
                                {isOpen && (
                                  <div style={{
                                    marginLeft: 12, marginTop: 4, marginBottom: 6, padding: 8,
                                    background: '#faf5ff', borderRadius: 6, fontSize: 11, lineHeight: 1.6, color: '#4c1d95',
                                  }}>
                                    {p.developer && <div>👤 Développeur: {p.developer}</div>}
                                    {p.stage && <div>📌 Stade: {stageLabel}</div>}
                                    {p.capacity_mw && <div>⚡ Capacité: {p.capacity_mw} MW</div>}
                                    {p.country && <div>📍 Pays: {p.country}</div>}
                                    {p.region ? <div>🗺️ Région: {p.region}</div> : p.department ? <div>📍 Département: {p.department}</div> : null}
                                    {p.rtb_date && <div>📅 Date RTB: {p.rtb_date}</div>}
                                    {p.cod_date && <div>📅 Date COD: {p.cod_date}</div>}
                                    {p.description && <div style={{ marginTop: 4 }}>📝 {p.description}</div>}
                                  </div>
                                )}
                              </div>
                            );})}
                          </div>
                        ))}
                      </>
                    );
                  })()}
                </div>
              )}

              {/* ✅ Checklist rapide */}
              {prep.editChecklist?.length > 0 && (
                <div style={{ background: '#fefce8', borderRadius: 8, padding: '10px 14px', marginBottom: 14, fontSize: 12, color: '#713f12' }}>
                  <strong style={{ fontSize: 13 }}>✅ Checklist rapide</strong>
                  <div style={{ fontSize: 11, color: '#a16207', marginBottom: 8 }}>À clarifier vite avec le client pendant l'appel</div>
                  {prep.editChecklist.map((item, i) => {
                    const done = item.done;
                    const sel = item.value;
                    return (
                      <div key={i} style={{
                        display: 'flex', alignItems: 'center', gap: 6, padding: '5px 6px',
                        borderRadius: 6, marginBottom: 3,
                        background: done ? '#f0fdf4' : '#fff',
                        border: '1px solid', borderColor: done ? '#bbf7d0' : '#fef08a',
                      }}>
                        {/* Checkbox */}
                        <div onClick={() => {
                          const c = [...prep.editChecklist];
                          c[i] = { ...c[i], done: !c[i].done };
                          setPrep({ ...prep, editChecklist: c, hasChanges: true });
                        }} style={{
                          width: 18, height: 18, borderRadius: 4, cursor: 'pointer', flexShrink: 0,
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                          background: done ? '#16a34a' : '#e5e7eb', color: '#fff', fontSize: 12, fontWeight: 700,
                        }}>{done ? '✓' : ''}</div>
                        {/* Label */}
                        <div style={{ minWidth: 130, fontWeight: 500, color: '#1f2937', flexShrink: 0 }}>{item.label}</div>
                        {/* Options chips */}
                        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 3, flex: 1 }}>
                          {item.options ? item.options.map((opt, j) => (
                            <span key={j} onClick={() => {
                              const c = [...prep.editChecklist];
                              c[i] = { ...c[i], value: c[i].value === opt ? '' : opt };
                              setPrep({ ...prep, editChecklist: c, hasChanges: true });
                            }} style={{
                              padding: '2px 8px', borderRadius: 10, cursor: 'pointer', fontSize: 11,
                              background: sel === opt ? '#2563eb' : '#f3f4f6',
                              color: sel === opt ? '#fff' : '#374151',
                              fontWeight: sel === opt ? 600 : 400,
                              border: '1px solid', borderColor: sel === opt ? '#2563eb' : '#e5e7eb',
                            }}>{opt}</span>
                          )) : (
                            <input value={sel} onChange={e => {
                              const c = [...prep.editChecklist];
                              c[i] = { ...c[i], value: e.target.value };
                              setPrep({ ...prep, editChecklist: c, hasChanges: true });
                            }} placeholder="..." style={{
                              width: '100%', padding: '3px 8px', border: '1px solid #e5e7eb',
                              borderRadius: 4, fontSize: 11, background: '#fff', color: '#374151',
                            }} />
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}

              {/* Editable: Talking Points */}
              <Section title="🎯 Points clés">
                {(prep.editTalkingPoints || []).map((pt, i) => (
                  <div key={i} style={{ display: 'flex', gap: 6, marginBottom: 6, alignItems: 'flex-start' }}>
                    <textarea
                      value={pt}
                      onChange={e => updateItem('editTalkingPoints', i, e.target.value)}
                      style={{
                        flex: 1, fontSize: 13, lineHeight: 1.5, fontFamily: 'inherit',
                        padding: '6px 8px', borderRadius: 6, border: '1px solid #e5e7eb',
                        resize: 'vertical', minHeight: 36, background: '#fff',
                        color: '#374151',
                      }}
                      rows={Math.max(2, pt.split('\n').length)}
                    />
                    <button onClick={() => removeItem('editTalkingPoints', i)}
                      style={{ background: '#fef2f2', border: '1px solid #fecaca', borderRadius: 6, cursor: 'pointer', color: '#dc2626', fontSize: 14, padding: '4px 8px', marginTop: 2 }}>✕</button>
                  </div>
                ))}
                <button onClick={() => addItem('editTalkingPoints')}
                  style={{ fontSize: 12, padding: '4px 12px', borderRadius: 6, border: '1px dashed #d1d5db', background: '#f9fafb', cursor: 'pointer', color: '#6b7280', width: '100%', marginTop: 4 }}>
                  + Ajouter un point
                </button>
              </Section>

              {/* Editable: Questions */}
              <Section title="❓ Questions à poser">
                {(prep.editQuestions || []).map((q, i) => (
                  <div key={i} style={{ display: 'flex', gap: 6, marginBottom: 6, alignItems: 'flex-start' }}>
                    <input
                      type="text"
                      value={q}
                      onChange={e => updateItem('editQuestions', i, e.target.value)}
                      style={{
                        flex: 1, fontSize: 13, padding: '6px 8px', borderRadius: 6, border: '1px solid #e5e7eb',
                        fontFamily: 'inherit', color: '#374151',
                      }}
                    />
                    <button onClick={() => removeItem('editQuestions', i)}
                      style={{ background: '#fef2f2', border: '1px solid #fecaca', borderRadius: 6, cursor: 'pointer', color: '#dc2626', fontSize: 14, padding: '4px 8px', marginTop: 2 }}>✕</button>
                  </div>
                ))}
                <button onClick={() => addItem('editQuestions')}
                  style={{ fontSize: 12, padding: '4px 12px', borderRadius: 6, border: '1px dashed #d1d5db', background: '#f9fafb', cursor: 'pointer', color: '#6b7280', width: '100%', marginTop: 4 }}>
                  + Ajouter une question
                </button>
              </Section>

              {/* Editable: Next Steps */}
              <Section title="➡️ Next steps">
                {(prep.editNextSteps || []).map((ns, i) => (
                  <div key={i} style={{ display: 'flex', gap: 6, marginBottom: 6, alignItems: 'flex-start' }}>
                    <input
                      type="text"
                      value={ns}
                      onChange={e => updateItem('editNextSteps', i, e.target.value)}
                      style={{
                        flex: 1, fontSize: 13, padding: '6px 8px', borderRadius: 6, border: '1px solid #e5e7eb',
                        fontFamily: 'inherit', color: '#374151',
                      }}
                    />
                    <button onClick={() => removeItem('editNextSteps', i)}
                      style={{ background: '#fef2f2', border: '1px solid #fecaca', borderRadius: 6, cursor: 'pointer', color: '#dc2626', fontSize: 14, padding: '4px 8px', marginTop: 2 }}>✕</button>
                  </div>
                ))}
                <button onClick={() => addItem('editNextSteps')}
                  style={{ fontSize: 12, padding: '4px 12px', borderRadius: 6, border: '1px dashed #d1d5db', background: '#f9fafb', cursor: 'pointer', color: '#6b7280', width: '100%', marginTop: 4 }}>
                  + Ajouter un next step
                </button>
              </Section>

              {/* Editable: Personal Notes */}
              <Section title="📝 Notes personnelles">
                <textarea
                  value={prep.editPersonalNotes || ''}
                  onChange={e => setPrep({ ...prep, editPersonalNotes: e.target.value, hasChanges: true })}
                  placeholder="Tes notes, observations, éléments à ne pas oublier..."
                  style={{
                    width: '100%', fontSize: 13, lineHeight: 1.6, fontFamily: 'inherit',
                    padding: '10px 12px', borderRadius: 8, border: '1px solid #e5e7eb',
                    resize: 'vertical', minHeight: 80, color: '#374151',
                    background: '#fafafa',
                  }}
                  rows={4}
                />
              </Section>
            </>
          )}
        </div>
      </div>
    </div>
  )
}

function Section({ title, children }) {
  return (
    <div style={{ marginBottom: 16 }}>
      <div style={{ fontSize: 12, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', letterSpacing: '0.05em', marginBottom: 8, borderBottom: '1px solid #e5e7eb', paddingBottom: 4 }}>{title}</div>
      {children}
    </div>
  )
}

function Line({ label, value }) {
  return (
    <div style={{ display: 'flex', gap: 8, fontSize: 13, padding: '3px 0' }}>
      <span style={{ color: '#9ca3af', minWidth: 60 }}>{label}</span>
      <span style={{ color: '#1f2937' }}>{value}</span>
    </div>
  )
}
