-- Add profile fields to app_user table

-- Profile information
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS avatar_url VARCHAR(500);
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS bio VARCHAR(1000);
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS address VARCHAR(255);
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS city VARCHAR(100);
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS country VARCHAR(100);
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS date_of_birth VARCHAR(10);
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS gender VARCHAR(20);

-- Account status
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Social links
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS telegram_username VARCHAR(100);
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS instagram_username VARCHAR(100);

-- Statistics (cached for performance)
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS followers_count INTEGER DEFAULT 0;
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS following_count INTEGER DEFAULT 0;
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS posts_count INTEGER DEFAULT 0;

-- Update existing users to have default values
UPDATE app_user SET is_verified = FALSE WHERE is_verified IS NULL;
UPDATE app_user SET is_active = TRUE WHERE is_active IS NULL;
UPDATE app_user SET followers_count = 0 WHERE followers_count IS NULL;
UPDATE app_user SET following_count = 0 WHERE following_count IS NULL;
UPDATE app_user SET posts_count = 0 WHERE posts_count IS NULL;

-- Comments
COMMENT ON COLUMN app_user.avatar_url IS 'URL to user avatar image';
COMMENT ON COLUMN app_user.bio IS 'User biography/description';
COMMENT ON COLUMN app_user.address IS 'Full user address';
COMMENT ON COLUMN app_user.city IS 'User city';
COMMENT ON COLUMN app_user.country IS 'User country';
COMMENT ON COLUMN app_user.date_of_birth IS 'Date of birth in YYYY-MM-DD format';
COMMENT ON COLUMN app_user.gender IS 'User gender: MALE, FEMALE, OTHER';
COMMENT ON COLUMN app_user.is_verified IS 'Whether user account is verified';
COMMENT ON COLUMN app_user.is_active IS 'Whether user account is active';
COMMENT ON COLUMN app_user.telegram_username IS 'Telegram username without @';
COMMENT ON COLUMN app_user.instagram_username IS 'Instagram username without @';
COMMENT ON COLUMN app_user.followers_count IS 'Cached count of followers';
COMMENT ON COLUMN app_user.following_count IS 'Cached count of following';
COMMENT ON COLUMN app_user.posts_count IS 'Cached count of posts';
