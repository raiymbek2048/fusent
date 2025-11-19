-- Add shop_id to app_user table to link sellers to specific shops (branches)
-- This allows a merchant to have multiple sellers, each assigned to specific shop locations

ALTER TABLE app_user
ADD COLUMN shop_id UUID,
ADD CONSTRAINT fk_user_shop
    FOREIGN KEY (shop_id)
    REFERENCES shop(id)
    ON DELETE SET NULL;

-- Create index for faster queries
CREATE INDEX idx_user_shop_id ON app_user(shop_id);

-- Comment for documentation
COMMENT ON COLUMN app_user.shop_id IS 'The shop/branch this seller is assigned to (NULL for non-sellers or unassigned sellers)';
