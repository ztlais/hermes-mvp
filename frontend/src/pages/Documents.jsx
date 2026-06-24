import { useEffect, useState } from 'react'
import api from '../api/client'
import { useLang } from '../context/LanguageContext'

const TYPE_LABELS = {
  nda: 'NDA',
  fee_agreement: 'Fee Agreement',
  teaser: 'Teaser',
  presentation: 'Présentation',
  compte_rendu: 'Compte Rendu',
  contract: 'Contrat',
  methodology: '📋 Méthodologie',
  memoire: '📘 Mémoire',
  other: 'Autre',
}

const TYPE_ICONS = {
  nda: '',
  fee_agreement: '',
  teaser: '',
  presentation: '',
  compte_rendu: '',
  contract: '',
  methodology: '📋',
  memoire: '📘',
  other: '',
}

const TYPE_COLORS = {
  nda: '#7c3aed',
  fee_agreement: '#1e40af',
  teaser: '#065f46',
  presentation: '#92400e',
  compte_rendu: '#92400e',
  contract: '#991b1b',
  methodology: '#0369a1',
  memoire: '#6b21a8',
  other: '#4b5563',
}

const TYPE_BG = {
  nda: '#ede9fe',
  fee_agreement: '#dbeafe',
  teaser: '#d1fae5',
  presentation: '#fef3c7',
  compte_rendu: '#fef3c7',
  contract: '#fee2e2',
  methodology: '#e0f2fe',
  memoire: '#f3e8ff',
  other: '#f3f4f6',
}

/* =============================================================
   THÈMES DU MÉMOIRE
   Chaque thème est un objet avec id, nom, icon, et items[]
   On peut ajouter d'autres thèmes ici facilement.
   ============================================================= */
const MEMOIRE_THEMES = [
  {
    id: 'stade-developpement',
    name: '📊 Stade de développement',
    icon: '📊',
    items: [
      {
        id: 'origination',
        title: 'Origination',
        subtitle: '🔍 Identification foncier',
        secured: 'Rien de sécurisé',
        ongoing: 'Prospection foncière',
        detail: 'Aucun terrain sécurisé. Recherche de sites potentiels.',
      },
      {
        id: 'early',
        title: 'Early (Précoce)',
        subtitle: '✅ Foncier sécurisé / 📝 Env ongoing',
        secured: 'Real estate — Secured',
        ongoing: 'Environmental — Ongoing',
        detail: 'Foncier sécurisé (promesse de bail signée). Études environnement en cours.',
      },
      {
        id: 'submit',
        title: 'Submit',
        subtitle: '✅ Autorités locales / 📝 Dépôt PC imminent',
        secured: 'Authorities — Secured',
        ongoing: 'Permitting — Near apply (date pas arrivée)',
        detail: 'Appui des autorités locales obtenu. PC prêt à déposer, date de dépôt pas encore arrivée.',
      },
      {
        id: 'mid',
        title: 'Mid',
        subtitle: '✅ Foncier sécurisé / ✅ PC déposé / 📝 En instruction',
        secured: 'Easements — Secured / Permitting — Submitted',
        ongoing: 'Permit en instruction',
        detail: 'Servitudes foncières sécurisées. PC déposé (date passée). En attente de la décision.',
      },
      {
        id: 'nearly-secured-recours',
        title: 'Nearly secured — Recours',
        subtitle: '✅ PC obtenu / ⚖️ Recours',
        secured: 'Permitting — Obtained',
        ongoing: 'Sous recours — purge en attente',
        detail: 'PC obtenu mais un recours a été déposé. En attente de purge.',
      },
      {
        id: 'nearly-secured-purge',
        title: 'Nearly secured — Purgé',
        subtitle: '✅ PC purgé',
        secured: 'Permitting — Obtained (purgé)',
        ongoing: '— (toiture) Rien de plus, pc purgé suffit',
        detail: 'PC purgé de tout recours. Pour les projets toiture, PC purgé = final. Pour les projets sol, raccordement et tarif restent à sécuriser.',
      },
      {
        id: 'secured-clean',
        title: 'Secured & clean',
        subtitle: '✅ Raccordement sécurisé / ✅ Tarif sécurisé',
        secured: 'Grid connection — Secured / Tariff — Secured',
        ongoing: 'Rien — projet prêt à construire',
        detail: 'Raccordement au réseau sécurisé + contrat d\'achat signé (PPA, AO CRE gagné, E17, etc.).',
      },
      {
        id: 'refused',
        title: 'Refused',
        subtitle: '❌ PC refusé',
        secured: 'Rien — projet arrêté',
        ongoing: '',
        detail: 'Permis refusé. Projet abandonné.',
      },
    ],
  },
  // 💡 Ajoute d'autres thèmes ici :
  // {
  //   id: 'finance',
  //   name: '💰 Financement',
  //   icon: '💰',
  //   items: [ ... ]
  // },
]

export default function Documents() {
  const { lang } = useLang()
  const [docs, setDocs] = useState([])
  const [loading, setLoading] = useState(true)
  const [showAdd, setShowAdd] = useState(false)
  const [form, setForm] = useState({ name: '', url: '', doc_type: 'other' })
  const [expanded, setExpanded] = useState({})
  const [search, setSearch] = useState('')
  // Mémoire: thème ouvert ? thème.id -> true/false
  const [expandedTheme, setExpandedTheme] = useState({})
  // Mémoire: item ouvert dans un thème ? 'themeId-itemId' -> true/false
  const [expandedItem, setExpandedItem] = useState({})

  const loadDocs = () => {
    setLoading(true)
    api.get('/documents/')
      .then(r => setDocs(r.data))
      .catch(() => {})
      .finally(() => setLoading(false))
  }

  useEffect(() => { loadDocs() }, [])

  const handleAdd = async () => {
    if (!form.name || !form.url) return
    try {
      await api.post('/documents/', form)
      setForm({ name: '', url: '', doc_type: 'other' })
      setShowAdd(false)
      loadDocs()
    } catch (e) {
      alert('Erreur: ' + (e.response?.data?.detail || e.message))
    }
  }

  const handleDelete = async (id) => {
    if (!confirm('Supprimer ce document ?')) return
    try {
      await api.delete(`/documents/${id}`)
      loadDocs()
    } catch (e) {
      alert('Erreur: ' + (e.response?.data?.detail || e.message))
    }
  }

  const filtered = search
    ? docs.filter(d => (d.name || '').toLowerCase().includes(search.toLowerCase()))
    : docs

  const grouped = {}
  filtered.forEach(d => {
    const cat = d.doc_type || 'other'
    if (!grouped[cat]) grouped[cat] = []
    grouped[cat].push(d)
  })

  const toggle = (cat) => {
    setExpanded(prev => ({ ...prev, [cat]: !prev[cat] }))
  }

  const toggleTheme = (themeId) => {
    setExpandedTheme(prev => ({ ...prev, [themeId]: !prev[themeId] }))
  }

  const toggleItem = (themeId, itemId) => {
    const key = `${themeId}-${itemId}`
    setExpandedItem(prev => ({ ...prev, [key]: !prev[key] }))
  }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
        <h2 style={{ margin: 0, fontSize: 20, color: '#1f2937' }}>Documents</h2>
        <button onClick={() => setShowAdd(!showAdd)}
          style={{ padding: '8px 16px', borderRadius: 8, border: 'none', background: '#059669', color: '#fff', fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>
          + {lang === 'fr' ? 'Ajouter' : 'Add'}
        </button>
      </div>

      {showAdd && (
        <div style={{ background: '#f9fafb', border: '1px solid #e5e7eb', borderRadius: 10, padding: 16, marginBottom: 12 }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            <input placeholder={lang === 'fr' ? 'Nom du document' : 'Document name'}
              value={form.name} onChange={e => setForm({...form, name: e.target.value})}
              style={{ padding: '8px 12px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 13 }} />
            <input placeholder="URL (lien Google Drive, Dropbox, etc.)"
              value={form.url} onChange={e => setForm({...form, url: e.target.value})}
              style={{ padding: '8px 12px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 13 }} />
            <select value={form.doc_type} onChange={e => setForm({...form, doc_type: e.target.value})}
              style={{ padding: '8px 12px', borderRadius: 6, border: '1px solid #d1d5db', fontSize: 13, background: '#fff' }}>
              {Object.entries(TYPE_LABELS).map(([k, v]) => (
                <option key={k} value={k}>{v}</option>
              ))}
            </select>
            <div style={{ display: 'flex', gap: 8 }}>
              <button onClick={handleAdd}
                style={{ padding: '8px 20px', borderRadius: 6, border: 'none', background: '#059669', color: '#fff', fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>
                ✅ {lang === 'fr' ? 'Ajouter' : 'Add'}
              </button>
              <button onClick={() => setShowAdd(false)}
                style={{ padding: '8px 20px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', color: '#374151', fontSize: 13, cursor: 'pointer' }}>
                {lang === 'fr' ? 'Annuler' : 'Cancel'}
              </button>
            </div>
          </div>
        </div>
      )}

      <div style={{ marginBottom: 14 }}>
        <input
          placeholder={lang === 'fr' ? '🔍 Rechercher un document...' : '🔍 Search documents...'}
          value={search}
          onChange={e => setSearch(e.target.value)}
          style={{
            width: '100%', padding: '9px 14px', borderRadius: 8,
            border: '1px solid #d1d5db', fontSize: 13,
            boxSizing: 'border-box', outline: 'none',
          }}
        />
      </div>

      {loading ? (
        <div style={{ color: '#9ca3af', fontSize: 14, padding: '40px 0', textAlign: 'center' }}>⏳ Chargement...</div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          {/* =========== MÉMOIRE =========== */}
          <div key="memoire" style={{
            background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10,
            overflow: 'hidden', transition: 'all 0.15s',
          }}>
            <div onClick={() => toggle('memoire')}
              style={{
                display: 'flex', alignItems: 'center', gap: 10,
                padding: '12px 16px', cursor: 'pointer',
                userSelect: 'none', transition: 'all 0.15s',
              }}>
              <span style={{ flexShrink: 0, fontSize: 16 }}>📘</span>
              <span style={{ flex: 1, fontWeight: 700, fontSize: 13, color: '#1f2937' }}>
                Mémoire
              </span>
              <span style={{
                padding: '2px 8px', borderRadius: 6, fontSize: 11, fontWeight: 600,
                background: '#f3e8ff', color: '#6b21a8',
              }}>
                {MEMOIRE_THEMES.length} thème{MEMOIRE_THEMES.length > 1 ? 's' : ''}
              </span>
              <span style={{
                fontSize: 12, color: '#9ca3af', transition: 'transform 0.2s',
                transform: expanded['memoire'] ? 'rotate(180deg)' : 'rotate(0deg)',
              }}>
                ▼
              </span>
            </div>

            {expanded['memoire'] && (
              <div style={{
                borderTop: '1px solid #f3f4f6', background: '#fafafa',
                padding: '12px 16px',
              }}>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                  {MEMOIRE_THEMES.map(theme => {
                    const themeOpen = expandedTheme[theme.id]
                    return (
                      <div key={theme.id} style={{
                        background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8,
                        overflow: 'hidden',
                      }}>
                        {/* En-tête du thème */}
                        <div onClick={() => toggleTheme(theme.id)}
                          style={{
                            display: 'flex', alignItems: 'center', gap: 8,
                            padding: '10px 12px', cursor: 'pointer',
                            userSelect: 'none',
                          }}>
                          <span style={{ fontSize: 15 }}>{theme.icon}</span>
                          <span style={{
                            flex: 1, fontWeight: 700, fontSize: 13, color: '#1f2937',
                          }}>
                            {theme.name}
                          </span>
                          <span style={{
                            padding: '2px 8px', borderRadius: 6, fontSize: 11, fontWeight: 600,
                            background: '#f3e8ff', color: '#6b21a8',
                          }}>
                            {theme.items.length}
                          </span>
                          <span style={{
                            fontSize: 10, color: '#9ca3af', transition: 'transform 0.2s',
                            transform: themeOpen ? 'rotate(180deg)' : 'rotate(0deg)',
                          }}>
                            ▼
                          </span>
                        </div>

                        {/* Items du thème */}
                        {themeOpen && (
                          <div style={{
                            borderTop: '1px solid #f3f4f6',
                            padding: '8px 10px',
                            background: '#fcfcfc',
                            display: 'flex', flexDirection: 'column', gap: 6,
                          }}>
                            {theme.items.map(item => {
                              const itemKey = `${theme.id}-${item.id}`
                              const itemOpen = expandedItem[itemKey]
                              return (
                                <div key={item.id} style={{
                                  background: '#fff', border: '1px solid #e5e7eb', borderRadius: 6,
                                  overflow: 'hidden',
                                }}>
                                  <div onClick={() => toggleItem(theme.id, item.id)}
                                    style={{
                                      display: 'flex', alignItems: 'center', gap: 6,
                                      padding: '8px 10px', cursor: 'pointer',
                                      userSelect: 'none',
                                    }}>
                                    <span style={{
                                      flex: 1, fontWeight: 600, fontSize: 12, color: '#1f2937',
                                    }}>
                                      {item.title}
                                    </span>
                                    <span style={{
                                      fontSize: 11, color: '#6b7280', fontWeight: 500,
                                    }}>
                                      {item.subtitle}
                                    </span>
                                    <span style={{
                                      fontSize: 9, color: '#9ca3af', transition: 'transform 0.2s',
                                      transform: itemOpen ? 'rotate(180deg)' : 'rotate(0deg)',
                                    }}>
                                      ▼
                                    </span>
                                  </div>
                                  {itemOpen && (
                                    <div style={{
                                      borderTop: '1px solid #f3f4f6',
                                      padding: '8px 10px',
                                      background: '#fafafa',
                                    }}>
                                      <div style={{ display: 'flex', flexDirection: 'column', gap: 5, fontSize: 12 }}>
                                        <div style={{ display: 'flex', gap: 6 }}>
                                          <span style={{ fontWeight: 600, color: '#059669', minWidth: 75 }}>✅ Sécurisé:</span>
                                          <span style={{ color: '#374151' }}>{item.secured}</span>
                                        </div>
                                        {item.ongoing && (
                                          <div style={{ display: 'flex', gap: 6 }}>
                                            <span style={{ fontWeight: 600, color: '#d97706', minWidth: 75 }}>📝 En cours:</span>
                                            <span style={{ color: '#374151' }}>{item.ongoing}</span>
                                          </div>
                                        )}
                                        <div style={{ display: 'flex', gap: 6 }}>
                                          <span style={{ fontWeight: 600, color: '#6b7280', minWidth: 75 }}>💬 Détail:</span>
                                          <span style={{ color: '#4b5563' }}>{item.detail}</span>
                                        </div>
                                      </div>
                                    </div>
                                  )}
                                </div>
                              )
                            })}
                          </div>
                        )}
                      </div>
                    )
                  })}
                </div>
              </div>
            )}
          </div>

          {/* =========== AUTRES DOCUMENTS =========== */}
          {Object.entries(grouped).map(([type, items]) => {
            if (type === 'memoire') return null
            const isOpen = expanded[type]
            const color = TYPE_COLORS[type] || '#6b7280'
            const bg = TYPE_BG[type] || '#f3f4f6'
            return (
              <div key={type} style={{
                background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10,
                overflow: 'hidden', transition: 'all 0.15s',
              }}>
                <div onClick={() => toggle(type)}
                  style={{
                    display: 'flex', alignItems: 'center', gap: 10,
                    padding: '12px 16px', cursor: 'pointer',
                    userSelect: 'none', transition: 'all 0.15s',
                  }}>
                  {TYPE_ICONS[type] && (
                  <span style={{ flexShrink: 0, fontSize: 16 }}>{TYPE_ICONS[type]}</span>
                  )}
                  <span style={{
                    flex: 1, fontWeight: 700, fontSize: 13, color: '#1f2937',
                  }}>
                    {TYPE_LABELS[type] || 'Autre'}
                  </span>
                  <span style={{
                    padding: '2px 8px', borderRadius: 6, fontSize: 11, fontWeight: 600,
                    background: bg, color: color,
                  }}>
                    {items.length}
                  </span>
                  <span style={{
                    fontSize: 12, color: '#9ca3af', transition: 'transform 0.2s',
                    transform: isOpen ? 'rotate(180deg)' : 'rotate(0deg)',
                  }}>
                    ▼
                  </span>
                </div>

                {isOpen && (
                  <div style={{
                    borderTop: '1px solid #f3f4f6', background: '#fafafa',
                  }}>
                    {items.map(doc => (
                      <div key={doc.id} style={{
                        display: 'flex', alignItems: 'center', gap: 10,
                        padding: '10px 16px', borderBottom: '1px solid #f3f4f6',
                      }}>
                        <a href={doc.url} target="_blank" rel="noreferrer"
                          style={{
                            flex: 1, color: '#2563eb', fontWeight: 500, fontSize: 13,
                            textDecoration: 'none', overflow: 'hidden',
                            textOverflow: 'ellipsis', whiteSpace: 'nowrap',
                          }}>
                          {doc.name}
                        </a>
                        <button onClick={() => handleDelete(doc.id)}
                          style={{
                            background: 'none', border: 'none', color: '#ef4444',
                            cursor: 'pointer', fontSize: 14, padding: '2px 4px',
                            flexShrink: 0, opacity: 0.5,
                          }}>
                          🗑️
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}
