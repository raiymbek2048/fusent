-- Add trending-related fields to post table

-- Add views_count field
ALTER TABLE post ADD COLUMN IF NOT EXISTS views_count INTEGER DEFAULT 0;

-- Add trending_score field
ALTER TABLE post ADD COLUMN IF NOT EXISTS trending_score DECIMAL(12, 4) DEFAULT 0.0;

-- Update existing posts to have default values
UPDATE post SET views_count = 0 WHERE views_count IS NULL;
UPDATE post SET trending_score = 0.0 WHERE trending_score IS NULL;

-- Create index for trending posts (optimized for ORDER BY trending_score DESC, created_at DESC)
CREATE INDEX IF NOT EXISTS idx_post_trending ON post(trending_score DESC, created_at DESC);

-- Create index for views count (useful for analytics)
CREATE INDEX IF NOT EXISTS idx_post_views ON post(views_count);

-- Comments
COMMENT ON COLUMN post.views_count IS 'Number of times the post has been viewed';
COMMENT ON COLUMN post.trending_score IS 'Calculated trending score based on engagement and time decay';
COMMENT ON INDEX idx_post_trending IS 'Optimized index for fetching trending posts';
