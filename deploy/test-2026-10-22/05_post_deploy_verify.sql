-- ============================================================================
-- UAR FIRST INSTALL -> TEST : POST-DEPLOY VERIFICATION (read-only -- changes nothing)
--
-- Run as XXUAR in the TEST workspace after the schema install, the first-admin script
-- AND the application import. Every result should match the "expect" note above it.
-- ============================================================================

-- 1. Expect: NO ROWS (nothing invalid).
select object_name, object_type, status from user_objects where status <> 'VALID' order by object_type, object_name;

-- 2. Expect: NO ROWS (no compile errors).
select name, type, line, text from user_errors order by name, type, sequence;

-- 3. What the install created. Expect exactly these counts, all VALID:
--    TABLE 7, VIEW 6, SEQUENCE 4, PACKAGE 2, PACKAGE BODY 2, TRIGGER 2, PROCEDURE 1, FUNCTION 1
--    (plus the 3 source feeds, which are not counted here).
select object_type, count(*) as objects,
       sum(case when status = 'VALID' then 1 else 0 end) as valid
  from user_objects
 where object_name like 'XXCTI_UAR%'
   and object_name not in ('XXCTI_UAR_WORKDAY_EMPLOYEE_MGR','XXCTI_UAR_EMPLOYEE_RESPONSIBILITIES',
                           'XXCTI_UAR_EMPLOYEE_RESPONSIBILITIES_AUDIT')
   and object_type in ('TABLE','VIEW','SEQUENCE','PACKAGE','PACKAGE BODY','TRIGGER','PROCEDURE','FUNCTION')
 group by object_type
 order by object_type;

-- 4. Expect: the cycle-rule indexes (2) and both triggers ENABLED.
select index_name, uniqueness from user_indexes where index_name in ('XXCTI_UAR_CYCLES_ONE_OPEN_UX','XXCTI_UAR_CYCLES_NAME_UX');
select trigger_name, status from user_triggers where trigger_name like 'XXCTI_UAR%' order by trigger_name;

-- 5. Expect: your first admin, and nothing else yet.
select email_address as admin, added_date from xxcti_uar_admins order by added_date;

-- 6. The application. Expect: 9 pages including 5 (Reviewer Assignments); idle timeout 1800 (30 min);
--    date format DD-Mon-YYYY; authentication scheme = the SSO scheme.
select application_id, application_name, pages, authentication_scheme, date_format,
       maximum_session_idle_seconds as idle_timeout_sec
  from apex_applications where application_id = 530;
select page_id, page_name from apex_application_pages where application_id = 530 order by page_id;

-- 7. Expect: NO ROWS yet (no cycle has been opened).
select cycle_id, cycle_name, status from xxcti_uar_review_cycles;

-- 8. What Page 3 / Page 5 will show right now (informational; matches pre-flight checks 8 and 9).
select reason, count(*) as employees, sum(responsibilities) as responsibilities
  from xxcti_uar_unassigned_employees group by reason order by 2 desc;
select issue, count(*) as cases from xxcti_uar_data_issues group by issue order by issue;

-- 9. Expect: one row, the first admin being recorded.
select action, performed_by, detail from xxcti_uar_admin_log order by log_id;
