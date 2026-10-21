-- ============================================================================
-- UAR release -> DEV : POST-DEPLOY VERIFICATION (read-only -- changes nothing)
--
-- Run as XXUAR in the DEV workspace after BOTH the schema patch and the app
-- import. Every result should match the "expect" note above it.
-- ============================================================================

-- 1. Expect: NO ROWS (nothing invalid).
select object_name, object_type, status from user_objects where status <> 'VALID' order by object_type, object_name;

-- 2. Expect: NO ROWS (no compile errors).
select name, type, line, text from user_errors order by name, type, sequence;

-- 3. Expect: 7 rows, all VALID.
select object_name, object_type, status
  from user_objects
 where object_name in ('XXCTI_UAR_ADMIN_LOG','XXCTI_UAR_REVIEWER_OVERRIDES','XXCTI_UAR_EFFECTIVE_MGR',
                       'XXCTI_UAR_UNASSIGNED_ITEMS','XXCTI_UAR_UNASSIGNED_EMPLOYEES','XXCTI_UAR_DATA_ISSUES',
                       'XXCTI_UAR_ERROR_HANDLER')
 order by object_name;

-- 4. Expect: the packages, triggers and cycle-rule indexes all present and VALID/ENABLED.
select object_name, object_type, status from user_objects
 where object_name in ('XXCTI_UAR_SECURITY_PKG','XXCTI_UAR_CYCLE_PKG','XXCTI_UAR_REVIEW_ITEMS_BIU',
                       'XXCTI_UAR_REVIEW_ITEMS_AUTH','XXCTI_UAR_CYCLES_ONE_OPEN_UX','XXCTI_UAR_CYCLES_NAME_UX')
 order by object_type, object_name;
select trigger_name, status from user_triggers order by trigger_name;

-- 5. Expect: both new procedures exist in the security package (assign/remove reviewer).
select object_name, procedure_name from user_procedures
 where object_name = 'XXCTI_UAR_SECURITY_PKG'
   and procedure_name in ('ASSIGN_REVIEWER','REMOVE_REVIEWER','ADD_ADMIN','REMOVE_ADMIN','REQUIRE_ADMIN','LOG_ACTION')
 order by procedure_name;

-- 6. The application. Expect: 9 pages including 5 (Reviewer Assignments); idle timeout 1800 (30 min);
--    date format DD-Mon-YYYY; authentication scheme = your DEV SSO scheme.
select application_id, application_name, pages, authentication_scheme, date_format,
       maximum_session_idle_seconds as idle_timeout_sec
  from apex_applications where application_id = 530;
select page_id, page_name from apex_application_pages where application_id = 530 order by page_id;

-- 7. What the new Page 3 warning panel / Page 5 will show in DEV right now (informational).
select reason, count(*) as employees, sum(responsibilities) as responsibilities
  from xxcti_uar_unassigned_employees group by reason order by 2 desc;
select issue, count(*) as cases from xxcti_uar_data_issues group by issue order by issue;

-- 8. Existing data survived. Compare with check 4 of the pre-flight (same cycles, same items/decided counts).
select c.cycle_id, c.cycle_name, c.status,
       (select count(*) from xxcti_uar_review_items i where i.cycle_id = c.cycle_id)                          as items,
       (select count(*) from xxcti_uar_review_items i where i.cycle_id = c.cycle_id and i.approval is not null) as decided
  from xxcti_uar_review_cycles c order by c.cycle_id;

-- 9. The admin log starts empty on first deploy and fills as admins act. (Informational.)
select count(*) as admin_log_rows from xxcti_uar_admin_log;
