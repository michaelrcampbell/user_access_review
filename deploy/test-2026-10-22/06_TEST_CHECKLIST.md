# UAR first install -> TEST : test checklist

Tick each box when it behaves as described. If something fails: note the page, what you did and what you saw, and
stop before the next area if it is in sections 0-3.

**Accounts you need** (sign-in is SSO):
- **ADMIN** - the email you seeded in Step 3 (and any others added on Page 7).
- **MANAGER** - a non-admin whose sign-in email matches a Workday manager who has direct reports.
- **NON-MANAGER** - a non-admin employee with no reports (optional, for the empty states).

TEST starts with **no cycles**. You will open the first one in section 3; use a recognisable name such as
`TEST UAT 1`. Opening a cycle snapshots every responsibility in the TEST feed, so managers see real TEST data.

---

## 0. Fresh-install sanity (before anyone signs in)
- [ ] `05_post_deploy_verify.sql`: checks 1 and 2 return no rows; check 3 shows exactly TABLE 7, VIEW 6, SEQUENCE 4,
      PACKAGE 2, PACKAGE BODY 2, TRIGGER 2, PROCEDURE 1, FUNCTION 1 (all valid); check 6 shows 9 pages, idle timeout
      1800, date format `DD-Mon-YYYY`; check 5 shows only your first admin; check 7 shows no cycles.
- [ ] The environment badge next to the title reads **TEST** (it is shown when the database name contains TEST).
      *If there is no badge, that is cosmetic only - it depends on the database name.*

## 1. Sign-in, access and session
- [ ] **SSO sign-in** works for ADMIN and MANAGER. *If Microsoft says `AADSTS900144 ... client_id`, the credential
      the login scheme uses has an empty Client ID (or the scheme points at another credential) - see README Step 4. A
      redirect/callback error means the Azure registration is missing TEST's address; an invalid-secret error means
      the secret value is wrong or expired.*
- [ ] **MANAGER** sees only *My Team Review* in the side menu; **ADMIN** also sees *Review Cycles*, *Audit History*,
      *Reviewer Assignments* and *Admin Users*.
- [ ] As MANAGER, open an admin page by address (e.g. `.../review-cycles`): you get
      *"Insufficient privileges, user is not an Administrator"*, not the page.
- [ ] A signed-in user who is **not an admin and not linked to an employee** sees a plain explanation on My Team
      Review, not an error.
- [ ] Leave a signed-in page idle for 30 minutes, then click: you are sent to sign in again. *(Start this first and
      come back to it.)*

## 2. Empty system - as ADMIN, before any cycle exists
- [ ] My Team Review says *"No review cycle is open right now."* with a link to open a cycle.
- [ ] Review Cycles shows the **Needs attention** panel only if the pre-flight found feed data problems (duplicates,
      conflicting managers, shared emails, end-dated rows); with a clean feed it is absent. (Employees with no
      reviewer are only reported there once a cycle is open - they are listed on Page 5 either way.) The cycles table
      says no cycles exist yet.
- [ ] Audit History opens and shows no rows (no error). Admin Activity shows your first-admin entry.

## 3. Cycle management (Page 3) - as ADMIN
- [ ] Open New Cycle with everything blank: *"Cycle name, period start, period end, and due date are all required."*
- [ ] Due date in the past: refused. Period end before start: refused. (Messages have no `ORA-20xxx:` prefix.)
- [ ] Dates typed or picked appear as `DD-Mon-YYYY`.
- [ ] Open a valid cycle (`TEST UAT 1`): success message with the number of items and employees. If anyone has no
      reviewer the message adds a warning, and a **Needs attention** panel links to Reviewer Assignments.
- [ ] A second *Open Cycle* while one is open is refused (*"... is already open - close it first"*).
- [ ] The *Close or Delete a Cycle* dropdown selects the cycle you just opened.
- [ ] **Manager Completion** lists every manager with a progress bar and a *Submitted* badge; a manager's name opens that
      manager's team (Page 1 with the **Admin view** banner).
- [ ] Close/Delete are tried at the end (section 8) so that you still have a cycle to test with.

## 4. Reviewing - as MANAGER (My Team Review and Employee Review)
- [ ] Page 1 shows a greeting, the due date line, a **progress bar**, and your direct reports with a **Review Complete**
      badge (green "Yes" / amber "No").
- [ ] Dates everywhere read like `04-Nov-2026`.
- [ ] Click an employee: their responsibilities show an **Approval** badge (Pending / Approved / Denied) and **Last
      Used** as a date.
- [ ] **Approve** an item: it turns green *Approved* and the page stays where you were.
- [ ] **Deny** an item: a short form opens. Blank reason: refused. Only spaces: refused. A real reason: you return to the
      list and the item shows red *Denied* with the reason.
- [ ] **Undo** a decision: back to Pending.
- [ ] The progress bar moves as you decide; *Review Complete* turns "Yes" for a finished employee.
- [ ] **Submit My Review** appears only when every item is decided. Press it (confirm dialog): success message, the page
      says *"You submitted your review on ..."*, and employee pages show *Locked*.
- [ ] After submitting, opening an employee returns you to Page 1.

## 5. Admin view and self-review - as ADMIN
- [ ] From *Manager Completion* open a manager: the amber **Admin view** banner names them and offers *Back to my team*.
- [ ] Approve an item in their team: it works, and Audit History later shows **your** name as the approver.
- [ ] Try to review **your own** access: open the manager above you and click your own employee ID. The page does not
      open - you are sent back to *My Team Review*.
- [ ] **Reopen a Manager's Submission** (on Page 3) for the manager who submitted: success message, they can edit again.
      With nothing selected: *"Select a manager first."*

## 6. Reviewer Assignments (Page 5) - as ADMIN
- [ ] *Employees Without a Reviewer* lists the people from pre-flight check 9 (or says *"Every employee ... has a reviewer."*).
- [ ] Assign with nothing chosen: *"Choose both an employee and a reviewer."* Same person twice: *"Nobody can be their own
      reviewer."* A reviewer who reports to the employee: refused as not independent.
- [ ] Assign a valid reviewer (outside the employee's chain) with a reason: success message; the employee moves to
      *Current Assignments* with an **Active** badge.
- [ ] That reviewer sees the employee under *My Team Review* in the open cycle and can review them.
- [ ] *Remove an Assignment*: nothing chosen gives *"Select an assignment first."*; choose one and confirm: removed, the
      employee is back on the unassigned list.

## 7. Audit History (Page 4) and Admin Users (Page 7) - as ADMIN
- [ ] Audit History's main report shows Cycle, Employee (name), Oracle user, Responsibility, Application, **Decision**
      badge, Approver, Approval Date, Comments, Manager - on one screen width, dates not wrapping. More columns are in
      the Actions menu.
- [ ] **Decision Changes** shows the *Undo* and any changes you made, with previous decision and who changed it.
- [ ] **Admin Activity** lists what you did (open cycle, reopen, assign/remove reviewer).
- [ ] Admin Users: malformed email refused; a valid email is added (stored lower-case) and an exact repeat gives
      *"... is already an admin."*; removing it works (confirm dialog); removing **your own** address is refused;
      removing an address that is not an admin says so.

## 8. Close and delete rules - as ADMIN (do these last)
- [ ] **Close Cycle**: the confirm dialog says how many items are still pending and how many managers have not submitted.
      After closing: success message, status badge shows *Closed*, managers can no longer edit.
- [ ] **Delete Cycle** (red) on the **closed** cycle is refused (*"Closed cycles are part of the audit record ..."*).
- [ ] To test deleting an **open** cycle: open a second cycle named `TEST DELETE ME`, then Delete Cycle - it asks for
      confirmation and removes it. *(Only open cycles can be deleted.)*

## 9. Finish
- [ ] Re-run `05_post_deploy_verify.sql`: still no invalid objects.
- [ ] Decide what to leave in TEST: the closed `TEST UAT 1` cycle stays as the audit record (closed cycles cannot be
      deleted from the app).
- [ ] Record the result and tag the commit (README, Step 7).

---
**Result:** PASS / FAIL (circle) &nbsp; **Tested by:** ____________ &nbsp; **Date:** ____________ &nbsp; **Notes:** ____________
