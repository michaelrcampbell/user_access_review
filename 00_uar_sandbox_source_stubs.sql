-- SANDBOX ONLY: empty stand-ins for externally-fed source tables
create table xxcti_uar_workday_employee_mgr (
  employee_id number, employee_legal_first_name varchar2(240), employee_legal_last_name varchar2(240),
  email_address varchar2(240), manager_id number, manager_first_name varchar2(240), manager_last_name varchar2(240));
create table xxcti_uar_employee_responsibilities (
  user_name varchar2(240), employee_number varchar2(240), responsibility varchar2(240),
  application varchar2(240), start_date date, end_date date);
create table xxcti_uar_employee_responsibilities_audit (
  audit_id number, user_name varchar2(240), employee_number varchar2(240), responsibility varchar2(240),
  application varchar2(240), start_date date, end_date date, last_logon date,
  approval varchar2(30), approver varchar2(240), approval_date date);
