-- ============================================================================
-- OPTIONAL -- one-time migration of the old MVP's audit data into the new
-- cycle model, as a single "Legacy" closed cycle, so existing approval
-- history isn't lost. Skip this if there's no data worth carrying over.
--
-- Run after 01_uar_schema_ddl.sql and 02_uar_packages.sql.
--
-- Verify xxcti_uar_employee_responsibilities_audit's real column list
-- before running -- inferred here from the app 104 APEX export
-- (UAR_Apex_Application_f104.sql), not from a live DDL script. Adjust the
-- select list if any names differ.
-- ============================================================================

declare
    l_cycle_id number;
begin
    l_cycle_id := xxcti_uar_cycle_id_seq.nextval;

    insert into xxcti_uar_review_cycles (
        cycle_id, cycle_name, period_start, period_end, due_date,
        status, closed_by, closed_date
    ) values (
        l_cycle_id, 'Legacy (pre-rebuild)', date '2020-01-01', sysdate, sysdate,
        'CLOSED', 'MIGRATION', sysdate
    );

    insert into xxcti_uar_review_items (
        review_item_id, cycle_id, employee_number, user_name, responsibility,
        application, start_date, end_date, last_logon, approval, approver,
        approval_date
    )
    select xxcti_uar_review_item_id_seq.nextval,
           l_cycle_id,
           employee_number,
           user_name,
           responsibility,
           application,
           start_date,
           end_date,
           last_logon,
           approval,
           approver,
           approval_date
      from xxcti_uar_employee_responsibilities_audit;

    dbms_output.put_line('Migrated into legacy cycle_id ' || l_cycle_id);
    commit;
end;
/
