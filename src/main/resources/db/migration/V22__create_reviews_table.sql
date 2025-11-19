-- Add reviews table with verified purchase support
-- A review can be for a Shop OR for a Product

CREATE TABLE review (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reviewer_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    shop_id UUID REFERENCES shop(id) ON DELETE CASCADE,
    product_id UUID REFERENCES product(id) ON DELETE CASCADE,
    order_id UUID REFERENCES "order"(id) ON DELETE SET NULL,

    rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    comment TEXT,

    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INTEGER DEFAULT 0,

    status VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Either shop_id or product_id must be set, but not both
    CONSTRAINT chk_review_target CHECK (
        (shop_id IS NOT NULL AND product_id IS NULL) OR
        (shop_id IS NULL AND product_id IS NOT NULL)
    ),

    -- Status constraint
    CONSTRAINT chk_review_status CHECK (status IN ('active', 'hidden', 'flagged', 'deleted'))
);

-- Indexes for performance
CREATE INDEX idx_review_reviewer ON review(reviewer_id);
CREATE INDEX idx_review_shop ON review(shop_id) WHERE shop_id IS NOT NULL;
CREATE INDEX idx_review_product ON review(product_id) WHERE product_id IS NOT NULL;
CREATE INDEX idx_review_order ON review(order_id) WHERE order_id IS NOT NULL;
CREATE INDEX idx_review_status ON review(status);
CREATE INDEX idx_review_verified ON review(is_verified_purchase);
CREATE INDEX idx_review_created ON review(created_at DESC);

-- Composite index for common queries
CREATE INDEX idx_review_shop_status ON review(shop_id, status) WHERE shop_id IS NOT NULL;
CREATE INDEX idx_review_product_status ON review(product_id, status) WHERE product_id IS NOT NULL;

-- Comments
COMMENT ON TABLE review IS 'User reviews for shops and products with verified purchase tracking';
COMMENT ON COLUMN review.is_verified_purchase IS 'True if review is from a user who purchased from this order';
COMMENT ON COLUMN review.order_id IS 'Reference to the order that enables verified purchase badge';
COMMENT ON COLUMN review.helpful_count IS 'Number of users who found this review helpful';
