-- Add name field to product_variant table for display purposes
ALTER TABLE product_variant ADD COLUMN name VARCHAR(255);

-- Update existing variants to have "Стандартный" as default name
UPDATE product_variant SET name = 'Стандартный' WHERE name IS NULL;
