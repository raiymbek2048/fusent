CREATE TABLE payment_method (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    card_number VARCHAR(50),
    card_holder VARCHAR(100),
    expiry_date VARCHAR(10),
    phone VARCHAR(50),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payment_method_user_id ON payment_method(user_id);
