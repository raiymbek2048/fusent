-- Add rating and review_count columns to shop table

ALTER TABLE shop
ADD COLUMN rating DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
ADD COLUMN review_count INTEGER NOT NULL DEFAULT 0;

-- Add index for rating to optimize sorting
CREATE INDEX idx_shop_rating ON shop(rating DESC);

-- Add comment for documentation
COMMENT ON COLUMN shop.rating IS 'Average rating of the shop (0.00 - 5.00)';
COMMENT ON COLUMN shop.review_count IS 'Total number of reviews for the shop';
