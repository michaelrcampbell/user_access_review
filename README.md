# UAR (User Access Review) App — Rebuild

Oracle APEX app rebuilding the "Oracle User Access Review" MVP (originally app 104,
schema `XXAPEX_EBS`) around a proper review-cycle model instead of a single mutable
snapshot, plus the authorization fixes identified in the original app's security review.

## Why a rebuild, not a patch

The original MVP was built in a rush and worked, but had no concept of a recurring review
*period* — one audit table got overwritten each time, so there was no historical record
per quarter, no due dates, and "notify managers" meant exporting a CSV of email addresses
for someone to paste into Outlook by hand. On top of that, both authorization schemes were
stub `return true;` functions and neither the manager picker nor the employee review page
checked that the logged-in user actually owned the record they were viewing — see
`UAR_APP_104_SECURITY_REVIEW.md` in project history for the original findings, superseded
by everything here.

## Status

| Piece | Status |
|---|---|
| Schema (`01_uar_schema_ddl.sql`) | Done — run and test directly |
| Packages (`02_uar_packages.sql`) | Done — run and test directly |
| Legacy data migration (`03_uar_migration_legacy_audit.sql`) | Done, optional |
| APEX application | **Not built yet** — see `APEX_BUILD_GUIDE.md` |

No mailer is configured yet, so `APEX_MAIL` notifications/reminders are explicitly **not**
part of this rebuild — Page 3's manager-completion report keeps the MVP's CSV-export
workaround until SMTP exists. The cycle model doesn't need to change to add that later.

## What changed from the MVP

- **Review cycles** (`xxcti_uar_review_cycles` / `xxcti_uar_review_items`) replace the
  single `xxcti_uar_employee_responsibilities_audit` table — each period's approvals are
  now a frozen, independent historical record with a name, period, and due date, instead
  of one table being overwritten every review.
- **Real authorization** (`xxcti_uar_security_pkg`) — `is_admin`/`resolve_employee_id`/
  `can_review` replace the two `return true;` stub schemes and add a genuine ownership
  check that was missing entirely (a manager could previously browse and approve/deny
  any employee's access review by URL, not just their own reports).
- **Audit-trail stamping** — `APPROVER`/`APPROVAL_DATE` are now set by a trigger, closing
  a gap where nothing in the MVP ever populated them.
- **Progress visibility** — a completion percentage per manager per cycle
  (`xxcti_uar_cycle_progress`), surfaced on both the manager's own landing page and the
  admin dashboard; the MVP had no way to see "how much is left" at either level.
- **Comments field** on each review item, so a denial can carry a rationale — the MVP had
  no way to record why something was denied.
- Old "Manager Email Listing" and "Response Tracking" admin pages fold into one "Review
  Cycles" dashboard (open/close a cycle, see per-manager completion, export the mailing
  list) rather than three separate pages doing overlapping things.

## Run order

```sql
@@01_uar_schema_ddl.sql
@@02_uar_packages.sql
-- @@03_uar_migration_legacy_audit.sql   -- optional
```
or just run `@INSTALL.sql`.

Then seed at least one admin (`insert into xxcti_uar_admins ...`, see the schema script),
and run the smoke tests commented at the bottom of `02_uar_packages.sql` before touching
APEX at all.

Once the schema/packages are confirmed working, build the application per
`APEX_BUILD_GUIDE.md` in Page Designer, then export it as `04_uar_apex.sql` for this repo
— at that point, future changes can go back to precise SQL patches the way the original
app-104 security patch did, since there'll be a real file to check parameter precedent
against.

## Known gotchas to keep in mind once the APEX layer exists here

Carried over from PMO Hub's history, all confirmed real:
- Never use `p_condition_type`/`p_condition_element`/`p_condition_expression` on
  `create_page_da_event()` — causes a silent import 400. Encode the condition in JS
  instead.
- A generic import 400 with no detail can mean a stale copy of the app already exists in
  the target workspace, not a SQL defect — check there first.
- Don't add a `wwv_flow_imp_page.*`/`wwv_flow_imp_shared.*` parameter with no precedent
  elsewhere in the file — grep for it first.
- `DECODE` is SQL-only — use `CASE` in bare PL/SQL.
- A PL/SQL process that does DML and then redirects needs an explicit `commit;` first, or
  the DML silently rolls back.
- When hand-editing already-escaped export text, verify quote-doubling mechanically, not
  by eye.
