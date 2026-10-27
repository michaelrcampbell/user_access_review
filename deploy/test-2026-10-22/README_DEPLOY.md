# UAR -> TEST: FIRST INSTALL pack (2026-10-22)

Oracle User Access Review, application 530, workspace `ct_bsg_apex`, schema `XXUAR`.
TEST has **no UAR objects yet**, so this is a first install, not an upgrade. The schema and application files are
**identical to what DEV runs** (git tag `dev-2026-10-22`), so what you test in TEST is what you tested in DEV.

Manual deployment: three things are run by hand in order (schema, first admin, app), with read-only checks
before and after.

## What gets installed
- **Schema (`XXUAR`):** 7 tables, 6 views, 4 sequences, 2 packages, 2 triggers, 1 procedure, 1 function. The three
  source **feeds** (Workday managers, responsibilities, responsibilities audit) are **not** created - they must
  already be loaded.
- **Application 530** (`Oracle User Access Review V2`): 9 pages - My Team Review, Employee Review, Review Cycles,
  Audit History, Reviewer Assignments, Admin Users, Deny Item, Login, Global. 30-minute idle timeout, dates as
  `DD-Mon-YYYY`.
- **No data** except the first admin you seed in Step 3. The first review cycle is opened by an admin in the app.

## Before you start - these must be true
| Needed | Why / how to check |
|---|---|
| Schema **XXUAR** exists in the TEST database, is attached to workspace **ct_bsg_apex**, can create tables/views/sequences/procedures/triggers and has storage quota | pre-flight checks 4 and 5. If the schema is missing, a DBA creates it and assigns it to the workspace first. |
| The **three source feeds** exist in XXUAR with data | pre-flight check 2 (and 8, 9 for what is in them). The install does not create them; without them the views cannot be created. If TEST has no feed yet, stop and ask - do not install around it. |
| Application id **530** is free in the workspace | pre-flight check 6 |
| **SSO** for the TEST URL: the Azure app registration lists TEST's callback address (`https://<TEST host>/ords/apex_authentication.callback`) and you have its **Application (client) ID** and a **client secret value** | Step 4. The import creates the web credential **empty** (export files never carry credential values). |
| The **email you sign in with** (SSO email claim) for the first admin | Step 3 |
| Who | someone who can run SQL as XXUAR and import applications in `ct_bsg_apex` on TEST |
| Time | about 20 minutes plus testing |

## Steps

### Step 1 - pre-flight (read-only): `01_preflight_checks.sql`
Run as XXUAR (SQL Workshop > SQL Scripts, or SQLcl) and read every result.
- Check 2: all three feeds `present`. Check 3: **no rows**. Check 4: five privileges. Check 5: XXUAR under
  CT_BSG_APEX. Check 6: **no rows** (id 530 free).
- Checks 7-9 are information: how the feed stores its ids (text or numbers; the release handles both), data
  problems to expect on Page 3, and the **employees who will have no reviewer** (expect the top of the hierarchy) -
  decide who should review them.
- "End date already past" should be 0 (you expect no end-dated responsibilities).

### Step 2 - install the schema: `02_schema_install.sql`
Run as **XXUAR**, **once**. It is a first-install script: running it a second time makes the original
`create table` statements fail (nothing is lost, but run `rollback/R1_uninstall_everything.sql` and start again
if you need a clean redo).
- Expect every statement to succeed (about 33 objects). Any "compilation errors" message: stop and tell me.

### Step 3 - seed the first admin: `03_seed_first_admin.sql`
Open the file, replace `CHANGE.ME@yourcompany.com` with your sign-in email, run as XXUAR. (It refuses to run until
you edit it, and is harmless to repeat.) Further admins are added later on the Admin Users page.

### Step 4 - import the application: `04_app/04_uar_apex.sql`
App Builder > **Import** > choose the file > install as **application 530**, parsing schema **XXUAR**.
- **SSO credential - fill in BOTH fields.** The import creates the web credential `Creation APEX - DEV - PMO`
  (static id `Creation_APEX_DEV_PMO`) with **no values**, and the "Azure AD SSO" login scheme is bound to it. Open
  Workspace Utilities > **Web Credentials** > that credential and enter the TEST registration's **Application
  (client) ID** in *Client ID or Username* and the secret **value** (not the secret ID) in *Client Secret or
  Password*; Apply Changes. (If the import wizard prompts for them, fill both in there.) The name says DEV/PMO but it
  is only a label.
- If you would rather use a TEST-named credential, create it and then select it in Shared Components >
  Authentication Schemes > **Azure AD SSO** > *Credential Store*. **Creating a credential alone changes nothing**: the
  scheme keeps using the one it was exported with.
- Sign-in error **AADSTS900144 "The request body must contain the following parameter: client_id"** means the credential
  the scheme uses has an empty Client ID, or the scheme points at a different credential from the one you filled in.
- If App Builder's Import fails with an opaque message (HTTP 400 / ORDS-13002), run the same file through
  **SQL Workshop > SQL Scripts** instead: it reports the real error. (If the workspace id differs from the one
  inside the file, the App Builder import still targets the workspace you are logged in to.)

### Step 5 - verify (read-only): `05_post_deploy_verify.sql`
Run as XXUAR. Each result has an "expect" note: no invalid objects, the exact object counts, 9 pages, idle
timeout 1800, date format `DD-Mon-YYYY`, your first admin, no cycles yet.

### Step 6 - test: `06_TEST_CHECKLIST.md`
Work through it with an admin account and a non-admin manager account.

### Step 7 - mark what is live
After the checklist passes, tag the commit named in `MANIFEST.txt`:

    git tag test-YYYY-MM-DD <commit from MANIFEST.txt>

## After the install: decisions for you
1. **Assign reviewers** on Page 5 for the employees nobody can review (pre-flight check 9 listed them).
2. **Page 3 may warn** about Workday data problems (duplicates, conflicting managers, shared emails): those are fixed at the source.
3. Admins can submit a review on a manager's behalf (allowed and logged).

## Rollback (undo a first install)
1. **Remove the application:** App Builder > application 530 > Edit Application Properties > **Delete this Application**.
2. **Remove the schema objects:** open `rollback/R1_uninstall_everything.sql`, change `l_confirm` from `'NO'` to
   `'YES'`, run as XXUAR. **This deletes every cycle, decision, log entry and reviewer assignment** and cannot be
   undone. It never touches the three source feeds. Safe to run twice.
Both steps leave TEST as it was before this install.

## What is deliberately NOT in this pack
`00_uar_sandbox_source_stubs.sql`, `05_uar_sandbox_seed.sql` and `07_uar_regression_tests.sql` are sandbox-only
(fake feeds, and tests that open and delete cycles). **Never run them in TEST.**

## Files
| File | Purpose |
|---|---|
| `01_preflight_checks.sql` | read-only checks before you change anything |
| `02_schema_install.sql` | the whole schema, first install only (generated from the repo) |
| `03_seed_first_admin.sql` | inserts the first admin - edit the email first |
| `04_app/04_uar_apex.sql` | the application export |
| `05_post_deploy_verify.sql` | read-only checks after |
| `06_TEST_CHECKLIST.md` | what to test and what "working" looks like |
| `rollback/R1_uninstall_everything.sql` | guarded uninstall of the schema objects |
| `MANIFEST.txt` | source commit and SHA-256 of every file |

## How this pack was rehearsed
The same install script, first-admin script, verification, a functional smoke test and the uninstall were run
end to end in an empty sandbox schema using a Workday feed shaped like DEV's (text `manager_id`): no errors, exact
object counts as above, uninstall left nothing behind and did not touch the feeds. The application import itself
was not rehearsed for TEST (it is the same file that went into DEV).
