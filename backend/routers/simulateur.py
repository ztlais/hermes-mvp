from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
import numpy as np

router = APIRouter(prefix="/simulateur", tags=["simulateur"])

# ── Données de référence ────────────────────────────────────────────────────

QUOTES_PARTS_S3RENR = {
    "Occitanie": 82.42,
    "Nouvelle-Aquitaine": 90.84,
    "PACA": 76.89,
    "Auvergne-Rhône-Alpes": 41.55,
    "Bretagne": 20.14,
    "Pays de la Loire": 45.54,
    "Centre-Val de Loire": 69.04,
    "Île-de-France": 55.0,
    "Grand Est": 48.0,
    "Normandie": 35.0,
    "Hauts-de-France": 30.0,
    "Bourgogne-Franche-Comté": 42.0,
}

# Tarifs ENEDIS-PRO-RES_080E (ZFA / ZFB)
RACCORDEMENT_REF = {
    "branchement_BT_fixe_ZFA": 3908,
    "branchement_BT_variable_ZFA": 95,
    "branchement_BT_fixe_ZFB": 3908,
    "branchement_BT_variable_ZFB": 95,
    "extension_fixe_ZFA": 1200,
    "extension_variable_ZFA": 55,
    "extension_fixe_ZFB": 1500,
    "extension_variable_ZFB": 70,
}

ZONES_ZFB = {"Bretagne", "Normandie", "Hauts-de-France", "Pays de la Loire"}

# ── Modèle d'entrée ─────────────────────────────────────────────────────────

class SimulateurInput(BaseModel):
    # Projet
    puissance_kwc: float = 145.5
    puissance_kva: float = 80.0
    productible_p90: float = 1280.0
    productible_p50: float = 1313.0
    surface_m2: float = 700.0
    region: str = "Occitanie"
    type_offre: str = "toiture"       # toiture | ombriere | sol
    batiment_neuf: bool = False
    date_t0: Optional[str] = None     # YYYY-MM-DD
    date_mise_en_service: Optional[str] = None

    # Tarif
    tarif_achat_override: Optional[float] = None   # €/MWh

    # Autoconsommation
    autoconsommation: bool = False
    acc: bool = False                 # Autoconsommation collective
    taux_autoconso: float = 0.0       # fraction (0-1)
    conso_annuelle_kwh: float = 64000.0
    prix_kwh_fournisseur: float = 0.25
    tarif_revente_acc: float = 0.11

    # Rénovations toiture (m²)
    depose_everite_amiantee_m2: float = 0.0
    depose_everite_na_m2: float = 0.0
    depose_tuiles_m2: float = 0.0
    depose_bac_acier_m2: float = 0.0
    pose_bac_acier_isole_m2: float = 0.0
    pose_bac_acier_standard_m2: float = 0.0

    # Construction spéciale
    ombriere_kwc: float = 0.0
    hangar_m2: float = 0.0

    # Raccordement
    ml_domaine_public: float = 0.0    # mètres pour extension BT
    relai_supplementaire: bool = False

    # Soulte propriétaire
    soulte_pct_ca: float = 0.0        # % CA sur 20 ans
    loyer_kwc: float = 0.0            # €/kWc/an (sol)

    # Financement
    levier: float = 0.7
    taux_interet: float = 0.0408
    maturite_ans: int = 20
    pme: bool = True                  # IS PME (15% / 25%) vs grande entreprise (25%)

    # Charges exploitation
    maintenance_kwc: float = 12.0
    assurance_kwc: float = 3.0
    ifer_kwc: Optional[float] = None  # auto si None
    autres_taxes_kwc: float = 1.5
    remplacement_onduleurs_kwc: float = 2.5
    frais_aggreg_kwc: float = 0.003
    frais_fixes_aggreg_k: float = 1.2

    # Modèle Nov'Era
    novera_actif: bool = False
    novera_annees_paiement: int = 5
    novera_pct_paiement: float = 0.055
    novera_pct_rachat: float = 0.88
    novera_taux_van: float = 0.03
    novera_levier_phase3: float = 0.7
    novera_maturite_phase3: int = 15


# ── Helpers ─────────────────────────────────────────────────────────────────

def _irr(cashflows: list) -> Optional[float]:
    rate = 0.1
    for _ in range(2000):
        npv = sum(cf / (1 + rate) ** i for i, cf in enumerate(cashflows))
        dnpv = sum(-i * cf / (1 + rate) ** (i + 1) for i, cf in enumerate(cashflows))
        if abs(dnpv) < 1e-12:
            break
        rate -= npv / dnpv
        if rate <= -1 or rate > 10:
            return None
    return rate if -1 < rate < 10 else None


def _npv(rate: float, cashflows: list) -> float:
    return sum(cf / (1 + rate) ** i for i, cf in enumerate(cashflows))


def calcul_tarif(puissance_kwc: float, autoconsommation: bool) -> float:
    if autoconsommation:
        return 0.0886
    if puissance_kwc > 100:
        return 0.0886
    elif puissance_kwc > 36:
        return 0.0912
    elif puissance_kwc > 9:
        return 0.1049
    return 0.1049


def calcul_prime_autoconso(puissance_kwc: float) -> float:
    if puissance_kwc <= 9:
        return 80 * puissance_kwc
    elif puissance_kwc <= 36:
        return 160 * puissance_kwc
    elif puissance_kwc <= 100:
        return 80 * puissance_kwc
    return 0.0


# ── RACCORDEMENT ────────────────────────────────────────────────────────────

def calcul_raccordement(inp: SimulateurInput) -> dict:
    zone = "ZFB" if inp.region in ZONES_ZFB else "ZFA"
    r = RACCORDEMENT_REF

    branchement_fixe = r[f"branchement_BT_fixe_{zone}"]
    branchement_var = r[f"branchement_BT_variable_{zone}"] * inp.ml_domaine_public
    ext_fixe = r[f"extension_fixe_{zone}"]
    ext_var = r[f"extension_variable_{zone}"] * inp.ml_domaine_public

    raccordement_enedis = branchement_fixe + branchement_var + ext_fixe + ext_var
    quotes_parts = QUOTES_PARTS_S3RENR.get(inp.region, 60.0) * inp.puissance_kwc
    relai = 40000 if inp.relai_supplementaire else 0

    total = raccordement_enedis + quotes_parts + relai

    return {
        "zone": zone,
        "branchement": round(branchement_fixe + branchement_var),
        "extension_bt": round(ext_fixe + ext_var),
        "quotes_parts_s3renr": round(quotes_parts),
        "relai_supplementaire": round(relai),
        "total": round(total),
        "total_kwc": round(total / inp.puissance_kwc, 1),
    }


# ── CAPEX ────────────────────────────────────────────────────────────────────

def calcul_capex(inp: SimulateurInput, raccordement: dict) -> dict:
    p = inp.puissance_kwc

    # Frais développement
    frais_commerciaux = 30 * p
    amo_dev = 15 * p
    etude_structure = 3000
    etude_sol = 5000 if inp.type_offre in ["ombriere", "sol"] else 0
    detection_reseau = 1500 if inp.type_offre in ["ombriere", "sol"] else 0
    architecte = 1500
    notaire = 5000
    geometre = 2240
    huissier = 350
    mise_en_place_acc = 1500 if inp.acc else 0
    frais_dev = (frais_commerciaux + amo_dev + etude_structure + etude_sol +
                 detection_reseau + architecte + notaire + geometre + huissier + mise_en_place_acc)

    # Rénovations
    renov_everite_amiantee = inp.depose_everite_amiantee_m2 * 43
    renov_everite_na = inp.depose_everite_na_m2 * 12
    renov_tuiles = inp.depose_tuiles_m2 * 34
    renov_bac_acier = inp.depose_bac_acier_m2 * 10
    renov_pose_isole = inp.pose_bac_acier_isole_m2 * 48
    renov_pose_standard = inp.pose_bac_acier_standard_m2 * 28
    total_renov = (renov_everite_amiantee + renov_everite_na + renov_tuiles +
                   renov_bac_acier + renov_pose_isole + renov_pose_standard)

    # Renforcement structure
    renforcement = 30 * inp.surface_m2 if (inp.type_offre == "toiture" and not inp.batiment_neuf) else 0

    # Construction ombrière / hangar
    construction_ombriere = (570 + 150) * inp.ombriere_kwc if inp.ombriere_kwc > 0 else 0
    construction_hangar = (100 + 25) * inp.hangar_m2 if inp.hangar_m2 > 0 else 0

    # Équipements PV
    panneaux = 0.13 * p * 1000
    string_connecteurs = 14 * p
    chemin_cables = 7 * p
    onduleurs = 35 * (p / 1.2)
    schelter = 35 * p
    cables_ac = max(2000, 45 * 100)
    vrd_elec = max(2000, 100 * 100)
    mise_en_service = 1500

    main_oeuvre = (200000 / 12000 + 165) * p
    base_imprevus = panneaux + string_connecteurs + chemin_cables + onduleurs + schelter + cables_ac + vrd_elec + main_oeuvre
    imprevus = 0.02 * base_imprevus

    assurance_do = 1000
    bureau_etudes = 1600 + 1850
    honoraires = 0.02 * base_imprevus
    assurances_etudes = assurance_do + bureau_etudes + honoraires

    construction = (panneaux + string_connecteurs + chemin_cables + onduleurs + schelter
                    + cables_ac + vrd_elec + mise_en_service + main_oeuvre
                    + imprevus + assurances_etudes + total_renov + renforcement
                    + construction_ombriere + construction_hangar)

    marge_construction = construction * 0.15 / (1 - 0.15)
    total_dev_commercial = 120 * p

    total_ht = (construction + marge_construction + frais_dev
                + raccordement["total"] + total_dev_commercial)

    return {
        "frais_dev": round(frais_dev),
        "raccordement": raccordement["total"],
        "renforcement_structure": round(renforcement),
        "renovations": round(total_renov),
        "panneaux": round(panneaux),
        "onduleurs": round(onduleurs),
        "main_oeuvre": round(main_oeuvre),
        "autres_construction": round(string_connecteurs + chemin_cables + schelter + cables_ac + vrd_elec + mise_en_service),
        "imprevus": round(imprevus),
        "assurances_etudes": round(assurances_etudes),
        "marge_construction": round(marge_construction),
        "total_dev_commercial": round(total_dev_commercial),
        "construction_speciale": round(construction_ombriere + construction_hangar),
        "total_ht": round(total_ht),
        "total_kwc": round(total_ht / p, 0),
    }


# ── AUTOCONSOMMATION ─────────────────────────────────────────────────────────

def calcul_autoconso(inp: SimulateurInput) -> dict:
    if not inp.autoconsommation and not inp.acc:
        return {}

    p = inp.puissance_kwc
    prod_p50 = p * inp.productible_p50 * 0.98
    prod_p90 = p * inp.productible_p90 * 0.98

    energie_autoconso = prod_p50 * inp.taux_autoconso
    energie_soutirée = max(0, inp.conso_annuelle_kwh - energie_autoconso)
    injection_p90 = max(0, prod_p90 - energie_autoconso)
    injection_p50 = max(0, prod_p50 - energie_autoconso)
    taux_autosuffisance = energie_autoconso / inp.conso_annuelle_kwh if inp.conso_annuelle_kwh > 0 else 0

    # Tarif revente réseau selon puissance
    tarif_surplus = 0.0617 if p <= 100 else (0.09 if p > 100 else 0.004)

    # Économies client
    economie_autoconso = energie_autoconso * inp.prix_kwh_fournisseur
    revenu_injection = injection_p50 * tarif_surplus
    reduction_facture = economie_autoconso / (inp.conso_annuelle_kwh * inp.prix_kwh_fournisseur) if inp.conso_annuelle_kwh > 0 else 0

    prime = calcul_prime_autoconso(p)

    return {
        "production_p90_kwh": round(prod_p90),
        "production_p50_kwh": round(prod_p50),
        "energie_autoconsommee_kwh": round(energie_autoconso),
        "energie_soutirée_reseau_kwh": round(energie_soutirée),
        "injection_reseau_p90_kwh": round(injection_p90),
        "injection_reseau_p50_kwh": round(injection_p50),
        "taux_autoconsommation": round(inp.taux_autoconso * 100, 1),
        "taux_autosuffisance": round(taux_autosuffisance * 100, 1),
        "tarif_surplus_kwh": round(tarif_surplus * 1000, 2),
        "economie_annuelle_eur": round(economie_autoconso),
        "revenu_injection_eur": round(revenu_injection),
        "reduction_facture_pct": round(reduction_facture * 100, 1),
        "prime_autoconso_eur": round(prime),
    }


# ── PRÉVISIONNEL 30 ANS ──────────────────────────────────────────────────────

def calcul_previsionnel(inp: SimulateurInput, capex: dict) -> list:
    p = inp.puissance_kwc
    tarif_kwh = (inp.tarif_achat_override / 1000) if inp.tarif_achat_override else calcul_tarif(p, inp.autoconsommation)
    tarif_apres_20 = 0.065  # €/kWh après 20 ans
    disponibilite = 0.98
    inflation_elec = 0.01
    degradation = -0.0035
    inflation_charges = 0.02

    prod_p90_an1 = p * inp.productible_p90 * disponibilite
    prod_p50_an1 = p * inp.productible_p50 * disponibilite

    # Charges fixes an 1 (k€)
    maintenance = inp.maintenance_kwc * p / 1000
    assurance = inp.assurance_kwc * p / 1000
    loyer = inp.loyer_kwc * p / 1000
    frais_aggreg = inp.frais_aggreg_kwc * p / 1000
    frais_fixes_aggreg = inp.frais_fixes_aggreg_k / 1000

    ifer = (inp.ifer_kwc if inp.ifer_kwc is not None else (3.542 if p >= 100 else 0))
    turpe = 0.50904 if 36 < p <= 250 else (0.83796 if p > 250 else 0.3828)
    autres_taxes = inp.autres_taxes_kwc * p / 1000
    remplacement_onduleurs = inp.remplacement_onduleurs_kwc * p / 1000

    charges_opex_an1 = maintenance + assurance + loyer + frais_aggreg + frais_fixes_aggreg
    charges_fiscales_an1 = (ifer * p / 1000 + turpe + autres_taxes + remplacement_onduleurs) / 1000

    investissement_k = capex["total_ht"] / 1000
    emprunt_k = investissement_k * inp.levier
    encours = emprunt_k

    annees = []
    charges_opex = charges_opex_an1
    charges_fiscales = charges_fiscales_an1

    for an in range(1, 32):
        # Revenus
        if an == 1:
            ca_p90 = prod_p90_an1 * tarif_kwh / 1000
            ca_p50 = prod_p50_an1 * tarif_kwh / 1000
        else:
            prev = annees[-1]
            tarif_an = tarif_kwh if an <= 20 else tarif_apres_20
            degr = (1 + degradation)
            infl = (1 + inflation_elec)
            if an == 2:
                ca_p90 = prev["ca_p90"] * (1 + inflation_elec - 0.0065) * degr
                ca_p50 = prev["ca_p50"] * (1 + inflation_elec - 0.0065) * degr
            else:
                ca_p90 = prev["ca_p90"] * infl * degr
                ca_p50 = prev["ca_p50"] * infl * degr

        # Soulte propriétaire (sur CA années 1-20)
        soulte_an = ca_p90 * inp.soulte_pct_ca if an <= 20 else 0

        charges_totales = charges_opex + charges_fiscales + soulte_an

        # Emprunt
        if an <= inp.maturite_ans and encours > 0:
            interet = encours * inp.taux_interet
            remb_capital = emprunt_k / inp.maturite_ans
            encours = max(0, encours - remb_capital)
        else:
            interet = 0
            remb_capital = 0

        treso_exploit_p90 = ca_p90 - charges_totales
        treso_exploit_p50 = ca_p50 - charges_totales

        # IS
        amort = (investissement_k / 20) if an <= 20 else 0
        rcai_p90 = treso_exploit_p90 - amort - interet
        rcai_p50 = treso_exploit_p50 - amort - interet

        def calcul_is(rcai):
            if rcai <= 0:
                return 0.0
            if inp.pme:
                if rcai * 1000 <= 42.5:
                    return rcai * 0.15
                return 42.5 * 0.15 / 1000 + (rcai - 42.5 / 1000) * 0.25
            return rcai * 0.25

        is_p90 = calcul_is(rcai_p90)
        is_p50 = calcul_is(rcai_p50)

        cashflow_p90 = treso_exploit_p90 - is_p90 - interet - remb_capital
        cashflow_p50 = treso_exploit_p50 - is_p50 - interet - remb_capital

        # DSCR = cashflow net exploitation / service de la dette
        dscr = (treso_exploit_p90 - is_p90) / (interet + remb_capital) if (interet + remb_capital) > 0 else None

        annees.append({
            "annee": an,
            "ca_p90": round(ca_p90, 3),
            "ca_p50": round(ca_p50, 3),
            "charges": round(charges_totales, 3),
            "soulte": round(soulte_an, 3),
            "treso_exploit_p90": round(treso_exploit_p90, 3),
            "treso_exploit_p50": round(treso_exploit_p50, 3),
            "amort": round(amort, 3),
            "interet": round(interet, 3),
            "remb_capital": round(remb_capital, 3),
            "is_p90": round(is_p90, 3),
            "is_p50": round(is_p50, 3),
            "cashflow_p90": round(cashflow_p90, 3),
            "cashflow_p50": round(cashflow_p50, 3),
            "dscr": round(dscr, 2) if dscr is not None else None,
        })

        if an < 31:
            charges_opex *= (1 + inflation_charges)
            charges_fiscales *= (1 + inflation_charges)

    return annees


# ── KPIs ─────────────────────────────────────────────────────────────────────

def calcul_kpis(inp: SimulateurInput, capex: dict, prev: list) -> dict:
    tarif = (inp.tarif_achat_override / 1000) if inp.tarif_achat_override else calcul_tarif(inp.puissance_kwc, inp.autoconsommation)
    inv_k = capex["total_ht"] / 1000
    fp_k = inv_k * (1 - inp.levier)

    # Cashflows pour TRI/VAN (investisseur fonds propres)
    cf_p90 = [-fp_k] + [a["cashflow_p90"] for a in prev]
    cf_p50 = [-fp_k] + [a["cashflow_p50"] for a in prev]

    tri_p90 = _irr(cf_p90)
    tri_p50 = _irr(cf_p50)

    # VAN à 3 taux
    van = {}
    for taux, label in [(0.03, "3"), (0.05, "5"), (0.07, "7")]:
        van[f"p90_{label}pct"] = round(_npv(taux, cf_p90) * 1000)
        van[f"p50_{label}pct"] = round(_npv(taux, cf_p50) * 1000)

    # Rendements
    rendement_brut = prev[0]["ca_p90"] / inv_k
    rendement_net_5ans = sum(a["treso_exploit_p50"] for a in prev[:5]) / 5 / inv_k
    rendement_net_30ans = sum(a["treso_exploit_p50"] for a in prev) / 30 / inv_k

    # DSCR moyen (années avec emprunt)
    dscrs = [a["dscr"] for a in prev if a["dscr"] is not None and a["dscr"] > 0]
    dscr_moyen = round(sum(dscrs) / len(dscrs), 2) if dscrs else None

    # Payback (cashflow cumulé positif)
    cumul = 0
    payback = None
    for a in prev:
        cumul += a["cashflow_p50"]
        if cumul >= 0 and payback is None:
            payback = a["annee"]

    production_an1 = inp.puissance_kwc * inp.productible_p90 * 0.98

    return {
        "tarif_achat_mwh": round(tarif * 1000, 2),
        "ca_an1_p90_eur": round(prev[0]["ca_p90"] * 1000),
        "ca_an1_p50_eur": round(prev[0]["ca_p50"] * 1000),
        "production_kwh_an": round(production_an1),
        "tri_p90": round(tri_p90 * 100, 2) if tri_p90 else None,
        "tri_p50": round(tri_p50 * 100, 2) if tri_p50 else None,
        "van": van,
        "rendement_brut": round(rendement_brut * 100, 2),
        "rendement_net_5ans": round(rendement_net_5ans * 100, 2),
        "rendement_net_30ans": round(rendement_net_30ans * 100, 2),
        "dscr_moyen": dscr_moyen,
        "payback_ans": payback,
        "capex_total": capex["total_ht"],
        "capex_kwc": capex["total_kwc"],
        "fonds_propres": round(fp_k * 1000),
        "emprunt": round(inv_k * inp.levier * 1000),
    }


# ── MODÈLE NOV'ERA ───────────────────────────────────────────────────────────

def calcul_novera(inp: SimulateurInput, capex: dict, prev: list) -> Optional[dict]:
    if not inp.novera_actif:
        return None

    inv_k = capex["total_ht"] / 1000
    n = inp.novera_annees_paiement

    # Phase 1 : Nov'Era achète le projet (modèle conservateur)
    # Investissement initial + paiements annuels + rachat final
    invest_init = -inv_k
    paiements = [-inp.novera_pct_paiement * abs(invest_init)] * n
    rachat = -inp.novera_pct_rachat * abs(invest_init)

    cf_novera_conservateur = [invest_init] + paiements[:-1] + [paiements[-1] + rachat] + [0] * (30 - n)
    tri_conservateur = _irr(cf_novera_conservateur)
    van_conservateur = _npv(inp.novera_taux_van, cf_novera_conservateur) * 1000

    # Phase 2 (Energy Manager) : EBE exploitant sur les premières années
    cf_energy_manager = []
    for i, a in enumerate(prev[:n]):
        ebe = a["treso_exploit_p90"] - abs(inp.novera_pct_paiement * inv_k)
        cf_energy_manager.append(round(ebe, 3))

    # Phase 3 : investisseur après rachat
    rachat_valeur = inp.novera_pct_rachat * inv_k
    emprunt_phase3 = rachat_valeur * inp.novera_levier_phase3
    fp_phase3 = rachat_valeur * (1 - inp.novera_levier_phase3)

    cf_phase3 = [-fp_phase3]
    encours_p3 = emprunt_phase3
    for a in prev[n:]:
        interet_p3 = encours_p3 * inp.taux_interet if encours_p3 > 0 else 0
        remb_p3 = emprunt_phase3 / inp.novera_maturite_phase3 if encours_p3 > 0 else 0
        encours_p3 = max(0, encours_p3 - remb_p3)
        cf_phase3.append(round(a["treso_exploit_p90"] - interet_p3 - remb_p3, 3))

    tri_phase3 = _irr(cf_phase3)
    van_phase3 = _npv(inp.novera_taux_van, cf_phase3) * 1000

    apport_fp_requis = round(fp_phase3 * 1000)

    return {
        "conservateur": {
            "annees_paiement": n,
            "pct_paiements": inp.novera_pct_paiement,
            "pct_rachat": inp.novera_pct_rachat,
            "tri": round(tri_conservateur * 100, 2) if tri_conservateur else None,
            "van": round(van_conservateur),
            "cashflows": [round(cf, 3) for cf in cf_novera_conservateur[:n+1]],
        },
        "energy_manager": {
            "ebe_annuel": cf_energy_manager,
            "total": round(sum(cf_energy_manager), 3),
        },
        "phase3_investisseur": {
            "rachat_valeur_eur": round(rachat_valeur * 1000),
            "emprunt_eur": round(emprunt_phase3 * 1000),
            "apport_fp_requis_eur": apport_fp_requis,
            "tri": round(tri_phase3 * 100, 2) if tri_phase3 else None,
            "van": round(van_phase3),
        },
    }


# ── ENDPOINT ─────────────────────────────────────────────────────────────────

@router.post("/calculate")
def calculate(inp: SimulateurInput):
    raccordement = calcul_raccordement(inp)
    capex = calcul_capex(inp, raccordement)
    previsionnel = calcul_previsionnel(inp, capex)
    kpis = calcul_kpis(inp, capex, previsionnel)
    autoconso = calcul_autoconso(inp)
    novera = calcul_novera(inp, capex, previsionnel)

    return {
        "kpis": kpis,
        "capex": capex,
        "raccordement": raccordement,
        "previsionnel": previsionnel,
        "autoconsommation": autoconso,
        "novera": novera,
    }


@router.get("/regions")
def get_regions():
    return list(QUOTES_PARTS_S3RENR.keys())
