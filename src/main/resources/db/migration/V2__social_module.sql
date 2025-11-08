-- Fucent Platform Schema Migration V2
-- Social Module: Posts, Media, Comments, Likes, Follows

-- Posts table (social feed content)
CREATE TABLE post (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_type VARCHAR(20) NOT NULL,
    owner_id UUID NOT NULL,
    text TEXT,
    post_type VARCHAR(20) NOT NULL DEFAULT 'photo',
    geo_lat DECIMAL(10, 7),
    geo_lon DECIMAL(10, 7),
    visibility VARCHAR(20) NOT NULL DEFAULT 'public',
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    likes_count INT DEFAULT 0,
    comments_count INT DEFAULT 0,
    shares_count INT DEFAULT 0,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_post_owner_type CHECK (owner_type IN ('merchant', 'user')),
    CONSTRAINT chk_post_type CHECK (post_type IN ('photo', 'video', 'carousel', 'short')),
    CONSTRAINT chk_post_visibility CHECK (visibility IN ('public', 'followers', 'private')),
    CONSTRAINT chk_post_status CHECK (status IN ('active', 'archived', 'deleted', 'flagged'))
);

CREATE INDEX idx_post_owner ON post(owner_type, owner_id);
CREATE INDEX idx_post_created ON post(created_at DESC);
CREATE INDEX idx_post_status ON post(status);
CREATE INDEX idx_post_location ON post(geo_lat, geo_lon) WHERE geo_lat IS NOT NULL;

-- Post Media table
CREATE TABLE post_media (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES post(id) ON DELETE CASCADE,
    media_type VARCHAR(20) NOT NULL,
    url VARCHAR(1000) NOT NULL,
    thumb_url VARCHAR(1000),
    sort_order INT DEFAULT 0,
    duration_seconds INT,
    width INT,
    height INT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_media_type CHECK (media_type IN ('image', 'video'))
);

CREATE INDEX idx_post_media_post ON post_media(post_id);
CREATE INDEX idx_post_media_sort ON post_media(post_id, sort_order);

-- Post Tags table
CREATE TABLE post_tag (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES post(id) ON DELETE CASCADE,
    tag VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_post_tag UNIQUE (post_id, tag)
);

CREATE INDEX idx_post_tag_post ON post_tag(post_id);
CREATE INDEX idx_post_tag_tag ON post_tag(tag);

-- Post Places (связь с магазинами на карте)
CREATE TABLE post_place (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES post(id) ON DELETE CASCADE,
    place_id UUID NOT NULL REFERENCES shop(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_post_place UNIQUE (post_id, place_id)
);

CREATE INDEX idx_post_place_post ON post_place(post_id);
CREATE INDEX idx_post_place_place ON post_place(place_id);

-- Comments table
CREATE TABLE comment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES post(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    is_flagged BOOLEAN DEFAULT FALSE,
    verified_purchase BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_comment_post ON comment(post_id);
CREATE INDEX idx_comment_user ON comment(user_id);
CREATE INDEX idx_comment_created ON comment(created_at DESC);
CREATE INDEX idx_comment_flagged ON comment(is_flagged) WHERE is_flagged = TRUE;

-- Likes table
CREATE TABLE "like" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES post(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_like_user_post UNIQUE (user_id, post_id)
);

CREATE INDEX idx_like_post ON "like"(post_id);
CREATE INDEX idx_like_user ON "like"(user_id);
CREATE INDEX idx_like_created ON "like"(created_at DESC);

-- Follows table
CREATE TABLE follow (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    target_type VARCHAR(20) NOT NULL,
    target_id UUID NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_follow_target_type CHECK (target_type IN ('merchant', 'user')),
    CONSTRAINT uq_follow UNIQUE (follower_id, target_type, target_id)
);

CREATE INDEX idx_follow_follower ON follow(follower_id);
CREATE INDEX idx_follow_target ON follow(target_type, target_id);
CREATE INDEX idx_follow_created ON follow(created_at DESC);

-- Audit Log table
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID,
    actor_role VARCHAR(20),
    action VARCHAR(100) NOT NULL,
    entity VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    details JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_actor ON audit_log(actor_id);
CREATE INDEX idx_audit_entity ON audit_log(entity, entity_id);
CREATE INDEX idx_audit_action ON audit_log(action);
CREATE INDEX idx_audit_created ON audit_log(created_at DESC);

-- Comments
COMMENT ON TABLE post IS 'User and merchant social posts (Instagram-like feed)';
COMMENT ON TABLE post_media IS 'Media attachments for posts (images/videos)';
COMMENT ON TABLE post_tag IS 'Hashtags and tags for posts';
COMMENT ON TABLE post_place IS 'Links posts to physical shop locations';
COMMENT ON TABLE comment IS 'Comments on posts with verified purchase indicator';
COMMENT ON TABLE "like" IS 'Post likes';
COMMENT ON TABLE follow IS 'User follows (merchants or other users)';
COMMENT ON TABLE audit_log IS 'System audit trail for admin/seller actions';
