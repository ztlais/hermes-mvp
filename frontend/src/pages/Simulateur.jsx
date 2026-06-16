import { useState } from 'react'
import api from '../api/client'
import { useLang } from '../context/LanguageContext'
import {
  AreaChart, Area, BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, Legend, ResponsiveContainer, ReferenceLine, LineChart, Line
} from 'recharts'

const REGIONS = [
  "Occitanie","Nouvelle-Aquitaine","PACA","Auvergne-Rhône-Alpes",
  "Bretagne","Pays de la Loire","Centre-Val de Loire",
  "Île-de-France","Grand Est","Normandie","Hauts-de-France","Bourgogne-Franche-Comté"
]

const DEFAULT = {
  puissance_kwc: 145.5, puissance_kva: 80,
  productible_p90: 1280, productible_p50: 1313,
  surface_m2: 700, region: "Occitanie", type_offre: "toiture",
  batiment_neuf: false,
  tarif_achat_override: null,
  // Autoconso
  autoconsommation: false, acc: false,
  taux_autoconso: 0, conso_annuelle_kwh: 64000,
  prix_kwh_fournisseur: 0.25, tarif_revente_acc: 0.11,
  // Rénovations
  depose_everite_amiantee_m2: 0, depose_everite_na_m2: 0,
  depose_tuiles_m2: 0, depose_bac_acier_m2: 0,
  pose_bac_acier_isole_m2: 0, pose_bac_acier_standard_m2: 0,
  // Construction spéciale
  ombriere_kwc: 0, hangar_m2: 0,
  // Raccordement
  ml_domaine_public: 0, relai_supplementaire: false,
  // Soulte
  soulte_pct_ca: 0, loyer_kwc: 0,
  // Financement
  levier: 0.7, taux_interet: 4.08, maturite_ans: 20, pme: true,
  // Charges
  maintenance_kwc: 12, assurance_kwc: 3,
  ifer_kwc: null, autres_taxes_kwc: 1.5,
  remplacement_onduleurs_kwc: 2.5,
  frais_aggreg_kwc: 0.003, frais_fixes_aggreg_k: 1.2,
  // Nov'Era
  novera_actif: false, novera_annees_paiement: 5,
  novera_pct_paiement: 5.5, novera_pct_rachat: 88,
  novera_taux_van: 3, novera_levier_phase3: 70, novera_maturite_phase3: 15,
}

const fmt = (n, suffix = '', dec = 0) => {
  if (n == null || n === undefined) return '—'
  return new Intl.NumberFormat('fr-FR', { maximumFractionDigits: dec }).format(n) + suffix
}
const pct = (n, dec = 2) => n != null ? `${fmt(n, '', dec)} %` : '—'
const keur = (n) => n != null ? `${fmt(n / 1000, '', 0)} k€` : '—'

function KpiCard({ label, value, sub, color = '#1f2937', bg = '#f9fafb', border }) {
  return (
    <div style={{ background: bg, border: `1px solid ${border || '#e5e7eb'}`, borderRadius: 10, padding: '14px 16px' }}>
      <div style={{ fontSize: 10, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 6 }}>{label}</div>
      <div style={{ fontSize: 20, fontWeight: 800, color, lineHeight: 1.2 }}>{value}</div>
      {sub && <div style={{ fontSize: 11, color: '#9ca3af', marginTop: 4 }}>{sub}</div>}
    </div>
  )
}

function Section({ title, children, collapsible = false }) {
  const [open, setOpen] = useState(true)
  return (
    <div style={{ marginBottom: 20 }}>
      <div
        onClick={() => collapsible && setOpen(o => !o)}
        style={{ fontSize: 11, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: open ? 10 : 0, paddingBottom: 6, borderBottom: '2px solid #e5e7eb', cursor: collapsible ? 'pointer' : 'default', display: 'flex', justifyContent: 'space-between' }}>
        {title}
        {collapsible && <span>{open ? '▲' : '▼'}</span>}
      </div>
      {open && children}
    </div>
  )
}

const inp = { width: '100%', padding: '7px 10px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 12, boxSizing: 'border-box', background: '#fff' }
const lbl = { display: 'block', fontSize: 10, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', marginBottom: 3, letterSpacing: 0.3 }
const g2 = { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }
const g3 = { display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }

const TTip = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null
  return (
    <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8, padding: '10px 14px', fontSize: 12, boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}>
      <div style={{ fontWeight: 700, marginBottom: 6, color: '#374151' }}>Année {label}</div>
      {payload.map(p => <div key={p.name} style={{ color: p.color, marginBottom: 2 }}>{p.name}: <strong>{fmt(p.value, ' k€', 1)}</strong></div>)}
    </div>
  )
}

const TABS = [
  { id: 'cashflow', label: 'Cashflows' },
  { id: 'cumul', label: 'Trésorerie cumulée' },
  { id: 'capex', label: 'CAPEX' },
  { id: 'raccordement', label: 'Raccordement' },
  { id: 'autoconso', label: 'Autoconsommation' },
  { id: 'novera', label: "Nov'Era" },
  { id: 'table', label: 'Tableau 30 ans' },
]

export default function Simulateur() {
  const { t } = useLang()
  const [form, setForm] = useState(DEFAULT)
  const [result, setResult] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [tab, setTab] = useState('cashflow')

  const set = (k, v) => setForm(f => ({ ...f, [k]: v }))

  const handleCalculer = async () => {
    setLoading(true); setError(null)
    try {
      const payload = {
        ...form,
        taux_interet: form.taux_interet / 100,
        tarif_achat_override: form.tarif_achat_override || null,
        novera_pct_paiement: form.novera_pct_paiement / 100,
        novera_pct_rachat: form.novera_pct_rachat / 100,
        novera_taux_van: form.novera_taux_van / 100,
        novera_levier_phase3: form.novera_levier_phase3 / 100,
      }
      const r = await api.post('/simulateur/calculate', payload)
      setResult(r.data)
      setTab('cashflow')
    } catch (e) {
      setError('Erreur : ' + (e.response?.data?.detail || e.message))
    }
    setLoading(false)
  }

  const { kpis, capex, raccordement, previsionnel: prev = [], autoconsommation: ac, novera } = result || {}

  const chartCF = prev.map(a => ({ annee: a.annee, 'CA P90': a.ca_p90, 'CA P50': a.ca_p50, 'Charges': -a.charges, 'Cash P90': a.cashflow_p90 }))
  const chartCumul = (() => { let c90 = 0, c50 = 0; return prev.map(a => { c90 += a.cashflow_p90; c50 += a.cashflow_p50; return { annee: a.annee, 'P90': +c90.toFixed(1), 'P50': +c50.toFixed(1) } }) })()
  const chartDSCR = prev.filter(a => a.dscr != null).map(a => ({ annee: a.annee, DSCR: a.dscr }))

  const capexItems = capex ? [
    { name: 'Panneaux', v: capex.panneaux, c: '#059669' },
    { name: "Main d'œuvre", v: capex.main_oeuvre, c: '#2563eb' },
    { name: 'Raccordement', v: capex.raccordement, c: '#7c3aed' },
    { name: 'Frais dev.', v: capex.frais_dev, c: '#f59e0b' },
    { name: 'Marge constr.', v: capex.marge_construction, c: '#ef4444' },
    { name: 'Dev commercial', v: capex.total_dev_commercial, c: '#0891b2' },
    { name: 'Onduleurs', v: capex.onduleurs, c: '#84cc16' },
    { name: 'Rénovations', v: capex.renovations, c: '#f97316' },
    { name: 'Renforcement', v: capex.renforcement_structure, c: '#a855f7' },
    { name: 'Autres', v: capex.autres_construction + capex.imprevus + capex.assurances_etudes + capex.construction_speciale, c: '#6b7280' },
  ].filter(d => d.v > 0) : []

  return (
    <div style={{ display: 'flex', gap: 16, height: 'calc(100vh - 64px)', minWidth: 0 }}>

      {/* ── Panneau de saisie ── */}
      <div style={{ width: 290, flexShrink: 0, overflowY: 'auto', background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, padding: 16 }}>
        <div style={{ fontSize: 15, fontWeight: 800, color: '#064e3b', marginBottom: 16 }}>☀️ {t('sim.title')}</div>

        <Section title={t('sim.section.project')}>
          <div style={{ marginBottom: 8 }}>
            <label style={lbl}>{t('sim.type')}</label>
            <select style={inp} value={form.type_offre} onChange={e => set('type_offre', e.target.value)}>
              <option value="toiture">{t('sim.type.toiture')}</option>
              <option value="ombriere">{t('sim.type.ombriere')}</option>
              <option value="sol">{t('sim.type.sol')}</option>
            </select>
          </div>
          <div style={{ marginBottom: 8 }}>
            <label style={lbl}>{t('sim.region')}</label>
            <select style={inp} value={form.region} onChange={e => set('region', e.target.value)}>
              {REGIONS.map(r => <option key={r}>{r}</option>)}
            </select>
          </div>
          <div style={{ display: 'flex', gap: 12, marginBottom: 4 }}>
            {[['batiment_neuf', t('sim.batiment_neuf')], ['autoconsommation', t('sim.autoconso')], ['acc', 'ACC'], ['pme', 'PME']].map(([k, lbl2]) => (
              <label key={k} style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 11, cursor: 'pointer' }}>
                <input type="checkbox" checked={form[k]} onChange={e => set(k, e.target.checked)} />{lbl2}
              </label>
            ))}
          </div>
        </Section>

        <Section title={t('sim.section.tech')}>
          <div style={{ marginBottom: 8 }}>
            <label style={lbl}>{t('sim.puissance')}</label>
            <input style={inp} type="number" value={form.puissance_kwc} onChange={e => set('puissance_kwc', +e.target.value)} />
          </div>
          <div style={{ ...g2, marginBottom: 8 }}>
            <div><label style={lbl}>{t('sim.p90')}</label><input style={inp} type="number" value={form.productible_p90} onChange={e => set('productible_p90', +e.target.value)} /></div>
            <div><label style={lbl}>{t('sim.p50')}</label><input style={inp} type="number" value={form.productible_p50} onChange={e => set('productible_p50', +e.target.value)} /></div>
          </div>
          <div style={{ marginBottom: 8 }}>
            <label style={lbl}>{t('sim.surface')}</label>
            <input style={inp} type="number" value={form.surface_m2} onChange={e => set('surface_m2', +e.target.value)} />
          </div>
          <div style={{ marginBottom: 8 }}>
            <label style={lbl}>{t('sim.tarif_override')}</label>
            <input style={inp} type="number" placeholder="Ex: 88.6" value={form.tarif_achat_override ?? ''} onChange={e => set('tarif_achat_override', e.target.value ? +e.target.value : null)} />
          </div>
        </Section>

        <Section title="Raccordement" collapsible>
          <div style={{ ...g2, marginBottom: 8 }}>
            <div><label style={lbl}>ML domaine public</label><input style={inp} type="number" value={form.ml_domaine_public} onChange={e => set('ml_domaine_public', +e.target.value)} /></div>
            <div style={{ display: 'flex', alignItems: 'flex-end', paddingBottom: 2 }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 11, cursor: 'pointer' }}>
                <input type="checkbox" checked={form.relai_supplementaire} onChange={e => set('relai_supplementaire', e.target.checked)} />Relai supp. (+40k€)
              </label>
            </div>
          </div>
        </Section>

        <Section title="Rénovations toiture" collapsible>
          {[
            ['depose_everite_amiantee_m2', 'Dépose éverite amiantée (m²) × 43€'],
            ['depose_everite_na_m2', 'Dépose éverite NA (m²) × 12€'],
            ['depose_tuiles_m2', 'Dépose tuiles (m²) × 34€'],
            ['depose_bac_acier_m2', 'Dépose bac acier (m²) × 10€'],
            ['pose_bac_acier_isole_m2', 'Pose bac acier isolé (m²) × 48€'],
            ['pose_bac_acier_standard_m2', 'Pose bac acier standard (m²) × 28€'],
          ].map(([k, label]) => (
            <div key={k} style={{ ...g2, marginBottom: 6 }}>
              <label style={{ ...lbl, marginBottom: 0, display: 'flex', alignItems: 'center' }}>{label}</label>
              <input style={inp} type="number" value={form[k]} onChange={e => set(k, +e.target.value)} />
            </div>
          ))}
        </Section>

        <Section title="Construction spéciale" collapsible>
          <div style={{ ...g2, marginBottom: 8 }}>
            <div><label style={lbl}>Ombrière (kWc)</label><input style={inp} type="number" value={form.ombriere_kwc} onChange={e => set('ombriere_kwc', +e.target.value)} /></div>
            <div><label style={lbl}>Hangar (m²)</label><input style={inp} type="number" value={form.hangar_m2} onChange={e => set('hangar_m2', +e.target.value)} /></div>
          </div>
        </Section>

        {(form.autoconsommation || form.acc) && (
          <Section title="Autoconsommation">
            <div style={{ ...g2, marginBottom: 8 }}>
              <div><label style={lbl}>Taux autoconso (%)</label><input style={inp} type="number" max={100} value={Math.round(form.taux_autoconso * 100)} onChange={e => set('taux_autoconso', +e.target.value / 100)} /></div>
              <div><label style={lbl}>Conso annuelle (kWh)</label><input style={inp} type="number" value={form.conso_annuelle_kwh} onChange={e => set('conso_annuelle_kwh', +e.target.value)} /></div>
            </div>
            <div style={{ ...g2, marginBottom: 8 }}>
              <div><label style={lbl}>Prix kWh fournisseur</label><input style={inp} type="number" step={0.01} value={form.prix_kwh_fournisseur} onChange={e => set('prix_kwh_fournisseur', +e.target.value)} /></div>
              <div><label style={lbl}>Tarif revente ACC</label><input style={inp} type="number" step={0.01} value={form.tarif_revente_acc} onChange={e => set('tarif_revente_acc', +e.target.value)} /></div>
            </div>
          </Section>
        )}

        <Section title="Soulte & Loyer" collapsible>
          <div style={{ ...g2, marginBottom: 8 }}>
            <div><label style={lbl}>Soulte propriétaire (% CA)</label><input style={inp} type="number" step={0.01} value={form.soulte_pct_ca} onChange={e => set('soulte_pct_ca', +e.target.value)} /></div>
            <div><label style={lbl}>Loyer sol (€/kWc/an)</label><input style={inp} type="number" value={form.loyer_kwc} onChange={e => set('loyer_kwc', +e.target.value)} /></div>
          </div>
        </Section>

        <Section title={t('sim.section.finance')}>
          <div style={{ ...g2, marginBottom: 8 }}>
            <div><label style={lbl}>{t('sim.levier')} (%)</label><input style={inp} type="number" value={Math.round(form.levier * 100)} onChange={e => set('levier', +e.target.value / 100)} /></div>
            <div><label style={lbl}>{t('sim.taux_interet')} (%)</label><input style={inp} type="number" step={0.01} value={form.taux_interet} onChange={e => set('taux_interet', +e.target.value)} /></div>
          </div>
          <div style={{ marginBottom: 8 }}>
            <label style={lbl}>{t('sim.maturite')}</label>
            <input style={inp} type="number" value={form.maturite_ans} onChange={e => set('maturite_ans', +e.target.value)} />
          </div>
        </Section>

        <Section title={t('sim.section.charges')} collapsible>
          <div style={{ ...g2, marginBottom: 8 }}>
            <div><label style={lbl}>{t('sim.maintenance')}</label><input style={inp} type="number" value={form.maintenance_kwc} onChange={e => set('maintenance_kwc', +e.target.value)} /></div>
            <div><label style={lbl}>{t('sim.assurance')}</label><input style={inp} type="number" value={form.assurance_kwc} onChange={e => set('assurance_kwc', +e.target.value)} /></div>
          </div>
          <div style={{ ...g2, marginBottom: 8 }}>
            <div><label style={lbl}>IFER (€/kWc, vide=auto)</label><input style={inp} type="number" value={form.ifer_kwc ?? ''} onChange={e => set('ifer_kwc', e.target.value ? +e.target.value : null)} /></div>
            <div><label style={lbl}>Autres taxes (€/kWc)</label><input style={inp} type="number" value={form.autres_taxes_kwc} onChange={e => set('autres_taxes_kwc', +e.target.value)} /></div>
          </div>
          <div style={{ ...g2, marginBottom: 8 }}>
            <div><label style={lbl}>Remplacement onduleurs</label><input style={inp} type="number" value={form.remplacement_onduleurs_kwc} onChange={e => set('remplacement_onduleurs_kwc', +e.target.value)} /></div>
            <div><label style={lbl}>{t('sim.loyer')}</label><input style={inp} type="number" value={form.loyer_kwc} onChange={e => set('loyer_kwc', +e.target.value)} /></div>
          </div>
        </Section>

        <Section title="Modèle Nov'Era" collapsible>
          <label style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, cursor: 'pointer', marginBottom: 10 }}>
            <input type="checkbox" checked={form.novera_actif} onChange={e => set('novera_actif', e.target.checked)} />
            Activer le modèle Nov'Era
          </label>
          {form.novera_actif && (
            <>
              <div style={{ ...g2, marginBottom: 8 }}>
                <div><label style={lbl}>Années paiement</label><input style={inp} type="number" value={form.novera_annees_paiement} onChange={e => set('novera_annees_paiement', +e.target.value)} /></div>
                <div><label style={lbl}>% paiements annuels</label><input style={inp} type="number" step={0.1} value={form.novera_pct_paiement} onChange={e => set('novera_pct_paiement', +e.target.value)} /></div>
              </div>
              <div style={{ ...g2, marginBottom: 8 }}>
                <div><label style={lbl}>% rachat</label><input style={inp} type="number" step={0.1} value={form.novera_pct_rachat} onChange={e => set('novera_pct_rachat', +e.target.value)} /></div>
                <div><label style={lbl}>Taux VAN (%)</label><input style={inp} type="number" step={0.1} value={form.novera_taux_van} onChange={e => set('novera_taux_van', +e.target.value)} /></div>
              </div>
              <div style={{ ...g2, marginBottom: 8 }}>
                <div><label style={lbl}>Levier phase 3 (%)</label><input style={inp} type="number" value={form.novera_levier_phase3} onChange={e => set('novera_levier_phase3', +e.target.value)} /></div>
                <div><label style={lbl}>Maturité phase 3 (ans)</label><input style={inp} type="number" value={form.novera_maturite_phase3} onChange={e => set('novera_maturite_phase3', +e.target.value)} /></div>
              </div>
            </>
          )}
        </Section>

        <button onClick={handleCalculer} disabled={loading} style={{
          width: '100%', padding: '11px', borderRadius: 8, border: 'none',
          background: loading ? '#9ca3af' : '#064e3b', color: '#fff',
          fontWeight: 800, fontSize: 13, cursor: loading ? 'default' : 'pointer',
        }}>
          {loading ? t('sim.calculating') : t('sim.calculate')}
        </button>
        {error && <div style={{ marginTop: 8, color: '#ef4444', fontSize: 11, background: '#fee2e2', borderRadius: 6, padding: 8 }}>{error}</div>}
      </div>

      {/* ── Résultats ── */}
      <div style={{ flex: 1, overflowY: 'auto', minWidth: 0 }}>
        {!result ? (
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%', flexDirection: 'column', gap: 12, color: '#9ca3af' }}>
            <div style={{ fontSize: 52 }}>☀️</div>
            <div style={{ fontSize: 16, fontWeight: 700 }}>{t('sim.empty')}</div>
            <div style={{ fontSize: 13 }}>{t('sim.empty.sub')}</div>
          </div>
        ) : (
          <>
            {/* KPIs ligne 1 */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 10, marginBottom: 10 }}>
              <KpiCard label={t('sim.kpi.capex')} value={fmt(kpis.capex_total, ' €')} sub={`${fmt(kpis.capex_kwc)} €/kWc`} bg="#eff6ff" color="#1e40af" border="#bfdbfe" />
              <KpiCard label={t('sim.kpi.ca_p90')} value={fmt(kpis.ca_an1_p90_eur, ' €')} sub={`P50 : ${fmt(kpis.ca_an1_p50_eur, ' €')}`} bg="#f0fdf4" color="#065f46" border="#bbf7d0" />
              <KpiCard label={t('sim.kpi.tri')} value={pct(kpis.tri_p50)} sub={`P90 : ${pct(kpis.tri_p90)}`} bg="#fefce8" color="#92400e" border="#fde68a" />
              <KpiCard label="VAN P50 (5%)" value={keur(kpis.van?.p50_5pct)} sub={`P90 : ${keur(kpis.van?.p90_5pct)}`} bg="#fdf4ff" color="#7e22ce" border="#e9d5ff" />
              <KpiCard label="DSCR moyen" value={kpis.dscr_moyen ? `${kpis.dscr_moyen}x` : '—'} sub={kpis.dscr_moyen >= 1.15 ? '✅ > 1.15' : kpis.dscr_moyen ? '⚠️ < 1.15' : 'N/A'} bg={kpis.dscr_moyen >= 1.15 ? '#f0fdf4' : '#fff7ed'} color={kpis.dscr_moyen >= 1.15 ? '#065f46' : '#92400e'} />
            </div>
            {/* KPIs ligne 2 */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 10, marginBottom: 16 }}>
              <KpiCard label={t('sim.kpi.production')} value={fmt(kpis.production_kwh_an, ' kWh')} sub="P90 · an 1" />
              <KpiCard label={t('sim.kpi.tarif')} value={`${kpis.tarif_achat_mwh} €/MWh`} sub="Tarif S21 sécurisé" />
              <KpiCard label={t('sim.kpi.fp')} value={fmt(kpis.fonds_propres, ' €')} sub={`Emprunt : ${fmt(kpis.emprunt, ' €')}`} />
              <KpiCard label="Payback" value={kpis.payback_ans ? `${kpis.payback_ans} ans` : '—'} sub="Retour sur investissement" />
              <KpiCard label={t('sim.kpi.rdt')} value={pct(kpis.rendement_net_30ans)} sub={`Brut : ${pct(kpis.rendement_brut)}`} />
            </div>

            {/* VAN multi-taux */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10, marginBottom: 16 }}>
              {[['3', '#f0fdf4', '#065f46'], ['5', '#eff6ff', '#1e40af'], ['7', '#fdf4ff', '#7e22ce']].map(([t_rate, bg, color]) => (
                <div key={t_rate} style={{ background: bg, border: '1px solid #e5e7eb', borderRadius: 8, padding: '10px 14px' }}>
                  <div style={{ fontSize: 10, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 4 }}>VAN à {t_rate}%</div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <div><div style={{ fontSize: 11, color: '#9ca3af' }}>P50</div><div style={{ fontSize: 15, fontWeight: 800, color }}>{keur(kpis.van?.[`p50_${t_rate}pct`])}</div></div>
                    <div style={{ textAlign: 'right' }}><div style={{ fontSize: 11, color: '#9ca3af' }}>P90</div><div style={{ fontSize: 15, fontWeight: 700, color }}>{keur(kpis.van?.[`p90_${t_rate}pct`])}</div></div>
                  </div>
                </div>
              ))}
            </div>

            {/* Tabs */}
            <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, overflow: 'hidden' }}>
              <div style={{ display: 'flex', borderBottom: '1px solid #e5e7eb', overflowX: 'auto' }}>
                {TABS.map(tb => (
                  <button key={tb.id} onClick={() => setTab(tb.id)} style={{
                    padding: '10px 16px', border: 'none', cursor: 'pointer', fontSize: 12, whiteSpace: 'nowrap',
                    fontWeight: tab === tb.id ? 700 : 500,
                    background: tab === tb.id ? '#fff' : '#f9fafb',
                    color: tab === tb.id ? '#064e3b' : '#6b7280',
                    borderBottom: tab === tb.id ? '2px solid #064e3b' : '2px solid transparent',
                  }}>{tb.label}</button>
                ))}
              </div>

              <div style={{ padding: 20 }}>

                {/* ── Cashflows ── */}
                {tab === 'cashflow' && (
                  <>
                    <div style={{ fontSize: 12, color: '#9ca3af', marginBottom: 12 }}>{t('sim.chart.ca')}</div>
                    <ResponsiveContainer width="100%" height={280}>
                      <BarChart data={chartCF} margin={{ top: 0, right: 10, left: 0, bottom: 0 }}>
                        <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" />
                        <XAxis dataKey="annee" tick={{ fontSize: 10 }} tickFormatter={v => `A${v}`} />
                        <YAxis tick={{ fontSize: 10 }} tickFormatter={v => `${v}k`} />
                        <Tooltip content={<TTip />} />
                        <Legend wrapperStyle={{ fontSize: 11 }} />
                        <Bar dataKey="CA P90" fill="#059669" radius={[3,3,0,0]} />
                        <Bar dataKey="CA P50" fill="#34d399" radius={[3,3,0,0]} />
                        <Bar dataKey="Cash P90" fill="#2563eb" radius={[3,3,0,0]} />
                      </BarChart>
                    </ResponsiveContainer>
                    {chartDSCR.length > 0 && (
                      <>
                        <div style={{ fontSize: 12, color: '#9ca3af', marginTop: 20, marginBottom: 10 }}>DSCR — ratio couverture dette (min. 1.15 banque)</div>
                        <ResponsiveContainer width="100%" height={160}>
                          <LineChart data={chartDSCR} margin={{ top: 0, right: 10, left: 0, bottom: 0 }}>
                            <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" />
                            <XAxis dataKey="annee" tick={{ fontSize: 10 }} tickFormatter={v => `A${v}`} />
                            <YAxis tick={{ fontSize: 10 }} domain={[0, 'auto']} />
                            <Tooltip />
                            <ReferenceLine y={1.15} stroke="#ef4444" strokeDasharray="4 4" label={{ value: '1.15', position: 'right', fontSize: 10 }} />
                            <Line type="monotone" dataKey="DSCR" stroke="#7c3aed" strokeWidth={2} dot={false} />
                          </LineChart>
                        </ResponsiveContainer>
                      </>
                    )}
                  </>
                )}

                {/* ── Trésorerie cumulée ── */}
                {tab === 'cumul' && (
                  <>
                    <div style={{ fontSize: 12, color: '#9ca3af', marginBottom: 12 }}>{t('sim.chart.cumul')}</div>
                    <ResponsiveContainer width="100%" height={300}>
                      <AreaChart data={chartCumul} margin={{ top: 0, right: 10, left: 0, bottom: 0 }}>
                        <defs>
                          <linearGradient id="g90" x1="0" y1="0" x2="0" y2="1"><stop offset="5%" stopColor="#059669" stopOpacity={0.2} /><stop offset="95%" stopColor="#059669" stopOpacity={0} /></linearGradient>
                          <linearGradient id="g50" x1="0" y1="0" x2="0" y2="1"><stop offset="5%" stopColor="#2563eb" stopOpacity={0.2} /><stop offset="95%" stopColor="#2563eb" stopOpacity={0} /></linearGradient>
                        </defs>
                        <CartesianGrid strokeDasharray="3 3" stroke="#f3f4f6" />
                        <XAxis dataKey="annee" tick={{ fontSize: 10 }} tickFormatter={v => `A${v}`} />
                        <YAxis tick={{ fontSize: 10 }} tickFormatter={v => `${v}k`} />
                        <Tooltip content={<TTip />} />
                        <Legend wrapperStyle={{ fontSize: 11 }} />
                        <ReferenceLine y={0} stroke="#ef4444" strokeDasharray="4 4" />
                        <Area type="monotone" dataKey="P90" stroke="#059669" strokeWidth={2} fill="url(#g90)" />
                        <Area type="monotone" dataKey="P50" stroke="#2563eb" strokeWidth={2} fill="url(#g50)" />
                      </AreaChart>
                    </ResponsiveContainer>
                  </>
                )}

                {/* ── CAPEX ── */}
                {tab === 'capex' && (
                  <>
                    <div style={{ fontSize: 12, color: '#9ca3af', marginBottom: 16 }}>{t('sim.chart.capex')} : <strong>{fmt(capex.total_ht, ' €')}</strong> HT — {fmt(capex.total_kwc, ' €/kWc')}</div>
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 8 }}>
                      {capexItems.map(item => (
                        <div key={item.name} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 14px', background: '#f9fafb', borderRadius: 8, border: '1px solid #e5e7eb' }}>
                          <div style={{ width: 10, height: 10, borderRadius: '50%', background: item.c, flexShrink: 0 }} />
                          <div style={{ flex: 1 }}>
                            <div style={{ fontSize: 12, fontWeight: 600 }}>{item.name}</div>
                            <div style={{ fontSize: 11, color: '#9ca3af' }}>{Math.round(item.v / capex.total_ht * 100)} % du total</div>
                          </div>
                          <div style={{ fontSize: 13, fontWeight: 700, color: item.c }}>{fmt(item.v / 1000, ' k€', 1)}</div>
                        </div>
                      ))}
                    </div>
                    <div style={{ marginTop: 16, padding: '12px 16px', background: '#f9fafb', borderRadius: 8, border: '1px solid #e5e7eb' }}>
                      <div style={{ fontSize: 12, fontWeight: 700, marginBottom: 8 }}>Résumé</div>
                      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8, fontSize: 12 }}>
                        <div><span style={{ color: '#9ca3af' }}>Total HT :</span><strong> {fmt(capex.total_ht, ' €')}</strong></div>
                        <div><span style={{ color: '#9ca3af' }}>TVA (20%) :</span><strong> {fmt(capex.total_ht * 0.2, ' €')}</strong></div>
                        <div><span style={{ color: '#9ca3af' }}>Total TTC :</span><strong> {fmt(capex.total_ht * 1.2, ' €')}</strong></div>
                      </div>
                    </div>
                  </>
                )}

                {/* ── Raccordement ── */}
                {tab === 'raccordement' && raccordement && (
                  <>
                    <div style={{ marginBottom: 16 }}>
                      <div style={{ display: 'inline-block', padding: '4px 12px', background: raccordement.zone === 'ZFA' ? '#dbeafe' : '#ede9fe', color: raccordement.zone === 'ZFA' ? '#1e40af' : '#5b21b6', borderRadius: 20, fontSize: 12, fontWeight: 700, marginBottom: 12 }}>
                        Zone {raccordement.zone} — {form.region}
                      </div>
                      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 10 }}>
                        {[
                          ['Branchement BT', raccordement.branchement, '#059669'],
                          ['Extension BT', raccordement.extension_bt, '#2563eb'],
                          ['Quotes-parts S3REnR', raccordement.quotes_parts_s3renr, '#7c3aed'],
                          ['Relai supplémentaire', raccordement.relai_supplementaire, '#f59e0b'],
                        ].map(([label, val, color]) => (
                          <div key={label} style={{ padding: '12px 14px', background: '#f9fafb', borderRadius: 8, border: '1px solid #e5e7eb' }}>
                            <div style={{ fontSize: 11, color: '#9ca3af', marginBottom: 4 }}>{label}</div>
                            <div style={{ fontSize: 16, fontWeight: 800, color }}>{fmt(val, ' €')}</div>
                          </div>
                        ))}
                      </div>
                      <div style={{ marginTop: 12, padding: '14px 16px', background: '#064e3b', borderRadius: 8, color: '#fff' }}>
                        <div style={{ fontSize: 11, opacity: 0.7 }}>Total raccordement ENEDIS + S3REnR</div>
                        <div style={{ fontSize: 22, fontWeight: 800 }}>{fmt(raccordement.total, ' €')} <span style={{ fontSize: 13, opacity: 0.7 }}>— {raccordement.total_kwc} €/kWc</span></div>
                      </div>
                    </div>
                  </>
                )}

                {/* ── Autoconsommation ── */}
                {tab === 'autoconso' && (
                  ac && Object.keys(ac).length > 0 ? (
                    <>
                      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10, marginBottom: 16 }}>
                        <KpiCard label="Taux autoconsommation" value={pct(ac.taux_autoconsommation, 1)} sub={`Autosuffisance : ${pct(ac.taux_autosuffisance, 1)}`} bg="#f0fdf4" color="#065f46" />
                        <KpiCard label="Économie annuelle" value={fmt(ac.economie_annuelle_eur, ' €')} sub="Vs facture fournisseur" bg="#fefce8" color="#92400e" />
                        <KpiCard label="Réduction facture" value={pct(ac.reduction_facture_pct, 1)} sub={`Revenu injection : ${fmt(ac.revenu_injection_eur, ' €')}`} bg="#eff6ff" color="#1e40af" />
                      </div>
                      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 10 }}>
                        {[
                          ['Production P90', ac.production_p90_kwh, 'kWh', '#059669'],
                          ['Production P50', ac.production_p50_kwh, 'kWh', '#34d399'],
                          ['Énergie autoconsommée', ac.energie_autoconsommee_kwh, 'kWh', '#2563eb'],
                          ['Énergie soutirée réseau', ac.energie_soutirée_reseau_kwh, 'kWh', '#6b7280'],
                          ['Injection réseau P90', ac.injection_reseau_p90_kwh, 'kWh', '#7c3aed'],
                          ['Prime autoconsommation', ac.prime_autoconso_eur, '€', '#f59e0b'],
                        ].map(([label, val, unit, color]) => (
                          <div key={label} style={{ padding: '12px 14px', background: '#f9fafb', borderRadius: 8, border: '1px solid #e5e7eb' }}>
                            <div style={{ fontSize: 11, color: '#9ca3af', marginBottom: 4 }}>{label}</div>
                            <div style={{ fontSize: 16, fontWeight: 700, color }}>{fmt(val)} <span style={{ fontSize: 12 }}>{unit}</span></div>
                          </div>
                        ))}
                      </div>
                    </>
                  ) : (
                    <div style={{ padding: 40, textAlign: 'center', color: '#9ca3af' }}>Activez l'autoconsommation dans le panneau de saisie pour voir ces données.</div>
                  )
                )}

                {/* ── Nov'Era ── */}
                {tab === 'novera' && (
                  novera ? (
                    <>
                      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 12, marginBottom: 20 }}>
                        <div style={{ background: '#f0fdf4', border: '1px solid #bbf7d0', borderRadius: 10, padding: 16 }}>
                          <div style={{ fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 8 }}>Conservateur (Modèle revenus)</div>
                          <div style={{ fontSize: 13, marginBottom: 4 }}>TRI : <strong style={{ color: '#065f46' }}>{pct(novera.conservateur.tri)}</strong></div>
                          <div style={{ fontSize: 13, marginBottom: 4 }}>VAN ({form.novera_taux_van}%) : <strong>{keur(novera.conservateur.van)}</strong></div>
                          <div style={{ fontSize: 11, color: '#9ca3af', marginTop: 8 }}>{novera.conservateur.annees_paiement} paiements × {form.novera_pct_paiement}% + rachat {form.novera_pct_rachat}%</div>
                        </div>
                        <div style={{ background: '#fefce8', border: '1px solid #fde68a', borderRadius: 10, padding: 16 }}>
                          <div style={{ fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 8 }}>Energy Manager</div>
                          <div style={{ fontSize: 13, marginBottom: 4 }}>EBE total : <strong style={{ color: '#92400e' }}>{keur(novera.energy_manager.total * 1000)}</strong></div>
                          <div style={{ fontSize: 11, color: '#9ca3af', marginTop: 8 }}>EBE annuels (k€) :</div>
                          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 4, marginTop: 4 }}>
                            {novera.energy_manager.ebe_annuel.map((v, i) => (
                              <span key={i} style={{ fontSize: 10, background: v >= 0 ? '#d1fae5' : '#fee2e2', color: v >= 0 ? '#065f46' : '#991b1b', padding: '2px 6px', borderRadius: 4 }}>A{i+1}: {fmt(v, '', 1)}</span>
                            ))}
                          </div>
                        </div>
                        <div style={{ background: '#eff6ff', border: '1px solid #bfdbfe', borderRadius: 10, padding: 16 }}>
                          <div style={{ fontSize: 11, fontWeight: 700, color: '#9ca3af', textTransform: 'uppercase', marginBottom: 8 }}>Phase 3 — Investisseur</div>
                          <div style={{ fontSize: 13, marginBottom: 4 }}>TRI : <strong style={{ color: '#1e40af' }}>{pct(novera.phase3_investisseur.tri)}</strong></div>
                          <div style={{ fontSize: 13, marginBottom: 4 }}>VAN : <strong>{keur(novera.phase3_investisseur.van)}</strong></div>
                          <div style={{ fontSize: 13, marginBottom: 4 }}>Rachat : <strong>{fmt(novera.phase3_investisseur.rachat_valeur_eur, ' €')}</strong></div>
                          <div style={{ fontSize: 13 }}>Apport FP requis : <strong>{fmt(novera.phase3_investisseur.apport_fp_requis_eur, ' €')}</strong></div>
                        </div>
                      </div>
                    </>
                  ) : (
                    <div style={{ padding: 40, textAlign: 'center', color: '#9ca3af' }}>Activez le modèle Nov'Era dans le panneau de saisie.</div>
                  )
                )}

                {/* ── Tableau 30 ans ── */}
                {tab === 'table' && (
                  <div style={{ overflowX: 'auto' }}>
                    <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 11 }}>
                      <thead style={{ background: '#f9fafb', position: 'sticky', top: 0 }}>
                        <tr>
                          {[t('sim.col.an'), t('sim.col.ca_p90'), t('sim.col.ca_p50'), t('sim.col.charges'), 'Soulte', t('sim.col.treso'), t('sim.col.cash_p90'), t('sim.col.cash_p50'), 'IS', t('sim.col.interets'), 'DSCR'].map(h => (
                            <th key={h} style={{ padding: '8px 10px', textAlign: 'right', fontSize: 10, color: '#6b7280', fontWeight: 700, textTransform: 'uppercase', borderBottom: '1px solid #e5e7eb', whiteSpace: 'nowrap' }}>{h}</th>
                          ))}
                        </tr>
                      </thead>
                      <tbody>
                        {prev.map((a, i) => (
                          <tr key={a.annee} style={{ background: i % 2 === 0 ? '#fff' : '#fafafa', borderBottom: '1px solid #f3f4f6' }}>
                            <td style={{ padding: '6px 10px', fontWeight: 700, color: '#374151' }}>A{a.annee}</td>
                            <td style={{ padding: '6px 10px', textAlign: 'right', color: '#059669', fontWeight: 600 }}>{fmt(a.ca_p90, '', 2)}</td>
                            <td style={{ padding: '6px 10px', textAlign: 'right', color: '#059669' }}>{fmt(a.ca_p50, '', 2)}</td>
                            <td style={{ padding: '6px 10px', textAlign: 'right', color: '#ef4444' }}>{fmt(a.charges, '', 2)}</td>
                            <td style={{ padding: '6px 10px', textAlign: 'right', color: '#f59e0b' }}>{a.soulte > 0 ? fmt(a.soulte, '', 2) : '—'}</td>
                            <td style={{ padding: '6px 10px', textAlign: 'right', color: a.treso_exploit_p90 >= 0 ? '#059669' : '#ef4444', fontWeight: 600 }}>{fmt(a.treso_exploit_p90, '', 2)}</td>
                            <td style={{ padding: '6px 10px', textAlign: 'right', color: a.cashflow_p90 >= 0 ? '#2563eb' : '#ef4444', fontWeight: 600 }}>{fmt(a.cashflow_p90, '', 2)}</td>
                            <td style={{ padding: '6px 10px', textAlign: 'right', color: a.cashflow_p50 >= 0 ? '#2563eb' : '#ef4444' }}>{fmt(a.cashflow_p50, '', 2)}</td>
                            <td style={{ padding: '6px 10px', textAlign: 'right', color: '#9ca3af' }}>{fmt(a.is_p90, '', 2)}</td>
                            <td style={{ padding: '6px 10px', textAlign: 'right', color: '#9ca3af' }}>{fmt(a.interet, '', 2)}</td>
                            <td style={{ padding: '6px 10px', textAlign: 'right', color: a.dscr >= 1.15 ? '#059669' : '#f59e0b', fontWeight: a.dscr ? 600 : 400 }}>{a.dscr ?? '—'}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  )
}
