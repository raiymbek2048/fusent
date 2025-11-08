-- Fucent Platform Schema Migration V3
-- Ads and Analytics Module

-- Ad Campaigns table
CREATE TABLE ad_campaign (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchant(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    campaign_type VARCHAR(20) NOT NULL,
    budget DECIMAL(12, 2),
    spent DECIMAL(12, 2) DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    start_date TIMESTAMP WITHOUT TIME ZONE,
    end_date TIMESTAMP WITHOUT TIME ZONE,
    targeting_json JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_campaign_type CHECK (campaign_type IN ('boost', 'banner', 'search', 'feed')),
    CONSTRAINT chk_campaign_status CHECK (status IN ('draft', 'active', 'paused', 'finished', 'cancelled')),
    CONSTRAINT chk_campaign_budget CHECK (budget IS NULL OR budget >= 0),
    CONSTRAINT chk_campaign_spent CHECK (spent >= 0)
);

CREATE INDEX idx_ad_campaign_merchant ON ad_campaign(merchant_id);
CREATE INDEX idx_ad_campaign_status ON ad_campaign(status);
CREATE INDEX idx_ad_campaign_dates ON ad_campaign(start_date, end_date);

-- Ad Event Daily (aggregated metrics)
CREATE TABLE ad_event_daily (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_id UUID NOT NULL REFERENCES ad_campaign(id) ON DELETE CASCADE,
    day DATE NOT NULL,
    impressions INT DEFAULT 0,
    clicks INT DEFAULT 0,
    spend DECIMAL(12, 2) DEFAULT 0,
    cpc DECIMAL(12, 4),
    cpm DECIMAL(12, 4),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_ad_event_campaign_day UNIQUE (campaign_id, day)
);

CREATE INDEX idx_ad_event_campaign ON ad_event_daily(campaign_id);
CREATE INDEX idx_ad_event_day ON ad_event_daily(day DESC);

-- Shop Metric Daily (aggregated analytics)
CREATE TABLE shop_metric_daily (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES shop(id) ON DELETE CASCADE,
    day DATE NOT NULL,
    views INT DEFAULT 0,
    clicks INT DEFAULT 0,
    route_builds INT DEFAULT 0,
    chats_started INT DEFAULT 0,
    follows INT DEFAULT 0,
    unfollows INT DEFAULT 0,
    revenue DECIMAL(12, 2) DEFAULT 0,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_shop_metric_shop_day UNIQUE (shop_id, day)
);

CREATE INDEX idx_shop_metric_shop ON shop_metric_daily(shop_id);
CREATE INDEX idx_shop_metric_day ON shop_metric_daily(day DESC);

-- Product Metric Daily (aggregated product analytics)
CREATE TABLE product_metric_daily (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variant_id UUID NOT NULL REFERENCES product_variant(id) ON DELETE CASCADE,
    day DATE NOT NULL,
    views INT DEFAULT 0,
    clicks INT DEFAULT 0,
    add_to_cart INT DEFAULT 0,
    orders INT DEFAULT 0,
    revenue DECIMAL(12, 2) DEFAULT 0,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_product_metric_variant_day UNIQUE (variant_id, day)
);

CREATE INDEX idx_product_metric_variant ON product_metric_daily(variant_id);
CREATE INDEX idx_product_metric_day ON product_metric_daily(day DESC);

-- Analytic Event Raw (event stream storage)
CREATE TABLE analytic_event_raw (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type VARCHAR(50) NOT NULL,
    user_id UUID,
    target_id UUID,
    target_type VARCHAR(50),
    context JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_analytic_event_type ON analytic_event_raw(event_type);
CREATE INDEX idx_analytic_event_user ON analytic_event_raw(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_analytic_event_target ON analytic_event_raw(target_type, target_id);
CREATE INDEX idx_analytic_event_created ON analytic_event_raw(created_at DESC);

-- Partition by month (for better performance with time-series data)
-- Note: Manual partitioning setup needed if data volume grows

-- Comments
COMMENT ON TABLE ad_campaign IS 'Advertising campaigns (boost posts, banners, search ads)';
COMMENT ON TABLE ad_event_daily IS 'Daily aggregated ad metrics per campaign';
COMMENT ON TABLE shop_metric_daily IS 'Daily aggregated shop/merchant metrics';
COMMENT ON TABLE product_metric_daily IS 'Daily aggregated product variant metrics';
COMMENT ON TABLE analytic_event_raw IS 'Raw analytics events (views, clicks, etc) - retained for 13 months';
