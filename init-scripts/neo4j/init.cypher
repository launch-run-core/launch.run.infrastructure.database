// launch.run Neo4j — graph database initialization
// Used for: trust graph, fraud rings, recommendation graph, social connections

// Constraints
CREATE CONSTRAINT user_id_unique IF NOT EXISTS FOR (u:User) REQUIRE u.id IS UNIQUE;
CREATE CONSTRAINT listing_id_unique IF NOT EXISTS FOR (l:Listing) REQUIRE l.id IS UNIQUE;
CREATE CONSTRAINT seller_id_unique IF NOT EXISTS FOR (s:Seller) REQUIRE s.id IS UNIQUE;

// Indexes for traversal performance
CREATE INDEX user_city IF NOT EXISTS FOR (u:User) ON (u.city);
CREATE INDEX listing_app IF NOT EXISTS FOR (l:Listing) ON (l.app_id);
CREATE INDEX trust_score IF NOT EXISTS FOR (u:User) ON (u.trust_score);

// Node types:
// (:User {id, city, trust_score, created_at})
// (:Seller {id, rating, listings_count, verified})
// (:Listing {id, app_id, category, price, quality_score})
// (:Device {fingerprint, platform})
// (:IP {address, country})
// (:PhoneNumber {hash})

// Relationship types:
// (User)-[:TRANSACTED_WITH {amount, at}]->(Seller)
// (User)-[:VIEWED]->(Listing)
// (User)-[:WISHLISTED]->(Listing)
// (User)-[:REFERRED]->(User)
// (User)-[:USES]->(Device)
// (User)-[:LOGGED_IN_FROM]->(IP)
// (Seller)-[:LISTED]->(Listing)
// (User)-[:FLAGGED_BY {reason}]->(Listing)

RETURN 'Neo4j initialized' AS status;
