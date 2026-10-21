-- ============================================================================
-- ROLLBACK 3 of 3 (OPTIONAL): remove what this release added to the schema.
-- Only after R1 and R2. WARNING: xxcti_uar_admin_log and xxcti_uar_reviewer_overrides hold real
-- history (admin actions, reviewer assignments) that is lost when dropped. Normally leave them.
-- ============================================================================

begin execute immediate 'drop view xxcti_uar_unassigned_employees'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
begin execute immediate 'drop view xxcti_uar_unassigned_items'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
begin execute immediate 'drop view xxcti_uar_data_issues'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
begin execute immediate 'drop view xxcti_uar_effective_mgr'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
begin execute immediate 'drop function xxcti_uar_error_handler'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
begin execute immediate 'drop index xxcti_uar_cycles_one_open_ux'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
begin execute immediate 'drop index xxcti_uar_cycles_name_ux'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
begin execute immediate 'alter table xxcti_uar_review_cycles drop constraint xxcti_uar_review_cycles_dates_ck'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
begin execute immediate 'drop table xxcti_uar_reviewer_overrides purge'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
begin execute immediate 'drop table xxcti_uar_admin_log purge'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
begin execute immediate 'drop sequence xxcti_uar_admin_log_seq'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
