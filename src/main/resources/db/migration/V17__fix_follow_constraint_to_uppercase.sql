-- Fix follow table CHECK constraint to use uppercase values to match Java enum
-- This fixes the chk_follow_target_type constraint to match FollowTargetType enum

-- Drop old constraint
ALTER TABLE follow DROP CONSTRAINT IF EXISTS chk_follow_target_type;

-- Add new constraint with uppercase values matching Java enum (MERCHANT, USER)
ALTER TABLE follow ADD CONSTRAINT chk_follow_target_type CHECK (target_type IN ('MERCHANT', 'USER'));

-- Update existing data to uppercase (if any exists)
UPDATE follow SET target_type = UPPER(target_type);
