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
  'One row per access-review period. Only one row should normally be OPEN '
  || 'at a time -- see xxcti_uar_cycle_pkg.current_open_cycle.';

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
        check (approval in ('Approved','Denied') or approval is null)
);

create index xxcti_uar_review_items_cyc_ix on xxcti_uar_review_items (cycle_id);
create index xxcti_uar_review_items_emp_ix on xxcti_uar_review_items (employee_number);

comment on table xxcti_uar_review_items is
  'Cycle-scoped snapshot of one employee responsibility, one row per '
  || 'cycle_id/employee_number/responsibility/application combination at the '
  || 'time the cycle opened. This is the table Page 2 edits.';

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
  'One row per prior approval state, written just before xxcti_uar_review_items.approval '
  || 'changes -- preserves the earlier approver/date/comments that would otherwise be '
  || 'silently overwritten if a manager revises their own decision before the cycle closes.';

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
  'Email addresses (matched against APEX APP_USER) authorized to bypass '
  || 'manager-scoping and view admin-only pages/reports.';

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
