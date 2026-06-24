import { NavLink } from 'react-router-dom'
import { useLang } from '../context/LanguageContext'

const NAV_MAIN = [
  { to: '/',              key: 'nav.overview' },
  { to: '/weekly-prep',   key: 'nav.weeklyPrep' },
  { to: '/projects',      key: 'nav.projects' },
  { to: '/opportunities', key: 'nav.opportunities' },
  { to: '/prospects',     key: 'nav.prospects' },
  { to: '/investors',     key: 'nav.investors' },
  { to: '/scouting',      key: 'nav.scouting' },
  { to: '/matching',      key: 'nav.matching' },
  { to: '/simulateur',    key: 'nav.simulateur' },
  { to: '/exhibitions',   key: 'nav.exhibitions' },
]
const NAV_SECONDARY = [
  { to: '/documents',     key: 'nav.documents' },
  { to: '/templates',     key: 'nav.templates' },
  { to: '/learning',      key: 'nav.learning' },
  { to: '/settings',      key: 'nav.settings' },
  { to: '/software',      key: 'nav.software' },
]

export default function Sidebar({ user, onLogout, onClose, isMobile }) {
  const { lang, toggleLang, t } = useLang()

  const initials = (user?.full_name || user?.username || '?')
    .split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2)

  const linkStyle = (isActive) => ({
    display: 'flex', alignItems: 'center', gap: 10,
    padding: '10px 12px', borderRadius: 8, marginBottom: 2,
    textDecoration: 'none', fontSize: 14, fontWeight: isActive ? 600 : 400,
    color: isActive ? '#f1f5f9' : '#94a3b8',
    background: isActive ? '#047857' : 'transparent',
    transition: 'all 0.15s',
  })

  return (
    <nav style={{
      width: '100%', height: '100vh', background: '#064e3b',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* Logo */}
      <div style={{ padding: '24px 20px 20px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: '0.12em', color: '#6ee7b7', textTransform: 'uppercase', marginBottom: 2 }}>
              EIR Dashboard
            </div>
            <div style={{ fontSize: 16, fontWeight: 700, color: '#f1f5f9' }}>
              French <span style={{ color: '#34d399' }}>market</span>
            </div>
          </div>
          {isMobile && (
            <button onClick={onClose} style={{ background: 'none', border: 'none', color: '#94a3b8', fontSize: 20, cursor: 'pointer' }}>
              ✕
            </button>
          )}
        </div>

        {/* Langue toggle */}
        <div style={{ display: 'inline-flex', background: '#065f46', borderRadius: 8, padding: 3, marginTop: 14 }}>
          <button onClick={() => lang !== 'fr' && toggleLang()}
            style={{
              padding: '5px 14px', borderRadius: 6, border: 'none', cursor: 'pointer',
              background: lang === 'fr' ? '#059669' : 'transparent',
              fontSize: 12, fontWeight: 700, color: lang === 'fr' ? '#fff' : '#6ee7b7',
              transition: 'all 0.15s',
            }}><span className="flag-emoji">🇫🇷 </span>FR</button>
          <button onClick={() => lang !== 'en' && toggleLang()}
            style={{
              padding: '5px 14px', borderRadius: 6, border: 'none', cursor: 'pointer',
              background: lang === 'en' ? '#059669' : 'transparent',
              fontSize: 12, fontWeight: 700, color: lang === 'en' ? '#fff' : '#6ee7b7',
              transition: 'all 0.15s',
            }}><span className="flag-emoji">🇬🇧 </span>EN</button>
        </div>
      </div>

      {/* Nav */}
      <div style={{ flex: 1, padding: '0 12px', overflowY: 'auto', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
        <div>
          {NAV_MAIN.map(({ to, key }) => (
            <NavLink key={to} to={to} end={to === '/'}
              onClick={onClose}
              style={({ isActive }) => linkStyle(isActive)}>
              <span>{t(key)}</span>
            </NavLink>
          ))}
        </div>
        <div style={{ borderTop: '1px solid #065f46', paddingTop: 10, marginBottom: 10 }}>
          <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: '0.1em', color: '#6ee7b7', textTransform: 'uppercase', padding: '0 12px', marginBottom: 6, opacity: 0.4 }}>
            {lang === 'fr' ? 'Outils' : 'Tools'}
          </div>
          {NAV_SECONDARY
            // tous les utilisateurs voient tous les liens
            .map(({ to, key }) => (
            <NavLink key={to} to={to}
              onClick={onClose}
              style={({ isActive }) => linkStyle(isActive)}>
              <span>{t(key)}</span>
            </NavLink>
          ))}
        </div>
      </div>

      {/* User */}
      <div style={{ padding: '12px', borderTop: '1px solid #065f46' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 12px', borderRadius: 8, background: '#065f46' }}>
          <div style={{
            width: 32, height: 32, borderRadius: '50%', background: '#059669',
            color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 12, fontWeight: 700, flexShrink: 0,
          }}>
            {initials}
          </div>
          <div style={{ flex: 1, overflow: 'hidden' }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: '#f1f5f9', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
              {user?.full_name || user?.username}
            </div>
            <div style={{ fontSize: 11, color: '#6ee7b7' }}>{user?.role}</div>
          </div>
          <button onClick={onLogout} style={{
            background: 'none', border: 'none', color: '#6ee7b7', cursor: 'pointer',
            fontSize: 16, padding: '2px 4px', borderRadius: 4, flexShrink: 0, opacity: 0.6,
          }}>
            ⏻
          </button>
        </div>
      </div>
    </nav>
  )
}
