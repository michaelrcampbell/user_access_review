#!/usr/bin/env python
"""Assemble the generated parts of a UAR deployment pack from the repo.

    python deploy/make_pack.py <pack-folder> <from-ref>

    pack-folder  e.g. deploy/dev-2026-10-21 (hand-written README/checklist/preflight/verify live there already)
    from-ref     the git ref that is currently live in the target environment (used for the rollback files)

Writes into the pack folder:
    02_schema_patch.sql         01b + table comments + 02, verbatim from the working tree (all re-runnable)
    03_app/04_uar_apex.sql      the application export, verbatim
    rollback/R1_..., R2_..., R3_...   previous-release packages/app, plus optional cleanup of the new objects
    MANIFEST.txt                source commit and SHA-256 of every file in the pack
Sandbox-only files (00_, 05_, 07_) are never included.
"""
import hashlib
import os
import re
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
pack = os.path.abspath(sys.argv[1])
from_ref = sys.argv[2]


def git(*args):
    return subprocess.run(["git", "-C", REPO, *args], capture_output=True, text=True, check=True).stdout


def read(name):
    with open(os.path.join(REPO, name), encoding="utf-8", newline="") as f:
        return f.read().replace("\r\n", "\n")


def write(rel, text):
    path = os.path.join(pack, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(text.replace("\n", "\r\n") if rel.endswith((".sql", ".md", ".txt")) else text)


head = git("rev-parse", "--short", "HEAD").strip()
dirty = git("status", "--porcelain", "--", "01b_uar_release_hardening.sql", "02_uar_packages.sql", "04_uar_apex.sql").strip()
assert not dirty, "uncommitted changes in the files being packaged:\n" + dirty
BAR = "-- " + "=" * 76 + "\n"

# ----------------------------------------------------------------------------- schema patch
# table comments: the five from 01_uar_schema_ddl.sql (the original 01 could not create them)
comments = re.findall(r"comment on (?:table|column) [\w.]+ is\s*\n\s*'(?:[^']|'')*';", read("01_uar_schema_ddl.sql"), re.I)
assert len(comments) == 5, len(comments)
patch = (BAR + f"-- UAR release -> DEV : SCHEMA PATCH (built from commit {head})\n--\n"
         "-- Run as XXUAR (SQL Workshop > SQL Scripts, or SQLcl). Safe to run more than once.\n"
         "--   PART A  new tables, views, indexes and constraints (01b_uar_release_hardening.sql)\n"
         "--   PART B  table comments that the original install never managed to create\n"
         "--   PART C  packages, triggers, error handler (02_uar_packages.sql)\n"
         "-- Part A stops with a plain message if existing cycle data would break a new rule;\n"
         "-- run 01_preflight_checks.sql first so you already know.\n" + BAR + "\n"
         + BAR + "-- PART A\n" + BAR + read("01b_uar_release_hardening.sql") + "\n"
         + BAR + "-- PART B\n" + BAR + "\n".join(comments) + "\n\n"
         + BAR + "-- PART C\n" + BAR + read("02_uar_packages.sql"))
write("02_schema_patch.sql", patch)

# ----------------------------------------------------------------------------- application
write("03_app/04_uar_apex.sql", read("04_uar_apex.sql"))

# ----------------------------------------------------------------------------- rollback
old02 = git("show", f"{from_ref}:02_uar_packages.sql").replace("\r\n", "\n")
old01 = git("show", f"{from_ref}:01_uar_schema_ddl.sql").replace("\r\n", "\n")
old04 = git("show", f"{from_ref}:04_uar_apex.sql").replace("\r\n", "\n")
m = re.search(r"create or replace view xxcti_uar_cycle_progress as.*?;\n", old01, re.S)
assert m, "old progress view not found"
write("rollback/R1_restore_previous_packages.sql",
      BAR + f"-- ROLLBACK 1 of 3: restore the PREVIOUS release's packages, triggers and progress view\n"
      f"-- (as of {from_ref}). Run as XXUAR. The new tables/views stay in place (harmless) -- see R3.\n"
      "-- Re-import the previous application too (R2), or the new app will call packages that no longer exist.\n" + BAR + "\n"
      "-- previous progress view\n" + m.group(0) + "\n" + old02)
write("rollback/R2_previous_app_04_uar_apex.sql",
      "-- ROLLBACK 2 of 3: previous release's application export (as of " + from_ref + ").\n"
      "-- Import exactly like the new one. If you took the Step 0 backup export of DEV, prefer that file.\n" + old04)
write("rollback/R3_optional_remove_new_objects.sql",
      BAR + "-- ROLLBACK 3 of 3 (OPTIONAL): remove what this release added to the schema.\n"
      "-- Only after R1 and R2. WARNING: xxcti_uar_admin_log and xxcti_uar_reviewer_overrides hold real\n"
      "-- history (admin actions, reviewer assignments) that is lost when dropped. Normally leave them.\n" + BAR + "\n"
      + "".join(
          "begin execute immediate '%s'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;\n/\n" % stmt
          for stmt in [
              "drop view xxcti_uar_unassigned_employees",
              "drop view xxcti_uar_unassigned_items",
              "drop view xxcti_uar_data_issues",
              "drop view xxcti_uar_effective_mgr",
              "drop function xxcti_uar_error_handler",
              "drop index xxcti_uar_cycles_one_open_ux",
              "drop index xxcti_uar_cycles_name_ux",
              "alter table xxcti_uar_review_cycles drop constraint xxcti_uar_review_cycles_dates_ck",
              "drop table xxcti_uar_reviewer_overrides purge",
              "drop table xxcti_uar_admin_log purge",
              "drop sequence xxcti_uar_admin_log_seq",
          ]))

# ----------------------------------------------------------------------------- manifest
lines = [f"UAR deployment pack", f"built from commit : {head} ({git('log', '-1', '--format=%s').strip()})",
         f"previous release  : {from_ref} ({git('log', '-1', '--format=%s', from_ref).strip()})", "",
         "SHA-256                                                           file"]
for root, _, files in sorted(os.walk(pack)):
    for fn in sorted(files):
        if fn == "MANIFEST.txt":
            continue
        p = os.path.join(root, fn)
        with open(p, "rb") as f:
            h = hashlib.sha256(f.read()).hexdigest()
        lines.append(f"{h}  {os.path.relpath(p, pack).replace(os.sep, '/')}")
write("MANIFEST.txt", "\n".join(lines) + "\n")
print("pack assembled in", pack, "from commit", head)
