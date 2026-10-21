-- ============================================================================
-- UAR release hardening -- schema objects.
-- Run as XXUAR AFTER 01_uar_schema_ddl.sql and BEFORE 02_uar_packages.sql
-- (the packages reference the views and the log table created here).
-- Existing installs: run this file, then re-run 02_uar_packages.sql
-- (every statement in 02 is CREATE OR REPLACE).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Pre-check: the new constraints below would fail on data that already
-- violates them. Say so up front instead of failing halfway through.
-- ----------------------------------------------------------------------------
declare
    l_open number;
    l_dup  number;
    l_bad  number;
begin
    select count(*) into l_open from xxcti_uar_review_cycles where status = 'OPEN';
    select count(*) into l_dup from (
        select upper(cycle_name) from xxcti_uar_review_cycles
         group by upper(cycle_name) having count(*) > 1);
    select count(*) into l_bad from xxcti_uar_review_cycles where period_end < period_start;

    if l_open > 1 then
        raise_application_error(-20900,
            'More than one cycle is OPEN. Close all but one, then re-run this script.');
    elsif l_dup > 0 then
        raise_application_error(-20901,
            'Duplicate cycle names exist (case-insensitive). Rename them, then re-run this script.');
    elsif l_bad > 0 then
        raise_application_error(-20902,
            'A cycle has period_end earlier than period_start. Fix it, then re-run this script.');
    end if;
end;
/

-- ----------------------------------------------------------------------------
-- 1. Cycle integrity the packages used to rely on alone.
-- ----------------------------------------------------------------------------
-- Exactly one OPEN cycle at a time, enforced by the database.
create unique index xxcti_uar_cycles_one_open_ux
    on xxcti_uar_review_cycles (case when status = 'OPEN' then 1 end);

-- Cycle names are how admins tell cycles apart in the pickers.
create unique index xxcti_uar_cycles_name_ux
    on xxcti_uar_review_cycles (upper(cycle_name));

alter table xxcti_uar_review_cycles add constraint xxcti_uar_review_cycles_dates_ck
    check (period_end >= period_start);

-- ----------------------------------------------------------------------------
-- 2. Admin action log. Written by the packages (never directly by the app).
--    Deliberately has no foreign keys: a deleted cycle's log entries must
--    outlive it.
-- ----------------------------------------------------------------------------
create sequence xxcti_uar_admin_log_seq start with 1 increment by 1;

create table xxcti_uar_admin_log (
    log_id         number         not null,
    action         varchar2(40)   not null,
    cycle_id       number,
    detail         varchar2(4000),
    performed_by   varchar2(240)  default coalesce(sys_context('APEX$SESSION','APP_USER'), user),
    performed_date date           default sysdate not null,
    constraint xxcti_uar_admin_log_pk primary key (log_id)
);

comment on table xxcti_uar_admin_log is
  'Who did what to cycles and the admin list: open, close, delete, reopen a submission, submit on behalf of a manager, add/remove admin. No FKs on purpose so entries outlive deleted cycles.';

-- ----------------------------------------------------------------------------
-- 3. Progress view, now immune to duplicate Workday rows (the same employee
--    listed twice used to double-count that manager's items).
-- ----------------------------------------------------------------------------
create or replace view xxcti_uar_cycle_progress as
select ri.cycle_id,
       uwe.manager_id,
       uwe.manager_first_name,
       uwe.manager_last_name,
       count(*)                                             as total_items,
       count(ri.approval)                                   as completed_items,
       round(count(ri.approval) / nullif(count(*),0) * 100) as pct_complete
  from xxcti_uar_review_items ri
  join (select distinct employee_id, manager_id, manager_first_name, manager_last_name
          from xxcti_uar_workday_employee_mgr) uwe
    on ri.employee_number = to_char(uwe.employee_id)
 group by ri.cycle_id, uwe.manager_id, uwe.manager_first_name, uwe.manager_last_name;

-- ----------------------------------------------------------------------------
-- 4. Items nobody can review: the employee is missing from the Workday data,
--    has no manager, or their manager has no row of their own (so the manager
--    can never sign in as themselves and Page 3 drops them from its report).
-- ----------------------------------------------------------------------------
create or replace view xxcti_uar_unassigned_items as
select ri.cycle_id,
       ri.review_item_id,
       ri.employee_number,
       ri.user_name,
       ri.responsibility,
       ri.application,
       case
         when e.employee_id is null then 'Employee not found in Workday data'
         when e.manager_id  is null then 'Employee has no manager in Workday data'
         else                            'Manager not found in Workday data'
       end as reason
  from xxcti_uar_review_items ri
  left join (select distinct employee_id, manager_id
               from xxcti_uar_workday_employee_mgr) e
    on to_char(e.employee_id) = ri.employee_number
 where e.employee_id is null
    or e.manager_id  is null
    or not exists (select 1 from xxcti_uar_workday_employee_mgr m
                    where m.employee_id = e.manager_id);

-- ----------------------------------------------------------------------------
-- 5. Source-data problems that make reviews ambiguous. Empty = healthy.
-- ----------------------------------------------------------------------------
create or replace view xxcti_uar_data_issues as
select 'Employee listed more than once in Workday data' as issue,
       to_char(employee_id)                             as ref,
       count(*) || ' rows'                              as detail
  from xxcti_uar_workday_employee_mgr
 group by employee_id
having count(*) > 1
union all
select 'Employee has conflicting managers',
       to_char(employee_id),
       count(distinct manager_id) || ' different managers'
  from xxcti_uar_workday_employee_mgr
 group by employee_id
having count(distinct manager_id) > 1
union all
select 'Email shared by more than one Workday row (sign-in ambiguous)',
       lower(email_address),
       count(*) || ' rows'
  from xxcti_uar_workday_employee_mgr
 where email_address is not null
 group by lower(email_address)
having count(*) > 1;
