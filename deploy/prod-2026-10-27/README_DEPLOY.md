# UAR -> PROD: FIRST INSTALL pack (2026-10-27)

Oracle User Access Review, application 530, workspace `ct_bsg_apex`, schema `XXUAR`.
PROD has **no UAR objects yet**, so this is a first install. The schema and application are **the same code that
passed in DEV (tag `dev-2026-10-22`) and TEST (tag `test-2026-10-27`)**, with exactly two production application
settings switched (see "What differs from TEST").

Installing the app **does not start a review**. Nothing happens to anyone until an admin opens the first cycle
(that is the go-live action, see Step 7).

## Change record (fill in before you start)
| | |
|---|---|
| Change / ticket | |
| Window (date, start-end) | |
| Deployer | |
| Approver | |
| TEST checklist signed off by / date | |
| Backup / restore point reference (Step 0) | |
| Person who decides on rollback | |

## Go / no-go: all of these must be true
- [ ] The TEST checklist passed and was signed off.
- [ ] A DBA has taken a **restore point or backup** of the PROD database (Step 0).
- [ ] The **three source feeds are loaded in PROD** and current (pre-flight checks 2 and 8). A review snapshots what is
      in the feed on the day a cycle is opened.
- [ ] **SSO**: the PROD Azure app registration lists PROD's callback address
      (`https://<PROD host>/ords/apex_authentication.callback`) and you have its **Application (client) ID** and a
      **client secret value**.
- [ ] **Two admins** are named (so no one is locked out): their sign-in emails.
- [ ] You know **who will review the employees nobody can review** today (pre-flight check 9 lists them - expect the
      top of the hierarchy), so Page 5 can be completed before go-live.
- [ ] Managers know the review is coming and roughly when.

## What differs from TEST
Only two application settings, set in the application file by the pack generator (`--prod`):
- **Availability = Available** (TEST/DEV use "Available with edit links", which shows developer edit links to anyone with
  developer rights - not wanted in production).
- **End-user Feedback = off.**
Everything else, including the schema, is identical. The environment badge (DEV/TEST) is not shown in PROD by design.

## Steps

### Step 0 - restore point
Ask a DBA to take a restore point / backup of the PROD database and note the reference in the change record. (A first
install adds objects only, but this is the standard safety net and the quickest way back to "before".)

### Step 1 - pre-flight (read-only): `01_preflight_checks.sql`
Run as XXUAR (SQL Workshop > SQL Scripts, or SQLcl) and read every result.
- Check 1: database XXUAR on the **production** database; the guard column must not say STOP.
- Check 2: all three feeds `present`. Check 3: **no rows**. Check 4: five privileges. Check 5: XXUAR under CT_BSG_APEX.
  Check 6: **no rows** (id 530 free).
- Checks 7-9 are information: how the feed stores its ids (text or numbers - both are handled), data problems to expect
  on Page 3, and the **employees who will have no reviewer**.
- "End date already past" should be 0.

### Step 2 - install the schema: `02_schema_install.sql`
Run as **XXUAR**, **once**. About 33 objects. Any "compilation errors" message: stop.

### Step 3 - seed the first admin: `03_seed_first_admin.sql`
Edit the placeholder email to the first admin's sign-in email and run as XXUAR. Run it again with the **second admin's**
email (edit, run). It refuses to run until the placeholder is changed, and is harmless to repeat.

### Step 4 - import the application: `04_app/04_uar_apex.sql`
App Builder > **Import** > the file > install as **application 530**, parsing schema **XXUAR**.
- **SSO credential - fill in BOTH fields.** The import creates the web credential `Creation APEX - DEV - PMO` (static id
  `Creation_APEX_DEV_PMO`) with **no values**, and the "Azure AD SSO" login scheme is bound to it. Open Workspace
  Utilities > **Web Credentials** > that credential and enter the PROD registration's **Application (client) ID** in
  *Client ID or Username* and the secret **value** (not the secret ID) in *Client Secret or Password*; Apply Changes.
  (The name says DEV/PMO but is only a label. If you prefer a PROD-named credential, create it and select it in Shared
  Components > Authentication Schemes > **Azure AD SSO** > *Credential Store* - creating one alone changes nothing.)
- Sign-in error **AADSTS900144 "...client_id"** = the credential the scheme uses has an empty Client ID.
- If App Builder's Import fails with an opaque message (HTTP 400 / ORDS-13002), run the same file through
  **SQL Workshop > SQL Scripts**: it reports the real error.

### Step 5 - verify (read-only): `05_post_deploy_verify.sql`
Run as XXUAR. Check 6 must show **availability AVAILABLE** and **feedback Disabled**, 9 pages, idle timeout 1800, date format
`DD-Mon-YYYY`. Check 3 must show the exact object counts.

### Step 6 - smoke test: `06_PROD_CHECKLIST.md` sections A-E
Sign-in, access control, empty states and reviewer assignments. **Do not open a cycle to test** - TEST already proved the
workflows; opening one in PROD is the go-live.

### Step 7 - go live: open the first real cycle (checklist section F)
Only when the go/no-go list is complete and Page 5 shows no unassigned employees. Opening a cycle snapshots the live feed.
If you open it wrongly **before any decision is recorded**, an open cycle can be deleted (Page 3) and reopened correctly.
Closed cycles can never be deleted from the app.

### Step 8 - mark what is live
    git tag prod-YYYY-MM-DD <commit from MANIFEST.txt>

## Rollback
**Before go-live (no real cycle opened):** remove the application (App Builder > application 530 > Edit Application
Properties > **Delete this Application**), then run `rollback/R1_uninstall_everything.sql` after changing `l_confirm` from
`'NO'` to `'YES'`. This leaves PROD as it was and never touches the feeds. Or restore the Step 0 restore point.

**After go-live (a real cycle exists):** **do not run the uninstall.** It deletes every cycle, decision and the admin log
- the audit evidence this system exists to keep. Instead: set the application to *Unavailable* (App Builder > Edit
Application Properties > Availability) to stop use, keep the data, and fix forward.

## What is deliberately NOT in this pack
`00_uar_sandbox_source_stubs.sql`, `05_uar_sandbox_seed.sql`, `07_uar_regression_tests.sql` are sandbox-only (fake feeds,
tests that open and delete cycles). **Never run them in PROD.** The three source feeds are not created by the install.

## Files
| File | Purpose |
|---|---|
| `01_preflight_checks.sql` | read-only checks before you change anything |
| `02_schema_install.sql` | the whole schema, first install only (generated from the repo) |
| `03_seed_first_admin.sql` | inserts an admin - edit the email first, run once per admin |
| `04_app/04_uar_apex.sql` | the application export (production variant) |
| `05_post_deploy_verify.sql` | read-only checks after |
| `06_PROD_CHECKLIST.md` | smoke test, go-live and monitoring |
| `rollback/R1_uninstall_everything.sql` | guarded uninstall (pre-go-live only) |
| `MANIFEST.txt` | source commit and SHA-256 of every file |

## How this was prepared
The schema scripts are byte-identical to the TEST pack's and were rehearsed end to end in an empty sandbox schema
against a feed shaped like DEV's (install, first admin, verification, smoke test, uninstall). The production application
variant was generated from the same source and import-tested in the sandbox. The real PROD import has not been run.
