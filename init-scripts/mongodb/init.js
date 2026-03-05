// Forja MongoDB — document store initialization
// Used for: vertical configs, dynamic attributes, CMS, A/B test configs

db = db.getSiblingDB('forja');

// Collections
db.createCollection('vertical_configs');
db.createCollection('micro_app_configs');
db.createCollection('dynamic_attributes');
db.createCollection('ab_test_configs');
db.createCollection('feature_flags');
db.createCollection('cms_content');
db.createCollection('agent_prompts');
db.createCollection('knowledge_base');

// Indexes
db.vertical_configs.createIndex({ app_id: 1 }, { unique: true });
db.micro_app_configs.createIndex({ micro_app_id: 1 }, { unique: true });
db.dynamic_attributes.createIndex({ app_id: 1, category: 1 });
db.ab_test_configs.createIndex({ experiment_id: 1 }, { unique: true });
db.feature_flags.createIndex({ flag_key: 1 }, { unique: true });
db.knowledge_base.createIndex({ entity_type: 1, entity_id: 1 });

print('MongoDB forja database initialized');
