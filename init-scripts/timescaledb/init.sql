-- Forja TimescaleDB — timeseries database initialization
-- Used for: price history, platform metrics, IoT (agri/solar), SLA tracking

CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Price history — track listing price changes over time
CREATE TABLE price_history (
    time        TIMESTAMPTZ NOT NULL,
    listing_id  UUID        NOT NULL,
    app_id      TEXT        NOT NULL,
    price       BIGINT      NOT NULL,
    currency    TEXT        NOT NULL DEFAULT 'INR'
);
SELECT create_hypertable('price_history', 'time');
CREATE INDEX ON price_history (listing_id, time DESC);

-- Platform metrics — counters and gauges
CREATE TABLE platform_metrics (
    time        TIMESTAMPTZ NOT NULL,
    service     TEXT        NOT NULL,
    metric_name TEXT        NOT NULL,
    value       DOUBLE PRECISION NOT NULL,
    labels      JSONB
);
SELECT create_hypertable('platform_metrics', 'time');
CREATE INDEX ON platform_metrics (service, metric_name, time DESC);

-- Search volume — queries per minute per vertical
CREATE TABLE search_volume (
    time        TIMESTAMPTZ NOT NULL,
    app_id      TEXT        NOT NULL,
    query_count BIGINT      NOT NULL,
    unique_users BIGINT     NOT NULL
);
SELECT create_hypertable('search_volume', 'time');

-- Agent latency tracking
CREATE TABLE agent_latency (
    time        TIMESTAMPTZ NOT NULL,
    agent_name  TEXT        NOT NULL,
    latency_ms  DOUBLE PRECISION NOT NULL,
    success     BOOLEAN     NOT NULL,
    model_used  TEXT
);
SELECT create_hypertable('agent_latency', 'time');
CREATE INDEX ON agent_latency (agent_name, time DESC);

-- IoT sensor data (agriculture, solar)
CREATE TABLE iot_readings (
    time        TIMESTAMPTZ NOT NULL,
    device_id   UUID        NOT NULL,
    app_id      TEXT        NOT NULL,
    sensor_type TEXT        NOT NULL,
    value       DOUBLE PRECISION NOT NULL,
    unit        TEXT        NOT NULL,
    metadata    JSONB
);
SELECT create_hypertable('iot_readings', 'time');

-- Continuous aggregates for dashboard
CREATE MATERIALIZED VIEW price_history_hourly
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', time) AS bucket,
       app_id,
       AVG(price) AS avg_price,
       MIN(price) AS min_price,
       MAX(price) AS max_price,
       COUNT(*) AS changes
FROM price_history
GROUP BY bucket, app_id
WITH NO DATA;
