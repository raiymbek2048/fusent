-- Add base_price column to product table
ALTER TABLE product ADD COLUMN IF NOT EXISTS base_price NUMERIC(12, 2);

-- Set base_price from existing variants (get minimum price from variants)
UPDATE product p
SET base_price = (
    SELECT MIN(pv.price)
    FROM product_variant pv
    WHERE pv.product_id = p.id
)
WHERE p.base_price IS NULL;

-- Set default 0 for products without variants
UPDATE product
SET base_price = 0
WHERE base_price IS NULL;
