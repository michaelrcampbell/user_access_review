> **Historical document.** This was the original page-by-page spec for building the app in Page Designer. The
> application has since been built (`04_uar_apex.sql`) and is live in DEV, TEST and PROD, and it differs from this
> spec in many places (for example Page 1 is an Interactive Report, there is a Reviewer Assignments page, sign-off and
> the audit views were added). Treat it as background only; `README.md` and `CHANGELOG.md` describe the real app.

# UAR App Rebuild — APEX Build Guide

Build this in Page Designer rather than hand-editing export SQL. The schema and packages
in this repo carry zero import risk (plain DDL/PL/SQL you can run and test directly); a
hand-authored `wwv_flow_imp_page.*` export for an app this size would introduce many new
parameter combinations with no way to verify the import succeeds ahead of time — the same
"unprecedented export-API parameter" 400 that's bitten PMO Hub three separate times. Build
each page through the UI, then export the finished app fresh — at that point future
changes can go back to precise, precedent-checked SQL patches like the original app-104
security patch did.

All security/cycle logic below calls `xxcti_uar_security_pkg` / `xxcti_uar_cycle_pkg` from
`02_uar_packages.sql` — install that first.

## Page 9999 — Login

Carry over the existing MVP's login page as-is (Oracle APEX Accounts authentication,
username/password items, "remember username" cookie processes). Nothing about auth
*mechanism* needed changing — only *authorization* (who can see what once logged in),
which is handled by the security package instead.

## Page 1 — "My Team Review" (was "Manager Selection")

**Page**: alias `MY-TEAM-REVIEW`, protection level C (session state protection).

**Items:**
- `P1_MANAGER` — Select List.
  - LOV (SQL Query):
    ```sql
    select manager_first_name || ' ' || manager_last_name as manager,
           manager_id
    from xxcti_uar_workday_employee_mgr
    where xxcti_uar_security_pkg.is_admin = 'Y'
       or manager_id = xxcti_uar_security_pkg.resolve_employee_id
    group by manager_id, manager_first_name, manager_last_name
    order by 1
    ```
    (Derives the manager list directly from the employee/mgr table instead of maintaining
    a separate `xxcti_uar_managers` table — always in sync, one less table to keep fed.)
  - Default Type: PL/SQL Expression → `xxcti_uar_security_pkg.resolve_employee_id`
  - Read Only Condition Type: PL/SQL Expression → `xxcti_uar_security_pkg.is_admin = 'N'`
    (a plain manager never sees a picker at all; an admin gets the full dropdown to
    delegate-review any manager's team).
- `P1_CYCLE_ID` — Hidden, Protected.
  - Default Type: PL/SQL Expression → `xxcti_uar_cycle_pkg.current_open_cycle`

**Region: "No Active Review Cycle"**
- Static/HTML region. Server-side Condition: PL/SQL Expression →
  `xxcti_uar_cycle_pkg.current_open_cycle is null`.
- Content: "There's no open access review right now. Check back once one starts." — the
  MVP had no such state; it just showed an empty grid with no explanation.

**Region: "Review Progress"**
- Server-side Condition: cycle is not null (inverse of above).
- Source: query `xxcti_uar_cycle_progress` filtered by
  `cycle_id = :P1_CYCLE_ID and manager_id = :P1_MANAGER`, showing something like
  "12 of 20 complete (60%)". A Progress Bar / gauge region type is a nice-to-have here;
  plain text is fine for v1.

**Region: "My Team's Access Items"** (Interactive Grid, non-editable — same shape as the
original Page 1 report region)
```sql
with completeness as (
    select employee_number,
           case when sum(case when approval is null then 1 else 0 end) = 0
                then 'Yes' else 'No' end as review_complete
    from xxcti_uar_review_items
    where cycle_id = :P1_CYCLE_ID
    group by employee_number
)
select distinct
    uwe.employee_id,
    uwe.employee_legal_first_name,
    uwe.employee_legal_last_name,
    ri.employee_number,
    ri.user_name,
    comp.review_complete
from xxcti_uar_workday_employee_mgr uwe
join xxcti_uar_review_items ri
  on to_char(uwe.employee_id) = ri.employee_number
left join completeness comp
  on ri.employee_number = comp.employee_number
where uwe.manager_id = :P1_MANAGER
  and ri.cycle_id = :P1_CYCLE_ID
```
Employee ID column → link to Page 2, passing `P2_EMPLOYEE_ID` and `P2_CYCLE_ID` (=
`:P1_CYCLE_ID`).

## Page 2 — "Employee Review"

Same editable-grid mechanic as the original MVP (proven, no reason to change it) —
just re-scoped to a cycle and with a real server-side ownership gate in front of it.

**Items:** `P2_EMPLOYEE_ID` (Hidden, Protected), `P2_CYCLE_ID` (Hidden, Protected).

**Process — "Enforce Manager Ownership and Cycle Status"** (PL/SQL Code, point:
Before Header):
```plsql
if xxcti_uar_security_pkg.can_review(:P2_EMPLOYEE_ID) = 'N' then
    owa_util.redirect_url('f?p=' || :APP_ID || ':1:' || :APP_SESSION);
    raise apex_application.e_stop_apex_engine;
end if;

if xxcti_uar_cycle_pkg.can_edit_cycle(:P2_CYCLE_ID) = 'N' then
    owa_util.redirect_url('f?p=' || :APP_ID || ':1:' || :APP_SESSION);
    raise apex_application.e_stop_apex_engine;
end if;
```
No DML happens in this process, so it's not subject to the missing-commit-before-redirect
gotcha — worth re-checking that note any time this process grows to do more.

(v1 simplification: a closed cycle's items become fully inaccessible via Page 2 rather
than viewable-read-only. Revisit if "browse a past closed cycle" turns out to matter —
Page 4's Audit History report already covers cross-cycle history for admins.)

**Region: "Responsibility Review"** (editable Interactive Grid, `edit_operations = u`,
same as the original):
```sql
select review_item_id,
       user_name,
       employee_number,
       responsibility,
       application,
       last_logon,
       start_date,
       end_date,
       approval,
       approver,
       approval_date,
       comments
from xxcti_uar_review_items
where employee_number = :P2_EMPLOYEE_ID
  and cycle_id = :P2_CYCLE_ID
```
- `APPROVAL` column: Select List, static LOV `Approved;Approved,Denied;Denied` (unchanged
  from the MVP).
- `APPROVER` / `APPROVAL_DATE`: Hidden, value-protected (the trigger stamps these — don't
  let the grid submit them directly).
- `COMMENTS`: new — Textarea, editable. Encourage rationale, especially for Denied rows —
  the MVP had no way to record *why* something was denied.
- Save: use Page Designer's built-in "Save Interactive Grid Data" process (same as the
  original) — no changes needed to that mechanic.

**Button**: "Back to My Team" → redirect to Page 1 (same as the original's back button).

## Page 3 — "Review Cycles" (Admin)

**Required Role**: an authorization scheme whose PL/SQL function body is
`return xxcti_uar_security_pkg.is_admin = 'Y';` (same shape as the original app's two stub
schemes — just with a real check this time instead of `return true;`).

**Region: "Cycles"**
```sql
select c.cycle_id, c.cycle_name, c.period_start, c.period_end, c.due_date,
       c.status, c.created_date, c.closed_date,
       (select count(*) from xxcti_uar_review_items ri where ri.cycle_id = c.cycle_id) as total_items,
       (select count(*) from xxcti_uar_review_items ri where ri.cycle_id = c.cycle_id and ri.approval is not null) as completed_items
from xxcti_uar_review_cycles c
order by c.period_start desc
```
- Button "Open New Cycle" → a form (modal or separate page) collecting cycle name, period
  start/end, due date, calling `xxcti_uar_cycle_pkg.open_cycle` on submit.
- Row action/button "Close" → calls `xxcti_uar_cycle_pkg.close_cycle(:CYCLE_ID)`. Add a
  `confirm()` dialog before this one — closing a cycle is exactly the kind of consequential
  action PMO Hub's delete-confirm pattern exists for.

**Region: "Manager Completion — Selected Cycle"** (replaces the old standalone Manager
Email Listing / Response Tracking pages)
```sql
select cp.manager_first_name || ' ' || cp.manager_last_name as manager_name,
       uwe.email_address,
       cp.total_items,
       cp.completed_items,
       cp.pct_complete
from xxcti_uar_cycle_progress cp
join xxcti_uar_workday_employee_mgr uwe
  on cp.manager_id = uwe.employee_id
where cp.cycle_id = :P3_SELECTED_CYCLE_ID
order by cp.pct_complete
```
Keep CSV export enabled — this is the same "give me a mailing list of who hasn't finished"
capability the MVP had, just cycle-scoped and paired with real completion data instead of
a flat manager-email dump. Swap for automated `APEX_MAIL` notify/reminder once SMTP exists
— the cycle model is already in place for that, it's a small addition later, not a
redesign.

## Page 4 — "Audit History" (Admin)

Same shape as the original app's Audit History Report, now genuinely useful across
multiple periods instead of one mutable table:
```sql
select cy.cycle_name,
       cy.status as cycle_status,
       ri.review_item_id,
       ri.user_name,
       ri.employee_number,
       ri.responsibility,
       ri.application,
       ri.start_date,
       ri.end_date,
       ri.approval,
       ri.approver,
       ri.approval_date,
       ri.last_logon,
       uwem.manager_first_name,
       uwem.manager_last_name,
       uwem.manager_id,
       b.email_address as manager_email
from xxcti_uar_review_items ri
join xxcti_uar_review_cycles cy
  on ri.cycle_id = cy.cycle_id
join xxcti_uar_workday_employee_mgr uwem
  on ri.employee_number = to_char(uwem.employee_id)
left join xxcti_uar_workday_employee_mgr b
  on uwem.manager_id = b.employee_id
order by cy.period_start desc, ri.approval_date desc
```
Same `Administration Rights` (real) authorization scheme as Page 3.

## Not carried over

- Old Page 4 "Manager Email Listing" and Page 5 "Response Tracking" as standalone pages —
  folded into Page 3's cycle dashboard above.
- The separate `xxcti_uar_managers` table dependency on Page 1 — derived from
  `xxcti_uar_workday_employee_mgr` instead (see schema script note).

## Deferred (cosmetic, no security impact — do whenever convenient)

- Nav-hiding for Pages 3/4 by role, DEV/TEST/PROD environment badge — same PMO-Hub-derived
  patterns noted in the phase-1 patch README, unchanged by the rebuild.
