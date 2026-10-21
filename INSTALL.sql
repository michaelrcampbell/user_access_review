-- ============================================================================
-- UAR App -- install/update schema and packages.
--
-- The APEX application itself is not yet built as an export file -- see
-- APEX_BUILD_GUIDE.md for the page-by-page spec to build it in Page
-- Designer. Once it exists as 04_uar_apex.sql, add its import here too.
-- ============================================================================

@@01_uar_schema_ddl.sql
@@01b_uar_release_hardening.sql   -- must run before 02 (views/log table the packages use)
@@02_uar_packages.sql
-- @@03_uar_migration_legacy_audit.sql   -- optional, uncomment if wanted

prompt Done -- schema and packages installed.
prompt Next: build/import the APEX app per APEX_BUILD_GUIDE.md.
