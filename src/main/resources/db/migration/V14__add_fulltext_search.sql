-- Add full-text search capabilities for products
-- This migration creates GIN indexes for efficient full-text search on product names and descriptions

-- Add tsvector columns for full-text search
ALTER TABLE product ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- Create function to update search_vector
CREATE OR REPLACE FUNCTION product_search_vector_update() RETURNS trigger AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('russian', coalesce(NEW.name, '')), 'A') ||
        setweight(to_tsvector('russian', coalesce(NEW.description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(NEW.name, '')), 'C') ||
        setweight(to_tsvector('english', coalesce(NEW.description, '')), 'D');
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update search_vector
DROP TRIGGER IF EXISTS product_search_vector_trigger ON product;
CREATE TRIGGER product_search_vector_trigger
    BEFORE INSERT OR UPDATE OF name, description
    ON product
    FOR EACH ROW
    EXECUTE FUNCTION product_search_vector_update();

-- Update existing records
UPDATE product SET search_vector =
    setweight(to_tsvector('russian', coalesce(name, '')), 'A') ||
    setweight(to_tsvector('russian', coalesce(description, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(name, '')), 'C') ||
    setweight(to_tsvector('english', coalesce(description, '')), 'D');

-- Create GIN index for fast full-text search
CREATE INDEX IF NOT EXISTS product_search_vector_idx ON product USING GIN(search_vector);

-- Create additional indexes for commonly searched fields
CREATE INDEX IF NOT EXISTS product_name_idx ON product USING GIN(to_tsvector('russian', name));
CREATE INDEX IF NOT EXISTS product_category_idx ON product(category_id);
CREATE INDEX IF NOT EXISTS product_shop_idx ON product(shop_id);
