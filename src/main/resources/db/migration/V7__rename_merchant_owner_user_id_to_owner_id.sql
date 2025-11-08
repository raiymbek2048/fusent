-- V7: Idempotent migration to rename merchant.owner_user_id to owner_id
-- This handles the case where JPA created owner_user_id instead of respecting @Column(name="owner_id")

DO $$
BEGIN
    -- Check if owner_user_id column exists
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'merchant'
          AND column_name = 'owner_user_id'
    ) THEN
        -- Rename owner_user_id to owner_id
        ALTER TABLE public.merchant RENAME COLUMN owner_user_id TO owner_id;
        RAISE NOTICE 'Renamed merchant.owner_user_id to owner_id';
    ELSE
        RAISE NOTICE 'Column owner_user_id does not exist, skipping rename';
    END IF;

    -- Ensure owner_id column exists and has correct constraints
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'merchant'
          AND column_name = 'owner_id'
    ) THEN
        -- Ensure NOT NULL constraint
        ALTER TABLE public.merchant ALTER COLUMN owner_id SET NOT NULL;

        -- Ensure foreign key exists
        IF NOT EXISTS (
            SELECT 1
            FROM information_schema.table_constraints
            WHERE constraint_name = 'fk_merchant_owner_id'
              AND table_name = 'merchant'
              AND table_schema = 'public'
        ) THEN
            ALTER TABLE public.merchant
                ADD CONSTRAINT fk_merchant_owner_id
                FOREIGN KEY (owner_id) REFERENCES app_user(id) ON DELETE RESTRICT;
            RAISE NOTICE 'Added foreign key constraint on merchant.owner_id';
        END IF;

        RAISE NOTICE 'Verified owner_id column constraints';
    ELSE
        RAISE WARNING 'Column owner_id does not exist in merchant table!';
    END IF;
END $$;
