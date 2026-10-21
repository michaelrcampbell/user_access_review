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
-- 3. Reviewer assignments. Workday decides who manages whom. When Workday gives
--    an employee NO usable manager (none on file, the manager has no row of
--    their own, or the employee is not in the feed at all) an admin can assign
--    a reviewer on Page 5. An assignment never overrides a manager Workday
--    knows about, and is ignored automatically once Workday supplies one.
-- ----------------------------------------------------------------------------
create table xxcti_uar_reviewer_overrides (
    employee_id   number         not null,
    reviewer_id   number         not null,
    reason        varchar2(400),
    assigned_by   varchar2(240)  default coalesce(sys_context('APEX$SESSION','APP_USER'), user),
    assigned_date date           default sysdate not null,
    constraint xxcti_uar_reviewer_ovr_pk primary key (employee_id),
    constraint xxcti_uar_reviewer_ovr_ck check (employee_id <> reviewer_id)
);

comment on table xxcti_uar_reviewer_overrides is
  'Admin-assigned reviewer for an employee Workday gives no usable manager (top of the hierarchy, manager missing, or employee not in the feed). Only used while Workday has no manager for the employee.';

-- ----------------------------------------------------------------------------
-- 3b. The one place that answers "who reviews employee X?". Everything that
--     used to read manager_id straight from the Workday table reads this.
--     manager_source: WORKDAY, ASSIGNED (Page 5), or null = nobody can review.
--     workday_manager_id keeps the raw Workday value for diagnostics.
-- ----------------------------------------------------------------------------
create or replace view xxcti_uar_effective_mgr as
select e.employee_id,
       e.employee_legal_first_name,
       e.employee_legal_last_name,
       case when mw.employee_id is not null then e.manager_id
            when rw.employee_id is not null then o.reviewer_id end          as manager_id,
       case when mw.employee_id is not null then e.manager_first_name
            when rw.employee_id is not null then rw.first_name end          as manager_first_name,
       case when mw.employee_id is not null then e.manager_last_name
            when rw.employee_id is not null then rw.last_name end           as manager_last_name,
       case when mw.employee_id is not null then mw.email_address
            when rw.employee_id is not null then rw.email_address end       as manager_email,
       case when mw.employee_id is not null then 'WORKDAY'
            when rw.employee_id is not null then 'ASSIGNED' end             as manager_source,
       e.manager_id                                                         as workday_manager_id
  -- exactly one row per employee, however many times the feed repeats them. An
  -- employee listed with two DIFFERENT managers has no usable manager (null) and
  -- shows up as unassigned and in xxcti_uar_data_issues rather than being guessed.
  from (select employee_id,
               min(employee_legal_first_name)                              as employee_legal_first_name,
               min(employee_legal_last_name)                               as employee_legal_last_name,
               case when count(distinct manager_id) = 1
                    then min(manager_id) end                               as manager_id,
               min(manager_first_name)                                     as manager_first_name,
               min(manager_last_name)                                      as manager_last_name
          from xxcti_uar_workday_employee_mgr
         group by employee_id) e
  left join (select employee_id, min(email_address) as email_address
               from xxcti_uar_workday_employee_mgr
              group by employee_id) mw
    on mw.employee_id = e.manager_id
  left join xxcti_uar_reviewer_overrides o
    on o.employee_id = e.employee_id
  left join (select employee_id,
                    min(employee_legal_first_name) as first_name,
                    min(employee_legal_last_name)  as last_name,
                    min(email_address)             as email_address
               from xxcti_uar_workday_employee_mgr
              group by employee_id) rw
    on rw.employee_id = o.reviewer_id
union all
-- employees that are only known through an assignment (typically someone who
-- left Workday but still has access)
select o.employee_id,
       cast(null as varchar2(240)),
       cast(null as varchar2(240)),
       o.reviewer_id,
       rw.first_name,
       rw.last_name,
       rw.email_address,
       'ASSIGNED',
       cast(null as number)
  from xxcti_uar_reviewer_overrides o
  join (select employee_id,
               min(employee_legal_first_name) as first_name,
               min(employee_legal_last_name)  as last_name,
               min(email_address)             as email_address
          from xxcti_uar_workday_employee_mgr
         group by employee_id) rw
    on rw.employee_id = o.reviewer_id
 where not exists (select 1 from xxcti_uar_workday_employee_mgr w
                    where w.employee_id = o.employee_id);

-- ----------------------------------------------------------------------------
-- 4. Progress view, immune to duplicate Workday rows and counting only items
--    somebody can actually review.
-- ----------------------------------------------------------------------------
create or replace view xxcti_uar_cycle_progress as
select ri.cycle_id,
       em.manager_id,
       em.manager_first_name,
       em.manager_last_name,
       count(*)                                             as total_items,
       count(ri.approval)                                   as completed_items,
       round(count(ri.approval) / nullif(count(*),0) * 100) as pct_complete
  from xxcti_uar_review_items ri
  join xxcti_uar_effective_mgr em
    on ri.employee_number = to_char(em.employee_id)
 where em.manager_id is not null
 group by ri.cycle_id, em.manager_id, em.manager_first_name, em.manager_last_name;

-- ----------------------------------------------------------------------------
-- 5. Items nobody can review. Resolve on Page 5 (assign a reviewer).
-- ----------------------------------------------------------------------------
create or replace view xxcti_uar_unassigned_items as
select ri.cycle_id,
       ri.review_item_id,
       ri.employee_number,
       ri.user_name,
       ri.responsibility,
       ri.application,
       case
         when e.employee_id        is null then 'Employee not found in Workday data'
         when exists (select 1 from xxcti_uar_workday_employee_mgr w
                       where w.employee_id = e.employee_id
                       group by w.employee_id
                      having count(distinct w.manager_id) > 1)
                                           then 'Employee has conflicting managers in Workday data'
         when e.workday_manager_id is null then 'Employee has no manager in Workday data'
         else                                   'Manager not found in Workday data'
       end as reason
  from xxcti_uar_review_items ri
  left join xxcti_uar_effective_mgr e
    on to_char(e.employee_id) = ri.employee_number
 where e.employee_id is null
    or e.manager_id  is null;

-- ----------------------------------------------------------------------------
-- 5b. The same question per EMPLOYEE (not per cycle item), straight from the
--     responsibilities data: who has access but no reviewer? Page 5 lists these.
-- ----------------------------------------------------------------------------
create or replace view xxcti_uar_unassigned_employees as
select employee_number,
       max(employee_name)  as employee_name,
       max(user_name)      as oracle_user,
       max(reason)         as reason,
       count(*)            as responsibilities
  from (select er.employee_number,
               er.user_name,
               nvl(trim(e.employee_legal_first_name || ' ' || e.employee_legal_last_name), '(not in Workday data)') as employee_name,
               case
                 when e.employee_id        is null then 'Employee not found in Workday data'
                 when exists (select 1 from xxcti_uar_workday_employee_mgr w
                               where w.employee_id = e.employee_id
                               group by w.employee_id
                              having count(distinct w.manager_id) > 1)
                                                   then 'Employee has conflicting managers in Workday data'
                 when e.workday_manager_id is null then 'Employee has no manager in Workday data'
                 else                                   'Manager not found in Workday data'
               end as reason
          from xxcti_uar_employee_responsibilities er
          left join xxcti_uar_effective_mgr e
            on to_char(e.employee_id) = er.employee_number
         where e.employee_id is null
            or e.manager_id  is null)
 group by employee_number;

-- ----------------------------------------------------------------------------
-- 6. Source-data problems that make reviews ambiguous or noisy. Empty = healthy.
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
having count(*) > 1
union all
select 'Responsibility already end-dated (still included in the review)',
       employee_number,
       count(*) || ' rows'
  from xxcti_uar_employee_responsibilities
 where end_date is not null
   and end_date < trunc(sysdate)
 group by employee_number;
