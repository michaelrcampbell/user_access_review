-- ============================================================================
-- UAR : seed the FIRST ADMIN (run once, after 02_schema_install.sql)
--
-- 1. Replace the placeholder email below with the email you sign in with (the SSO email claim).
-- 2. Run as XXUAR. More admins can be added later on the Admin Users page (Page 7).
-- ============================================================================

declare
    l_email varchar2(240) := 'CHANGE.ME@yourcompany.com';   -- <<< EDIT THIS
begin
    if l_email like 'CHANGE.ME%' then
        raise_application_error(-20999, 'Edit the email address in this script first.');
    end if;
    insert into xxcti_uar_admins (email_address) values (lower(trim(l_email)));
    xxcti_uar_security_pkg.log_action('ADD_ADMIN', null, lower(trim(l_email)) || ' (first admin)');
    commit;
exception
    when dup_val_on_index then null;   -- already an admin
end;
/

select email_address as admin, added_date from xxcti_uar_admins order by added_date;
