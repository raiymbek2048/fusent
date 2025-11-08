-- Fix for duplicate owner columns in merchant table
-- This drops the extra owner_user_id column that was created by JPA auto-ddl
-- The correct column name is owner_id as defined in V1__init_schema.sql

ALTER TABLE merchant DROP COLUMN IF EXISTS owner_user_id;
