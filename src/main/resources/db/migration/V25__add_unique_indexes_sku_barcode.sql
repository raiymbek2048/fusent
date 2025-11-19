-- Add unique indexes for SKU and barcode in product_variant table

-- Create unique index for SKU (every product variant must have unique SKU)
CREATE UNIQUE INDEX IF NOT EXISTS idx_product_variant_sku_unique
ON product_variant(sku);

-- Create unique index for barcode (only for non-null barcodes)
-- This allows multiple NULL barcodes but ensures unique non-null barcodes
CREATE UNIQUE INDEX IF NOT EXISTS idx_product_variant_barcode_unique
ON product_variant(barcode)
WHERE barcode IS NOT NULL;

-- Add regular index on barcode for faster lookups
CREATE INDEX IF NOT EXISTS idx_product_variant_barcode
ON product_variant(barcode);

-- Comments
COMMENT ON INDEX idx_product_variant_sku_unique IS 'Ensures SKU uniqueness across all product variants';
COMMENT ON INDEX idx_product_variant_barcode_unique IS 'Ensures barcode uniqueness for non-null values';
COMMENT ON INDEX idx_product_variant_barcode IS 'Fast lookup index for barcode searches';
