import { useState } from 'react'
import axios from 'axios'

export default function Login({ onLogin }) {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const res = await axios.post('/api/auth/login', { username, password })
      localStorage.setItem('hermes_token', res.data.token)
      localStorage.setItem('hermes_user', JSON.stringify({
        username: res.data.username,
        full_name: res.data.full_name,
        role: res.data.role,
      }))
      onLogin(res.data)
    } catch {
      setError('Identifiants incorrects')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{ minHeight: '100vh', display: 'flex' }}>

      {/* Left panel */}
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
        padding: '48px 52px',
        backgroundImage: 'url(/eir-cover.jpg)',
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        position: 'relative', overflow: 'hidden',
      }}>
        {/* Dark overlay */}
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(160deg, rgba(10,40,20,0.82) 0%, rgba(15,70,35,0.70) 60%, rgba(10,40,20,0.85) 100%)' }} />

        {/* Top: logo */}
        <div style={{ position: 'relative', zIndex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 8 }}>
            <div style={{
              width: 40, height: 40, borderRadius: 10,
              background: 'rgba(255,255,255,0.15)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 20,
            }}>⚡</div>
            <div>
              <div style={{ color: '#fff', fontWeight: 800, fontSize: 20, letterSpacing: 0.5 }}>ENECHANGE</div>
              <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: 11, fontWeight: 600, letterSpacing: 1.5, textTransform: 'uppercase' }}>EIR Program</div>
            </div>
          </div>
        </div>

        {/* Bottom: French Market badge */}
        <div style={{ position: 'relative', zIndex: 1 }}>
          <span style={{
            padding: '8px 18px', borderRadius: 24,
            background: 'rgba(255,255,255,0.15)',
            border: '1px solid rgba(255,255,255,0.3)',
            color: '#fff', fontSize: 15, fontWeight: 700, letterSpacing: 0.5,
          }}>
            🇫🇷 French Market
          </span>
        </div>
      </div>

      {/* Right panel — login form */}
      <div style={{
        width: 420, display: 'flex', alignItems: 'center', justifyContent: 'center',
        background: '#fff', padding: '48px 40px',
      }}>
        <div style={{ width: '100%', maxWidth: 340 }}>
          <h2 style={{ fontSize: 24, fontWeight: 800, color: '#1f2937', marginBottom: 6 }}>Connexion</h2>
          <p style={{ fontSize: 13, color: '#9ca3af', marginBottom: 32 }}>Accès réservé à l'équipe EIR</p>

          <form onSubmit={handleSubmit}>
            <div style={{ marginBottom: 16 }}>
              <label style={{ display: 'block', fontSize: 12, fontWeight: 700, color: '#374151', marginBottom: 6 }}>
                Identifiant
              </label>
              <input
                type="text"
                value={username}
                onChange={e => setUsername(e.target.value)}
                autoFocus
                style={{
                  width: '100%', padding: '11px 14px',
                  border: '1.5px solid #e5e7eb', borderRadius: 8,
                  fontSize: 14, boxSizing: 'border-box', outline: 'none',
                  transition: 'border-color 0.2s',
                }}
                onFocus={e => e.target.style.borderColor = '#16a34a'}
                onBlur={e => e.target.style.borderColor = '#e5e7eb'}
                placeholder="ex: zein"
              />
            </div>

            <div style={{ marginBottom: 24 }}>
              <label style={{ display: 'block', fontSize: 12, fontWeight: 700, color: '#374151', marginBottom: 6 }}>
                Mot de passe
              </label>
              <input
                type="password"
                value={password}
                onChange={e => setPassword(e.target.value)}
                style={{
                  width: '100%', padding: '11px 14px',
                  border: '1.5px solid #e5e7eb', borderRadius: 8,
                  fontSize: 14, boxSizing: 'border-box', outline: 'none',
                  transition: 'border-color 0.2s',
                }}
                onFocus={e => e.target.style.borderColor = '#16a34a'}
                onBlur={e => e.target.style.borderColor = '#e5e7eb'}
              />
            </div>

            {error && (
              <div style={{
                background: '#fef2f2', border: '1px solid #fecaca', borderRadius: 8,
                padding: '10px 14px', fontSize: 13, color: '#dc2626', marginBottom: 16, textAlign: 'center',
              }}>
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={loading || !username || !password}
              style={{
                width: '100%', padding: '12px', borderRadius: 8, border: 'none',
                background: loading || !username || !password ? '#86efac' : '#16a34a',
                color: '#fff', fontWeight: 700, fontSize: 15,
                cursor: loading || !username || !password ? 'not-allowed' : 'pointer',
                transition: 'background 0.2s',
              }}
            >
              {loading ? 'Connexion...' : 'Se connecter →'}
            </button>
          </form>

          <div style={{ marginTop: 40, padding: '16px', background: '#f9fafb', borderRadius: 8, fontSize: 12, color: '#9ca3af', textAlign: 'center' }}>
            Accès sécurisé · Hermes MVP v1
          </div>
        </div>
      </div>
    </div>
  )
}
