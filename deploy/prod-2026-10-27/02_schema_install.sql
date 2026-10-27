-- ============================================================================
-- UAR : SCHEMA INSTALL, FIRST INSTALL ONLY (built from commit 05a43d7)
--
-- Run as XXUAR (SQL Workshop > SQL Scripts, or SQLcl) in a schema that has NO UAR objects yet.
-- It is NOT safe to run twice: the original table/sequence statements refuse to repeat.
--   PART A  original tables, sequences, indexes, base view   (01_uar_schema_ddl.sql)
--   PART B  this release's additions                         (01b_uar_release_hardening.sql)
--   PART C  packages, triggers, error handler                (02_uar_packages.sql)
-- The three source tables (Workday managers, responsibilities, responsibilities audit) are NOT
-- created here: they are feeds and must already exist (01_preflight_checks.sql checks this).
-- ============================================================================

-- ============================================================================
-- PART A
-- ============================================================================
-- ============================================================================
-- UAR (User Access Review) -- rebuild schema, phase 1
-- Run as XXUAR (or a user with DDL rights on that schema). Corrected
-- 2026-09-29 -- this previously said XXAPEX_EBS, assumed from the original
-- app 104 export rather than confirmed; the real schema is XXUAR in the
-- ct_bsg_apex workspace.
--
-- PREREQUISITES (assumed to already exist, fed by an external EBS/Workday
-- extract process -- NOT created by this script):
--   xxcti_uar_workday_employee_mgr (employee_id, manager_id,
--     employee_legal_first_name, employee_legal_last_name, email_address,
--     manager_first_name, manager_last_name, ...)
--   xxcti_uar_employee_responsibilities (employee_number, user_name,
--     responsibility, application, start_date, end_date, last_logon, ...)
--
-- Verify these column lists against the real DDL before running -- they're
-- inferred from the app 104 APEX export (UAR_Apex_Application_f104.sql),
-- not from a live DDL script.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Review cycles -- the piece the MVP never had. One row per review period
--    (e.g. "Q3 2026"), replacing the old single mutable audit snapshot with
--    a real historical record per period.
-- ----------------------------------------------------------------------------
create sequence xxcti_uar_cycle_id_seq start with 1 increment by 1;

create table xxcti_uar_review_cycles (
    cycle_id     number        not null,
    cycle_name   varchar2(120) not null,
    period_start date          not null,
    period_end   date          not null,
    due_date     date          not null,
    status       varchar2(10)  default 'OPEN' not null,
    created_by   varchar2(240) default sys_context('APEX$SESSION','APP_USER'),
    created_date date          default sysdate not null,
    closed_by    varchar2(240),
    closed_date  date,
    constraint xxcti_uar_review_cycles_pk primary key (cycle_id),
    constraint xxcti_uar_review_cycles_status_ck
        check (status in ('OPEN','CLOSED'))
);

comment on table xxcti_uar_review_cycles is
  'One row per access-review period. Only one row should normally be OPEN at a time -- see xxcti_uar_cycle_pkg.current_open_cycle.';

-- ----------------------------------------------------------------------------
-- 2. Review items -- replaces xxcti_uar_employee_responsibilities_audit.
--    Snapshotted from xxcti_uar_employee_responsibilities when a cycle
--    opens, so each cycle's approvals are a frozen, independent record
--    instead of one table being overwritten every period.
-- ----------------------------------------------------------------------------
create sequence xxcti_uar_review_item_id_seq start with 1 increment by 1;

create table xxcti_uar_review_items (
    review_item_id  number        not null,
    cycle_id        number        not null,
    employee_number varchar2(30)  not null,
    user_name       varchar2(4000),
    responsibility  varchar2(100),
    application     varchar2(240),
    start_date      date,
    end_date        date,
    last_logon      date,
    approval        varchar2(20),
    approver        varchar2(240),
    approval_date   date,
    comments        varchar2(4000),
    constraint xxcti_uar_review_items_pk primary key (review_item_id),
    constraint xxcti_uar_review_items_cycle_fk foreign key (cycle_id)
        references xxcti_uar_review_cycles (cycle_id),
    constraint xxcti_uar_review_items_appr_ck
        check (approval in ('Approved','Denied') or approval is null),
    constraint xxcti_uar_review_items_denial_ck
        check (approval <> 'Denied' or trim(comments) is not null)
);

create index xxcti_uar_review_items_cyc_ix on xxcti_uar_review_items (cycle_id);
create index xxcti_uar_review_items_emp_ix on xxcti_uar_review_items (employee_number);

comment on table xxcti_uar_review_items is
  'Cycle-scoped snapshot of one employee responsibility, one row per cycle_id/employee_number/responsibility/application combination at the time the cycle opened. This is the table Page 2 edits.';

-- ----------------------------------------------------------------------------
-- 2b. Review item history -- captures the prior approval state whenever a
--     review item's approval changes, so a manager revising their own
--     earlier decision (approve then later deny, or vice versa) before the
--     cycle closes doesn't silently erase the original decision and its
--     approver/date. Written by xxcti_uar_review_items_biu
--     (02_uar_packages.sql) before each approval change; the app never
--     writes to this table directly.
-- ----------------------------------------------------------------------------
create sequence xxcti_uar_review_items_hist_seq start with 1 increment by 1;

create table xxcti_uar_review_items_history (
    history_id        number        not null,
    review_item_id    number        not null,
    cycle_id          number        not null,
    employee_number   varchar2(30),
    old_approval      varchar2(20),
    old_approver      varchar2(240),
    old_approval_date date,
    old_comments      varchar2(4000),
    changed_by        varchar2(240) default sys_context('APEX$SESSION','APP_USER'),
    changed_date      date          default sysdate not null,
    constraint xxcti_uar_review_items_hist_pk primary key (history_id),
    constraint xxcti_uar_review_items_hist_fk foreign key (review_item_id)
        references xxcti_uar_review_items (review_item_id)
);

create index xxcti_uar_review_items_hist_ix on xxcti_uar_review_items_history (review_item_id);

comment on table xxcti_uar_review_items_history is
  'One row per prior approval state, written just before xxcti_uar_review_items.approval changes -- preserves the earlier approver/date/comments that would otherwise be silently overwritten if a manager revises their own decision before the cycle closes.';

-- ----------------------------------------------------------------------------
-- 2c. Manager sign-off. A manager submits their review once every item is
--     complete; the write-path trigger then locks their items for the rest
--     of the cycle (xxcti_uar_cycle_pkg.can_edit_item,
--     xxcti_uar_review_items_auth in 02_uar_packages.sql). Only an admin can
--     reopen a submission (Page 3), which is a plain delete of this row --
--     there is no separate "reopened" state to track.
-- ----------------------------------------------------------------------------
create table xxcti_uar_manager_signoffs (
    cycle_id       number        not null,
    manager_id     number        not null,
    submitted_by   varchar2(240) default sys_context('APEX$SESSION','APP_USER'),
    submitted_date date          default sysdate not null,
    constraint xxcti_uar_manager_signoffs_pk primary key (cycle_id, manager_id),
    constraint xxcti_uar_manager_signoffs_cyc_fk foreign key (cycle_id)
        references xxcti_uar_review_cycles (cycle_id)
);

comment on table xxcti_uar_manager_signoffs is
  'One row per manager who has submitted their review for a cycle. Presence of a row locks that manager''s items against further edits until an admin deletes it (xxcti_uar_cycle_pkg.reopen_review) or the cycle closes.';

-- ----------------------------------------------------------------------------
-- 3. Admin allow-list (carried over from the phase-1 security patch)
-- ----------------------------------------------------------------------------
create table xxcti_uar_admins (
    email_address varchar2(240) not null,
    added_by      varchar2(240) default sys_context('APEX$SESSION','APP_USER'),
    added_date    date default sysdate not null,
    constraint xxcti_uar_admins_pk primary key (email_address)
);

comment on table xxcti_uar_admins is
  'Email addresses (matched against APEX APP_USER) authorized to bypass manager-scoping and view admin-only pages/reports.';

-- Seed yourself so you can test end to end. Change the email first.
-- insert into xxcti_uar_admins (email_address) values ('your.email@company.com');
-- commit;

-- ----------------------------------------------------------------------------
-- 4. Progress view -- per manager, per cycle completion rollup. Powers the
--    Page 1 progress indicator and the admin Review Cycles dashboard.
-- ----------------------------------------------------------------------------
create or replace view xxcti_uar_cycle_progress as
select ri.cycle_id,
       uwe.manager_id,
       uwe.manager_first_name,
       uwe.manager_last_name,
       count(*)                                            as total_items,
       count(ri.approval)                                  as completed_items,
       round(count(ri.approval) / nullif(count(*),0) * 100) as pct_complete
  from xxcti_uar_review_items ri
  join xxcti_uar_workday_employee_mgr uwe
    on ri.employee_number = to_char(uwe.employee_id)
 group by ri.cycle_id, uwe.manager_id, uwe.manager_first_name, uwe.manager_last_name;

-- ----------------------------------------------------------------------------
-- Note on xxcti_uar_managers: the original app maintained this as a separate
-- table (manager, manager_id). The rebuild's Page 1 LOV derives the manager
-- list directly from xxcti_uar_workday_employee_mgr instead (see
-- APEX_BUILD_GUIDE.md), so xxcti_uar_managers is no longer required by the
-- new app. Not dropped here in case something else still reads it -- verify
-- before removing it.
-- ----------------------------------------------------------------------------

-- ============================================================================
-- PART B
-- ============================================================================
-- ============================================================================
-- UAR release hardening -- schema objects.
-- Run as XXUAR AFTER 01_uar_schema_ddl.sql and BEFORE 02_uar_packages.sql
-- (the packages reference the views and the log table created here).
-- Existing installs: run this file, then re-run 02_uar_packages.sql
-- (every statement in 02 is CREATE OR REPLACE). This file is safe to run again:
-- objects that already exist are left alone and the views are refreshed.
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
begin
    execute immediate q'~create unique index xxcti_uar_cycles_one_open_ux
    on xxcti_uar_review_cycles (case when status = 'OPEN' then 1 end)~';
exception
    when others then
        -- already installed (name in use / index or constraint exists): nothing to do
        if sqlcode not in (-955, -1408, -2264, -2275) then raise; end if;
end;
/

-- Cycle names are how admins tell cycles apart in the pickers.
begin
    execute immediate q'~create unique index xxcti_uar_cycles_name_ux
    on xxcti_uar_review_cycles (upper(cycle_name))~';
exception
    when others then
        -- already installed (name in use / index or constraint exists): nothing to do
        if sqlcode not in (-955, -1408, -2264, -2275) then raise; end if;
end;
/

begin
    execute immediate q'~alter table xxcti_uar_review_cycles add constraint xxcti_uar_review_cycles_dates_ck
    check (period_end >= period_start)~';
exception
    when others then
        -- already installed (name in use / index or constraint exists): nothing to do
        if sqlcode not in (-955, -1408, -2264, -2275) then raise; end if;
end;
/

-- ----------------------------------------------------------------------------
-- 2. Admin action log. Written by the packages (never directly by the app).
--    Deliberately has no foreign keys: a deleted cycle's log entries must
--    outlive it.
-- ----------------------------------------------------------------------------
begin
    execute immediate q'~create sequence xxcti_uar_admin_log_seq start with 1 increment by 1~';
exception
    when others then
        -- already installed (name in use / index or constraint exists): nothing to do
        if sqlcode not in (-955, -1408, -2264, -2275) then raise; end if;
end;
/

begin
    execute immediate q'~create table xxcti_uar_admin_log (
    log_id         number         not null,
    action         varchar2(40)   not null,
    cycle_id       number,
    detail         varchar2(4000),
    performed_by   varchar2(240)  default coalesce(sys_context('APEX$SESSION','APP_USER'), user),
    performed_date date           default sysdate not null,
    constraint xxcti_uar_admin_log_pk primary key (log_id)
)~';
exception
    when others then
        -- already installed (name in use / index or constraint exists): nothing to do
        if sqlcode not in (-955, -1408, -2264, -2275) then raise; end if;
end;
/

comment on table xxcti_uar_admin_log is
  'Who did what to cycles and the admin list: open, close, delete, reopen a submission, submit on behalf of a manager, add/remove admin. No FKs on purpose so entries outlive deleted cycles.';

-- ----------------------------------------------------------------------------
-- 3. Reviewer assignments. Workday decides who manages whom. When Workday gives
--    an employee NO usable manager (none on file, the manager has no row of
--    their own, or the employee is not in the feed at all) an admin can assign
--    a reviewer on Page 5. An assignment never overrides a manager Workday
--    knows about, and is ignored automatically once Workday supplies one.
-- ----------------------------------------------------------------------------
begin
    execute immediate q'~create table xxcti_uar_reviewer_overrides (
    employee_id   number         not null,
    reviewer_id   number         not null,
    reason        varchar2(400),
    assigned_by   varchar2(240)  default coalesce(sys_context('APEX$SESSION','APP_USER'), user),
    assigned_date date           default sysdate not null,
    constraint xxcti_uar_reviewer_ovr_pk primary key (employee_id),
    constraint xxcti_uar_reviewer_ovr_ck check (employee_id <> reviewer_id)
)~';
exception
    when others then
        -- already installed (name in use / index or constraint exists): nothing to do
        if sqlcode not in (-955, -1408, -2264, -2275) then raise; end if;
end;
/

comment on table xxcti_uar_reviewer_overrides is
  'Admin-assigned reviewer for an employee Workday gives no usable manager (top of the hierarchy, manager missing, or employee not in the feed). Only used while Workday has no manager for the employee.';

-- ----------------------------------------------------------------------------
-- 3b. The one place that answers "who reviews employee X?". Everything that
--     used to read manager_id straight from the Workday table reads this.
--     manager_source: WORKDAY, ASSIGNED (Page 5), or null = nobody can review.
--     workday_manager_id keeps the raw Workday value for diagnostics.
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- 3a. The Workday feed's id columns are text in some environments and numbers in others.
--     Everything new reads the ids through this view, which always gives numbers (a value
--     that is not a number becomes null instead of failing the query).
-- ----------------------------------------------------------------------------
create or replace view xxcti_uar_workday_norm as
select to_number(trim(employee_id) default null on conversion error) as employee_id,
       employee_legal_first_name,
       employee_legal_last_name,
       email_address,
       to_number(trim(manager_id) default null on conversion error)  as manager_id,
       manager_first_name,
       manager_last_name
  from xxcti_uar_workday_employee_mgr;

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
          from xxcti_uar_workday_norm
         where employee_id is not null
         group by employee_id) e
  left join (select employee_id, min(email_address) as email_address
               from xxcti_uar_workday_norm
              group by employee_id) mw
    on mw.employee_id = e.manager_id
  left join xxcti_uar_reviewer_overrides o
    on o.employee_id = e.employee_id
  left join (select employee_id,
                    min(employee_legal_first_name) as first_name,
                    min(employee_legal_last_name)  as last_name,
                    min(email_address)             as email_address
               from xxcti_uar_workday_norm
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
          from xxcti_uar_workday_norm
         group by employee_id) rw
    on rw.employee_id = o.reviewer_id
 where not exists (select 1 from xxcti_uar_workday_norm w
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
         when exists (select 1 from xxcti_uar_workday_norm w
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
                 when exists (select 1 from xxcti_uar_workday_norm w
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

-- ============================================================================
-- PART C
-- ============================================================================
-- ============================================================================
-- UAR rebuild -- packages, phase 1
-- Run after 01_uar_schema_ddl.sql, as XXUAR (corrected 2026-09-29, see
-- 01_uar_schema_ddl.sql header).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Security (carried over from the phase-1 patch, unchanged in shape).
-- 'Y'/'N' returns rather than boolean so every function here is callable
-- from both SQL (LOV queries, view predicates) and PL/SQL (page conditions,
-- process bodies) without a second wrapper -- see project memory on DECODE
-- being SQL-only for why mixing SQL-only and PL/SQL-only assumptions in the
-- same codebase is worth avoiding on principle.
-- ----------------------------------------------------------------------------
create or replace package xxcti_uar_security_pkg as

    function is_admin(
        p_app_user in varchar2 default sys_context('APEX$SESSION','APP_USER')
    ) return varchar2;

    -- Resolves the calling APEX user to their own employee_id via email
    -- match against xxcti_uar_workday_employee_mgr. Returns null if no match
    -- (e.g. the logged-in APEX account isn't also a Workday employee row).
    function resolve_employee_id(
        p_app_user in varchar2 default sys_context('APEX$SESSION','APP_USER')
    ) return varchar2;

    -- 'Y' if p_app_user may review p_employee_id: either an admin, or
    -- p_employee_id's manager_id resolves back to p_app_user's own
    -- employee_id.
    -- Never 'Y' for the caller's OWN access, admin or not: nobody approves
    -- their own responsibilities. Fails closed ('N') if the Workday data is
    -- ambiguous for that employee.
    function can_review(
        p_employee_id in varchar2,
        p_app_user    in varchar2 default sys_context('APEX$SESSION','APP_USER')
    ) return varchar2;

    -- Raises ORA-20050 unless the caller is an admin. Only enforced inside an
    -- APEX session: scripts run directly as the schema owner are trusted, the
    -- same way the update trigger documents for maintenance work.
    procedure require_admin;

    -- Appends to xxcti_uar_admin_log. Part of the caller's transaction.
    procedure log_action(
        p_action   in varchar2,
        p_cycle_id in number   default null,
        p_detail   in varchar2 default null
    );

    -- Admin-list maintenance (Page 7). Validates, enforces admin-only, logs.
    procedure add_admin(p_email in varchar2);
    procedure remove_admin(p_email in varchar2);

    -- Reviewer assignments (Page 5): give an employee Workday has no usable
    -- manager for (none, manager missing, or not in the feed) a reviewer. Admin
    -- only. Refused when Workday already provides a reviewer, when the reviewer
    -- is the employee, has no email on file, or reports (directly or
    -- indirectly) to the employee -- the review must be independent. Logged.
    procedure assign_reviewer(
        p_employee_id in number,
        p_reviewer_id in number,
        p_reason      in varchar2 default null
    );
    procedure remove_reviewer(p_employee_id in number);

end xxcti_uar_security_pkg;
/
show errors

create or replace package body xxcti_uar_security_pkg as

    function is_admin(
        p_app_user in varchar2 default sys_context('APEX$SESSION','APP_USER')
    ) return varchar2 is
        l_count number;
    begin
        select count(*)
          into l_count
          from xxcti_uar_admins
         where upper(email_address) = upper(p_app_user);

        return case when l_count > 0 then 'Y' else 'N' end;
    end is_admin;

    function resolve_employee_id(
        p_app_user in varchar2 default sys_context('APEX$SESSION','APP_USER')
    ) return varchar2 is
        l_employee_id varchar2(240);
    begin
        select to_char(employee_id)
          into l_employee_id
          from xxcti_uar_workday_employee_mgr
         where upper(email_address) = upper(p_app_user)
           and rownum = 1;

        return l_employee_id;
    exception
        when no_data_found then
            return null;
    end resolve_employee_id;

    function can_review(
        p_employee_id in varchar2,
        p_app_user    in varchar2 default sys_context('APEX$SESSION','APP_USER')
    ) return varchar2 is
        l_manager_id varchar2(240);
        l_self       varchar2(240);
    begin
        l_self := resolve_employee_id(p_app_user);

        -- Nobody reviews their own access -- admins included.
        if l_self is not null and l_self = p_employee_id then
            return 'N';
        end if;

        if is_admin(p_app_user) = 'Y' then
            return 'Y';
        end if;

        select to_char(manager_id)
          into l_manager_id
          from xxcti_uar_effective_mgr
         where to_char(employee_id) = p_employee_id;

        return case
                 when l_manager_id = l_self then 'Y'
                 else 'N'
               end;
    exception
        when no_data_found or too_many_rows then
            return 'N';
    end can_review;

    procedure require_admin is
        l_user varchar2(240) := sys_context('APEX$SESSION','APP_USER');
    begin
        if l_user is not null and is_admin(l_user) = 'N' then
            raise_application_error(-20050, 'Administrator access is required for this action.');
        end if;
    end require_admin;

    procedure log_action(
        p_action   in varchar2,
        p_cycle_id in number   default null,
        p_detail   in varchar2 default null
    ) is
    begin
        insert into xxcti_uar_admin_log (log_id, action, cycle_id, detail)
        values (xxcti_uar_admin_log_seq.nextval, p_action, p_cycle_id, substr(p_detail, 1, 4000));
    end log_action;

    procedure add_admin(p_email in varchar2) is
        l_email varchar2(240) := lower(trim(p_email));
        l_count number;
    begin
        require_admin;

        if l_email is null
           or not regexp_like(l_email, '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$') then
            raise_application_error(-20040, 'Enter a valid email address, for example name@company.com.');
        end if;

        select count(*) into l_count from xxcti_uar_admins where upper(email_address) = upper(l_email);
        if l_count > 0 then
            raise_application_error(-20041, l_email || ' is already an admin.');
        end if;

        insert into xxcti_uar_admins (email_address) values (l_email);
        log_action('ADD_ADMIN', null, l_email);
        commit;
    end add_admin;

    procedure remove_admin(p_email in varchar2) is
        l_email varchar2(240) := lower(trim(p_email));
    begin
        require_admin;

        if upper(l_email) = upper(sys_context('APEX$SESSION','APP_USER')) then
            raise_application_error(-20002, 'You cannot remove your own admin access from here.');
        end if;

        delete from xxcti_uar_admins where upper(email_address) = upper(l_email);
        if sql%rowcount = 0 then
            raise_application_error(-20042, l_email || ' is not in the admin list.');
        end if;

        log_action('REMOVE_ADMIN', null, l_email);
        commit;
    end remove_admin;

    procedure assign_reviewer(
        p_employee_id in number,
        p_reviewer_id in number,
        p_reason      in varchar2 default null
    ) is
        l_n      number;
        l_old    number;
        l_reason varchar2(400) := substr(trim(p_reason), 1, 400);
        l_emp    varchar2(400);
        l_rev    varchar2(400);
    begin
        require_admin;

        if p_employee_id is null or p_reviewer_id is null then
            raise_application_error(-20066, 'Choose both an employee and a reviewer.');
        end if;
        if p_employee_id = p_reviewer_id then
            raise_application_error(-20060, 'Nobody can be their own reviewer.');
        end if;

        select count(*) into l_n
          from xxcti_uar_workday_norm
         where employee_id = p_reviewer_id and email_address is not null;
        if l_n = 0 then
            raise_application_error(-20061,
                'The reviewer must be an employee with an email address on file, so they can sign in.');
        end if;

        select count(*) into l_n from (
            select 1 from xxcti_uar_workday_norm where employee_id = p_employee_id
            union all
            select 1 from xxcti_uar_employee_responsibilities where employee_number = to_char(p_employee_id));
        if l_n = 0 then
            raise_application_error(-20063,
                'That employee is not in the Workday data or the responsibilities data.');
        end if;

        select count(*) into l_n
          from xxcti_uar_effective_mgr
         where employee_id = p_employee_id and manager_source = 'WORKDAY';
        if l_n > 0 then
            raise_application_error(-20062,
                'Workday already provides a reviewer for this employee, so one cannot be assigned here.');
        end if;

        -- independence: the reviewer's own management chain must not contain the employee
        select count(*) into l_n from (
            select employee_id
              from xxcti_uar_workday_norm
             start with employee_id = p_reviewer_id
           connect by nocycle prior manager_id = employee_id)
         where employee_id = p_employee_id;
        if l_n > 0 then
            raise_application_error(-20064,
                'That reviewer reports (directly or indirectly) to this employee, so the review would not be independent.');
        end if;

        select nvl(min(employee_legal_first_name || ' ' || employee_legal_last_name), to_char(p_employee_id))
          into l_emp from xxcti_uar_workday_norm where employee_id = p_employee_id;
        select min(employee_legal_first_name || ' ' || employee_legal_last_name)
          into l_rev from xxcti_uar_workday_norm where employee_id = p_reviewer_id;

        begin
            select reviewer_id into l_old from xxcti_uar_reviewer_overrides where employee_id = p_employee_id;
            update xxcti_uar_reviewer_overrides
               set reviewer_id   = p_reviewer_id,
                   reason        = l_reason,
                   assigned_by   = coalesce(sys_context('APEX$SESSION','APP_USER'), user),
                   assigned_date = sysdate
             where employee_id = p_employee_id;
            log_action('CHANGE_REVIEWER', null,
                l_emp || ' (' || p_employee_id || '): reviewer ' || l_old || ' -> ' || l_rev || ' (' || p_reviewer_id || ')' ||
                case when l_reason is not null then '. ' || l_reason end);
        exception
            when no_data_found then
                insert into xxcti_uar_reviewer_overrides (employee_id, reviewer_id, reason)
                values (p_employee_id, p_reviewer_id, l_reason);
                log_action('ASSIGN_REVIEWER', null,
                    l_emp || ' (' || p_employee_id || ') -> reviewer ' || l_rev || ' (' || p_reviewer_id || ')' ||
                    case when l_reason is not null then '. ' || l_reason end);
        end;
        commit;
    end assign_reviewer;

    procedure remove_reviewer(p_employee_id in number) is
        l_rev number;
    begin
        require_admin;

        begin
            select reviewer_id into l_rev from xxcti_uar_reviewer_overrides where employee_id = p_employee_id;
        exception
            when no_data_found then
                raise_application_error(-20065, 'That employee has no assigned reviewer.');
        end;

        delete from xxcti_uar_reviewer_overrides where employee_id = p_employee_id;
        log_action('REMOVE_REVIEWER', null,
            'Employee ' || p_employee_id || ': removed assigned reviewer ' || l_rev || '.');
        commit;
    end remove_reviewer;

end xxcti_uar_security_pkg;
/
show errors

-- ----------------------------------------------------------------------------
-- Cycle management.
-- Every state-changing procedure here validates for itself: the Page 3/Page 1
-- buttons being hidden or role-gated is a convenience, not the control.
-- Error codes: -20001 cycle already open, -20010..-20014 open_cycle input,
-- -20015..-20018 close/delete state, -20030..-20034 sign-off, -20050 not admin.
-- ----------------------------------------------------------------------------
create or replace package xxcti_uar_cycle_pkg as

    -- Returns the currently OPEN cycle_id, or null if none is open.
    function current_open_cycle return number;

    -- Admin only. Opens a new cycle and snapshots every row currently in
    -- xxcti_uar_employee_responsibilities into xxcti_uar_review_items for it.
    -- Raises if a cycle is already open, the inputs are invalid, the name is
    -- taken, or there is nothing to review. Logged.
    procedure open_cycle(
        p_cycle_name   in varchar2,
        p_period_start in date,
        p_period_end   in date,
        p_due_date     in date,
        p_cycle_id     out number
    );

    -- Admin only. Closes an OPEN cycle. Items left with a null approval stay
    -- null -- closing does not force-approve or force-deny anything; it
    -- locks the cycle's items against further edits. Raises if the cycle does
    -- not exist or is already closed. Logged, with how much was still pending.
    procedure close_cycle(p_cycle_id in number);

    -- 'Y'/'N' -- whether p_cycle_id currently accepts edits.
    function can_edit_cycle(p_cycle_id in number) return varchar2;

    -- 'Y'/'N' -- whether p_manager_id has already submitted their review for
    -- p_cycle_id (a row exists in xxcti_uar_manager_signoffs).
    function manager_signed_off(p_cycle_id in number, p_manager_id in number) return varchar2;

    -- 'Y'/'N' -- whether a specific review item may still be edited: the
    -- cycle must be open AND the item's manager must not have submitted.
    -- Both the Page 2/8 load gates and the xxcti_uar_review_items_auth
    -- trigger call this. Resolves the manager from p_employee_number itself
    -- rather than trusting a caller-supplied manager id. Fails closed.
    function can_edit_item(p_employee_number in varchar2, p_cycle_id in number) return varchar2;

    -- Records that p_manager_id has submitted their review for p_cycle_id.
    -- Validates: cycle open, manager exists and has items, the caller is that
    -- manager (or an admin, which is logged as a submit-on-behalf), and no
    -- item is still pending. Idempotent for an already-submitted manager.
    procedure submit_review(p_cycle_id in number, p_manager_id in number);

    -- Admin only. Undoes a submission, unlocking that manager's items again.
    -- Raises if there is no submission to undo. Logged.
    procedure reopen_review(p_cycle_id in number, p_manager_id in number);

    -- Admin only. Permanently deletes an OPEN cycle and everything in it --
    -- meant for cleaning up a cycle opened by mistake. CLOSED cycles are the
    -- audit record and can never be deleted here. Logged, with what was
    -- discarded.
    procedure delete_cycle(p_cycle_id in number);

end xxcti_uar_cycle_pkg;
/
show errors

create or replace package body xxcti_uar_cycle_pkg as

    function current_open_cycle return number is
        l_cycle_id number;
    begin
        select cycle_id
          into l_cycle_id
          from xxcti_uar_review_cycles
         where status = 'OPEN'
           and rownum = 1;

        return l_cycle_id;
    exception
        when no_data_found then
            return null;
    end current_open_cycle;

    procedure open_cycle(
        p_cycle_name   in varchar2,
        p_period_start in date,
        p_period_end   in date,
        p_due_date     in date,
        p_cycle_id     out number
    ) is
        l_existing   number;
        l_name       varchar2(120) := trim(p_cycle_name);
        l_count      number;
        l_items      number;
        l_unassigned number;
    begin
        xxcti_uar_security_pkg.require_admin;

        if l_name is null or p_period_start is null or p_period_end is null or p_due_date is null then
            raise_application_error(-20010,
                'Cycle name, period start, period end, and due date are all required.');
        end if;
        if p_period_end < p_period_start then
            raise_application_error(-20011, 'Period end cannot be earlier than period start.');
        end if;
        if trunc(p_due_date) < trunc(sysdate) then
            raise_application_error(-20012, 'Due date cannot be in the past.');
        end if;

        l_existing := current_open_cycle;
        if l_existing is not null then
            raise_application_error(
                -20001,
                'Cycle ' || l_existing || ' is already open -- close it before opening a new one.'
            );
        end if;

        select count(*) into l_count
          from xxcti_uar_review_cycles where upper(cycle_name) = upper(l_name);
        if l_count > 0 then
            raise_application_error(-20013,
                'A cycle named "' || l_name || '" already exists. Choose a different name.');
        end if;

        select count(*) into l_count from xxcti_uar_employee_responsibilities;
        if l_count = 0 then
            raise_application_error(-20014,
                'There are no responsibilities to review, so a cycle would be empty.');
        end if;

        select xxcti_uar_cycle_id_seq.nextval into p_cycle_id from dual;

        insert into xxcti_uar_review_cycles (
            cycle_id, cycle_name, period_start, period_end, due_date, status
        ) values (
            p_cycle_id, l_name, p_period_start, p_period_end, p_due_date, 'OPEN'
        );

        -- last_logon is not on xxcti_uar_employee_responsibilities; the real
        -- source is the old MVP's audit table, matched by employee/
        -- responsibility/application. A scalar MAX() subquery, not a join, so
        -- a duplicate match there can't multiply snapshot rows. Best-available,
        -- not guaranteed-current (see README).
        insert into xxcti_uar_review_items (
            review_item_id, cycle_id, employee_number, user_name,
            responsibility, application, start_date, end_date, last_logon
        )
        select xxcti_uar_review_item_id_seq.nextval,
               p_cycle_id,
               er.employee_number,
               er.user_name,
               er.responsibility,
               er.application,
               er.start_date,
               er.end_date,
               (select max(aud.last_logon)
                  from xxcti_uar_employee_responsibilities_audit aud
                 where aud.employee_number = er.employee_number
                   and aud.responsibility  = er.responsibility
                   and aud.application     = er.application)
          from xxcti_uar_employee_responsibilities er;
        l_items := sql%rowcount;

        select count(*) into l_unassigned
          from xxcti_uar_unassigned_items where cycle_id = p_cycle_id;

        xxcti_uar_security_pkg.log_action('OPEN_CYCLE', p_cycle_id,
            'Opened "' || l_name || '": ' || l_items || ' items, ' || l_unassigned ||
            ' with no reachable reviewer.');

        commit;
    end open_cycle;

    procedure close_cycle(p_cycle_id in number) is
        l_status  varchar2(10);
        l_total   number;
        l_pending number;
    begin
        xxcti_uar_security_pkg.require_admin;

        begin
            select status into l_status
              from xxcti_uar_review_cycles
             where cycle_id = p_cycle_id
               for update;
        exception
            when no_data_found then
                raise_application_error(-20015, 'That cycle does not exist.');
        end;

        if l_status <> 'OPEN' then
            raise_application_error(-20016, 'That cycle is already closed.');
        end if;

        select count(*), count(*) - count(approval)
          into l_total, l_pending
          from xxcti_uar_review_items
         where cycle_id = p_cycle_id;

        update xxcti_uar_review_cycles
           set status      = 'CLOSED',
               closed_by   = sys_context('APEX$SESSION','APP_USER'),
               closed_date = sysdate
         where cycle_id = p_cycle_id;

        xxcti_uar_security_pkg.log_action('CLOSE_CYCLE', p_cycle_id,
            'Closed with ' || l_pending || ' of ' || l_total || ' items still pending.');

        commit;
    end close_cycle;

    function can_edit_cycle(p_cycle_id in number) return varchar2 is
        l_status varchar2(10);
    begin
        select status
          into l_status
          from xxcti_uar_review_cycles
         where cycle_id = p_cycle_id;

        return case when l_status = 'OPEN' then 'Y' else 'N' end;
    exception
        when no_data_found then
            return 'N';
    end can_edit_cycle;

    function manager_signed_off(p_cycle_id in number, p_manager_id in number) return varchar2 is
        l_count number;
    begin
        select count(*)
          into l_count
          from xxcti_uar_manager_signoffs
         where cycle_id = p_cycle_id
           and manager_id = p_manager_id;

        return case when l_count > 0 then 'Y' else 'N' end;
    end manager_signed_off;

    function can_edit_item(p_employee_number in varchar2, p_cycle_id in number) return varchar2 is
        l_manager_id number;
    begin
        if can_edit_cycle(p_cycle_id) = 'N' then
            return 'N';
        end if;

        select manager_id
          into l_manager_id
          from xxcti_uar_effective_mgr
         where to_char(employee_id) = p_employee_number;

        -- no reviewer at all (see Page 5): fail closed
        if l_manager_id is null then
            return 'N';
        end if;

        return case when manager_signed_off(p_cycle_id, l_manager_id) = 'Y' then 'N' else 'Y' end;
    exception
        when no_data_found or too_many_rows then
            return 'N';
    end can_edit_item;

    procedure submit_review(p_cycle_id in number, p_manager_id in number) is
        l_user    varchar2(240) := sys_context('APEX$SESSION','APP_USER');
        l_count   number;
        l_pending number;
        l_total   number;
    begin
        if can_edit_cycle(p_cycle_id) = 'N' then
            raise_application_error(-20030, 'This review cycle is closed or does not exist.');
        end if;

        select count(*) into l_count
          from xxcti_uar_effective_mgr where manager_id = p_manager_id;
        if l_count = 0 then
            raise_application_error(-20031, 'That manager does not exist.');
        end if;

        if l_user is not null
           and xxcti_uar_security_pkg.is_admin(l_user) = 'N'
           and nvl(xxcti_uar_security_pkg.resolve_employee_id(l_user), '-') <> to_char(p_manager_id) then
            raise_application_error(-20032, 'You can only submit your own review.');
        end if;

        -- already submitted: nothing to do
        if manager_signed_off(p_cycle_id, p_manager_id) = 'Y' then
            return;
        end if;

        select count(*), count(*) - count(ri.approval)
          into l_total, l_pending
          from xxcti_uar_review_items ri
         where ri.cycle_id = p_cycle_id
           and ri.employee_number in (
                 select to_char(employee_id)
                   from xxcti_uar_effective_mgr
                  where manager_id = p_manager_id);

        if l_total = 0 then
            raise_application_error(-20034, 'There are no items assigned for this cycle, so there is nothing to submit.');
        end if;
        if l_pending > 0 then
            raise_application_error(-20033,
                l_pending || ' item(s) are still pending. Approve or deny every item before submitting.');
        end if;

        insert into xxcti_uar_manager_signoffs (cycle_id, manager_id)
        values (p_cycle_id, p_manager_id);

        if l_user is not null
           and nvl(xxcti_uar_security_pkg.resolve_employee_id(l_user), '-') <> to_char(p_manager_id) then
            xxcti_uar_security_pkg.log_action('SUBMIT_ON_BEHALF', p_cycle_id,
                'Admin ' || l_user || ' submitted the review for manager ' || p_manager_id || '.');
        end if;

        commit;
    exception
        when dup_val_on_index then
            null;
    end submit_review;

    procedure reopen_review(p_cycle_id in number, p_manager_id in number) is
    begin
        xxcti_uar_security_pkg.require_admin;

        delete from xxcti_uar_manager_signoffs
         where cycle_id = p_cycle_id
           and manager_id = p_manager_id;
        if sql%rowcount = 0 then
            raise_application_error(-20017, 'That manager has no submission to reopen.');
        end if;

        xxcti_uar_security_pkg.log_action('REOPEN_REVIEW', p_cycle_id,
            'Reopened the submission of manager ' || p_manager_id || '.');
        commit;
    end reopen_review;

    procedure delete_cycle(p_cycle_id in number) is
        l_status   varchar2(10);
        l_name     varchar2(120);
        l_items    number;
        l_decided  number;
    begin
        xxcti_uar_security_pkg.require_admin;

        begin
            select status, cycle_name into l_status, l_name
              from xxcti_uar_review_cycles
             where cycle_id = p_cycle_id
               for update;
        exception
            when no_data_found then
                raise_application_error(-20015, 'That cycle does not exist.');
        end;

        if l_status <> 'OPEN' then
            raise_application_error(-20018,
                'Closed cycles are part of the audit record and cannot be deleted.');
        end if;

        select count(*), count(approval)
          into l_items, l_decided
          from xxcti_uar_review_items
         where cycle_id = p_cycle_id;

        delete from xxcti_uar_manager_signoffs where cycle_id = p_cycle_id;
        delete from xxcti_uar_review_items_history
         where review_item_id in (
            select review_item_id from xxcti_uar_review_items where cycle_id = p_cycle_id
         );
        delete from xxcti_uar_review_items where cycle_id = p_cycle_id;
        delete from xxcti_uar_review_cycles where cycle_id = p_cycle_id;

        xxcti_uar_security_pkg.log_action('DELETE_CYCLE', p_cycle_id,
            'Deleted open cycle "' || l_name || '": discarded ' || l_items ||
            ' items, ' || l_decided || ' with a recorded decision.');
        commit;
    end delete_cycle;

end xxcti_uar_cycle_pkg;
/
show errors

-- ----------------------------------------------------------------------------
-- Audit-trail stamping. APPROVER/APPROVAL_DATE were never populated by
-- anything in the original MVP -- this closes that gap at the table level so
-- it holds regardless of how the update arrives (Page 2's IG, a future API,
-- a script). Also writes the prior approval state to
-- xxcti_uar_review_items_history before overwriting it -- otherwise a
-- manager revising their own earlier decision (approve then later deny, or
-- vice versa) before the cycle closes would silently erase the original
-- decision with no trace.
-- ----------------------------------------------------------------------------
create or replace trigger xxcti_uar_review_items_biu
    before update on xxcti_uar_review_items
    for each row
    when (nvl(new.approval, 'x') != nvl(old.approval, 'x')
       or nvl(new.comments, '~') != nvl(old.comments, '~'))
begin
    insert into xxcti_uar_review_items_history (
        history_id, review_item_id, cycle_id, employee_number,
        old_approval, old_approver, old_approval_date, old_comments
    ) values (
        xxcti_uar_review_items_hist_seq.nextval, :old.review_item_id, :old.cycle_id, :old.employee_number,
        :old.approval, :old.approver, :old.approval_date, :old.comments
    );

    :new.approver      := coalesce(sys_context('APEX$SESSION','APP_USER'), user);
    :new.approval_date := sysdate;
end;
/
show errors

-- ----------------------------------------------------------------------------
-- Write-path authorization. The page-load gates on Page 2 do not cover saves:
-- the Interactive Grid updates rows by primary key, so every update must be
-- checked here, at the table, whatever channel it arrives through. Admin
-- maintenance outside an APEX session is blocked too; use a privileged
-- correction script with this trigger disabled, and say so in the change log.
-- ----------------------------------------------------------------------------
create or replace trigger xxcti_uar_review_items_auth
    before update on xxcti_uar_review_items
    for each row
begin
    if xxcti_uar_cycle_pkg.can_edit_item(:old.employee_number, :old.cycle_id) = 'N' then
        raise_application_error(-20020,
            'This review cycle is closed, or this manager''s review has already been ' ||
            'submitted; items can no longer be changed.');
    end if;

    if xxcti_uar_security_pkg.can_review(:old.employee_number) = 'N' then
        raise_application_error(-20021,
            'You are not authorized to review this employee.');
    end if;

    -- Same rule as xxcti_uar_review_items_denial_ck (01_uar_schema_ddl.sql), checked
    -- here first so the user sees this message instead of the constraint's raw
    -- ORA-02290 -- the constraint stays as a backstop for anything that updates the
    -- table outside this trigger's reach.
    if :new.approval = 'Denied' and trim(:new.comments) is null then
        raise_application_error(-20022,
            'A comment is required when denying an item -- please explain why before saving.');
    end if;
end;
/
show errors

-- ----------------------------------------------------------------------------
-- Application error handler (Shared Components > Application Definition >
-- Error Handling Function). The packages raise their rule violations with
-- raise_application_error (-20000..-20999) and write the text for people, so
-- show that text without the "ORA-20xxx:" prefix. Everything else (genuine
-- bugs, constraint violations, APEX's own errors) is left exactly as APEX
-- would show it.
-- ----------------------------------------------------------------------------
create or replace function xxcti_uar_error_handler(
    p_error in apex_error.t_error
) return apex_error.t_error_result is
    l_result apex_error.t_error_result;
begin
    l_result := apex_error.init_error_result(p_error => p_error);

    if not p_error.is_internal_error
       and p_error.ora_sqlcode between -20999 and -20000 then
        l_result.message         := apex_error.get_first_ora_error_text(p_error => p_error);
        l_result.additional_info := null;
    end if;

    return l_result;
end xxcti_uar_error_handler;
/
show errors

-- ----------------------------------------------------------------------------
-- SSO post-authentication hook. Standalone (not packaged), matching PMO Hub's
-- xxcti_pmo_sso_post_auth -- APEX's "Post-Authentication Procedure Name" field
-- on an authentication scheme expects a plain procedure name, and this is the
-- proven-working shape for that. Unlike PMO Hub's version, this is a genuine
-- no-op: UAR has no registration allow-list table and no login gate -- any
-- authenticated account may open the app, scoped afterward by
-- xxcti_uar_security_pkg.is_admin / resolve_employee_id as already happens
-- today for native APEX accounts. Confirmed 2026-10-12 as the real cause of a
-- PLS-00201 "must be declared" error: UAR's authentication scheme had been
-- pointed directly at PMO Hub's xxcti_pmo_sso_post_auth, which doesn't exist
-- in this schema. After running this, update the authentication scheme's
-- Post-Authentication Procedure Name field to XXCTI_UAR_SSO_POST_AUTH.
-- ----------------------------------------------------------------------------
create or replace procedure xxcti_uar_sso_post_auth as
begin
    null;
end xxcti_uar_sso_post_auth;
/
show errors

-- ----------------------------------------------------------------------------
-- Standalone smoke tests -- run after seeding xxcti_uar_admins in
-- 01_uar_schema_ddl.sql, before touching APEX at all.
-- ----------------------------------------------------------------------------
-- select xxcti_uar_security_pkg.is_admin('your.email@company.com') from dual;
-- select xxcti_uar_security_pkg.resolve_employee_id('some.manager@company.com') from dual;
-- select xxcti_uar_security_pkg.can_review('12345', 'some.manager@company.com') from dual;
-- select xxcti_uar_cycle_pkg.current_open_cycle from dual;
--
-- declare
--     l_cycle_id number;
-- begin
--     xxcti_uar_cycle_pkg.open_cycle(
--         p_cycle_name   => 'Q4 2026 Test Cycle',
--         p_period_start => date '2026-10-01',
--         p_period_end   => date '2026-12-31',
--         p_due_date     => date '2026-10-15',
--         p_cycle_id     => l_cycle_id
--     );
--     dbms_output.put_line('Opened cycle ' || l_cycle_id);
-- end;
-- /
