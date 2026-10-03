# LA Referencia Harvester Application

Web application for OAI-PMH metadata harvesting, validation, transformation,
entity extraction and publication.

## 🎯 Functionality

### Network Management
Configure and manage national repository networks, harvesting schedules, validation rules, and transformation pipelines.

### OAI-PMH Harvesting
Full and incremental harvesting with multiple metadata formats, automatic retry, and comprehensive logging. Since 2026-09-04 the catalog tracks per-record changes (`oai_record.change_type` `N`/`U`/`D`) enabling incremental harvesting, validation and indexing.

### Metadata Processing
Validation rule engine, field transformation, entity extraction, and SQLite-backed validation statistics (incremental validation reuse via fingerprint + manifest).

### Indexing
Elasticsearch/OpenSearch indexing for search and entity relationship tracking (see [`docs/ENTITY_INDEXING_ARCHITECTURE.md`](../docs/ENTITY_INDEXING_ARCHITECTURE.md)).

### Web Interface
- **React Admin Web** (from `lareferencia-lrharvester-admin-web`) is served at the root of port `8090` (built into `static/`).
- **API v5** under `/api/v5` (OpenAPI at `/api/v5/openapi`, Swagger at `/api/v5/docs`). React is the only web UI; legacy UI and Spring Data REST are not exposed.
- **Identity**: local PostgreSQL users, JDBC web sessions with CSRF, and revocable repository-scoped Bearer tokens for service accounts. Bootstrap the first admin from `lareferencia-shell` after `database_migrate`; see the [authentication runbook](../docs/AUTHENTICATION.md).
- Multi-language UI: Spanish, English and Portuguese (`config/i18n/messages_*.properties`).

## 📄 License

Licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.  
See [LICENSE.txt](../LICENSE.txt) for complete terms.

## 📧 Support

**Email**: soporte@lareferencia.redclara.net

---

**LA Referencia** - Red Latinoamericana y de España de Ciencia Abierta  
Part of the LA Referencia Platform 5.0.0-rc3
