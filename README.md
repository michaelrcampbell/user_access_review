# UAR (User Access Review) App — Rebuild

Oracle APEX app rebuilding the "Oracle User Access Review" MVP (originally app 104,
workspace `ct_bsg_apex`, schema `XXUAR`) around a proper review-cycle model instead of a
single mutable snapshot, plus the authorization fixes identified in the original app's
security review.

**Correction (2026-09-29):** earlier drafts of this repo assumed workspace/schema
`XXAPEX_EBS` — copied from the original app 104 export's declared owner without ever
confirming it — instead of asking. That mismatch (real values: workspace `ct_bsg_apex`,
schema `XXUAR`) is the confirmed likely cause of every `04_uar_apex.sql` import failure
during Stage 0 testing. Fixed in `04_uar_apex.sql`, `01_uar_schema_ddl.sql`, and
`02_uar_packages.sql`.

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
| Packages (`02_uar_packages.sql`) | Done, tested — `open_cycle`'s snapshot fixed 2026-09-28 to drop `last_logon` (not present on `xxcti_uar_employee_responsibilities`) |
| Legacy data migration (`03_uar_migration_legacy_audit.sql`) | Done, optional |
| APEX application (`04_uar_apex.sql`) | **Stage 0 hand-authored, untested** — shell + Login + Page 1 (My Team Review). Pages 2–4 follow in later stages once this imports clean. |

`04_uar_apex.sql` is hand-authored, not exported from Page Designer (there's no live instance
to build it in and export from yet) — built and reviewed stage by stage instead of all at
once, specifically so a failed import points at a small, known set of new components rather
than an entire app. See the file's own header comment for what's deliberately simplified in
Stage 0 (no logo/icons, no remember-me cookie, Classic Report instead of Interactive Grid on
Page 1, no progress-bar region yet). New app ID `105` — change
`p_default_application_id`/`p_id` references if that's taken in the target workspace, and
double check `p_default_workspace_id` (`1376906471187634`, copied from the original app 104
export on the assumption it's the same workspace).

### Testing Stage 0

1. Confirm `01_uar_schema_ddl.sql`/`02_uar_packages.sql` are already installed and at least
   one row exists in `xxcti_uar_admins` for your own email.
2. Run `04_uar_apex.sql` against the target workspace (SQL Workshop → SQL Scripts, or App
   Builder → Import).
3. If it fails: capture the exact error text (component name / page prompt line it failed
   under, if any) — that's usually enough to identify which specific call needs fixing
   without guessing.
4. If it imports: open the app, log in with an APEX account, and confirm Page 1 shows either
   your own name pre-selected (or the full manager list if you're in `xxcti_uar_admins`) and
   the "no access items" message (there's no open cycle yet, so this is expected — nothing
   to review until a cycle is opened via `xxcti_uar_cycle_pkg.open_cycle` from
   `02_uar_packages.sql`'s smoke tests).

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
  a gap where nothing in the MVP ever populated them. A prior-state history table
  (`xxcti_uar_review_items_history`) also preserves each earlier decision whenever a
  manager revises their own approval before the cycle closes — the MVP had no concept of
  this at all, and even this rebuild's own first pass only kept the latest decision.
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
@@01b_uar_release_hardening.sql     -- before 02: the packages use its views and log table
@@02_uar_packages.sql
-- @@03_uar_migration_legacy_audit.sql   -- optional
```
or just run `@INSTALL.sql`.

**Already installed (DEV/TEST)?** Run `01b_uar_release_hardening.sql`, then re-run
`02_uar_packages.sql` (every statement in it is `CREATE OR REPLACE`), then import the new
`04_uar_apex.sql`. `01b` stops with a plain message if existing data would violate its new
constraints (two open cycles, duplicate cycle names, a cycle ending before it starts).

Sandbox only (never DEV/TEST/PROD, which have the real Workday/EBS feeds):
`00_uar_sandbox_source_stubs.sql` + `05_uar_sandbox_seed.sql` build fake source data, and
`07_uar_regression_tests.sql` is an 83-check regression suite. It refuses to run while any
cycle is open, so it can never touch real review data.

Then seed at least one admin (`insert into xxcti_uar_admins ...`, see the schema script),
and run the smoke tests commented at the bottom of `02_uar_packages.sql` before touching
APEX at all.

`APEX_BUILD_GUIDE.md` is the original page-by-page spec written for building this in Page
Designer by hand; `04_uar_apex.sql` is now the actively-developed hand-authored path
instead, growing stage by stage as each prior stage is confirmed importing and working.

## Confirmed schema facts (from live `user_tab_columns` checks, not the APEX export)

- `xxcti_uar_employee_responsibilities` columns: `user_name`, `employee_number`,
  `responsibility`, `application`, `start_date`, `end_date` — **no `last_logon`**.
- `xxcti_uar_employee_responsibilities_audit` (the old MVP's single mutable table) columns
  confirmed 2026-10-12: `APPLICATION`, `APPROVAL`, `APPROVAL_DATE`, `APPROVER`, `AUDIT_ID`,
  `EMPLOYEE_NUMBER`, `END_DATE`, `LAST_LOGON`, `RESPONSIBILITY`, `START_DATE`, `USER_NAME`.
  **This is `last_logon`'s real source** — `xxcti_uar_cycle_pkg.open_cycle` now pulls it via
  a scalar `MAX()` match on employee/responsibility/application when snapshotting a new
  cycle. Whether this table is still actively refreshed by its original external process
  isn't confirmed (its most recent `last_logon` as of 2026-10-12 was 2026-09-28, right around
  when this rebuild started) — treat the value as best-available, not guaranteed-current.

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

## Deployment discipline

- **Export before import.** An import replaces the whole app. Take a fresh export of the
  currently-deployed app from the target workspace before importing a new version, so
  there's something to restore from if the import goes wrong. Not yet automated here —
  a manual step before each DEV import.
- **ID convention.** New hand-authored component ids in `04_uar_apex.sql` use the
  `9700000000000xxx` prefix (distinct from the original app 104's and PMO Hub's own id
  ranges, so the three never collide if ever compared side by side). Before adding a new
  id, grep the file to confirm it's unused — every id added this way so far has been
  verified unique and cross-reference-checked before committing; keep doing that.
- **Script size.** `04_uar_apex.sql` is currently about 90 KB and imports cleanly through
  SQL Workshop → SQL Scripts. PMO Hub's export (about 796 KB) was too large for SQL
  Scripts on this instance. If this file approaches the high hundreds of KB, switch to
  App Builder → Import instead of waiting for a size error.

## Deployment packs
`deploy/<env>-<date>/` is a ready-to-run manual deployment pack (pre-flight checks, schema patch, app export,
post-deploy checks, a test checklist, rollback files, and a manifest). `deploy/make_pack.py <folder> <from-ref>`
assembles the generated parts from the repo; `from-ref` is whatever is currently live in the target. Start with
`deploy/dev-2026-10-21/README_DEPLOY.md`. After a pack is deployed and tested, tag the source commit
(`dev-YYYY-MM-DD`, `test-...`, `prod-...`) like PMO Hub does.
