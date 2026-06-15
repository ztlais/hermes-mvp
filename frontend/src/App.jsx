import { useState } from 'react'
import { Routes, Route, Navigate } from 'react-router-dom'
import Sidebar from './components/Sidebar'
import Overview from './pages/Overview'
import Scouting from './pages/Scouting'
import Prospects from './pages/Prospects'
import Investors from './pages/Investors'
import Matching from './pages/Matching'
import Templates from './pages/Templates'
import Learning from './pages/Learning'
import Login from './pages/Login'

function getStoredUser() {
  try { return JSON.parse(localStorage.getItem('hermes_user')) } catch { return null }
}

export default function App() {
  const [user, setUser] = useState(getStoredUser)

  const handleLogin = (data) => {
    setUser({ username: data.username, full_name: data.full_name, role: data.role })
  }

  const handleLogout = () => {
    localStorage.removeItem('hermes_token')
    localStorage.removeItem('hermes_user')
    setUser(null)
  }

  if (!user) {
    return <Login onLogin={handleLogin} />
  }

  return (
    <div style={{ display: 'flex', minHeight: '100vh', background: '#fafafa' }}>
      <Sidebar user={user} onLogout={handleLogout} />
      <main style={{ flex: 1, padding: 32, overflowY: 'auto' }}>
        <Routes>
          <Route path="/" element={<Overview />} />
          <Route path="/scouting" element={<Scouting />} />
          <Route path="/prospects" element={<Prospects />} />
          <Route path="/investors" element={<Investors />} />
          <Route path="/matching" element={<Matching />} />
          <Route path="/templates" element={<Templates />} />
          <Route path="/learning" element={<Learning />} />
          <Route path="*" element={<Navigate to="/" />} />
        </Routes>
      </main>
    </div>
  )
}
