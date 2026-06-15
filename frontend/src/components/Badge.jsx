const colors = {
  to_contact:       { bg: '#f3f4f6', color: '#4b5563' },
  contacted:        { bg: '#dbeafe', color: '#1e40af' },
  in_discussion:    { bg: '#fef3c7', color: '#92400e' },
  meeting_scheduled:{ bg: '#ede9fe', color: '#5b21b6' },
  nda_signed:       { bg: '#d1fae5', color: '#065f46' },
  deal_in_progress: { bg: '#cffafe', color: '#155e75' },
  closed:           { bg: '#d1fae5', color: '#065f46' },
  rejected:         { bg: '#fee2e2', color: '#991b1b' },
  active:           { bg: '#d1fae5', color: '#065f46' },
  inactive:         { bg: '#f3f4f6', color: '#4b5563' },
  email_sent:       { bg: '#dbeafe', color: '#1e40af' },
  linkedin_sent:    { bg: '#ede9fe', color: '#5b21b6' },
  responded:        { bg: '#d1fae5', color: '#065f46' },
  meeting_done:     { bg: '#fef3c7', color: '#92400e' },
  converted:        { bg: '#d1fae5', color: '#065f46' },
  no_response:      { bg: '#f3f4f6', color: '#4b5563' },
  not_interested:   { bg: '#fee2e2', color: '#991b1b' },
}

const labels = {
  to_contact: 'À contacter', contacted: 'Contacté', in_discussion: 'En discussion',
  meeting_scheduled: 'RDV planifié', nda_signed: 'NDA signé', deal_in_progress: 'Deal en cours',
  closed: 'Fermé', rejected: 'Rejeté', active: 'Actif', inactive: 'Inactif',
  email_sent: 'Email envoyé', linkedin_sent: 'LinkedIn envoyé', responded: 'A répondu',
  meeting_done: 'RDV fait', converted: 'Converti', no_response: 'Pas de réponse',
  not_interested: 'Pas intéressé',
  developer: 'Dev', investor: 'Investisseur', ipp: 'IPP', family_office: 'Family Office',
  fund: 'Fonds', corporate: 'Corporate', other: 'Autre',
  solar: '☀️ Solaire', wind: '💨 Éolien', bess: '🔋 BESS', hydro: '💧 Hydro',
}

export default function Badge({ value }) {
  const c = colors[value] || { bg: '#f3f4f6', color: '#4b5563' }
  const label = labels[value] || value
  return (
    <span style={{
      display: 'inline-block', padding: '2px 10px', borderRadius: 10,
      fontSize: 11, fontWeight: 600, background: c.bg, color: c.color,
    }}>
      {label}
    </span>
  )
}
