# ============================================================================
# PR #2: Semantic Layer & Agent Governance (Dataplex & Data Catalog)
# Repository: https://github.com/GoogleCloudPlatform/government-data-platform
# Configures Dataplex Lakes, Sectoral Curated Zones, Business Glossary, and
# Fine-Grained Policy Tags (Column-Level Masking for LGPD PII).
# ============================================================================

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

variable "project_id" {
  type    = string
  default = "gcp-gov-agentic-data-cloud-prod"
}

variable "region" {
  type    = string
  default = "southamerica-east1"
}

# 1. Unified Government Agentic Data Lake in Dataplex
resource "google_dataplex_lake" "gov_agentic_data_lake" {
  name         = "gov-agentic-data-cloud-lake"
  location     = var.region
  project      = var.project_id
  display_name = "Government Agentic Data Cloud Lake (8 Subagent Domains)"
  description  = "Camada semântica e governança Dataplex para o AI Agent Harness for Government"
}

# 2. Curated Sectoral Zones for Agentic Consumption
resource "google_dataplex_zone" "curated_sectoral_zone" {
  name         = "curated-gov-sectoral-zone"
  lake         = google_dataplex_lake.gov_agentic_data_lake.name
  location     = var.region
  project      = var.project_id
  type         = "CURATED"
  display_name = "Curated Sectoral Zone (LGPD, Chain of Custody, DataJud, PCDT, BNCC, CAR/ZARC)"

  discovery_spec {
    enabled = true
  }

  resource_spec {
    location_type = "SINGLE_REGION"
  }
}

# 3. Data Catalog Policy Tag Taxonomy for Fine-Grained Column-Level ACLs (LGPD)
resource "google_data_catalog_taxonomy" "lgpd_gov_taxonomy" {
  region                 = var.region
  project                = var.project_id
  display_name           = "Taxonomia Governamental LGPD e Sigilo Legal"
  description            = "Políticas de acesso em nível de coluna para subagentes governamentais"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
}

resource "google_data_catalog_policy_tag" "pii_sensivel_lgpd" {
  taxonomy     = google_data_catalog_taxonomy.lgpd_gov_taxonomy.id
  display_name = "LGPD_DADO_PESSOAL_SENSIVEL_ART_11"
  description  = "Dados pessoais sensíveis (Saúde/RNDS, Criança/Adolescente ECA, Benefícios Sociais)"
}

resource "google_data_catalog_policy_tag" "sigilo_investigativo_cpp" {
  taxonomy     = google_data_catalog_taxonomy.lgpd_gov_taxonomy.id
  display_name = "SIGILO_INVESTIGATIVO_CADEIA_CUSTODIA"
  description  = "Evidências multimodais sob cadeia de custódia (AegisGov /CustosLegis)"
}
