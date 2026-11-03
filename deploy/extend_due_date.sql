-- ============================================================================
-- UAR : extend the due date of the OPEN review cycle (run as XXUAR)
--
-- Edit the three values marked <<<, then run the whole block.
-- It refuses (and changes nothing) unless ALL of these are true:
--   * the cycle exists and is OPEN (a closed cycle is the audit record - never change it)
--   * the new date is LATER than the current due date and not in the past
--   * the new date falls within the cycle's period (period start .. period end)
-- It writes an entry to the admin log (Page 4 > Admin Activity) in the same transaction,
-- so the change is visible and attributable. Nothing else reads the due date except the
-- screens, which show the new date on their next refresh; managers need do nothing.
-- ============================================================================
set serveroutput on

declare
    l_cycle  number        := 1;                                  -- <<< cycle id (Page 3 > Cycles)
    l_new    date          := date '2026-11-20';                  -- <<< the new due date
    l_why    varchar2(300) := 'Extended at the request of NAME, ticket NNNN';   -- <<< who asked and why

    l_name   varchar2(120);
    l_status varchar2(10);
    l_start  date;
    l_end    date;
    l_old    date;
begin
    begin
        select cycle_name, status, period_start, period_end, due_date
          into l_name, l_status, l_start, l_end, l_old
          from xxcti_uar_review_cycles
         where cycle_id = l_cycle
           for update;
    exception
        when no_data_found then
            raise_application_error(-20001, 'Cycle ' || l_cycle || ' does not exist.');
    end;

    if l_status <> 'OPEN' then
        raise_application_error(-20002, 'Cycle ' || l_cycle || ' is ' || l_status || ', not OPEN. A closed cycle is the audit record and is not changed.');
    end if;
    if trunc(l_new) <= trunc(l_old) then
        raise_application_error(-20003, 'The new due date must be later than the current one (' || to_char(l_old, 'DD-Mon-YYYY') || ').');
    end if;
    if trunc(l_new) < trunc(sysdate) then
        raise_application_error(-20004, 'The new due date is in the past.');
    end if;
    if trunc(l_new) not between trunc(l_start) and trunc(l_end) then
        raise_application_error(-20005, 'The new due date is outside the cycle period (' ||
            to_char(l_start, 'DD-Mon-YYYY') || ' to ' || to_char(l_end, 'DD-Mon-YYYY') || ').');
    end if;

    update xxcti_uar_review_cycles
       set due_date = trunc(l_new)
     where cycle_id = l_cycle;

    xxcti_uar_security_pkg.log_action('EXTEND_DUE_DATE', l_cycle,
        'Due date of "' || l_name || '" moved from ' || to_char(l_old, 'DD-Mon-YYYY') ||
        ' to ' || to_char(l_new, 'DD-Mon-YYYY') || '. ' || l_why);

    commit;
    dbms_output.put_line('Done: "' || l_name || '" is now due ' || to_char(l_new, 'DD-Mon-YYYY') ||
                         ' (was ' || to_char(l_old, 'DD-Mon-YYYY') || ').');
end;
/
