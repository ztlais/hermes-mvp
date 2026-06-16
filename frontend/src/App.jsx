import { useState, useEffect } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import Sidebar from './components/Sidebar'
import './styles.css'
import Overview from './pages/Overview'
import Scouting from './pages/Scouting'
import Prospects from './pages/Prospects'
import Investors from './pages/Investors'
import Matching from './pages/Matching'
import Templates from './pages/Templates'
import Learning from './pages/Learning'
import Simulateur from './pages/Simulateur'
import Opportunities from './pages/Opportunities'
import Projects from './pages/Projects'
import Settings from './pages/Settings'
import Login from './pages/Login'
import { LanguageProvider } from './context/LanguageContext'

function getStoredUser() {
  try { return JSON.parse(localStorage.getItem('hermes_user')) } catch { return null }
}

export default function App() {
  const [user, setUser] = useState(getStoredUser)
  const [mobileSidebar, setMobileSidebar] = useState(false)
  const [isMobile, setIsMobile] = useState(window.innerWidth < 768)

  useEffect(() => {
    const onResize = () => setIsMobile(window.innerWidth < 768)
    window.addEventListener('resize', onResize)
    return () => window.removeEventListener('resize', onResize)
  }, [])

  const handleLogin = (data) => {
    setUser({ username: data.username, full_name: data.full_name, role: data.role })
  }

  const handleLogout = () => {
    localStorage.removeItem('hermes_token')
    localStorage.removeItem('hermes_user')
    setUser(null)
  }

  if (!user) {
    return (
      <LanguageProvider>
        <Login onLogin={handleLogin} />
      </LanguageProvider>
    )
  }

  return (
    <LanguageProvider>
      <div style={{ display: 'flex', minHeight: '100vh', background: '#f1f5f9' }}>
        {/* Mobile overlay */}
        {isMobile && mobileSidebar && (
          <div onClick={() => setMobileSidebar(false)}
            style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 90 }} />
        )}

        {/* Sidebar */}
        <div style={{
          width: 240, flexShrink: 0,
          position: isMobile ? 'fixed' : 'relative',
          left: isMobile ? (mobileSidebar ? 0 : -240) : 0,
          top: 0, bottom: 0, zIndex: 100,
          transition: 'left 0.25s ease',
        }}>
          <Sidebar user={user} onLogout={handleLogout} onClose={() => setMobileSidebar(false)} isMobile={isMobile} />
        </div>

        <main style={{ flex: 1, padding: isMobile ? 16 : 32, overflowY: 'auto', minWidth: 0 }}>
          {/* Mobile hamburger */}
          {isMobile && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
              <button onClick={() => setMobileSidebar(true)}
                style={{ background: '#064e3b', border: 'none', color: '#fff', fontSize: 22, padding: '6px 12px', borderRadius: 8, cursor: 'pointer' }}>
                ☰
              </button>
              <span style={{ fontWeight: 700, fontSize: 16, color: '#064e3b' }}>EIR Dashboard</span>
            </div>
          )}
          <Routes>
            <Route path="/" element={<Overview />} />
            <Route path="/opportunities" element={<Opportunities />} />
            <Route path="/projects" element={<Projects />} />
            <Route path="/scouting" element={<Scouting />} />
            <Route path="/prospects" element={<Prospects />} />
            <Route path="/investors" element={<Investors />} />
            <Route path="/matching" element={<Matching />} />
            <Route path="/templates" element={<Templates />} />
            <Route path="/learning" element={<Learning />} />
            <Route path="/simulateur" element={<Simulateur />} />
            <Route path="/settings" element={<Settings user={user} />} />
            <Route path="*" element={<Navigate to="/" />} />
          </Routes>
        </main>
      </div>
    </LanguageProvider>
  )
}
