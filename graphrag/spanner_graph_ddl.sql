-- ============================================================================
-- PR #3: Institutional GraphRAG & Vector Search Infrastructure
-- Repository: https://github.com/GoogleCloudPlatform/government-data-platform
-- Implements Spanner Graph (`GovKnowledgeGraph`) for relational + semantic
-- retrieval across Legislation, Jurisprudence, Clinical Protocols, BNCC, and CAR.
-- ============================================================================

CREATE TABLE LegalAndTechnicalNode (
  node_id STRING(128) NOT NULL,
  sector_domain STRING(64) NOT NULL,
  node_type STRING(64) NOT NULL, -- LEGISLATION | ACORDAO | SUMULA | PCDT_PROTOCOL | BNCC_SKILL
  title STRING(512) NOT NULL,
  official_uri STRING(1024) NOT NULL,
  verbatim_content STRING(MAX) NOT NULL,
  content_sha256 STRING(64) NOT NULL,
  text_embedding ARRAY<FLOAT32>(vector_length=>768),
  updated_at TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true)
) PRIMARY KEY (node_id);

CREATE TABLE NormativeRelationshipEdge (
  source_node_id STRING(128) NOT NULL,
  target_node_id STRING(128) NOT NULL,
  relationship_type STRING(64) NOT NULL, -- REGULATES | CITES_PRECEDENT | DEPENDS_ON_GEOSPATIAL | SUPERSEDES
  effective_since DATE NOT NULL,
  CONSTRAINT FK_SourceNode FOREIGN KEY (source_node_id) REFERENCES LegalAndTechnicalNode (node_id),
  CONSTRAINT FK_TargetNode FOREIGN KEY (target_node_id) REFERENCES LegalAndTechnicalNode (node_id)
) PRIMARY KEY (source_node_id, target_node_id, relationship_type);

CREATE PROPERTY GRAPH GovKnowledgeGraph
  NODE TABLES (
    LegalAndTechnicalNode
      KEY (node_id)
      LABEL NormativeEntity
      PROPERTIES (node_id, sector_domain, node_type, title, official_uri, verbatim_content, text_embedding)
  )
  EDGE TABLES (
    NormativeRelationshipEdge
      KEY (source_node_id, target_node_id, relationship_type)
      SOURCE KEY (source_node_id) REFERENCES LegalAndTechnicalNode (node_id)
      DESTINATION KEY (target_node_id) REFERENCES LegalAndTechnicalNode (node_id)
      LABEL RELATES_TO
      PROPERTIES (relationship_type, effective_since)
  );
