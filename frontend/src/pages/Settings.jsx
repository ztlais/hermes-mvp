import { useState } from 'react'
import api from '../api/client'
import { useLang } from '../context/LanguageContext'

export default function Settings({ user }) {
  const { t } = useLang()
  const [form, setForm] = useState({ current: '', new: '', confirm: '' })
  const [msg, setMsg] = useState(null)
  const [saving, setSaving] = useState(false)
  const [pushState, setPushState] = useState({ loading: false, msg: null })

  const handleGitPush = async () => {
    setPushState({ loading: true, msg: null })
    try {
      const res = await api.post('/git/push')
      setPushState({ loading: false, msg: { type: 'success', text: res.data.message } })
    } catch (e) {
      setPushState({ loading: false, msg: { type: 'error', text: e.response?.data?.detail || 'Erreur push GitHub' } })
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setMsg(null)

    if (form.new !== form.confirm) {
      setMsg({ type: 'error', text: 'Les mots de passe ne correspondent pas' })
      return
    }
    if (form.new.length < 6) {
      setMsg({ type: 'error', text: 'Le mot de passe doit faire au moins 6 caractères' })
      return
    }

    setSaving(true)
    try {
      await api.post('/auth/change-password', {
        current_password: form.current,
        new_password: form.new,
      })
      setMsg({ type: 'success', text: '✅ Mot de passe changé avec succès !' })
      setForm({ current: '', new: '', confirm: '' })
    } catch (e) {
      setMsg({ type: 'error', text: e.response?.data?.detail || 'Erreur lors du changement' })
    }
    setSaving(false)
  }

  const card = {
    background: '#fff',
    border: '1px solid #e5e7eb',
    borderRadius: 10,
    padding: 24,
    maxWidth: 480,
  }

  const input = {
    width: '100%',
    padding: '10px 14px',
    border: '1px solid #d1d5db',
    borderRadius: 8,
    fontSize: 14,
    fontFamily: 'inherit',
    boxSizing: 'border-box',
    outline: 'none',
    transition: 'border 0.15s',
    marginBottom: 12,
  }

  return (
    <div style={{ maxWidth: 600 }}>
      <h1 style={{ fontSize: 20, fontWeight: 700, marginBottom: 24, color: '#1f2937' }}>
        ⚙️ {t('nav.settings')}
      </h1>

      {/* User Info */}
      <div style={{ ...card, marginBottom: 16 }}>
        <h3 style={{ fontSize: 14, fontWeight: 700, color: '#374151', margin: '0 0 12px' }}>👤 Compte</h3>
        <div style={{ fontSize: 13, color: '#6b7280', lineHeight: 1.8 }}>
          <div><strong style={{ color: '#374151' }}>Nom :</strong> {user?.full_name || user?.username}</div>
          <div><strong style={{ color: '#374151' }}>Rôle :</strong> {user?.role}</div>
        </div>
      </div>

      {/* Password Change — admin only */}
      {user?.role === 'admin' && (
        <div style={card}>
        <h3 style={{ fontSize: 14, fontWeight: 700, color: '#374151', margin: '0 0 12px' }}>🔑 Mot de passe</h3>

        {msg && (
          <div style={{
            padding: '10px 14px', borderRadius: 8, marginBottom: 14, fontSize: 13,
            background: msg.type === 'success' ? '#f0fdf4' : '#fef2f2',
            color: msg.type === 'success' ? '#16a34a' : '#dc2626',
            border: msg.type === 'success' ? '1px solid #bbf7d0' : '1px solid #fecaca',
          }}>
            {msg.text}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <input type="password" placeholder="Mot de passe actuel" value={form.current}
            onChange={e => setForm({ ...form, current: e.target.value })}
            style={input}
            onFocus={e => e.target.style.borderColor = '#059669'}
            onBlur={e => e.target.style.borderColor = '#d1d5db'} />

          <input type="password" placeholder="Nouveau mot de passe" value={form.new}
            onChange={e => setForm({ ...form, new: e.target.value })}
            style={input}
            onFocus={e => e.target.style.borderColor = '#059669'}
            onBlur={e => e.target.style.borderColor = '#d1d5db'} />

          <input type="password" placeholder="Confirmer le nouveau mot de passe" value={form.confirm}
            onChange={e => setForm({ ...form, confirm: e.target.value })}
            style={input}
            onFocus={e => e.target.style.borderColor = '#059669'}
            onBlur={e => e.target.style.borderColor = '#d1d5db'} />

          <button type="submit" disabled={saving || !form.current || !form.new || !form.confirm}
            style={{
              padding: '10px 20px', borderRadius: 8, border: 'none',
              background: form.current && form.new && form.confirm ? '#059669' : '#9ca3af',
              color: '#fff', fontSize: 14, fontWeight: 600, cursor: form.current && form.new && form.confirm ? 'pointer' : 'default',
              width: '100%', marginTop: 4,
            }}>
            {saving ? '⏳ Changement en cours...' : '🔑 Changer le mot de passe'}
          </button>
        </form>
        </div>
      )}

      {/* GitHub Push — admin only */}
      {user?.role === 'admin' && (
        <div style={{ ...card, marginTop: 16 }}>
          <h3 style={{ fontSize: 14, fontWeight: 700, color: '#374151', margin: '0 0 12px' }}>🚀 Push GitHub</h3>
          <p style={{ fontSize: 13, color: '#6b7280', margin: '0 0 12px' }}>
            Met à jour le repo GitHub avec les dernières modifications du code.
          </p>
          {pushState.msg && (
            <div style={{
              padding: '10px 14px', borderRadius: 8, marginBottom: 14, fontSize: 13,
              background: pushState.msg.type === 'success' ? '#f0fdf4' : '#fef2f2',
              color: pushState.msg.type === 'success' ? '#16a34a' : '#dc2626',
              border: pushState.msg.type === 'success' ? '1px solid #bbf7d0' : '1px solid #fecaca',
            }}>
              {pushState.msg.text}
            </div>
          )}
          <button onClick={handleGitPush} disabled={pushState.loading}
            style={{
              padding: '10px 20px', borderRadius: 8, border: 'none',
              background: pushState.loading ? '#9ca3af' : '#1f2937',
              color: '#fff', fontSize: 14, fontWeight: 600,
              cursor: pushState.loading ? 'default' : 'pointer',
              width: '100%',
            }}>
            {pushState.loading ? '⏳ Push en cours...' : '🚀 Push to GitHub'}
          </button>
        </div>
      )}
  </div>
  )
}
