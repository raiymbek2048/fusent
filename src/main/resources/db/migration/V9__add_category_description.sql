-- Add missing description column to category table
ALTER TABLE category ADD COLUMN IF NOT EXISTS description TEXT;
