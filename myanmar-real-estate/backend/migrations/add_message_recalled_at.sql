-- Migration: Add recalled_at column to messages table
-- Date: 2026-03-31
-- Bug: BUG-014

-- Add recalled_at column
ALTER TABLE messages ADD COLUMN IF NOT EXISTS recalled_at TIMESTAMP WITH TIME ZONE;

-- Create index for recalled_at if needed frequently
CREATE INDEX IF NOT EXISTS idx_messages_recalled_at ON messages(recalled_at) WHERE recalled_at IS NOT NULL;
