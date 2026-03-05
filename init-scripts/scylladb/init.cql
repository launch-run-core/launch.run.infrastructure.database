-- Forja ScyllaDB — wide-column store initialization
-- Used for: activity feeds, notification history, real-time auction events

CREATE KEYSPACE IF NOT EXISTS forja
    WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}
    AND durable_writes = true;

USE forja;

-- Activity feed (reverse-chronological, partitioned by user)
CREATE TABLE IF NOT EXISTS activity_feed (
    user_id     UUID,
    created_at  TIMEUUID,
    event_type  TEXT,
    entity_id   UUID,
    entity_type TEXT,
    payload     TEXT,  -- JSON
    PRIMARY KEY (user_id, created_at)
) WITH CLUSTERING ORDER BY (created_at DESC)
  AND default_time_to_live = 2592000;  -- 30 days TTL

-- Notification history
CREATE TABLE IF NOT EXISTS notification_history (
    user_id        UUID,
    sent_at        TIMEUUID,
    channel        TEXT,  -- push, email, sms, in_app
    notification_id UUID,
    title          TEXT,
    body           TEXT,
    read_at        TIMESTAMP,
    PRIMARY KEY (user_id, sent_at)
) WITH CLUSTERING ORDER BY (sent_at DESC)
  AND default_time_to_live = 7776000;  -- 90 days TTL

-- Auction bid stream (high-write, partition by auction)
CREATE TABLE IF NOT EXISTS auction_bids (
    auction_id  UUID,
    bid_at      TIMEUUID,
    bidder_id   UUID,
    amount      BIGINT,
    currency    TEXT,
    status      TEXT,
    PRIMARY KEY (auction_id, bid_at)
) WITH CLUSTERING ORDER BY (bid_at DESC);

-- Search query log (analytics)
CREATE TABLE IF NOT EXISTS search_log (
    app_id      TEXT,
    date_bucket DATE,
    logged_at   TIMEUUID,
    user_id     UUID,
    query       TEXT,
    results     INT,
    clicked_id  UUID,
    PRIMARY KEY ((app_id, date_bucket), logged_at)
) WITH CLUSTERING ORDER BY (logged_at DESC)
  AND default_time_to_live = 604800;  -- 7 days

-- User session events
CREATE TABLE IF NOT EXISTS session_events (
    session_id  UUID,
    occurred_at TIMEUUID,
    event_type  TEXT,
    payload     TEXT,
    PRIMARY KEY (session_id, occurred_at)
) WITH CLUSTERING ORDER BY (occurred_at ASC)
  AND default_time_to_live = 86400;  -- 24h
