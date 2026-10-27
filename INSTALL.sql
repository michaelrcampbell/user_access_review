-- ============================================================================
-- UAR App -- FIRST INSTALL of the schema and packages (SQLcl runner).
--
-- For DEV/TEST/PROD use a deployment pack under deploy/ instead (pre-flight checks,
-- first admin, application import, verification, rollback). This script is for a
-- scratch schema. It is NOT safe to run twice: 01 creates tables.
--
-- The three source feeds (xxcti_uar_workday_employee_mgr,
-- xxcti_uar_employee_responsibilities, xxcti_uar_employee_responsibilities_audit)
-- must already exist. The application itself is 04_uar_apex.sql (import it with
-- App Builder after this).
-- ============================================================================

@@01_uar_schema_ddl.sql
@@01b_uar_release_hardening.sql   -- must run before 02 (views/log table the packages use)
@@02_uar_packages.sql
-- @@03_uar_migration_legacy_audit.sql   -- optional, uncomment if wanted

prompt Done -- schema and packages installed.
prompt Next: seed an admin (insert into xxcti_uar_admins) and import 04_uar_apex.sql.
