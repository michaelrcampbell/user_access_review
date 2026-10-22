-- ============================================================================
-- UAR release -> DEV : PRE-FLIGHT CHECKS (read-only -- changes nothing)
--
-- Run as XXUAR in the DEV workspace (SQL Workshop > SQL Scripts, or SQLcl).
-- Read every result set top to bottom BEFORE running 02_schema_patch.sql.
-- Anything marked FIX FIRST must be resolved or understood before you continue.
-- ============================================================================

-- 1. Are you in the right place? Expect: DB user XXUAR, the DEV database.
select user as db_user, sys_context('userenv','con_name') as database_name from dual;

-- 2. The tables this release builds on must already exist (they come from 01_uar_schema_ddl.sql).
select e.table_name,
       case when exists (select 1 from user_tables t where t.table_name = e.table_name)
            then 'present' else 'MISSING - DEV is not on the expected baseline; stop' end as status
  from (select 'XXCTI_UAR_REVIEW_CYCLES'         as table_name from dual union all
        select 'XXCTI_UAR_REVIEW_ITEMS'          from dual union all
        select 'XXCTI_UAR_REVIEW_ITEMS_HISTORY'  from dual union all
        select 'XXCTI_UAR_MANAGER_SIGNOFFS'      from dual union all
        select 'XXCTI_UAR_ADMINS'                from dual union all
        select 'XXCTI_UAR_WORKDAY_EMPLOYEE_MGR'  from dual union all
        select 'XXCTI_UAR_EMPLOYEE_RESPONSIBILITIES' from dual union all
        select 'XXCTI_UAR_EMPLOYEE_RESPONSIBILITIES_AUDIT' from dual) e
 order by e.table_name;

-- 3. What this release adds. First deploy: all 'not installed yet'. (Re-running is safe either way.)
select n.object_name,
       case when exists (select 1 from user_objects o where o.object_name = n.object_name)
            then 'already installed' else 'not installed yet' end as status
  from (select 'XXCTI_UAR_ADMIN_LOG'            as object_name from dual union all
        select 'XXCTI_UAR_REVIEWER_OVERRIDES'   from dual union all
        select 'XXCTI_UAR_WORKDAY_NORM'         from dual union all
        select 'XXCTI_UAR_EFFECTIVE_MGR'        from dual union all
        select 'XXCTI_UAR_UNASSIGNED_ITEMS'     from dual union all
        select 'XXCTI_UAR_UNASSIGNED_EMPLOYEES' from dual union all
        select 'XXCTI_UAR_DATA_ISSUES'          from dual union all
        select 'XXCTI_UAR_ERROR_HANDLER'        from dual) n
 order by n.object_name;

-- 3b. How the Workday feed stores its ids in THIS environment. Informational: the release handles either
--     text or numbers (through the view xxcti_uar_workday_norm).
select column_name, data_type, data_length
  from user_tab_columns
 where table_name = 'XXCTI_UAR_WORKDAY_EMPLOYEE_MGR' and column_name in ('EMPLOYEE_ID','MANAGER_ID')
 order by column_name;

-- 4. Cycles in DEV right now (the new schema rules apply to these -- see check 5).
select c.cycle_id, c.cycle_name, c.status, c.period_start, c.period_end, c.due_date,
       (select count(*) from xxcti_uar_review_items i where i.cycle_id = c.cycle_id)                          as items,
       (select count(*) from xxcti_uar_review_items i where i.cycle_id = c.cycle_id and i.approval is not null) as decided,
       (select count(*) from xxcti_uar_manager_signoffs s where s.cycle_id = c.cycle_id)                      as submitted_managers
  from xxcti_uar_review_cycles c
 order by c.cycle_id;

-- 5. Things that would make the new cycle rules fail. 02_schema_patch.sql stops with a clear message
--    on any of these; fix them here first. Each line should say OK.
select 'More than one OPEN cycle' as check_name,
       case when count(*) <= 1 then 'OK' else 'FIX FIRST - close all but one' end as result
  from xxcti_uar_review_cycles where status = 'OPEN'
union all
select 'Duplicate cycle names (ignoring case)',
       case when count(*) = 0 then 'OK' else 'FIX FIRST - rename: ' || listagg(nm, ', ') within group (order by nm) end
  from (select upper(cycle_name) as nm from xxcti_uar_review_cycles group by upper(cycle_name) having count(*) > 1)
union all
select 'A cycle ending before it starts',
       case when count(*) = 0 then 'OK' else 'FIX FIRST - cycle ids: ' || listagg(to_char(cycle_id), ', ') within group (order by cycle_id) end
  from xxcti_uar_review_cycles where period_end < period_start;

-- 6. Source-data health. These are what Page 3 will warn about after the deploy.
select 'Workday rows / distinct employees' as check_name,
       count(*) || ' / ' || count(distinct employee_id) as value
  from xxcti_uar_workday_employee_mgr
union all
select 'Employees listed more than once in Workday data (expect 0)', to_char(count(*))
  from (select employee_id from xxcti_uar_workday_employee_mgr group by employee_id having count(*) > 1)
union all
select 'Employees with two different managers (expect 0)', to_char(count(*))
  from (select employee_id from xxcti_uar_workday_employee_mgr group by employee_id having count(distinct manager_id) > 1)
union all
select 'Emails shared by more than one Workday row (expect 0)', to_char(count(*))
  from (select lower(email_address) from xxcti_uar_workday_employee_mgr where email_address is not null
         group by lower(email_address) having count(*) > 1)
union all
select 'Responsibility rows with an end date already past (you expect 0)', to_char(count(*))
  from xxcti_uar_employee_responsibilities where end_date is not null and end_date < trunc(sysdate);

-- 7. Employees with access but NO reviewer today (no manager, manager has no Workday row, or not in Workday).
--    After the deploy these appear on Page 3 and Page 5 so an admin can assign a reviewer -- expect the
--    top of your hierarchy here. Decide in advance who should review them.
select er.employee_number,
       max(er.user_name) as oracle_user,
       nvl(max(w.employee_legal_first_name || ' ' || w.employee_legal_last_name), '(not in Workday data)') as employee_name,
       case when max(w.employee_id) is null then 'not in Workday data'
            when max(w.manager_id)  is null then 'no manager in Workday data'
            else 'manager has no Workday row' end as why,
       count(*) as responsibilities
  from xxcti_uar_employee_responsibilities er
  left join (select employee_id, min(employee_legal_first_name) as employee_legal_first_name,
                    min(employee_legal_last_name) as employee_legal_last_name, min(manager_id) as manager_id
               from xxcti_uar_workday_employee_mgr group by employee_id) w
    on to_char(w.employee_id) = er.employee_number
 where w.employee_id is null
    or w.manager_id is null
    or not exists (select 1 from xxcti_uar_workday_employee_mgr m where m.employee_id = w.manager_id)
 group by er.employee_number
 order by 3;

-- 8. Admins and the application as it is now.
select email_address as current_admin, added_date from xxcti_uar_admins order by added_date;

select application_id, application_name, pages, authentication_scheme, date_format
  from apex_applications where application_id = 530;
