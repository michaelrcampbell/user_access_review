# UAR PATCH: move employees between managers (2026-11-17)

Oracle User Access Review, application 530, workspace `ct_bsg_apex`, schema `XXUAR`.
Applies to **DEV, TEST and PROD** (in that order). It upgrades the release currently in PROD (tag `prod-2026-10-27`).

## What changes for people
On **Reviewer Assignments (Page 5)** an admin can now **move any employee to another manager's team**, even when Workday
already has a valid manager for them. Find the employee (search grid), click their number, pick the new reviewer, give a
reason, **Move Employee**.
- The employee leaves the old manager's team and appears on the new reviewer's team immediately. Decisions already
  recorded on that employee's items are kept (the new reviewer can change them).
- A **reason is required** when moving someone away from their Workday manager. Every move is written to the admin log
  (`MOVE_REVIEWER`).
- **Remove** on the assignment list returns the employee to their Workday manager.
- Same safety rules as before: nobody reviews themselves, the reviewer needs an email, no one reviews someone above them
  in their own chain, and two people cannot review each other.
- If the new reviewer has already submitted the cycle, the admin gets a warning that they must reopen/re-submit.

### BEHAVIOUR CHANGE you must check before patching
Until now an assignment was **ignored whenever Workday had a usable manager**. After this patch an assignment **always
applies** until removed. Any existing assignment where Workday has a *different* manager will therefore **start taking
effect** when you patch. Pre-flight check 3 lists them. Remove any that are not wanted (Page 5) before Step 2.

## Change record (fill in before you start)
| | |
|---|---|
| Change / ticket | |
| Environment (DEV / TEST / PROD) | |
| Window (date, start-end) | |
| Deployer | |
| Approver (PROD) | |
| TEST checklist signed off by / date (PROD) | |
| Backup / restore point reference (Step 0) | |

## Steps

### Step 0 - backup
- **App export**: App Builder > application 530 > Export/Import > Export (keep the file; it is the quickest rollback of the app).
- **PROD**: ask a DBA for a restore point as well. The schema patch changes no data but replaces views and packages.
- Best done when **no cycle is open or nobody is mid-review**; it is safe in an open cycle, but users in the app during the
  import may see one page reload.

### Step 1 - pre-flight (read-only): `01_preflight_checks.sql`
Run as XXUAR. Check 2 = all `present` (the new view `not installed yet`). **Check 3: review every `STARTS TO APPLY` row.**
Check 4 shows any open cycle (moves act on it at once). Check 5: PROD should already read AVAILABLE / feedback Disabled.

### Step 2 - schema patch: `02_schema_patch.sql`
Run as **XXUAR** (SQL Workshop > SQL Scripts or SQLcl). Safe to repeat. It replaces the effective-reviewer view, adds the
view `xxcti_uar_employee_reviewers`, and recompiles the packages (`assign_reviewer` rewritten). Any "compilation errors"
message: stop and use the rollback.

### Step 3 - import the application
- **DEV / TEST**: `03_app/04_uar_apex.sql`
- **PROD**: `03_app/04_uar_apex_PROD.sql` (identical except availability AVAILABLE and feedback off)
App Builder > Import > install as **application 530**, parsing schema **XXUAR**, "Replace existing application".
If Import fails with an opaque error (HTTP 400), run the file through SQL Workshop > SQL Scripts to see the real message.
**SSO credential**: re-importing creates/overwrites the web credential `Creation_APEX_DEV_PMO` **empty** - re-enter the
Client ID and secret (Workspace Utilities > Web Credentials) if sign-in shows AADSTS900144 afterwards. (If you already did
this for the environment and the import kept it, nothing to do - check by signing in.)

### Step 4 - verify (read-only): `04_post_deploy_verify.sql`
Checks 1 and 2 return no rows; check 3 one VALID row; check 5 matches; check 6 no rows; check 7 correct availability
(PROD: AVAILABLE, feedback Disabled); check 8 lists the new Page 5 regions.

### Step 5 - checklist: `05_TEST_CHECKLIST.md`
Run all of it in TEST; in PROD run section A and only the "read-only look" items of section B unless you actually have a
real move to make (a real move is the production use of the feature).

### Step 6 - mark what is live
    git tag <env>-YYYY-MM-DD <commit from MANIFEST.txt>

## Rollback
1. `rollback/R1_restore_previous_packages.sql` as XXUAR (previous packages, triggers and effective view).
2. Re-import the previous app: `rollback/R2_previous_app_04_uar_apex.sql` (DEV/TEST) or `..._PROD.sql` (PROD), or your
   Step 0 export.
3. Optional `rollback/R3_optional_remove_new_objects.sql` drops the new view only.
Moves made while the patch was live: after rollback the old rule returns (assignments ignored where Workday has a
manager), so those employees go back to their Workday manager. The admin log keeps the record.

## Files
| File | Purpose |
|---|---|
| `01_preflight_checks.sql` | read-only checks, including assignments that will start to apply |
| `02_schema_patch.sql` | views, packages, comments (generated from the repo) |
| `03_app/04_uar_apex.sql` | application export for DEV/TEST |
| `03_app/04_uar_apex_PROD.sql` | application export for PROD |
| `04_post_deploy_verify.sql` | read-only checks after |
| `05_TEST_CHECKLIST.md` | functional test of the move feature and regression |
| `rollback/` | R1 packages, R2 previous app (both variants), R3 optional |
| `MANIFEST.txt` | source commit and SHA-256 of every file |

## How this was prepared
Built from the repo branch `feature/move-employees` (commit in MANIFEST). The sandbox regression suite (104 checks) and an
HTTP-level walkthrough of Page 5 (move, reason required, removal, both managers' teams) passed. The standard and PROD app
files were generated from one source. Not yet run in DEV/TEST/PROD.
