-- Migration: Add service_state to services table
-- Purpose: Track real-time health state of services (HEALTHY, ERROR, INACTIVE)
-- Date: 2026-01-23
-- Version: 1.1.0

-- Step 1: Add service_state column (nullable initially for backfill)
ALTER TABLE services ADD COLUMN service_state VARCHAR(20);

-- Step 2: Backfill existing data based on current state
-- Set INACTIVE for services where monitoring is disabled
UPDATE services
SET service_state = 'inactive'
WHERE is_active = 0;

-- Set ERROR for active services that have open incidents
UPDATE services
SET service_state = 'error'
WHERE is_active = 1
  AND id IN (
    SELECT DISTINCT service_id
    FROM incidents
    WHERE status IN ('open', 'investigating')
  );

-- Set HEALTHY for all remaining active services (no open incidents)
UPDATE services
SET service_state = 'healthy'
WHERE service_state IS NULL AND is_active = 1;

-- Step 3: Make column NOT NULL after backfill
-- Note: SQLite doesn't support ALTER COLUMN, so we verify all rows have values
-- For PostgreSQL/MySQL, uncomment the next line:
-- ALTER TABLE services ALTER COLUMN service_state SET NOT NULL;

-- Step 4: Create index for efficient dashboard queries
CREATE INDEX IF NOT EXISTS idx_services_state ON services(service_state);

-- Step 5: Create composite index for common project-scoped queries
CREATE INDEX IF NOT EXISTS idx_services_project_state ON services(project_id, service_state, is_active);

-- Verification query (run manually to verify migration success):
-- SELECT service_state, COUNT(*) as count FROM services GROUP BY service_state;

-- Expected results:
-- service_state | count
-- --------------|-------
-- healthy       | X
-- error         | Y
-- inactive      | Z

-- Rollback (if needed):
-- DROP INDEX IF EXISTS idx_services_project_state;
-- DROP INDEX IF EXISTS idx_services_state;
-- ALTER TABLE services DROP COLUMN service_state;
