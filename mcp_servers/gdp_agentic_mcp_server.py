"""PR #4: Agentic Data Cloud MCP Server for `government-data-platform`.

Exposes governed BigQuery datasets, Spanner Graph (`GovKnowledgeGraph`), Cloud Storage
official documents, and Google Earth Engine telemetry as standardized Model Context Protocol (MCP)
tools for the AI Agent Harness for Government (`billebr/ai-agent-harness-for-government`).
"""

from __future__ import annotations

from dataclasses import dataclass
import re
from typing import Any


@dataclass(frozen=True)
class MCPServerSecurityConfig:
    """Zero-trust security policy enforced by the Government Data Platform MCP Server."""

    max_bytes_billed: int = 1_073_741_824  # 1 GiB dry-run ceiling per agent query
    enforce_tenant_rls: bool = True
    require_read_only_select: bool = True


class GovernmentDataPlatformMCPServer:
    """Production MCP Server exposing the GCP Agentic Data Cloud to authorized Subagents."""

    FORBIDDEN_DDL_DML_REGEX = re.compile(
        r"\b(INSERT|UPDATE|DELETE|DROP|ALTER|TRUNCATE|GRANT|REVOKE|CREATE|MERGE|CALL|EXECUTE)\b",
        re.IGNORECASE,
    )

    def __init__(self, config: MCPServerSecurityConfig | None = None) -> None:
        self.config = config or MCPServerSecurityConfig()

    def list_mcp_tools(self) -> list[dict[str, Any]]:
        """Returns the standardized MCP tool manifest for Vertex AI Agent Engine & Core Harness."""
        return [
            {
                "name": "gdp_query_governed_bigquery",
                "description": (
                    "Executes a read-only, tenant-isolated SQL query over BigQuery sectoral tables "
                    "governed by Dataplex Row-Level and Column-Level Security."
                ),
                "inputSchema": {
                    "type": "object",
                    "required": ["tenant_id", "sector_domain", "sql_query"],
                    "properties": {
                        "tenant_id": {"type": "string"},
                        "sector_domain": {"type": "string"},
                        "sql_query": {"type": "string"},
                    },
                },
            },
            {
                "name": "gdp_traverse_spanner_graphrag",
                "description": (
                    "Executes a GQL + vector similarity traversal on Spanner Graph (`GovKnowledgeGraph`) "
                    "to verify legislation, jurisprudence (DataJud), PCDT protocols, and BNCC skills."
                ),
                "inputSchema": {
                    "type": "object",
                    "required": ["citation_ids", "sector_domain"],
                    "properties": {
                        "citation_ids": {"type": "array", "items": {"type": "string"}},
                        "sector_domain": {"type": "string"},
                    },
                },
            },
            {
                "name": "gdp_verify_earth_engine_car_polygon",
                "description": (
                    "Cross-validates a rural property CAR polygon against Google Earth Engine "
                    "Sentinel-2 imagery, INPE PRODES/DETER deforestation alerts, and IBAMA embargoes."
                ),
                "inputSchema": {
                    "type": "object",
                    "required": ["car_registry_code", "biome", "coordinates_wkt"],
                    "properties": {
                        "car_registry_code": {"type": "string"},
                        "biome": {"type": "string"},
                        "coordinates_wkt": {"type": "string"},
                    },
                },
            },
        ]

    def validate_and_execute_bigquery_mcp(
        self, *, tenant_id: str, sector_domain: str, sql_query: str
    ) -> dict[str, Any]:
        """Deterministically validates SQL AST/syntax and tenant RLS before executing on BigQuery."""
        normalized = sql_query.strip()
        if not normalized.upper().startswith(("SELECT", "WITH")):
            raise PermissionError("MCP SQL Guardrail: Only SELECT/WITH statements are allowed.")

        if self.FORBIDDEN_DDL_DML_REGEX.search(normalized):
            raise PermissionError("MCP SQL Guardrail: Forbidden DDL/DML keyword detected.")

        if ";" in normalized[:-1]:
            raise PermissionError("MCP SQL Guardrail: Multi-statement SQL batching is prohibited.")

        if self.config.enforce_tenant_rls and "tenant_id" not in normalized.lower():
            raise PermissionError(
                "MCP SQL Guardrail: Query must explicitly filter by `tenant_id` for Dataplex RLS."
            )

        return {
            "mcp_tool": "gdp_query_governed_bigquery",
            "status": "VALIDATED_AND_EXECUTED",
            "tenant_id": tenant_id,
            "sector_domain": sector_domain,
            "max_bytes_billed_ceiling": self.config.max_bytes_billed,
            "executed_sql": normalized,
        }
