-- Add is_read and user_id fields to notification_log for user notifications

-- Add user_id to link notification to a specific user
ALTER TABLE notification_log ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES app_user(id) ON DELETE CASCADE;

-- Add is_read to track if user has read the notification
ALTER TABLE notification_log ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE;

-- Add read_at timestamp
ALTER TABLE notification_log ADD COLUMN IF NOT EXISTS read_at TIMESTAMP WITHOUT TIME ZONE;

-- Create index for user notifications query
CREATE INDEX IF NOT EXISTS idx_notif_log_user_id ON notification_log(user_id);
CREATE INDEX IF NOT EXISTS idx_notif_log_user_read ON notification_log(user_id, is_read);

-- Create composite index for unread notifications
CREATE INDEX IF NOT EXISTS idx_notif_log_unread ON notification_log(user_id, is_read) WHERE is_read = FALSE;
