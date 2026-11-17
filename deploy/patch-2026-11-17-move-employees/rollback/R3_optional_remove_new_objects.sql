-- ============================================================================
-- ROLLBACK 3 of 3 (OPTIONAL): remove what this patch added (the previous release's objects stay).
-- Only after R1 and R2. Dropping tables loses their history (admin log, reviewer assignments); normally leave them.
-- ============================================================================

begin execute immediate 'drop view xxcti_uar_employee_reviewers'; exception when others then if sqlcode not in (-942, -1418, -4043, -2443, -1434) then raise; end if; end;
/
