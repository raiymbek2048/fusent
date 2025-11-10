-- Add image_url field to product table
ALTER TABLE product ADD COLUMN IF NOT EXISTS image_url VARCHAR(500);

COMMENT ON COLUMN product.image_url IS 'Primary product image URL (stored in S3/MinIO)';

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_product_image ON product(image_url) WHERE image_url IS NOT NULL;
