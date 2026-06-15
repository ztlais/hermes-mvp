import { useEffect, useState } from 'react'
import api from '../api/client'

const CATEGORIES = ['vocabulary','concept','regulation','market','finance','technical','other']

export default function Learning() {
  const [data, setData] = useState([])
  const [quiz, setQuiz] = useState(null)
  const [quizAnswers, setQuizAnswers] = useState({})
  const [quizDone, setQuizDone] = useState(false)
  const [search, setSearch] = useState('')
  const [category, setCategory] = useState('')
  const [showAdd, setShowAdd] = useState(false)
  const [form, setForm] = useState({ term: '', definition: '', category: 'vocabulary', example: '' })

  const load = () => {
    const params = {}
    if (search) params.search = search
    if (category) params.category = category
    api.get('/learning/', { params }).then(r => setData(r.data))
  }

  useEffect(() => { load() }, [search, category])

  const handleAdd = async () => {
    await api.post('/learning/', form)
    setForm({ term: '', definition: '', category: 'vocabulary', example: '' })
    setShowAdd(false)
    load()
  }

  const handleDelete = async (id) => {
    if (!confirm('Supprimer ?')) return
    await api.delete(`/learning/${id}`)
    load()
  }

  const startQuiz = async () => {
    const r = await api.get('/learning/quiz', { params: { count: 5 } })
    setQuiz(r.data)
    setQuizAnswers({})
    setQuizDone(false)
  }

  const score = quiz ? quiz.filter(q => quizAnswers[q.id] === q.correct_definition).length : 0

  const input = { width: '100%', padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 14 }
  const label = { display: 'block', fontSize: 12, fontWeight: 600, color: '#374151', marginBottom: 4, marginTop: 10 }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
        <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1f2937' }}>📚 Learning</h1>
        <div style={{ display: 'flex', gap: 10 }}>
          <button onClick={startQuiz} style={{ padding: '8px 16px', background: '#7c3aed', color: '#fff', border: 'none', borderRadius: 6, fontWeight: 600, cursor: 'pointer' }}>
            🧠 Quiz
          </button>
          <button onClick={() => setShowAdd(!showAdd)} style={{ padding: '8px 16px', background: '#2563eb', color: '#fff', border: 'none', borderRadius: 6, fontWeight: 600, cursor: 'pointer' }}>
            + Ajouter
          </button>
        </div>
      </div>

      {showAdd && (
        <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8, padding: 20, marginBottom: 20 }}>
          <h3 style={{ fontWeight: 600, marginBottom: 12 }}>Nouveau terme</h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            <div><label style={label}>Terme *</label><input style={input} value={form.term} onChange={e => setForm(f => ({ ...f, term: e.target.value }))} /></div>
            <div><label style={label}>Catégorie</label>
              <select style={input} value={form.category} onChange={e => setForm(f => ({ ...f, category: e.target.value }))}>
                {CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
              </select>
            </div>
          </div>
          <label style={label}>Définition *</label>
          <textarea style={{ ...input, height: 80, resize: 'vertical' }} value={form.definition} onChange={e => setForm(f => ({ ...f, definition: e.target.value }))} />
          <label style={label}>Exemple</label>
          <input style={input} value={form.example} onChange={e => setForm(f => ({ ...f, example: e.target.value }))} />
          <div style={{ display: 'flex', gap: 10, marginTop: 12, justifyContent: 'flex-end' }}>
            <button onClick={() => setShowAdd(false)} style={{ padding: '8px 16px', borderRadius: 6, border: '1px solid #d1d5db', background: '#fff', cursor: 'pointer' }}>Annuler</button>
            <button onClick={handleAdd} style={{ padding: '8px 16px', borderRadius: 6, border: 'none', background: '#2563eb', color: '#fff', cursor: 'pointer', fontWeight: 600 }}>Sauvegarder</button>
          </div>
        </div>
      )}

      {quiz && (
        <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8, padding: 24, marginBottom: 24 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 16 }}>
            <h3 style={{ fontWeight: 700, fontSize: 16 }}>🧠 Quiz — {quiz.length} questions</h3>
            <button onClick={() => setQuiz(null)} style={{ padding: '4px 10px', border: '1px solid #d1d5db', borderRadius: 6, background: '#fff', cursor: 'pointer', fontSize: 12 }}>Fermer</button>
          </div>
          {quiz.map((q, i) => (
            <div key={q.id} style={{ marginBottom: 20, paddingBottom: 20, borderBottom: i < quiz.length - 1 ? '1px solid #f3f4f6' : 'none' }}>
              <div style={{ fontWeight: 600, marginBottom: 10, color: '#1f2937' }}>Q{i + 1}. Que signifie "{q.term}" ?</div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                {q.choices.map((c, j) => {
                  const selected = quizAnswers[q.id] === c
                  const correct = quizDone && c === q.correct_definition
                  const wrong = quizDone && selected && c !== q.correct_definition
                  return (
                    <button key={j} onClick={() => !quizDone && setQuizAnswers(a => ({ ...a, [q.id]: c }))}
                      style={{
                        padding: '10px 14px', borderRadius: 6, textAlign: 'left', cursor: quizDone ? 'default' : 'pointer',
                        border: `2px solid ${correct ? '#16a34a' : wrong ? '#dc2626' : selected ? '#2563eb' : '#e5e7eb'}`,
                        background: correct ? '#d1fae5' : wrong ? '#fee2e2' : selected ? '#eff6ff' : '#fff',
                        color: '#1f2937', fontSize: 13,
                      }}>
                      {c}
                    </button>
                  )
                })}
              </div>
            </div>
          ))}
          {!quizDone ? (
            <button onClick={() => setQuizDone(true)} disabled={Object.keys(quizAnswers).length < quiz.length}
              style={{ padding: '10px 20px', background: '#2563eb', color: '#fff', border: 'none', borderRadius: 6, fontWeight: 600, cursor: 'pointer', opacity: Object.keys(quizAnswers).length < quiz.length ? 0.5 : 1 }}>
              Valider les réponses
            </button>
          ) : (
            <div style={{ padding: 16, background: score === quiz.length ? '#d1fae5' : '#fef3c7', borderRadius: 8, fontWeight: 600, fontSize: 16, textAlign: 'center' }}>
              {score}/{quiz.length} bonnes réponses {score === quiz.length ? '🎉' : '💪'}
            </div>
          )}
        </div>
      )}

      <div style={{ display: 'flex', gap: 10, marginBottom: 16 }}>
        <input placeholder="🔍 Rechercher..." value={search} onChange={e => setSearch(e.target.value)}
          style={{ flex: 1, padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 14 }} />
        <select value={category} onChange={e => setCategory(e.target.value)}
          style={{ padding: '8px 12px', border: '1px solid #d1d5db', borderRadius: 6, fontSize: 14 }}>
          <option value="">Toutes catégories</option>
          {CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
        </select>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 12 }}>
        {data.map(item => (
          <div key={item.id} style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 8, padding: 16 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
              <span style={{ fontWeight: 700, color: '#1f2937' }}>{item.term}</span>
              <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                <span style={{ padding: '2px 8px', background: '#ede9fe', color: '#5b21b6', borderRadius: 8, fontSize: 10, fontWeight: 600 }}>{item.category}</span>
                <button onClick={() => handleDelete(item.id)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#dc2626', fontSize: 14 }}>✕</button>
              </div>
            </div>
            <div style={{ fontSize: 13, color: '#4b5563', lineHeight: 1.5 }}>{item.definition}</div>
            {item.example && <div style={{ fontSize: 12, color: '#9ca3af', marginTop: 8, fontStyle: 'italic' }}>Ex: {item.example}</div>}
          </div>
        ))}
      </div>
    </div>
  )
}
