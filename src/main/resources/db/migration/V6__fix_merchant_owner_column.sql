-- Fix merchant.owner_user_id column name to match entity mapping
-- The entity uses @Column(name = "owner_id") but JPA created owner_user_id by default

ALTER TABLE merchant RENAME COLUMN owner_user_id TO owner_id;
