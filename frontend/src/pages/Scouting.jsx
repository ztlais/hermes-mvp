import { useState } from 'react'
import ScoutingMarket from '../components/scouting/ScoutingMarket'
import { PLATFORMS } from '../components/scouting/shared'

const MARKETS = [
  { key: 'FR', label: '🇫🇷 France' },
  { key: 'BE', label: '🇧🇪 Belgique' },
  { key: 'ES', label: '🇪🇸 Espagne' },
]

export default function Scouting() {
  const [market, setMarket] = useState('FR')
  const [showAdd, setShowAdd] = useState(false)
  const [showPlatforms, setShowPlatforms] = useState(false)
  const [searchPlatform, setSearchPlatform] = useState('')

  return (
    <div style={{ height: 'calc(100vh - 64px)', display: 'flex', flexDirection: 'column' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12, flexShrink: 0 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1f2937' }}>🔍 Scouting ENR</h1>
          <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
            {MARKETS.map(m => (
              <button key={m.key} onClick={() => setMarket(m.key)} style={{
                padding: '6px 14px', borderRadius: 6, border: 'none', cursor: 'pointer',
                fontSize: 13, fontWeight: 700,
                background: market === m.key ? '#1f2937' : '#f3f4f6',
                color: market === m.key ? '#fff' : '#6b7280',
              }}>{m.label}</button>
            ))}
          </div>
        </div>
        <button onClick={() => setShowAdd(true)} style={{ padding: '9px 18px', background: '#2563eb', color: '#fff', border: 'none', borderRadius: 6, fontWeight: 700, cursor: 'pointer' }}>
          + Nouveau
        </button>
      </div>

      {/* Platforms section (commune aux 3 marchés) */}
      <div style={{ marginBottom: 12, flexShrink: 0 }}>
        <button onClick={() => setShowPlatforms(!showPlatforms)} style={{
          padding: '5px 10px', borderRadius: 6, border: '1px solid #d1d5db', background: showPlatforms ? '#f3f4f6' : '#fff', cursor: 'pointer', fontSize: 12, fontWeight: 600
        }}>
          📋 Plateformes de recherche {showPlatforms ? '▲' : '▼'}
        </button>
        {showPlatforms && (
          <div style={{ marginTop: 8, background: '#f9fafb', borderRadius: 8, padding: 12, border: '1px solid #e5e7eb', maxHeight: 240, overflowY: 'auto' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8, flexWrap: 'wrap', gap: 8 }}>
              <div style={{ fontSize: 12, color: '#6b7280' }}>
                ✅ {PLATFORMS.filter(p => p.statut.includes('Fait')).length} exploitées · 🔍 {PLATFORMS.filter(p => p.statut.includes('À faire')).length} à explorer · {PLATFORMS.length} total
              </div>
              <div style={{ display: 'flex', gap: 8 }}>
                <select value={searchPlatform} onChange={e => setSearchPlatform(e.target.value)} style={{ padding: '4px 8px', border: '1px solid #d1d5db', borderRadius: 4, fontSize: 12 }}>
                  <option value="">Choisir une plateforme...</option>
                  {PLATFORMS.filter(p => p.statut.includes('À faire')).map(p => (
                    <option key={p.name} value={p.name}>{p.name}</option>
                  ))}
                </select>
                {searchPlatform && (
                  <a href={PLATFORMS.find(p => p.name === searchPlatform)?.url} target="_blank" rel="noreferrer" style={{
                    padding: '4px 10px', background: '#2563eb', color: '#fff', borderRadius: 4, textDecoration: 'none', fontSize: 12, fontWeight: 600
                  }}>
                    🔍 Rechercher de nouveaux clients
                  </a>
                )}
                <button onClick={() => setShowAdd(true)} style={{
                  padding: '4px 10px', background: '#059669', color: '#fff', borderRadius: 4, border: 'none', cursor: 'pointer', fontSize: 12, fontWeight: 600
                }}>
                  + Ajouter à la base
                </button>
              </div>
            </div>
            <table style={{ width: '100%', fontSize: 11, borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ color: '#6b7280', textTransform: 'uppercase', fontSize: 10 }}>
                  <th style={{ textAlign: 'left', padding: '4px 8px' }}>Plateforme</th>
                  <th style={{ textAlign: 'left', padding: '4px 8px' }}>Cible</th>
                  <th style={{ textAlign: 'left', padding: '4px 8px' }}>Statut</th>
                  <th style={{ textAlign: 'left', padding: '4px 8px' }}>Notes</th>
                </tr>
              </thead>
              <tbody>
                {PLATFORMS.map(p => (
                  <tr key={p.name} style={{ borderBottom: '1px solid #f3f4f6' }}>
                    <td style={{ padding: '4px 8px', fontWeight: 600 }}>
                      {p.url ? <a href={p.url} target="_blank" rel="noreferrer" style={{ color: '#2563eb', textDecoration: 'none' }}>{p.name}</a> : p.name}
                    </td>
                    <td style={{ padding: '4px 8px', color: '#6b7280' }}>{p.cible}</td>
                    <td style={{ padding: '4px 8px' }}>
                      <span style={{ fontSize: 10, fontWeight: 600, color: p.statut.includes('Fait') ? '#065f46' : '#92400e' }}>
                        {p.statut}
                      </span>
                    </td>
                    <td style={{ padding: '4px 8px', color: '#9ca3af' }}>{p.note}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Board */}
      <div style={{ flex: 1, minHeight: 0 }}>
        <ScoutingMarket market={market} marketLabel={MARKETS.find(m => m.key === market)?.label} showAdd={showAdd} onCloseAdd={() => setShowAdd(false)} />
      </div>
    </div>
  )
}
