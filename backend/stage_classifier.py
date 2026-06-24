"""
Classification du stade de développement projet selon la méthodologie à 8 stades
(voir docs/stages-methodology.md) : Origination, Early, Submit, Mid, Advanced,
Nearly secured, Secured & clean, Refused.

Source de vérité unique : `custom_stage` est dérivé du texte brut "État de
développement", et `stage` (enum ProjectStage) est dérivé de `custom_stage`.
Ne jamais classifier `stage` indépendamment de `custom_stage`.
"""
import re

CUSTOM_STAGE_TO_ENUM = {
    'Origination': 'origination',
    'Early': 'early',
    'Submit': 'submit',
    'Mid': 'mid',
    'Advanced': 'advanced',
    'Nearly secured': 'nearly_secured',
    'Secured & clean': 'secured_and_clean',
    'Refused': 'refused',
}

_FR_WORDS = [
    'environnement', 'autorisations', 'raccordement', 'réseau', 'permis',
    'déposé', 'obtention', 'prévue', 'purgé', 'recours', 'foncier', 'études',
    'terrain', 'déposer', 'instruction', 'signé', 'purge', 'arrêté',
    'urbanisme', 'mairie', 'plu', 'enedis', 'rte', 'connexion',
]

_STATUS_PATTERNS = [
    r'Permis purgé|PC purgé', r'Certificat Enedis', r'PTF signée',
    r'PC déposé|Permis déposé', r'PC à déposer|Permis à déposer',
    r'Permis en instruction|En instruction', r'Statut permis Recours|Recours',
    r'Études?\s*environnementales?\s*en\s*cours', r'Land\s+(fully\s+)?secured',
    r'étude\s*en\s*cours', r'PRAC',
]


def classify_custom_stage(etat):
    """Classifie le stade personnalisé (Origination→Secured & clean) à partir de l'état brut."""
    if not etat or etat == 'nan':
        return 'Origination'
    e = etat.strip()
    first_line = e.split('\n')[0] if '\n' in e else e
    second = e.split('\n')[1] if '\n' in e else ''

    if re.search(r'^Early[-–—]', first_line, re.I): return 'Early'
    if re.search(r'^Submit[-–—]', first_line, re.I): return 'Submit'
    if re.search(r'^Mid[-–—]', first_line, re.I): return 'Mid'
    if re.search(r'^Advanced[-–—]', first_line, re.I): return 'Advanced'
    if re.search(r'^Nearly secured[-–—]', first_line, re.I): return 'Nearly secured'
    if re.search(r'Secured[ &]+(clean|and)[ &]+of appeal', first_line, re.I): return 'Secured & clean'
    if re.search(r'^Origination', first_line, re.I): return 'Origination'
    if re.search(r'Refus|refus', e): return 'Refused'
    # Inférence quand le texte n'a pas de préfixe de stade explicite
    if re.search(r'\(5\)', first_line): return 'Secured & clean'  # (5) Raccordement → permis purgé
    if re.search(r'^\d+\.\s*(Etudes|Études)', first_line, re.I):
        return 'Early' if re.search(r'land\s+secured', second, re.I) else 'Origination'
    return 'Origination'


def split_fr_en(text):
    """Sépare un texte en lignes FR et EN."""
    if not text:
        return '', ''
    lines = text.split('\n')
    fr = [l for l in lines if any(w in l.lower() for w in _FR_WORDS)]
    en = [l for l in lines if not any(w in l.lower() for w in _FR_WORDS)]
    return '\n'.join(fr), '\n'.join(en)


def extract_status(text_lang):
    """Extrait un statut court (FR ou EN) à partir d'un bloc de texte."""
    if not text_lang:
        return ''
    lines = text_lang.strip().split('\n')
    l2 = ' '.join(lines[1:]) if len(lines) > 1 else lines[0]
    for p in _STATUS_PATTERNS:
        m = re.search(p, l2, re.I)
        if m:
            return m.group(0)
    s = re.split(r'[;.\n¡!]', l2)[0].strip()
    s = re.sub(r'^(Land|Environmental|Studies?)\s+', '', s, flags=re.I).strip()
    return s[:30] if len(s) <= 30 else s[:28] + '…'


def classify(etat):
    """Classifie un texte brut "État de développement" en champs structurés."""
    custom_stage = classify_custom_stage(etat)
    fr_text, en_text = split_fr_en(etat or '')
    return {
        'custom_stage': custom_stage,
        'stage': CUSTOM_STAGE_TO_ENUM[custom_stage],
        'status_detail': etat or None,
        'status_fr': extract_status(fr_text) or None,
        'status_en': extract_status(en_text) or None,
    }
