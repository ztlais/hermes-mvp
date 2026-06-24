import { useState, useEffect, useRef } from 'react'
import api from '../api/client'

const CATEGORIES = [
  { value: 'general', label: '📌 Général', color: '#6b7280' },
  { value: 'prospect', label: '👤 Prospect', color: '#1e40af' },
  { value: 'action', label: '⚡ Action', color: '#92400e' },
  { value: 'question', label: '❓ Question', color: '#5b21b6' },
  { value: 'team', label: '👥 Équipe', color: '#0891b2' },
]

const TEAM_CATEGORIES = [
  { value: 'team', label: '👥 Équipe', color: '#0891b2' },
  { value: 'question', label: '❓ Question', color: '#5b21b6' },
]

const PRIORITIES = [
  { value: 'haute', label: '🔴 Haute', color: '#dc2626' },
  { value: 'moyenne', label: '🟡 Moyenne', color: '#d97706' },
  { value: 'basse', label: '🟢 Basse', color: '#059669' },
]

const ASSIGNEES = ['Zein', 'Mariella', 'Les deux']

const PRIO_MAP = Object.fromEntries(PRIORITIES.map(p => [p.value, p]))
const CAT_MAP = Object.fromEntries(CATEGORIES.map(c => [c.value, c]))

function SuggestionSection({ title, list, addingTask, onAdd, dismissingSuggestion, onDismiss, emptyText }) {
  const [expandedRef, setExpandedRef] = useState(null)

  return (
    <div>
      <div style={{ padding: '8px 14px', background: '#fafafa', borderBottom: '1px solid #f3f4f6', fontSize: 12, fontWeight: 700, color: '#374151' }}>
        {title} ({list.length})
      </div>
      {list.length === 0 ? (
        <div style={{ padding: 16, textAlign: 'center', color: '#9ca3af', fontSize: 13 }}>{emptyText}</div>
      ) : (
        <div style={{ maxHeight: 320, overflowY: 'auto' }}>
          {list.map((s, i) => (
            <div key={s.ref} style={{
              padding: '10px 14px',
              borderBottom: i < list.length - 1 ? '1px solid #f3f4f6' : 'none',
            }}>
              <div style={{ display: 'flex', gap: 10, alignItems: 'flex-start' }}>
                <div style={{
                  width: 28, height: 28, borderRadius: 8,
                  background: s.score >= 6 ? '#fef2f2' : s.score >= 4 ? '#fffbeb' : '#f3f4f6',
                  color: s.score >= 6 ? '#dc2626' : s.score >= 4 ? '#d97706' : '#6b7280',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 12, fontWeight: 700, flexShrink: 0,
                }}>{s.score}</div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 13, fontWeight: 600, color: '#1f2937' }}>
                    {s.company} {s.ai_generated && <span title="Tâche générée par IA à partir des notes" style={{ fontSize: 10, fontWeight: 500, color: '#7c3aed' }}>✨</span>}
                  </div>
                  {s.contact_name && <div style={{ fontSize: 11, color: '#6b7280' }}>👤 {s.contact_name}</div>}
                  {s.task && <div style={{ fontSize: 12, color: '#1f2937', fontWeight: 600, marginTop: 3 }}>→ {s.task}</div>}
                  <div style={{ fontSize: 11, color: '#6366f1', marginTop: 2 }}>{s.reason}</div>
                  {s.next_action && <div style={{ fontSize: 11, color: '#92400e', marginTop: 1 }}>⏭️ {s.next_action.slice(0, 80)}</div>}
                  {s.notes && (
                    <button
                      onClick={() => setExpandedRef(expandedRef === s.ref ? null : s.ref)}
                      style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0, marginTop: 4, fontSize: 11, color: '#9333ea', fontWeight: 600 }}>
                      {expandedRef === s.ref ? '▾ Masquer la note' : '📝 Voir la note'}
                    </button>
                  )}
                  {expandedRef === s.ref && s.notes && (
                    <div style={{ marginTop: 6, padding: 8, background: '#f9fafb', border: '1px solid #e5e7eb', borderRadius: 6, fontSize: 11, color: '#374151', whiteSpace: 'pre-wrap' }}>
                      {s.notes}
                    </div>
                  )}
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 4, flexShrink: 0 }}>
                  <button onClick={() => onAdd(s)} disabled={addingTask === s.ref}
                    style={{
                      padding: '5px 10px', borderRadius: 6, border: 'none', cursor: 'pointer',
                      fontSize: 11, fontWeight: 600, whiteSpace: 'nowrap',
                      background: addingTask === s.ref ? '#d1fae5' : '#2563eb',
                      color: addingTask === s.ref ? '#065f46' : '#fff',
                    }}>
                    {addingTask === s.ref ? '✅' : '+ Tâche'}
                  </button>
                  <button onClick={() => onDismiss(s)} disabled={dismissingSuggestion === s.ref}
                    style={{
                      padding: '4px 10px', borderRadius: 6, border: '1px solid #e5e7eb', cursor: 'pointer',
                      fontSize: 11, fontWeight: 600, whiteSpace: 'nowrap',
                      background: '#fff', color: '#9ca3af',
                    }}>
                    {dismissingSuggestion === s.ref ? '…' : '✕ Ignorer'}
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default function WeeklyPrep() {
  const [tasks, setTasks] = useState([])
  const [stats, setStats] = useState({ total: 0, fait: 0, en_cours: 0, a_faire: 0 })
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [filterAssignee, setFilterAssignee] = useState('')
  const [filterCategory, setFilterCategory] = useState('')
  const [outcomeFor, setOutcomeFor] = useState(null)
  const [outcomeText, setOutcomeText] = useState('')
  const [section, setSection] = useState('crm') // 'crm' | 'team'
  const [quickAddText, setQuickAddText] = useState('')
  const [weekFilter, setWeekFilter] = useState('current') // 'current' | 'all'
  const [searchQuery, setSearchQuery] = useState('')
  const formRef = useRef(null)

  const [showSuggestions, setShowSuggestions] = useState(true)
  const [prospectSuggestions, setProspectSuggestions] = useState([])
  const [investorSuggestions, setInvestorSuggestions] = useState([])
  const [loadingSuggestions, setLoadingSuggestions] = useState(false)
  const [regenerating, setRegenerating] = useState(false)
  const [addingTask, setAddingTask] = useState(null)
  const [dismissingSuggestion, setDismissingSuggestion] = useState(null)

  const loadSuggestions = async () => {
    setLoadingSuggestions(true)
    setShowSuggestions(true)
    try {
      const r = await api.get('/weekly-tasks/suggestions')
      setProspectSuggestions(r.data.prospects || [])
      setInvestorSuggestions(r.data.investors || [])
    } catch { setProspectSuggestions([]); setInvestorSuggestions([]) }
    setLoadingSuggestions(false)
  }

  const regenerateSuggestions = async () => {
    setRegenerating(true)
    setShowSuggestions(true)
    try {
      const r = await api.post('/weekly-tasks/suggestions/regenerate')
      setProspectSuggestions(r.data.prospects || [])
      setInvestorSuggestions(r.data.investors || [])
    } catch { /* keep current suggestions on failure */ }
    setRegenerating(false)
  }

  const addSuggestionAsTask = async (s) => {
    setAddingTask(s.ref)
    await api.post('/weekly-tasks/', {
      title: s.task || (`Suivi ${s.company}` + (s.next_action ? ` — ${s.next_action.slice(0, 40)}` : '')),
      description: s.reason + (s.notes_preview ? `\n\n${s.notes_preview}` : ''),
      category: 'prospect',
      priority: s.score >= 6 ? 'haute' : s.score >= 4 ? 'moyenne' : 'basse',
      assignee: '',
      related_company: s.company,
      prospect_id: s.prospect_id,
      suggestion_id: s.id,
    })
    setAddingTask(null)
    loadSuggestions()  // refresh from DB to remove the converted suggestion
    load()  // refresh task list
  }

  const dismissSuggestion = async (s) => {
    setDismissingSuggestion(s.ref)
    try {
      await api.delete(`/weekly-tasks/suggestions/${s.id}`)
      if (s.source === 'investor') {
        setInvestorSuggestions(prev => prev.filter(x => x.id !== s.id))
      } else {
        setProspectSuggestions(prev => prev.filter(x => x.id !== s.id))
      }
    } catch { /* leave it visible on failure */ }
    setDismissingSuggestion(null)
  }

  const [form, setForm] = useState({
    title: '', description: '', category: 'general',
    priority: 'moyenne', assignee: '', related_company: '', prospect_id: null,
  })
  const [prospectQuery, setProspectQuery] = useState('')
  const [prospectResults, setProspectResults] = useState([])

  const load = (filter) => {
    const mode = filter || weekFilter
    setLoading(true)
    const url = mode === 'all' ? '/weekly-tasks/all-weeks' : '/weekly-tasks/current-week'
    api.get(url)
      .then(r => {
        setTasks(r.data.tasks || [])
        setStats({ total: r.data.total, fait: r.data.fait, en_cours: r.data.en_cours, a_faire: r.data.a_faire })
        setLoading(false)
      })
      .catch(() => setLoading(false))
  }

  const switchWeekFilter = (mode) => {
    setWeekFilter(mode)
    load(mode)
  }

  useEffect(() => { load(); loadSuggestions() }, [])

  const addTask = async () => {
    if (!form.title.trim()) return
    await api.post('/weekly-tasks/', {
      title: form.title.trim(),
      description: form.description.trim() || null,
      category: form.category,
      priority: form.priority,
      assignee: form.assignee,
      related_company: form.related_company.trim() || null,
      prospect_id: form.prospect_id,
    })
    setForm({ title: '', description: '', category: 'general', priority: 'moyenne', assignee: '', related_company: '', prospect_id: null })
    setProspectQuery('')
    setProspectResults([])
    setShowForm(false)
    load()
  }

  const searchProspects = async (q) => {
    setProspectQuery(q)
    setForm(f => ({ ...f, prospect_id: null, related_company: q }))
    if (q.trim().length < 2) { setProspectResults([]); return }
    const r = await api.get('/prospects/', { params: { search: q.trim() } })
    setProspectResults((r.data || []).slice(0, 6))
  }

  const pickProspect = (p) => {
    setForm(f => ({ ...f, prospect_id: p.id, related_company: p.company }))
    setProspectQuery(p.company)
    setProspectResults([])
  }

  // Décocher = retour en arrière, pas de note nécessaire.
  // Cocher = on ouvre la capture du résultat (sera répercuté sur le prospect lié).
  const toggleDone = async (id, currentDone) => {
    if (currentDone) {
      await api.put(`/weekly-tasks/${id}/undone`)
      load()
    } else {
      setOutcomeText('')
      setOutcomeFor(id)
    }
  }

  const confirmDone = async (id, withOutcome) => {
    await api.put(`/weekly-tasks/${id}/done`, withOutcome ? { outcome: outcomeText.trim() } : {})
    setOutcomeFor(null)
    setOutcomeText('')
    load()
  }

  const setStatus = async (id, status) => {
    await api.put(`/weekly-tasks/${id}`, { status })
    load()
  }

  const assignTask = async (id, assignee) => {
    await api.put(`/weekly-tasks/${id}`, { assignee })
    load()
  }

  const moveSection = async (id, newCategory) => {
    await api.put(`/weekly-tasks/${id}`, { category: newCategory })
    load()
  }

  const deleteTask = async (id) => {
    await api.delete(`/weekly-tasks/${id}`)
    load()
  }

  const handleQuickAdd = async (title) => {
    await api.post('/weekly-tasks/', {
      title,
      description: null,
      category: section === 'team' ? 'team' : 'general',
      priority: 'moyenne',
      assignee: section === 'team' ? 'Zein' : '',
      related_company: null,
      prospect_id: null,
    })
    setQuickAddText('')
    load()
  }

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      addTask()
    }
  }

  const activeCategories = section === 'team' ? TEAM_CATEGORIES : CATEGORIES

  // Filtering
  const filtered = tasks.filter(t => {
    if (section === 'team' && t.category !== 'team' && t.category !== 'question') return false
    if (section === 'crm' && t.category === 'team') return false
    if (filterAssignee && t.assignee !== filterAssignee) return false
    if (filterCategory && t.category !== filterCategory) return false
    if (searchQuery) {
      const q = searchQuery.toLowerCase()
      const match = (t.title?.toLowerCase() || '').includes(q)
        || (t.description?.toLowerCase() || '').includes(q)
        || (t.related_company?.toLowerCase() || '').includes(q)
      if (!match) return false
    }
    return true
  })

  const aFaire = filtered.filter(t => t.status === 'a_faire')
  const enCours = filtered.filter(t => t.status === 'en_cours')
  const fait = filtered.filter(t => t.status === 'fait')

  const progress = stats.total > 0 ? Math.round((stats.fait / stats.total) * 100) : 0

  const openForm = () => {
    setShowForm(true)
    setTimeout(() => formRef.current?.focus(), 100)
  }

  return (
    <div style={{ maxWidth: 900, margin: '0 auto' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16, flexWrap: 'wrap', gap: 10 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1f2937', margin: 0 }}>
            📋 Réunion Hebdo
          </h1>
          <p style={{ fontSize: 13, color: '#6b7280', marginTop: 2 }}>
            {stats.total} tâches · {stats.fait} finies · {stats.en_cours} en cours · {stats.a_faire} à faire
          </p>
        </div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <div style={{ display: 'flex', background: '#f3f4f6', borderRadius: 8, padding: 2 }}>
            <button onClick={() => setSection('crm')} style={{
              padding: '6px 14px', borderRadius: 6, border: 'none', cursor: 'pointer',
              fontSize: 12, fontWeight: 700,
              background: section === 'crm' ? '#fff' : 'transparent',
              color: section === 'crm' ? '#1f2937' : '#6b7280',
              boxShadow: section === 'crm' ? '0 1px 3px rgba(0,0,0,0.1)' : 'none',
            }}>📋 Tâches CRM</button>
            <button onClick={() => setSection('team')} style={{
              padding: '6px 14px', borderRadius: 6, border: 'none', cursor: 'pointer',
              fontSize: 12, fontWeight: 700,
              background: section === 'team' ? '#fff' : 'transparent',
              color: section === 'team' ? '#1f2937' : '#6b7280',
              boxShadow: section === 'team' ? '0 1px 3px rgba(0,0,0,0.1)' : 'none',
            }}>👥 Équipe</button>
          </div>
          <div style={{ display: 'flex', background: '#f3f4f6', borderRadius: 8, padding: 2 }}>
            <button onClick={() => switchWeekFilter('current')} style={{
              padding: '6px 10px', borderRadius: 6, border: 'none', cursor: 'pointer',
              fontSize: 11, fontWeight: 700, whiteSpace: 'nowrap',
              background: weekFilter === 'current' ? '#fff' : 'transparent',
              color: weekFilter === 'current' ? '#1f2937' : '#6b7280',
              boxShadow: weekFilter === 'current' ? '0 1px 3px rgba(0,0,0,0.1)' : 'none',
            }}>📅 Cette semaine</button>
            <button onClick={() => switchWeekFilter('all')} style={{
              padding: '6px 10px', borderRadius: 6, border: 'none', cursor: 'pointer',
              fontSize: 11, fontWeight: 700, whiteSpace: 'nowrap',
              background: weekFilter === 'all' ? '#fff' : 'transparent',
              color: weekFilter === 'all' ? '#1f2937' : '#6b7280',
              boxShadow: weekFilter === 'all' ? '0 1px 3px rgba(0,0,0,0.1)' : 'none',
            }}>📅 Toutes</button>
          </div>
          <button onClick={openForm}
          style={{
            padding: '9px 18px', background: '#2563eb', color: '#fff', border: 'none',
            borderRadius: 6, fontWeight: 700, cursor: 'pointer', fontSize: 13,
          }}>
          + Nouvelle tâche
        </button>
      </div>
    </div>

      {/* Progress bar */}
      {stats.total > 0 && (
        <div style={{ marginBottom: 12, background: '#e5e7eb', borderRadius: 10, height: 8, overflow: 'hidden' }}>
          <div style={{
            width: `${progress}%`, height: '100%',
            background: progress === 100 ? '#059669' : '#2563eb',
            borderRadius: 10, transition: 'width 0.3s',
          }} />
        </div>
      )}

      {/* Quick add task bar - tape et Enter pour ajouter direct */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 10, alignItems: 'center' }}>
        <span style={{ fontSize: 12, fontWeight: 600, color: '#6b7280', whiteSpace: 'nowrap' }}>
          {section === 'team' ? '👥' : '📋'} Ajout rapide:
        </span>
        <input
          value={quickAddText}
          onChange={e => setQuickAddText(e.target.value)}
          onKeyDown={e => {
            if (e.key === 'Enter' && quickAddText.trim()) {
              handleQuickAdd(quickAddText.trim())
            }
          }}
          placeholder={section === 'team' ? 'Tâche équipe, question pour Mariella...' : 'Nouvelle tâche CRM...'}
          style={{
            flex: 1, padding: '7px 12px', border: '1px solid #d1d5db', borderRadius: 6,
            fontSize: 13, fontFamily: 'inherit',
          }}
        />
        <button onClick={() => { if (quickAddText.trim()) handleQuickAdd(quickAddText.trim()) }}
          disabled={!quickAddText.trim()}
          style={{
            padding: '7px 16px', borderRadius: 6, border: 'none', cursor: 'pointer',
            fontSize: 12, fontWeight: 700,
            background: quickAddText.trim() ? '#059669' : '#9ca3af',
            color: '#fff', whiteSpace: 'nowrap',
          }}>
          + Ajouter
        </button>
      </div>

      {/* Filters */}
      <div style={{ display: 'flex', gap: 6, marginBottom: 12, flexWrap: 'wrap', alignItems: 'center' }}>
        <span style={{ fontSize: 11, fontWeight: 700, color: '#6b7280' }}>Filtrer:</span>
        <select value={filterAssignee} onChange={e => setFilterAssignee(e.target.value)}
          style={{ padding: '4px 8px', border: '1px solid #d1d5db', borderRadius: 4, fontSize: 12 }}>
          <option value="">Tous</option>
          {ASSIGNEES.map(a => <option key={a} value={a}>{a}</option>)}
        </select>
        <select value={filterCategory} onChange={e => setFilterCategory(e.target.value)}
          style={{ padding: '4px 8px', border: '1px solid #d1d5db', borderRadius: 4, fontSize: 12 }}>
          <option value="">Toutes catégories</option>
          {activeCategories.map(c => <option key={c.value} value={c.value}>{c.label}</option>)}
        </select>
        <input
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          placeholder="🔍 Rechercher dans les tâches..."
          style={{
            padding: '4px 8px', border: '1px solid #d1d5db', borderRadius: 4, fontSize: 12,
            fontFamily: 'inherit', width: 180,
          }}
        />
        <div style={{ flex: 1 }} />
        <button onClick={loadSuggestions}
          style={{
            padding: '6px 14px', borderRadius: 6, border: '1px solid #c7d2fe',
            background: showSuggestions ? '#eef2ff' : '#fff',
            fontSize: 12, fontWeight: 600, cursor: 'pointer',
            color: '#4338ca', display: 'flex', alignItems: 'center', gap: 5,
          }}>
          📋 Suggestions
        </button>
      </div>

      {/* Add form */}
      {showForm && (
        <div style={{ marginBottom: 16, background: '#fff', border: '1px solid #e5e7eb', borderRadius: 10, padding: 16, boxShadow: '0 4px 12px rgba(0,0,0,0.06)' }}>
          <input
            ref={formRef}
            value={form.title}
            onChange={e => setForm(f => ({ ...f, title: e.target.value }))}
            onKeyDown={handleKeyDown}
            placeholder="Titre de la tâche (Enter pour ajouter)"
            style={{
              width: '100%', boxSizing: 'border-box',
              padding: '10px 12px', border: '1px solid #d1d5db', borderRadius: 6,
              fontSize: 14, fontWeight: 600, fontFamily: 'inherit',
            }}
            autoFocus
          />
          <textarea
            value={form.description}
            onChange={e => setForm(f => ({ ...f, description: e.target.value }))}
            placeholder="Description ou note (optionnel)"
            style={{
              width: '100%', boxSizing: 'border-box', marginTop: 8,
              padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6,
              fontSize: 12, fontFamily: 'inherit', resize: 'vertical', minHeight: 50,
            }}
          />
          <div style={{ display: 'flex', gap: 8, marginTop: 10, flexWrap: 'wrap', alignItems: 'center' }}>
            {/* Categories */}
            {activeCategories.map(c => (
              <button key={c.value} onClick={() => setForm(f => ({ ...f, category: c.value }))}
                style={{
                  padding: '4px 10px', borderRadius: 6, border: 'none', cursor: 'pointer',
                  fontSize: 11, fontWeight: 600,
                  background: form.category === c.value ? c.color : '#f3f4f6',
                  color: form.category === c.value ? '#fff' : c.color,
                }}>
                {c.label}
              </button>
            ))}
            <span style={{ color: '#d1d5db' }}>|</span>
            {/* Priorities */}
            {PRIORITIES.map(p => (
              <button key={p.value} onClick={() => setForm(f => ({ ...f, priority: p.value }))}
                style={{
                  padding: '4px 10px', borderRadius: 6, border: 'none', cursor: 'pointer',
                  fontSize: 11, fontWeight: 600,
                  background: form.priority === p.value ? p.color : '#f3f4f6',
                  color: form.priority === p.value ? '#fff' : p.color,
                }}>
                {p.label}
              </button>
            ))}
            <span style={{ color: '#d1d5db' }}>|</span>
            {/* Assignee */}
            {ASSIGNEES.map(a => (
              <button key={a} onClick={() => setForm(f => ({ ...f, assignee: form.assignee === a ? '' : a }))}
                style={{
                  padding: '4px 10px', borderRadius: 6, border: 'none', cursor: 'pointer',
                  fontSize: 11, fontWeight: 600,
                  background: form.assignee === a ? '#1f2937' : '#f3f4f6',
                  color: form.assignee === a ? '#fff' : '#374151',
                }}>
                {a === 'Zein' ? '👤 Zein' : a === 'Mariella' ? '👤 Mariella' : '👥 Les deux'}
              </button>
            ))}
            {section === 'crm' && (
              <div style={{ position: 'relative', flex: 1, minWidth: 140 }}>
                <input
                  value={prospectQuery}
                  onChange={e => searchProspects(e.target.value)}
                  placeholder="🏢 Lier à un prospect (tape un nom)"
                  style={{
                    width: '100%', boxSizing: 'border-box', padding: '6px 10px', border: '1px solid #d1d5db',
                    borderRadius: 6, fontSize: 12,
                    background: form.prospect_id ? '#ecfdf5' : '#fff',
                    borderColor: form.prospect_id ? '#059669' : '#d1d5db',
                  }}
                />
                {prospectResults.length > 0 && (
                  <div style={{
                    position: 'absolute', top: '100%', left: 0, right: 0, zIndex: 10,
                    background: '#fff', border: '1px solid #d1d5db', borderRadius: 6,
                    marginTop: 2, boxShadow: '0 4px 12px rgba(0,0,0,0.1)', maxHeight: 160, overflowY: 'auto',
                  }}>
                    {prospectResults.map(p => (
                      <div key={p.id} onClick={() => pickProspect(p)}
                        style={{ padding: '6px 10px', fontSize: 12, cursor: 'pointer', borderBottom: '1px solid #f3f4f6' }}
                        onMouseEnter={e => e.currentTarget.style.background = '#f9fafb'}
                        onMouseLeave={e => e.currentTarget.style.background = '#fff'}>
                        <strong>{p.company}</strong>{p.contact_name ? ` — ${p.contact_name}` : ''}
                      </div>
                    ))}
                  </div>
                )}
                {form.prospect_id && (
                  <div style={{ fontSize: 10, color: '#059669', marginTop: 2 }}>✓ lié au CRM — la note de clôture mettra à jour ce prospect</div>
                )}
              </div>
            )}
            <button onClick={addTask} disabled={!form.title.trim()}
              style={{
                padding: '6px 16px', borderRadius: 6, border: 'none', cursor: 'pointer',
                fontSize: 12, fontWeight: 700,
                background: form.title.trim() ? '#2563eb' : '#9ca3af',
                color: '#fff',
              }}>
              Ajouter
            </button>
          </div>
        </div>
      )}

      {/* Suggestions panel */}
      {showSuggestions && (
        <div style={{ marginBottom: 16, background: '#fff', border: '1px solid #c7d2fe', borderRadius: 10, overflow: 'hidden' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 14px', background: '#eef2ff', borderBottom: '1px solid #c7d2fe' }}>
            <span style={{ fontSize: 13, fontWeight: 700, color: '#4338ca' }}>📋 Suggestions de tâches</span>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <button onClick={regenerateSuggestions} disabled={regenerating || loadingSuggestions}
                title="Recalcule les suggestions (relance l'analyse IA)"
                style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#6366f1', fontSize: 12, fontWeight: 600 }}>
                {regenerating ? '🔄 Régénération...' : '🔄 Régénérer'}
              </button>
              <button onClick={() => setShowSuggestions(false)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#6366f1', fontSize: 14 }}>✕</button>
            </div>
          </div>
          {loadingSuggestions || regenerating ? (
            <div style={{ padding: 20, textAlign: 'center', color: '#9ca3af', fontSize: 13 }}>
              {regenerating ? 'Régénération des suggestions (IA)...' : 'Chargement...'}
            </div>
          ) : (
            <>
              <SuggestionSection
                title="📋 Prospects" list={prospectSuggestions} addingTask={addingTask}
                onAdd={addSuggestionAsTask}
                dismissingSuggestion={dismissingSuggestion} onDismiss={dismissSuggestion}
                emptyText="Tous les prospects ont deja une tache cette semaine ✅"
              />
              <SuggestionSection
                title="💰 Investisseurs" list={investorSuggestions} addingTask={addingTask}
                onAdd={addSuggestionAsTask}
                dismissingSuggestion={dismissingSuggestion} onDismiss={dismissSuggestion}
                emptyText="Tous les investisseurs ont deja une tache cette semaine ✅"
              />
            </>
          )}
        </div>
      )}

      {/* Loading */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: 40, color: '#9ca3af' }}>Chargement...</div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {/* À faire */}
          {aFaire.length > 0 && (
            <div>
              <h2 style={{ fontSize: 14, fontWeight: 700, color: '#dc2626', margin: '0 0 8px 0', display: 'flex', alignItems: 'center', gap: 6 }}>
                <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#dc2626', display: 'inline-block' }} />
                À faire ({aFaire.length})
              </h2>
              {aFaire.map(t => <TaskCard key={t.id} task={t} onToggle={toggleDone} onStatus={setStatus} onAssignee={assignTask} onDelete={deleteTask} onMoveSection={moveSection}
                outcomeOpen={outcomeFor === t.id} outcomeText={outcomeText} setOutcomeText={setOutcomeText}
                onConfirmDone={confirmDone} onCancelOutcome={() => setOutcomeFor(null)} />)}
            </div>
          )}

          {/* En cours */}
          {enCours.length > 0 && (
            <div>
              <h2 style={{ fontSize: 14, fontWeight: 700, color: '#d97706', margin: '0 0 8px 0', display: 'flex', alignItems: 'center', gap: 6 }}>
                <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#d97706', display: 'inline-block' }} />
                En cours ({enCours.length})
              </h2>
              {enCours.map(t => <TaskCard key={t.id} task={t} onToggle={toggleDone} onStatus={setStatus} onAssignee={assignTask} onDelete={deleteTask} onMoveSection={moveSection}
                outcomeOpen={outcomeFor === t.id} outcomeText={outcomeText} setOutcomeText={setOutcomeText}
                onConfirmDone={confirmDone} onCancelOutcome={() => setOutcomeFor(null)} />)}
            </div>
          )}

          {/* Fait */}
          {fait.length > 0 && (
            <div>
              <h2 style={{ fontSize: 14, fontWeight: 700, color: '#059669', margin: '0 0 8px 0', display: 'flex', alignItems: 'center', gap: 6 }}>
                <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#059669', display: 'inline-block' }} />
                Fait ({fait.length})
              </h2>
              {fait.map(t => <TaskCard key={t.id} task={t} onToggle={toggleDone} onStatus={setStatus} onAssignee={assignTask} onDelete={deleteTask} onMoveSection={moveSection}
                outcomeOpen={outcomeFor === t.id} outcomeText={outcomeText} setOutcomeText={setOutcomeText}
                onConfirmDone={confirmDone} onCancelOutcome={() => setOutcomeFor(null)} />)}
            </div>
          )}

          {filtered.length === 0 && !loading && (
            <div style={{ textAlign: 'center', padding: 40, background: '#f9fafb', borderRadius: 10, color: '#9ca3af', fontSize: 13 }}>
              Aucune tâche cette semaine. Ajoutes-en une ! ✨
            </div>
          )}
        </div>
      )}
    </div>
  )
}

function TaskCard({ task, onToggle, onStatus, onAssignee, onDelete, onMoveSection, outcomeOpen, outcomeText, setOutcomeText, onConfirmDone, onCancelOutcome }) {
  const cat = CAT_MAP[task.category] || CAT_MAP.general
  const prio = PRIO_MAP[task.priority] || PRIO_MAP.moyenne
  const [showProspectNotes, setShowProspectNotes] = useState(false)
  const [prospectNotes, setProspectNotes] = useState(null)
  const [loadingNotes, setLoadingNotes] = useState(false)

  const loadProspectNotes = async () => {
    if (!task.prospect_id) return
    if (prospectNotes) { setShowProspectNotes(!showProspectNotes); return }
    setLoadingNotes(true)
    try {
      const r = await api.get(`/prospects/${task.prospect_id}`)
      setProspectNotes(r.data)
      setShowProspectNotes(true)
    } catch { setProspectNotes({ notes: '❌ Erreur chargement' }) }
    setLoadingNotes(false)
  }

  const dateStr = task.created_at
    ? new Date(task.created_at).toLocaleString('fr-FR', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' })
    : ''

  return (
    <div style={{
      display: 'flex', gap: 12, alignItems: 'flex-start',
      padding: '12px 16px', marginBottom: 4,
      background: task.done ? '#f9fafb' : '#fff',
      border: `1px solid ${task.done ? '#e5e7eb' : '#e5e7eb'}`,
      borderLeft: `4px solid ${task.done ? '#d1d5db' : cat.color}`,
      borderRadius: 8,
      opacity: task.done ? 0.55 : 1,
      transition: 'all 0.12s',
    }}>
      {/* Checkbox */}
      <div style={{ paddingTop: 2 }}>
        <button onClick={() => onToggle(task.id, task.done)}
          style={{
            width: 22, height: 22, borderRadius: 6,
            border: `2px solid ${task.done ? '#059669' : '#d1d5db'}`,
            background: task.done ? '#059669' : 'transparent',
            cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 12, color: '#fff', fontWeight: 700,
            transition: 'all 0.12s',
          }}>
          {task.done ? '✓' : ''}
        </button>
      </div>

      {/* Content */}
      <div style={{ flex: 1, minWidth: 0 }}>
        {/* Badges row */}
        <div style={{ display: 'flex', gap: 5, alignItems: 'center', marginBottom: 4, flexWrap: 'wrap' }}>
          <span style={{ fontSize: 10, fontWeight: 700, padding: '2px 7px', borderRadius: 4, background: cat.color + '18', color: cat.color }}>
            {cat.label}
          </span>
          <span style={{ fontSize: 10, fontWeight: 700, padding: '2px 7px', borderRadius: 4, background: prio.color + '18', color: prio.color }}>
            {prio.label}
          </span>
          {/* Section toggle */}
          <button onClick={() => onMoveSection(task.id, task.category === 'team' || task.category === 'question' ? 'general' : 'team')}
            style={{
              fontSize: 10, fontWeight: 600, padding: '2px 7px', borderRadius: 4,
              border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer',
              color: '#6b7280', display: 'inline-flex', alignItems: 'center', gap: 3,
              transition: 'all 0.12s',
            }}
            onMouseEnter={e => { e.currentTarget.style.background = '#f3f4f6'; e.currentTarget.style.border = '1px solid #9ca3af'; }}
            onMouseLeave={e => { e.currentTarget.style.background = '#fff'; e.currentTarget.style.border = '1px solid #d1d5db'; }}
            title={task.category === 'team' || task.category === 'question' ? 'Déplacer vers CRM' : 'Déplacer vers Équipe'}>
            {task.category === 'team' || task.category === 'question' ? '📋 CRM' : '👥 Équipe'}
          </button>
          {/* Assignee - cliquable */}
          {task.assignee ? (
            <span onClick={() => onAssignee(task.id, '')}
              style={{ fontSize: 10, fontWeight: 600, padding: '2px 7px', borderRadius: 4,
                background: '#f3f4f6', color: '#374151', cursor: 'pointer',
                display: 'inline-flex', alignItems: 'center', gap: 3,
                transition: 'all 0.12s',
              }}
              title="Cliquer pour enlever l'assignation">
              👤 {task.assignee} <span style={{ fontSize: 9, color: '#9ca3af' }}>✕</span>
            </span>
          ) : (
            ['Zein', 'Mariella', 'Les deux'].map(name => (
              <button key={name} onClick={() => onAssignee(task.id, name)}
                style={{
                  fontSize: 10, fontWeight: 600, padding: '2px 7px', borderRadius: 4,
                  border: '1px dashed #d1d5db', background: '#fff', cursor: 'pointer',
                  color: '#6b7280', display: 'inline-flex', alignItems: 'center', gap: 2,
                  transition: 'all 0.12s',
                }}
                onMouseEnter={e => { e.currentTarget.style.background = '#f3f4f6'; e.currentTarget.style.border = '1px solid #9ca3af'; }}
                onMouseLeave={e => { e.currentTarget.style.background = '#fff'; e.currentTarget.style.border = '1px dashed #d1d5db'; }}>
                👤 {name}
              </button>
            ))
          )}
          {task.related_company && (
            <span style={{ fontSize: 10, fontWeight: 500, color: '#2563eb', display: 'inline-flex', alignItems: 'center', gap: 4 }}>
              {task.prospect_id ? '🔗' : '🏢'} {task.related_company}
              {task.prospect_id && (
                <button onClick={loadProspectNotes}
                  style={{
                    background: 'none', border: 'none', cursor: 'pointer',
                    fontSize: 10, padding: '1px 3px', opacity: 0.7,
                    color: showProspectNotes ? '#059669' : '#2563eb',
                  }}
                  title="Voir les notes du prospect">
                  📋
                </button>
              )}
            </span>
          )}
          <span style={{ fontSize: 10, color: '#9ca3af', marginLeft: 'auto' }}>{dateStr}</span>
        </div>

        {/* Title */}
        <div style={{
          fontSize: 13, fontWeight: 600, color: task.done ? '#6b7280' : '#1f2937',
          textDecoration: task.done ? 'line-through' : 'none',
          lineHeight: 1.4,
        }}>
          {task.title}
        </div>

        {/* Description */}
        {task.description && (
          <div style={{
            fontSize: 12, color: '#6b7280', marginTop: 4, lineHeight: 1.5,
            whiteSpace: 'pre-wrap',
          }}>
            {task.description}
          </div>
        )}

        {/* Résultat enregistré (répercuté sur le CRM si tâche liée à un prospect) */}
        {task.outcome && (
          <div style={{
            fontSize: 11, color: '#065f46', marginTop: 6, padding: '6px 8px',
            background: '#ecfdf5', borderRadius: 6, lineHeight: 1.5, whiteSpace: 'pre-wrap',
          }}>
            ✅ {task.outcome}
          </div>
        )}

        {/* Prospect notes expandable */}
        {showProspectNotes && (
          <div style={{
            marginTop: 8, padding: 10, background: '#f0f4ff', border: '1px solid #c7d2fe',
            borderRadius: 8, fontSize: 11, lineHeight: 1.6, color: '#1e1b4b',
          }}>
            {loadingNotes ? (
              <div style={{ color: '#9ca3af', fontStyle: 'italic' }}>Chargement...</div>
            ) : prospectNotes ? (
              <div style={{ maxHeight: 300, overflowY: 'auto' }}>
                {prospectNotes.notes && (
                  <div>
                    <div style={{ fontSize: 9, fontWeight: 700, color: '#6366f1', textTransform: 'uppercase', marginBottom: 4 }}>📝 Notes</div>
                    <div style={{ whiteSpace: 'pre-wrap', marginBottom: 8 }}>{prospectNotes.notes}</div>
                  </div>
                )}
                {prospectNotes.next_action && (
                  <div style={{ background: '#fffbeb', padding: '6px 8px', borderRadius: 6, marginBottom: 6 }}>
                    <span style={{ fontWeight: 700 }}>⏭️ Prochaine action:</span> {prospectNotes.next_action}
                  </div>
                )}
                {prospectNotes.teaser && (
                  <div style={{ background: '#eff6ff', padding: '6px 8px', borderRadius: 6, marginBottom: 6 }}>
                    <span style={{ fontWeight: 700 }}>📄 Teaser:</span> {prospectNotes.teaser.slice(0, 200)}
                  </div>
                )}
                <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap', marginTop: 4 }}>
                  {prospectNotes.status && <span style={{ padding: '2px 6px', borderRadius: 4, background: '#e0e7ff', fontSize: 10 }}>Statut: {prospectNotes.status}</span>}
                  {prospectNotes.type && <span style={{ padding: '2px 6px', borderRadius: 4, background: '#e0e7ff', fontSize: 10 }}>Type: {prospectNotes.type}</span>}
                  {prospectNotes.nda_signed === 'Oui' && <span style={{ padding: '2px 6px', borderRadius: 4, background: '#d1fae5', color: '#065f46', fontSize: 10 }}>✅ NDA signé</span>}
                </div>
              </div>
            ) : (
              <div style={{ color: '#9ca3af', fontStyle: 'italic' }}>Pas de prospect lié</div>
            )}
          </div>
        )}

        {/* Capture du résultat à la clôture */}
        {outcomeOpen && (
          <div style={{ marginTop: 8, padding: 10, background: '#f9fafb', border: '1px solid #e5e7eb', borderRadius: 8 }}>
            <textarea
              autoFocus
              value={outcomeText}
              onChange={e => setOutcomeText(e.target.value)}
              placeholder={task.prospect_id
                ? "Quel résultat ? (réponse reçue, mail envoyé, doc obtenu...) — sera ajouté au prospect lié"
                : "Quel résultat ? (optionnel)"}
              style={{
                width: '100%', boxSizing: 'border-box', padding: '6px 8px', border: '1px solid #d1d5db',
                borderRadius: 6, fontSize: 12, fontFamily: 'inherit', resize: 'vertical', minHeight: 50,
              }}
            />
            <div style={{ display: 'flex', gap: 6, marginTop: 6 }}>
              <button onClick={() => onConfirmDone(task.id, true)} disabled={!outcomeText.trim()}
                style={{
                  padding: '5px 12px', borderRadius: 6, border: 'none', cursor: 'pointer',
                  fontSize: 11, fontWeight: 700, color: '#fff',
                  background: outcomeText.trim() ? '#059669' : '#9ca3af',
                }}>
                Valider {task.prospect_id ? '(+ maj CRM)' : ''}
              </button>
              <button onClick={() => onConfirmDone(task.id, false)}
                style={{ padding: '5px 12px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer', fontSize: 11, color: '#6b7280' }}>
                Marquer fait sans note
              </button>
              <button onClick={onCancelOutcome}
                style={{ padding: '5px 12px', borderRadius: 6, border: 'none', background: 'transparent', cursor: 'pointer', fontSize: 11, color: '#9ca3af' }}>
                Annuler
              </button>
            </div>
          </div>
        )}

        {/* Status buttons */}
        {!task.done && (
          <div style={{ display: 'flex', gap: 4, marginTop: 6 }}>
            <button onClick={() => onStatus(task.id, 'a_faire')}
              style={{
                padding: '2px 8px', borderRadius: 4, border: 'none', cursor: 'pointer',
                fontSize: 10, fontWeight: 600,
                background: task.status === 'a_faire' ? '#fef2f2' : 'transparent',
                color: task.status === 'a_faire' ? '#dc2626' : '#9ca3af',
              }}>
              📋 À faire
            </button>
            <button onClick={() => onStatus(task.id, 'en_cours')}
              style={{
                padding: '2px 8px', borderRadius: 4, border: 'none', cursor: 'pointer',
                fontSize: 10, fontWeight: 600,
                background: task.status === 'en_cours' ? '#fffbeb' : 'transparent',
                color: task.status === 'en_cours' ? '#d97706' : '#9ca3af',
              }}>
              🔄 En cours
            </button>
            {(task.prospect_id || task.related_company) && (
              <span style={{ marginLeft: 'auto' }}>
                <button onClick={async () => {
                  const btn = document.getElementById(`tsync-${task.id}`)
                  if (btn) { btn.textContent = '⏳'; btn.disabled = true }
                  try {
                    const r = await api.post(`/weekly-tasks/${task.id}/sync-to-crm`)
                    if (btn) {
                      btn.textContent = '✅ CRM'
                      btn.style.background = '#059669'
                      setTimeout(() => {
                        btn.textContent = '🔄 CRM'
                        btn.style.background = '#2563eb'
                        btn.disabled = false
                      }, 2000)
                    }
                  } catch {
                    if (btn) { btn.textContent = '❌'; btn.disabled = false }
                  }
                }}
                  id={`tsync-${task.id}`}
                  style={{
                    padding: '2px 8px', borderRadius: 4, border: 'none', cursor: 'pointer',
                    fontSize: 10, fontWeight: 600, background: '#2563eb', color: '#fff',
                  }}>
                  🔄 CRM
                </button>
              </span>
            )}
          </div>
        )}
      </div>

      {/* Delete */}
      <button onClick={() => onDelete(task.id)}
        style={{
          background: 'none', border: 'none', cursor: 'pointer',
          color: '#d1d5db', fontSize: 14, padding: '2px 4px', opacity: 0.4,
          transition: 'opacity 0.12s',
        }}
        onMouseEnter={e => e.currentTarget.style.opacity = '1'}
        onMouseLeave={e => e.currentTarget.style.opacity = '0.4'}>
        🗑
      </button>
    </div>
  )
}
