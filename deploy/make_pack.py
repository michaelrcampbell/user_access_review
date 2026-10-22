#!/usr/bin/env python
"""Assemble the generated parts of a UAR deployment pack from the repo.

    python deploy/make_pack.py <pack-folder> <from-ref>     upgrade pack
    python deploy/make_pack.py <pack-folder> FRESH          first-install pack

    pack-folder  e.g. deploy/dev-2026-10-21 (hand-written README/checklist/preflight/verify live there already)
    from-ref     the git ref that is currently live in the target environment (used for the rollback files),
                 or the word FRESH when the target has no UAR objects yet

Upgrade pack writes into the pack folder:
    02_schema_patch.sql         01b + table comments + 02, verbatim from the working tree (all re-runnable)
    03_app/04_uar_apex.sql      the application export, verbatim
    rollback/R1_..., R2_..., R3_...   previous-release packages/app, plus optional cleanup of the new objects
    MANIFEST.txt                source commit and SHA-256 of every file in the pack
FRESH pack writes:
    02_schema_install.sql       01 + 01b + 02, verbatim from the working tree (first install only)
    03_seed_first_admin.sql     template that inserts the first admin (must be edited)
    04_app/04_uar_apex.sql      the application export, verbatim
    rollback/R1_uninstall_everything.sql   guarded script that removes every UAR object (never the source feeds)
    MANIFEST.txt
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
FRESH = from_ref.upper() == "FRESH"


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
dirty = git("status", "--porcelain", "--", "01_uar_schema_ddl.sql", "01b_uar_release_hardening.sql",
            "02_uar_packages.sql", "04_uar_apex.sql").strip()
assert not dirty, "uncommitted changes in the files being packaged:\n" + dirty
BAR = "-- " + "=" * 76 + "\n"

if FRESH:
    # ------------------------------------------------------------------------- first-install pack
    install = (BAR + f"-- UAR : SCHEMA INSTALL, FIRST INSTALL ONLY (built from commit {head})\n--\n"
               "-- Run as XXUAR (SQL Workshop > SQL Scripts, or SQLcl) in a schema that has NO UAR objects yet.\n"
               "-- It is NOT safe to run twice: the original table/sequence statements refuse to repeat.\n"
               "--   PART A  original tables, sequences, indexes, base view   (01_uar_schema_ddl.sql)\n"
               "--   PART B  this release's additions                         (01b_uar_release_hardening.sql)\n"
               "--   PART C  packages, triggers, error handler                (02_uar_packages.sql)\n"
               "-- The three source tables (Workday managers, responsibilities, responsibilities audit) are NOT\n"
               "-- created here: they are feeds and must already exist (01_preflight_checks.sql checks this).\n"
               + BAR + "\n"
               + BAR + "-- PART A\n" + BAR + read("01_uar_schema_ddl.sql") + "\n"
               + BAR + "-- PART B\n" + BAR + read("01b_uar_release_hardening.sql") + "\n"
               + BAR + "-- PART C\n" + BAR + read("02_uar_packages.sql"))
    write("02_schema_install.sql", install)

    write("03_seed_first_admin.sql",
          BAR + "-- UAR : seed the FIRST ADMIN (run once, after 02_schema_install.sql)\n--\n"
          "-- 1. Replace the placeholder email below with the email you sign in with (the SSO email claim).\n"
          "-- 2. Run as XXUAR. More admins can be added later on the Admin Users page (Page 7).\n" + BAR + "\n"
          "declare\n"
          "    l_email varchar2(240) := 'CHANGE.ME@yourcompany.com';   -- <<< EDIT THIS\n"
          "begin\n"
          "    if l_email like 'CHANGE.ME%' then\n"
          "        raise_application_error(-20999, 'Edit the email address in this script first.');\n"
          "    end if;\n"
          "    insert into xxcti_uar_admins (email_address) values (lower(trim(l_email)));\n"
          "    xxcti_uar_security_pkg.log_action('ADD_ADMIN', null, lower(trim(l_email)) || ' (first admin)');\n"
          "    commit;\n"
          "exception\n"
          "    when dup_val_on_index then null;   -- already an admin\n"
          "end;\n"
          "/\n\n"
          "select email_address as admin, added_date from xxcti_uar_admins order by added_date;\n")

    write("04_app/04_uar_apex.sql", read("04_uar_apex.sql"))

    order = [("trigger", ["xxcti_uar_review_items_biu", "xxcti_uar_review_items_auth"]),
             ("package", ["xxcti_uar_cycle_pkg", "xxcti_uar_security_pkg"]),
             ("procedure", ["xxcti_uar_sso_post_auth"]),
             ("function", ["xxcti_uar_error_handler"]),
             ("view", ["xxcti_uar_unassigned_employees", "xxcti_uar_unassigned_items", "xxcti_uar_data_issues",
                       "xxcti_uar_cycle_progress", "xxcti_uar_effective_mgr", "xxcti_uar_workday_norm"]),
             ("table", ["xxcti_uar_review_items_history", "xxcti_uar_manager_signoffs", "xxcti_uar_review_items",
                        "xxcti_uar_review_cycles", "xxcti_uar_reviewer_overrides", "xxcti_uar_admin_log",
                        "xxcti_uar_admins"]),
             ("sequence", ["xxcti_uar_cycle_id_seq", "xxcti_uar_review_item_id_seq",
                           "xxcti_uar_review_items_hist_seq", "xxcti_uar_admin_log_seq"])]
    body = ""
    for kind, names in order:
        for n in names:
            suffix = " cascade constraints purge" if kind == "table" else ""
            body += f"        drop_it('drop {kind} {n}{suffix}');\n"
    write("rollback/R1_uninstall_everything.sql",
          BAR + "-- UNINSTALL: removes every UAR object the install created. DESTRUCTIVE - all cycles, decisions,\n"
          "-- history, the admin log and reviewer assignments are DELETED and cannot be recovered.\n"
          "-- It never touches the three source feeds (xxcti_uar_workday_employee_mgr,\n"
          "-- xxcti_uar_employee_responsibilities, xxcti_uar_employee_responsibilities_audit).\n"
          "-- The application itself is removed separately (see the README).\n"
          "-- To run it, change l_confirm below from 'NO' to 'YES'. Run as XXUAR.\n" + BAR + "\n"
          "set serveroutput on\n"
          "declare\n"
          "    l_confirm varchar2(3) := 'NO';   -- <<< change to 'YES' to proceed\n\n"
          "    procedure drop_it(p_sql varchar2) is\n"
          "    begin\n"
          "        execute immediate p_sql;\n"
          "    exception when others then\n"
          "        if sqlcode not in (-942, -4043, -2289, -1418, -4042, -4080) then raise; end if;\n"
          "    end;\n"
          "begin\n"
          "    if l_confirm <> 'YES' then\n"
          "        dbms_output.put_line('Nothing was removed. Set l_confirm to YES to uninstall.');\n"
          "        return;\n"
          "    end if;\n" + body +
          "    dbms_output.put_line('UAR objects removed.');\n"
          "end;\n/\n")
else:
    # ------------------------------------------------------------------------- upgrade pack
    comments = re.findall(r"comment on (?:table|column) [\w.]+ is\s*\n\s*'(?:[^']|'')*';",
                          read("01_uar_schema_ddl.sql"), re.I)
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
    write("03_app/04_uar_apex.sql", read("04_uar_apex.sql"))

    old02 = git("show", f"{from_ref}:02_uar_packages.sql").replace("\r\n", "\n")
    old01 = git("show", f"{from_ref}:01_uar_schema_ddl.sql").replace("\r\n", "\n")
    old04 = git("show", f"{from_ref}:04_uar_apex.sql").replace("\r\n", "\n")
    m = re.search(r"create or replace view xxcti_uar_cycle_progress as.*?;\n", old01, re.S)
    assert m, "old progress view not found"
    write("rollback/R1_restore_previous_packages.sql",
          BAR + "-- ROLLBACK 1 of 3: restore the PREVIOUS release's packages, triggers and progress view\n"
          f"-- (as of {from_ref}). Run as XXUAR. The new tables/views stay in place (harmless) -- see R3.\n"
          "-- Re-import the previous application too (R2), or the new app will call packages that no longer exist.\n"
          + BAR + "\n-- previous progress view\n" + m.group(0) + "\n" + old02)
    write("rollback/R2_previous_app_04_uar_apex.sql",
          "-- ROLLBACK 2 of 3: previous release's application export (as of " + from_ref + ").\n"
          "-- Import exactly like the new one. If you took the Step 0 backup export of DEV, prefer that file.\n" + old04)
    write("rollback/R3_optional_remove_new_objects.sql",
          BAR + "-- ROLLBACK 3 of 3 (OPTIONAL): remove what this release added to the schema.\n"
          "-- Only after R1 and R2. WARNING: xxcti_uar_admin_log and xxcti_uar_reviewer_overrides hold real\n"
          "-- history (admin actions, reviewer assignments) that is lost when dropped. Normally leave them.\n"
          + BAR + "\n"
          + "".join(
              "begin execute immediate '%s'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;\n/\n" % stmt
              for stmt in [
                  "drop view xxcti_uar_unassigned_employees",
                  "drop view xxcti_uar_unassigned_items",
                  "drop view xxcti_uar_data_issues",
                  "drop view xxcti_uar_effective_mgr",
                  "drop view xxcti_uar_workday_norm",
                  "drop function xxcti_uar_error_handler",
                  "drop index xxcti_uar_cycles_one_open_ux",
                  "drop index xxcti_uar_cycles_name_ux",
                  "alter table xxcti_uar_review_cycles drop constraint xxcti_uar_review_cycles_dates_ck",
                  "drop table xxcti_uar_reviewer_overrides purge",
                  "drop table xxcti_uar_admin_log purge",
                  "drop sequence xxcti_uar_admin_log_seq",
              ]))

# ----------------------------------------------------------------------------- manifest
lines = ["UAR deployment pack", f"built from commit : {head} ({git('log', '-1', '--format=%s').strip()})",
         "previous release  : " + ("none - FIRST INSTALL" if FRESH else
                                   f"{from_ref} ({git('log', '-1', '--format=%s', from_ref).strip()})"), "",
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
print("pack assembled in", pack, "from commit", head, "(first install)" if FRESH else "")
