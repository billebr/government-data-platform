-- ============================================================================
-- PR #1: Sectoral Data Foundations for Google Cloud Agentic Data Cloud
-- Repository: https://github.com/GoogleCloudPlatform/government-data-platform
-- Covers all 8 Specialized Subagent Domains with Partitioning, Clustering,
-- Dataplex Policy Tags (CLS), and Row-Level Access Policies (RLS).
-- ============================================================================

-- 1. CIVITAS (Cidadania / Serviços ao Cidadão)
CREATE SCHEMA IF NOT EXISTS `gdp_civitas_cidadania`
OPTIONS(location="southamerica-east1", description="Dados governados de Cidadania e Proteção Social (CadÚnico / Gov.br)");

CREATE TABLE IF NOT EXISTS `gdp_civitas_cidadania.cadunico_beneficios_pseudonimizados` (
  tenant_id STRING NOT NULL OPTIONS(description="Identificador do ente federativo/órgão"),
  family_nis_hash STRING NOT NULL OPTIONS(description="Hash SHA-256 salgado do NIS familiar"),
  citizen_cpf_pseudo STRING NOT NULL OPTIONS(description="Pseudônimo determinístico LGPD do CPF"),
  ibge_municipality_code STRING NOT NULL,
  per_capita_income_brl NUMERIC NOT NULL,
  eligible_programs ARRAY<STRING>,
  lgpd_legal_basis STRING NOT NULL OPTIONS(description="Art. 7º III ou Art. 23 da Lei 13.709/2018"),
  consent_token_hash STRING,
  updated_at TIMESTAMP NOT NULL
)
PARTITION BY DATE(updated_at)
CLUSTER BY tenant_id, ibge_municipality_code;

CREATE ROW ACCESS POLICY IF NOT EXISTS rls_civitas_tenant_lgpd
ON `gdp_civitas_cidadania.cadunico_beneficios_pseudonimizados`
GRANT TO ("group:gov-harness-civitas-agents@gov.br")
FILTER USING (tenant_id = SESSION_USER() OR tenant_id LIKE "gov-br-%");

-- 2. AEGISGOV (Segurança Pública)
CREATE SCHEMA IF NOT EXISTS `gdp_aegis_seguranca`
OPTIONS(location="southamerica-east1", description="Inteligência Integrada e Cadeia de Custódia Multimodal (SINESP)");

CREATE TABLE IF NOT EXISTS `gdp_aegis_seguranca.ocorrencias_cadeia_custodia_multimodal` (
  tenant_id STRING NOT NULL,
  evidence_id STRING NOT NULL,
  operation_corridor STRING NOT NULL,
  media_type STRING NOT NULL OPTIONS(description="text | audio | image | video | geospatial"),
  evidence_sha256 STRING NOT NULL OPTIONS(description="Hash SHA-256 obrigatório (Art. 158-A CPP)"),
  collector_badge_id STRING NOT NULL,
  origin_system STRING NOT NULL,
  geolocation GEOGRAPHY,
  embedding ARRAY<FLOAT64> OPTIONS(description="Embedding multimodal Vertex AI"),
  collected_at TIMESTAMP NOT NULL
)
PARTITION BY DATE(collected_at)
CLUSTER BY tenant_id, operation_corridor;

-- 3. LEXVERITAS (Justiça e Tribunais)
CREATE SCHEMA IF NOT EXISTS `gdp_lexveritas_justica`
OPTIONS(location="southamerica-east1", description="Base Oficial de Jurisprudência e Precedentes Vinculantes (CNJ DataJud)");

CREATE TABLE IF NOT EXISTS `gdp_lexveritas_justica.datajud_acordaos_precedentes_oficiais` (
  tenant_id STRING NOT NULL,
  citation_id STRING NOT NULL OPTIONS(description="ID canônico ex: STF-TEMA-1022-RE-688267"),
  court_code STRING NOT NULL OPTIONS(description="STF | STJ | TRF | TJ"),
  precedent_type STRING NOT NULL OPTIONS(description="ACORDAO | SUMULA | TEMA_REPERCUSSAO_GERAL"),
  official_uri STRING NOT NULL,
  ementa_verbatim STRING NOT NULL,
  embedding ARRAY<FLOAT64>,
  published_at DATE NOT NULL
)
PARTITION BY published_at
CLUSTER BY court_code, citation_id;

-- 4. CUSTOSLEGIS (Ministério Público)
CREATE SCHEMA IF NOT EXISTS `gdp_custoslegis_mp`
OPTIONS(location="southamerica-east1", description="Auditoria de Editais de Licitação, Contratos (PNCP) e Inquéritos Civis");

CREATE TABLE IF NOT EXISTS `gdp_custoslegis_mp.pncp_editais_contratos_auditoria` (
  tenant_id STRING NOT NULL,
  edital_id STRING NOT NULL,
  contracting_agency_uasg STRING NOT NULL,
  legal_regime STRING NOT NULL OPTIONS(description="Lei 14.133/2021"),
  estimated_total_brl NUMERIC NOT NULL,
  reference_painel_precos_brl NUMERIC NOT NULL,
  overpricing_index_pct FLOAT64 NOT NULL,
  restrictive_clauses ARRAY<STRING>,
  mp_hitl_approval_id STRING OPTIONS(description="Assinatura digital obrigatória do Membro do MP"),
  audited_at TIMESTAMP NOT NULL
)
PARTITION BY DATE(audited_at)
CLUSTER BY tenant_id, contracting_agency_uasg;

-- 5. VITALISGOV (Saúde Pública / SUS)
CREATE SCHEMA IF NOT EXISTS `gdp_vitalis_saude`
OPTIONS(location="southamerica-east1", description="Regulação de Filas (SISREG), RNDS e Protocolos Clínicos PCDT/MS");

CREATE TABLE IF NOT EXISTS `gdp_vitalis_saude.rnds_sisreg_regulacao_leitos_pcdt` (
  tenant_id STRING NOT NULL,
  macroregion_code STRING NOT NULL,
  cnes_facility_id STRING NOT NULL,
  icu_beds_available INT64 NOT NULL,
  pcdt_protocol_id STRING NOT NULL,
  cid10_code STRING NOT NULL,
  contraindicated_substances ARRAY<STRING>,
  validating_physician_crm STRING NOT NULL,
  snapshot_at TIMESTAMP NOT NULL
)
PARTITION BY DATE(snapshot_at)
CLUSTER BY tenant_id, macroregion_code;

-- 6. SOPHIAEDU (Educação Pública)
CREATE SCHEMA IF NOT EXISTS `gdp_sophia_educacao`
OPTIONS(location="southamerica-east1", description="Gestão Pedagógica, Busca Ativa Escolar (INEP) e Diretrizes BNCC");

CREATE TABLE IF NOT EXISTS `gdp_sophia_educacao.inep_censo_busca_ativa_bncc` (
  tenant_id STRING NOT NULL,
  inep_school_id STRING NOT NULL,
  student_pseudo_id STRING NOT NULL,
  student_age_years INT64 NOT NULL,
  bncc_stage STRING NOT NULL,
  bncc_skill_codes ARRAY<STRING>,
  attendance_rate_pct FLOAT64 NOT NULL,
  dropout_risk_tier STRING NOT NULL,
  evaluated_at TIMESTAMP NOT NULL
)
PARTITION BY DATE(evaluated_at)
CLUSTER BY tenant_id, bncc_stage;

-- 7. GAIAGUARD (Meio Ambiente)
CREATE SCHEMA IF NOT EXISTS `gdp_gaiaguard_ambiente`
OPTIONS(location="southamerica-east1", description="Licenciamento Ambiental, SICAR e Telemetria Earth Engine / PRODES / DETER");

CREATE TABLE IF NOT EXISTS `gdp_gaiaguard_ambiente.sicar_prodes_deter_telemetria_satelite` (
  tenant_id STRING NOT NULL,
  car_registry_code STRING NOT NULL,
  biome STRING NOT NULL,
  polygon_geom GEOGRAPHY NOT NULL,
  declared_native_vegetation_ha FLOAT64 NOT NULL,
  satellite_observed_native_vegetation_ha FLOAT64 NOT NULL,
  declared_deforestation_post_2008_ha FLOAT64 NOT NULL,
  satellite_deforestation_post_2008_ha FLOAT64 NOT NULL,
  ibama_active_embargo BOOL NOT NULL,
  ndvi_mean_score FLOAT64 NOT NULL,
  earth_engine_scene_id STRING NOT NULL,
  observed_at TIMESTAMP NOT NULL
)
PARTITION BY DATE(observed_at)
CLUSTER BY biome, car_registry_code;

-- 8. AGRONEXO (Agricultura e Crédito Rural)
CREATE SCHEMA IF NOT EXISTS `gdp_agronexo_agricultura`
OPTIONS(location="southamerica-east1", description="Crédito Rural (SICOR / Plano Safra), ZARC/MAPA e Conformidade Agroambiental");

CREATE TABLE IF NOT EXISTS `gdp_agronexo_agricultura.sicor_zarc_credito_rural_conformidade` (
  tenant_id STRING NOT NULL,
  operation_id STRING NOT NULL,
  car_registry_code STRING NOT NULL OPTIONS(description="Chave estrangeira compartilhada em sinergia com GaiaGuard"),
  municipality_ibge STRING NOT NULL,
  crop_code STRING NOT NULL,
  planting_window_month INT64 NOT NULL,
  zarc_approved_months ARRAY<INT64>,
  app_or_reserva_legal_overlap BOOL NOT NULL,
  ibama_embargo_verified BOOL NOT NULL,
  credit_status STRING NOT NULL,
  analyzed_at TIMESTAMP NOT NULL
)
PARTITION BY DATE(analyzed_at)
CLUSTER BY municipality_ibge, crop_code;
