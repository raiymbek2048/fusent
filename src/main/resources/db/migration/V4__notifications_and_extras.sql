-- Fucent Platform Schema Migration V4
-- Notifications, Subscriptions, and Additional Features

-- Notification Preferences table
CREATE TABLE notification_pref (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_type VARCHAR(20) NOT NULL,
    owner_id UUID NOT NULL,
    channel VARCHAR(20) NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    quiet_hours JSONB,
    locale VARCHAR(10) DEFAULT 'ru',
    categories TEXT[],
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_notif_pref_owner_type CHECK (owner_type IN ('user', 'shop', 'merchant')),
    CONSTRAINT chk_notif_pref_channel CHECK (channel IN ('push', 'sms', 'email')),
    CONSTRAINT uq_notif_pref UNIQUE (owner_type, owner_id, channel)
);

CREATE INDEX idx_notif_pref_owner ON notification_pref(owner_type, owner_id);

-- Notification Templates table
CREATE TABLE notification_template (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_key VARCHAR(100) NOT NULL,
    channel VARCHAR(20) NOT NULL,
    locale VARCHAR(10) NOT NULL DEFAULT 'ru',
    subject VARCHAR(500),
    body TEXT NOT NULL,
    version INT DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_notif_template_channel CHECK (channel IN ('push', 'sms', 'email')),
    CONSTRAINT uq_notif_template UNIQUE (template_key, channel, locale, version)
);

CREATE INDEX idx_notif_template_key ON notification_template(template_key, is_active);

-- Notification Log table
CREATE TABLE notification_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    channel VARCHAR(20) NOT NULL,
    recipient VARCHAR(255) NOT NULL,
    template_key VARCHAR(100) NOT NULL,
    payload_json JSONB,
    status VARCHAR(20) NOT NULL DEFAULT 'queued',
    provider VARCHAR(50),
    provider_ref VARCHAR(255),
    attempts INT DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    delivered_at TIMESTAMP WITHOUT TIME ZONE,

    CONSTRAINT chk_notif_log_channel CHECK (channel IN ('push', 'sms', 'email')),
    CONSTRAINT chk_notif_log_status CHECK (status IN ('queued', 'sent', 'delivered', 'failed', 'bounced'))
);

CREATE INDEX idx_notif_log_status ON notification_log(status);
CREATE INDEX idx_notif_log_created ON notification_log(created_at DESC);
CREATE INDEX idx_notif_log_recipient ON notification_log(recipient);

-- Merchant Subscriptions table (PRO/ENTERPRISE tiers)
CREATE TABLE merchant_subscription (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchant(id) ON DELETE CASCADE,
    plan VARCHAR(20) NOT NULL DEFAULT 'FREE',
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    trial_end_at TIMESTAMP WITHOUT TIME ZONE,
    current_period_start TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    current_period_end TIMESTAMP WITHOUT TIME ZONE,
    auto_renew BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_subscription_plan CHECK (plan IN ('FREE', 'PRO', 'ENTERPRISE')),
    CONSTRAINT chk_subscription_status CHECK (status IN ('active', 'trialing', 'past_due', 'cancelled', 'expired'))
);

CREATE INDEX idx_subscription_merchant ON merchant_subscription(merchant_id);
CREATE INDEX idx_subscription_status ON merchant_subscription(status);

-- Chat Messages table (buyer-seller communication)
CREATE TABLE chat_message (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL,
    sender_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    is_flagged BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_chat_conversation ON chat_message(conversation_id);
CREATE INDEX idx_chat_sender ON chat_message(sender_id);
CREATE INDEX idx_chat_recipient ON chat_message(recipient_id);
CREATE INDEX idx_chat_created ON chat_message(created_at DESC);
CREATE INDEX idx_chat_unread ON chat_message(recipient_id, is_read) WHERE is_read = FALSE;

-- POS Devices table (registered POS terminals)
CREATE TABLE pos_device (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES shop(id) ON DELETE CASCADE,
    device_id VARCHAR(100) NOT NULL UNIQUE,
    device_name VARCHAR(255),
    status VARCHAR(20) NOT NULL DEFAULT 'inactive',
    last_heartbeat_at TIMESTAMP WITHOUT TIME ZONE,
    firmware_version VARCHAR(50),
    ip_address VARCHAR(45),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_pos_device_status CHECK (status IN ('inactive', 'active', 'offline', 'suspended'))
);

CREATE INDEX idx_pos_device_shop ON pos_device(shop_id);
CREATE INDEX idx_pos_device_status ON pos_device(status);
CREATE INDEX idx_pos_device_last_heartbeat ON pos_device(last_heartbeat_at DESC);

-- Saved Items (user wishlist/favorites)
CREATE TABLE saved_item (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES product(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_saved_item UNIQUE (user_id, product_id)
);

CREATE INDEX idx_saved_item_user ON saved_item(user_id);
CREATE INDEX idx_saved_item_product ON saved_item(product_id);

-- Platform Settings table (global configuration)
CREATE TABLE platform_setting (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    value_type VARCHAR(20) NOT NULL DEFAULT 'string',
    description TEXT,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_platform_setting_value_type CHECK (value_type IN ('string', 'number', 'boolean', 'json'))
);

CREATE INDEX idx_platform_setting_key ON platform_setting(setting_key);

-- Insert default platform settings
INSERT INTO platform_setting (setting_key, setting_value, value_type, description) VALUES
    ('take_rate', '0.0', 'number', 'Platform commission rate (0-100%)'),
    ('comments_mode', 'all', 'string', 'Comment policy: all, buyers_only, followers_only, off'),
    ('min_order_amount', '0', 'number', 'Minimum order amount in KGS'),
    ('pos_heartbeat_timeout_min', '10', 'number', 'POS heartbeat timeout in minutes');

-- Comments
COMMENT ON TABLE notification_pref IS 'User/merchant notification preferences per channel';
COMMENT ON TABLE notification_template IS 'Notification templates with i18n support';
COMMENT ON TABLE notification_log IS 'Notification delivery log and status tracking';
COMMENT ON TABLE merchant_subscription IS 'Merchant subscription plans (FREE/PRO/ENTERPRISE)';
COMMENT ON TABLE chat_message IS 'Buyer-seller chat messages';
COMMENT ON TABLE pos_device IS 'Registered POS devices with heartbeat tracking';
COMMENT ON TABLE saved_item IS 'User saved/favorited products';
COMMENT ON TABLE platform_setting IS 'Global platform configuration settings';
