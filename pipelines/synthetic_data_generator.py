"""PR #1: Synthetic Public Sector Data Generator for `government-data-platform`.

Generates realistic, privacy-preserving (100% synthetic/pseudonymized) records across all
8 Government Subagent domains for local testing, CI/CD, and BigQuery seeding.
"""

from __future__ import annotations

from datetime import datetime, timezone
import hashlib
import json
from typing import Any


def generate_sectoral_synthetic_bundle() -> dict[str, list[dict[str, Any]]]:
    """Generates deterministic synthetic datasets covering all 8 subagent domains."""
    now_iso = datetime.now(timezone.utc).isoformat()
    sample_evidence_bytes = b"sinesp-optical-ocr-corridor-br116-frame-001"
    sample_evidence_hash = hashlib.sha256(sample_evidence_bytes).hexdigest()

    return {
        "gdp_civitas_cidadania.cadunico_beneficios_pseudonimizados": [
            {
                "tenant_id": "gov-br-mds",
                "family_nis_hash": "NIS-PSEUDO-88A1F09C",
                "citizen_cpf_pseudo": "CPF-PSEUDO-3F9011BC",
                "ibge_municipality_code": "5300108",
                "per_capita_income_brl": 195.00,
                "eligible_programs": ["Bolsa Família", "Tarifa Social de Energia Elétrica"],
                "lgpd_legal_basis": "LEI_13709_ART_7_III_POLITICAS_PUBLICAS",
                "consent_token_hash": "CONSENT-SHA256-991A",
                "updated_at": now_iso,
            }
        ],
        "gdp_aegis_seguranca.ocorrencias_cadeia_custodia_multimodal": [
            {
                "tenant_id": "gov-br-mjsp",
                "evidence_id": "EV-SINESP-2026-0001",
                "operation_corridor": "BR-116",
                "media_type": "video",
                "evidence_sha256": sample_evidence_hash,
                "collector_badge_id": "PRF-AGENTE-4412",
                "origin_system": "SINESP-SENTINELA-OCR",
                "geolocation": "POINT(-46.6333 -23.5505)",
                "collected_at": now_iso,
            }
        ],
        "gdp_lexveritas_justica.datajud_acordaos_precedentes_oficiais": [
            {
                "tenant_id": "gov-br-cnj",
                "citation_id": "STF-TEMA-1022-RE-688267",
                "court_code": "STF",
                "precedent_type": "TEMA_REPERCUSSAO_GERAL",
                "official_uri": "https://portal.stf.jus.br/",
                "ementa_verbatim": "Empresas públicas e sociedades de economia mista têm o dever jurídico de motivar a demissão de empregados concursados.",
                "published_at": "2024-02-28",
            }
        ],
        "gdp_custoslegis_mp.pncp_editais_contratos_auditoria": [
            {
                "tenant_id": "mpf-br",
                "edital_id": "PE-90012/2026",
                "contracting_agency_uasg": "153010",
                "legal_regime": "Lei 14.133/2021",
                "estimated_total_brl": 4850000.00,
                "reference_painel_precos_brl": 3895582.33,
                "overpricing_index_pct": 24.5,
                "restrictive_clauses": ["Exigência de marca exclusiva sem justificativa técnica"],
                "mp_hitl_approval_id": "HITL-MP-2026-001",
                "audited_at": now_iso,
            }
        ],
        "gdp_vitalis_saude.rnds_sisreg_regulacao_leitos_pcdt": [
            {
                "tenant_id": "sus-ms",
                "macroregion_code": "BR-SP-MACRO-01",
                "cnes_facility_id": "CNES-2077485",
                "icu_beds_available": 14,
                "pcdt_protocol_id": "MS-PCDT-SEPSE-DENGUE-2025",
                "cid10_code": "A90",
                "contraindicated_substances": ["Ibuprofeno", "Ácido Acetilsalicílico", "Diclofenaco"],
                "validating_physician_crm": "CRM-SP-123456",
                "snapshot_at": now_iso,
            }
        ],
        "gdp_sophia_educacao.inep_censo_busca_ativa_bncc": [
            {
                "tenant_id": "mec-inep",
                "inep_school_id": "INEP-53001089",
                "student_pseudo_id": "ALUNO-PSEUDO-7721",
                "student_age_years": 12,
                "bncc_stage": "ENSINO_FUNDAMENTAL_ANOS_FINAIS",
                "bncc_skill_codes": ["EF06MA01", "EF67LP08"],
                "attendance_rate_pct": 81.5,
                "dropout_risk_tier": "MODERATE",
                "evaluated_at": now_iso,
            }
        ],
        "gdp_gaiaguard_ambiente.sicar_prodes_deter_telemetria_satelite": [
            {
                "tenant_id": "mma-ibama",
                "car_registry_code": "MT-5107925-VALID-001",
                "biome": "CERRADO",
                "polygon_geom": "POLYGON((-55.7 -12.5, -55.6 -12.5, -55.6 -12.6, -55.7 -12.6, -55.7 -12.5))",
                "declared_native_vegetation_ha": 180.0,
                "satellite_observed_native_vegetation_ha": 180.0,
                "declared_deforestation_post_2008_ha": 0.0,
                "satellite_deforestation_post_2008_ha": 0.0,
                "ibama_active_embargo": False,
                "ndvi_mean_score": 0.78,
                "earth_engine_scene_id": "COPERNICUS/S2_SR_HARMONIZED/20261015T1348_T21LXG",
                "observed_at": now_iso,
            }
        ],
        "gdp_agronexo_agricultura.sicor_zarc_credito_rural_conformidade": [
            {
                "tenant_id": "mapa-bcb",
                "operation_id": "SICOR-2026-99881",
                "car_registry_code": "MT-5107925-VALID-001",
                "municipality_ibge": "5107925",
                "crop_code": "SOJA",
                "planting_window_month": 11,
                "zarc_approved_months": [10, 11, 12],
                "app_or_reserva_legal_overlap": False,
                "ibama_embargo_verified": False,
                "credit_status": "APPROVED",
                "analyzed_at": now_iso,
            }
        ],
    }


if __name__ == "__main__":
    bundle = generate_sectoral_synthetic_bundle()
    print(json.dumps({k: len(v) for k, v in bundle.items()}, indent=2))
