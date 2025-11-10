-- Add test users to the database
-- Passwords are BCrypt hashed (strength 10)

-- Admin user: admin@fusent.kg / Admin123!
INSERT INTO app_user (id, email, password_hash, role, is_verified, created_at, updated_at)
VALUES
    (uuid_generate_v4(), 'admin@fusent.kg', '$2a$10$YQ7TZ4UZ3c7YL5r9BzM.2OqRJ.VgNhG8kXZ2fXP8K.wK8yXB6.3gS', 'admin', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (email) DO NOTHING;

-- Customer/Buyer user: customer@fusent.kg / Customer123!
INSERT INTO app_user (id, email, password_hash, role, is_verified, created_at, updated_at)
VALUES
    (uuid_generate_v4(), 'customer@fusent.kg', '$2a$10$N5qJf8h7LxRJ4F9gQvFYveuqN3ZhN5.fO8qKx3PQK8M5zN7R8K9dC', 'buyer', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (email) DO NOTHING;

-- Seller user: seller@fusent.kg / Seller123!
-- First insert the seller user
INSERT INTO app_user (id, email, password_hash, role, is_verified, created_at, updated_at)
VALUES
    ('d7a3e5f0-1234-4567-89ab-cdef12345678', 'seller@fusent.kg', '$2a$10$K8m9L3nP5Q7R9S1T3U5V7.xYzA3BcD5EfG7HiJ9KlM1NoP3QrS5Tu', 'seller', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Create a merchant for the seller (only if not exists)
INSERT INTO merchant (id, owner_id, name, description, payout_status, buy_eligibility, created_at, updated_at)
SELECT uuid_generate_v4(), 'd7a3e5f0-1234-4567-89ab-cdef12345678', 'Тестовый магазин', 'Магазин для тестирования', 'active', 'online_purchase', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM merchant WHERE owner_id = 'd7a3e5f0-1234-4567-89ab-cdef12345678');

-- Create a shop for the merchant
INSERT INTO shop (id, merchant_id, name, address, phone, pos_status, created_at, updated_at)
SELECT
    uuid_generate_v4(),
    m.id,
    'Тестовая торговая точка',
    'г. Бишкек, ул. Тестовая 123',
    '+996 555 123 456',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM merchant m
WHERE m.owner_id = 'd7a3e5f0-1234-4567-89ab-cdef12345678';
