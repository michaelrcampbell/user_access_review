# UAR first install -> PROD : smoke test, go-live and monitoring

The workflows (reviewing, approving/denying, sign-off, closing, deleting) were tested in TEST. In PROD do **not** open a
cycle to test - opening one is the go-live. Sections A-E check the installation without creating review data; section F is
the go-live; section G is what to watch afterwards.

**Accounts:** ADMIN (a seeded admin), a second admin, a MANAGER (non-admin with direct reports), optionally a workspace
DEVELOPER account.

---

## A. Installation verified
- [ ] `05_post_deploy_verify.sql`: checks 1 and 2 return no rows.
- [ ] Check 3: TABLE 7, VIEW 6, SEQUENCE 4, PACKAGE 2, PACKAGE BODY 2, TRIGGER 2, PROCEDURE 1, FUNCTION 1, all valid.
- [ ] Check 6: 9 pages including 5; idle timeout 1800; date format `DD-Mon-YYYY`; availability **AVAILABLE**; feedback **Disabled**.
- [ ] Check 5: exactly the admins you seeded. Check 7: no cycles.

## B. Sign-in, access and production settings
- [ ] SSO sign-in works for ADMIN, the second admin and a MANAGER. *If Microsoft says `AADSTS900144 ... client_id`, the
      credential's Client ID is empty or the login scheme uses a different credential (README Step 4). A redirect error
      means the PROD callback address is missing from the Azure registration.*
- [ ] **MANAGER** sees only *My Team Review*; **ADMIN** also sees *Review Cycles*, *Audit History*, *Reviewer Assignments*
      and *Admin Users*.
- [ ] As MANAGER, open an admin page by address (e.g. `.../review-cycles`): *"Insufficient privileges, user is not an
      Administrator"*.
- [ ] No environment badge is shown (PROD has none by design).
- [ ] As a workspace DEVELOPER, running the app shows **no** developer edit links, and there is **no Feedback** link.
- [ ] (Optional) Idle 30 minutes, click: you are sent to sign in again.

## C. Empty system - as ADMIN
- [ ] My Team Review says *"No review cycle is open right now."* with a link to open a cycle.
- [ ] Review Cycles shows the **Needs attention** panel only for feed problems (duplicates, conflicting managers, shared
      emails, end-dated rows). With a clean feed it is absent. Audit History opens with no rows; Admin Activity shows
      your first-admin entries.

## D. Reviewer assignments (Page 5) - real configuration, keep the result
- [ ] *Employees Without a Reviewer* lists the people from pre-flight check 9.
- [ ] For each: assign a reviewer who is **outside their reporting chain** (the page refuses anyone who reports to them),
      with a reason. Each moves to *Current Assignments* with an **Active** badge.
- [ ] The list ends with *"Every employee in the responsibilities data has a reviewer."* (This must be true before go-live.)
- [ ] Sign in as an assigned reviewer (or use their Page 1 once a cycle is open): the assigned employee appears there.

## E. Admin Users (Page 7)
- [ ] The two admins are listed. Add a malformed email: refused. Remove your own address: refused.
- [ ] Admin Activity (Page 4) records the admin additions and the reviewer assignments.

## F. GO-LIVE - open the first real cycle (only when the go/no-go list is complete)
- [ ] Page 3 > Open New Cycle: real name, period start/end, due date. Success message shows the number of items and
      employees; **items equal the responsibility rows from pre-flight check 8**, and no "no reachable reviewer" warning
      appears.
- [ ] The cycle shows as *Open*; Manager Completion lists every manager with 0% progress.
- [ ] Spot-check three managers (use *Admin view* from Manager Completion): the employees listed match Workday.
- [ ] A real MANAGER signs in: sees their team, the due date and progress bar.
- [ ] Tell the managers the review is open and when it is due.
- [ ] **If anything is wrong and no decision has been recorded yet:** Page 3 > Delete Cycle (open cycles only), correct the
      cause, and open it again. Once decisions exist, do not delete - fix forward.

## G. After go-live
- [ ] Daily until the due date: Page 3 *Manager Completion* for who has not submitted; reopen a submission only when a
      manager asks (it is logged).
- [ ] Page 4 *Admin Activity* shows who did what; *Decision Changes* shows any decision that was later changed.
- [ ] Close the cycle at the due date (the confirmation says how many items and managers are still outstanding). A closed
      cycle is the permanent audit record and cannot be deleted from the app.
- [ ] Tag the commit (README Step 8) and file the signed checklist with the change record.

---
**Result (A-E):** PASS / FAIL (circle) &nbsp; **Tested by:** ____________ &nbsp; **Date:** ____________ &nbsp; **Notes:** ____________
