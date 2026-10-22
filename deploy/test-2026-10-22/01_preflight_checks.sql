-- ============================================================================
-- UAR FIRST INSTALL -> TEST : PRE-FLIGHT CHECKS (read-only -- changes nothing)
--
-- Run as XXUAR in the TEST workspace (SQL Workshop > SQL Scripts, or SQLcl).
-- Read every result set top to bottom BEFORE running 02_schema_install.sql.
-- Anything marked STOP must be resolved first.
-- ============================================================================

-- 1. Are you in the right place? Expect: DB user XXUAR, the TEST database.
select user as db_user, sys_context('userenv','con_name') as database_name from dual;

-- 2. The three SOURCE FEEDS must already exist in this schema -- the install does not create them.
--    Expect: all three 'present'. 'MISSING' means the feed (Workday managers / EBS responsibilities) is not
--    loaded into TEST yet: stop and sort that out first.
select e.table_name,
       case when exists (select 1 from user_objects o where o.object_name = e.table_name and o.object_type in ('TABLE','VIEW'))
            then 'present' else 'STOP - MISSING: load the feed before installing' end as status
  from (select 'XXCTI_UAR_WORKDAY_EMPLOYEE_MGR'               as table_name from dual union all
        select 'XXCTI_UAR_EMPLOYEE_RESPONSIBILITIES'          from dual union all
        select 'XXCTI_UAR_EMPLOYEE_RESPONSIBILITIES_AUDIT'    from dual) e
 order by e.table_name;

-- 3. This must be a FIRST install. Expect: NO ROWS. Any row means UAR objects already exist in this schema
--    (a first-install script would fail on them) -- stop and ask; you probably want an upgrade pack instead.
select object_name, object_type
  from user_objects
 where object_name like 'XXCTI_UAR%'
   and object_name not in ('XXCTI_UAR_WORKDAY_EMPLOYEE_MGR','XXCTI_UAR_EMPLOYEE_RESPONSIBILITIES',
                           'XXCTI_UAR_EMPLOYEE_RESPONSIBILITIES_AUDIT')
 order by object_type, object_name;

-- 4. Can this schema create what the install needs? Expect: 5 rows (table, view, sequence, procedure, trigger).
select privilege from session_privs
 where privilege in ('CREATE TABLE','CREATE VIEW','CREATE SEQUENCE','CREATE PROCEDURE','CREATE TRIGGER')
 order by privilege;

--    ...and room to store data (informational: expect UNLIMITED or a comfortable number).
select tablespace_name, bytes as used_bytes,
       case when max_bytes = -1 then 'UNLIMITED' else to_char(max_bytes) end as quota
  from user_ts_quotas;

-- 5. Is the schema attached to the TEST workspace? Expect: a row for XXUAR under workspace CT_BSG_APEX.
select workspace_name, schema from apex_workspace_schemas order by workspace_name, schema;

-- 6. Is application id 530 free in this workspace? Expect: NO ROWS (a row means something already uses id 530).
select application_id, application_name from apex_applications where application_id = 530;

-- 7. How the Workday feed stores its ids in THIS environment. Informational: the release handles either text
--    or numbers (it reads them through the view xxcti_uar_workday_norm).
select column_name, data_type, data_length
  from user_tab_columns
 where table_name = 'XXCTI_UAR_WORKDAY_EMPLOYEE_MGR' and column_name in ('EMPLOYEE_ID','MANAGER_ID')
 order by column_name;

-- 8. Source-data health: what Page 3 will warn about once the app is live.
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
select 'Responsibility rows / distinct employees', count(*) || ' / ' || count(distinct employee_number)
  from xxcti_uar_employee_responsibilities
union all
select 'Responsibility rows with an end date already past (you expect 0)', to_char(count(*))
  from xxcti_uar_employee_responsibilities where end_date is not null and end_date < trunc(sysdate);

-- 9. Employees with access but NO reviewer (no manager, manager has no Workday row, or not in Workday).
--    After the install these appear on Page 3 and Page 5 so an admin can assign a reviewer -- expect the top of
--    your hierarchy here. Decide in advance who should review them.
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
    or not exists (select 1 from xxcti_uar_workday_employee_mgr m where to_char(m.employee_id) = to_char(w.manager_id))
 group by er.employee_number
 order by 3;
