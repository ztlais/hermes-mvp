import { useState, useEffect } from 'react'
import axios from 'axios'
import { useLang } from '../context/LanguageContext'

export default function Login({ onLogin }) {
  const { lang, toggleLang } = useLang()
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [isMobile, setIsMobile] = useState(window.innerWidth < 768)

  useEffect(() => {
    const onResize = () => setIsMobile(window.innerWidth < 768)
    window.addEventListener('resize', onResize)
    return () => window.removeEventListener('resize', onResize)
  }, [])

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
      setError(lang === 'fr' ? 'Identifiants incorrects' : 'Invalid credentials')
    } finally {
      setLoading(false)
    }
  }

  // Mobile layout
  if (isMobile) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
        {/* Header band */}
        <div style={{
          background: 'linear-gradient(160deg, #064e3b, #047857)',
          padding: '32px 24px', textAlign: 'center',
        }}>
          <div style={{ fontSize: 14, fontWeight: 700, letterSpacing: 1.5, color: '#6ee7b7', textTransform: 'uppercase', marginBottom: 4 }}>
            EIR
          </div>
          <div style={{ fontSize: 22, fontWeight: 800, color: '#fff' }}>
            French <span style={{ color: '#34d399' }}>market</span>
          </div>
        </div>

        {/* Toggle */}
        <div style={{ display: 'flex', justifyContent: 'flex-end', padding: '12px 16px' }}>
          <div style={{ display: 'inline-flex', background: '#f3f4f6', borderRadius: 8, padding: 2 }}>
            <button onClick={() => lang !== 'fr' && toggleLang()}
              style={{
                padding: '5px 12px', borderRadius: 6, border: 'none',
                background: lang === 'fr' ? '#059669' : 'transparent',
                fontSize: 12, fontWeight: 700, color: lang === 'fr' ? '#fff' : '#6b7280',
              }}><span className="flag-emoji">🇫🇷 </span>FR</button>
            <button onClick={() => lang !== 'en' && toggleLang()}
              style={{
                padding: '5px 12px', borderRadius: 6, border: 'none',
                background: lang === 'en' ? '#059669' : 'transparent',
                fontSize: 12, fontWeight: 700, color: lang === 'en' ? '#fff' : '#6b7280',
              }}><span className="flag-emoji">🇬🇧 </span>EN</button>
          </div>
        </div>

        {/* Form */}
        <div style={{ flex: 1, padding: '0 24px 32px', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
          <h2 style={{ fontSize: 22, fontWeight: 800, color: '#1f2937', marginBottom: 4, textAlign: 'center' }}>
            {lang === 'fr' ? 'Connexion' : 'Login'}
          </h2>
          <p style={{ fontSize: 13, color: '#9ca3af', marginBottom: 28, textAlign: 'center' }}>
            {lang === 'fr' ? "Accès réservé à l'équipe EIR" : 'EIR team access only'}
          </p>

          <form onSubmit={handleSubmit}>
            <div style={{ marginBottom: 14 }}>
              <label style={{ display: 'block', fontSize: 12, fontWeight: 700, color: '#374151', marginBottom: 5 }}>
                {lang === 'fr' ? 'Identifiant' : 'Username'}
              </label>
              <input type="text" value={username} onChange={e => setUsername(e.target.value)} autoFocus
                style={{ width: '100%', padding: '12px 14px', border: '1.5px solid #e5e7eb', borderRadius: 8, fontSize: 15, outline: 'none', boxSizing: 'border-box' }}
                onFocus={e => e.target.style.borderColor = '#059669'}
                onBlur={e => e.target.style.borderColor = '#e5e7eb'}
                placeholder="ex: zein" />
            </div>
            <div style={{ marginBottom: 22 }}>
              <label style={{ display: 'block', fontSize: 12, fontWeight: 700, color: '#374151', marginBottom: 5 }}>
                {lang === 'fr' ? 'Mot de passe' : 'Password'}
              </label>
              <input type="password" value={password} onChange={e => setPassword(e.target.value)}
                style={{ width: '100%', padding: '12px 14px', border: '1.5px solid #e5e7eb', borderRadius: 8, fontSize: 15, outline: 'none', boxSizing: 'border-box' }}
                onFocus={e => e.target.style.borderColor = '#059669'}
                onBlur={e => e.target.style.borderColor = '#e5e7eb'} />
            </div>

            {error && (
              <div style={{ background: '#fef2f2', border: '1px solid #fecaca', borderRadius: 8, padding: '10px 14px', fontSize: 13, color: '#dc2626', marginBottom: 14, textAlign: 'center' }}>
                {error}
              </div>
            )}

            <button type="submit" disabled={loading || !username || !password}
              style={{
                width: '100%', padding: '13px', borderRadius: 8, border: 'none',
                background: loading || !username || !password ? '#a7f3d0' : '#059669',
                color: '#fff', fontWeight: 700, fontSize: 15,
                cursor: loading || !username || !password ? 'not-allowed' : 'pointer',
              }}>
              {loading ? (lang === 'fr' ? 'Connexion...' : 'Logging in...') : (lang === 'fr' ? 'Se connecter →' : 'Sign in →')}
            </button>
          </form>
        </div>
      </div>
    )
  }

  // Desktop layout
  return (
    <div style={{ minHeight: '100vh', display: 'flex' }}>
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'space-between',
        padding: '48px 52px',
        backgroundImage: 'url(/eir-cover.jpg)',
        backgroundSize: 'cover', backgroundPosition: 'center',
        position: 'relative', overflow: 'hidden',
      }}>
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(160deg, rgba(10,40,20,0.82) 0%, rgba(15,70,35,0.70) 60%, rgba(10,40,20,0.85) 100%)' }} />
        <div style={{ position: 'relative', zIndex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 8 }}>
            <div style={{ width: 40, height: 40, borderRadius: 10, background: 'rgba(255,255,255,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20 }}>⚡</div>
            <div>
              <div style={{ color: '#fff', fontWeight: 800, fontSize: 20, letterSpacing: 0.5 }}><span className="flag-emoji">🇬🇧 </span>ENECHANGE</div>
              <div style={{ color: 'rgba(255,255,255,0.6)', fontSize: 11, fontWeight: 600, letterSpacing: 1.5, textTransform: 'uppercase' }}>EIR Program</div>
            </div>
          </div>
        </div>
        <div style={{ position: 'relative', zIndex: 1 }}>
          <span style={{ padding: '8px 18px', borderRadius: 24, background: 'rgba(255,255,255,0.15)', border: '1px solid rgba(255,255,255,0.3)', color: '#fff', fontSize: 15, fontWeight: 700 }}>
            🇫🇷 French Market
          </span>
        </div>
      </div>

      <div style={{ width: 420, display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#fff', padding: '48px 40px', position: 'relative' }}>
        <div style={{ position: 'absolute', top: 20, right: 24 }}>
          <div style={{ display: 'inline-flex', background: '#f3f4f6', borderRadius: 8, padding: 2 }}>
            <button onClick={() => lang !== 'fr' && toggleLang()}
              style={{ padding: '5px 12px', borderRadius: 6, border: 'none', cursor: 'pointer', background: lang === 'fr' ? '#059669' : 'transparent', fontSize: 12, fontWeight: 700, color: lang === 'fr' ? '#fff' : '#6b7280', transition: 'all 0.15s' }}><span className="flag-emoji">🇫🇷 </span>FR</button>
            <button onClick={() => lang !== 'en' && toggleLang()}
              style={{ padding: '5px 12px', borderRadius: 6, border: 'none', cursor: 'pointer', background: lang === 'en' ? '#059669' : 'transparent', fontSize: 12, fontWeight: 700, color: lang === 'en' ? '#fff' : '#6b7280', transition: 'all 0.15s' }}><span className="flag-emoji">🇬🇧 </span>EN</button>
          </div>
        </div>
        <div style={{ width: '100%', maxWidth: 340 }}>
          <h2 style={{ fontSize: 24, fontWeight: 800, color: '#1f2937', marginBottom: 6 }}>{lang === 'fr' ? 'Connexion' : 'Login'}</h2>
          <p style={{ fontSize: 13, color: '#9ca3af', marginBottom: 32 }}>{lang === 'fr' ? "Accès réservé à l'équipe EIR" : 'EIR team access only'}</p>
          <form onSubmit={handleSubmit}>
            <div style={{ marginBottom: 16 }}>
              <label style={{ display: 'block', fontSize: 12, fontWeight: 700, color: '#374151', marginBottom: 6 }}>{lang === 'fr' ? 'Identifiant' : 'Username'}</label>
              <input type="text" value={username} onChange={e => setUsername(e.target.value)} autoFocus
                style={{ width: '100%', padding: '11px 14px', border: '1.5px solid #e5e7eb', borderRadius: 8, fontSize: 14, boxSizing: 'border-box', outline: 'none', transition: 'border-color 0.2s' }}
                onFocus={e => e.target.style.borderColor = '#059669'}
                onBlur={e => e.target.style.borderColor = '#e5e7eb'}
                placeholder="ex: zein" />
            </div>
            <div style={{ marginBottom: 24 }}>
              <label style={{ display: 'block', fontSize: 12, fontWeight: 700, color: '#374151', marginBottom: 6 }}>{lang === 'fr' ? 'Mot de passe' : 'Password'}</label>
              <input type="password" value={password} onChange={e => setPassword(e.target.value)}
                style={{ width: '100%', padding: '11px 14px', border: '1.5px solid #e5e7eb', borderRadius: 8, fontSize: 14, boxSizing: 'border-box', outline: 'none', transition: 'border-color 0.2s' }}
                onFocus={e => e.target.style.borderColor = '#059669'}
                onBlur={e => e.target.style.borderColor = '#e5e7eb'} />
            </div>
            {error && (
              <div style={{ background: '#fef2f2', border: '1px solid #fecaca', borderRadius: 8, padding: '10px 14px', fontSize: 13, color: '#dc2626', marginBottom: 16, textAlign: 'center' }}>{error}</div>
            )}
            <button type="submit" disabled={loading || !username || !password}
              style={{
                width: '100%', padding: '12px', borderRadius: 8, border: 'none',
                background: loading || !username || !password ? '#a7f3d0' : '#059669',
                color: '#fff', fontWeight: 700, fontSize: 15,
                cursor: loading || !username || !password ? 'not-allowed' : 'pointer',
              }}>
              {loading ? (lang === 'fr' ? 'Connexion...' : 'Logging in...') : (lang === 'fr' ? 'Se connecter →' : 'Sign in →')}
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
