-- ============================================================================
-- ROLLBACK 1 of 3: restore the PREVIOUS release's packages, triggers and progress view
-- (as of 416c666). Run as XXUAR. The new tables/views stay in place (harmless) -- see R3.
-- Re-import the previous application too (R2), or the new app will call packages that no longer exist.
-- ============================================================================

-- previous progress view
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
    function can_review(
        p_employee_id in varchar2,
        p_app_user    in varchar2 default sys_context('APEX$SESSION','APP_USER')
    ) return varchar2;

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
    begin
        if is_admin(p_app_user) = 'Y' then
            return 'Y';
        end if;

        select to_char(manager_id)
          into l_manager_id
          from xxcti_uar_workday_employee_mgr
         where to_char(employee_id) = p_employee_id;

        return case
                 when l_manager_id = resolve_employee_id(p_app_user) then 'Y'
                 else 'N'
               end;
    exception
        when no_data_found then
            return 'N';
    end can_review;

end xxcti_uar_security_pkg;
/
show errors

-- ----------------------------------------------------------------------------
-- Cycle management -- new for the rebuild.
-- ----------------------------------------------------------------------------
create or replace package xxcti_uar_cycle_pkg as

    -- Returns the currently OPEN cycle_id, or null if none is open.
    function current_open_cycle return number;

    -- Opens a new cycle and snapshots every row currently in
    -- xxcti_uar_employee_responsibilities into xxcti_uar_review_items for
    -- it. Raises an application error if a cycle is already open (close it
    -- first) -- deliberately only one open cycle at a time, to keep "which
    -- cycle am I reviewing" unambiguous on Page 1.
    procedure open_cycle(
        p_cycle_name   in varchar2,
        p_period_start in date,
        p_period_end   in date,
        p_due_date     in date,
        p_cycle_id     out number
    );

    -- Closes a cycle. Items left with a null approval stay null -- closing
    -- does not force-approve or force-deny anything; it just locks the
    -- cycle's items against further edits (enforced by can_edit_cycle,
    -- called from the Page 2 BEFORE_HEADER gate in APEX_BUILD_GUIDE.md).
    procedure close_cycle(p_cycle_id in number);

    -- 'Y'/'N' -- whether p_cycle_id currently accepts edits.
    function can_edit_cycle(p_cycle_id in number) return varchar2;

    -- 'Y'/'N' -- whether p_manager_id has already submitted their review for
    -- p_cycle_id (a row exists in xxcti_uar_manager_signoffs).
    function manager_signed_off(p_cycle_id in number, p_manager_id in number) return varchar2;

    -- 'Y'/'N' -- whether a specific review item may still be edited: the
    -- cycle must be open AND the item's manager must not have submitted.
    -- This is the one check both the Page 2 load gate and the
    -- xxcti_uar_review_items_auth trigger call, so both enforce the same
    -- rule. Resolves the manager from p_employee_number itself rather than
    -- trusting a caller-supplied manager id.
    function can_edit_item(p_employee_number in varchar2, p_cycle_id in number) return varchar2;

    -- Records that p_manager_id has submitted their review for p_cycle_id.
    -- Idempotent -- submitting twice is a no-op, not an error. Page 1 only
    -- offers this once every item is complete, but the check is not
    -- re-validated here; the caller (the page) is responsible for only
    -- offering it when true.
    procedure submit_review(p_cycle_id in number, p_manager_id in number);

    -- Undoes a submission, unlocking that manager's items again. Admin UI
    -- only (Page 3).
    procedure reopen_review(p_cycle_id in number, p_manager_id in number);

    -- Permanently deletes a cycle and every review item in it -- including
    -- any approval/denial/comment history already recorded. No undo. Admin
    -- UI only (Page 6), intended for cleaning up test/mistake cycles.
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
        l_existing number;
    begin
        l_existing := current_open_cycle;
        if l_existing is not null then
            raise_application_error(
                -20001,
                'Cycle ' || l_existing || ' is already open -- close it before opening a new one.'
            );
        end if;

        select xxcti_uar_cycle_id_seq.nextval into p_cycle_id from dual;

        insert into xxcti_uar_review_cycles (
            cycle_id, cycle_name, period_start, period_end, due_date, status
        ) values (
            p_cycle_id, p_cycle_name, p_period_start, p_period_end, p_due_date, 'OPEN'
        );

        -- xxcti_uar_employee_responsibilities has no last_logon column (confirmed
        -- against user_tab_columns 2026-09-28). The real source is the old MVP's
        -- audit table (xxcti_uar_employee_responsibilities_audit), confirmed
        -- 2026-10-12 to still carry last_logon by employee/responsibility/
        -- application -- whether it's still actively refreshed by its external
        -- process isn't confirmed, so treat this as best-available, not
        -- guaranteed-current. A scalar MAX() subquery, not a join, so a
        -- duplicate match in the audit table can't multiply snapshot rows.
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

        commit;
    end open_cycle;

    procedure close_cycle(p_cycle_id in number) is
    begin
        update xxcti_uar_review_cycles
           set status      = 'CLOSED',
               closed_by   = sys_context('APEX$SESSION','APP_USER'),
               closed_date = sysdate
         where cycle_id = p_cycle_id;

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
          from xxcti_uar_workday_employee_mgr
         where to_char(employee_id) = p_employee_number;

        return case when manager_signed_off(p_cycle_id, l_manager_id) = 'Y' then 'N' else 'Y' end;
    exception
        when no_data_found then
            return 'N';
    end can_edit_item;

    procedure submit_review(p_cycle_id in number, p_manager_id in number) is
    begin
        insert into xxcti_uar_manager_signoffs (cycle_id, manager_id)
        values (p_cycle_id, p_manager_id);
        commit;
    exception
        when dup_val_on_index then
            null;
    end submit_review;

    procedure reopen_review(p_cycle_id in number, p_manager_id in number) is
    begin
        delete from xxcti_uar_manager_signoffs
         where cycle_id = p_cycle_id
           and manager_id = p_manager_id;
        commit;
    end reopen_review;

    procedure delete_cycle(p_cycle_id in number) is
    begin
        delete from xxcti_uar_manager_signoffs where cycle_id = p_cycle_id;
        delete from xxcti_uar_review_items_history
         where review_item_id in (
            select review_item_id from xxcti_uar_review_items where cycle_id = p_cycle_id
         );
        delete from xxcti_uar_review_items where cycle_id = p_cycle_id;
        delete from xxcti_uar_review_cycles where cycle_id = p_cycle_id;
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
    when (nvl(new.approval, 'x') != nvl(old.approval, 'x'))
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
