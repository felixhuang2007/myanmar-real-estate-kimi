-- Migration: Fix ACN ratio field types to match code implementation
-- Date: 2026-04-01
-- Bug: BUG-015

-- Problem: Database uses DECIMAL(5,2) for ratios, but code stores integer (percentage * 100)
-- Example: 30.50% is stored as 3050 in code, but DECIMAL(5,2) max is 999.99
-- Solution: Change ratio columns to INTEGER type

-- acn_transactions table
ALTER TABLE acn_transactions
    ALTER COLUMN entrant_ratio TYPE INTEGER,
    ALTER COLUMN maintainer_ratio TYPE INTEGER,
    ALTER COLUMN introducer_ratio TYPE INTEGER,
    ALTER COLUMN accompanier_ratio TYPE INTEGER,
    ALTER COLUMN closer_ratio TYPE INTEGER,
    ALTER COLUMN platform_ratio TYPE INTEGER;

-- acn_commission_details table
ALTER TABLE acn_commission_details
    ALTER COLUMN ratio TYPE INTEGER;

-- Update default values from DECIMAL to INTEGER (percentage * 100)
ALTER TABLE acn_transactions
    ALTER COLUMN entrant_ratio SET DEFAULT 1500,      -- 15.00%
    ALTER COLUMN maintainer_ratio SET DEFAULT 2000,   -- 20.00%
    ALTER COLUMN introducer_ratio SET DEFAULT 1000,   -- 10.00%
    ALTER COLUMN accompanier_ratio SET DEFAULT 1500,  -- 15.00%
    ALTER COLUMN closer_ratio SET DEFAULT 4000,       -- 40.00%
    ALTER COLUMN platform_ratio SET DEFAULT 1000;     -- 10.00%

-- Verify the changes
-- \d acn_transactions
-- \d acn_commission_details
