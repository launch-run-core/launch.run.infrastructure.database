# launch.run.infrastructure.database

Database infrastructure for the Launch Run platform. Contains Docker Compose configurations and initialization scripts for all database services.

## Databases

| Database | Version | Port | Purpose |
|----------|---------|------|---------|
| PostgreSQL | 16 | 5432 | Primary relational store (services use schema isolation) |
| Redis (cache) | 7 | 6379 | General caching with allkeys-lru eviction |
| Redis (sessions) | 7 | 6380 | Session storage with allkeys-lru eviction |
| Redis (pub/sub) | 7 | 6381 | Pub/sub messaging with noeviction policy |
| ClickHouse | 24 | 8123 (HTTP), 9010 (TCP) | Analytics and event storage |
| MongoDB | 7 | 27017 | Document store (configs, CMS, feature flags) |
| Neo4j | 5 | 7474 (UI), 7687 (Bolt) | Graph database (trust, fraud, recommendations) |
| Elasticsearch | 8.14 | 9200 | Full-text search |
| Qdrant | 1.9 | 6333 (REST), 6334 (gRPC) | Vector database for embeddings |
| TimescaleDB | latest (PG16) | 5433 | Time-series data (prices, metrics, IoT) |
| ScyllaDB | 6.0 | 9042 (CQL), 9160 (Thrift) | Wide-column store (feeds, notifications, bids) |

## Quick Start

### Start all databases

```bash
docker compose up -d
```

### Start specific databases

```bash
docker compose up -d postgres redis mongodb
```

### Check health

```bash
docker compose ps
```

### Connect to PostgreSQL

```bash
docker compose exec postgres psql -U launch.run -d launch.run
```

### Connect to MongoDB

```bash
docker compose exec mongodb mongosh -u launch.run -p launch.run --authenticationDatabase admin launch.run
```

### Connect to ClickHouse

```bash
docker compose exec clickhouse clickhouse-client --user launch.run --password launch.run
```

### Connect to Neo4j

Open http://localhost:7474 in your browser. Credentials: `neo4j` / `launch.runlaunch.run`

### Stop all databases

```bash
docker compose down
```

### Reset all data

```bash
docker compose down -v
```

## Structure

```
docker-compose.yml              All database service definitions
config/                         Database-specific configuration files
init-scripts/
  postgres/init.sql             Schema isolation (per-service schemas)
  clickhouse/init.sql           Event analytics table
  mongodb/init.js               Collections and indexes
  neo4j/init.cypher             Graph constraints and indexes
  timescaledb/init.sql          Hypertables for time-series data
  scylladb/init.cql             Keyspace, tables for feeds/notifications/bids
```

## Default Credentials

All databases use development credentials:

| Database | User | Password |
|----------|------|----------|
| PostgreSQL | launch-run | launch-run |
| ClickHouse | launch-run | launch-run |
| MongoDB | launch-run | launch-run |
| Neo4j | neo4j | launch-runlaunch.run |
| TimescaleDB | launch-run | launch-run |

**WARNING**: These credentials are for local development only. Production credentials are managed via Kubernetes Secrets and Terraform.

## Init Scripts

### PostgreSQL
Creates isolated schemas for each microservice: `users`, `listings`, `transactions`, `reviews`, `notifications`, `intelligence`, `media`, `config`.

### ClickHouse
Creates the `launch.run.event` table partitioned by month with 2-year TTL for analytics events.

### MongoDB
Initializes collections (`vertical_configs`, `micro_app_configs`, `dynamic_attributes`, `ab_test_configs`, `feature_flags`, `cms_content`, `agent_prompts`, `knowledge_base`) with indexes.

### Neo4j
Creates uniqueness constraints and indexes for `User`, `Listing`, and `Seller` nodes with relationship types for transactions, views, referrals, and fraud detection.

### TimescaleDB
Creates hypertables for `price_history`, `platform_metrics`, `search_volume`, `agent_latency`, and `iot_readings` with a continuous aggregate for hourly price stats.

### ScyllaDB
Creates tables for `activity_feed`, `notification_history`, `auction_bids`, `search_log`, and `session_events` with appropriate TTLs and clustering orders.
