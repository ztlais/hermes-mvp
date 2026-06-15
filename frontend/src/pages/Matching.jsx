import { useEffect, useState } from 'react'
import api from '../api/client'

const TECH_LABELS = { solar: '☀️ Solaire', wind: '💨 Éolien', bess: '🔋 BESS', hydro: '💧 Hydro', biomass: '🌿 Biomasse', other: '⚡ Autre' }
const STAGE_LABELS = { development: '🔧 Développement', permitting: '📋 Permitting', ready_to_build: '🟢 RTB', construction: '🏗️ Construction', operational: '⚡ Opérationnel' }

function ScoreBadge({ score }) {
  const color = score >= 80 ? { bg: '#d1fae5', text: '#065f46', border: '#6ee7b7' }
              : score >= 60 ? { bg: '#dbeafe', text: '#1e40af', border: '#93c5fd' }
              : score >= 40 ? { bg: '#fef3c7', text: '#92400e', border: '#fcd34d' }
              : { bg: '#fee2e2', text: '#991b1b', border: '#fca5a5' }
  return (
    <div style={{
      width: 56, height: 56, borderRadius: '50%', display: 'flex', alignItems: 'center',
      justifyContent: 'center', flexDirection: 'column', flexShrink: 0,
      background: color.bg, border: `2px solid ${color.border}`,
    }}>
      <div style={{ fontSize: 18, fontWeight: 800, color: color.text, lineHeight: 1 }}>{score}</div>
      <div style={{ fontSize: 9, color: color.text, opacity: 0.7 }}>/100</div>
    </div>
  )
}

function IntroModal({ match, onClose }) {
  const [copied, setCopied] = useState(false)

  const techLabel = TECH_LABELS[match.project_technology] || match.project_technology || ''
  const stageLabel = STAGE_LABELS[match.project_stage] || match.project_stage || ''

  const emailBody = `Bonjour ${match.investor_contact || match.investor_company},

J'espère que vous allez bien.

Dans le cadre de notre activité de conseil en transactions ENR, nous avons identifié un projet qui correspond à vos critères d'investissement :

📋 Projet : ${match.project_name}${match.project_developer ? `\n🏗️ Développeur : ${match.project_developer}` : ''}
⚡ Technologie : ${techLabel}
📊 Stade : ${stageLabel}
🔋 Capacité : ${match.project_capacity_mw ? `${match.project_capacity_mw} MWc` : 'À confirmer'}
🌍 Localisation : ${match.project_region || match.project_country || 'France'}

Ce projet présente un profil solide et répond à vos critères d'acquisition.

Seriez-vous disponible pour un échange cette semaine afin de vous présenter cette opportunité en détail ?

Dans l'attente de votre retour,

Cordialement,
Zein Tlais
EIR — ENECHANGE`

  const copy = () => {
    navigator.clipboard.writeText(emailBody)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 200, padding: 16 }}
      onClick={e => e.target === e.currentTarget && onClose()}>
      <div style={{ background: '#fff', borderRadius: 12, padding: 28, width: 620, maxHeight: '90vh', overflowY: 'auto', boxShadow: '0 25px 60px rgba(0,0,0,0.2)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
          <h2 style={{ fontSize: 18, fontWeight: 700, color: '#1f2937' }}>📧 Email d'introduction</h2>
          <button onClick={onClose} style={{ background: 'none', border: 'none', fontSize: 20, cursor: 'pointer', color: '#9ca3af' }}>✕</button>
        </div>

        <div style={{ background: '#f9fafb', borderRadius: 8, padding: 12, marginBottom: 16, display: 'flex', gap: 16 }}>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 11, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 2 }}>Destinataire</div>
            <div style={{ fontWeight: 700, color: '#1f2937' }}>{match.investor_company}</div>
            {match.investor_contact && <div style={{ fontSize: 13, color: '#6b7280' }}>{match.investor_contact}</div>}
            {match.investor_email && (
              <div style={{ fontSize: 13, color: '#2563eb', marginTop: 4 }}>
                <a href={`mailto:${match.investor_email}`}>{match.investor_email}</a>
              </div>
            )}
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 11, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 2 }}>Projet</div>
            <div style={{ fontWeight: 700, color: '#1f2937' }}>{match.project_name}</div>
            <div style={{ fontSize: 13, color: '#6b7280' }}>{techLabel} · {stageLabel}</div>
            {match.project_capacity_mw && <div style={{ fontSize: 13, color: '#6b7280' }}>{match.project_capacity_mw} MWc</div>}
          </div>
        </div>

        <div style={{ background: '#f9fafb', border: '1px solid #e5e7eb', borderRadius: 8, padding: 16, marginBottom: 16 }}>
          <div style={{ fontFamily: 'monospace', fontSize: 13, lineHeight: 1.7, whiteSpace: 'pre-wrap', color: '#1f2937' }}>
            {emailBody}
          </div>
        </div>

        <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end' }}>
          <button onClick={onClose} style={{ padding: '9px 18px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer' }}>
            Fermer
          </button>
          {match.investor_email && (
            <a href={`mailto:${match.investor_email}?subject=Opportunité ENR — ${match.project_name}&body=${encodeURIComponent(emailBody)}`}
              style={{ padding: '9px 18px', borderRadius: 6, border: 'none', background: '#7c3aed', color: '#fff', cursor: 'pointer', fontWeight: 600, textDecoration: 'none', fontSize: 14 }}>
              📧 Ouvrir dans Gmail
            </a>
          )}
          <button onClick={copy} style={{ padding: '9px 18px', borderRadius: 6, border: 'none', background: copied ? '#16a34a' : '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 600 }}>
            {copied ? '✅ Copié !' : '📋 Copier le texte'}
          </button>
        </div>
      </div>
    </div>
  )
}

function MatchCard({ match, onIntro }) {
  const [expanded, setExpanded] = useState(false)
  const goodReasons = match.reasons.filter(r => r.match)
  const badReasons = match.reasons.filter(r => !r.match)

  return (
    <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, overflow: 'hidden', marginBottom: 12 }}>
      <div style={{ display: 'flex', gap: 16, padding: 18, alignItems: 'flex-start' }}>
        <ScoreBadge score={match.score} />

        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', gap: 20, marginBottom: 10, flexWrap: 'wrap' }}>
            <div style={{ flex: 1, minWidth: 180 }}>
              <div style={{ fontSize: 11, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: 0.4, marginBottom: 3 }}>🏦 Investisseur</div>
              <div style={{ fontWeight: 700, fontSize: 15, color: '#1f2937' }}>{match.investor_company}</div>
              {match.investor_contact && <div style={{ fontSize: 12, color: '#6b7280' }}>{match.investor_contact}</div>}
              {match.investor_technologies && (
                <div style={{ fontSize: 11, color: '#7c3aed', marginTop: 4 }}>
                  {match.investor_technologies.split(',').map(t => TECH_LABELS[t] || t).join(' · ')}
                </div>
              )}
            </div>

            <div style={{ display: 'flex', alignItems: 'center', color: '#d1d5db', fontSize: 22, flexShrink: 0 }}>⇌</div>

            <div style={{ flex: 1, minWidth: 180 }}>
              <div style={{ fontSize: 11, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: 0.4, marginBottom: 3 }}>⚡ Projet</div>
              <div style={{ fontWeight: 700, fontSize: 15, color: '#1f2937' }}>{match.project_name}</div>
              {match.project_developer && (
                <div style={{ fontSize: 12, color: '#7c3aed', fontWeight: 600, marginTop: 2 }}>
                  🏗️ {match.project_developer}
                </div>
              )}
              <div style={{ fontSize: 12, color: '#6b7280', marginTop: 2 }}>
                {TECH_LABELS[match.project_technology] || match.project_technology}
                {match.project_capacity_mw && ` · ${match.project_capacity_mw} MW`}
                {match.project_region && ` · ${match.project_region}`}
              </div>
              {match.project_stage && (
                <div style={{ fontSize: 11, color: '#2563eb', marginTop: 4 }}>
                  {STAGE_LABELS[match.project_stage] || match.project_stage}
                </div>
              )}
            </div>
          </div>

          {/* Raisons match */}
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginBottom: 8 }}>
            {goodReasons.map((r, i) => (
              <span key={i} style={{ padding: '3px 10px', background: '#d1fae5', color: '#065f46', borderRadius: 10, fontSize: 11, fontWeight: 600 }}>
                ✓ {r.label} <span style={{ opacity: 0.7 }}>+{r.pts}pts</span>
              </span>
            ))}
            {badReasons.map((r, i) => (
              <span key={i} style={{ padding: '3px 10px', background: '#fee2e2', color: '#991b1b', borderRadius: 10, fontSize: 11, fontWeight: 600 }}>
                {r.label}
              </span>
            ))}
          </div>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 8, flexShrink: 0 }}>
          <button onClick={() => onIntro(match)} style={{
            padding: '8px 14px', background: '#2563eb', color: '#fff', border: 'none',
            borderRadius: 6, cursor: 'pointer', fontWeight: 600, fontSize: 13, whiteSpace: 'nowrap',
          }}>
            📧 Intro
          </button>
          <button onClick={() => setExpanded(!expanded)} style={{
            padding: '6px 14px', background: '#f9fafb', color: '#6b7280', border: '1px solid #e5e7eb',
            borderRadius: 6, cursor: 'pointer', fontSize: 12,
          }}>
            {expanded ? '▲ Moins' : '▼ Détails'}
          </button>
        </div>
      </div>

      {expanded && match.project_description && (
        <div style={{ padding: '12px 18px 16px', borderTop: '1px solid #f3f4f6', background: '#fafafa' }}>
          <div style={{ fontSize: 11, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 6 }}>Description du projet</div>
          <div style={{ fontSize: 12, color: '#4b5563', lineHeight: 1.6, whiteSpace: 'pre-wrap' }}>{match.project_description}</div>
        </div>
      )}
    </div>
  )
}

export default function Matching() {
  const [matches, setMatches] = useState([])
  const [loading, setLoading] = useState(true)
  const [minScore, setMinScore] = useState(30)
  const [introMatch, setIntroMatch] = useState(null)
  const [stats, setStats] = useState({ total: 0, high: 0, medium: 0 })

  const load = () => {
    setLoading(true)
    api.get('/matching/', { params: { min_score: minScore } })
      .then(r => {
        setMatches(r.data)
        setStats({
          total: r.data.length,
          high: r.data.filter(m => m.score >= 70).length,
          medium: r.data.filter(m => m.score >= 40 && m.score < 70).length,
        })
        setLoading(false)
      })
      .catch(() => { setLoading(false); setMatches([]) })
  }

  useEffect(() => { load() }, [minScore])

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 24 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1f2937' }}>🎯 Matching</h1>
          <p style={{ fontSize: 13, color: '#6b7280', marginTop: 2 }}>
            Connexion automatique projets ↔ investisseurs selon leurs critères
          </p>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <span style={{ fontSize: 13, color: '#6b7280' }}>Score min :</span>
          {[20, 30, 50, 70].map(s => (
            <button key={s} onClick={() => setMinScore(s)} style={{
              padding: '6px 12px', borderRadius: 6, cursor: 'pointer', fontSize: 13, fontWeight: 600,
              border: minScore === s ? '2px solid #2563eb' : '1px solid #e5e7eb',
              background: minScore === s ? '#eff6ff' : '#fff',
              color: minScore === s ? '#2563eb' : '#6b7280',
            }}>{s}+</button>
          ))}
          <button onClick={load} style={{ padding: '8px 16px', background: '#2563eb', color: '#fff', border: 'none', borderRadius: 6, cursor: 'pointer', fontWeight: 600 }}>
            ↻ Relancer
          </button>
        </div>
      </div>

      {/* KPIs */}
      {!loading && matches.length > 0 && (
        <div style={{ display: 'flex', gap: 12, marginBottom: 24 }}>
          {[
            { label: 'Total matches', value: stats.total, color: '#2563eb', bg: '#eff6ff' },
            { label: 'Score ≥ 70 (fort)', value: stats.high, color: '#065f46', bg: '#d1fae5' },
            { label: 'Score 40–70 (moyen)', value: stats.medium, color: '#92400e', bg: '#fef3c7' },
          ].map(k => (
            <div key={k.label} style={{ background: k.bg, borderRadius: 8, padding: '12px 20px', flex: 1 }}>
              <div style={{ fontSize: 28, fontWeight: 800, color: k.color }}>{k.value}</div>
              <div style={{ fontSize: 12, color: k.color, opacity: 0.8 }}>{k.label}</div>
            </div>
          ))}
        </div>
      )}

      {loading ? (
        <div style={{ padding: 60, textAlign: 'center' }}>
          <div style={{ fontSize: 32, marginBottom: 12 }}>🔄</div>
          <div style={{ color: '#6b7280' }}>Analyse en cours...</div>
        </div>
      ) : matches.length === 0 ? (
        <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, padding: 60, textAlign: 'center' }}>
          <div style={{ fontSize: 48, marginBottom: 12 }}>🎯</div>
          <div style={{ fontSize: 16, fontWeight: 700, color: '#1f2937', marginBottom: 8 }}>Aucun match trouvé</div>
          <div style={{ color: '#6b7280', fontSize: 14, maxWidth: 400, margin: '0 auto' }}>
            Pour voir des matches :<br />
            1. Mets des investisseurs en statut <strong>Actif</strong><br />
            2. Renseigne leurs critères (technologies, pays, MW)<br />
            3. Relance l'analyse
          </div>
        </div>
      ) : (
        <div>
          {matches.map((m, i) => (
            <MatchCard key={i} match={m} onIntro={setIntroMatch} />
          ))}
        </div>
      )}

      {introMatch && <IntroModal match={introMatch} onClose={() => setIntroMatch(null)} />}
    </div>
  )
}
