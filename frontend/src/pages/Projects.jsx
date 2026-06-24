import { useEffect, useState, useRef } from 'react'
import api from '../api/client'
import { useLang } from '../context/LanguageContext'
import * as XLSX from 'xlsx'
import { jsPDF } from 'jspdf'
import { autoTable } from 'jspdf-autotable'

// Pipeline stages from the sheet (Origination → Early → Submit → Mid → Advanced → Nearly secured → Secured & clean → Refused)
// `custom_stage` (libellé) et `stage` (enum snake_case) sont tous deux dérivés de cette même taxonomie côté backend.
const CUSTOM_STAGE_COLORS = {
  'Origination':        { color: '#6b7280', bg: '#f3f4f6' },
  'Early':              { color: '#3b82f6', bg: '#eff6ff' },
  'Submit':             { color: '#0d9488', bg: '#f0fdfa' },
  'Mid':                { color: '#d97706', bg: '#fffbeb' },
  'Advanced':           { color: '#ea580c', bg: '#fff7ed' },
  'Nearly secured':     { color: '#7c3aed', bg: '#f5f3ff' },
  'Secured & clean':    { color: '#059669', bg: '#f0fdf4' },
  'Refused':            { color: '#dc2626', bg: '#fef2f2' },
}

// stage (enum) -> libellé custom_stage, pour réutiliser CUSTOM_STAGE_COLORS / les traductions proj.stage.custom.*
const STAGE_ENUM_TO_LABEL = {
  origination: 'Origination', early: 'Early', submit: 'Submit', mid: 'Mid',
  advanced: 'Advanced', nearly_secured: 'Nearly secured',
  secured_and_clean: 'Secured & clean', refused: 'Refused',
}
const STAGE_ENUM_TO_TKEY = {
  origination: 'origination', early: 'early', submit: 'submit', mid: 'mid',
  advanced: 'advanced', nearly_secured: 'nearly_secured',
  secured_and_clean: 'secured_clean', refused: 'refused',
}
const STAGE_COLORS = Object.fromEntries(
  Object.entries(STAGE_ENUM_TO_LABEL).map(([enumKey, label]) => [enumKey, CUSTOM_STAGE_COLORS[label]])
)

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

const STAGES = ['origination', 'early', 'submit', 'mid', 'advanced', 'nearly_secured', 'secured_and_clean', 'refused']

// Column definitions: key, label translation key, accessor function
const fmtNum = (n) => n != null ? new Intl.NumberFormat('fr-FR').format(Math.round(n)) : '—'

const ALL_COLUMNS = [
  // ── Key columns (visible by default) ──
  { key: 'code',         labelKey: 'proj.table.code',          accessor: (p, t) => p.code || p.id },
  { key: 'pays',         labelKey: 'proj.table.country',     accessor: (p, t) => p.country || '—' },
  { key: 'entreprise',   labelKey: 'proj.table.entreprise',  renderer: 'entreprise', accessor: (p, t) => p.developer_name || '—' },
  { key: 'name',         labelKey: 'proj.table.name',          accessor: (p, t) => p.name },
  { key: 'profil',       labelKey: 'proj.table.profil',        accessor: (p, t) => {
    let rawTech = ''
    try { const rd = JSON.parse(p.raw_data || '{}'); rawTech = rd['Technologie'] || '' } catch(e) {}
    return [rawTech, p.technology_detail].filter(Boolean).join(' · ')
  } },
  { key: 'etat_developpement', labelKey: 'proj.table.etatDeveloppement', accessor: (p, t, lang = 'fr') => {
    const tkey = STAGE_ENUM_TO_TKEY[p.stage]
    const stageLabel = (tkey && t(`proj.stage.custom.${tkey}`)) || p.custom_stage || p.stage || '—'
    const status = lang === 'fr' ? (p.status_fr || p.status_en) : (p.status_en || p.status_fr)
    return status ? `${stageLabel} · ${status}` : stageLabel
  }, renderer: 'etat_developpement' },
  { key: 'rendement',    labelKey: 'proj.table.rendement',     accessor: (p, t) => {
    let v = ''
    try { const rd = JSON.parse(p.raw_data || '{}'); v = rd['Rendement (kWh/kWc)'] || '' } catch(e) {}
    return v || '—'
  } },
  { key: 'p50',          labelKey: 'proj.table.p50',           accessor: (p, t) => p.p50_mwh ? `${fmtNum(p.p50_mwh)} MWh` : '—' },
  { key: 'mw',           labelKey: 'proj.table.mw',            accessor: (p, t) => p.capacity_mw ?? '—' },
  { key: 'capex',        labelKey: 'proj.table.capex',         accessor: (p, t) => {
    try {
      const rd = JSON.parse(p.raw_data || '{}')
      if (rd['CAPEX (€)'] != null) return `${rd['CAPEX (€)']} €`
      return rd['CAPEX'] || rd['CAPEX total'] || rd['Investissement total'] || '—'
    } catch(e) { return '—' }
  } },
  { key: 'devex',        labelKey: 'proj.table.devex',         accessor: (p, t) => {
    try { const rd = JSON.parse(p.raw_data || '{}'); return rd['DEVEX (€)'] || rd['DEVEX'] || '—' } catch(e) { return '—' }
  } },
  { key: 'surface',      labelKey: 'proj.table.surface',       accessor: (p, t) => {
    try {
      const rd = JSON.parse(p.raw_data || '{}')
      return rd['Surface totale (m²)'] || rd['Surface totale centrale (m²)'] || rd['Surface (m²)'] || '—'
    } catch(e) { return '—' }
  } },
  // ── Extra columns (hidden by default) ──
  { key: 'rtb',          labelKey: 'proj.table.rtb',           accessor: (p, t) => p.rtb_date || '—' },
  { key: 'cod',          labelKey: 'proj.table.cod',           accessor: (p, t) => p.cod_date || '—' },
  { key: 'commune',      labelKey: 'proj.table.commune',       accessor: (p, t) => p.commune || '—' },
  { key: 'codepostal',   labelKey: 'proj.table.codepostal',    accessor: (p, t) => '—' },
  { key: 'dept',         labelKey: 'proj.table.dept',          accessor: (p, t) => p.department || p.department_code || '—' },
  { key: 'securisation', labelKey: 'proj.table.securisation',  accessor: (p, t) => {
    const stageMap = {
      'origination': '❌ Rien de sécurisé',
      'early': '✅ Foncier sécurisé',
      'submit': '✅ Autorisations sécurisées',
      'mid': '✅ Permis déposé',
      'advanced': '✅ Permis complet',
      'nearly_secured': '✅ Presque finalisé',
      'secured_and_clean': '🏗️ Prêt à construire',
      'refused': '❌ Refusé',
    };
    return stageMap[p.stage] || '—';
  } },
  { key: 'offtake_type', labelKey: 'proj.table.offtakeType',   accessor: (p, t) => p.offtake_type || '—' },
  { key: 'foncier',      labelKey: 'Foncier',                  accessor: (p, t) => {
    try {
      const rd = JSON.parse(p.raw_data || '{}')
      const raw = rd['Contrat foncier'] || ''
      if (!raw) return '—'
      // Shorten long labels
      let type = raw
      if (type.startsWith('Promesses de baux')) type = 'Promesse bail emphytéotique'
      else if (type.startsWith('Promesses')) type = 'Promesse'
      // Check signed
      const signe = (rd['Contrat foncier signé ?'] || '').toLowerCase()
      const isSigned = signe.includes('yes') || signe.includes('oui')
      // Duration
      const duree = rd['Durée contrat (ans)'] || ''
      const cleanDuree = duree === 'À confirmer' || !duree ? '' : duree.trim()
      // Build display
      const parts = [type]
      if (cleanDuree) parts.push(cleanDuree)
      if (isSigned) parts.push('✅')
      return parts.join(' ')
    } catch(e) { return '—' }
  } },
  { key: 'statut_permis', labelKey: 'proj.table.statutPermis',  accessor: (p, t) => p.permis_status || p.permit_status || '—' },
  { key: 'tariff',       labelKey: 'proj.table.tariff',        accessor: (p, t) => '—' },
  { key: 'distance',     labelKey: 'Distance raccordement',   accessor: (p, t) => {
    try {
      const rd = JSON.parse(p.raw_data || '{}')
      const v = rd['Distance point connexion (km)']
      return v || '—'
    } catch(e) { return '—' }
  } },
  // ── Africa / Carbon project columns ──
  { key: 'beneficiaires', labelKey: 'proj.table.beneficiaires', accessor: (p, t) => {
    try { const rd = JSON.parse(p.raw_data || '{}'); return rd['Beneficiaires'] || rd['Bénéficiaires'] || '—' } catch(e) { return '—' }
  } },
  { key: 'credits_carbone', labelKey: 'proj.table.creditsCarbone', accessor: (p, t) => {
    try { const rd = JSON.parse(p.raw_data || '{}'); return rd['Credits carbone annuels'] || rd['Crédits carbone annuels'] || '—' } catch(e) { return '—' }
  } },
  { key: 'irr',           labelKey: 'proj.table.irr',           accessor: (p, t) => {
    try { const rd = JSON.parse(p.raw_data || '{}'); return rd['IRR (4L/pers/j)'] || rd['IRR'] || p.irr || '—' } catch(e) { return '—' }
  } },
  { key: 'standard_carbone', labelKey: 'Standard carbone',     accessor: (p, t) => {
    try { const rd = JSON.parse(p.raw_data || '{}'); return rd['Standard carbone'] || '—' } catch(e) { return '—' }
  } },
  { key: 'invest_total',   labelKey: 'Investissement total',   accessor: (p, t) => {
    try { const rd = JSON.parse(p.raw_data || '{}'); return rd['Investissement total'] || '—' } catch(e) { return '—' }
  } },
]

// Colonnes propres à l'administratif français (raccordement Enedis, permis FR...) — non pertinentes
// pour les projets internationaux, donc exclues du "Tout cocher" en zone Afrique.
const FR_ONLY_COLUMNS = ['rtb', 'cod', 'codepostal', 'dept', 'foncier', 'statut_permis', 'tariff', 'distance']

// Renderers for specific columns (JSX in table)
// La classification du stade (custom_stage / stage / status_fr / status_en) est calculée
// côté backend (stage_classifier.py) à partir du texte brut "État de développement" — source
// de vérité unique, voir docs/stages-methodology.md. On se contente ici de l'afficher.
const COLUMN_RENDERERS = {
  entreprise: (p, t) => {
    let extra = null
    try {
      const rd = JSON.parse(p.raw_data || '{}')
      const action = rd['Actionnariat SPV (%)']
      if (action) {
        const lines = action.split('\n').map(l => l.trim()).filter(Boolean)
        if (lines.length > 1) extra = lines.slice(1)
      }
    } catch(e) {}
    return (
      <div>
        <span style={{ fontSize: 12, color: '#1f2937' }}>{p.developer_name || '—'}</span>
        {extra && extra.map((line, i) => (
          <div key={i} style={{ fontSize: 10, color: '#9ca3af', lineHeight: 1.3 }}>{line}</div>
        ))}
      </div>
    )
  },
  etat_developpement: (p, t, lang) => {
    const tkey = STAGE_ENUM_TO_TKEY[p.stage]
    const stageLabel = (tkey && t(`proj.stage.custom.${tkey}`)) || p.custom_stage || p.stage || '—'
    const customColor = CUSTOM_STAGE_COLORS[p.custom_stage] || { color: '#6b7280', bg: '#f3f4f6' }
    const status = lang === 'fr' ? (p.status_fr || p.status_en) : (p.status_en || p.status_fr)

    return (
      <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <span style={{ fontSize: 10, fontWeight: 700, padding: '3px 8px', borderRadius: 20,
          color: customColor.color, background: customColor.bg, whiteSpace: 'nowrap', flexShrink: 0 }}>
          {stageLabel}
        </span>
        {status && <span style={{ fontSize: 11, color: '#6b7280' }}>• {status}</span>}
      </div>
    )
  },
  statut_permis: (p, t) => {
    const val = p.permis_status || p.permit_status
    if (!val) return null
    // Extract base keyword for color, keep full text
    const base = val.toLowerCase()
    let cfg = PERMIT_CONFIG['purgé']
    if (base.includes('purgé')) cfg = PERMIT_CONFIG['purgé']
    else if (base.includes('recours')) cfg = PERMIT_CONFIG['recours']
    else if (base.includes('submitted') || base.includes('déposé') || base.includes('dépose')) cfg = PERMIT_CONFIG['déposé']
    else if (base.includes('à déposer') || base.includes('a déposer')) cfg = PERMIT_CONFIG['à déposer']
    else if (base.includes('obtenu')) cfg = PERMIT_CONFIG['recours']
    else cfg = { color: '#6b7280', bg: '#f3f4f6' }
    return (
      <span style={{ fontSize: 11, fontWeight: 600, padding: '2px 7px', borderRadius: 10,
        color: cfg.color, background: cfg.bg, whiteSpace: 'nowrap' }}>
        {val}
      </span>
    )
  },
  tech: (p, t) => {
    const techColor = TECH_COLORS[p.technology] || TECH_COLORS.other
    return (
      <span style={{ fontSize: 11, fontWeight: 600, color: techColor }}>
        {p.technology_detail || t(`proj.filter.${p.technology}`) || p.technology}
      </span>
    )
  },
}

function StageBadge({ stage, t }) {
  const cfg = STAGE_COLORS[stage] || { color: '#6b7280', bg: '#f3f4f6' }
  const tkey = STAGE_ENUM_TO_TKEY[stage]
  return (
    <span style={{ fontSize: 11, fontWeight: 700, padding: '3px 8px', borderRadius: 20,
      color: cfg.color, background: cfg.bg, whiteSpace: 'nowrap' }}>
      {(tkey && t(`proj.stage.custom.${tkey}`)) || stage}
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
  const [showEn, setShowEn] = useState(false)

  // Afficher les deux langues FR + EN en même temps
  const sdLines = (project.status_detail || '').split('\n').filter(Boolean)
  const displayStatus = sdLines.join('\n')

  // Parse raw_data JSON
  let raw = {}
  try {
    if (project.raw_data) raw = JSON.parse(project.raw_data)
  } catch(e) {}

  const handleSave = async () => {
    setSaving(true)
    await api.put(`/projects/${project.id}`, { notes, nda_signed: nda })
    setSaving(false)
    onSave()
  }

  const fmt = (n) => n ? new Intl.NumberFormat('fr-FR').format(Math.round(n)) : '—'

  // Group raw_data into sections
  const rawSections = [
    { title: '📍 Localisation', keys: ['Code postal', 'Ville / Commune', 'Département', 'Région'] },
    { title: '☀️ Technique', keys: ['Technologie', 'Typologie', "Type d'implantation", 'Configuration',
        'Puissance installée (MWc)', 'Puissance injectée réseau (MWac)', 'Rendement (kWh/kWc)', 'Production annuelle / P50 (MWh)'] },
    { title: '📅 Planning', keys: ['Date RTB estimée', 'Date COD estimée'] },
    { title: '📄 Offtake', keys: ["Type d'offtake", 'Signé ?', 'Durée du contrat Offtake (ans)', 'Tariff (EUR/kWh)'] },
    { title: '🏗️ Foncier', keys: ['Type de terrain', 'Activité', 'Contrat foncier', 'Contrat foncier signé ?',
        'Durée contrat (ans)', 'Prix (EUR ou EUR/Ha/an)', 'Aire du terrain (Ha)', 'Sécurisation accès au foncier'] },
    { title: '📋 Études & Permis', keys: ['Études techniques et d\'optimisation agricole',
        'Support administration locale', 'Environnement & contraintes', 'EIE (EIA)', 'Urbanisme',
        'Type permis', 'Statut permis', 'Date de Dépot', 'Date obtention', 'Date purge'] },
    { title: '🔌 Raccordement', keys: ['Gestionnaire réseau', 'Prix raccordement (€)',
        'Distance point connexion (km)', 'Deposit PTF / Offre technique (EUR)',
        'Deposit PTF / Offre technique payé?', 'Certificat Enedis délivré ?', 'PRD (Planned Raccordement Date)'] },
    { title: '📋 EPC & O&M', keys: ['Contrat EPC signé ?', 'O&M Mandaté ?'] },
    { title: '📎 Divers', keys: ['Code', 'Actionnariat SPV (%)', 'Lien - Project teaser', 'Date added / updated', 'Notes'] },
  ]

  const sectionHtml = rawSections.map(section => {
    const items = section.keys
      .map(k => ({ key: k, val: raw[k] }))
      .filter(x => x.val && x.val !== 'nan')
    if (items.length === 0) return ''
    return items.map(x =>
      `<div class="rd-row"><span class="rd-key">${x.key}</span><span class="rd-val">${String(x.val).replace(/\n/g, ' · ')}</span></div>`
    ).join('\n')
  }).filter(Boolean)

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
            ✅ {t('proj.detail.ndaSigned')}
          </span>
        )}
      </div>

      {project.status_detail && (
        <div style={{ background: '#f8fafc', borderRadius: 8, padding: '10px 12px', fontSize: 12,
          color: '#374151', lineHeight: 1.5, marginBottom: 10, border: '1px solid #e5e7eb' }}>
          {displayStatus}
        </div>
      )}
      <div style={{ textAlign: 'right', marginBottom: 14 }}>
        <button onClick={() => setShowEn(!showEn)}
          style={{ fontSize: 11, color: '#6b7280', background: '#f3f4f6', border: '1px solid #e5e7eb',
            borderRadius: 14, padding: '3px 10px', cursor: 'pointer', fontWeight: 600 }}>
          {showEn ? '🇫🇷 FR' : '🇬🇧 EN'}
        </button>
      </div>

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

      {/* All raw data from sheet */}
      {rawSections.map((section, si) => {
        const items = section.keys
          .map(k => ({ key: k, val: raw[k] }))
          .filter(x => x.val && x.val !== 'nan')
        if (items.length === 0) return null
        return (
          <div key={si} style={{ marginBottom: 14 }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 6, letterSpacing: 0.3 }}>
              {section.title}
            </div>
            {items.map((x, ii) => (
              <div key={ii} style={{ fontSize: 12, marginBottom: 3, display: 'flex', gap: 6 }}>
                <span style={{ color: '#9ca3af', minWidth: 110, flexShrink: 0 }}>{x.key}</span>
                <span style={{ color: '#1f2937', fontWeight: 500 }}>{String(x.val).replace(/\n/g, ' · ')}</span>
              </div>
            ))}
          </div>
        )
      })}

      {/* Fallback for non-French project fields (Africa, etc.) */}
      {(() => {
        const coveredKeys = new Set(rawSections.flatMap(s => s.keys))
        const leftover = Object.keys(raw).filter(k => !coveredKeys.has(k) && raw[k] && raw[k] !== 'nan')
        if (leftover.length === 0) return null
        return (
          <div style={{ marginBottom: 14 }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 6, letterSpacing: 0.3 }}>
              📋 Données complémentaires
            </div>
            {leftover.map((k, ii) => (
              <div key={ii} style={{ fontSize: 12, marginBottom: 3, display: 'flex', gap: 6 }}>
                <span style={{ color: '#9ca3af', minWidth: 110, flexShrink: 0 }}>{k}</span>
                <span style={{ color: '#1f2937', fontWeight: 500 }}>{String(raw[k]).replace(/\n/g, ' · ')}</span>
              </div>
            ))}
          </div>
        )
      })()}

      <div style={{ marginBottom: 14 }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 4 }}>
          {t('proj.detail.nda')}
        </div>
        <div style={{ display: 'flex', gap: 6 }}>
          {[t('proj.detail.no'), t('proj.detail.yes')].map(v => {
            const isYes = v === t('proj.detail.yes')
            return (
            <button key={v} onClick={() => setNda(isYes ? 'Oui' : 'Non')} style={{
              padding: '5px 14px', borderRadius: 6, border: `2px solid ${(isYes ? nda === 'Oui' : nda === 'Non') ? (isYes ? '#059669' : '#d1d5db') : '#e5e7eb'}`,
              background: (isYes ? nda === 'Oui' : nda === 'Non') ? (isYes ? '#d1fae5' : '#f3f4f6') : '#fff',
              color: (isYes ? nda === 'Oui' : nda === 'Non') ? (isYes ? '#059669' : '#374151') : '#9ca3af',
              cursor: 'pointer', fontSize: 13, fontWeight: 600,
            }}>{v}</button>
          )})}
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
  const { t, lang } = useLang()
  const [projects, setProjects] = useState([])
  const [loading, setLoading] = useState(true)
  const [selected, setSelected] = useState(null)
  const [search, setSearch] = useState('')
  const [filterStage, setFilterStage] = useState('')
  const [filterDev, setFilterDev] = useState('')
  const [filterTech, setFilterTech] = useState('')
  const [zone, setZone] = useState('france')

  // Column visibility: key columns visible by default (France vs Africa)
  const defaultVisibleForZone = (z) => {
    if (z === 'afrique') {
      return ['code', 'pays', 'entreprise', 'name', 'profil', 'etat_developpement', 'capex', 'beneficiaires', 'credits_carbone', 'irr', 'securisation']
    }
    return ['name', 'profil', 'etat_developpement', 'rendement', 'p50', 'mw', 'code', 'securisation', 'offtake_type']
  }
  const [visibleCols, setVisibleCols] = useState(() =>
    Object.fromEntries(ALL_COLUMNS.map(c => [c.key, defaultVisibleForZone('france').includes(c.key)]))
  )
  const [showColMenu, setShowColMenu] = useState(false)
  const colMenuRef = useRef(null)

  // Anonymization toggle
  const [anonymize, setAnonymize] = useState(false)

  // Export dropdown
  const [showExportMenu, setShowExportMenu] = useState(false)
  const exportMenuRef = useRef(null)
  const [recipientName, setRecipientName] = useState('')

  // Close dropdowns on outside click
  useEffect(() => {
    const handleClick = (e) => {
      if (colMenuRef.current && !colMenuRef.current.contains(e.target)) setShowColMenu(false)
      if (exportMenuRef.current && !exportMenuRef.current.contains(e.target)) setShowExportMenu(false)
    }
    document.addEventListener('mousedown', handleClick)
    return () => document.removeEventListener('mousedown', handleClick)
  }, [])

  const load = () => {
    setLoading(true)
    const params = {}
    if (filterStage) params.stage = filterStage
    if (filterDev) params.developer = filterDev
    if (filterTech) params.technology = filterTech
    api.get('/projects/', { params }).then(r => {
      setProjects(r.data)
      setLoading(false)
    }).catch(() => setLoading(false))
  }

  useEffect(() => { load() }, [filterStage, filterDev, filterTech])

  useEffect(() => { setFilterDev(''); setSelected(null); setVisibleCols(
    Object.fromEntries(ALL_COLUMNS.map(c => [c.key, defaultVisibleForZone(zone).includes(c.key)]))
  ) }, [zone])

  const isFrance = (p) => !p.country || p.country.toUpperCase() === 'FR'
  const zoned = projects.filter(p => zone === 'france' ? isFrance(p) : !isFrance(p))

  const filtered = zoned.filter(p =>
    !search ||
    p.name.toLowerCase().includes(search.toLowerCase()) ||
    (p.developer_name || '').toLowerCase().includes(search.toLowerCase()) ||
    (p.department || '').toLowerCase().includes(search.toLowerCase()) ||
    (p.commune || '').toLowerCase().includes(search.toLowerCase())
  )

  const totalMw = filtered.reduce((s, p) => s + (p.capacity_mw || 0), 0)
  const rtbCount = filtered.filter(p => p.stage === 'secured_and_clean').length
  const sel = selected ? projects.find(p => p.id === selected) : null
  const devs = [...new Set(zoned.map(p => p.developer_name).filter(Boolean))].sort()
  const enabledCols = ALL_COLUMNS.filter(c => visibleCols[c.key])

  // Resolve project name: anonymized or real
  const projectLabel = (p, idx) => anonymize ? `Pr${idx + 1}` : p.name

  // Export helpers
  const visibleColKeys = ALL_COLUMNS.filter(c => visibleCols[c.key])
  const exportData = filtered.map((p, i) => {
    const row = {}
    visibleColKeys.forEach(c => {
      if (c.key === 'name') {
        row[t(c.labelKey)] = projectLabel(p, i)
      } else {
        row[t(c.labelKey)] = c.accessor(p, t, lang)
      }
    })
    return row
  })

  const exportExcel = () => {
    const wb = XLSX.utils.book_new()
    const ws = XLSX.utils.json_to_sheet(exportData)
    XLSX.utils.book_append_sheet(wb, ws, t('proj.title'))
    XLSX.writeFile(wb, `projets_enr_${new Date().toISOString().slice(0,10)}.xlsx`)
    setShowExportMenu(false)
  }

  // Strip emoji & non-printable chars for PDF export
  const cleanForPdf = (val) => {
    if (typeof val !== 'string') return val
    // Replace common emoji with text alternatives
    return val
      .replace(/✅/g, '[OK]')
      .replace(/❌/g, '[NON]')
      .replace(/📝/g, '>')
      .replace(/⚖️/g, '[RECOURS]')
      .replace(/🔍/g, '>')
      .replace(/[^\x20-\x7E\u00C0-\u017F\u2010-\u201E\u2026\u2030-\u2039]/g, '')
      .trim()
  }

  const exportPdf = async () => {
    const doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' })

    // Load Unicode font for proper French character support
    try {
      const resp = await fetch('/fonts/DejaVuSans.ttf')
      const blob = await resp.blob()
      const reader = new FileReader()
      const b64 = await new Promise((resolve) => {
        reader.onload = () => resolve(reader.result.split(',')[1])
        reader.readAsDataURL(blob)
      })
      doc.addFileToVFS('DejaVuSans.ttf', b64)
      doc.addFont('DejaVuSans.ttf', 'DejaVuSans', 'normal')

      const respB = await fetch('/fonts/DejaVuSans-Bold.ttf')
      const blobB = await respB.blob()
      const readerB = new FileReader()
      const b64B = await new Promise((resolve) => {
        readerB.onload = () => resolve(readerB.result.split(',')[1])
        readerB.readAsDataURL(blobB)
      })
      doc.addFileToVFS('DejaVuSans-Bold.ttf', b64B)
      doc.addFont('DejaVuSans-Bold.ttf', 'DejaVuSans', 'bold')

      doc.setFont('DejaVuSans')
    } catch (e) {
      console.warn('Font load failed, using default', e)
    }

    const headers = visibleColKeys.map(c => t(c.labelKey))
    const rows = filtered.map((p, i) =>
      visibleColKeys.map(c => {
        const val = c.key === 'name' ? projectLabel(p, i) : c.accessor(p, t, lang)
        return cleanForPdf(val)
      })
    )
    doc.setFontSize(13)
    doc.text(t('proj.title'), 14, 16)
    if (recipientName) {
      doc.setFontSize(9)
      doc.text(`Portfolio destiné à : ${recipientName}`, 14, 22)
    }
    autoTable(doc, {
      head: [headers],
      body: rows,
      startY: recipientName ? 27 : 22,
      styles: { font: 'DejaVuSans', fontSize: 6.5, cellPadding: 1.5 },
      headStyles: { font: 'DejaVuSans', fillColor: [5, 150, 105], fontSize: 6.5, fontStyle: 'bold' },
      // Ensure text columns get enough width
      columnStyles: headers.reduce((acc, h, i) => {
        const key = visibleColKeys[i]?.key
        if (['code', '#'].includes(h)) acc[i] = { cellWidth: 10 }
        else if (key === 'pays' || h === 'Pays') acc[i] = { cellWidth: 16 }
        else if (key === 'entreprise') acc[i] = { cellWidth: 30 }
        else if (key === 'name') acc[i] = { cellWidth: 38 }
        else if (key === 'capex') acc[i] = { cellWidth: 22 }
        else if (key === 'code') acc[i] = { cellWidth: 10 }
        else if (key === 'beneficiaires') acc[i] = { cellWidth: 22 }
        else if (key === 'credits_carbone') acc[i] = { cellWidth: 22 }
        else if (key === 'irr') acc[i] = { cellWidth: 14 }
        return acc
      }, {}),
    })
    doc.save(`projets_enr_${new Date().toISOString().slice(0,10)}.pdf`)
    setShowExportMenu(false)
  }

  // Detailed export: all raw_data fields for 1-5 projects
  const exportDetailPdf = async () => {
    const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' })

    // Load font
    try {
      const resp = await fetch('/fonts/DejaVuSans.ttf')
      const blob = await resp.blob()
      const reader = new FileReader()
      const b64 = await new Promise((resolve) => {
        reader.onload = () => resolve(reader.result.split(',')[1])
        reader.readAsDataURL(blob)
      })
      doc.addFileToVFS('DejaVuSans.ttf', b64)
      doc.addFont('DejaVuSans.ttf', 'DejaVuSans', 'normal')
      const respB = await fetch('/fonts/DejaVuSans-Bold.ttf')
      const blobB = await respB.blob()
      const readerB = new FileReader()
      const b64B = await new Promise((resolve) => {
        readerB.onload = () => resolve(readerB.result.split(',')[1])
        readerB.readAsDataURL(blobB)
      })
      doc.addFileToVFS('DejaVuSans-Bold.ttf', b64B)
      doc.addFont('DejaVuSans-Bold.ttf', 'DejaVuSans', 'bold')
      doc.setFont('DejaVuSans')
    } catch (e) { console.warn('Font load failed', e) }

    for (let pi = 0; pi < filtered.length; pi++) {
      const p = filtered[pi]
      if (pi > 0) doc.addPage()

      // Header
      doc.setFontSize(14)
      doc.setFont('DejaVuSans', 'bold')
      doc.text(p.name, 14, 20)
      doc.setFontSize(9)
      doc.setFont('DejaVuSans', 'normal')
      doc.text(`#${p.code || p.id} · ${p.developer_name || ''} · ${p.country || ''} · ${p.custom_stage || p.stage || ''}`, 14, 27)

      // Raw data as key-value table
      let raw = {}
      try { raw = JSON.parse(p.raw_data || '{}') } catch(e) {}

      const kvRows = Object.entries(raw)
        .filter(([, v]) => v && v !== 'nan')
        .map(([k, v]) => [k, String(v).replace(/\n/g, ' · ')])

      if (kvRows.length > 0) {
        doc.setFontSize(8)
        autoTable(doc, {
          body: kvRows,
          startY: 33,
          styles: { font: 'DejaVuSans', fontSize: 7, cellPadding: 1.5 },
          columnStyles: { 0: { cellWidth: 50, fontStyle: 'bold', fillColor: [245, 245, 245] }, 1: { cellWidth: 'auto' } },
          margin: { left: 14, right: 14 },
          tableLineColor: [200, 200, 200],
        })
      }
    }
    doc.save(`projet_detail_${new Date().toISOString().slice(0,10)}.pdf`)
    setShowExportMenu(false)
  }

  return (
    <div style={{ maxWidth: 1400 }}>
      <div style={{ marginBottom: 20 }}>
        <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1f2937', marginBottom: 4 }}>
          {t('proj.title')}
        </h1>
        <div style={{ fontSize: 13, color: '#6b7280' }}>
          {filtered.length} {t(filtered.length > 1 ? 'proj.projects' : 'proj.project')} · {totalMw.toFixed(1)} {t('proj.mwc')} · {rtbCount} {t('proj.rtb')}
        </div>
      </div>

      {/* Zone tabs */}
      <div style={{ display: 'flex', gap: 4, marginBottom: 16, background: '#f3f4f6', borderRadius: 10, padding: 4, width: 'fit-content' }}>
        {[['france', 'proj.zone.france'], ['afrique', 'proj.zone.afrique']].map(([z, key]) => (
          <button key={z} onClick={() => setZone(z)}
            style={{
              padding: '8px 18px', borderRadius: 8, border: 'none', cursor: 'pointer',
              fontSize: 13, fontWeight: 600,
              background: zone === z ? '#059669' : 'transparent',
              color: zone === z ? '#fff' : '#6b7280',
              transition: 'all 0.15s',
            }}>
            {t(key)}
          </button>
        ))}
      </div>

      {/* Filters row */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 16, flexWrap: 'wrap', alignItems: 'center' }}>
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
          {STAGES.map(s => <option key={s} value={s}>{t(`proj.stage.custom.${STAGE_ENUM_TO_TKEY[s]}`)}</option>)}
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

        <div style={{ flex: 1 }} />

        {/* Anonymize toggle */}
        <button onClick={() => setAnonymize(!anonymize)}
          style={{ padding: '8px 12px', borderRadius: 8, border: '1px solid #e5e7eb',
            background: anonymize ? '#fef3c7' : '#fff', fontSize: 13, cursor: 'pointer',
            display: 'flex', alignItems: 'center', gap: 5,
            color: anonymize ? '#92400e' : '#374151', fontWeight: anonymize ? 600 : 400 }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
            <circle cx="9" cy="7" r="4" />
            <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
            <path d="M16 3.13a4 4 0 0 1 0 7.75" />
          </svg>
          {anonymize ? t('proj.anonymize.on') : t('proj.anonymize')}
        </button>

        {/* Column visibility toggle */}
        <div ref={colMenuRef} style={{ position: 'relative' }}>
          <button onClick={() => setShowColMenu(!showColMenu)}
            style={{ padding: '8px 12px', borderRadius: 8, border: '1px solid #e5e7eb', background: '#fff', fontSize: 13, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 5 }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="3" y="3" width="18" height="18" rx="2" />
              <line x1="3" y1="9" x2="21" y2="9" />
              <line x1="9" y1="3" x2="9" y2="21" />
            </svg>
            {t('proj.columns')}
          </button>
          {showColMenu && (
            <div style={{ position: 'absolute', top: '100%', right: 0, marginTop: 4, zIndex: 50,
              background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, boxShadow: '0 4px 16px rgba(0,0,0,0.12)',
              padding: 8, minWidth: 200 }}>
              <div style={{ display: 'flex', gap: 4, marginBottom: 6, padding: '4px 8px' }}>
                <button onClick={() => setVisibleCols(Object.fromEntries(ALL_COLUMNS.map(c => [c.key, true])))}
                  style={{ flex: 1, padding: '4px 8px', border: '1px solid #e5e7eb', borderRadius: 6, background: '#f9fafb', fontSize: 11, cursor: 'pointer', fontWeight: 600 }}>
                  {t('proj.export.all')}
                </button>
                <button onClick={() => setVisibleCols(Object.fromEntries(ALL_COLUMNS.map(c => [c.key, false])))}
                  style={{ flex: 1, padding: '4px 8px', border: '1px solid #e5e7eb', borderRadius: 6, background: '#f9fafb', fontSize: 11, cursor: 'pointer', fontWeight: 600 }}>
                  {t('proj.export.none')}
                </button>
              </div>
              {ALL_COLUMNS.map(col => (
                <label key={col.key}
                  style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '5px 8px', borderRadius: 6,
                    cursor: 'pointer', fontSize: 13, color: '#374151' }}>
                  <input type="checkbox" checked={visibleCols[col.key]}
                    onChange={() => setVisibleCols(p => ({ ...p, [col.key]: !p[col.key] }))} />
                  {t(col.labelKey)}
                </label>
              ))}
            </div>
          )}
        </div>

        {/* Export button */}
        <div ref={exportMenuRef} style={{ position: 'relative' }}>
          <button onClick={() => setShowExportMenu(!showExportMenu)}
            style={{ padding: '8px 14px', borderRadius: 8, border: 'none',
              background: '#059669', color: '#fff', fontSize: 13, fontWeight: 600, cursor: 'pointer',
              display: 'flex', alignItems: 'center', gap: 5 }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
              <polyline points="7 10 12 15 17 10" />
              <line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            {t('proj.export.title')}
          </button>
          {showExportMenu && (
            <div style={{ position: 'absolute', top: '100%', right: 0, marginTop: 4, zIndex: 50,
              background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, boxShadow: '0 4px 16px rgba(0,0,0,0.12)',
              padding: 6, minWidth: 170 }}>
              <div style={{ padding: '6px 10px 4px', fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase' }}>
                {t('proj.export.title')} ({filtered.length} {t(filtered.length > 1 ? 'proj.projects' : 'proj.project')})
              </div>
              <div style={{ padding: '6px 10px 4px' }}>
                <input
                  value={recipientName} onChange={e => setRecipientName(e.target.value)}
                  placeholder="Destinataire (entreprise)"
                  style={{ width: '100%', padding: '6px 8px', border: '1px solid #e5e7eb', borderRadius: 6, fontSize: 12, outline: 'none', boxSizing: 'border-box' }}
                />
              </div>
              <button onClick={exportExcel}
                style={{ display: 'flex', alignItems: 'center', gap: 8, width: '100%', padding: '8px 10px', border: 'none',
                  background: 'none', cursor: 'pointer', fontSize: 13, color: '#374151', borderRadius: 6 }}>
                📊 {t('proj.export.excel')}
              </button>
              <button onClick={exportPdf}
                style={{ display: 'flex', alignItems: 'center', gap: 8, width: '100%', padding: '8px 10px', border: 'none',
                  background: 'none', cursor: 'pointer', fontSize: 13, color: '#374151', borderRadius: 6 }}>
                📄 {t('proj.export.pdf')}
              </button>
              {filtered.length <= 5 && (
                <button onClick={exportDetailPdf}
                  style={{ display: 'flex', alignItems: 'center', gap: 8, width: '100%', padding: '8px 10px', border: 'none',
                    background: 'none', cursor: 'pointer', fontSize: 13, color: '#374151', borderRadius: 6 }}>
                  📋 Export détaillé
                </button>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Stats cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(140px, 1fr))', gap: 10, marginBottom: 20 }}>
        {STAGES.map(stage => {
          const cfg = STAGE_COLORS[stage]
          const count = zoned.filter(p => p.stage === stage).length
          const mw = zoned.filter(p => p.stage === stage).reduce((s, p) => s + (p.capacity_mw || 0), 0)
          return (
            <div key={stage} onClick={() => setFilterStage(filterStage === stage ? '' : stage)}
              style={{ background: '#fff', border: `1px solid ${filterStage === stage ? cfg.color : '#e5e7eb'}`,
                borderRadius: 10, padding: '12px 16px', cursor: 'pointer',
                borderLeft: `4px solid ${cfg.color}` }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: cfg.color, textTransform: 'uppercase', marginBottom: 4 }}>
                {t(`proj.stage.custom.${STAGE_ENUM_TO_TKEY[stage]}`)}
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
          <div style={{ fontSize: 20, fontWeight: 700, color: '#1f2937' }}>{zoned.length}</div>
          <div style={{ fontSize: 11, color: '#9ca3af' }}>
            {zoned.reduce((s, p) => s + (p.capacity_mw || 0), 0).toFixed(1)} MWc
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
                  {enabledCols.map(col => (
                    <th key={col.key} style={{ padding: '10px 12px', textAlign: 'left', fontSize: 11, fontWeight: 700,
                      color: '#6b7280', textTransform: 'uppercase', whiteSpace: 'nowrap' }}>
                      {t(col.labelKey)}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((p, i) => {
                  const isActive = selected === p.id
                  return (
                    <tr key={p.id} onClick={() => setSelected(isActive ? null : p.id)}
                      style={{ borderBottom: '1px solid #f3f4f6', cursor: 'pointer',
                        background: isActive ? '#f0fdf4' : i % 2 === 0 ? '#fff' : '#fafafa' }}>
                      {enabledCols.map(col => {
                        const renderer = COLUMN_RENDERERS[col.key]
                        const val = col.key === 'name' ? projectLabel(p, i) : (renderer ? renderer(p, t, lang) : col.accessor(p, t))
                        return (
                          <td key={col.key} style={{
                            padding: '10px 12px',
                            fontWeight: col.key === 'name' ? 600 : col.key === 'mw' ? 600 : 'inherit',
                            color: col.key === 'name' ? '#1f2937' : col.key === 'code' ? '#9ca3af' :
                                   col.key === 'mw' ? '#1f2937' : '#374151',
                            fontSize: col.key === 'code' ? 11 : col.key === 'rtb' || col.key === 'cod' ? 12 : 'inherit',
                            whiteSpace: 'nowrap',
                            maxWidth: col.key === 'name' ? 200 : 'none',
                          }}>
                            {val}
                          </td>
                        )
                      })}
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
