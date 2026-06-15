import { useEffect, useState } from 'react'
import api from '../api/client'

const EVENT_COLORS = {
  external: { bg: '#eff6ff', border: '#3b82f6', dot: '#2563eb', label: 'Ext.' },
  internal: { bg: '#f5f3ff', border: '#8b5cf6', dot: '#7c3aed', label: 'Int.' },
  personal: { bg: '#fff7ed', border: '#f97316', dot: '#ea580c', label: '' },
}

function formatEventDate(isoStr) {
  const d = new Date(isoStr)
  const today = new Date()
  const tomorrow = new Date(today)
  tomorrow.setDate(today.getDate() + 1)

  const sameDay = (a, b) =>
    a.getDate() === b.getDate() && a.getMonth() === b.getMonth() && a.getFullYear() === b.getFullYear()

  const dayFR = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam']
  const time = d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })

  if (sameDay(d, today)) return { badge: "Auj.", badgeColor: '#16a34a', time }
  if (sameDay(d, tomorrow)) return { badge: "Demain", badgeColor: '#2563eb', time }
  return {
    badge: `${dayFR[d.getDay()]} ${d.getDate()}/${String(d.getMonth() + 1).padStart(2, '0')}`,
    badgeColor: '#6b7280',
    time,
  }
}

function AgendaRow({ event }) {
  const { badge, badgeColor, time } = formatEventDate(event.start)
  const colors = EVENT_COLORS[event.type] || EVENT_COLORS.internal

  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      padding: '8px 0', borderBottom: '1px solid #f3f4f6', fontSize: 13,
    }}>
      <span style={{
        minWidth: 60, fontSize: 11, fontWeight: 600, color: badgeColor,
        background: badgeColor + '15', borderRadius: 4, padding: '2px 6px', textAlign: 'center',
      }}>{badge}</span>
      <span style={{ minWidth: 42, color: '#6b7280', fontSize: 12 }}>{time}</span>
      <span style={{
        width: 8, height: 8, borderRadius: '50%',
        background: colors.dot, flexShrink: 0,
      }} />
      <span style={{ flex: 1, color: '#1f2937', fontWeight: 500, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
        {event.title}
      </span>
      {event.meet_url && (
        <a href={event.meet_url} target="_blank" rel="noreferrer" style={{
          fontSize: 11, color: '#2563eb', background: '#eff6ff',
          borderRadius: 4, padding: '2px 7px', textDecoration: 'none',
          border: '1px solid #bfdbfe', flexShrink: 0,
        }}>
          {event.meet_url.includes('teams') ? 'Teams' : 'Meet'}
        </a>
      )}
    </div>
  )
}

const PIPELINE_STAGES = [
  { key: 'to_contact',        label: 'À contacter',    color: '#9ca3af' },
  { key: 'contacted',         label: 'Contacté',       color: '#60a5fa' },
  { key: 'in_discussion',     label: 'En discussion',  color: '#818cf8' },
  { key: 'meeting_scheduled', label: 'RDV planifié',   color: '#a78bfa' },
  { key: 'nda_signed',        label: 'NDA signé',      color: '#34d399' },
  { key: 'deal_in_progress',  label: 'Deal en cours',  color: '#fbbf24' },
  { key: 'closed',            label: 'Fermé',          color: '#10b981' },
  { key: 'rejected',          label: 'Rejeté',         color: '#f87171' },
]

const INVESTOR_STATUSES = [
  { key: 'to_contact',    label: 'À contacter',    color: '#9ca3af' },
  { key: 'contacted',     label: 'Contacté',       color: '#60a5fa' },
  { key: 'in_discussion', label: 'En discussion',  color: '#818cf8' },
  { key: 'active',        label: 'Actif',          color: '#34d399' },
  { key: 'inactive',      label: 'Inactif',        color: '#f87171' },
]

const SCOUTING_STATUSES = [
  { key: 'to_contact',     label: 'À contacter',    color: '#9ca3af' },
  { key: 'email_sent',     label: 'Email envoyé',   color: '#60a5fa' },
  { key: 'linkedin_sent',  label: 'LinkedIn envoyé',color: '#38bdf8' },
  { key: 'responded',      label: 'A répondu',      color: '#a78bfa' },
  { key: 'meeting_done',   label: 'RDV fait',       color: '#818cf8' },
  { key: 'converted',      label: 'Converti',       color: '#34d399' },
  { key: 'no_response',    label: 'Sans réponse',   color: '#fb923c' },
  { key: 'not_interested', label: 'Pas intéressé',  color: '#f87171' },
]

function KPI({ label, value, color, sub, icon }) {
  return (
    <div style={{
      background: '#fff',
      border: '1px solid #e5e7eb',
      borderTop: `3px solid ${color}`,
      borderRadius: 10,
      padding: '18px 20px',
      flex: 1,
      minWidth: 130,
    }}>
      <div style={{ fontSize: 11, color: '#6b7280', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 6 }}>
        {icon} {label}
      </div>
      <div style={{ fontSize: 30, fontWeight: 700, color }}>{value ?? '—'}</div>
      {sub && <div style={{ fontSize: 11, color: '#9ca3af', marginTop: 4 }}>{sub}</div>}
    </div>
  )
}

function StatusBar({ label, count, max, color, total }) {
  const barPct = max > 0 ? Math.round((count / max) * 100) : 0
  const ofTotal = total > 0 ? Math.round((count / total) * 100) : 0
  return (
    <div style={{ marginBottom: 12 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 5, fontSize: 12 }}>
        <span style={{ color: '#374151', display: 'flex', alignItems: 'center', gap: 7 }}>
          <span style={{ width: 8, height: 8, borderRadius: '50%', background: color, display: 'inline-block', flexShrink: 0 }} />
          {label}
        </span>
        <span style={{ color: '#6b7280', fontWeight: 600, minWidth: 40, textAlign: 'right' }}>
          {count}{total ? <span style={{ fontWeight: 400, color: '#9ca3af' }}> · {ofTotal}%</span> : ''}
        </span>
      </div>
      <div style={{ background: '#f3f4f6', borderRadius: 4, height: 6, overflow: 'hidden' }}>
        <div style={{
          background: color,
          width: `${barPct}%`,
          height: '100%',
          borderRadius: 4,
          transition: 'width 0.5s ease',
        }} />
      </div>
    </div>
  )
}

function Panel({ title, children }) {
  return (
    <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, padding: 20 }}>
      <h3 style={{ fontSize: 13, fontWeight: 600, color: '#1f2937', marginBottom: 18 }}>
        {title}
      </h3>
      {children}
    </div>
  )
}

export default function Overview() {
  const [stats, setStats] = useState({})
  const [agenda, setAgenda] = useState({ events: [], last_synced: null })

  useEffect(() => {
    Promise.all([
      api.get('/prospects/stats/summary'),
      api.get('/investors/stats/summary'),
      api.get('/scouting/stats/summary'),
    ]).then(([p, inv, sc]) => {
      setStats({ prospects: p.data, investors: inv.data, scouting: sc.data })
    }).catch(() => {})

    api.get('/calendar/events?limit=8')
      .then(r => setAgenda(r.data))
      .catch(() => {})
  }, [])

  const p   = stats.prospects  || {}
  const inv = stats.investors  || {}
  const sc  = stats.scouting   || {}

  const pByStatus   = p.by_status   || {}
  const invByStatus = inv.by_status || {}
  const scByStatus  = sc.by_status  || {}

  const hotPipeline = ['in_discussion', 'meeting_scheduled', 'nda_signed', 'deal_in_progress']
    .reduce((sum, k) => sum + (pByStatus[k] || 0), 0)

  const pMax   = Math.max(...PIPELINE_STAGES.map(s => pByStatus[s.key]   || 0), 1)
  const invMax = Math.max(...INVESTOR_STATUSES.map(s => invByStatus[s.key] || 0), 1)
  const scMax  = Math.max(...SCOUTING_STATUSES.map(s => scByStatus[s.key]  || 0), 1)

  return (
    <div style={{ maxWidth: 1100 }}>
      <h1 style={{ fontSize: 20, fontWeight: 700, marginBottom: 24, color: '#1f2937' }}>
        Vue d'ensemble
      </h1>

      <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', marginBottom: 24 }}>
        <KPI label="Prospects"          value={p.total}              color="#2563eb" icon="🏢" />
        <KPI label="Pipeline chaud"     value={hotPipeline}          color="#7c3aed" icon="🔥" sub="En discussion → Deal" />
        <KPI label="NDA Signés"         value={p.nda_signed}         color="#16a34a" icon="✍️" />
        <KPI label="Investisseurs actifs" value={invByStatus['active']} color="#0891b2" icon="💼" />
        <KPI label="Scouting"           value={sc.total}             color="#d97706" icon="🔍" />
      </div>

      <div style={{ marginBottom: 16 }}>
        <Panel title="🚀 Pipeline Prospects">
          {(p.total || 0) === 0 ? (
            <div style={{ color: '#9ca3af', fontSize: 13 }}>Aucun prospect pour l'instant.</div>
          ) : (
            PIPELINE_STAGES.map(({ key, label, color }) => (
              <StatusBar
                key={key}
                label={label}
                count={pByStatus[key] || 0}
                max={pMax}
                color={color}
                total={p.total}
              />
            ))
          )}
        </Panel>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 16 }}>
        <Panel title="💼 Investisseurs par statut">
          {INVESTOR_STATUSES.map(({ key, label, color }) => (
            <StatusBar
              key={key}
              label={label}
              count={invByStatus[key] || 0}
              max={invMax}
              color={color}
              total={inv.total}
            />
          ))}
        </Panel>

        <Panel title="📨 Scouting par statut">
          {SCOUTING_STATUSES.map(({ key, label, color }) => (
            <StatusBar
              key={key}
              label={label}
              count={scByStatus[key] || 0}
              max={scMax}
              color={color}
              total={sc.total}
            />
          ))}
        </Panel>
      </div>

      <Panel title={
        <span style={{ display: 'flex', justifyContent: 'space-between', width: '100%', alignItems: 'center' }}>
          <span>📅 Prochains rendez-vous</span>
          {agenda.last_synced && (
            <span style={{ fontSize: 11, color: '#9ca3af', fontWeight: 400 }}>
              Synchro {new Date(agenda.last_synced).toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })}
            </span>
          )}
        </span>
      }>
        <div style={{ display: 'flex', gap: 12, marginBottom: 12, fontSize: 11, color: '#6b7280' }}>
          <span><span style={{ display: 'inline-block', width: 8, height: 8, borderRadius: '50%', background: '#2563eb', marginRight: 4 }} />Externe</span>
          <span><span style={{ display: 'inline-block', width: 8, height: 8, borderRadius: '50%', background: '#7c3aed', marginRight: 4 }} />Interne</span>
          <span><span style={{ display: 'inline-block', width: 8, height: 8, borderRadius: '50%', background: '#ea580c', marginRight: 4 }} />Personnel</span>
        </div>
        {agenda.events.length === 0 ? (
          <div style={{ color: '#9ca3af', fontSize: 13 }}>Aucun événement à venir.</div>
        ) : (
          agenda.events.map(ev => <AgendaRow key={ev.id} event={ev} />)
        )}
      </Panel>
    </div>
  )
}
