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

## Constraint driving the Import-wizard requirement

SQL Scripts works reliably for testing but has a file-size ceiling — PMO Hub's export is a
real example of a file too large for it. As this app grows through later stages (pages 3–4,
any static files/icons added back), it will likely exceed that ceiling too, at which point
App Builder → Import becomes the only viable way to install it. Getting Import to accept
this file isn't just today's problem — it has to keep working as the file grows.
