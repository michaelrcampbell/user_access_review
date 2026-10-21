-- ============================================================================
-- SANDBOX ONLY -- do not run in DEV/TEST/PROD (those have real source feeds).
-- Seeds fake org/responsibility data into the stand-in source tables created
-- by 00_uar_sandbox_source_stubs.sql, plus the sandbox admin. Re-runnable.
--
-- Hierarchy: 1 VP (1001) -> 5 managers (2001-2005) -> 30 employees (3001-3030).
-- Michael Campbell is manager 2001 AND an admin, so Page 1 shows his own team
-- and the admin pages work. Reproducible (dbms_random seeded).
-- ============================================================================
set serveroutput on
delete from xxcti_uar_employee_responsibilities_audit;
delete from xxcti_uar_employee_responsibilities;
delete from xxcti_uar_workday_employee_mgr;

declare
  type t_str is table of varchar2(100);
  l_first t_str := t_str('James','Maria','Robert','Linda','David','Priya','Wei','Aisha','Carlos','Elena',
                         'Tomas','Grace','Omar','Hannah','Victor','Naomi','Liam','Sofia','Kenji','Fatima',
                         'Daniel','Chloe','Rahul','Isabel','Marcus','Yuki','Andre','Zoe','Samuel','Leah');
  l_last  t_str := t_str('Nguyen','Patel','Kim','Garcia','Okafor','Silva','Brown','Chen','Novak','Haddad',
                         'Johansson','Reyes','Kowalski','Tanaka','Mensah','Rossi','Fischer','Singh','Lopez','Murphy',
                         'Ahmed','Cohen','Dubois','Ivanov','Walker','Sato','Moreau','Costa','Hughes','Bennett');
  type t_resp is table of varchar2(100);
  l_resp t_resp := t_resp('General Ledger Super User','General Ledger Inquiry','Payables Manager',
      'Payables Inquiry','Purchasing Super User','Purchasing Buyer','Receivables Manager',
      'Cash Management User','Fixed Assets Manager','Inventory Super User','Order Management Super User',
      'Project Billing Super User','Projects Inquiry','System Administrator','Application Developer');
  l_app  t_resp := t_resp('General Ledger','General Ledger','Payables','Payables','Purchasing','Purchasing',
      'Receivables','Cash Management','Fixed Assets','Inventory','Order Management',
      'Projects','Projects','System Administration','Application Object Library');

  procedure add_emp(p_id number, p_first varchar2, p_last varchar2, p_email varchar2,
                    p_mgr_id number, p_mgr_first varchar2, p_mgr_last varchar2) is
    l_n  number := trunc(dbms_random.value(2,6));
    l_ix number;
    l_start date;
    l_end   date;
    l_user  varchar2(240) := upper(p_first || '.' || p_last);
  begin
    insert into xxcti_uar_workday_employee_mgr
      (employee_id, employee_legal_first_name, employee_legal_last_name, email_address,
       manager_id, manager_first_name, manager_last_name)
    values (p_id, p_first, p_last, lower(p_email), p_mgr_id, p_mgr_first, p_mgr_last);

    for i in 1 .. l_n loop
      l_ix    := mod(p_id * 7 + i * 3 + trunc(dbms_random.value(0,15)), l_resp.count) + 1;
      l_start := trunc(sysdate) - trunc(dbms_random.value(30, 1800));
      l_end   := case when dbms_random.value < 0.12 then l_start + trunc(dbms_random.value(10, 300)) end;
      insert into xxcti_uar_employee_responsibilities
        (user_name, employee_number, responsibility, application, start_date, end_date)
      values (l_user, to_char(p_id), l_resp(l_ix), l_app(l_ix), l_start, l_end);
      insert into xxcti_uar_employee_responsibilities_audit
        (audit_id, user_name, employee_number, responsibility, application, start_date, end_date, last_logon)
      values (p_id * 100 + i, l_user, to_char(p_id), l_resp(l_ix), l_app(l_ix), l_start, l_end,
              case when dbms_random.value < 0.15 then null
                   else trunc(sysdate) - trunc(dbms_random.value(0, 200)) end);
    end loop;
  end;
begin
  dbms_random.seed(42);
  add_emp(1001, 'Eleanor', 'Whitfield', 'eleanor.whitfield@example.com', null, null, null);
  add_emp(2001, 'Michael', 'Campbell',  'michael.r.campbell@gmail.com',  1001, 'Eleanor', 'Whitfield');
  add_emp(2002, 'Sandra',  'Okonkwo',   'sandra.okonkwo@example.com',    1001, 'Eleanor', 'Whitfield');
  add_emp(2003, 'Brian',   'Lindqvist', 'brian.lindqvist@example.com',   1001, 'Eleanor', 'Whitfield');
  add_emp(2004, 'Mei',     'Zhang',     'mei.zhang@example.com',         1001, 'Eleanor', 'Whitfield');
  add_emp(2005, 'Paulo',   'Fernandes', 'paulo.fernandes@example.com',   1001, 'Eleanor', 'Whitfield');
  for i in 1 .. 30 loop
    declare
      l_mgr number := 2001 + mod(i - 1, 5);
      l_mf  varchar2(50); l_ml varchar2(50);
    begin
      select employee_legal_first_name, employee_legal_last_name into l_mf, l_ml
        from xxcti_uar_workday_employee_mgr where employee_id = l_mgr;
      add_emp(3000 + i, l_first(i), l_last(i),
              lower(l_first(i) || '.' || l_last(i)) || '@example.com', l_mgr, l_mf, l_ml);
    end;
  end loop;
end;
/
merge into xxcti_uar_admins a
using (select 'michael.r.campbell@gmail.com' email_address from dual) s
   on (upper(a.email_address) = upper(s.email_address))
 when not matched then insert (email_address) values (s.email_address);
commit;

select count(*) employees from xxcti_uar_workday_employee_mgr;
select count(*) responsibilities from xxcti_uar_employee_responsibilities;
