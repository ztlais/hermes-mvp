import { NavLink } from 'react-router-dom'

const nav = [
  { to: '/',           icon: '📊', label: "Vue d'ensemble" },
  { to: '/scouting',   icon: '🔍', label: 'Scouting' },
  { to: '/prospects',  icon: '🤝', label: 'Prospects' },
  { to: '/investors',  icon: '🏦', label: 'Investisseurs' },
  { to: '/matching',   icon: '🎯', label: 'Matching' },
  { to: '/templates',  icon: '📝', label: 'Templates' },
  { to: '/learning',   icon: '📚', label: 'Learning' },
]

const s = {
  sidebar: {
    width: 220, minHeight: '100vh', background: '#fff',
    borderRight: '1px solid #e5e7eb', padding: '24px 0', display: 'flex',
    flexDirection: 'column',
  },
  logo: {
    padding: '0 20px 24px', fontSize: 18, fontWeight: 700, color: '#1f2937',
    borderBottom: '1px solid #e5e7eb', marginBottom: 12,
  },
  link: {
    display: 'flex', alignItems: 'center', gap: 10, padding: '10px 20px',
    textDecoration: 'none', color: '#6b7280', fontSize: 14, fontWeight: 500,
    borderRadius: 0, transition: 'all 0.15s',
  },
  active: { color: '#2563eb', background: '#eff6ff', fontWeight: 600 },
}

export default function Sidebar({ user, onLogout }) {
  const initials = (user?.full_name || user?.username || '?')
    .split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2)

  return (
    <nav style={s.sidebar}>
      <div style={s.logo}>
        ⚡ <span style={{ color: '#2563eb' }}>Hermes</span>
      </div>
      {nav.map(({ to, icon, label }) => (
        <NavLink
          key={to}
          to={to}
          end={to === '/'}
          style={({ isActive }) => ({ ...s.link, ...(isActive ? s.active : {}) })}
        >
          <span>{icon}</span>
          <span>{label}</span>
        </NavLink>
      ))}

      {/* User info + logout */}
      <div style={{ marginTop: 'auto', borderTop: '1px solid #e5e7eb', padding: '16px 20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
          <div style={{
            width: 32, height: 32, borderRadius: '50%', background: '#2563eb',
            color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 12, fontWeight: 700, flexShrink: 0,
          }}>
            {initials}
          </div>
          <div style={{ overflow: 'hidden' }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: '#1f2937', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
              {user?.full_name || user?.username}
            </div>
            <div style={{ fontSize: 11, color: '#9ca3af' }}>{user?.role}</div>
          </div>
        </div>
        <button onClick={onLogout} style={{
          width: '100%', padding: '7px', borderRadius: 6,
          border: '1px solid #e5e7eb', background: '#f9fafb',
          color: '#6b7280', fontSize: 12, cursor: 'pointer', fontWeight: 600,
        }}>
          Déconnexion
        </button>
      </div>
    </nav>
  )
}
