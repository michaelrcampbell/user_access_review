-- ============================================================================
-- UAR : managers who have employees to review, and a check that nobody is missing
-- Run as XXUAR (SQLcl / SQL*Plus; the check uses a bind variable, so SQL Workshop's
-- script runner may need `:cyc` replaced by the cycle id).
--
--   PART 1  the list: manager name, email and counts for the OPEN cycle
--   PART 2  reconciliation: covered + unassigned must equal the cycle's totals, and the
--           list of managers must match the raw Workday table (independent of the app's views)
--   PART 3  the same list before any cycle is open (from the responsibilities feed)
-- Managers' employees with NO reviewer are deliberately not in the list: they are on
-- Page 5 and in xxcti_uar_unassigned_employees.
-- ============================================================================
set pagesize 100 linesize 200 feedback off serveroutput on

prompt === PART 1. Managers with employees to review in the OPEN cycle
select em.manager_id,
       em.manager_first_name || ' ' || em.manager_last_name        as manager_name,
       em.manager_email                                            as email_address,
       count(distinct em.employee_id)                              as employees,
       count(*)                                                    as items,
       count(ri.approval)                                          as items_decided,
       case when so.manager_id is not null then 'Yes' else 'No' end as submitted
  from xxcti_uar_review_items ri
  join xxcti_uar_effective_mgr em
    on to_char(em.employee_id) = ri.employee_number
  left join xxcti_uar_manager_signoffs so
    on so.cycle_id = ri.cycle_id and so.manager_id = em.manager_id
 where ri.cycle_id = xxcti_uar_cycle_pkg.current_open_cycle
   and em.manager_id is not null
 group by em.manager_id, em.manager_first_name, em.manager_last_name, em.manager_email, so.manager_id
 order by em.manager_last_name, em.manager_first_name;

prompt === PART 2. Reconciliation (see the notes under each heading)
variable cyc number
exec :cyc := xxcti_uar_cycle_pkg.current_open_cycle

prompt === 1. The open cycle itself
select :cyc as cycle_id,
       count(*)                          as items_in_cycle,
       count(distinct employee_number)   as employees_in_cycle
  from xxcti_uar_review_items where cycle_id = :cyc;

prompt === 2. What the manager query covers (sum over all managers it lists)
with q as (
  select em.manager_id, count(distinct em.employee_id) as employees, count(*) as items
    from xxcti_uar_review_items ri
    join xxcti_uar_effective_mgr em on to_char(em.employee_id) = ri.employee_number
   where ri.cycle_id = :cyc and em.manager_id is not null
   group by em.manager_id)
select count(*) as managers_listed, sum(employees) as employees_covered, sum(items) as items_covered from q;

prompt === 3. What the app says nobody can review (not in the manager list, by design)
select count(*) as unassigned_items, count(distinct employee_number) as unassigned_employees from xxcti_uar_unassigned_items where cycle_id = :cyc;

prompt === 4. RECONCILIATION: covered + unassigned must equal the cycle total
select case when t.items = c.items + u.items and t.emps = c.emps + u.emps then 'OK - nobody is missing, nothing is counted twice'
            else 'MISMATCH - investigate' end as result,
       t.items as cycle_items, c.items as covered, u.items as unassigned,
       t.emps as cycle_employees, c.emps as covered_emps, u.emps as unassigned_emps
  from (select count(*) items, count(distinct employee_number) emps from xxcti_uar_review_items where cycle_id = :cyc) t,
       (select count(*) items, count(distinct ri.employee_number) emps
          from xxcti_uar_review_items ri join xxcti_uar_effective_mgr em on to_char(em.employee_id) = ri.employee_number
         where ri.cycle_id = :cyc and em.manager_id is not null) c,
       (select count(*) items, count(distinct employee_number) emps from xxcti_uar_unassigned_items where cycle_id = :cyc) u;

prompt === 5. INDEPENDENT CHECK from the raw Workday table (no app views): managers whose reports have items in the cycle
prompt     5a. in raw Workday but NOT in the query's list (expect no rows, unless a reviewer was assigned on Page 5)
select distinct to_char(w.manager_id) as manager_id
  from xxcti_uar_workday_employee_mgr w
  join xxcti_uar_review_items ri on ri.employee_number = to_char(w.employee_id) and ri.cycle_id = :cyc
 where w.manager_id is not null
minus
select to_char(em.manager_id)
  from xxcti_uar_review_items ri join xxcti_uar_effective_mgr em on to_char(em.employee_id) = ri.employee_number
 where ri.cycle_id = :cyc and em.manager_id is not null;
prompt     5b. in the query's list but NOT in raw Workday (expect no rows; rows here would be Page 5 assigned reviewers)
select to_char(em.manager_id) as manager_id
  from xxcti_uar_review_items ri join xxcti_uar_effective_mgr em on to_char(em.employee_id) = ri.employee_number
 where ri.cycle_id = :cyc and em.manager_id is not null
minus
select distinct to_char(w.manager_id)
  from xxcti_uar_workday_employee_mgr w
  join xxcti_uar_review_items ri on ri.employee_number = to_char(w.employee_id) and ri.cycle_id = :cyc
 where w.manager_id is not null;

prompt === 6. Per manager: query's employee count vs raw Workday direct reports who have items (expect same)
select em.manager_id,
       count(distinct em.employee_id) as query_employees,
       (select count(distinct w.employee_id) from xxcti_uar_workday_employee_mgr w
          join xxcti_uar_review_items r2 on r2.employee_number = to_char(w.employee_id) and r2.cycle_id = :cyc
         where to_char(w.manager_id) = to_char(em.manager_id)) as raw_workday_reports,
       count(*) as query_items,
       (select count(*) from xxcti_uar_review_items r3
         where r3.cycle_id = :cyc and r3.employee_number in
               (select to_char(w.employee_id) from xxcti_uar_workday_employee_mgr w where to_char(w.manager_id) = to_char(em.manager_id))) as raw_items
  from xxcti_uar_review_items ri join xxcti_uar_effective_mgr em on to_char(em.employee_id) = ri.employee_number
 where ri.cycle_id = :cyc and em.manager_id is not null
 group by em.manager_id order by em.manager_id;

prompt === 7. People in the CURRENT feed who are not in this cycle's snapshot (a cycle is a snapshot of the day it opened)
select (select count(distinct employee_number) from xxcti_uar_employee_responsibilities) as employees_in_feed_now,
       (select count(distinct employee_number) from xxcti_uar_review_items where cycle_id = :cyc) as employees_in_open_cycle
  from dual;
select er.employee_number, max(er.user_name) as oracle_user, count(*) as responsibilities
  from xxcti_uar_employee_responsibilities er
 where not exists (select 1 from xxcti_uar_review_items ri where ri.cycle_id = :cyc and ri.employee_number = er.employee_number)
 group by er.employee_number;

prompt === PART 3. Managers with employees in the feed (use when no cycle is open)
select em.manager_id,
       em.manager_first_name || ' ' || em.manager_last_name as manager_name,
       em.manager_email                                     as email_address,
       count(distinct em.employee_id)                       as employees
  from xxcti_uar_employee_responsibilities er
  join xxcti_uar_effective_mgr em
    on to_char(em.employee_id) = er.employee_number
 where em.manager_id is not null
 group by em.manager_id, em.manager_first_name, em.manager_last_name, em.manager_email
 order by em.manager_last_name, em.manager_first_name;
