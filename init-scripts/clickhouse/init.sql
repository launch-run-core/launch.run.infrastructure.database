CREATE DATABASE IF NOT EXISTS launch_run;

CREATE TABLE IF NOT EXISTS launch_run.event (
    event_id    UUID,
    app_id      LowCardinality(String),
    user_id     Nullable(UUID),
    session_id  Nullable(String),
    event_type  LowCardinality(String),
    event_data  String,
    device_type LowCardinality(String),
    city        LowCardinality(Nullable(String)),
    created_at  DateTime64(3)
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(created_at)
ORDER BY (app_id, event_type, created_at)
TTL created_at + INTERVAL 2 YEAR;
