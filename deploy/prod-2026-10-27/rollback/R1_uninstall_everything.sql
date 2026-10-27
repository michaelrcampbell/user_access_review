-- ============================================================================
-- UNINSTALL: removes every UAR object the install created. DESTRUCTIVE - all cycles, decisions,
-- history, the admin log and reviewer assignments are DELETED and cannot be recovered.
-- It never touches the three source feeds (xxcti_uar_workday_employee_mgr,
-- xxcti_uar_employee_responsibilities, xxcti_uar_employee_responsibilities_audit).
-- The application itself is removed separately (see the README).
-- To run it, change l_confirm below from 'NO' to 'YES'. Run as XXUAR.
-- ============================================================================

set serveroutput on
declare
    l_confirm varchar2(3) := 'NO';   -- <<< change to 'YES' to proceed

    procedure drop_it(p_sql varchar2) is
    begin
        execute immediate p_sql;
    exception when others then
        if sqlcode not in (-942, -4043, -2289, -1418, -4042, -4080) then raise; end if;
    end;
begin
    if l_confirm <> 'YES' then
        dbms_output.put_line('Nothing was removed. Set l_confirm to YES to uninstall.');
        return;
    end if;
        drop_it('drop trigger xxcti_uar_review_items_biu');
        drop_it('drop trigger xxcti_uar_review_items_auth');
        drop_it('drop package xxcti_uar_cycle_pkg');
        drop_it('drop package xxcti_uar_security_pkg');
        drop_it('drop procedure xxcti_uar_sso_post_auth');
        drop_it('drop function xxcti_uar_error_handler');
        drop_it('drop view xxcti_uar_unassigned_employees');
        drop_it('drop view xxcti_uar_unassigned_items');
        drop_it('drop view xxcti_uar_data_issues');
        drop_it('drop view xxcti_uar_cycle_progress');
        drop_it('drop view xxcti_uar_effective_mgr');
        drop_it('drop view xxcti_uar_workday_norm');
        drop_it('drop table xxcti_uar_review_items_history cascade constraints purge');
        drop_it('drop table xxcti_uar_manager_signoffs cascade constraints purge');
        drop_it('drop table xxcti_uar_review_items cascade constraints purge');
        drop_it('drop table xxcti_uar_review_cycles cascade constraints purge');
        drop_it('drop table xxcti_uar_reviewer_overrides cascade constraints purge');
        drop_it('drop table xxcti_uar_admin_log cascade constraints purge');
        drop_it('drop table xxcti_uar_admins cascade constraints purge');
        drop_it('drop sequence xxcti_uar_cycle_id_seq');
        drop_it('drop sequence xxcti_uar_review_item_id_seq');
        drop_it('drop sequence xxcti_uar_review_items_hist_seq');
        drop_it('drop sequence xxcti_uar_admin_log_seq');
    dbms_output.put_line('UAR objects removed.');
end;
/
