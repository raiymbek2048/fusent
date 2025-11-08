-- Cart System Migration
-- Adds cart and cart_item tables for shopping cart functionality

-- Cart table (persistent shopping carts for users)
CREATE TABLE cart (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_cart_user UNIQUE(user_id)
);

CREATE INDEX idx_cart_user ON cart(user_id);


-- Cart Items table
CREATE TABLE cart_item (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id UUID NOT NULL REFERENCES cart(id) ON DELETE CASCADE,
    variant_id UUID NOT NULL REFERENCES product_variant(id) ON DELETE CASCADE,
    qty INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_cart_item_qty CHECK (qty > 0),
    CONSTRAINT uq_cart_item_variant UNIQUE(cart_id, variant_id)
);

CREATE INDEX idx_cart_item_cart ON cart_item(cart_id);
CREATE INDEX idx_cart_item_variant ON cart_item(variant_id);


-- Function to update cart updated_at timestamp
CREATE OR REPLACE FUNCTION update_cart_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE cart SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.cart_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update cart timestamp when cart items are modified
CREATE TRIGGER trg_cart_item_update
AFTER INSERT OR UPDATE OR DELETE ON cart_item
FOR EACH ROW
EXECUTE FUNCTION update_cart_timestamp();
