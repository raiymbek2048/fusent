-- Fucent Platform Schema Migration V1
-- Core tables: Users, Merchants, Shops, Catalog, Orders, POS

-- Extension for UUID support
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE app_user (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone VARCHAR(20),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'buyer',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_role CHECK (role IN ('buyer', 'seller', 'admin'))
);

CREATE INDEX idx_user_email ON app_user(email);
CREATE INDEX idx_user_role ON app_user(role);

-- Merchants table
CREATE TABLE merchant (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    payout_account_number VARCHAR(100),
    payout_bank_name VARCHAR(100),
    payout_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    buy_eligibility VARCHAR(30) NOT NULL DEFAULT 'manual_contact',
    settings_json JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_payout_status CHECK (payout_status IN ('pending', 'active', 'suspended')),
    CONSTRAINT chk_buy_eligibility CHECK (buy_eligibility IN ('manual_contact', 'online_purchase', 'hybrid'))
);

CREATE INDEX idx_merchant_owner ON merchant(owner_id);
CREATE INDEX idx_merchant_payout_status ON merchant(payout_status);

-- Shops table (physical locations)
CREATE TABLE shop (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchant(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    lat DECIMAL(10, 7),
    lon DECIMAL(10, 7),
    pos_status VARCHAR(20) NOT NULL DEFAULT 'inactive',
    last_heartbeat_at TIMESTAMP WITHOUT TIME ZONE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_pos_status CHECK (pos_status IN ('inactive', 'active'))
);

CREATE INDEX idx_shop_merchant ON shop(merchant_id);
CREATE INDEX idx_shop_pos_status ON shop(pos_status);
CREATE INDEX idx_shop_location ON shop(lat, lon) WHERE lat IS NOT NULL AND lon IS NOT NULL;

-- Categories table (hierarchical)
CREATE TABLE category (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id UUID REFERENCES category(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_category_parent ON category(parent_id);
CREATE INDEX idx_category_active ON category(is_active);

-- Products table
CREATE TABLE product (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES shop(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES category(id) ON DELETE RESTRICT,
    name VARCHAR(500) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_shop ON product(shop_id);
CREATE INDEX idx_product_category ON product(category_id);
CREATE INDEX idx_product_active ON product(is_active);

-- Product Variants table
CREATE TABLE product_variant (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES product(id) ON DELETE CASCADE,
    sku VARCHAR(100) NOT NULL UNIQUE,
    barcode VARCHAR(100),
    attributes_json JSONB,
    price DECIMAL(12, 2) NOT NULL,
    stock_qty INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_price CHECK (price >= 0),
    CONSTRAINT chk_stock CHECK (stock_qty >= 0)
);

CREATE INDEX idx_variant_product ON product_variant(product_id);
CREATE INDEX idx_variant_sku ON product_variant(sku);
CREATE INDEX idx_variant_barcode ON product_variant(barcode) WHERE barcode IS NOT NULL;
CREATE INDEX idx_variant_attributes ON product_variant USING GIN(attributes_json);

-- Orders table
CREATE TABLE "order" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES app_user(id) ON DELETE RESTRICT,
    shop_id UUID NOT NULL REFERENCES shop(id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP WITHOUT TIME ZONE,
    fulfilled_at TIMESTAMP WITHOUT TIME ZONE,

    CONSTRAINT chk_order_status CHECK (status IN ('pending', 'paid', 'cancelled', 'fulfilled', 'refunded')),
    CONSTRAINT chk_total_amount CHECK (total_amount >= 0)
);

CREATE INDEX idx_order_user ON "order"(user_id);
CREATE INDEX idx_order_shop ON "order"(shop_id);
CREATE INDEX idx_order_status ON "order"(status);
CREATE INDEX idx_order_created ON "order"(created_at DESC);

-- Order Items table
CREATE TABLE order_item (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES "order"(id) ON DELETE CASCADE,
    variant_id UUID NOT NULL REFERENCES product_variant(id) ON DELETE RESTRICT,
    qty INT NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    subtotal DECIMAL(12, 2) NOT NULL,

    CONSTRAINT chk_order_item_qty CHECK (qty > 0),
    CONSTRAINT chk_order_item_price CHECK (price >= 0),
    CONSTRAINT chk_order_item_subtotal CHECK (subtotal >= 0)
);

CREATE INDEX idx_order_item_order ON order_item(order_id);
CREATE INDEX idx_order_item_variant ON order_item(variant_id);

-- POS Sales table
CREATE TABLE pos_sale (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES shop(id) ON DELETE RESTRICT,
    variant_id UUID NOT NULL REFERENCES product_variant(id) ON DELETE RESTRICT,
    qty DECIMAL(10, 2) NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,
    total_price DECIMAL(12, 2) NOT NULL,
    receipt_number VARCHAR(100) NOT NULL,
    sale_type VARCHAR(20) NOT NULL DEFAULT 'sale',
    sold_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_sale_qty CHECK (qty != 0),
    CONSTRAINT chk_sale_type CHECK (sale_type IN ('sale', 'refund', 'void'))
);

CREATE INDEX idx_pos_sale_shop ON pos_sale(shop_id);
CREATE INDEX idx_pos_sale_variant ON pos_sale(variant_id);
CREATE INDEX idx_pos_sale_receipt ON pos_sale(receipt_number);
CREATE INDEX idx_pos_sale_sold_at ON pos_sale(sold_at DESC);
CREATE UNIQUE INDEX idx_pos_sale_idempotency ON pos_sale(shop_id, receipt_number, variant_id);

-- POS Summary Daily (aggregated data)
CREATE TABLE pos_summary_daily (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES shop(id) ON DELETE CASCADE,
    day DATE NOT NULL,
    total_sales DECIMAL(12, 2) DEFAULT 0,
    total_refunds DECIMAL(12, 2) DEFAULT 0,
    total_receipts INT DEFAULT 0,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_pos_summary_shop_day UNIQUE (shop_id, day)
);

CREATE INDEX idx_pos_summary_shop ON pos_summary_daily(shop_id);
CREATE INDEX idx_pos_summary_day ON pos_summary_daily(day DESC);

-- Comments
COMMENT ON TABLE app_user IS 'Platform users (buyers, sellers, admins)';
COMMENT ON TABLE merchant IS 'Merchant/seller profiles with payout settings';
COMMENT ON TABLE shop IS 'Physical shop locations with POS integration';
COMMENT ON TABLE category IS 'Hierarchical product categories';
COMMENT ON TABLE product IS 'Products with variants';
COMMENT ON TABLE product_variant IS 'Product SKUs with stock and pricing';
COMMENT ON TABLE "order" IS 'Customer orders';
COMMENT ON TABLE order_item IS 'Items within orders';
COMMENT ON TABLE pos_sale IS 'POS transaction records';
COMMENT ON TABLE pos_summary_daily IS 'Daily aggregated POS sales data';
