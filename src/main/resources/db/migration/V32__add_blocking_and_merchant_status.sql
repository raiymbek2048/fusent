-- Add blocked field to users
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS blocked BOOLEAN DEFAULT FALSE NOT NULL;
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP;
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS blocked_reason VARCHAR(500);

-- Add blocked field to merchants
ALTER TABLE merchant ADD COLUMN IF NOT EXISTS blocked BOOLEAN DEFAULT FALSE NOT NULL;
ALTER TABLE merchant ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP;
ALTER TABLE merchant ADD COLUMN IF NOT EXISTS blocked_reason VARCHAR(500);

-- Add merchant approval status
ALTER TABLE merchant ADD COLUMN IF NOT EXISTS approval_status VARCHAR(20) DEFAULT 'PENDING' NOT NULL;
ALTER TABLE merchant ADD COLUMN IF NOT EXISTS approval_note VARCHAR(500);
ALTER TABLE merchant ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP;
ALTER TABLE merchant ADD COLUMN IF NOT EXISTS approved_by UUID;

-- Add blocked field to products
ALTER TABLE product ADD COLUMN IF NOT EXISTS blocked BOOLEAN DEFAULT FALSE NOT NULL;
ALTER TABLE product ADD COLUMN IF NOT EXISTS blocked_at TIMESTAMP;
ALTER TABLE product ADD COLUMN IF NOT EXISTS blocked_reason VARCHAR(500);

-- Add blocked field to posts (status BLOCKED)
-- Post already has status enum, we'll add BLOCKED to it

-- Create indexes for efficient admin queries
CREATE INDEX IF NOT EXISTS idx_user_blocked ON app_user(blocked);
CREATE INDEX IF NOT EXISTS idx_merchant_blocked ON merchant(blocked);
CREATE INDEX IF NOT EXISTS idx_merchant_approval_status ON merchant(approval_status);
CREATE INDEX IF NOT EXISTS idx_product_blocked ON product(blocked);
