-- Fix column types from float8/double to numeric/decimal for proper money handling
-- This migration ensures all monetary and coordinate columns have the correct precision

-- Product Variant: price
ALTER TABLE product_variant
ALTER COLUMN price TYPE NUMERIC(12, 2) USING price::numeric(12, 2);

-- Order: total_amount
ALTER TABLE "order"
ALTER COLUMN total_amount TYPE NUMERIC(12, 2) USING total_amount::numeric(12, 2);

-- Order Item: price and subtotal
ALTER TABLE order_item
ALTER COLUMN price TYPE NUMERIC(12, 2) USING price::numeric(12, 2),
ALTER COLUMN subtotal TYPE NUMERIC(12, 2) USING subtotal::numeric(12, 2);

-- POS Sale: qty, unit_price, total_price
ALTER TABLE pos_sale
ALTER COLUMN qty TYPE NUMERIC(10, 2) USING qty::numeric(10, 2),
ALTER COLUMN unit_price TYPE NUMERIC(12, 2) USING unit_price::numeric(12, 2),
ALTER COLUMN total_price TYPE NUMERIC(12, 2) USING total_price::numeric(12, 2);

-- Shop: total_sales, total_refunds, lat, lon
ALTER TABLE shop
ALTER COLUMN total_sales TYPE NUMERIC(12, 2) USING total_sales::numeric(12, 2),
ALTER COLUMN total_refunds TYPE NUMERIC(12, 2) USING total_refunds::numeric(12, 2),
ALTER COLUMN lat TYPE NUMERIC(10, 7) USING lat::numeric(10, 7),
ALTER COLUMN lon TYPE NUMERIC(10, 7) USING lon::numeric(10, 7);

-- Comments for clarity
COMMENT ON COLUMN product_variant.price IS 'Product variant price in numeric(12,2) format for precise monetary calculations';
COMMENT ON COLUMN "order".total_amount IS 'Order total amount in numeric(12,2) format for precise monetary calculations';
COMMENT ON COLUMN order_item.price IS 'Item price at time of order in numeric(12,2) format';
COMMENT ON COLUMN order_item.subtotal IS 'Item subtotal (price * qty) in numeric(12,2) format';
COMMENT ON COLUMN pos_sale.unit_price IS 'Unit price in numeric(12,2) format';
COMMENT ON COLUMN pos_sale.total_price IS 'Total price in numeric(12,2) format';
COMMENT ON COLUMN shop.lat IS 'Shop latitude in numeric(10,7) format for precise geolocation';
COMMENT ON COLUMN shop.lon IS 'Shop longitude in numeric(10,7) format for precise geolocation';
