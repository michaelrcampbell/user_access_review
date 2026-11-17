-- ============================================================================
-- UAR PATCH "move employees between managers" : POST-DEPLOY VERIFICATION (read-only)
-- Run as XXUAR after BOTH the schema patch and the application import.
-- ============================================================================

-- 1. Expect: NO ROWS (nothing invalid).
select object_name, object_type, status from user_objects where status <> 'VALID' order by object_type, object_name;

-- 2. Expect: NO ROWS (no compile errors).
select name, type, line, text from user_errors order by name, type, sequence;

-- 3. Expect: 1 row, VALID (the view this patch adds).
select object_name, object_type, status from user_objects where object_name = 'XXCTI_UAR_EMPLOYEE_REVIEWERS';

-- 4. Expect: the packages still have all their procedures (assign_reviewer was rewritten, the rest unchanged).
select object_name, procedure_name from user_procedures
 where object_name = 'XXCTI_UAR_SECURITY_PKG'
   and procedure_name in ('ASSIGN_REVIEWER','REMOVE_REVIEWER','ADD_ADMIN','REMOVE_ADMIN','REQUIRE_ADMIN','LOG_ACTION')
 order by procedure_name;

-- 5. The new rule: an assignment now WINS over Workday. Expect assignments_with_a_reviewer = effective_assigned
--    (every assignment whose reviewer exists is in effect). A mismatch means an assignment names a reviewer who is
--    no longer in the Workday data.
select (select count(*) from xxcti_uar_reviewer_overrides o
         where exists (select 1 from xxcti_uar_workday_norm w where w.employee_id = o.reviewer_id)) as assignments_with_a_reviewer,
       (select count(*) from xxcti_uar_effective_mgr where manager_source = 'ASSIGNED')           as effective_assigned
  from dual;

-- 6. Expect: no employee whose assignment is ignored while a different person is shown as reviewer.
select o.employee_id, o.reviewer_id as assigned, e.manager_id as effective_reviewer, e.manager_source
  from xxcti_uar_reviewer_overrides o
  join xxcti_uar_effective_mgr e on e.employee_id = o.employee_id
 where e.manager_id is not null and e.manager_id <> o.reviewer_id
   and exists (select 1 from xxcti_uar_workday_norm w where w.employee_id = o.reviewer_id);

-- 7. The application. Expect: 9 pages; idle timeout 1800; date format DD-Mon-YYYY. PROD: availability AVAILABLE and feedback Disabled.
select application_id, application_name, pages, authentication_scheme, date_format,
       maximum_session_idle_seconds as idle_timeout_sec, flow_status_code as availability, feedback
  from apex_applications where application_id = 530;

-- 8. Page 5 now has the move components. Expect: P5_FIND, P5_MOVE_SELECTED and P5_MOVE among the regions.
select region_name from apex_application_page_regions
 where application_id = 530 and page_id = 5 order by display_sequence;

-- 9. Informational: every employee in the responsibilities data with who reviews them and why (first 15 rows).
select employee_number, employee_name, reviewer_name, reviewer_source, workday_manager
  from xxcti_uar_employee_reviewers
 where rownum <= 15
 order by employee_name;
