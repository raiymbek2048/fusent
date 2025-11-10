-- Migration for SavedPost and Share tables

-- Create saved_post table
CREATE TABLE IF NOT EXISTS saved_post (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    post_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_saved_post_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_saved_post_post FOREIGN KEY (post_id) REFERENCES post(id) ON DELETE CASCADE,
    CONSTRAINT uq_saved_post UNIQUE (user_id, post_id)
);

CREATE INDEX idx_saved_post_user ON saved_post(user_id);
CREATE INDEX idx_saved_post_post ON saved_post(post_id);
CREATE INDEX idx_saved_post_created ON saved_post(created_at);

-- Create share table
CREATE TABLE IF NOT EXISTS share (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    post_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_share_user FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE,
    CONSTRAINT fk_share_post FOREIGN KEY (post_id) REFERENCES post(id) ON DELETE CASCADE,
    CONSTRAINT uq_share_user_post UNIQUE (user_id, post_id)
);

CREATE INDEX idx_share_post ON share(post_id);
CREATE INDEX idx_share_user ON share(user_id);
CREATE INDEX idx_share_created ON share(created_at);
