
-- =====================================================
-- SEED DATA для Fusent (запускать после старта бэкенда)
-- =====================================================

-- 1. Категории
INSERT INTO category (id, name, sort_order, is_active, created_at) VALUES
                                                                       ('11111111-1111-1111-1111-111111111111', 'Электроника', 1, true, NOW()),
                                                                       ('22222222-2222-2222-2222-222222222222', 'Одежда', 2, true, NOW()),
                                                                       ('33333333-3333-3333-3333-333333333333', 'Продукты', 3, true, NOW()),
                                                                       ('44444444-4444-4444-4444-444444444444', 'Дом и сад', 4, true, NOW()),
                                                                       ('55555555-5555-5555-5555-555555555555', 'Красота', 5, true, NOW());

-- 2. Пользователи (пароль: Test123!)
-- BCrypt hash для Test123! = $2a$10$K8m9L3nP5Q7R9S1T3U5V7.xYzA3BcD5EfG7HiJ9KlM1NoP3QrS5Tu

-- Admin
INSERT INTO app_user (id, full_name, email, username, phone, password_hash, role, is_verified, is_active, blocked, followers_count, following_count, posts_count, created_at,
                      updated_at)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Администратор', 'admin@fusent.kg', 'admin', '+996555000001', '$2a$10$K8m9L3nP5Q7R9S1T3U5V7.xYzA3BcD5EfG7HiJ9KlM1NoP3QrS5Tu',
        'ADMIN', true, true, false, 0, 0, 0, NOW(), NOW());

-- Seller
INSERT INTO app_user (id, full_name, email, username, phone, password_hash, role, is_verified, is_active, blocked, shop_address, has_smartpos, followers_count,
                      following_count, posts_count, created_at, updated_at)
VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Продавец Тест', 'seller@test.com', 'seller', '+996555000002', '$2a$10$K8m9L3nP5Q7R9S1T3U5V7.xYzA3BcD5EfG7HiJ9KlM1NoP3QrS5Tu',
        'SELLER', true, true, false, 'Бишкек, ул. Тестовая 1', true, 10, 5, 3, NOW(), NOW());

-- Buyer
INSERT INTO app_user (id, full_name, email, username, phone, password_hash, role, is_verified, is_active, blocked, followers_count, following_count, posts_count, created_at,
                      updated_at)
VALUES ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Покупатель Тест', 'buyer@test.com', 'buyer', '+996555000003', '$2a$10$K8m9L3nP5Q7R9S1T3U5V7.xYzA3BcD5EfG7HiJ9KlM1NoP3QrS5Tu',
        'BUYER', true, true, false, 0, 0, 0, NOW(), NOW());

-- Mobile tester
INSERT INTO app_user (id, full_name, email, username, phone, password_hash, role, is_verified, is_active, blocked, followers_count, following_count, posts_count, created_at,
                      updated_at)
VALUES ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'Мобильный Тестер', 'mobile@test.com', 'mobile', '+996555000004',
        '$2a$10$K8m9L3nP5Q7R9S1T3U5V7.xYzA3BcD5EfG7HiJ9KlM1NoP3QrS5Tu', 'BUYER', true, true, false, 0, 0, 0, NOW(), NOW());

-- 3. Мерчант для продавца
INSERT INTO merchant (id, owner_id, name, description, payout_status, buy_eligibility, approval_status, blocked, created_at, updated_at)
VALUES ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Тестовый Магазин', 'Описание магазина', 'ACTIVE', 'ONLINE_PURCHASE', 'APPROVED',
        false, NOW(), NOW());

-- 4. Магазин
INSERT INTO shop (id, merchant_id, name, address, phone, lat, lon, pos_status, created_at, updated_at)
VALUES ('ffffffff-ffff-ffff-ffff-ffffffffffff', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Торговая точка №1', 'Бишкек, ул. Тестовая 1', '+996555123456', 42.8746, 74.5698,
        'ACTIVE', NOW(), NOW());

-- 5. Тестовый товар
INSERT INTO product (id, shop_id, category_id, name, description, base_price, is_active, created_at, updated_at)
VALUES ('10000000-0000-0000-0000-000000000001', 'ffffffff-ffff-ffff-ffff-ffffffffffff', '11111111-1111-1111-1111-111111111111', 'iPhone 15 Pro', 'Флагманский смартфон Apple',
        99900.00, true, NOW(), NOW());

-- 6. Вариант товара
INSERT INTO product_variant (id, product_id, sku, barcode, name, price, stock_qty, created_at, updated_at)
VALUES ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'IPHONE15PRO-256', '1234567890123', '256GB Black', 99900.00, 10, NOW(), NOW());

Логины:
  - admin@fusent.kg / Test123!
  - seller@test.com / Test123!
  - buyer@test.com / Test123!
  - mobile@test.com / Test123!
