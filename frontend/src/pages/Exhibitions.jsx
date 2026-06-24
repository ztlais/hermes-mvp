import { useState, useEffect, useCallback } from 'react'
import { useLang } from '../context/LanguageContext'
import api from '../api/client'

const STATUS_MAP = {
  to_contact: { label: { fr: 'À contacter', en: 'To contact' }, color: '#6b7280' },
  contacted: { label: { fr: 'Contact pris', en: 'Contacted' }, color: '#d97706' },
  meeting_scheduled: { label: { fr: 'RDV booké', en: 'Meeting booked' }, color: '#2563eb' },
  meeting_done: { label: { fr: 'Déjà vu', en: 'Met' }, color: '#059669' },
  not_interested: { label: { fr: 'Pas intéressé', en: 'Not interested' }, color: '#dc2626' },
}

export default function Exhibitions() {
  const { t, lang } = useLang()
  const [exhibitions, setExhibitions] = useState([])
  const [selectedExh, setSelectedExh] = useState(null)
  const [companies, setCompanies] = useState([])
  const [loading, setLoading] = useState(true)
  const [showNewExh, setShowNewExh] = useState(false)
  const [newExhName, setNewExhName] = useState('')

  const loadExhibitions = useCallback(async () => {
    try {
      const { data } = await api.get('/exhibitions')
      setExhibitions(data)
      if (data.length > 0 && !selectedExh) {
        setSelectedExh(data[0].id)
      }
    } catch (e) {
      console.error(e)
    } finally {
      setLoading(false)
    }
  }, [selectedExh])

  const loadCompanies = useCallback(async (exhId) => {
    if (!exhId) return
    try {
      const { data } = await api.get(`/exhibitions/${exhId}/companies`)
      setCompanies(data)
    } catch (e) {
      console.error(e)
    }
  }, [])

  useEffect(() => { loadExhibitions() }, [])
  useEffect(() => { loadCompanies(selectedExh) }, [selectedExh])

  const createExhibition = async () => {
    if (!newExhName.trim()) return
    await api.post('/exhibitions', { name: newExhName })
    setNewExhName('')
    setShowNewExh(false)
    loadExhibitions()
  }

  const updateCompanyStatus = async (coId, newStatus) => {
    await api.put(`/exhibitions/companies/${coId}`, { status: newStatus })
    loadCompanies(selectedExh)
  }

  const [editingNotesId, setEditingNotesId] = useState(null)
  const [draftNotes, setDraftNotes] = useState('')

  const notesField = lang === 'fr' ? 'notes_fr' : 'notes_en'

  const startEditNotes = (co) => {
    setEditingNotesId(co.id)
    setDraftNotes(co[notesField] || '')
  }

  const cancelEditNotes = () => {
    setEditingNotesId(null)
    setDraftNotes('')
  }

  const saveNotes = async (coId) => {
    await api.put(`/exhibitions/companies/${coId}`, { [notesField]: draftNotes })
    setEditingNotesId(null)
    loadCompanies(selectedExh)
  }

  const statusClass = (s) => STATUS_MAP[s] || STATUS_MAP.to_contact

  if (loading) return <div style={{ padding: 40, color: '#6b7280' }}>{t('common.loading') || 'Loading...'}</div>

  return (
    <div>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
        <div>
          <h2 style={{ margin: 0, fontSize: 22, fontWeight: 700, color: '#1f2937' }}>🗺️ {lang === 'fr' ? 'Expositions' : 'Exhibitions'}</h2>
          <p style={{ margin: '4px 0 0', color: '#6b7280', fontSize: 14 }}>
            {lang === 'fr' ? 'Suivi des salons et entreprises rencontrées' : 'Track exhibitions and companies met'}
          </p>
        </div>
        <button onClick={() => setShowNewExh(true)}
          style={{ background: '#059669', color: '#fff', border: 'none', padding: '10px 20px', borderRadius: 8, fontWeight: 600, cursor: 'pointer' }}>
          + {lang === 'fr' ? 'Nouvelle exposition' : 'New exhibition'}
        </button>
      </div>

      {/* New exhibition modal */}
      {showNewExh && (
        <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 12, padding: 20, marginBottom: 20 }}>
          <input value={newExhName} onChange={e => setNewExhName(e.target.value)}
            placeholder={lang === 'fr' ? 'Nom (ex: Intersolar 2027)' : 'Name (e.g. Intersolar 2027)'}
            style={{ width: '100%', padding: '10px 14px', borderRadius: 8, border: '1px solid #d1d5db', fontSize: 14, marginBottom: 12 }} />
          <div style={{ display: 'flex', gap: 8 }}>
            <button onClick={createExhibition}
              style={{ background: '#059669', color: '#fff', border: 'none', padding: '8px 20px', borderRadius: 8, fontWeight: 600, cursor: 'pointer' }}>
              {lang === 'fr' ? 'Créer' : 'Create'}
            </button>
            <button onClick={() => setShowNewExh(false)}
              style={{ background: '#e5e7eb', color: '#374151', border: 'none', padding: '8px 20px', borderRadius: 8, cursor: 'pointer' }}>
              {lang === 'fr' ? 'Annuler' : 'Cancel'}
            </button>
          </div>
        </div>
      )}

      {/* Exhibition selector */}
      {exhibitions.length > 0 && (
        <div style={{ display: 'flex', gap: 12, marginBottom: 20, flexWrap: 'wrap' }}>
          {exhibitions.map(exh => (
            <button key={exh.id} onClick={() => setSelectedExh(exh.id)}
              style={{
                padding: '10px 18px', borderRadius: 10, border: 'none', cursor: 'pointer',
                background: selectedExh === exh.id ? '#059669' : '#f3f4f6',
                color: selectedExh === exh.id ? '#fff' : '#374151',
                fontWeight: selectedExh === exh.id ? 600 : 400, fontSize: 14,
                display: 'flex', alignItems: 'center', gap: 8,
              }}>
              {exh.name}
              <span style={{
                background: selectedExh === exh.id ? '#fff' : '#e5e7eb',
                color: selectedExh === exh.id ? '#059669' : '#6b7280',
                borderRadius: 12, padding: '1px 8px', fontSize: 11, fontWeight: 700,
              }}>{exh.company_count}</span>
            </button>
          ))}
        </div>
      )}

      {/* Companies */}
      {companies.length === 0 ? (
        <div style={{ textAlign: 'center', padding: 60, color: '#9ca3af' }}>
          {lang === 'fr' ? 'Aucune entreprise ajoutée' : 'No companies added yet'}
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {companies.map(co => {
            const st = statusClass(co.status)
            return (
              <div key={co.id} style={{
                background: '#fff', borderRadius: 12, padding: '16px 20px',
                border: '1px solid #e5e7eb', borderLeft: `4px solid ${st.color}`,
              }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
                  <div>
                    <strong style={{ fontSize: 16, color: '#1f2937' }}>{co.name}</strong>
                    {co.type && <span style={{ color: '#6b7280', fontSize: 13, marginLeft: 8 }}>({co.type})</span>}
                    {co.country && <span style={{ color: '#9ca3af', fontSize: 12, marginLeft: 8 }}>{co.country}</span>}
                  </div>
                  <span style={{
                    background: st.color + '18', color: st.color,
                    padding: '3px 10px', borderRadius: 12, fontSize: 11, fontWeight: 600,
                  }}>
                    {st.label[lang]}
                  </span>
                </div>

                {co.stand && <div style={{ fontSize: 13, color: '#6b7280', marginBottom: 4 }}>📍 {co.stand}</div>}
                {co.contact_name && <div style={{ fontSize: 13, color: '#6b7280', marginBottom: 4 }}>👤 {co.contact_name}</div>}
                {co.contact_email && <div style={{ fontSize: 13, color: '#6b7280', marginBottom: 4 }}>📧 {co.contact_email}</div>}

                {editingNotesId === co.id ? (
                  <div style={{ marginTop: 8 }}>
                    <textarea
                      value={draftNotes}
                      onChange={e => setDraftNotes(e.target.value)}
                      rows={6}
                      autoFocus
                      style={{
                        width: '100%', borderRadius: 8, border: '1px solid #d1d5db',
                        padding: '10px 14px', fontSize: 13, color: '#374151',
                        lineHeight: 1.5, fontFamily: 'inherit', resize: 'vertical',
                      }}
                    />
                    <div style={{ display: 'flex', gap: 6, marginTop: 6 }}>
                      <button onClick={() => saveNotes(co.id)}
                        style={{ background: '#059669', color: '#fff', border: 'none', padding: '4px 14px', borderRadius: 6, fontSize: 12, fontWeight: 600, cursor: 'pointer' }}>
                        {lang === 'fr' ? 'Enregistrer' : 'Save'}
                      </button>
                      <button onClick={cancelEditNotes}
                        style={{ background: '#e5e7eb', color: '#374151', border: 'none', padding: '4px 14px', borderRadius: 6, fontSize: 12, cursor: 'pointer' }}>
                        {lang === 'fr' ? 'Annuler' : 'Cancel'}
                      </button>
                    </div>
                  </div>
                ) : (
                  <div onClick={() => startEditNotes(co)} title={lang === 'fr' ? 'Cliquer pour modifier' : 'Click to edit'}
                    style={{
                      background: '#f9fafb', borderRadius: 8, padding: '10px 14px', marginTop: 8,
                      fontSize: 13, color: co.notes ? '#374151' : '#9ca3af', whiteSpace: 'pre-wrap', lineHeight: 1.5,
                      cursor: 'pointer', border: '1px dashed transparent',
                    }}
                    onMouseEnter={e => e.currentTarget.style.border = '1px dashed #d1d5db'}
                    onMouseLeave={e => e.currentTarget.style.border = '1px dashed transparent'}
                  >
                    {co[notesField] || (lang === 'fr' ? '+ Ajouter une note...' : '+ Add a note...')}
                  </div>
                )}

                {/* Status actions */}
                <div style={{ display: 'flex', gap: 6, marginTop: 10, flexWrap: 'wrap' }}>
                  {Object.entries(STATUS_MAP).map(([key, val]) => (
                    <button key={key} onClick={() => updateCompanyStatus(co.id, key)}
                      style={{
                        padding: '4px 10px', borderRadius: 6, border: '1px solid #e5e7eb',
                        background: co.status === key ? val.color + '20' : '#fff',
                        color: co.status === key ? val.color : '#6b7280',
                        fontWeight: co.status === key ? 600 : 400,
                        fontSize: 11, cursor: 'pointer',
                      }}>
                      {val.label[lang]}
                    </button>
                  ))}
                </div>
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}
