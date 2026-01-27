-- Migration: Add guest_key column to projects table
-- Purpose: Support guest user project ownership alongside Firebase users
-- Date: 2026-01-22
-- Author: Claude Code (Guest User Support Implementation)

-- ============================================================================
-- FORWARD MIGRATION
-- ============================================================================

-- Step 1: Add guest_key column (nullable to allow existing records)
ALTER TABLE projects ADD COLUMN guest_key VARCHAR(200);

-- Step 2: Create unique index on guest_key
CREATE UNIQUE INDEX idx_projects_guest_key ON projects(guest_key) WHERE guest_key IS NOT NULL;

-- Step 3: Migrate any existing projects with NULL user_id (if any)
-- These are likely orphaned projects that should be assigned a guest_key
-- This step should be handled manually or via application code to ensure proper key generation

-- Step 4: Add CHECK constraint for mutual exclusivity
-- SQLite 3.3.0+ supports CHECK constraints
-- This ensures exactly one of user_id OR guest_key is set (not both, not neither)
-- Note: SQLite doesn't support ALTER TABLE ADD CONSTRAINT for CHECK
-- The constraint must be added during table creation or table recreation

-- For SQLite, we'll document the constraint but it will be enforced at application level
-- If using PostgreSQL or MySQL, uncomment and use:
-- ALTER TABLE projects ADD CONSTRAINT chk_owner_exclusivity
-- CHECK (
--   (user_id IS NOT NULL AND guest_key IS NULL) OR
--   (user_id IS NULL AND guest_key IS NOT NULL)
-- );

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify the column was added
-- PRAGMA table_info(projects);

-- Check for projects with both user_id and guest_key (should be 0)
-- SELECT COUNT(*) FROM projects WHERE user_id IS NOT NULL AND guest_key IS NOT NULL;

-- Check for projects with neither user_id nor guest_key (should be 0 after migration)
-- SELECT COUNT(*) FROM projects WHERE user_id IS NULL AND guest_key IS NULL;

-- ============================================================================
-- ROLLBACK MIGRATION
-- ============================================================================

-- Step 1: Drop the unique index
-- DROP INDEX IF EXISTS idx_projects_guest_key;

-- Step 2: Remove the guest_key column
-- Note: SQLite doesn't support DROP COLUMN directly
-- You would need to:
-- 1. Create a new table without guest_key
-- 2. Copy data from old table to new table
-- 3. Drop old table
-- 4. Rename new table to projects

-- Simplified rollback (if supported by newer SQLite versions or other DBs):
-- ALTER TABLE projects DROP COLUMN guest_key;

-- ============================================================================
-- NOTES
-- ============================================================================

-- 1. Backward Compatibility:
--    - Existing projects with user_id set will continue to work
--    - guest_key is NULL for Firebase-owned projects
--    - user_id is NULL for guest-owned projects

-- 2. Security Considerations:
--    - guest_key stores the actual API key value (like a password)
--    - Ensure database access is properly secured
--    - Use HTTPS for all API communications
--    - Do not expose guest_key in API responses

-- 3. Application-Level Validation:
--    - The Project model includes @validates decorator
--    - ProjectRepository.create() enforces mutual exclusivity
--    - Both layers provide defense in depth

-- 4. Migration Strategy for Existing Data:
--    - If you have projects with user_id=NULL, you should:
--      a) Generate a unique guest_key for each
--      b) Create corresponding API key records in api_keys table
--      c) Log the migration for audit purposes

-- Example Python migration code:
--
-- from app.models.api_key import generate_api_key
-- from app.repositories.project_repository import ProjectRepository
-- from app.repositories.api_key_repository import APIKeyRepository
--
-- orphaned_projects = session.query(Project).filter(Project.user_id == None).all()
-- for project in orphaned_projects:
--     guest_key = generate_api_key()
--     project.guest_key = guest_key
--     # Create corresponding API key record
--     api_key = APIKey(
--         project_id=project.id,
--         key_value=guest_key,
--         name="Migrated Guest Key",
--         description="Auto-generated during migration"
--     )
--     session.add(api_key)
-- session.commit()
