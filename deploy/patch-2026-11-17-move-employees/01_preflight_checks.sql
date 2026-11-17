-- ============================================================================
-- UAR PATCH "move employees between managers" : PRE-FLIGHT CHECKS (read-only)
--
-- Run as XXUAR in the environment you are about to patch (DEV, TEST or PROD),
-- SQL Workshop > SQL Scripts or SQLcl. Read every result BEFORE running
-- 02_schema_patch.sql. Nothing here changes data.
-- ============================================================================

-- 1. Are you in the right place? The guard column is name-based only: it says STOP in PROD if the
--    database name contains DEV or TEST (and tells you nothing in DEV/TEST) - confirm by eye.
select user as db_user,
       sys_context('userenv','con_name') as database_name,
       case when upper(sys_context('userenv','con_name')) like '%DEV%'
              or upper(sys_context('userenv','con_name')) like '%TEST%'
            then 'DEV/TEST by name' else 'name does not say DEV or TEST - is this PROD?' end as environment_hint
  from dual;

-- 2. Baseline: this patch sits on top of the release-hardening version. Expect: all rows 'present',
--    except XXCTI_UAR_EMPLOYEE_REVIEWERS = 'not installed yet' (this patch creates it; 'already installed' is fine on a re-run).
select n.object_name,
       case when exists (select 1 from user_objects o where o.object_name = n.object_name)
            then 'present' else case when n.object_name = 'XXCTI_UAR_EMPLOYEE_REVIEWERS'
                                     then 'not installed yet' else 'MISSING - not on the expected baseline; stop' end end as status
  from (select 'XXCTI_UAR_REVIEWER_OVERRIDES'    as object_name from dual union all
        select 'XXCTI_UAR_EFFECTIVE_MGR'         from dual union all
        select 'XXCTI_UAR_WORKDAY_NORM'          from dual union all
        select 'XXCTI_UAR_ADMIN_LOG'             from dual union all
        select 'XXCTI_UAR_SECURITY_PKG'          from dual union all
        select 'XXCTI_UAR_CYCLE_PKG'             from dual union all
        select 'XXCTI_UAR_EMPLOYEE_REVIEWERS'    from dual) n
 order by n.object_name;

-- 3. BEHAVIOUR CHANGE TO REVIEW: today an assignment is IGNORED whenever Workday has a usable manager for the employee.
--    After this patch an assignment ALWAYS applies until removed. So any assignment below marked
--    'STARTS TO APPLY' will take effect when you run the patch: the employee moves to the assigned reviewer's team.
--    Check each one is still wanted (remove the ones that are not, on Page 5, BEFORE patching). Expect no rows or only
--    'already in effect' / 'no change' rows.
select o.employee_id,
       emp.name   as employee,
       rev.name   as assigned_reviewer,
       wm.name    as workday_manager,
       case when wm.name is null                         then 'already in effect (Workday has no usable manager)'
            when w.manager_id = o.reviewer_id            then 'no change (same person as the Workday manager)'
            else 'STARTS TO APPLY - employee moves from the Workday manager to the assigned reviewer' end as after_the_patch,
       o.reason,
       o.assigned_by,
       o.assigned_date
  from xxcti_uar_reviewer_overrides o
  left join (select employee_id, max(manager_id) as manager_id
               from xxcti_uar_workday_norm group by employee_id) w
    on w.employee_id = o.employee_id
  left join (select employee_id, min(employee_legal_first_name || ' ' || employee_legal_last_name) as name
               from xxcti_uar_workday_norm group by employee_id) emp
    on emp.employee_id = o.employee_id
  left join (select employee_id, min(employee_legal_first_name || ' ' || employee_legal_last_name) as name
               from xxcti_uar_workday_norm group by employee_id) rev
    on rev.employee_id = o.reviewer_id
  left join (select employee_id, min(employee_legal_first_name || ' ' || employee_legal_last_name) as name
               from xxcti_uar_workday_norm group by employee_id) wm
    on wm.employee_id = w.manager_id
 order by case when wm.name is not null and w.manager_id <> o.reviewer_id then 0 else 1 end, o.assigned_date;

-- 4. Is a cycle open right now? (Moves take effect immediately in an open cycle.) Informational.
select c.cycle_id, c.cycle_name, c.status, c.due_date,
       (select count(*) from xxcti_uar_review_items i where i.cycle_id = c.cycle_id) as items,
       (select count(*) from xxcti_uar_review_items i where i.cycle_id = c.cycle_id and i.approval is not null) as decided,
       (select count(*) from xxcti_uar_manager_signoffs s where s.cycle_id = c.cycle_id) as managers_submitted
  from xxcti_uar_review_cycles c
 order by c.cycle_id;

-- 5. The application as it is now. PROD: availability should already read AVAILABLE and feedback Disabled.
select application_id, application_name, pages, flow_status_code as availability, feedback,
       maximum_session_idle_seconds as idle_timeout_sec
  from apex_applications where application_id = 530;
