-- Fix merchant.owner_user_id column name to match entity mapping
-- The entity uses @Column(name = "owner_id") but JPA created owner_user_id by default

-- Check if owner_user_id column exists and rename it to owner_id
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'merchant'
        AND column_name = 'owner_user_id'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE merchant RENAME COLUMN owner_user_id TO owner_id;
    END IF;
END $$;
