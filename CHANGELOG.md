# 04_uar_apex.sql — build/debug history

Moved out of the SQL file's own header on 2026-09-30, after discovering that a large
accumulated comment block before `wwv_flow_imp.import_begin` is the likely reason App
Builder's Import wizard rejected the file as "not a valid Oracle APEX application import
file" — no other file built for this or any other project (including PMO Hub, the original
app 104 export, and a fresh `f113.sql` test export) has ever carried this much hand-authored
text before the real content starts, and none of them have hit this rejection. The wizard's
file-type check most likely only scans a limited prefix of the file looking for
`wwv_flow_imp.import_begin`; a bloated preamble can push it past that window. The SQL file's
header is now trimmed to match the real, compact canonical format exactly — this file is
where that history lives instead.

## Stage 0 — application shell, Login, Page 1 (My Team Review)

Confirmed importing and working 2026-09-29.

Deliberately simplified vs. the original app 104:
- No custom logo/app icons/PWA — omitted `p_logo_type`/`p_logo_text` entirely rather than
  guess at a valid token (original only ever shows `p_logo_type=>'IT'`, not the `'TEXT'`
  this file originally guessed — fixed 2026-09-29 after a bare import 400). Pure appearance
  either way; add back later via the real App Builder UI once the app exists.
- No "remember username" cookie on Login — convenience feature, not required for login to
  work.
- Page 1's employee list is a Classic Report, not an Interactive Grid — functionally
  equivalent for a read-only display, and matches the already-proven
  `create_report_region`/`create_report_columns` pattern from the original app's admin pages
  instead of the larger IG call chain.
- No progress-bar/no-open-cycle messaging region yet — region-level conditions have no
  precedent to check against in the original file; the report's own `p_query_no_data_found`
  message covers the empty case for now.
- Employee ID is not yet a link to Page 2 — Page 2 didn't exist until Stage 1.

**Bugs found and fixed during Stage 0:**
- `p_logo_type=>'TEXT'` had zero precedent in the original app 104 file (only `'IT'` is ever
  shown) — removed `p_logo_type`/`p_logo_text` entirely rather than guess at another token.
- `p_checksum_salt` was hand-typed as a 65-character hex string instead of the original's
  64 — never mechanically counted at the time. Fixed with a properly generated,
  length-verified 64-char value after re-reviewing the whole file line by line against a
  real, repeated import failure (not a length-sensitive value that's safe to eyeball, in
  hindsight).
- `p_default_workspace_id` and `p_default_owner`/`p_owner` were wrong — assumed (copied from
  the original app 104 export) rather than confirmed. Real values: workspace `ct_bsg_apex`
  (id `9805500296728652`, confirmed via a live export taken from it), schema `XXUAR`, not
  `XXAPEX_EBS`/`1376906471187634`. Turned out **not** to be the actual cause of the import
  failures at the time — fixed anyway since it was still wrong.
- **Actual root cause of the Stage 0 import failures**, found via SQL Workshop → SQL
  Scripts (which surfaces real PL/SQL errors, unlike App Builder → Import's opaque
  CORS-flavored 400/403 wrapper): `create_theme` had an extra `,p_version_scn=>...`
  parameter that procedure does not accept — added by mistake during an earlier "restore
  dropped `p_version_scn` params" pass that over-applied to a call it doesn't belong on
  (`create_list`, `create_security_scheme`, `create_acl_role`, and `create_authentication`
  DO take it; `create_theme` does not — confirmed against both the original app 104 export
  and `f113.sql`). Caused `PLS-00306 "wrong number or types of arguments in call to
  'CREATE_THEME'"`. Removed. **If App Builder Import ever throws an opaque error like this
  again with no useful detail, try SQL Scripts first — it gave the exact line and error
  immediately.**

## Stage 1 — Page 2 (Employee Review)

Editable Interactive Grid against `xxcti_uar_review_items`, mirroring the original app's
Page 2 IG structure/parameters as closely as possible — every `create_interactive_grid`/
`create_ig_report`/`create_ig_report_view`/`create_ig_report_column`/`create_region_column`
parameter is copied from a real, confirmed example, not guessed (see the `create_theme`
lesson above). New vs. the original: a `BEFORE_HEADER` process enforcing manager ownership
(`xxcti_uar_security_pkg.can_review`) and cycle-open status
(`xxcti_uar_cycle_pkg.can_edit_cycle`) before the grid loads, a `cycle_id` filter, and a
`COMMENTS` column for denial rationale.

**Known gap:** Page 1's Employee ID isn't yet a clickable link to Page 2 — the original's
link mechanism (`NATIVE_LINK` item type) is only confirmed precedented on an Interactive
Grid region column, and Page 1 here is a Classic Report. Testing Page 2 directly requires
manually navigating to it with `P2_EMPLOYEE_ID`/`P2_CYCLE_ID` set until this is revisited.

**Bugs found and fixed during Stage 1:**
- Runtime `ORA-20876` (APEX's generic wrapped-exception error) on Page 2. The gate process
  used `owa_util.redirect_url` — a legacy Oracle Web Agent API tied to the old mod_plsql/DAD
  gateway, known to misbehave under ORDS (confirmed this instance runs ORDS/`APEX_240200`
  from the error trace's package names). Switched both redirects to `apex_util.redirect_url`,
  the documented, gateway-safe API, which also stops page processing on its own — dropped
  the now-redundant explicit `apex_application.e_stop_apex_engine` raise after each call.
- Page 2 still 404'd (confirmed via Page Designer's own "Run Page" button, not just a
  manually-typed URL) even after the above. Root cause: the redirect target was hand-built
  as a relative classic-syntax fragment (`'f?p=' || :APP_ID || ':1:' || :APP_SESSION`). This
  app uses Friendly URLs (confirmed: Page 1 is reached at `.../uar-rebuild/my-team-review`,
  not via `:1:`) — a relative redirect from a friendly-URL request path resolves against
  that path and produces an unroutable URL, 404ing instead of reaching Page 1. Replaced both
  redirects' target with `apex_page.get_url(p_page => 1)`, the documented runtime API that
  generates a correct URL (friendly or classic, whichever the app actually uses) instead of
  assuming one.
- Two divergent app copies existed in the workspace at one point: one at whatever id the
  wizard's interactive override was set to (`530`) during manual imports, and one at
  whatever the file itself hardcoded (`105`) from a SQL Scripts run (which doesn't apply the
  wizard's override). A 404 on Page 2 was navigating into app `530`, which predated that
  session's Page 2 addition — not a real bug. Declared `530` directly in the file so SQL
  Scripts and Import both target the same app.
- App Builder's Import wizard rejected the file outright: "not a valid Oracle APEX
  application import file." First attempt: the canonical header had text appended directly
  onto the "Oracle APEX export file" line — restored verbatim, moved custom notes to a
  separate block. Didn't fix it. Second attempt: added the `Application Export:` metadata
  comment block that every real export has and this file never did. Didn't fix it either.
  **Actual cause (most likely): this file had accumulated 100+ lines of hand-authored
  commentary before `wwv_flow_imp.import_begin` even started** — no other file built for any
  project has this much text in front of the real content, and none of them have hit this
  rejection. The wizard's file-type check most likely only scans a limited prefix looking for
  that call; a bloated preamble pushes it past that window. Fixed by moving all of this
  history out of the SQL file (into this document) and trimming the file's own header back
  to the real, compact canonical format.

## Stage 1 follow-up — Page 1 → Page 2 link (2026-09-30)

Confirmed end to end: a cycle opened via `xxcti_uar_cycle_pkg.open_cycle` correctly
populates Page 1 with real data for the manager. But Page 1's Employee ID had no link to
Page 2 (noted as a known gap above), and "Run Page" on Page 2 from Designer just redirects
back to Page 1 — expected, since the ownership gate sees a null `P2_EMPLOYEE_ID` and denies.

Converted Page 1's report region from a Classic Report to an Interactive Grid (matching the
original app's Page 1 exactly), specifically to use the `NATIVE_LINK` item type on the
Employee ID region column — the only mechanism with confirmed precedent for a clickable
report-column link (from the original app's own Page 1 IG). Link target extends the
original's pattern to also pass `P2_CYCLE_ID`:
`f?p=&APP_ID.:2:&SESSION.::&DEBUG.::P2_EMPLOYEE_ID,P2_CYCLE_ID:#EMPLOYEE_ID#,&P1_CYCLE_ID.`
(`#COLUMN#` substitution for the row's own value, `&ITEM.` substitution for the page item).

## Stage 1 follow-up — link still didn't navigate (2026-09-30)

After the Page 1 → IG conversion, clicking the Employee ID link just stayed on Page 1.
Copied the link's actual resulting URL: `...?p2_employee_id=&p2_cycle_id=&session=...&cs=...
#EMPLOYEE_ID#,1` — both query params were empty, and the literal text `#EMPLOYEE_ID#,1` got
dumped as a URL fragment instead of being parsed as item values. `&P1_CYCLE_ID.` (a real
page item) substituted correctly to `1`; `#EMPLOYEE_ID#` never substituted at all, and a
literal `#` character in the value broke the whole items/values parsing for the friendly-URL
generator.

This means the original app's `&EMPLOYEE_ID.#EMPLOYEE_ID#` link value (copied as
`#EMPLOYEE_ID#,&P1_CYCLE_ID.` here) was mis-read — `&EMPLOYEE_ID.` (item-style syntax,
resolving to the same-named column when no such item exists) was apparently the part that
actually worked, with `#EMPLOYEE_ID#` being inert leftover text that happened not to cause
visible harm under classic URL rendering but breaks outright under Friendly URLs. Changed
both link values to the same `&COLUMN.` substitution style:
`f?p=&APP_ID.:2:&SESSION.::&DEBUG.::P2_EMPLOYEE_ID,P2_CYCLE_ID:&EMPLOYEE_ID.,&P1_CYCLE_ID.`

## Stage 2 — Page 3 (Review Cycles admin page)

Kept deliberately simple, using only mechanics already proven working in this file:
- "Open New Cycle" form (plain text fields for name/dates, `YYYY-MM-DD` format hint rather
  than a date-picker item type not yet used elsewhere) + a single button calling
  `xxcti_uar_cycle_pkg.open_cycle` via a `NATIVE_PLSQL` process, same shape as every other
  process in this file.
- "Cycles" and "Manager Completion - Current Cycle" Classic Reports, same
  `create_report_region`/`create_report_columns` pattern already proven on Page 1's original
  form and Pages 3/4/5 in the original app.
- Gated with `p_required_role` referencing the real "Administration Rights" scheme
  (precedented directly on `create_page` in the original app's own admin pages).
- Added a nav menu link to Page 3.

**Deliberately deferred:** a "Close Cycle" button. Only one button exists on this page
(`OPEN_CYCLE`) specifically to avoid needing an unproven "which button triggered this submit"
conditional-process pattern — no example of that exists anywhere in this file yet. Closing a
cycle still works fine via `xxcti_uar_cycle_pkg.close_cycle(<id>)` directly in SQL, same as
opening did before this page existed. Revisit once there's a confirmed-safe pattern for
multiple buttons/processes on one page.

## Stage 2 follow-up — bad nav-item authorization guess (2026-10-01)

`p_security_scheme=>'Administration Rights'` on the Page 3 nav list item caused
`APEX.AUTHORIZATION.UNHANDLED_ERROR` / `ORA-06502` (character to number conversion error)
inside `APEX_240200.WWV_FLOW_AUTHORIZATION` as soon as the nav menu rendered. `p_security_scheme`
on a list item is apparently only valid for the built-in reserved constants (like
`MUST_NOT_BE_PUBLIC_USER`, the only value ever seen on a list item in the original app) —
not a way to reference a custom-named authorization scheme by string; the authorization
resolver apparently tries to convert it to something numeric internally. No precedent
anywhere in this file for gating a list item by a custom scheme at all — removed the
parameter entirely rather than guess again at the right one. The real protection (Page 3's
`p_required_role`, which *is* precedented) was never affected; the nav link just shows to
everyone now, and non-admins get rejected by the page itself if they click it, which is
normal APEX behavior, not a gap.

## Stage 3 — Page 4 (Audit History admin page)

Cross-cycle historical report, same `create_report_region`/`create_report_columns` Classic
Report pattern as Page 3 (and the original app's own Audit History page) — join
`xxcti_uar_review_items` to `xxcti_uar_review_cycles` and `xxcti_uar_workday_employee_mgr`
(twice, for employee and manager) to show every review item across every cycle, including
the new `COMMENTS` column (denial rationale) the original never had. Same `p_required_role`
Administration Rights gate as Page 3, and a nav menu link added the same (unguarded) way as
Page 3's — learned from the Stage 2 `p_security_scheme` mistake not to repeat it.

This completes the originally-scoped rebuild stages (Pages 1–4). Remaining items are the
deferred cosmetic/UX pieces noted throughout this file: nav-hiding by role, a DEV/TEST/PROD
env badge, confirm() dialogs, a progress-bar region on Page 1, and a "Close Cycle" button.

## Backlog items — progress indicator + Close Cycle (2026-10-01)

- **Progress indicator on Page 1**: a small Classic Report region (`P1_PROGRESS`, one row)
  against `xxcti_uar_cycle_progress`, same proven pattern as every other report in this
  file — total items, completed items, pct complete for the current manager+cycle.
- **Close Cycle**, as its own Page 5 rather than a second button on Page 3: a text item
  defaulting to the current open cycle (via the same `BEFORE_HEADER` default-and-check
  pattern already used on Pages 1/2), one button, one process calling
  `xxcti_uar_cycle_pkg.close_cycle`, plus a read-only cycles list for context. Deliberately
  its own page instead of a second button on Page 3, specifically to avoid needing an
  unproven "which button triggered this submit" conditional-process pattern — every page in
  this file so far has exactly one button per page for that reason.

Still deferred, need a genuinely new (unproven in this file) mechanism each: nav-hiding
Pages 3/4/5 by role and a DEV/TEST/PROD env badge (both need a `NATIVE_PLSQL` dynamic-content
region, zero precedent here), and confirm() dialogs (need a Dynamic Action, zero precedent
here either).

## Nav-hiding + env badge, following the PMO Hub playbook (2026-10-01)

Per the user's reminder to use what PMO Hub already proved out (see memory
`feedback_apex_treeview_nav_hiding` / `project_pmo_hub`), rather than improvising:

- **Nav-hiding**: a `NATIVE_PLSQL` region on the Global Page emits a `<style>` block with a
  CSS attribute selector on `href` (`li:has(a[href*="review-cycles" i])...`), guarded by
  `xxcti_uar_security_pkg.is_admin = 'N'` — never JS DOM matching, exactly per the PMO Hub
  lesson (the Tree View widget re-renders its DOM asynchronously, so a JS approach loses
  that race; CSS re-applies automatically to anything the widget inserts). Matches on each
  page's alias (`review-cycles`/`audit-history`/`close-cycle`), with `:not(.t-Header-logo-link)`
  on every selector per the second PMO Hub gotcha (home page's logo link resolving to the
  same alias) — not actually triggered here since the home page is `my-team-review`, but
  kept as the same defensive habit.
- **Env badge**: a second `NATIVE_PLSQL` region, `SYS_CONTEXT('USERENV','CON_NAME')` matched
  against `%DEV%/%TEST%/%PROD%`, using PMO Hub's exact proven color scheme
  (`DEV=#2E75B6`/`TEST=#E6A817`/`PROD=#C00000`). Adapted the positioning: PMO Hub's badge
  JS-reads its "PMO Hub" logo's computed typography to sit flush beside it; this app has no
  custom logo at all right now (removed earlier — see Stage 0 notes), so the badge is just a
  fixed-position corner element instead rather than inventing a selector for a logo that
  doesn't exist.

Both use `p_plug_source_type=>'NATIVE_PLSQL'` on `create_page_plug` — no precedent for a
PL/SQL Dynamic Content *region* anywhere in this file before now (only the `NATIVE_PLSQL`
*process* type was precedented, on Pages 1/2's gate processes), so this is this file's
first genuine guess at that exact token. Every quote in both PL/SQL blocks was mechanically
quote-counted (even count per line) before committing, not eyeballed, per the
quote-escaping-layers lesson — a real mistake (using `\"` to escape double quotes, which
has no meaning in Oracle SQL/PL/SQL) was caught and fixed this way before even an import
attempt.

## App title + badge positioning, matching PMO Hub more closely (2026-10-01)

User asked for the app title ("Oracle User Access Review") and the env badge positioned
beside it on the left, above the nav bar — same as PMO Hub, rather than the generic fixed
corner badge from the previous commit.

- **App title**: added `p_logo_type=>'T'` + `p_logo_text=>'Oracle User Access Review'` to
  `create_flow`. Confirmed precedent this time, not a guess — `f113.sql` (a real export from
  this same workspace) uses exactly `p_logo_type=>'T'` + `p_logo_text=>'test'`, a genuinely
  different value from the original app 104's `'IT'` (Image+Text). `'T'` is text-only, which
  is what's needed here since this app has no logo image.
- **Badge positioning**: rewrote the Environment Badge region to inject a `<script>` that
  finds `.t-Header-logo-link` (Universal Theme's standard logo class — already relied on in
  the nav-hiding region's `:not()` guards, so confirmed to exist), reads its computed font
  via `getComputedStyle`, and inserts a styled `<span>` badge right after it — matching PMO
  Hub's actual technique (JS-matching the logo's typography) rather than a plain fixed-
  position div.
- Every line of the rewritten PL/SQL block was mechanically quote-counted (even count per
  line) before committing. Wrote the JS/HTML content using double quotes exclusively for its
  own string literals specifically so none of it needs escaping at the outer PL/SQL-string
  level — only the two variable-interpolation lines (`l_env`/`l_color` spliced via `||`)
  need the doubled-`''` treatment, kept to a minimum on purpose to reduce where a
  quote-counting mistake could hide.

## Date pickers on Page 3 + Delete Cycle as Page 6 (2026-10-01)

- **Date pickers**: switched Page 3's three date fields (period start/end, due date) from
  plain `NATIVE_TEXT_FIELD` to `NATIVE_DATE_PICKER_APEX`, APEX's standard native date picker.
  Kept the item attributes minimal (none specified, relying on the plugin's defaults) to
  reduce the chance of a wrong attribute value — first use of this item type in this file.
  The `to_date(..., 'YYYY-MM-DD')` conversions in the open-cycle process were left
  unchanged; the native date picker stores session state in that same ISO format
  internally regardless of what's displayed to the user.
- **Delete Cycle**: new `xxcti_uar_cycle_pkg.delete_cycle` procedure (hard delete of a cycle
  and all its review items, including any approval/comment history — no undo) plus Page 6,
  mirroring Page 5's exact proven single-button shape (text item, one button, one process,
  a cycles list for reference) rather than adding a second button to an existing page. Nav
  link added, and `delete-cycle` added to the Global Page's nav-hiding selector list
  alongside the other admin-only pages.

## Several user-requested changes in one batch (2026-10-01)

- **Env badge excludes PROD**: showing a badge in production is pointless noise; removed the
  PROD branch from the badge's PL/SQL entirely so `l_env` stays null there and nothing
  renders. DEV/TEST unaffected.

- **Consolidated Close/Delete Cycle onto Page 3**, removing the separate Pages 5 and 6
  entirely (including their nav items). This reopened the "multiple buttons on one page"
  risk deliberately avoided earlier — solved cleanly without any new export-API parameter:
  each process checks `:REQUEST` (the clicked button's name, which APEX sets automatically
  on submit) as a plain `IF` statement *inside its own PL/SQL body*. No process-level
  condition parameter needed at all, so zero new guessing risk. The pre-existing "Open New
  Cycle" process was retrofitted with the same `:REQUEST = 'OPEN_CYCLE'` guard, since it
  previously ran unconditionally on *any* submit of the page — fine with one button, a real
  bug with three. `xxcti_uar_cycle_pkg.delete_cycle` (hard delete, no undo) and its UI moved
  from the removed Page 6 onto this same page/pattern.

- **Resized Page 3's text/date fields to 20 characters** (cycle name, period start/end, due
  date, and the new shared cycle-id field for close/delete) — were up to 30.

- **Page 1 manager-switch now actually refreshes the employee list.** The dropdown already
  showed every manager to admins, but nothing re-queried the IG when the selection changed —
  a real gap, not just a missing confirmation. Added the Dynamic Action the original app 104
  had for exactly this (`New`/`change` event on `P1_MANAGER` → `NATIVE_SUBMIT_PAGE` →
  `NATIVE_REFRESH` on the employees region), copied with full confirmed precedent straight
  from that file, not guessed. No condition params used on the DA event, per the existing
  gotcha about those.

- **New Page 7 (Admin Users)**: add/remove rows in `xxcti_uar_admins` from the app instead of
  only via direct SQL. Same shared-item + `:REQUEST`-guarded-processes pattern as Page 3's
  close/delete. Add is idempotent (duplicate email is silently ignored via
  `dup_val_on_index`); Remove explicitly blocks removing your own logged-in email
  (`sys_context('APEX$SESSION','APP_USER')`) to prevent a self-lockout with no other admin
  able to undo it. Nav link and Global Page nav-hiding entry added alongside the other admin
  pages.

Every PL/SQL block touched in this batch was mechanically quote-counted (even count per
line) before committing, consistent with the discipline established after the `\"`
escaping mistake earlier.

## Page 3 field width — actual root cause, found in PMO Hub's real file (2026-10-01)

The `:t-Form-fieldContainer--small` guess (previous section) didn't fix it. User asked to
check how PMO Hub actually handles field width — reading `04_pmo_hub_apex.sql` directly
(not guessing) showed the real cause: PMO Hub's multi-field forms (e.g. its "Project
Request" region) use `p_plug_template=>0` (the plain default region template), not the
Hero template. This app's "Open New Cycle", "Close or Delete a Cycle", and "Add or Remove
Admin" regions were all built on the Hero template (`2674017834225413037`) — which is
specifically designed to stretch/bold its contents, so no item-level attribute could have
fixed it; the width was coming from the region template itself. The original app 104 only
ever used Hero for a single prominent selector (`P1_MANAGER_SELECTION`) and a title-display
region (`P2_EMPLOYEE_REVIEW`) — both left as Hero here, unaffected — never for a multi-field
form, which is the case that was actually broken.

Reverted the `--small` guess back to plain `'#DEFAULT#'` on the 5 items, and changed the
three multi-field form regions' `p_plug_template` from `2674017834225413037` to `0`,
dropping the now-irrelevant `t-HeroRegion--noPadding` region template option alongside it.
This is a confirmed fix pulled from a real working file, not an inference this time.

## Constraint driving the Import-wizard requirement

SQL Scripts works reliably for testing but has a file-size ceiling — PMO Hub's export is a
real example of a file too large for it. As this app grows through later stages (pages 3–4,
any static files/icons added back), it will likely exceed that ceiling too, at which point
App Builder → Import becomes the only viable way to install it. Getting Import to accept
this file isn't just today's problem — it has to keep working as the file grows.

## P1 manager dropdown JS crash — root cause found via live browser debugging (2026-10-05)

Opening the P1_MANAGER search-select dropdown threw `Uncaught Error: Invalid choice object,
r property missing` from `desktop_all.min.js`'s `searchChoices`. Ruled out by direct testing
before guessing further: null/blank LOV rows (none), duplicate `manager_id` with differing
name text from the admin-visible-managers GROUP BY (none), and the newly added Dynamic
Action (error fires on dropdown *open*, before any `change` event could reach the DA's
listener).

Traced live in Chrome DevTools (pause-on-exceptions breakpoint at the actual throw site,
then read the real minified source around it):

```js
if (!h.r)
    throw new Error("Invalid choice object, r property missing");
```

`h.r` is checked for truthiness, not just presence. The item's `min_chars=>'0'` attribute
makes the search-select run a search immediately on open, with an empty term — and that
search path chokes on APEX's auto-inserted "- Select -" null/placeholder choice, whose
`r` value is legitimately `''` (empty string, hence falsy). This is a widget behavior gap,
not a data problem in the LOV query.

Fix: added `p_lov_display_null=>'NO'` to P1_MANAGER's `create_page_item` call, suppressing
the placeholder entry entirely — functionally harmless since the page's "Initialize Page
Defaults" process already auto-resolves `P1_MANAGER` when null. Confirmed `'YES'`/`'NO'`
(string) is the correct form for this parameter on `create_page_item` via PMO Hub precedent
(`04_pmo_hub_apex.sql:4765`); a `true` (boolean) precedent exists elsewhere in this file but
only on `create_region_column`, a different API, so it wasn't valid precedent here.

Methodology note: this is the first bug in this project resolved by debugging live in the
browser (DevTools pause-on-exceptions + reading the real un-minified-equivalent source
around the throw) rather than by inferring from SQL/export data alone — worth defaulting to
earlier next time a thrown JS error names a specific library function.

## P1 manager dropdown crash — correction: the null-entry fix was insufficient, real cause is scale (2026-10-05)

The `p_lov_display_null=>'NO'` fix (previous entry) did not resolve the crash on reimport/retest.
Stopped guessing further and instead did a structural comparison across all three available
apps (`f104.sql` — the original, still-working UAR app; `PMO_Hub/04_pmo_hub_apex.sql`; and
this rebuild), rather than more live-debugging iterations:

- PMO Hub has no search-select item anywhere (no `min_chars` attribute at all) and no
  Interactive Grid regions — not a useful comparable for this widget.
- `f104.sql` has the **exact same** P1_MANAGER item (same attributes, same field template,
  same item template options) coexisting with an Interactive Grid named `P1_EMPLOYEES` on
  the same page (`f104.sql:1281`) — proving IG-coexistence and this item's attribute set
  are not inherently broken. Ruled out as a cause.
- The one real structural difference: `f104.sql`'s LOV read from a small, purpose-built
  `apps.xxcti_uar_managers` table (dropped in this rebuild per `01_uar_schema_ddl.sql`'s own
  design note, in favor of deriving managers via `GROUP BY` over the per-employee table).
  That was fine at the scale of "one manager's own row," but the "admins see all managers"
  feature widened it to 343 rows company-wide — a scale F104 never exercised. Every test so
  far had been run as an admin (added to `xxcti_uar_admins` earlier in the build), so the
  small-list path was never actually exercised either.

Combined with the earlier live-debugged finding that the throw happens inside a search
triggered immediately on open (because `min_chars=>'0'` searches with an empty term right
away): `fetch_on_search=>'N'` + `min_chars=>'0'` is the correct, proven configuration for a
small, fully client-side list (matching the original's small dedicated table) — it is the
wrong mode now that the list can be 343 rows. APEX's search-select item has a documented
server-side mode for exactly this: `fetch_on_search=>'Y'` with `min_chars` above 0, which
fetches matching choices via AJAX as the user types instead of shipping/auto-searching the
full list client-side. Changed P1_MANAGER's attributes from
`fetch_on_search=>'N', min_chars=>'0'` to `fetch_on_search=>'Y', min_chars=>'2'`. This also
makes the earlier null-entry fix moot for this symptom (the problematic eager empty-term
search no longer runs on open at all) but it's left in place since showing "- Select -" was
never meaningful given the page already auto-resolves a default.

Methodology note: comparing against the two other real, working apps (not just inferring
from this app's own data) found the actual cause in one pass, after two rounds of
live-debugging + guessing had each produced a plausible-but-insufficient fix.

## Page 3 buttons missing entirely, fields rendering blank/full-width (2026-10-05)

After the P1 dropdown fix, screenshot showed Page 3's "Open New Cycle" fields rendering as
bare full-width bars with no visible input chrome, and no buttons at all anywhere on the
page (not "too wide" this time -- missing outright).

Compared this app's `plug_template=>0` regions against every `plug_template=>0` region in
PMO Hub rather than guessing at more template/attribute tweaks. Found a consistent pattern
used for every single form region in PMO Hub, with no exceptions: the form-fields region
(`plug_template=>0`) always has `p_plug_source_type=>'NATIVE_FORM'` set, and its buttons are
never attached directly to it -- they live in a separate sibling region using
`plug_template=>2126429139436695430` (the Buttons container template) at
`p_plug_display_point=>'REGION_POSITION_03'`, with `p_button_position` values like `CREATE`/
`CANCEL`/`DELETE`, never `NEXT`.

This app had neither: `p_plug_source_type` was unset on the fields regions, and buttons were
attached directly to the same `plug_template=>0` region with `p_button_position=>'NEXT'` --
a combination with no precedent anywhere in either working app. `plug_template=>0` has no
button slot of its own, which explains the missing buttons; the missing `NATIVE_FORM` source
type explains the bare/unstyled field rendering.

Fixed on all three affected regions (P3 "Open New Cycle", P3 "Close or Delete a Cycle", and
P7 "Add or Remove Admin" -- the last wasn't yet visually tested but had the identical
anti-pattern, fixed proactively):
- Added `p_plug_source_type=>'NATIVE_FORM'` to each fields region.
- Added a new sibling "Buttons" region per form (ids 406, 457, 804), using the precedented
  template/display-point combination.
- Re-pointed each button's `p_button_plug_id` to its new Buttons region, and changed
  `p_button_position` from `NEXT` to `CREATE` (primary action) or `DELETE` (destructive
  action), matching PMO Hub's precedent exactly rather than inventing new position values.

Methodology note: this is the second bug in a row resolved by diffing against PMO Hub's
actual working pattern end-to-end instead of iterating on this app's own template/attribute
values -- see the P1 dropdown entry above and [[feedback_apex_research_before_guessing]] in
project memory. Comparison-first is now the default approach for any APEX rendering bug in
this project, not just JS crashes.

## PMO Hub review pass -- proactive UX/functional improvements (2026-10-05)

Reviewed PMO Hub's KNOWLEDGE_TRANSFER.md and `04_pmo_hub_apex.sql` end-to-end and applied
four improvements to UAR, each from proven PMO Hub precedent or pure PL/SQL (no unprecedented
export parameters -- per the standing import-400 rule). All quote-doubling verified
mechanically (whole-file odd-single-quote scan came back clean) and all new component ids
confirmed unique with correct cross-references before committing.

1. **Confirmation dialogs on destructive actions.** Delete Cycle (P3), Close Cycle (P3), and
   Remove Admin (P7) previously fired instantly on click with no guard -- Delete Cycle in
   particular permanently removes a cycle and every review item in it. Converted all three
   buttons from `p_button_action=>'SUBMIT'` to `'DEFINED_BY_DA'` with a backing
   click-event + `NATIVE_JAVASCRIPT_CODE` action running `if(confirm(...)){apex.submit(...)}`,
   exactly the pattern PMO Hub uses for all 8 of its delete buttons (KT S7.3). The
   `apex.submit("<REQUEST>")` call preserves each existing `:REQUEST`-guarded process, so no
   process logic changed.

2. **Cycle picker instead of a raw id text box (P3).** `P3_ACTION_CYCLE_ID` (used by Close
   and Delete) was a free-text field -- the admin typed a cycle id number by hand, directly
   feeding a permanent-delete. Changed it to a `NATIVE_SELECT_LIST` of cycles
   (`cycle_name (status)`, value = cycle_id, newest first) with a "- Select a cycle -" null
   prompt. The existing BEFORE_HEADER default still preselects the current open cycle.
   Removes the fat-finger-wrong-id-then-delete hazard; select-list + LOV + null-text are all
   precedented (PMO Hub P31_DEPARTMENT, and P1_MANAGER here).

3. **Friendly validation on Open New Cycle (P3).** Added null checks (name + all three dates
   required) and a period-end-not-before-start check to the Open New Cycle process, raising
   clear `-20010`/`-20011` messages instead of letting a blank submit fall through to an
   opaque `ORA-01400`/bad data. Pure PL/SQL inside the existing process body -- no new export
   param, no import risk (KT S8.5's concern was specifically about adding `p_is_required` to
   the item, which this avoids).

4. **Personalized greeting on P1.** Added a `NATIVE_PLSQL` greeting region at the top of My
   Team Review (PMO Hub KT S7.1): server-rendered "Hello, <first name>!" fallback, rewritten
   client-side to a time-of-day greeting using the browser clock, first name resolved from
   `xxcti_uar_workday_employee_mgr` by email (falls back to `:APP_USER`), name run through
   `apex_escape.html`.

Deliberately not done this pass (to avoid scope creep / over-engineering): RAG-style color
coding of completion %, progress-bar visualization on P1, and required-field flags on the
open-cycle items (the validation in #3 covers the real need without the import-400 param
risk). The README is also stale (still describes "Stage 0") -- flagged, not rewritten here.

## Correction: the dialogbtnr "Buttons" region fix was wrong -- real fix found (2026-10-05)

User reimported and reported Page 3 still missing buttons, fields still oversized -- the
previous fix (separate "Buttons" sibling region on `plug_template=>2126429139436695430` at
`REGION_POSITION_03`) did not work.

Root cause of that failure: `2126429139436695430` is this theme's own
`p_default_dialogbtnr_template` (confirmed from this file's own `create_theme` call) --
Universal Theme's **dialog/drawer button bar**, not a general-purpose button container.
Checked where PMO Hub actually uses that id: every single occurrence is on a page that sets
`p_step_template` plus a `js-dialog-class-t-Drawer--pullOutEnd` CSS option (confirmed on
Project Edit, P26) -- i.e. a modal drawer page, a fundamentally different page type from P3/P7
(plain nav-list content pages, no step template override). PMO Hub has no example of this
pattern on a regular page because **every** create/edit form in that app is a drawer (KT
S5.2) -- there was no valid precedent to copy in the first place, and the apparent match was
coincidental.

Real fix: this file's own `create_theme` call already declares
`p_default_form_template=>4072358936313175081` as the application's default form template --
the theme's own designated template for exactly this case (a region holding items + buttons
on a normal page), and the same id already renders correctly throughout this file on every
report region (`p_template=>4072358936313175081` on P1/P3/P7's report regions). Changed
P3_OPEN_NEW_CYCLE, P3_MANAGE_EXISTING_CYCLE, and P7_ADD_REMOVE_ADMIN from
`plug_template=>0` to `4072358936313175081`, dropped the unprecedented
`p_plug_source_type=>'NATIVE_FORM'` (no valid precedent for a non-automatic-DML custom-process
region either -- PMO's NATIVE_FORM regions are all automatic-DML drawer forms, a different
mechanism from this app's manual `:REQUEST`-guarded processes), removed the three stray
"Buttons" sibling regions entirely, and re-pointed every button's `p_button_plug_id` back to
its own field region (positions CREATE/DELETE left as-is -- those are generic APEX button
position constants, not specific to the dialog button bar).

Methodology note: comparing against PMO Hub found a pattern that looked right but came from
an unrelated page *type* (modal vs. regular) -- surface-level similarity in an export file
isn't the same as confirming the two pages are actually the same kind of thing. The id that
actually resolved it was sitting in this app's own `create_theme` call the whole time,
labeled for exactly this purpose.

## Page 3/7 field width -- actually narrow now, via scoped CSS (2026-10-05)

Buttons confirmed working after the template fix, but fields still spanned the full page
width. Checked whether PMO Hub's narrow "Project Edit" fields come from a reusable CSS class
(grepped for `t-Form-fieldContainer--`, `u-maxWidth`, `max-width` across the whole PMO Hub
file) -- none exists. PMO Hub's forms look narrow because they render inside a drawer (a
~400-500px sliding panel per KT S5.2), not because of any per-field width setting. P3/P7 are
plain full-width content pages, not drawers, so there's no equivalent mechanism to copy --
this app genuinely needs its own width constraint that PMO Hub never had to solve.

Used the one CSS-injection technique already proven working in this exact file (Global
Page's role-based nav-hiding, `NATIVE_PLSQL` region + `htp.p('<style>...')`) rather than
inventing a new mechanism: added a small CSS-only region at the top of Page 3 and Page 7
(sequence 5, before the form regions) capping `.t-Form-fieldContainer input`/`select` to
400px. Scoped per-page since that's where the actual `.t-Form-fieldContainer` elements are
(the report regions on the same pages don't use that class, so no risk of over-scoping).

## Open New Cycle: ORA-01843 invalid month (2026-10-05)

Opening a cycle threw `ORA-01843: An invalid month was specified` from the `to_date()` calls
added in the earlier validation pass -- `to_date(:P3_NEW_PERIOD_START, 'YYYY-MM-DD')` assumed
the NATIVE_DATE_PICKER_APEX item stores its session-state value as ISO text, which it doesn't.

Checked PMO Hub rather than guessing a different mask: its Milestone Entry page (P24) has the
identical item shape (`NATIVE_DATE_PICKER_APEX`, same template, no format attribute) and its
Save process binds `due_dt=:P24_DUE_DT`/`actual_dt=:P24_ACTUAL_DT` directly into the DML with
**no** `to_date()` wrapper at all anywhere in the app -- it relies entirely on implicit
conversion against the session's NLS date format rather than a hardcoded mask.

Fixed by dropping the explicit `'YYYY-MM-DD'` mask from all three `to_date()` calls (the two
feeding `xxcti_uar_cycle_pkg.open_cycle`'s DATE parameters, plus the period-end-before-start
comparison), leaving bare `to_date(:ITEM)` so each falls back to the session format the same
way PMO Hub's proven pattern does.

## P1 manager dropdown: admin-only, instructional text for regular users (2026-10-05)

User feedback: a regular (non-admin) user should only ever see their own direct reports --
the manager-select dropdown doesn't make sense for them (it already only returns their own
row from the LOV, so it was a dropdown with one fixed option). Only admins need it, to review
other managers' employees/troubleshoot. Requested replacing that section with instructions
for everyone else.

No region- or item-level visibility condition parameter has any precedent anywhere in this
file or PMO Hub (`p_condition_type` has zero hits in either) -- adding one blind would risk
the standing unprecedented-param import-400 gotcha. Used the two techniques already proven
working in this exact file instead:

- CSS-hide the whole "Manager Selection" Hero region for non-admins via the same `:has()`
  selector technique the Global Page's nav-hiding already uses successfully --
  `.t-HeroRegion:has(.fa-check-square-o){display:none!important}` (the icon class is unique
  to this region's own Hero wrapper; the only other place it's reused is a side-nav `<li>`,
  which doesn't carry `.t-HeroRegion` so there's no collision risk).
- A new conditional `NATIVE_PLSQL` region (`P1_MANAGER_VISIBILITY`, sequence 6, right after
  the greeting) that emits that CSS plus a plain-language instructions block, only when
  `xxcti_uar_security_pkg.is_admin = 'N'` -- same conditional-`htp.p` pattern as the
  environment badge.

The underlying `P1_MANAGER` item and its BEFORE_HEADER default (`resolve_employee_id`) are
untouched -- non-admins still get correctly scoped to their own reports via the existing
bind variable, they just never see or interact with the (redundant, for them) dropdown UI.

## P1 cycle due-date / days-remaining banner (2026-10-05)

Added a due-date and days-remaining indicator to P1, for all users (admin and non-admin
alike), showing the current open cycle's due date plus a color-coded count of days left.
Bands confirmed with the user (their original wording had an overlapping range): >50% of
the cycle's total days remaining = green, 25-50% = yellow, <25% = red; a due date already
passed always shows red as "N day(s) past due" rather than a nonsensical negative count.

"Total days" is `due_date - created_date` (the cycle's whole open-to-due window), not
`period_end - period_start` (which is the audit period being reviewed, a different date
range entirely -- using it would make the countdown math meaningless). New
`NATIVE_PLSQL` region (`P1_CYCLE_DUE_INFO`, sequence 7, right after the existing
greeting/instructions regions), same proven conditional-`htp.p` pattern as those. Renders
nothing when there's no open cycle.

Colors are PMO Hub's own documented RAG palette (`KNOWLEDGE_TRANSFER.md` S5.2: green
`#1A7C4F`, amber `#E6A817`, red `#C00000`) rather than inventing new ones -- `#E6A817`
was already in use in this app's own environment badge, so this keeps the palette
consistent across both apps.

## P2 grid: row-selector checkboxes were defined but never wired in (2026-10-05)

User reported no checkboxes on P2's editable grid, needed for the built-in multi-row bulk
edit feature. Root cause: `APEX$ROW_SELECTOR` (column id 334, `enable_multi_select=>'Y'`)
was defined via `create_region_column` back when the grid was first built, but never added
to the grid's actual visible column set via `create_ig_report_column` -- only
`APEX$ROW_ACTION` (333) got that second step. A region column that exists in metadata but
was never attached to a `create_ig_report_column` entry simply never renders -- same shape
of bug as the earlier IR-column gotcha in project memory, one layer removed (grid report
view, not a classic IR saved report).

Added the missing `create_ig_report_column` entry (id 363, `p_display_seq=>-1` so checkboxes
render leftmost of the row-action icon). With this in place, APEX's native "apply to
selected rows" cell-edit feature should now be available: select multiple rows via the new
checkboxes, edit the Approval dropdown on one of them, and APEX should prompt to apply that
value to all selected rows -- built-in Interactive Grid behavior, no custom code needed.

## P2 grid: start in edit mode, not view-then-click-Edit (2026-10-05)

Screenshot showed a separate toolbar "Edit" button the user had to click before any cell
became editable, plus confirmed the row-selector checkboxes from the previous fix still
weren't visible -- likely because Interactive Grid only shows bulk-edit row-selection
checkboxes while actually in edit mode, not in the default read-only view.

Root cause of both: `p_edit_mode=>false` on P2's grid view (set when the grid was first
built), which makes an editable IG load in read-only display mode until the user explicitly
clicks "Edit." Changed to `p_edit_mode=>true` so the grid is immediately editable on page
load -- directly addresses the "can the user just start working, does Save need an Edit step
first" question from this session, and should also surface the row-selector checkboxes if
they were conditionally hidden outside edit mode. (P1's read-only grid has the same parameter
at `p_edit_mode=>false` -- left alone, correct there since that grid is never editable.)

## Row-selector checkboxes: real root cause found via a live Page-Designer export (2026-10-05)

Dead end after dead end on this (edit_mode, ig_report_column wiring) because neither
available reference file (f104, this app's own history) had a genuinely confirmed-working
example to diff against. User added a throwaway Page 5 directly in Page Designer on the real
app, built a standard editable IG on it, confirmed its checkboxes render, and exported it
fresh (`f530.sql`) -- real, current, ground-truth precedent instead of an old export or
another guess.

Diffing that page's `APEX$ROW_SELECTOR`/`APEX$ROW_ACTION` region columns against ours found
the actual cause: both of ours carried `p_required_patch=>wwv_flow_imp.id(9700000000000060)`
-- pointing at this app's own "Commented Out" build option (status `EXCLUDE`). `p_required_patch`
is meant to reference an internal APEX patch-compatibility record, not a build option; this
was carried over from the original f104 export without ever pointing it at anything real.
The fresh Page-Designer export has **zero** occurrences of `p_required_patch` anywhere.
Whatever APEX does with an unresolvable/excluded reference there, the effect was the same as
silently skipping the column's creation -- no error, just never renders, matching the exact
symptom chased across three prior attempts.

Also confirmed from the same working export: the row selector is **never** listed in
`create_ig_report_column` even in a page that renders checkboxes correctly -- that part of
the earlier fix (adding one) was chasing the wrong lever the whole time and has been removed
again. The control-column shape is otherwise the same as `APEX$ROW_ACTION`'s: no
`p_session_state_data_type`, no `p_use_as_row_header`; instead `p_enable_hide=>true` and
`p_is_primary_key=>false`. Rewrote both `APEX$ROW_ACTION` and `APEX$ROW_SELECTOR` to match
the confirmed-working shape exactly (also added `APEX$ROW_ACTION`'s missing `p_label=>'Actions'`
/ alignment attributes, present in the real export but absent from ours).

Methodology note: when no available reference file has a genuinely confirmed-working example
of the specific thing being debugged, the fastest path is to build a minimal throwaway
example directly in Page Designer and export it fresh, rather than keep inferring from
older/adjacent exports that may not actually prove the behavior in question.

## P4 Audit History: search by user or manager name (2026-10-05)

Added a search box so an admin can find records by employee (Oracle user name) or manager
name without scrolling/paginating through the full cross-cycle history. Used the same
proven patterns already established in this file rather than introducing a new region type
(Interactive Report) with no precedent anywhere in this app: a plain `NATIVE_TEXT_FIELD`
item + `SUBMIT` button (same shape as P3/P7's forms), and the report's existing SQL source
extended with an optional `WHERE` clause matching the bind variable against either
`ri.user_name` or the joined manager's concatenated name -- `:P4_SEARCH_TEXT is null` keeps
showing everything when the box is empty, same optional-filter idiom already proven on P1's
reports (`:P1_CYCLE_ID`/`:P1_MANAGER` bind-variable filtering). `submit_when_enter_pressed`
on the item lets Enter trigger the search without requiring a Search-button click. Also
applied the now-standard scoped field-width CSS region to this page for visual consistency
with P3/P7.

## Approval change history -- preserve prior decisions, not just the latest (2026-10-05)

User raised a real gap: the existing `xxcti_uar_review_items_biu` trigger stamps
APPROVER/APPROVAL_DATE on every approval change, but only the *current* value is kept --
if a manager approves an item, saves, then later (within the same still-open cycle) changes
their mind and denies it, the fact it was ever approved, by whom, and when is silently
overwritten with zero trace. For a tool whose purpose is a defensible compliance record,
that's a real gap, not a nice-to-have.

Added `xxcti_uar_review_items_history` (`01_uar_schema_ddl.sql`): one row per prior
approval state (old approval/approver/approval_date/comments, plus who/when made the
change), keyed to `review_item_id` with a proper FK -- standard "shadow audit table"
pattern, not DML the app writes to directly. Extended the existing trigger
(`02_uar_packages.sql`) to insert the `:old` row's state into this table before applying
each approval change, using the same `WHEN` condition it already had (fires on every
approval change, including the first NULL-to-decision transition, for a complete history).
`xxcti_uar_cycle_pkg.delete_cycle` updated to purge history rows alongside review items
when a cycle is deliberately deleted, keeping the existing cleanup symmetric.

No UI changes in this pass -- the history is queryable but not yet surfaced anywhere (e.g.
a P4 drill-down). Deliberately scoped to just the backend mechanism per the user's request;
a UI view can be added separately if wanted.

## P4 Audit History: converted to a true Interactive Report, matching PMO Hub's P20 (2026-10-05)

User asked for P4 to work like PMO Hub's P20 (Projects) -- filterable/sortable columns with
per-column value selection, read-only. That's PMO Hub's `NATIVE_IR` (Interactive Report)
pattern, a region type this app had never used before (P1/P2 use `NATIVE_IG`, P3/P4/P7 used
plain `NATIVE_SQL_REPORT`). Copied PMO Hub's real, confirmed-working P20 definition exactly
rather than guessing at IR's parameter surface: `create_page_plug` with
`p_plug_source_type=>'NATIVE_IR'` on the IRR region template (`2100526641005906379`, already
used elsewhere in this app for IG regions too), followed by `create_worksheet` (implicit
context from the preceding plug, no explicit region-id parameter -- same implicit-context
convention already used by this app's own `create_report_columns` calls), one
`create_worksheet_column` per column (18 total, each needing a unique single-letter
`p_column_identifier` A-R), and `create_worksheet_rpt` as the default (`p_is_default=>'Y'`)
saved report.

Per the already-known IR gotcha (project memory: a column missing from the default saved
report's `p_report_columns` list silently doesn't render, independent of
`create_worksheet_column`), mechanically cross-checked that all 18 `p_db_column_name` values
appear in `p_report_columns` and that all 18 `p_column_identifier` letters are unique before
committing.

This also **removed** last session's custom P4_SEARCH text box/button and its WHERE-clause
bind filter -- redundant now that Interactive Report provides a built-in global search bar
(covers "find by user or manager" more completely than the custom box did) plus per-column
filter/sort/show-distinct-values out of the box, exactly matching P20's actual design (which
has no custom search box either). IR is inherently read-only unless explicitly configured
for inline editing, which this isn't -- satisfies "obviously it shouldn't be editable" with
no extra configuration needed.

## P1 employee list: converted from a read-only Interactive Grid to an Interactive Report (2026-10-09)

Per the apex-app-builder skill's guidance (read-only analysis belongs on an Interactive
Report; a read-only grid is justified only for frozen columns, cell-range copy, or as the
detail of another grid -- none of which apply here), converted P1_EMPLOYEES from
`NATIVE_IG` (`p_is_editable=>false`) to `NATIVE_IR`, matching the same `create_worksheet` /
`create_worksheet_column` / `create_worksheet_rpt` shape already proven on P4.

The original reason for choosing IG over Classic Report here (getting a working link to
Page 2, since `#COLUMN#` link-column substitution silently failed under this app's Friendly
URLs) is solved differently and more robustly this time: an Interactive Report worksheet
column has no NATIVE_LINK item type, so the link is built the way PMO Hub's P20 does it --
an `apex_page.get_url(...)` call directly in the SQL source (two items, `P2_EMPLOYEE_ID` and
`P2_CYCLE_ID`, passed as comma-delimited `p_items`/`p_values`), returned as a hidden
`EMPLOYEE_URL` column (`p_display_text_as=>'HIDDEN_ESCAPE_SC'`), referenced from the visible
`EMPLOYEE_ID` column's HTML expression (`<a href="#EMPLOYEE_URL#">#EMPLOYEE_ID#</a>`). This
`#COL#` substitution is a different, separate APEX mechanism from the link-column kind that
failed before -- proven working in PMO Hub's live app, not a retry of the earlier approach.

Dropped `EMPLOYEE_NUMBER` from the outer `SELECT` entirely -- it was already hidden and
nothing downstream on this page reads it; it's still used internally in the query's
join/filter logic. Mechanically verified before committing: all 6 `p_db_column_name` values
appear in the default report's `p_report_columns` list, all 6 `p_column_identifier` letters
are unique, and the existing "manager changed -> refresh this region" dynamic action still
targets the same region id (unchanged by the region-type swap).

**Flag for testing:** the same IR conversion pattern was used for P4 (commit `00f9d34`) and,
per the apex-app-builder skill's own verification notes, was never actually confirmed
rendering in a browser. Test both P1 and P4 together this round.

## Manager sign-off: submit, lock, and admin reopen (2026-10-09)

Per the apex-app-builder skill's review (item 5, approved by the user): a manager can now
submit their review once every item is complete, which locks their items for the rest of
the cycle; only an admin can undo that.

**Schema (`01_uar_schema_ddl.sql`):** new table `xxcti_uar_manager_signoffs`
(`cycle_id`, `manager_id`, `submitted_by`, `submitted_date`), PK on `(cycle_id, manager_id)`.
Presence of a row is the lock -- there's no separate status flag to go stale.

**Package (`02_uar_packages.sql`):** `xxcti_uar_cycle_pkg` gains `manager_signed_off`,
`can_edit_item` (combines the existing cycle-open check with the new signed-off check --
resolves the manager from the employee number itself, not a caller-supplied value),
`submit_review` (idempotent insert), and `reopen_review` (delete). `delete_cycle` now also
purges signoffs for symmetry with the history/items cleanup already there.

**Write-path enforcement:** `xxcti_uar_review_items_auth` (the trigger added for the earlier
authorization fix) now calls `can_edit_item` instead of `can_edit_cycle` directly -- the same
one function both the trigger and Page 2's load gate call, so there's one rule, not two
copies of it that could drift apart. This also means the lock applies regardless of who's
editing; an admin wanting to fix a submitted manager's items has to reopen it first, same as
anyone else -- no quiet admin bypass.

**Page 1:** a new `BEFORE_HEADER` process computes a hidden `P1_CAN_SUBMIT` flag (100%
complete, cycle open, not already submitted). A new region holds the Submit button, shown
only when that flag is set -- the exact `p_button_condition`/`ITEM_IS_NOT_NULL` idiom PMO
Hub's own status-report lock/unlock buttons already use (confirmed by grep before copying,
not assumed). The button is `DEFINED_BY_DA` with a `confirm()` guard, same shape as every
other destructive-ish action in this app. A status region above it shows "submitted on
<date>" once locked, or "complete every item" while progress is under 100%.

**Page 3:** the Manager Completion report gains Submitted/Submitted Date columns. A new
"Reopen a Manager's Submission" form lists only managers currently signed off for the open
cycle (plain `SUBMIT`, no confirm -- reopening is reversible by the manager just resubmitting,
unlike the destructive actions elsewhere on this page).

Mechanically verified before committing: every new component id is unique and every
cross-reference resolves, and quote-doubling checked whole-file across all three changed
files.

**Untested -- branch is for review before merging.**

## Six usability fixes from user review (2026-10-09)

1. **P2 back button** -- already existed (`P2_BACK_BUTTON`, confirmed working in an earlier
   test session), no change made. Flagged to the user in case it's not actually appearing,
   rather than silently skipping the request.

2. **P1 manager dropdown removed; moved to P3.** The dropdown only ever mattered for admins
   browsing another manager's team -- redundant UI for a regular user checking their own
   team. Removed the Hero region, the `P1_MANAGER` select-list item (now `NATIVE_HIDDEN`,
   still `value_protected`, same as `P1_CYCLE_ID`), and the now-dead "manager changed ->
   refresh" dynamic action. `P1_MANAGER_VISIBILITY` (the CSS-hide-the-dropdown-for-non-admins
   region) is now just `P1_INSTRUCTIONS` -- same message, shown unconditionally, since there's
   no dropdown left to hide. The `BEFORE_HEADER` default logic (non-admin always forced to
   their own manager id) is unchanged -- still the thing preventing URL tampering, just no
   longer paired with a visible control.

3. **No region just for a button.** `P1_SUBMIT_REVIEW` existed only to hold the hidden
   `P1_CAN_SUBMIT` item and the Submit button. Reviewed PMO Hub's button placement per the
   user's request: P20's "Create Project" button attaches directly to the same Interactive
   Report region it acts on (`p_button_plug_id` = the IR's own plug id), not a separate
   region. Moved the item and button onto `P1_PROGRESS` (same proven form template,
   `4072358936313175081`) and deleted the standalone region.

4 & 2 (combined). **Manager Completion converted to an Interactive Report, with the manager
   picker now living there as a link.** Rather than add a separate dropdown+button region to
   P3 (redundant with the report already listing every manager), the manager-name column is
   now a link built the same way P1's and P4's employee/row links are --
   `apex_page.get_url(p_page=>1, p_items=>'P1_MANAGER', ...)` in the SQL source, feeding a
   hidden `MANAGER_URL` worksheet column referenced from `MANAGER_NAME`'s HTML expression.
   Clicking a manager's name on P3 opens Page 1 scoped to that manager's team -- the exact
   functionality the old dropdown provided, positioned where an admin is already looking at
   each manager's completion status. The report itself gets Interactive Report's native
   sort/filter/search for free, satisfying "find a manager" directly; "find ... employee" is
   satisfied one click away, by the already-Interactive-Report employee list on P1 that
   clicking through lands on.

5. **Reopen Submission repositioned above Manager Completion** -- `p_plug_display_sequence`
   changed from 45 (after) to 35 (before, i.e. between Cycles at 30 and Manager Completion
   at 40).

6. **Friendly message for "Denied needs a comment," instead of raw ORA-02290.** No precedent
   anywhere (PMO Hub or the fresh Page Designer export) for `create_page_validation` or an
   application-level error-handling function, so neither was guessed at. Instead, extended
   the already-proven write-path trigger (`xxcti_uar_review_items_auth`, added for the
   earlier authorization fix) with the same rule the check constraint enforces, raised as a
   custom `raise_application_error` -- exactly the pattern already used there for the
   cycle-closed and not-authorized checks, which the user never found unfriendly. This
   trigger has no `WHEN` clause (fires on every update, unlike the audit-stamping trigger),
   so it also catches the edge case of editing comments to blank on an already-denied row,
   not just the common "pick Denied and save" path. The check constraint remains as a
   backstop for anything that writes to the table outside this trigger's reach.

Mechanically verified before committing: every new/changed component id resolves correctly
with no dangling references, the Manager Completion IR's `p_report_columns` list matches its
8 worksheet columns exactly, and quote-doubling checked whole-file across both changed SQL
files.

## P2 back button: wrong region id, found by diffing against the real original (2026-10-09)

Item 1 from the last batch said "already present" based on reading our own file -- the
button existed, but existing isn't the same as rendering. User reported it doesn't show.

Diffed our button against `f104.sql`'s actual button line by line rather than trusting
memory of "this was copied from the original": ours has `p_button_plug_id` pointing at
`P2_EMPLOYEE_REVIEW` (the Hero-template region) -- the real original attaches it to
`P2_RESPONSIBILITY` (the IG/IRR-template region) instead, confirmed at `f104.sql:2266`
(`p_button_plug_id=>wwv_flow_imp.id(9658844932781608)`, which is `P2_RESPONSIBILITY`'s own
id at `f104.sql:1733`, not `P2_EMPLOYEE_REVIEW`'s). Every other attribute on the button
already matched the original exactly; only the plug id was wrong, apparently copied
incorrectly when this file was first hand-authored. Fixed to point at our own
`P2_RESPONSIBILITY` plug (`9700000000000320`) instead of `P2_EMPLOYEE_REVIEW`
(`9700000000000300`).

## P2 back button: spacing fix (2026-10-09)

User reported the (now correctly-positioned, per the prior fix) back button renders too
close to the "Employee Review" title's icon above it -- likely because the Hero region's
title/icon sits directly above P2_RESPONSIBILITY (its own header hidden via
`t-IRR-region--hideHeader`), with no natural gap between them now that the button renders at
the top of that region. Added a small scoped `<style>` rule (same CSS-injection technique
used elsewhere in this app) targeting the button by its name-derived DOM id
(`#P2_BACK_BUTTON` -- APEX's standard convention: a button's id defaults to its name unless a
static id overrides it) with `margin-top:20px`. Not confirmed against the live DOM -- if the
id guess is wrong, this will just have no visible effect, not break anything.

## P2 back button spacing: correct selector, found via live DOM inspection (2026-10-09)

The `#P2_BACK_BUTTON` id guess was wrong -- confirmed via the button's actual rendered
HTML, pasted by the user: its real `id` is an internal generated value
(`B12787771470140425`) that would change on every reimport, not usable as a stable
selector. The button does carry `data-otel-label="P2_BACK_BUTTON"`, though -- an
OpenTelemetry attribute APEX stamps with the component's declared name, stable across
reimports. Switched the CSS selector to `[data-otel-label="P2_BACK_BUTTON"]`.

## P2: removed the row-selector/row-action column (2026-10-09)

Removed `APEX$ROW_SELECTOR` (the bulk-edit checkbox column, added earlier this project for
multi-row approve/deny) and `APEX$ROW_ACTION` (the per-row "..." menu) from P2's grid --
both the `create_region_column` definitions and the one `create_ig_report_column` wiring
entry that made `ROW_ACTION` visible (`ROW_SELECTOR` was never wired into the view, per the
earlier `p_required_patch` finding -- nothing to remove there beyond its own definition).
Simplifies the grid back down to just the data columns.

## P2: restored the row-selector checkbox, actions menu stays removed (2026-10-09)

Previous commit removed both system columns; user clarified only the "..." actions menu
(`APEX$ROW_ACTION`) was the unwanted clutter -- the bulk-edit checkbox column
(`APEX$ROW_SELECTOR`) should stay, given the effort to get it rendering correctly earlier
this project (the `p_required_patch` fix). Restored its `create_region_column` definition
(id `9700000000000334`, unchanged shape) -- no `create_ig_report_column` wiring needed, per
the earlier confirmed finding that this column renders from its region-column definition
alone.

## Split instructions: P1 describes P1, P2 describes P2 (2026-10-09)

P1's instructions previously described the whole workflow, including P2-only actions
(marking Approved/Denied, commenting, saving) that a manager hasn't reached yet when
they're still looking at their team list. Rewrote P1's text to describe only what's on
P1 (click an employee to open their items, submit once everything's complete), and added
a new `P2_INSTRUCTIONS` region (same `NATIVE_PLSQL` conditional-htp.p pattern used
throughout this app, sequence 20 -- between the employee-context Hero region and the
editable grid) carrying the approve/deny/comment/save instructions that actually belong
there. Quote-doubling for the one apostrophe ("employee's") mechanically verified by
collapsing both escaping layers by hand, not just checking the file-wide balance.

## Title+icon banner on every page, matching P2's "Employee Review" (2026-10-09)

P2 was the only page with the Hero-template title+icon banner at the top. P1 actually had
one too, originally, but it was removed along with the manager dropdown (they shared the
same region). Added an empty Hero-template title region (`plug_template=>2674017834225413037`,
`#DEFAULT#:t-HeroRegion--noPadding` -- the exact shape already proven on P2's
`P2_EMPLOYEE_REVIEW`) as the first region on P1, P3, P4, and P7. No body content needed --
the title/icon render from the region's own template chrome regardless of what's inside.

Icons reused from the nav list rather than picked fresh, so the page header matches its own
nav entry: P1 "My Team Review" / `fa-check-square-o`, P3 "Review Cycles" / `fa-calendar`,
P4 "Audit History" / `fa-database-lock`, P7 "Admin Users" / `fa-user-plus`.

## Spacing below each new title banner (2026-10-09)

User reported the title banners added last commit feel crowded against the content below.
The title regions are empty Hero-template plugs with no body content of their own, so CSS
can't be injected inside them directly -- used the same `:has()` selector technique already
proven on the Global Page's nav-hiding (`.t-HeroRegion:has(.fa-check-square-o)` etc.),
targeting each page's title banner by its own icon class, scoped safely because only the
title region on each page actually carries the `t-HeroRegion` wrapper class (other regions
on P7 reuse the same icon, `fa-user-plus`, but aren't Hero-templated, so the combined
selector doesn't match them). Added `margin-bottom:3em` to each. Extended the existing CSS
regions on P1 (the greeting) and P3/P7 (the field-width regions) rather than add new ones;
added one small new region on P4, which had no existing CSS injection point.

## P2: title spacing and Edit-button instruction (2026-10-10)

Added `margin-bottom:3em` below P2's title banner, same `:has()` technique and value used on
the other pages' title spacing fix -- extended the existing `P2_BACK_BUTTON_SPACING_CSS`
region rather than add a new one, targeting `.t-HeroRegion:has(.fa-list-ul)` (unique to the
title region on this page; `P2_RESPONSIBILITY` below it has no icon class to collide with).

Instructions now open with "Click Edit above the list to start editing" -- the grid loads
read-only until that toolbar button is clicked (this app's confirmed, proven-matching-the-
original behavior, not something to change), and nothing previously told the user that step
was required.

## last_logon: found the real source, wired into open_cycle (2026-10-12)

User asked why P2's "Last Used" column was always blank and pointed at
`xxcti_uar_employee_responsibilities_audit.last_logon` -- the old MVP's single mutable
audit table, which this rebuild's `03_uar_migration_legacy_audit.sql` already reads from
for the one-time historical import, but `open_cycle`'s ongoing snapshot never did. Confirmed
the real column list (matches `03`'s existing inferred names exactly) and that the table's
most recent `last_logon` is 2026-09-28 before changing anything, rather than assume.

`xxcti_uar_cycle_pkg.open_cycle` now pulls `last_logon` via a scalar `MAX()` subquery
(matching on employee_number/responsibility/application, not a join, so a duplicate match
can't multiply snapshot rows) when snapshotting a newly-opened cycle. Whether the audit
table is still actively refreshed by its external process isn't confirmed -- its freshest
date lines up with when this rebuild started, which doesn't prove either way -- so this is
best-available data, not guaranteed-current, documented as such in the README.

**Not retroactive** -- only affects cycles opened after this change. The currently-open
cycle's already-snapshotted rows stay null unless backfilled directly; gave the user a
one-time UPDATE to run for that (not added to the repo as a tracked script, since it's a
one-off data repair, not a reusable migration).

## P3: two real bugs from user testing (2026-10-12)

1. **Reopen dropdown showed a stale manager id after reopening.** The LOV itself was
   already correct (inner join to `xxcti_uar_manager_signoffs`, which no longer has a row
   for a just-reopened manager) -- what was stale was `P3_REOPEN_MANAGER_ID`'s own session
   state. A plain `SUBMIT` doesn't reset an item's value, so it kept holding the manager's
   raw id after the reopen ran, and the select-list widget fell back to showing that raw
   value as text since it no longer matched any option in the refreshed LOV. Cleared the
   item (`:P3_REOPEN_MANAGER_ID := null;`) at the end of the Reopen Submission process.

2. **"My Team Review" nav link didn't reset an admin back to their own team.** After
   viewing another manager's team (via the Manager Completion link added earlier), clicking
   the main nav link kept `P1_MANAGER` at whatever value was last set -- plain session
   state, nothing ever cleared it. Added `clear_cache=1` to the nav list item's link target
   (the classic `f?p=` 6th segment -- same underlying mechanism as `p_clear_cache` on
   `apex_page.get_url`, just via the syntax this nav list already uses), so navigating via
   the main menu always resets P1's session state and the existing `BEFORE_HEADER` default
   logic puts the admin back on their own team.

## SSO login error: wrong procedure, fixed with a minimal UAR-specific one (2026-10-12)

User set up Azure AD SSO on UAR "like PMO Hub," which worked initially (an existing valid
session/token was being reused) then failed with a generic APEX plug-in error on a fresh
login. The real exception, from the APEX error log, was decisive:
`PLS-00201: identifier 'XXCTI_PMO_SSO_POST_AUTH' must be declared` -- UAR's authentication
scheme's Post-Authentication Procedure Name field was pointed directly at PMO Hub's existing
procedure, which lives in PMO's schema and doesn't exist in UAR's.

Confirmed with the user which fix was wanted: PMO's version also gates login entirely
(rejects anyone not in `XXCTI_PMO_USERS`, a registration allow-list). UAR has no equivalent
table or gate today, and the user confirmed they don't want one added as part of this fix --
just the broken reference corrected. Added `xxcti_uar_sso_post_auth` to
`02_uar_packages.sql` as a standalone procedure (not packaged, matching PMO's own proven
shape, since APEX's config field expects a plain procedure name) that's a genuine no-op --
nothing in it can fail, since there's no check to perform. Access stays scoped exactly as it
already is for native APEX accounts, via `xxcti_uar_security_pkg`.

**Still needs a manual step in the live instance** -- running the new procedure doesn't fix
anything by itself. The authentication scheme's Post-Authentication Procedure Name field
must be changed from `XXCTI_PMO_SSO_POST_AUTH` to `XXCTI_UAR_SSO_POST_AUTH`; that setting
isn't in `04_uar_apex.sql` (UAR's authentication scheme there still shows
`NATIVE_APEX_ACCOUNTS` -- SSO was configured directly in the live instance, outside this
file, so the export doesn't yet reflect it).

## Application name: "Oracle User Access Review V2" (2026-10-12)

Changed from "Oracle User Access Review (Rebuild)" across the header comment and
`p_name` default on `create_flow`. The alias (`UAR-REBUILD`) was left as-is -- not asked
for, and changing it would change every page's URL.

## Application alias: UAR-V2 (2026-10-12)

Changed from `UAR-REBUILD` to `UAR-V2`, matching the "V2" rename. **Every page URL changes**
(e.g. `/ords/r/ct_bsg_apex/uar-rebuild/my-team-review` becomes
`/ords/r/ct_bsg_apex/uar-v2/my-team-review`) -- any bookmarked or shared link using the old
alias will need updating.

## Azure AD SSO captured into the export file (2026-10-12)

UAR's authentication scheme was set up directly in the live instance (outside this file)
in an earlier session; `04_uar_apex.sql` had never reflected it and still showed the
original placeholder `NATIVE_APEX_ACCOUNTS` scheme. User provided a real component export
of the live, working "Azure AD SSO" scheme (`f530_components.sql`) rather than have this
guessed at or copied from PMO Hub blind -- replaced the placeholder scheme with it, matching
PMO Hub's proven `NATIVE_SOCIAL`/`OPENID_CONNECT` shape exactly (same tenant, same scopes),
now pointing at `XXCTI_UAR_SSO_POST_AUTH` (confirmed already correct in the live export --
the fix from earlier this session).

**Found and dropped one real bug while diffing against PMO's own scheme:**
`p_cookie_name=>'PMO_COOKIE'` in the live export -- a leftover from copying PMO Hub's setup.
PMO's own scheme doesn't set this at all (relies on the default); two apps sharing a literal
cookie name risks session collisions for anyone with both open in the same browser. Omitted
it to match PMO's own proven pattern rather than invent a UAR-specific value.

**Confirmed from the real export:** UAR shares PMO Hub's Azure App Registration/credential
(`10878677230346892`, "Creation APEX - DEV - PMO") rather than needing its own -- both apps
live in the same workspace.

**Open risk, not yet resolved:** that credential is created by PMO Hub's own import file,
under PMO's own `p_default_id_offset`. This file now references the same raw credential id
under UAR's own (different) offset. Whether `wwv_flow_imp.id()` resolves that reference to
the correct real object across two separate hand-authored import files with different
offsets is genuinely untested -- flagged to the user, SSO login is the first thing to test
after reimporting because of this specifically. If it breaks, the likely fix is adding a
`wwv_imp_workspace.create_credential` call to this file too, matching PMO's by static id, so
APEX's import matches/updates the existing workspace object instead of creating a disconnected
one.

## App Builder Import 400: declared the shared credential in this file too (2026-10-12)

User confirmed wizard imports worked fine until the SSO scheme commit (`72f1a98`) -- matches
the risk flagged in that commit's own message exactly. The referenced credential
(`10878677230346892`, "Creation APEX - DEV - PMO") is created by PMO Hub's own import file
under PMO's own `p_default_id_offset`; this file only referenced the same raw id under UAR's
different offset, with no `create_credential` call of its own. SQL Scripts never cared (raw
PL/SQL execution doesn't validate that a credential reference resolves to a real object) --
the Import wizard apparently does, since credentials carry secrets.

Added the same `wwv_imp_workspace.create_credential` call PMO Hub's file has, matching its
`p_static_id` exactly, right before the authentication scheme that references it. APEX's
import matches workspace-level objects by static id, so this should update/reuse the
existing real credential rather than leave a dangling cross-file reference -- the same
object either way, just now declared in both apps' files instead of only PMO's.

Untested -- branch is for that test specifically (reimport via the App Builder wizard, not
SQL Scripts).

## P2 instructions: mention double-click as an alternate edit entry point (2026-10-12)

Added "(or double-click in the Approval cell)" after the Edit-button instruction, per user
request.

## P2 approval UX: Approve/Deny buttons replace the editable grid (2026-10-13)

First attempt at a friendlier approval UX was a `NATIVE_YES_NO` ("Switch") column on the
existing Interactive Grid, in place of the select-list dropdown. Built and tested on branch
`feature/approval-switch` (commit `e428287`) — rejected by the user: the switch only
rendered its real widget once a cell was clicked/focused, and the collapsed/unfocused cell
showed generic "On"/"Off" text instead of the custom `Approved`/`Denied` labels. Reverted
(`git branch -D feature/approval-switch`) without merging; no functional change from that
attempt survives on master.

Replaced instead with the design the user proposed directly: a static-looking report with
one-click "Approve" and "Deny" buttons per row, where Deny opens a page requiring a mandatory
comment before it saves. The Interactive Grid on P2 (`P2_RESPONSIBILITY`, plug id
`9700000000000320`) is now a classic/static `create_report_region` (`NATIVE_SQL_REPORT`)
instead — same plug id, so `P2_BACK_BUTTON`'s existing reference needed no change. The old
`NATIVE_IG_DML` save process (id `9700000000000370`) is removed; there's no longer a grid to
save, since each action commits immediately.

Row-level HTML (the Approve button, the Deny link, and a "Locked" span for items the manager
can no longer edit) renders via `p_plug_query_strip_html=>'N'` on the region — already
precedented 3x elsewhere in this exact file (`P1_PROGRESS`, `P3_CYCLES`, `P7_ADMINS`), this
is the classic-report region attribute ("Strip HTML") that turns off escaping so a column's
raw `<button>`/`<a>` text renders instead of showing as literal text. Confirmed before
building: whether this mechanism actually works was *not* guessed — PMO Hub's own precedent
for row-level buttons/cards is `htp.p()` output in a `NATIVE_PLSQL` region, a different
(heavier) mechanism used there because PMO's cards need custom grouping/layout beyond a
plain tabular report; it doesn't indicate strip-HTML doesn't work for a simple per-row button,
and this file's own three existing uses of the attribute confirm it's the established
in-repo pattern.

Approve is instant: a small `NATIVE_PLSQL` script region emits
`uarApproveItem(id)` (`apex.item('P2_ACTION_ITEM_ID').setValue(id); apex.submit('APPROVE_ITEM')`)
— the same `apex.item().setValue()` + `apex.submit()` shape already used by this app's
confirm-dialog DA buttons — and a new `AFTER_SUBMIT` process updates the row and commits.

Deny navigates to a new **Page 8 "Deny Item"**, since grepping PMO Hub's entire export for
`DIALOG_CLOSED`/"Dialog Closed" turned up zero matches — PMO's own "modal" forms are full
page redirects, not true AJAX dialogs, so Page 8 is built the same way: a real page, gated on
load by the same `can_review` + `can_edit_item` checks P2 itself uses, with a required
`P8_COMMENTS` textarea, a `CONFIRM_DENY` process that updates the row (`comment` +
`'Denied'`), commits, and redirects back to P2 with the employee/cycle context carried via
`apex_page.get_url`, and a `CANCEL` button that redirects back the same way without saving.
Considered and dropped PMO's drawer-style slide-in panel template
(`p_step_template`/`js-dialog-class-t-Drawer--pullOutEnd`) — that specific template id has no
precedent anywhere in this file (only one page here sets `p_step_template` at all, to a
different value), and hand-copying a template id between apps is the exact
`p_required_patch`-style mistake this project has been burned by before. Page 8 instead uses
this app's own default page template, same as every other page here.

Caught and fixed during mechanical review before commit (not during a live import attempt):
the new report region had copied `p_template` and `p_region_template_options` values from
P1's Interactive-Report-based employee list instead of from this file's own classic-report
precedent — fixed to match `P1_PROGRESS`/`P3_CYCLES`/`P7_ADMINS` exactly
(`p_template=>4072358936313175081`, `p_region_template_options=>'#DEFAULT#'`).

Known scope gap, not yet addressed: a comment can now only be added via the Deny flow —
there's no path to attach an optional comment to an already-Approved item, unlike the old
dropdown design. Flagged for the user as a possible follow-up, not fixed here.

Untested — needs a real import and manual test of: Approve (instant, no page change), Deny
(Page 8 loads, requires a comment, saves, redirects back to P2), Locked display (cycle closed
or manager already submitted shows "Locked" instead of buttons), and that `P2_BACK_BUTTON`
still renders correctly now that its parent region changed type.

**Correction (2026-10-13):** tested and the Approve/Deny markup rendered as literal escaped
text (`&lt;button...`), not real buttons. `p_plug_query_strip_html=>'N'` turned out not to be
the right mechanism — it's a `create_report_region` (classic report) attribute, and classic
reports have no per-column way to disable escaping at all (confirmed by checking
`create_report_columns`'s real parameter list in the original app 104 export and a fresh Page
Designer test export — no escape-control parameter exists there). The actual in-repo
precedent for raw per-row HTML is `p_column_html_expression` on `create_worksheet_column`,
which only exists on Interactive Report regions (`p_plug_source_type=>'NATIVE_IR'`) — already
proven working in this exact app on `P1_EMPLOYEES`'s employee-link column. Rebuilt
`P2_RESPONSIBILITY` as an IR on that same pattern: the SQL is unchanged, the `ACTIONS`
column's own `html_expression` is `'#ACTIONS#'` (a column referencing its own placeholder
bypasses the default escaping, same technique `P1_EMPLOYEES` uses with
`EMPLOYEE_URL`/`EMPLOYEE_ID`), and `p_show_toolbar=>false` on the new `create_worksheet` call
keeps the static, toolbar-free look the user asked for. Added the `create_worksheet_rpt`
default-report declaration this requires — a previously logged gotcha (new IR columns
silently don't render without one) applies here too. Still untested after this fix.

**Correction (2026-10-13, again):** import failed — `ORA-06550 ... PLS-00306: wrong number or
types of arguments in call to 'CREATE_WORKSHEET'`. Had added `p_show_toolbar`/
`p_toolbar_buttons` to the new `create_worksheet` call to hide the IR's toolbar for a static
look; those two params actually belong to `create_interactive_grid` (confirmed in the
original app 104 export) and don't exist on `create_worksheet` at all — another case of
copying a parameter with no precedent on the actual call being made. Removed both;
`create_worksheet` now matches `P1_EMPLOYEES`'s already-working signature exactly. The
toolbar will show by default until a real IR-toolbar-hiding mechanism is found and verified —
not attempted again without precedent this time.

**Correction (2026-10-13, third time):** import succeeded, but the Approve/Deny markup
still rendered as escaped text. Root cause: `p_column_html_expression` escapes the
*substituted value*, not the template's own literal text — `P1_EMPLOYEES`'s working example
(`'<a href="#EMPLOYEE_URL#">#EMPLOYEE_ID#</a>'`) never actually tested this, because
`EMPLOYEE_URL`/`EMPLOYEE_ID` are a plain URL and a number with no markup in them to escape.
My `'#ACTIONS#'` column asked APEX to substitute a value that *was itself* the full
`<button>`/`<a>` markup, computed in SQL — exactly the thing html_expression escapes to
prevent XSS from dynamic data. There is no way to turn that off.

Fixed by flipping which part is literal and which is substituted: the full button/link HTML
is now literal text inside the `p_column_html_expression` parameter itself (on the
`REVIEW_ITEM_ID` column, reusing the same "carrier column" trick `P1_EMPLOYEES` uses), and
only plain, safe values are substituted into it — `#REVIEW_ITEM_ID#` (a number),
`#DENY_URL#` (a URL; its `&` query separators become `&amp;` when escaped, which is the
*correct* encoding inside an `href` attribute anyway, not a bug), and `#LOCKED_DISPLAY#`/
`#UNLOCKED_DISPLAY#` (plain words `'inline'`/`'none'` driving a CSS `display:` toggle instead
of trying to conditionally swap HTML — plain alphanumeric text passes through escaping
unchanged either way, so this sidesteps the whole problem instead of fighting it). Three new
hidden (`HIDDEN_ESCAPE_SC`) helper columns carry `DENY_URL`/`LOCKED_DISPLAY`/
`UNLOCKED_DISPLAY`; the SQL source now returns only plain values, no HTML. Still untested
after this fix.

**Follow-up fixes after live testing (2026-10-13):** markup now rendered correctly; four
issues reported from the live page:
- Clicking Approve threw "Session state protection violation" on `P2_ACTION_ITEM_ID`.
  Removed `value_protected=>'Y'` from that item — it's intentionally overwritten by
  `uarApproveItem()`'s own JS before submit, and session state protection exists to catch
  exactly that kind of client-side change, so the two are fundamentally incompatible for an
  item used this way.
- Approve/Deny colors: `t-Button--hot`/`t-Button--warning` replaced with the standard
  Universal Theme semantic classes `t-Button--success` (green) and `t-Button--danger` (red,
  already precedented in PMO Hub's own "Remove" button).
- Button column too wide: changed the carrier column (`REVIEW_ITEM_ID`) from
  `NUMBER`/`RIGHT`-aligned to plain `STRING` with no alignment override, and added
  `white-space:nowrap` to the html_expression's own wrapper spans, so the column shrinks to
  its actual content width instead of reserving numeric-column space.
- P8 fields stretching to full page width: added a small `NATIVE_PLSQL` region emitting a
  `<style>` block that caps `#P8_RESPONSIBILITY_DISPLAY`/`#P8_APPLICATION_DISPLAY`/
  `#P8_COMMENTS` at `max-width:50ch` — using the page item's own name as its DOM id, which is
  always true in APEX, rather than guessing another internal sizing parameter after getting
  burned twice already in this same feature by parameters that didn't exist on the call
  being made.

Still untested after these four fixes.

**Follow-up (2026-10-13, continued):** two of the four weren't actually fixed.
- Session state protection still fired on Approve. Every `value_protected` usage in both this
  app's and PMO Hub's export files sets it explicitly to `'Y'` or `'N'` — none omit the
  attribute. Dropping it entirely (the previous fix) apparently doesn't reliably default to
  unprotected. Set it explicitly to `'N'` on `P2_ACTION_ITEM_ID` instead of omitting it.
- P8's `max-width:50ch` on the three individual fields didn't shrink the page — the fields'
  *containers* were still full-width, and the region holding the Confirm Deny button isn't
  tied to any one item's CSS at all. Replaced the per-field rule with
  `.t-Region:has(#P8_COMMENTS){max-width:50ch;}` — `.t-Region` is Universal Theme's standard,
  stable region wrapper class, and `:has()` lets the single known item id (`#P8_COMMENTS`,
  reliable since an item's name is always its DOM id in APEX) select its *ancestor* region
  without needing to guess a region-level id or any new PL/SQL parameter. Narrowing the
  region narrows everything inside it, fields and buttons alike, in one rule.

Still untested after this round.

## P2: clear stale denial comment on re-approval, update instructions (2026-10-13)

If an item was Denied (with a comment) and the manager then clicks Approve on it, the
"Approve Item" process now also sets `comments = null` — otherwise the old denial rationale
would stick around on an approved item, which reads as leftover/contradictory. Allowed by
the `xxcti_uar_review_items_auth` trigger's comment rule, which only requires a non-null
comment when `approval = 'Denied'`.

Also rewrote `P2_INSTRUCTIONS` to describe the current button-based flow (Approve/Deny per
row, Deny opening a form requiring a comment) — the old text still referenced the removed
Interactive Grid's "Click Edit" / "double-click in the Approval cell" workflow and the
select-list dropdown, both gone since this feature replaced them.

## P1: due-date label and a graphical progress bar (2026-10-13)

"Current review cycle due:" renamed to "Complete Review By:" per user request.

Replaced `P1_PROGRESS`'s three-column classic report (Total Items / Completed / % Complete)
with a single red-to-green progress bar. Given the escaping problems worked through earlier
today on P2, this was built directly as a `NATIVE_PLSQL` region using `htp.p()` output (the
same, already-proven technique as `P1_INSTRUCTIONS`/`P1_CYCLE_DUE_INFO` on this same page),
not another report-region HTML-escaping workaround. The bar's fill color is computed as
`hsl(pct_complete * 1.2, 70%, 45%)` — a continuous hue sweep from red (0%) to green (100%)
rather than discrete buckets, since the user asked for color that changes "as progress
increases." Kept the same plug id (`9700000000000270`) since `P1_CAN_SUBMIT` and the
`SUBMIT_REVIEW` button are both parented to this region and needed no changes themselves.

## P2: show which employee is being reviewed, instructions point back to P1 (2026-10-13)

P2 had no on-page indication of which employee's access was being reviewed — just a
generic "Employee Review" title and a hidden `P2_EMPLOYEE_ID`. Added `P2_EMPLOYEE_NAME`
(hidden, populated in the existing `BEFORE_HEADER` ownership-check process via a lookup
against `xxcti_uar_workday_employee_mgr` keyed on `P2_EMPLOYEE_ID`, with a fallback to the
raw id if the lookup finds nothing) and a "Reviewing: **Name**" line at the top of
`P2_INSTRUCTIONS`, escaped via `apex_escape.html` the same way `P1_GREETING` already escapes
the logged-in user's name.

Also added a closing line to `P2_INSTRUCTIONS` telling the manager to click **Back to My
Team** (the existing button's actual label) to continue reviewing other employees and submit
once every item is complete — per user request, since the instructions previously only
covered this one employee's page and never said where to go next.

## P2: employee name as the page header, preserve scroll position (2026-10-13)

The "Reviewing: Name" line added earlier got lost inside the instructions banner, easy to
miss. Moved it to where it's actually prominent: the Hero region's own title, which was a
static "Employee Review" — now `'&P2_EMPLOYEE_NAME.''s Access Review'`, using APEX's
standard substitution-string syntax in a region title (a basic, long-standing APEX feature,
not an internal import-API parameter, so this doesn't carry the same risk as the guesses
that broke earlier imports this session). `P2_EMPLOYEE_NAME` is already populated by the
page's `BEFORE_HEADER` process, which runs before the title renders, so the value is set in
time. Removed the now-redundant line from `P2_INSTRUCTIONS`.

Also fixed: clicking Approve or Deny on a long list scrolled back to the top every time,
forcing the manager to re-find their place. Both actions cause a full page
reload/navigation (Approve submits the page; Deny navigates to Page 8 and back), which
resets scroll natively — there's no AJAX-partial-refresh precedent anywhere in this app to
reach for instead. Fixed client-side only, no new PL/SQL API surface: `uarSaveScrollPos()`
stores `window.scrollY` in `sessionStorage` before the action fires (added to both
`uarApproveItem()` and the Deny link's `onclick`), and a `window.addEventListener("load", ...)`
in the same script restores and clears it on the next page load. Known minor edge case: since
`sessionStorage` isn't scoped per employee, a stale position could in theory carry over if a
manager leaves mid-review and returns to a *different* employee's page before ever reaching a
fresh load without a pending saved position — considered minor enough not to engineer around
unless it turns out to be noticeable in practice.
