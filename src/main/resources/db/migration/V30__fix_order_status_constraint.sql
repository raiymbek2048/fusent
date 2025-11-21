-- Fix order status constraint to use uppercase values matching Java enum
ALTER TABLE "order" DROP CONSTRAINT IF EXISTS chk_order_status;
ALTER TABLE "order" ADD CONSTRAINT chk_order_status CHECK (status IN ('CREATED', 'PAID', 'CANCELLED', 'FULFILLED', 'REFUNDED'));

-- Update existing data to uppercase
UPDATE "order" SET status = UPPER(status);
