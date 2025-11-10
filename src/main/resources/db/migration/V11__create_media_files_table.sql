-- Create media_files table for centralized media management
CREATE TABLE IF NOT EXISTS media_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID,
    owner_type VARCHAR(50),
    purpose VARCHAR(50),
    media_type VARCHAR(20) NOT NULL,
    original_filename VARCHAR(255),
    storage_key VARCHAR(500) NOT NULL,
    url VARCHAR(1000) NOT NULL,
    thumbnail_url VARCHAR(1000),
    mime_type VARCHAR(100),
    file_size BIGINT,
    width INTEGER,
    height INTEGER,
    duration_seconds INTEGER,
    uploaded_by UUID,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_media_owner ON media_files(owner_id, owner_type);
CREATE INDEX IF NOT EXISTS idx_media_created ON media_files(created_at);
CREATE INDEX IF NOT EXISTS idx_media_storage_key ON media_files(storage_key);
CREATE INDEX IF NOT EXISTS idx_media_uploaded_by ON media_files(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_media_deleted ON media_files(deleted_at);

-- Add comment
COMMENT ON TABLE media_files IS 'Centralized storage for all media file metadata';
COMMENT ON COLUMN media_files.owner_id IS 'ID of the owning entity (User, Product, Post, etc.)';
COMMENT ON COLUMN media_files.owner_type IS 'Type of owner: USER, PRODUCT, POST, SHOP, etc.';
COMMENT ON COLUMN media_files.purpose IS 'Purpose: AVATAR, COVER, PRODUCT_IMAGE, POST_IMAGE, etc.';
COMMENT ON COLUMN media_files.storage_key IS 'S3/MinIO object key/path';
COMMENT ON COLUMN media_files.deleted_at IS 'Soft delete timestamp';
