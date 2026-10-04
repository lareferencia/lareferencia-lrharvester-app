-- Apply before starting the version that persists per-worker indexing results.
-- Historical snapshots retain their legacy indexstatus; no per-worker result is inferred.
BEGIN;
ALTER TABLE networksnapshot ADD COLUMN IF NOT EXISTS indexing_results jsonb;
UPDATE networksnapshot SET indexing_results = '{"generation":0,"results":{}}'::jsonb
WHERE indexing_results IS NULL;
ALTER TABLE networksnapshot ALTER COLUMN indexing_results
    SET DEFAULT '{"generation":0,"results":{}}'::jsonb;
ALTER TABLE networksnapshot ALTER COLUMN indexing_results SET NOT NULL;
COMMIT;
