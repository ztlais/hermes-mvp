// Éléments partagés du module Scouting (utilisés par ScoutingMarket)

export const TYPE_BADGE_STYLES = {
  developer:    { bg: '#dbeafe', color: '#1e40af' },
  investor:     { bg: '#fef3c7', color: '#92400e' },
  ipp:          { bg: '#cffafe', color: '#155e75' },
  family_office:{ bg: '#ede9fe', color: '#5b21b6' },
}
export const TYPE_VALUES = ['developer', 'investor', 'ipp', 'family_office']
export const TYPE_SHORT_LABELS = { developer: 'Dev', investor: 'Invest.', ipp: 'IPP', family_office: 'Family' }

// ── Plateformes de recherche ──
export const PLATFORMS = [
  { name: "France Renouvelables", url: "https://www.france-renouvelables.fr/annuaire-des-membres/", cible: "Investisseurs + Développeurs", statut: "✅ Fait", note: "17 investisseurs ajoutés" },
  { name: "FFPA", url: "https://ffpa.fr/developpeurs-de-projets/", cible: "Développeurs (AgriPV)", statut: "✅ Fait", note: "31 développeurs ajoutés" },
  { name: "France Agrivoltaïsme", url: "https://france-agrivoltaisme.org/nos-membres/", cible: "Développeurs + Investisseurs", statut: "✅ Fait", note: "" },
  { name: "SER (Syndicat ENR)", url: "https://www.syndicat-energies-renouvelables.fr/", cible: "Tous acteurs ENR", statut: "✅ Fait", note: "339 membres - 89 développeurs ajoutés" },
  { name: "LinkedIn Search", url: "", cible: "Investisseurs (France/Europe)", statut: "🔍 À faire", note: "Mots-clés: Investment Manager ENR, Head of M&A solar" },
  { name: "Lendosphere", url: "https://www.lendosphere.com/", cible: "Investisseurs", statut: "🔍 À faire", note: "" },
  { name: "Enerfip", url: "https://www.enerfip.fr/", cible: "Investisseurs", statut: "🔍 À faire", note: "" },
  { name: "Lumo", url: "https://www.lumo.fr/", cible: "Investisseurs", statut: "🔍 À faire", note: "" },
  { name: "Lendopolis", url: "https://www.lendopolis.com/", cible: "Investisseurs", statut: "🔍 À faire", note: "" },
  { name: "CRE (Appels d'offres)", url: "https://www.cre.fr/", cible: "Développeurs lauréats", statut: "🔍 À faire", note: "" },
  { name: "Intersolar Europe", url: "https://www.intersolar-europe.com/", cible: "Tous", statut: "🔍 À faire", note: "" },
  { name: "European Energy Summit", url: "", cible: "Investisseurs", statut: "🔍 À faire", note: "" },
  { name: "SER - Éolien Terrestre", url: "https://www.syndicat-energies-renouvelables.fr/adherer/nos-adherents/", cible: "Développeurs éoliens", statut: "✅ Fait", note: "Filtrer par 'Éolien terrestre'" },
]

export const getLang = (country) => ['FR', 'BE'].includes(country?.toUpperCase()) ? 'fr' : 'en'
export const getFirstName = (name) => name?.split(' ')[0] || ''

// ── Templates par défaut (FR) ──
export const DEFAULT_TEMPLATES = {
  developer: {
    1: { linkedin: "Bonjour [Prénom],\n\nJe suis chez ENECHANGE (Japon, TSE:4169) — via EIR, on connecte les développeurs ENR avec des investisseurs en Europe.\n30+ investisseurs | 700+ projets\nFinancement, acquisition ou cession ? Je peux vous aider.\nZein\nzein.tlais@enechange.com", email: "" },
    2: { linkedin: "Bonjour [Prénom],\n\nMerci pour la connexion. Nos investisseurs recherchent :\n• Co-développement par jalons\n• Projets RTB à acquérir\n• Partenariats SPV\n\nRéservez un créneau : https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBien à vous,\nZein", email: "Objet : Présentation EIR\n\nBonjour [Prénom],\n\nSuite à notre échange LinkedIn, voici notre plateforme.\n\nBien à vous,\nZein Tlais\nzein.tlais@enechange.com" }
  },
  investor: {
    1: { linkedin: "Bonjour [Prénom],\n\nJe suis chez ENECHANGE (Japon, TSE:4169) — via EIR, on source des projets ENR bankables en Europe.\n700+ projets analysés | 30+ investisseurs connectés\nBest,\nzein.tlais@enechange.com", email: "" },
    2: { linkedin: "Bonjour [Prénom],\n\nMerci pour la connexion. Via EIR, on connecte les investisseurs avec des opportunités :\n• Co-investissement\n• Projets RTB\n• Co-développement\n\nRéservez un créneau : https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBien à vous,\nZein", email: "Objet : Pipeline EIR\n\nBonjour [Prénom],\n\nSuite à notre échange LinkedIn, voici notre pipeline.\n\nBien à vous,\nZein Tlais\nzein.tlais@enechange.com" }
  },
  ipp: {
    1: { linkedin: "Bonjour [Prénom],\n\nJe suis chez ENECHANGE (Japon, TSE:4169) — via EIR, on connecte les IPP avec des investisseurs en Europe.\n30+ investisseurs | 700+ projets\n\nZein\nzein.tlais@enechange.com", email: "" },
    2: { linkedin: "Bonjour [Prénom],\n\nMerci pour la connexion. Via EIR, on connecte les IPP avec des investisseurs.\n\nRéservez un créneau : https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBien à vous,\nZein", email: "Objet : Partenariat EIR\n\nBonjour [Prénom],\n\nSuite à notre échange LinkedIn, voici notre plateforme.\n\nBien à vous,\nZein Tlais\nzein.tlais@enechange.com" }
  },
  family_office: {
    1: { linkedin: "Bonjour [Prénom],\n\nJe suis chez ENECHANGE (Japon, TSE:4169) — via EIR, on connecte les fonds avec des développeurs ENR en Europe.\n30+ investisseurs | 700+ projets\n\nZein\nzein.tlais@enechange.com", email: "" },
    2: { linkedin: "Bonjour [Prénom],\n\nMerci pour la connexion. Via EIR, on connecte les fonds avec des opportunités :\n• Deals off-market\n• Co-investissement\n• Projets RTB\n\nRéservez un créneau : https://calendar.app.google/Fe8Br6t4KzuWRxDE8\n\nBien à vous,\nZein", email: "Objet : Off-market deals EIR\n\nBonjour [Prénom],\n\nSuite à notre échange LinkedIn, voici notre plateforme.\n\nBien à vous,\nZein Tlais\nzein.tlais@enechange.com" }
  }
}

export const personalize = (body, item) => {
  const prenom = getFirstName(item.contact_name)
  return (body || '')
    .replace(/\[Prénom\]/g, prenom)
    .replace(/\[Name\]/g, prenom)
    .replace(/\[Société\]/g, item.company || '')
    .replace(/\[Company\]/g, item.company || '')
}

export function parseData(item) {
  try {
    return JSON.parse(item.data || '{}')
  } catch { return {} }
}

export function TypeBadge({ type }) {
  const styles = TYPE_BADGE_STYLES[type] || { bg: '#f3f4f6', color: '#4b5563' }
  return (
    <span style={{ padding: '2px 7px', borderRadius: 8, fontSize: 10, fontWeight: 700, background: styles.bg, color: styles.color }}>
      {TYPE_SHORT_LABELS[type] || type}
    </span>
  )
}

export function Tab({ label, active, onClick, count }) {
  return (
    <button onClick={onClick} style={{
      padding: '5px 12px', border: 'none', borderRadius: 5, cursor: 'pointer',
      fontSize: 12, fontWeight: 600,
      background: active ? '#1f2937' : '#f3f4f6',
      color: active ? '#fff' : '#6b7280',
    }}>
      {label}{count != null ? ` (${count})` : ''}
    </button>
  )
}
