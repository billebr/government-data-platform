# Pacote de Pull Requests (PRs #1 a #4) — Evolução para Google Cloud Agentic Data Cloud

**Repositório Alvo**: [`https://github.com/GoogleCloudPlatform/government-data-platform`](https://github.com/GoogleCloudPlatform/government-data-platform)  
**Repositório Consumidor (Core Harness)**: [`https://github.com/billebr/ai-agent-harness-for-government`](https://github.com/billebr/ai-agent-harness-for-government)

Este diretório contém a especificação técnica detalhada e os artefatos de código (SQL BigQuery DDL, Spanner Graph DDL, Terraform Dataplex e Python MCP Server) divididos em **4 Pull Requests modulares** para transformar o `government-data-platform` em uma fundação completa de **Agentic Data Cloud**.

| Pull Request | Título Formal do PR | Arquivos Incluídos | Subagentes Atendidos |
| :--- | :--- | :--- | :--- |
| **PR #1** | `feat(schemas): add 8 sectoral BigQuery schemas, RLS policies, and synthetic data generator` | `schemas/bigquery/01_sectoral_domains_ddl.sql`, `pipelines/synthetic_data_generator.py` | Todos os 8 (`Civitas`, `AegisGov`, `LexVeritas`, `CustosLegis`, `VitalisGov`, `SophiaEdu`, `GaiaGuard`, `AgroNexo`) |
| **PR #2** | `feat(dataplex): configure Agentic Data Cloud semantic layer, LGPD taxonomy, and fine-grained ACLs` | `terraform/dataplex_governance/main.tf` | Todos os 8 (Governança LGPD, Sigilo Investigativo CPP e RLS/CLS) |
| **PR #3** | `feat(graphrag): add Spanner Graph GovKnowledgeGraph DDL and Vertex AI Vector Search pipelines` | `graphrag/spanner_graph_ddl.sql` | `LexVeritas`, `CustosLegis`, `VitalisGov`, `SophiaEdu`, `Civitas` |
| **PR #4** | `feat(mcp): expose governed BigQuery, Spanner Graph, and Earth Engine via zero-trust MCP Server` | `mcp_servers/gdp_agentic_mcp_server.py` | Todos os 8 via `MCPToolBus` e Vertex AI Agent Engine |
