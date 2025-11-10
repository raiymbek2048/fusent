-- Fix CHECK constraints to use uppercase values to match Java enums
-- This migration updates the constraints to match the EnumType.STRING values

-- Drop old constraints
ALTER TABLE post DROP CONSTRAINT IF EXISTS chk_post_owner_type;
ALTER TABLE post DROP CONSTRAINT IF EXISTS chk_post_type;
ALTER TABLE post DROP CONSTRAINT IF EXISTS chk_post_visibility;
ALTER TABLE post DROP CONSTRAINT IF EXISTS chk_post_status;
ALTER TABLE post_media DROP CONSTRAINT IF EXISTS chk_media_type;

-- Add new constraints with uppercase values matching Java enums
ALTER TABLE post ADD CONSTRAINT chk_post_owner_type CHECK (owner_type IN ('MERCHANT', 'USER'));
ALTER TABLE post ADD CONSTRAINT chk_post_type CHECK (post_type IN ('PHOTO', 'VIDEO', 'CAROUSEL', 'SHORT'));
ALTER TABLE post ADD CONSTRAINT chk_post_visibility CHECK (visibility IN ('PUBLIC', 'FOLLOWERS', 'PRIVATE'));
ALTER TABLE post ADD CONSTRAINT chk_post_status CHECK (status IN ('ACTIVE', 'ARCHIVED', 'DELETED', 'FLAGGED'));
ALTER TABLE post_media ADD CONSTRAINT chk_media_type CHECK (media_type IN ('IMAGE', 'VIDEO'));

-- Update existing data to uppercase (if any exists)
UPDATE post SET owner_type = UPPER(owner_type);
UPDATE post SET post_type = UPPER(post_type);
UPDATE post SET visibility = UPPER(visibility);
UPDATE post SET status = UPPER(status);
UPDATE post_media SET media_type = UPPER(media_type);

-- Update default values in post table
ALTER TABLE post ALTER COLUMN post_type SET DEFAULT 'PHOTO';
ALTER TABLE post ALTER COLUMN visibility SET DEFAULT 'PUBLIC';
ALTER TABLE post ALTER COLUMN status SET DEFAULT 'ACTIVE';
