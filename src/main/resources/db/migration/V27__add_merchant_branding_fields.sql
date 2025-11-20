-- Add branding and verification fields to merchant table
-- Note: logo_url and banner_url already exist (added by Hibernate), so we only add is_verified

-- Step 1: Add is_verified column as nullable first
ALTER TABLE merchant
    ADD COLUMN IF NOT EXISTS is_verified BOOLEAN;

-- Step 2: Update existing rows to set default value for is_verified
UPDATE merchant
SET is_verified = false
WHERE is_verified IS NULL;

-- Step 3: Now make is_verified NOT NULL with default
ALTER TABLE merchant
    ALTER COLUMN is_verified SET DEFAULT false,
    ALTER COLUMN is_verified SET NOT NULL;

-- Create index for verified merchants (for faster queries)
CREATE INDEX IF NOT EXISTS idx_merchant_verified ON merchant(is_verified) WHERE is_verified = true;

-- Add comments for documentation
COMMENT ON COLUMN merchant.logo_url IS 'URL to merchant logo image stored in MinIO';
COMMENT ON COLUMN merchant.banner_url IS 'URL to merchant banner/cover image stored in MinIO';
COMMENT ON COLUMN merchant.is_verified IS 'Whether the merchant has been verified by platform administrators';
