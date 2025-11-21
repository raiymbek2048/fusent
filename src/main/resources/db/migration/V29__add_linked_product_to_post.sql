-- Add linked_product_id column to post table to support product-linked posts
ALTER TABLE post
ADD COLUMN linked_product_id UUID;

-- Add foreign key constraint to product table
ALTER TABLE post
ADD CONSTRAINT fk_post_linked_product
FOREIGN KEY (linked_product_id) REFERENCES product(id) ON DELETE SET NULL;

-- Add index for performance
CREATE INDEX idx_post_linked_product ON post(linked_product_id);
