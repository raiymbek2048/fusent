-- Analytics events table for tracking user interactions
CREATE TABLE IF NOT EXISTS analytics_event (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Event type: product_view, post_view, shop_view, add_to_cart, purchase, click, search
    event_type VARCHAR(50) NOT NULL,

    -- Who triggered the event (nullable for anonymous)
    user_id UUID REFERENCES app_user(id),

    -- Target entity (what was viewed/clicked)
    target_type VARCHAR(30), -- PRODUCT, POST, SHOP, CATEGORY
    target_id UUID,

    -- Owner of the target (for seller analytics)
    owner_type VARCHAR(30), -- USER, MERCHANT
    owner_id UUID,

    -- Additional event data (JSON)
    event_data JSONB,

    -- Session tracking
    session_id VARCHAR(100),
    device_type VARCHAR(20), -- MOBILE, WEB, TABLET
    platform VARCHAR(20), -- IOS, ANDROID, WEB

    -- Location (optional)
    ip_address VARCHAR(45),
    country VARCHAR(2),
    city VARCHAR(100),

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Indexes for analytics queries
CREATE INDEX IF NOT EXISTS idx_analytics_event_type ON analytics_event(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_user ON analytics_event(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_target ON analytics_event(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_analytics_owner ON analytics_event(owner_type, owner_id);
CREATE INDEX IF NOT EXISTS idx_analytics_created ON analytics_event(created_at);
CREATE INDEX IF NOT EXISTS idx_analytics_session ON analytics_event(session_id);

-- Composite index for owner analytics
CREATE INDEX IF NOT EXISTS idx_analytics_owner_date ON analytics_event(owner_type, owner_id, created_at);
