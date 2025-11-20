-- Add message type and shared content fields to chat_message table
ALTER TABLE chat_message
    ADD COLUMN message_type VARCHAR(20) NOT NULL DEFAULT 'TEXT',
    ADD COLUMN shared_product_id UUID,
    ADD COLUMN shared_post_id UUID,
    ADD CONSTRAINT chat_message_type_check CHECK (message_type IN ('TEXT', 'PRODUCT_SHARE', 'POST_SHARE'));

-- Add foreign key constraints for shared content
ALTER TABLE chat_message
    ADD CONSTRAINT fk_chat_message_shared_product
        FOREIGN KEY (shared_product_id) REFERENCES product(id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_chat_message_shared_post
        FOREIGN KEY (shared_post_id) REFERENCES post(id) ON DELETE SET NULL;

-- Add check constraint: only one shared item per message
ALTER TABLE chat_message
    ADD CONSTRAINT chat_message_share_exclusivity_check
        CHECK (
            (message_type = 'TEXT' AND shared_product_id IS NULL AND shared_post_id IS NULL) OR
            (message_type = 'PRODUCT_SHARE' AND shared_product_id IS NOT NULL AND shared_post_id IS NULL) OR
            (message_type = 'POST_SHARE' AND shared_post_id IS NOT NULL AND shared_product_id IS NULL)
        );

-- Create indexes for better query performance
CREATE INDEX idx_chat_message_type ON chat_message(message_type);
CREATE INDEX idx_chat_message_shared_product ON chat_message(shared_product_id) WHERE shared_product_id IS NOT NULL;
CREATE INDEX idx_chat_message_shared_post ON chat_message(shared_post_id) WHERE shared_post_id IS NOT NULL;
