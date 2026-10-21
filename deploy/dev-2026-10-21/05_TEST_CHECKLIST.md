# UAR release -> DEV : test checklist

Tick each box when it behaves as described. Anything that does not: note the page, what you did, what you saw,
and stop before moving to the next area if it is in sections 1-3.

**Accounts you need** (DEV signs in through SSO):
- **ADMIN** - an email listed in `xxcti_uar_admins` (Page 7).
- **MANAGER** - a non-admin whose sign-in email matches a Workday manager who has direct reports.
- **NON-MANAGER** - a non-admin employee with no reports (optional, for the empty states).

Use an open cycle you can afford to experiment with. If you need a throwaway one: as ADMIN open a cycle named
`ZZ DEV test`, and delete it at the end (open cycles can be deleted; closed ones cannot).

---

## 1. Sign-in, session and shell
- [ ] **SSO sign-in** works for ADMIN and MANAGER. *If it fails, re-enter the web credential's client secret (README, Step 3).*
- [ ] The environment badge shows **DEV** next to the title.
- [ ] **MANAGER** sees only *My Team Review* in the side menu; **ADMIN** also sees *Review Cycles*, *Audit History*,
      *Reviewer Assignments* and *Admin Users*.
- [ ] As MANAGER, open an admin page by address (e.g. `.../review-cycles`): you get
      *"Insufficient privileges, user is not an Administrator"*, not the page.
- [ ] Leave a signed-in page idle for 30 minutes, then click something: you are sent to sign in again.
      *(Takes a while - start it first and come back to it.)*

## 2. Reviewing: My Team Review (Page 1) and Employee Review (Page 2) - as MANAGER
- [ ] Page 1 shows a greeting, the due date line, a **progress bar**, and your direct reports with a
      **Review Complete** badge (green "Yes" / amber "No").
- [ ] Dates everywhere read like `04-Nov-2026` (no `11/04/2026`, no `Nov 04, 2026`).
- [ ] Click an employee: Page 2 lists their responsibilities with an **Approval** badge
      (Pending / Approved / Denied) and **Last Used** as a date.
- [ ] **Approve** an item: it turns green *Approved* and the page stays where you were.
- [ ] **Deny** an item: a short form opens. Leave the reason blank and press *Confirm Deny*: it is refused
      ("must have some value"). Type only spaces: refused. Enter a real reason: you return to Page 2, the item
      shows red *Denied* with the reason.
- [ ] **Undo** a decision: back to Pending. (Check Audit History later: the earlier decision is kept.)
- [ ] Page 1 progress bar moves as you decide items; *Review Complete* turns to "Yes" for a finished employee.
- [ ] **Submit My Review** is only offered when every item is decided. Press it (confirm dialog appears): you get a
      success message, the page says *"You submitted your review on ..."*, and the employee pages show *Locked*.
- [ ] After submitting, opening an employee takes you back to Page 1 (you can no longer change items).
- [ ] As **NON-MANAGER** (or an account not linked to an employee): Page 1 explains there is nothing to review
      instead of showing an empty table. With no cycle open, Page 1 says *"No review cycle is open right now."*

## 3. Cycle management (Page 3) - as ADMIN
- [ ] Open New Cycle with everything blank: *"Cycle name, period start, period end, and due date are all required."*
- [ ] Due date in the past: refused. Period end before start: refused. (Messages have no `ORA-20xxx:` prefix.)
- [ ] Dates typed or picked appear as `DD-Mon-YYYY`.
- [ ] Open a valid cycle: success message with the number of items and employees. If anyone has no reviewer the
      message adds a warning and a **"Needs attention"** panel appears with a link to Reviewer Assignments.
- [ ] A second *Open Cycle* while one is open is refused (*"... is already open - close it first"*).
- [ ] *Close or Delete a Cycle* dropdown selects the cycle you just opened.
- [ ] **Close Cycle**: the confirm dialog says how many items are still pending and how many managers have not
      submitted. After closing: success message, status badge changes to *Closed*, managers can no longer edit.
- [ ] **Delete Cycle** (red) on a **closed** cycle is refused ("Closed cycles are part of the audit record ...").
      On an **open** cycle it asks for confirmation and then deletes it.
- [ ] **Reopen a Manager's Submission**: pick a manager who has submitted; success message; that manager can edit
      again. With nothing selected you get *"Select a manager first."*
- [ ] **Manager Completion** has its heading, a progress bar per manager, a *Submitted* badge, and the manager's
      name opens that manager's team (Page 1 with the **Admin view** banner).
- [ ] Data-quality panel: shows only if the pre-flight found problems (duplicates, conflicts, end-dated rows).
      If the pre-flight was clean, the panel is absent.

## 4. Admin view of someone else's team - as ADMIN
- [ ] From *Manager Completion* open a manager: Page 1 shows the amber **Admin view** banner naming that manager
      and a *Back to my team* link.
- [ ] Open one of their employees and approve an item: it works, and Audit History later shows **your** name as
      the approver.
- [ ] Try to review **your own** access: open the manager above you (Manager Completion) and click your own
      employee ID. The page does not open - you are sent back to *My Team Review*. (Nobody can approve their own
      responsibilities, admins included.)

## 5. Reviewer Assignments (Page 5) - as ADMIN
- [ ] The page opens; *Employees Without a Reviewer* lists the same people as pre-flight check 7
      (or says *"Every employee ... has a reviewer."*).
- [ ] Assign with nothing chosen: *"Choose both an employee and a reviewer."*
- [ ] Choose the same person as employee and reviewer: *"Nobody can be their own reviewer."*
- [ ] Choose a reviewer who reports (directly or indirectly) to the employee: refused as not independent.
- [ ] Pick an employee who is on the list and a valid reviewer outside their chain, add a reason, press
      *Assign Reviewer*: success message; the employee leaves the top list and appears under *Current Assignments*
      with an **Active** badge.
- [ ] Sign in as that reviewer (or use their Page 1 via Admin view): the assigned employee is listed under
      *My Team Review* in the open cycle, and can be reviewed.
- [ ] *Remove an Assignment*: with nothing chosen *"Select an assignment first."*; choose one and confirm: removed,
      the employee is back on the unassigned list.
- [ ] Page 3's *Needs attention* panel link opens this page.
- [ ] (Optional) If one of the people has since been given a manager in Workday, their assignment shows
      *"Not used - Workday now has a manager"*.

## 6. Audit History (Page 4) - as ADMIN
- [ ] The main report shows Cycle, Employee (name), Oracle user, Responsibility, Application, **Decision** badge,
      Approver, Approval Date, Comments, Manager - on one screen width, dates not wrapping. Other columns are
      available from the Actions menu.
- [ ] Items for employees missing from Workday still appear (employee shown by Oracle user name).
- [ ] **Decision Changes** lists the *Undo* and any change you made in section 2 with the previous decision, previous
      approver and who changed it.
- [ ] **Admin Activity** lists what you did in sections 3 and 5 (open/close/delete cycle, reopen, assign/remove reviewer).

## 7. Admin Users (Page 7) - as ADMIN
- [ ] Add a malformed email (`not-an-email`): refused with a clear message.
- [ ] Add a valid email: success message, listed (stored lower-case). Adding it again: *"... is already an admin."*
- [ ] Remove that email (confirm dialog): success message. Remove your **own** address: refused.
      Remove an address that is not an admin: *"... is not in the admin list."*

## 8. Housekeeping
- [ ] Delete any throwaway cycle you opened (open cycles only). Remove any test admin you added.
- [ ] Run `04_post_deploy_verify.sql` once more: no invalid objects, existing cycles unchanged.
- [ ] Note the result and tag the commit (README, Step 6).

---
**Result:** PASS / FAIL (circle) &nbsp; **Tested by:** ____________ &nbsp; **Date:** ____________ &nbsp; **Notes:** ____________
