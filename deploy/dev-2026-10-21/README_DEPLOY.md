# UAR release -> DEV deployment pack (2026-10-21, build 2 of 2026-10-22)

Oracle User Access Review, application 530, workspace `ct_bsg_apex`, schema `XXUAR`.
Moves DEV from the previous release (`416c666`, the last merged state) to this one.
Everything here is a **manual** deployment: three things are run by hand, in order, plus two read-only checks.

> **Build 2 - read this if you already ran the first build's `02_schema_patch.sql` on DEV.**
> The first build stopped at the effective-reviewer view with `ORA-00932 ... "O"."REVIEWER_ID" is of data type
> NUMBER, which is incompatible with expected data type CHAR`: in DEV the Workday feed stores `manager_id` as
> text, and the sandbox it was tested on stored it as a number. Build 2 reads the ids through a small view that
> works for either, and was re-tested against sandbox copies with a text `manager_id` and with both ids as text
> (83/83 regression checks each, plus a walk through the real pages).
> **What to do:** just run this build's `02_schema_patch.sql` again (it is safe to repeat; it creates what the
> first run could not and recompiles the packages). Until you do, the first run may have left the packages
> **invalid**, which would make the *current* DEV app error. Then run `04_post_deploy_verify.sql` (checks 1 and 2
> must be empty). If you would rather undo everything first, `rollback/R1_restore_previous_packages.sql` restores
> the previous packages.

## What this release is

**Control fixes** (found in a pre-release review, each reproduced before fixing):
admins can no longer approve their own access; sign-off is validated on the server (open cycle, real
manager, your own review or an admin's, nothing still pending); closed cycles can no longer be deleted;
admin actions (open/close/delete cycle, reopen a submission, submit on behalf, add/remove admin, assign
reviewer) are logged; rewriting a denial reason is tracked in the history; the database now enforces one
open cycle, unique cycle names and end date >= start date.

**New:** a **Reviewer Assignments** page (Page 5, admins only) for employees nobody can review today (top of
the hierarchy, manager missing from Workday, or not in Workday at all). A reviewer is assigned by an admin,
must not report to the employee, and is only used while Workday has no manager for that employee.

**Usability and looks:** success messages on every action; "no cycle open" / "not linked to an employee"
states; an "Admin view" banner; confirm dialogs that say how much is pending; status badges; progress bars;
one date format (`DD-Mon-YYYY`); error text without the `ORA-20xxx:` prefix; **30-minute idle session
timeout**.

Full detail: `CHANGELOG.md` in the repo.

## Before you start

| Need | Detail |
|---|---|
| Who | someone who can run SQL as **XXUAR** in DEV and import applications in workspace `ct_bsg_apex` |
| Time | about 15-20 minutes, plus testing |
| When | a quiet time. The import **replaces the application**: signed-in users are dropped, and users' private saved Interactive Report views may be lost. Cycle data is not touched. |
| Baseline | DEV currently runs the previous release (app 530, tables from `01_uar_schema_ddl.sql`). Step 1 checks this. |

## Steps

### Step 0 - back up the current DEV application
App Builder > application 530 > **Export/Import** > **Export** > save the `.sql` file somewhere safe.
This is your fastest way back (see Rollback).

### Step 1 - pre-flight (read-only): `01_preflight_checks.sql`
Run it as XXUAR (SQL Workshop > SQL Scripts, or SQLcl) and read every result.
- Check 2 must say `present` for all eight tables, otherwise DEV is not on the expected baseline - stop and ask.
- Check 5 must say `OK` three times. If not, fix that data first (close an extra open cycle, rename a duplicate
  cycle, correct a cycle's dates); the schema patch would refuse to run otherwise.
- Checks 6 and 7 are information: they show the data problems and the employees with **no reviewer** that Page 3
  and Page 5 will start showing. Expect the top of your hierarchy in check 7 and decide who should review them.
- Check 6 line "end date already past" should be 0 (you expect no end-dated responsibilities). If it is not,
  those rows will be included in the next review cycle.

### Step 2 - schema patch: `02_schema_patch.sql`
Run as **XXUAR**. It is safe to run more than once (objects that already exist are left alone; views and
packages are replaced).
- Part A creates the log table, reviewer-assignment table, views (including `xxcti_uar_workday_norm`, which
  hides whether the Workday ids are text or numbers), indexes and constraints.
- Part B adds table comments. Part C replaces the packages, triggers and error handler.
- Expect every statement to succeed. A "compilation errors" message on any package or trigger means stop and
  tell me; `04_post_deploy_verify.sql` checks 1 and 2 must also come back empty.
- If Part A stops with a message starting `More than one cycle is OPEN`, `Duplicate cycle names` or
  `A cycle has period_end earlier than period_start`, fix that data and run the file again from the top.

### Step 3 - import the application: `03_app/04_uar_apex.sql`
App Builder > **Import** > choose the file > install as **application 530** (it replaces the existing app 530 -
this is how previous releases went in). Parsing schema `XXUAR`.
- **SSO credential:** the export references the web credential `Creation APEX - DEV - PMO`. If the import asks for
  its **client secret**, enter the same secret as before. If SSO sign-in fails after the import, re-enter the secret
  under Workspace Utilities > Web Credentials (the credential name and the Azure app registration are unchanged by
  this release).
- If App Builder's Import fails with an opaque message (HTTP 400 / ORDS-13002), run the same file through
  **SQL Workshop > SQL Scripts** instead: it reports the real error.

### Step 4 - verify (read-only): `04_post_deploy_verify.sql`
Run as XXUAR. Each result has an "expect" note above it (no invalid objects, 8 new objects, 9 pages including Page 5, idle
timeout 1800, date format `DD-Mon-YYYY`, existing cycles unchanged compared with pre-flight check 4).

### Step 5 - test: `05_TEST_CHECKLIST.md`
Work through it with an admin account and a non-admin manager account. Record anything that fails.

### Step 6 - mark what is live
When the checklist passes, tag the commit this pack was built from (see `MANIFEST.txt`), mirroring what is done
for PMO Hub:

    git tag dev-2026-10-21 <commit from MANIFEST.txt>

## After the deploy: decisions for you
1. **Page 5 will list employees with no reviewer** (check 7 of the pre-flight shows them in advance). Assign
   reviewers; for the person at the very top you need someone outside their reporting chain (a peer or a
   board-level employee record with an email).
2. **Page 3 may show a data-quality warning** if the Workday feed has duplicate employees, conflicting managers or
   shared emails. Those need fixing at the source.
3. Admins can submit a review on a manager's behalf (allowed, and logged). Say so if you would rather forbid it.

## Rollback
See `rollback/`. Quickest path: re-import the Step 0 backup (or `R2`), then run `R1` to restore the previous
packages. `R3` (optional) removes the new tables/views - normally leave them, they are harmless and `R3` also
discards the admin log. Cycle data is never changed by this release or by the rollback.

## What is deliberately NOT in this pack
`00_uar_sandbox_source_stubs.sql`, `05_uar_sandbox_seed.sql` and `07_uar_regression_tests.sql` are sandbox-only
(fake data, and tests that open and delete cycles). **Never run them in DEV.**
`01_uar_schema_ddl.sql` is not re-run either: DEV already has those tables.

## Files
| File | Purpose |
|---|---|
| `01_preflight_checks.sql` | read-only checks before you change anything |
| `02_schema_patch.sql` | schema + packages (generated from the repo; re-runnable) |
| `03_app/04_uar_apex.sql` | the application export |
| `04_post_deploy_verify.sql` | read-only checks after |
| `05_TEST_CHECKLIST.md` | what to test and what "working" looks like |
| `rollback/` | previous release's packages and app, optional cleanup |
| `MANIFEST.txt` | source commit and SHA-256 of every file (compare if a file is ever in doubt) |
