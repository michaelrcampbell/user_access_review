-- ============================================================================
-- UAR regression tests -- SANDBOX / DEV ONLY (needs seed data, opens cycles).
--
-- Run as XXUAR (SQLcl/SQL*Plus, not SQL Workshop -- it prints with DBMS_OUTPUT):
--     @07_uar_regression_tests.sql
--
-- Needs: 01, 01b, 02 installed; the stand-in/real source tables populated
-- (05_uar_sandbox_seed.sql provides: admin Michael = employee 2001; Sandra =
-- employee 2002, a non-admin manager of employee 3002; Brian = employee 2003;
-- employee 3001 reports to Michael; Eleanor = 1001 is the top of the chain);
-- APEX app 530 imported (apex_session needs an app id).
--
-- Safe by design: it REFUSES TO RUN while any cycle is open (so it can never
-- touch real review data), creates its own cycles named "ZZ Regression A/B",
-- and removes them when it finishes. Entries in xxcti_uar_admin_log remain.
-- Simulated sign-ins are created with APEX_SESSION, which commits -- that is
-- why this script commits before switching users.
-- ============================================================================
set serveroutput on size unlimited feedback off verify off
whenever sqlerror exit failure

declare
    l_open number := xxcti_uar_cycle_pkg.current_open_cycle;
begin
    if l_open is not null then
        raise_application_error(-20999,
            'Cycle ' || l_open || ' is open. Close or delete it first -- these tests refuse to run alongside live review data.');
    end if;
end;
/

whenever sqlerror continue

declare
    g_pass number := 0;
    g_fail number := 0;
    g_start date  := sysdate;

    procedure out(p varchar2) is begin dbms_output.put_line(p); end;

    function q(p_sql varchar2) return varchar2 is
        n varchar2(4000);
    begin
        execute immediate p_sql into n;
        return n;
    end;

    procedure as_user(p_user varchar2) is
    begin
        commit;
        begin apex_session.delete_session; exception when others then null; end;
        apex_session.create_session(530, 1, p_user);
    end;

    procedure no_session is
    begin
        commit;
        begin apex_session.delete_session; exception when others then null; end;
    end;

    procedure verdict(p_label varchar2, p_ok boolean, p_note varchar2 default null) is
    begin
        if p_ok then
            g_pass := g_pass + 1;
            out('  PASS | ' || p_label);
        else
            g_fail := g_fail + 1;
            out('  FAIL | ' || p_label || case when p_note is not null then '  -> ' || p_note end);
        end if;
    end;

    -- expects p_code (a positive Oracle error number) to be raised, or success when null
    procedure expect(p_label varchar2, p_sql varchar2, p_code number default null) is
    begin
        execute immediate p_sql;
        if p_code is null then
            verdict(p_label, true);
        else
            verdict(p_label, false, 'expected ORA-' || lpad(p_code, 5, '0') || ' but it succeeded');
        end if;
    exception when others then
        if p_code is not null and sqlcode = -p_code then
            verdict(p_label, true);
        else
            verdict(p_label, false, case when p_code is null then 'unexpected error: ' else 'wrong error: ' end ||
                                    replace(substr(sqlerrm, 1, 150), chr(10), ' '));
        end if;
    end;

    function cyc(p_name varchar2) return number is
    begin
        return to_number(q('select cycle_id from xxcti_uar_review_cycles where cycle_name = ''' || p_name || ''''));
    end;
begin
    out('UAR regression tests, ' || to_char(sysdate, 'YYYY-MM-DD HH24:MI'));

    ----------------------------------------------------------------------------------------
    out('== 1. open_cycle input validation (admin: Michael)');
    as_user('MICHAEL.R.CAMPBELL@GMAIL.COM');
    expect('blank cycle name rejected',
           q'[declare c number; begin xxcti_uar_cycle_pkg.open_cycle('  ', trunc(sysdate), trunc(sysdate)+30, trunc(sysdate)+14, c); end;]', 20010);
    expect('period end before start rejected',
           q'[declare c number; begin xxcti_uar_cycle_pkg.open_cycle('ZZ bad', trunc(sysdate)+30, trunc(sysdate), trunc(sysdate)+14, c); end;]', 20011);
    expect('due date in the past rejected',
           q'[declare c number; begin xxcti_uar_cycle_pkg.open_cycle('ZZ bad', trunc(sysdate), trunc(sysdate)+30, trunc(sysdate)-1, c); end;]', 20012);
    expect('valid cycle "ZZ Regression A" opens',
           q'[declare c number; begin xxcti_uar_cycle_pkg.open_cycle('ZZ Regression A', trunc(sysdate), trunc(sysdate)+30, trunc(sysdate)+14, c); end;]');
    expect('a second cycle cannot be opened while one is open',
           q'[declare c number; begin xxcti_uar_cycle_pkg.open_cycle('ZZ Regression Z', trunc(sysdate), trunc(sysdate)+30, trunc(sysdate)+14, c); end;]', 20001);
    verdict('the open was logged',
            q('select count(*) from xxcti_uar_admin_log where action = ''OPEN_CYCLE'' and cycle_id = ' || cyc('ZZ Regression A')) = '1');

    ----------------------------------------------------------------------------------------
    out('== 2. Who may decide which item (cycle A)');
    expect('admin CANNOT approve their own access (employee 2001)',
           q'[update xxcti_uar_review_items set approval='Approved' where employee_number='2001' and cycle_id=(select cycle_id from xxcti_uar_review_cycles where cycle_name='ZZ Regression A')]', 20021);
    expect('admin can approve another manager''s report (employee 3002)',
           q'[update xxcti_uar_review_items set approval='Approved' where employee_number='3002' and rownum=1 and cycle_id=(select cycle_id from xxcti_uar_review_cycles where cycle_name='ZZ Regression A')]');
    rollback;

    as_user('SANDRA.OKONKWO@EXAMPLE.COM');
    expect('non-admin cannot edit another manager''s report (3001)',
           q'[update xxcti_uar_review_items set approval='Approved' where employee_number='3001' and rownum=1 and cycle_id=(select cycle_id from xxcti_uar_review_cycles where cycle_name='ZZ Regression A')]', 20021);
    expect('non-admin cannot approve their own access (2002)',
           q'[update xxcti_uar_review_items set approval='Approved' where employee_number='2002' and rownum=1 and cycle_id=(select cycle_id from xxcti_uar_review_cycles where cycle_name='ZZ Regression A')]', 20021);
    expect('manager can approve their own report (3002)',
           q'[update xxcti_uar_review_items set approval='Approved' where employee_number='3002' and rownum=1 and cycle_id=(select cycle_id from xxcti_uar_review_cycles where cycle_name='ZZ Regression A')]');
    verdict('approver is stamped with the real user',
            q('select max(approver) from xxcti_uar_review_items where employee_number=''3002'' and approval=''Approved'' and cycle_id=' || cyc('ZZ Regression A')) = 'SANDRA.OKONKWO@EXAMPLE.COM');
    expect('deny with a whitespace-only comment rejected',
           q'[update xxcti_uar_review_items set approval='Denied', comments='   ' where employee_number='3002' and rownum=1 and cycle_id=(select cycle_id from xxcti_uar_review_cycles where cycle_name='ZZ Regression A')]', 20022);
    expect('invalid status value rejected',
           q'[update xxcti_uar_review_items set approval='Hacked' where employee_number='3002' and rownum=1 and cycle_id=(select cycle_id from xxcti_uar_review_cycles where cycle_name='ZZ Regression A')]', 2290);
    rollback;

    no_session;
    expect('updates outside an APEX session are blocked',
           q'[update xxcti_uar_review_items set approval='Approved' where rownum=1 and cycle_id=(select cycle_id from xxcti_uar_review_cycles where cycle_name='ZZ Regression A')]', 20021);
    rollback;

    ----------------------------------------------------------------------------------------
    out('== 3. Audit trail: rewriting a decision is tracked');
    as_user('SANDRA.OKONKWO@EXAMPLE.COM');
    update xxcti_uar_review_items
       set approval = 'Denied', comments = 'original reason'
     where employee_number = '3002' and approval is null and rownum = 1
       and cycle_id = (select cycle_id from xxcti_uar_review_cycles where cycle_name = 'ZZ Regression A');
    commit;
    declare l_hist_before number := to_number(q('select count(*) from xxcti_uar_review_items_history'));
    begin
        as_user('MICHAEL.R.CAMPBELL@GMAIL.COM');
        update xxcti_uar_review_items set comments = 'REWRITTEN reason'
         where comments = 'original reason' and cycle_id = (select cycle_id from xxcti_uar_review_cycles where cycle_name = 'ZZ Regression A');
        commit;
        verdict('a comment-only rewrite writes a history row',
                to_number(q('select count(*) from xxcti_uar_review_items_history')) = l_hist_before + 1);
        verdict('...and re-stamps the approver as whoever rewrote it',
                q('select approver from xxcti_uar_review_items where comments=''REWRITTEN reason'' and cycle_id=' || cyc('ZZ Regression A')) = 'MICHAEL.R.CAMPBELL@GMAIL.COM');
        verdict('...and the history keeps the original reason',
                q('select count(*) from xxcti_uar_review_items_history where old_comments=''original reason''') = '1');
    end;
    -- put the item back to pending for the sign-off tests
    as_user('SANDRA.OKONKWO@EXAMPLE.COM');
    update xxcti_uar_review_items set approval = null, comments = null
     where comments = 'REWRITTEN reason' and cycle_id = (select cycle_id from xxcti_uar_review_cycles where cycle_name = 'ZZ Regression A');
    commit;

    ----------------------------------------------------------------------------------------
    out('== 4. Manager sign-off (Sandra = manager 2002)');
    expect('cannot submit with items still pending',
           'begin xxcti_uar_cycle_pkg.submit_review(' || cyc('ZZ Regression A') || ', 2002); end;', 20033);
    expect('cannot submit on behalf of another manager (non-admin)',
           'begin xxcti_uar_cycle_pkg.submit_review(' || cyc('ZZ Regression A') || ', 2001); end;', 20032);
    expect('cannot submit for a manager who does not exist',
           'begin xxcti_uar_cycle_pkg.submit_review(' || cyc('ZZ Regression A') || ', 99999); end;', 20031);
    update xxcti_uar_review_items set approval = 'Approved'
     where approval is null
       and employee_number in (select to_char(employee_id) from xxcti_uar_workday_employee_mgr where manager_id = 2002)
       and cycle_id = (select cycle_id from xxcti_uar_review_cycles where cycle_name = 'ZZ Regression A');
    commit;
    expect('submit succeeds once every item is decided',
           'begin xxcti_uar_cycle_pkg.submit_review(' || cyc('ZZ Regression A') || ', 2002); end;');
    expect('submitting twice is harmless',
           'begin xxcti_uar_cycle_pkg.submit_review(' || cyc('ZZ Regression A') || ', 2002); end;');
    expect('items are locked after submit',
           q'[update xxcti_uar_review_items set approval='Denied', comments='x' where employee_number='3002' and rownum=1 and cycle_id=(select cycle_id from xxcti_uar_review_cycles where cycle_name='ZZ Regression A')]', 20020);
    rollback;
    expect('non-admin cannot reopen a submission',
           'begin xxcti_uar_cycle_pkg.reopen_review(' || cyc('ZZ Regression A') || ', 2002); end;', 20050);

    as_user('MICHAEL.R.CAMPBELL@GMAIL.COM');
    expect('admin can reopen a submission',
           'begin xxcti_uar_cycle_pkg.reopen_review(' || cyc('ZZ Regression A') || ', 2002); end;');
    expect('reopening again is rejected (nothing to reopen)',
           'begin xxcti_uar_cycle_pkg.reopen_review(' || cyc('ZZ Regression A') || ', 2002); end;', 20017);
    expect('admin can submit on a manager''s behalf...',
           'begin xxcti_uar_cycle_pkg.submit_review(' || cyc('ZZ Regression A') || ', 2002); end;');
    verdict('...and that is logged as SUBMIT_ON_BEHALF',
            to_number(q('select count(*) from xxcti_uar_admin_log where action=''SUBMIT_ON_BEHALF'' and cycle_id=' || cyc('ZZ Regression A'))) >= 1);

    ----------------------------------------------------------------------------------------
    out('== 5. Close / delete rules');
    as_user('SANDRA.OKONKWO@EXAMPLE.COM');
    expect('non-admin cannot close a cycle',
           'begin xxcti_uar_cycle_pkg.close_cycle(' || cyc('ZZ Regression A') || '); end;', 20050);
    expect('non-admin cannot delete a cycle',
           'begin xxcti_uar_cycle_pkg.delete_cycle(' || cyc('ZZ Regression A') || '); end;', 20050);

    as_user('MICHAEL.R.CAMPBELL@GMAIL.COM');
    expect('admin can delete an OPEN cycle (opened by mistake)...',
           'begin xxcti_uar_cycle_pkg.delete_cycle(' || cyc('ZZ Regression A') || '); end;');
    verdict('...it and its items are gone',
            q('select count(*) from xxcti_uar_review_cycles where cycle_name=''ZZ Regression A''') = '0');
    verdict('...and the deletion is logged with what was discarded',
            to_number(q('select count(*) from xxcti_uar_admin_log where action=''DELETE_CYCLE'' and detail like ''%ZZ Regression A%discarded%''')) >= 1);

    expect('open "ZZ Regression B"',
           q'[declare c number; begin xxcti_uar_cycle_pkg.open_cycle('ZZ Regression B', trunc(sysdate), trunc(sysdate)+30, trunc(sysdate)+14, c); end;]');
    expect('close it',
           'begin xxcti_uar_cycle_pkg.close_cycle(' || cyc('ZZ Regression B') || '); end;');
    expect('closing an already-closed cycle is rejected',
           'begin xxcti_uar_cycle_pkg.close_cycle(' || cyc('ZZ Regression B') || '); end;', 20016);
    expect('closing a cycle that does not exist is rejected',
           q'[begin xxcti_uar_cycle_pkg.close_cycle(424242); end;]', 20015);
    expect('a CLOSED cycle can never be deleted (audit record)',
           'begin xxcti_uar_cycle_pkg.delete_cycle(' || cyc('ZZ Regression B') || '); end;', 20018);
    expect('cycle names are unique, ignoring case',
           q'[declare c number; begin xxcti_uar_cycle_pkg.open_cycle('zz regression b', trunc(sysdate), trunc(sysdate)+30, trunc(sysdate)+14, c); end;]', 20013);
    expect('setup: insert an OPEN row directly (none is open right now)',
           q'[insert into xxcti_uar_review_cycles(cycle_id,cycle_name,period_start,period_end,due_date,status) values (xxcti_uar_cycle_id_seq.nextval,'ZZ dup open 1',sysdate,sysdate,sysdate,'OPEN')]' , null);
    expect('database refuses a second OPEN cycle row',
           q'[insert into xxcti_uar_review_cycles(cycle_id,cycle_name,period_start,period_end,due_date,status) values (xxcti_uar_cycle_id_seq.nextval,'ZZ dup open 2',sysdate,sysdate,sysdate,'OPEN')]', 1);
    rollback;
    expect('database refuses period_end before period_start',
           q'[insert into xxcti_uar_review_cycles(cycle_id,cycle_name,period_start,period_end,due_date,status) values (xxcti_uar_cycle_id_seq.nextval,'ZZ bad dates',date '2026-12-31',date '2026-01-01',date '2026-12-31','CLOSED')]', 2290);
    rollback;

    ----------------------------------------------------------------------------------------
    out('== 6. Data-quality guards (rolled back; uses closed cycle B)');
    declare
        l_b      number := cyc('ZZ Regression B');
        l_base   varchar2(40) := q('select total_items from xxcti_uar_cycle_progress where cycle_id=' || cyc('ZZ Regression B') || ' and manager_id=2001');
    begin
        insert into xxcti_uar_workday_employee_mgr values (3001,'Dup','Row','dup.row@example.com',2001,'Michael','Campbell');
        verdict('a duplicate Workday row does NOT inflate a manager''s totals',
                q('select total_items from xxcti_uar_cycle_progress where cycle_id=' || l_b || ' and manager_id=2001') = l_base,
                'total changed from ' || l_base);
        verdict('...and is reported by xxcti_uar_data_issues',
                to_number(q('select count(*) from xxcti_uar_data_issues where issue like ''Employee listed more than once%''')) >= 1);
        rollback;

        insert into xxcti_uar_review_items(review_item_id,cycle_id,employee_number,user_name,responsibility,application)
            values (xxcti_uar_review_item_id_seq.nextval, l_b, '999999', 'GHOST', 'General Ledger Inquiry', 'General Ledger');
        verdict('an item for an employee missing from Workday shows as unassigned',
                q('select reason from xxcti_uar_unassigned_items where cycle_id=' || l_b || ' and employee_number=''999999''') = 'Employee not found in Workday data');
        rollback;

        insert into xxcti_uar_workday_employee_mgr values (999998,'Lost','Report','lost.report@example.com',999997,'Gone','Manager');
        insert into xxcti_uar_review_items(review_item_id,cycle_id,employee_number,user_name,responsibility,application)
            values (xxcti_uar_review_item_id_seq.nextval, l_b, '999998', 'LOST', 'Payables Manager', 'Payables');
        verdict('an item whose manager has no Workday row shows as unassigned',
                q('select reason from xxcti_uar_unassigned_items where cycle_id=' || l_b || ' and employee_number=''999998''') = 'Manager not found in Workday data');
        rollback;
    end;

    ----------------------------------------------------------------------------------------
    out('== 7. Admin list maintenance');
    expect('malformed email rejected',  q'[begin xxcti_uar_security_pkg.add_admin('not-an-email'); end;]', 20040);
    expect('existing admin rejected (case-insensitive)', q'[begin xxcti_uar_security_pkg.add_admin('MICHAEL.R.CAMPBELL@gmail.com'); end;]', 20041);
    expect('cannot remove yourself', q'[begin xxcti_uar_security_pkg.remove_admin('michael.r.campbell@gmail.com'); end;]', 20002);
    expect('removing someone who is not an admin is rejected', q'[begin xxcti_uar_security_pkg.remove_admin('nobody@example.com'); end;]', 20042);
    expect('add a new admin', q'[begin xxcti_uar_security_pkg.add_admin('  ZZ.Test.Admin@Example.com '); end;]');
    verdict('...stored trimmed and lower-cased',
            q('select count(*) from xxcti_uar_admins where email_address=''zz.test.admin@example.com''') = '1');
    expect('remove that admin', q'[begin xxcti_uar_security_pkg.remove_admin('zz.test.admin@example.com'); end;]');
    verdict('add and remove were both logged',
            to_number(q('select count(*) from xxcti_uar_admin_log where detail=''zz.test.admin@example.com'' and action in (''ADD_ADMIN'',''REMOVE_ADMIN'') and performed_date >= to_date(''' || to_char(g_start, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS'')')) = 2);
    as_user('SANDRA.OKONKWO@EXAMPLE.COM');
    expect('non-admin cannot add an admin', q'[begin xxcti_uar_security_pkg.add_admin('someone@example.com'); end;]', 20050);

    ----------------------------------------------------------------------------------------
    out('== 8. Reviewer assignments (fixtures are created and removed by this script)');
    as_user('MICHAEL.R.CAMPBELL@GMAIL.COM');
    -- 910001: top-level employee, no manager. 910002: manager (910099) has no Workday row.
    -- 910003: has responsibilities but is not in Workday at all (left the company).
    insert into xxcti_uar_workday_employee_mgr values (910001,'Top','Level','top.level@example.com',null,null,null);
    insert into xxcti_uar_workday_employee_mgr values (910002,'Lost','Report','lost.report2@example.com',910099,'Gone','Manager');
    insert into xxcti_uar_employee_responsibilities values ('TOP.LEVEL','910001','General Ledger Inquiry','General Ledger',sysdate-100,null);
    insert into xxcti_uar_employee_responsibilities values ('LOST.REPORT','910002','Payables Manager','Payables',sysdate-100,null);
    insert into xxcti_uar_employee_responsibilities values ('LEFT.PERSON','910003','Purchasing Buyer','Purchasing',sysdate-100,null);
    commit;
    verdict('before: nobody can review 910001 / 910002',
            q('select count(*) from xxcti_uar_effective_mgr where employee_id in (910001,910002) and manager_id is null') = '2');
    expect('a person cannot be their own reviewer',      q'[begin xxcti_uar_security_pkg.assign_reviewer(910001, 910001); end;]', 20060);
    expect('the reviewer must exist with an email',      q'[begin xxcti_uar_security_pkg.assign_reviewer(910001, 99999999); end;]', 20061);
    expect('the employee must be known to the data',     q'[begin xxcti_uar_security_pkg.assign_reviewer(88888888, 2002); end;]', 20063);
    expect('refused when Workday already has a reviewer', q'[begin xxcti_uar_security_pkg.assign_reviewer(3002, 2001); end;]', 20062);
    expect('refused: reviewer reports directly to the employee',   q'[begin xxcti_uar_security_pkg.assign_reviewer(1001, 2001); end;]', 20064);
    expect('refused: reviewer reports indirectly to the employee', q'[begin xxcti_uar_security_pkg.assign_reviewer(1001, 3001); end;]', 20064);
    expect('both employee and reviewer are required',    q'[begin xxcti_uar_security_pkg.assign_reviewer(910001, null); end;]', 20066);

    as_user('SANDRA.OKONKWO@EXAMPLE.COM');
    expect('non-admin cannot assign a reviewer',         q'[begin xxcti_uar_security_pkg.assign_reviewer(910001, 2002); end;]', 20050);

    as_user('MICHAEL.R.CAMPBELL@GMAIL.COM');
    expect('admin assigns Sandra (2002) to the top-level employee',
           q'[begin xxcti_uar_security_pkg.assign_reviewer(910001, 2002, 'regression test'); end;]');
    verdict('...the effective reviewer is now Sandra, source ASSIGNED',
            q('select manager_id || ''/'' || manager_source from xxcti_uar_effective_mgr where employee_id = 910001') = '2002/ASSIGNED');
    expect('admin assigns a reviewer for the employee whose manager has no Workday row',
           q'[begin xxcti_uar_security_pkg.assign_reviewer(910002, 2003); end;]');
    expect('admin assigns a reviewer for an employee who left Workday',
           q'[begin xxcti_uar_security_pkg.assign_reviewer(910003, 2004, 'left the company'); end;]');
    verdict('...that employee is visible with the assigned reviewer and no Workday name',
            q('select manager_id || ''/'' || nvl(employee_legal_first_name, ''-'') from xxcti_uar_effective_mgr where employee_id = 910003') = '2004/-');
    verdict('none of the three is "unassigned" any more',
            q('select count(*) from xxcti_uar_effective_mgr where employee_id in (910001,910002,910003) and manager_id is null') = '0');
    expect('reassigning changes the reviewer (and is logged as a change)',
           q'[begin xxcti_uar_security_pkg.assign_reviewer(910001, 2003); end;]');
    verdict('...the new reviewer is in effect',
            q('select manager_id from xxcti_uar_effective_mgr where employee_id = 910001') = '2003');
    verdict('...and the log says CHANGE_REVIEWER',
            to_number(q('select count(*) from xxcti_uar_admin_log where action = ''CHANGE_REVIEWER'' and performed_date >= to_date(''' || to_char(g_start, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS'')')) >= 1);

    as_user('BRIAN.LINDQVIST@EXAMPLE.COM');   -- 2003, the assigned reviewer of 910001 and 910002
    verdict('an assigned reviewer may review the employee (can_review = Y)',
            xxcti_uar_security_pkg.can_review('910001') = 'Y' and xxcti_uar_security_pkg.can_review('910002') = 'Y');
    verdict('an assigned reviewer may NOT review someone else''s employee',
            xxcti_uar_security_pkg.can_review('910003') = 'N');

    as_user('MICHAEL.R.CAMPBELL@GMAIL.COM');
    -- Workday later supplies a manager: the assignment stops being used
    update xxcti_uar_workday_employee_mgr
       set manager_id = 2001, manager_first_name = 'Michael', manager_last_name = 'Campbell'
     where employee_id = 910001;
    commit;
    verdict('once Workday has a manager the assignment is ignored (source WORKDAY)',
            q('select manager_id || ''/'' || manager_source from xxcti_uar_effective_mgr where employee_id = 910001') = '2001/WORKDAY');
    expect('...and a new assignment is refused', q'[begin xxcti_uar_security_pkg.assign_reviewer(910001, 2002); end;]', 20062);

    expect('admin removes an assignment',         q'[begin xxcti_uar_security_pkg.remove_reviewer(910002); end;]');
    expect('removing it again is rejected',       q'[begin xxcti_uar_security_pkg.remove_reviewer(910002); end;]', 20065);
    as_user('SANDRA.OKONKWO@EXAMPLE.COM');
    expect('non-admin cannot remove an assignment', q'[begin xxcti_uar_security_pkg.remove_reviewer(910003); end;]', 20050);

    as_user('MICHAEL.R.CAMPBELL@GMAIL.COM');
    verdict('assignments were logged (assign/remove)',
            to_number(q('select count(*) from xxcti_uar_admin_log where action in (''ASSIGN_REVIEWER'',''REMOVE_REVIEWER'') and performed_date >= to_date(''' || to_char(g_start, 'YYYY-MM-DD HH24:MI:SS') || ''', ''YYYY-MM-DD HH24:MI:SS'')')) >= 4);

    -- end-dated rows are reported (rolled back)
    update xxcti_uar_employee_responsibilities set end_date = trunc(sysdate) - 30 where employee_number = '910003';
    verdict('an already end-dated responsibility is reported in xxcti_uar_data_issues',
            to_number(q('select count(*) from xxcti_uar_data_issues where issue like ''Responsibility already end-dated%'' and ref = ''910003''')) = 1);
    rollback;

    -- fixtures out
    no_session;
    delete from xxcti_uar_reviewer_overrides where employee_id in (910001, 910002, 910003);
    delete from xxcti_uar_employee_responsibilities where employee_number in ('910001', '910002', '910003');
    delete from xxcti_uar_workday_employee_mgr where employee_id in (910001, 910002);
    commit;

    ----------------------------------------------------------------------------------------
    -- cleanup: cycle B is closed, which the package (rightly) will not delete
    no_session;
    delete from xxcti_uar_review_items_history where review_item_id in (select review_item_id from xxcti_uar_review_items where cycle_id = (select cycle_id from xxcti_uar_review_cycles where cycle_name = 'ZZ Regression B'));
    delete from xxcti_uar_manager_signoffs where cycle_id = (select cycle_id from xxcti_uar_review_cycles where cycle_name = 'ZZ Regression B');
    delete from xxcti_uar_review_items where cycle_id = (select cycle_id from xxcti_uar_review_cycles where cycle_name = 'ZZ Regression B');
    delete from xxcti_uar_review_cycles where cycle_name in ('ZZ Regression A', 'ZZ Regression B');
    commit;
    out('cleanup: test cycles remaining = ' || q('select count(*) from xxcti_uar_review_cycles where cycle_name like ''ZZ Regression%'''));

    out('');
    out('RESULT: ' || g_pass || ' passed, ' || g_fail || ' failed');
    if g_fail > 0 then
        raise_application_error(-20998, g_fail || ' regression test(s) failed -- see FAIL lines above.');
    end if;
end;
/
