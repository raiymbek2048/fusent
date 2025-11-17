-- Add profile fields to app_user table
ALTER TABLE public.app_user
ADD COLUMN full_name VARCHAR(255),
ADD COLUMN username VARCHAR(255),
ADD COLUMN phone VARCHAR(50),
ADD COLUMN shop_address TEXT,
ADD COLUMN has_smartpos BOOLEAN DEFAULT FALSE;

-- Add unique constraint on username
ALTER TABLE public.app_user
ADD CONSTRAINT uk_app_user_username UNIQUE (username);

-- Update existing users with default values
UPDATE public.app_user
SET full_name = COALESCE(full_name, email),
    username = COALESCE(username, SUBSTRING(email FROM 1 FOR POSITION('@' IN email) - 1))
WHERE full_name IS NULL OR username IS NULL;

-- Make full_name NOT NULL after setting defaults
ALTER TABLE public.app_user
ALTER COLUMN full_name SET NOT NULL;
