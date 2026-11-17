# Test checklist - move employees between managers

Environment: ______  Tester: ______  Date: ______  Build/commit: ______
Use an **admin** account, and two **manager** accounts you can sign in as (call them Manager A and Manager B).
Pick a test employee **E** who reports to Manager A in Workday and is not an admin or above A/B in the hierarchy.
A cycle should be **open** for sections C-E (in TEST open one; in PROD do not test with real people).

## A. Deployment sanity (all environments)
- [ ] A1 Post-deploy verify script: checks 1, 2, 6 no rows; check 3 one VALID row.
- [ ] A2 Sign in with SSO as admin; the Home page loads, no errors.
- [ ] A3 Reviewer Assignments opens; sections shown: explainer, Unassigned, Assign a Reviewer, search grid
      ("Find an Employee"), Move an Employee, Current Assignments.
- [ ] A4 A non-admin cannot reach Page 5 (access-denied / not listed in the menu).

## B. Page 5 read-only look (safe in PROD)
- [ ] B1 The search grid lists employees with their current reviewer, and who Workday says the manager is.
- [ ] B2 Searching by name/number filters the grid.
- [ ] B3 Clicking an employee number shows "Moving <name>" with current reviewer, and nothing is changed yet.
- [ ] B4 Existing assignments (pre-flight check 3) show the status you expected and "Workday Manager (overridden)".

## C. Move an employee (TEST)
- [ ] C1 Select E, choose Manager B, **leave the reason blank**, Move -> refused with a clear message, nothing changed.
- [ ] C2 Move E to Manager B **with a reason** -> success message naming old and new reviewer, and the item counts.
- [ ] C3 Current Assignments now lists E: "Active - moved from Workday manager", Workday manager = A.
- [ ] C4 Sign in as **Manager B**: E is on My Team Review with E's items; progress count includes them.
- [ ] C5 Sign in as **Manager A**: E is gone from the team; A's progress count dropped accordingly.
- [ ] C6 Manager A cannot open E's items by editing the URL/ids (access denied).
- [ ] C7 Decisions already recorded for E before the move are still shown to B; B can change one.
- [ ] C8 Admin log (Page 6 or equivalent) has a `MOVE_REVIEWER` row with both names, ids, and the reason.

## D. Rules
- [ ] D1 Moving E to **E themself** -> refused.
- [ ] D2 Moving E to someone **already reviewing E** -> refused.
- [ ] D3 Moving E's manager's report chain upward (someone **above** E/in E's chain, if available) -> refused (independence).
- [ ] D4 Making two people review each other -> refused.
- [ ] D5 Reviewer without an email -> refused (if you have such a record).
- [ ] D6 Move to the **Workday manager** by assignment -> refused with "remove the assignment instead".
- [ ] D7 If Manager B has **already submitted** the cycle, the move still works and shows the warning.

## E. Remove and unassigned flows
- [ ] E1 Remove E's assignment (Current Assignments) -> message says E returns to the Workday manager.
- [ ] E2 Manager A sees E again; Manager B no longer does; counts correct.
- [ ] E3 The original "Assign a Reviewer" flow for an employee with **no** reviewer still works and no longer
      says "ignored once Workday supplies a manager".

## F. Regression (normal reviewing)
- [ ] F1 A manager can approve/deny items, add a comment, and submit the team review.
- [ ] F2 Home page shows cycle progress; the Cycle pages (3, closed cycle view) open without errors.
- [ ] F3 Data issues page (Page 3 issues) opens.
- [ ] F4 Page 5 layout looks right on a narrow window (no overlap; dropdown has no grey bar).

Sign-off: ______________________  Result: PASS / FAIL  Notes: ______________________
