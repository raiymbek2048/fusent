-- FCM Tokens table for push notifications
CREATE TABLE IF NOT EXISTS fcm_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token VARCHAR(500) NOT NULL UNIQUE,
    user_id UUID NOT NULL,
    device_type VARCHAR(20), -- 'ANDROID' or 'IOS'
    device_id VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fcm_token_user
        FOREIGN KEY (user_id)
        REFERENCES app_users(id)
        ON DELETE CASCADE
);

-- Indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user_id ON fcm_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_active ON fcm_tokens(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_device ON fcm_tokens(user_id, device_id);

-- Comments
COMMENT ON TABLE fcm_tokens IS 'Firebase Cloud Messaging tokens for push notifications';
COMMENT ON COLUMN fcm_tokens.token IS 'FCM registration token from Firebase';
COMMENT ON COLUMN fcm_tokens.device_type IS 'Device platform: ANDROID or IOS';
COMMENT ON COLUMN fcm_tokens.device_id IS 'Unique device identifier';
COMMENT ON COLUMN fcm_tokens.is_active IS 'Whether the token is still valid and active';
