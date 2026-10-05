prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>9805500296728652
,p_default_application_id=>530
,p_default_id_offset=>3087771470140045
,p_default_owner=>'XXUAR'
);
end;
/

prompt APPLICATION 530 - Oracle User Access Review (Rebuild)
--
-- Application Export:
--   Application:     530
--   Name:            Oracle User Access Review (Rebuild)
--   Date and Time:   00:00 Wednesday September 30, 2026
--   Exported By:     MICHAEL.CAMPBELL
--   Flashback:       0
--   Export Type:     Application Export
--     Pages:                      4
--       Items:                    6
--       Processes:                5
--       Regions:                  5
--       Buttons:                  2
--     Shared Components:
--       Logic:
--         Build Options:          1
--       Navigation:
--         Lists:                  2
--       Security:
--         Authentication:         1
--         Authorization:          2
--         ACL Roles:              1
--       User Interface:
--         Themes:                 1
--         Templates:
--       PWA:
--       Globalization:
--       Reports:
--       E-Mail:
--     Supporting Objects:  Included
--   Version:         24.2.0
--   Instance ID:     9805500296728652
--

prompt --application/delete_application
begin
wwv_flow_imp.remove_flow(wwv_flow.g_flow_id);
end;
/
prompt --application/create_application
begin
wwv_imp_workspace.create_flow(
 p_id=>wwv_flow.g_flow_id
,p_owner=>nvl(wwv_flow_application_install.get_schema,'XXUAR')
,p_name=>nvl(wwv_flow_application_install.get_application_name,'Oracle User Access Review (Rebuild)')
,p_alias=>nvl(wwv_flow_application_install.get_application_alias,'UAR-REBUILD')
,p_page_view_logging=>'YES'
,p_page_protection_enabled_y_n=>'Y'
,p_checksum_salt=>'7351B4D0A711040E6177B30EF96F9FF1638173D0702C1D257D3C8F7A5E4CE05E'
,p_bookmark_checksum_function=>'SH512'
,p_compatibility_mode=>'24.2'
,p_flow_language=>'en'
,p_flow_language_derived_from=>'FLOW_PRIMARY_LANGUAGE'
,p_allow_feedback_yn=>'Y'
,p_date_format=>'DS'
,p_timestamp_format=>'DS'
,p_timestamp_tz_format=>'DS'
,p_flow_image_prefix => nvl(wwv_flow_application_install.get_image_prefix,'')
,p_authentication_id=>wwv_flow_imp.id(9700000000000010)
,p_logo_type=>'T'
,p_logo_text=>'Oracle User Access Review'
,p_proxy_server=>nvl(wwv_flow_application_install.get_proxy,'')
,p_no_proxy_domains=>nvl(wwv_flow_application_install.get_no_proxy_domains,'')
,p_flow_version=>'Rebuild 0.1 (Stage 0)'
,p_flow_status=>'AVAILABLE_W_EDIT_LINK'
,p_flow_unavailable_text=>'This application is currently unavailable at this time.'
,p_exact_substitutions_only=>'Y'
,p_browser_cache=>'N'
,p_browser_frame=>'D'
,p_rejoin_existing_sessions=>'N'
,p_csv_encoding=>'Y'
,p_auto_time_zone=>'N'
,p_substitution_string_01=>'APP_NAME'
,p_substitution_value_01=>'Oracle User Access Review'
,p_file_prefix => nvl(wwv_flow_application_install.get_static_app_file_prefix,'')
,p_files_version=>1
,p_print_server_type=>'NATIVE'
,p_file_storage=>'DB'
,p_is_pwa=>'N'
);
end;
/
prompt --application/user_interfaces
begin
wwv_flow_imp_shared.create_user_interface(
 p_id=>wwv_flow_imp.id(530)
,p_theme_id=>42
,p_home_url=>'f?p=&APP_ID.:1:&APP_SESSION.::&DEBUG.:::'
,p_login_url=>'f?p=&APP_ID.:LOGIN:&APP_SESSION.::&DEBUG.:::'
,p_theme_style_by_user_pref=>false
,p_built_with_love=>false
,p_global_page_id=>0
,p_navigation_list_id=>wwv_flow_imp.id(9700000000000020)
,p_navigation_list_position=>'SIDE'
,p_navigation_list_template_id=>2467739217141810545
,p_nav_list_template_options=>'#DEFAULT#:t-TreeNav--styleA:js-navCollapsed--hidden'
,p_nav_bar_type=>'LIST'
,p_nav_bar_list_id=>wwv_flow_imp.id(9700000000000030)
,p_nav_bar_list_template_id=>2847543055748234966
,p_nav_bar_template_options=>'#DEFAULT#'
);
end;
/
prompt --application/shared_components/navigation/lists/navigation_menu
begin
wwv_flow_imp_shared.create_list(
 p_id=>wwv_flow_imp.id(9700000000000020)
,p_name=>'Navigation Menu'
,p_list_status=>'PUBLIC'
,p_version_scn=>9000000000001
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(9700000000000021)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'My Team Review'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-check-square-o'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(9700000000000022)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'Review Cycles'
,p_list_item_link_target=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-calendar'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(9700000000000023)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'Audit History'
,p_list_item_link_target=>'f?p=&APP_ID.:4:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-database-lock'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(9700000000000026)
,p_list_item_display_sequence=>40
,p_list_item_link_text=>'Admin Users'
,p_list_item_link_target=>'f?p=&APP_ID.:7:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-user-plus'
,p_list_item_current_type=>'TARGET_PAGE'
);
end;
/
prompt --application/shared_components/navigation/lists/navigation_bar
begin
wwv_flow_imp_shared.create_list(
 p_id=>wwv_flow_imp.id(9700000000000030)
,p_name=>'Navigation Bar'
,p_list_status=>'PUBLIC'
,p_version_scn=>9000000000002
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(9700000000000031)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'&APP_USER.'
,p_list_item_link_target=>'#'
,p_list_item_icon=>'fa-user'
,p_list_text_02=>'has-username'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(9700000000000032)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'---'
,p_list_item_link_target=>'separator'
,p_list_item_disp_cond_type=>'USER_IS_NOT_PUBLIC_USER'
,p_parent_list_item_id=>wwv_flow_imp.id(9700000000000031)
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(9700000000000033)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'Sign Out'
,p_list_item_link_target=>'&LOGOUT_URL.'
,p_list_item_icon=>'fa-sign-out'
,p_list_item_disp_cond_type=>'USER_IS_NOT_PUBLIC_USER'
,p_parent_list_item_id=>wwv_flow_imp.id(9700000000000031)
,p_list_item_current_type=>'TARGET_PAGE'
);
end;
/
prompt --application/shared_components/security/authorizations/administrators_only
begin
wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id(9700000000000050)
,p_name=>'Administrators Only'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return xxcti_uar_security_pkg.is_admin = ''Y'';'
,p_error_message=>'Insufficient privileges, user is not an Administrator'
,p_version_scn=>9000000000003
,p_caching=>'BY_USER_BY_PAGE_VIEW'
);
end;
/
prompt --application/shared_components/security/authorizations/administration_rights
begin
wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id(9700000000000051)
,p_name=>'Administration Rights'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'return xxcti_uar_security_pkg.is_admin = ''Y'';'
,p_error_message=>'Insufficient privileges, user is not an Administrator'
,p_version_scn=>9000000000004
,p_caching=>'BY_USER_BY_PAGE_VIEW'
);
end;
/
prompt --application/shared_components/security/app_access_control/administrator
begin
wwv_flow_imp_shared.create_acl_role(
 p_id=>wwv_flow_imp.id(9700000000000052)
,p_static_id=>'ADMINISTRATOR'
,p_name=>'Administrator'
,p_version_scn=>9000000000005
);
end;
/
prompt --application/shared_components/user_interface/themes
begin
wwv_flow_imp_shared.create_theme(
 p_id=>wwv_flow_imp.id(9700000000000040)
,p_theme_id=>42
,p_theme_name=>'Universal Theme'
,p_theme_internal_name=>'UNIVERSAL_THEME'
,p_version_identifier=>'24.2'
,p_navigation_type=>'L'
,p_nav_bar_type=>'LIST'
,p_reference_id=>4072363937200175119
,p_is_locked=>false
,p_current_theme_style_id=>2721322117358710262
,p_default_page_template=>4072355960268175073
,p_default_dialog_template=>2100407606326202693
,p_error_template=>2101157952850466385
,p_printer_friendly_template=>4072355960268175073
,p_login_template=>2101157952850466385
,p_default_button_template=>4072362960822175091
,p_default_region_template=>4072358936313175081
,p_default_chart_template=>4072358936313175081
,p_default_form_template=>4072358936313175081
,p_default_reportr_template=>4072358936313175081
,p_default_tabform_template=>4072358936313175081
,p_default_wizard_template=>4072358936313175081
,p_default_menur_template=>2531463326621247859
,p_default_listr_template=>4072358936313175081
,p_default_irr_template=>2100526641005906379
,p_default_report_template=>2538654340625403440
,p_default_label_template=>1609121967514267634
,p_default_menu_template=>4072363345357175094
,p_default_calendar_template=>4072363550766175095
,p_default_list_template=>4072361143931175087
,p_default_nav_list_template=>2526754704087354841
,p_default_top_nav_list_temp=>2526754704087354841
,p_default_side_nav_list_temp=>2467739217141810545
,p_default_nav_list_position=>'SIDE'
,p_default_dialogbtnr_template=>2126429139436695430
,p_default_dialogr_template=>4501440665235496320
,p_default_option_label=>1609121967514267634
,p_default_required_label=>1609122147107268652
,p_default_navbar_list_template=>2847543055748234966
,p_file_prefix => nvl(wwv_flow_application_install.get_static_theme_file_prefix(42),'#APEX_FILES#themes/theme_42/24.2/')
,p_files_version=>64
,p_icon_library=>'FONTAPEX'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#APEX_FILES#libraries/apex/#MIN_DIRECTORY#widget.stickyWidget#MIN#.js?v=#APEX_VERSION#',
'#THEME_FILES#js/theme42#MIN#.js?v=#APEX_VERSION#'))
,p_css_file_urls=>'#THEME_FILES#css/Core#MIN#.css?v=#APEX_VERSION#'
);
end;
/
prompt --application/shared_components/security/authentications/oracle_apex_accounts
begin
wwv_flow_imp_shared.create_authentication(
 p_id=>wwv_flow_imp.id(9700000000000010)
,p_name=>'Oracle APEX Accounts'
,p_scheme_type=>'NATIVE_APEX_ACCOUNTS'
,p_invalid_session_type=>'LOGIN'
,p_use_secure_cookie_yn=>'N'
,p_ras_mode=>0
,p_version_scn=>9000000000007
);
end;
/
prompt --application/pages/page_00000
begin
wwv_flow_imp_page.create_page(
 p_id=>0
,p_name=>'Global Page'
,p_step_title=>'Global Page'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'D'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000600)
,p_plug_name=>'Role-Based Nav Hiding'
,p_plug_display_sequence=>10
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if xxcti_uar_security_pkg.is_admin = ''N'' then',
'   htp.p(''<style>'');',
'   htp.p(''li:has(a[href*="review-cycles" i]):not(.t-Header-logo-link),'');',
'   htp.p(''li:has(a[href*="audit-history" i]):not(.t-Header-logo-link),'');',
'   htp.p(''li:has(a[href*="admin-users" i]):not(.t-Header-logo-link)'');',
'   htp.p(''{ display:none!important; }'');',
'   htp.p(''a[href*="review-cycles" i]:not(.t-Header-logo-link),'');',
'   htp.p(''a[href*="audit-history" i]:not(.t-Header-logo-link),'');',
'   htp.p(''a[href*="admin-users" i]:not(.t-Header-logo-link)'');',
'   htp.p(''{ display:none!important; }'');',
'   htp.p(''</style>'');',
'end if;'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000610)
,p_plug_name=>'Environment Badge'
,p_plug_display_sequence=>20
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'   l_env   varchar2(10);',
'   l_color varchar2(10);',
'   l_name  varchar2(100) := sys_context(''userenv'',''con_name'');',
'begin',
'   if l_name like ''%TEST%'' then',
'      l_env := ''TEST''; l_color := ''#E6A817'';',
'   elsif l_name like ''%DEV%'' then',
'      l_env := ''DEV'';  l_color := ''#2E75B6'';',
'   end if;',
'',
'   if l_env is not null then',
'      htp.p(''<script>'');',
'      htp.p(''(function(){'');',
'      htp.p(''var logo = document.querySelector(".t-Header-logo-link");'');',
'      htp.p(''if (!logo) return;'');',
'      htp.p(''var cs = window.getComputedStyle(logo);'');',
'      htp.p(''var badge = document.createElement("span");'');',
'      htp.p(''badge.textContent = "'' || l_env || ''";'');',
'      htp.p(''badge.style.marginLeft = "10px";'');',
'      htp.p(''badge.style.padding = "2px 10px";'');',
'      htp.p(''badge.style.borderRadius = "4px";'');',
'      htp.p(''badge.style.fontFamily = cs.fontFamily;'');',
'      htp.p(''badge.style.fontWeight = "bold";'');',
'      htp.p(''badge.style.fontSize = "11px";'');',
'      htp.p(''badge.style.color = "#fff";'');',
'      htp.p(''badge.style.backgroundColor = "'' || l_color || ''";'');',
'      htp.p(''badge.style.verticalAlign = "middle";'');',
'      htp.p(''badge.style.display = "inline-block";'');',
'      htp.p(''logo.parentNode.insertBefore(badge, logo.nextSibling);'');',
'      htp.p(''})();'');',
'      htp.p(''</script>'');',
'   end if;',
'end;'))
);
end;
/
prompt --application/pages/page_00001
begin
wwv_flow_imp_page.create_page(
 p_id=>1
,p_name=>'My Team Review'
,p_alias=>'MY-TEAM-REVIEW'
,p_step_title=>'Oracle User Access Review'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000230)
,p_plug_name=>'P1_GREETING'
,p_plug_template=>0
,p_plug_display_sequence=>5
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'   l_first varchar2(200);',
'begin',
'   begin',
'      select employee_legal_first_name into l_first',
'      from xxcti_uar_workday_employee_mgr',
'      where upper(email_address) = upper(:APP_USER)',
'        and rownum = 1;',
'   exception when no_data_found then',
'      l_first := :APP_USER;',
'   end;',
'   l_first := nvl(l_first, :APP_USER);',
'   htp.p(''<style>.uar-greeting{font-size:1.1rem;font-weight:600;color:#2E75B6;margin:4px 0 10px;}</style>'');',
'   htp.p(''<div id="uar-greeting" class="uar-greeting" data-name="'' || apex_escape.html(l_first) || ''">Hello, '' || apex_escape.html(l_first) || ''!</div>'');',
'   htp.p(''<script>'');',
'   htp.p(''(function(){'');',
'   htp.p(''var el=document.getElementById("uar-greeting");'');',
'   htp.p(''if(!el)return;'');',
'   htp.p(''var h=new Date().getHours();'');',
'   htp.p(''var g=h<12?"Good Morning":(h<18?"Good Afternoon":"Good Evening");'');',
'   htp.p(''el.textContent=g+", "+el.dataset.name+"!";'');',
'   htp.p(''})();'');',
'   htp.p(''</script>'');',
'end;'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000231)
,p_plug_name=>'P1_MANAGER_VISIBILITY'
,p_plug_display_sequence=>6
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if xxcti_uar_security_pkg.is_admin = ''N'' then',
'   htp.p(''<style>.t-HeroRegion:has(.fa-check-square-o){display:none!important}</style>'');',
'   htp.p(''<div class="uar-instructions" style="background:#F5F8FA;border-left:3px solid #2E75B6;padding:12px 16px;margin:0 0 16px;border-radius:0 4px 4px 0;">'');',
'   htp.p(''<strong>How to complete your review:</strong> Below is the list of employees '');',
'   htp.p(''currently assigned to you. For each access item, review the responsibility and '');',
'   htp.p(''application listed, then mark it <strong>Approved</strong> or <strong>Denied</strong>. '');',
'   htp.p(''Add a comment if you deny an item or need to explain your decision, then save your '');',
'   htp.p(''changes before the due date for this review cycle.'');',
'   htp.p(''</div>'');',
'end if;'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000232)
,p_plug_name=>'P1_CYCLE_DUE_INFO'
,p_plug_display_sequence=>7
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'   l_due_date    date;',
'   l_created     date;',
'   l_total_days  number;',
'   l_days_left   number;',
'   l_pct         number;',
'   l_color       varchar2(10);',
'   l_label       varchar2(100);',
'begin',
'   if :P1_CYCLE_ID is not null then',
'      begin',
'         select due_date, created_date',
'           into l_due_date, l_created',
'           from xxcti_uar_review_cycles',
'          where cycle_id = :P1_CYCLE_ID;',
'      exception when no_data_found then',
'         l_due_date := null;',
'      end;',
'',
'      if l_due_date is not null then',
'         l_total_days := greatest(trunc(l_due_date) - trunc(l_created), 1);',
'         l_days_left  := trunc(l_due_date) - trunc(sysdate);',
'         l_pct        := (l_days_left / l_total_days) * 100;',
'',
'         if l_days_left < 0 then',
'            l_color := ''#C00000'';',
'            l_label := abs(l_days_left) || '' day(s) past due'';',
'         elsif l_pct < 25 then',
'            l_color := ''#C00000'';',
'            l_label := l_days_left || '' day(s) remaining'';',
'         elsif l_pct <= 50 then',
'            l_color := ''#E6A817'';',
'            l_label := l_days_left || '' day(s) remaining'';',
'         else',
'            l_color := ''#1A7C4F'';',
'            l_label := l_days_left || '' day(s) remaining'';',
'         end if;',
'',
'         htp.p(''<div class="uar-due-banner" style="margin:0 0 16px;font-size:1rem;">'');',
'         htp.p(''Current review cycle due: <strong>'' || to_char(l_due_date,''Mon DD, YYYY'') || ''</strong>'');',
'         htp.p('' &mdash; <strong style="color:'' || l_color || '';">'' || l_label || ''</strong>'');',
'         htp.p(''</div>'');',
'      end if;',
'   end if;',
'end;'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000210)
,p_plug_name=>'P1_MANAGER_SELECTION'
,p_title=>'Manager Selection'
,p_icon_css_classes=>'fa-check-square-o'
,p_region_template_options=>'#DEFAULT#:t-HeroRegion--noPadding'
,p_plug_template=>2674017834225413037
,p_plug_display_sequence=>10
,p_location=>null
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000200)
,p_name=>'P1_MANAGER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(9700000000000210)
,p_display_as=>'NATIVE_SELECT_ONE'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select manager_first_name || '' '' || manager_last_name as manager,',
'       manager_id',
'from xxcti_uar_workday_employee_mgr',
'where xxcti_uar_security_pkg.is_admin = ''Y''',
'   or manager_id = xxcti_uar_security_pkg.resolve_employee_id',
'group by manager_id, manager_first_name, manager_last_name',
'order by 1'))
,p_lov_display_null=>'NO'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--large:t-Form-fieldContainer--boldDisplay'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'case_sensitive', 'N',
  'fetch_on_search', 'Y',
  'match_type', 'CONTAINS',
  'min_chars', '2')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000201)
,p_name=>'P1_CYCLE_ID'
,p_item_sequence=>20
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000220)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Initialize Page Defaults'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P1_MANAGER is null then',
'   :P1_MANAGER := xxcti_uar_security_pkg.resolve_employee_id;',
'end if;',
':P1_CYCLE_ID := xxcti_uar_cycle_pkg.current_open_cycle;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>1700000000000220
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(9700000000000270)
,p_name=>'P1_PROGRESS'
,p_title=>'Review Progress'
,p_template=>4072358936313175081
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select total_items, completed_items, pct_complete',
'from xxcti_uar_cycle_progress',
'where cycle_id = :P1_CYCLE_ID',
'  and manager_id = :P1_MANAGER'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>1
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No items to review yet for this cycle.'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000271)
,p_query_column_id=>1
,p_column_alias=>'TOTAL_ITEMS'
,p_column_display_sequence=>1
,p_column_heading=>'Total Items'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000272)
,p_query_column_id=>2
,p_column_alias=>'COMPLETED_ITEMS'
,p_column_display_sequence=>2
,p_column_heading=>'Completed'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000273)
,p_query_column_id=>3
,p_column_alias=>'PCT_COMPLETE'
,p_column_display_sequence=>3
,p_column_heading=>'% Complete'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000240)
,p_plug_name=>'P1_EMPLOYEES'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'with completeness as (',
'    select employee_number,',
'           case when sum(case when approval is null then 1 else 0 end) = 0',
'                then ''Yes'' else ''No'' end as review_complete',
'    from xxcti_uar_review_items',
'    where cycle_id = :P1_CYCLE_ID',
'    group by employee_number',
')',
'select distinct',
'    uwe.employee_id,',
'    uwe.employee_legal_first_name,',
'    uwe.employee_legal_last_name,',
'    ri.employee_number,',
'    ri.user_name,',
'    comp.review_complete',
'from xxcti_uar_workday_employee_mgr uwe',
'join xxcti_uar_review_items ri',
'  on to_char(uwe.employee_id) = ri.employee_number',
'left join completeness comp',
'  on ri.employee_number = comp.employee_number',
'where uwe.manager_id = :P1_MANAGER',
'  and ri.cycle_id = :P1_CYCLE_ID'))
,p_plug_source_type=>'NATIVE_IG'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000241)
,p_name=>'REVIEW_COMPLETE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'REVIEW_COMPLETE'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Review Complete'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>70
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>3
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'DISTINCT'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000242)
,p_name=>'EMPLOYEE_ID'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'EMPLOYEE_ID'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_LINK'
,p_heading=>'Employee ID'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>10
,p_value_alignment=>'LEFT'
,p_link_target=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.::P2_EMPLOYEE_ID,P2_CYCLE_ID:&EMPLOYEE_ID.,&P1_CYCLE_ID.'
,p_link_text=>'&EMPLOYEE_ID.'
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'DISTINCT'
,p_static_id=>'P1_EMPLOYEE_ID'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_escape_on_http_output=>true
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000243)
,p_name=>'EMPLOYEE_LEGAL_FIRST_NAME'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'EMPLOYEE_LEGAL_FIRST_NAME'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'First Name'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>20
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>50
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'DISTINCT'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000244)
,p_name=>'EMPLOYEE_LEGAL_LAST_NAME'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'EMPLOYEE_LEGAL_LAST_NAME'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Last Name'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>30
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>50
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'DISTINCT'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000245)
,p_name=>'EMPLOYEE_NUMBER'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'EMPLOYEE_NUMBER'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_filter_is_required=>false
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000246)
,p_name=>'USER_NAME'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'USER_NAME'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXTAREA'
,p_heading=>'Oracle User Name'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>50
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>4000
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_lov_type=>'NONE'
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(9700000000000247)
,p_internal_uid=>1700000000000247
,p_is_editable=>false
,p_lazy_loading=>false
,p_requires_filter=>false
,p_select_first_row=>true
,p_fixed_row_height=>true
,p_pagination_type=>'SCROLL'
,p_show_total_row_count=>true
,p_show_toolbar=>false
,p_toolbar_buttons=>null
,p_enable_save_public_report=>false
,p_enable_subscriptions=>true
,p_enable_flashback=>true
,p_define_chart_view=>true
,p_enable_download=>true
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>true
,p_fixed_header=>'PAGE'
,p_show_icon_view=>false
,p_show_detail_view=>false
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(9700000000000248)
,p_interactive_grid_id=>wwv_flow_imp.id(9700000000000247)
,p_static_id=>'20002'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(9700000000000249)
,p_report_id=>wwv_flow_imp.id(9700000000000248)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000250)
,p_view_id=>wwv_flow_imp.id(9700000000000249)
,p_display_seq=>10
,p_column_id=>wwv_flow_imp.id(9700000000000241)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000251)
,p_view_id=>wwv_flow_imp.id(9700000000000249)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(9700000000000242)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000252)
,p_view_id=>wwv_flow_imp.id(9700000000000249)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(9700000000000243)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000253)
,p_view_id=>wwv_flow_imp.id(9700000000000249)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(9700000000000244)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000254)
,p_view_id=>wwv_flow_imp.id(9700000000000249)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(9700000000000245)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000255)
,p_view_id=>wwv_flow_imp.id(9700000000000249)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(9700000000000246)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(9700000000000280)
,p_name=>'New'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P1_MANAGER'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(9700000000000281)
,p_event_id=>wwv_flow_imp.id(9700000000000280)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_SUBMIT_PAGE'
,p_attribute_02=>'N'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(9700000000000282)
,p_event_id=>wwv_flow_imp.id(9700000000000280)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(9700000000000240)
,p_attribute_01=>'N'
);
end;
/
prompt --application/shared_components/logic/build_options
begin
wwv_flow_imp_shared.create_build_option(
 p_id=>wwv_flow_imp.id(9700000000000060)
,p_build_option_name=>'Commented Out'
,p_build_option_status=>'EXCLUDE'
);
end;
/
prompt --application/pages/page_00002
begin
wwv_flow_imp_page.create_page(
 p_id=>2
,p_name=>'Employee Review'
,p_alias=>'EMPLOYEE-REVIEW'
,p_step_title=>'Employee Review'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000300)
,p_plug_name=>'P2_EMPLOYEE_REVIEW'
,p_title=>'Employee Review'
,p_icon_css_classes=>'fa-lg fa-list-ul'
,p_region_template_options=>'#DEFAULT#:t-HeroRegion--noPadding'
,p_plug_template=>2674017834225413037
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_query_num_rows=>15
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000301)
,p_name=>'P2_EMPLOYEE_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(9700000000000300)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000302)
,p_name=>'P2_CYCLE_ID'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(9700000000000300)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000310)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Enforce Manager Ownership and Cycle Status'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if xxcti_uar_security_pkg.can_review(:P2_EMPLOYEE_ID) = ''N'' then',
'   apex_util.redirect_url(apex_page.get_url(p_page => 1));',
'end if;',
'',
'if xxcti_uar_cycle_pkg.can_edit_cycle(:P2_CYCLE_ID) = ''N'' then',
'   apex_util.redirect_url(apex_page.get_url(p_page => 1));',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>1700000000000310
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000320)
,p_plug_name=>'P2_RESPONSIBILITY'
,p_title=>'Responsibility Review'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select *',
'from xxcti_uar_review_items',
'where employee_number = :P2_EMPLOYEE_ID',
'  and cycle_id = :P2_CYCLE_ID'))
,p_plug_source_type=>'NATIVE_IG'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000321)
,p_name=>'REVIEW_ITEM_ID'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'REVIEW_ITEM_ID'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>true
,p_duplicate_value=>true
,p_include_in_export=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000322)
,p_name=>'USER_NAME'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'USER_NAME'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXTAREA'
,p_heading=>'User Name'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>20
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>4000
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_lov_type=>'NONE'
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_readonly_condition_type=>'ALWAYS'
,p_readonly_for_each_row=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000323)
,p_name=>'EMPLOYEE_NUMBER'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'EMPLOYEE_NUMBER'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Employee Number'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>30
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>30
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'DISTINCT'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_readonly_condition_type=>'ALWAYS'
,p_readonly_for_each_row=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000324)
,p_name=>'RESPONSIBILITY'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'RESPONSIBILITY'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Responsibility'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>40
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>100
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'DISTINCT'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_readonly_condition_type=>'ALWAYS'
,p_readonly_for_each_row=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000325)
,p_name=>'APPLICATION'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'APPLICATION'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>50
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>240
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'DISTINCT'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_readonly_condition_type=>'ALWAYS'
,p_readonly_for_each_row=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000326)
,p_name=>'LAST_LOGON'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'LAST_LOGON'
,p_data_type=>'DATE'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Last Used'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>60
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_enable_filter=>true
,p_filter_is_required=>false
,p_filter_date_ranges=>'ALL'
,p_filter_lov_type=>'DISTINCT'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_readonly_condition_type=>'ALWAYS'
,p_readonly_for_each_row=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000327)
,p_name=>'START_DATE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'START_DATE'
,p_data_type=>'DATE'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>70
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000328)
,p_name=>'END_DATE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'END_DATE'
,p_data_type=>'DATE'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>80
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000329)
,p_name=>'APPROVAL'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'APPROVAL'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_SELECT_LIST'
,p_heading=>'Approval'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>90
,p_value_alignment=>'LEFT'
,p_is_required=>false
,p_lov_type=>'STATIC'
,p_lov_source=>'STATIC:Approved;Approved,Denied;Denied'
,p_lov_display_extra=>true
,p_lov_display_null=>true
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'LOV'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000330)
,p_name=>'APPROVER'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'APPROVER'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>100
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000331)
,p_name=>'APPROVAL_DATE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'APPROVAL_DATE'
,p_data_type=>'DATE'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>110
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000332)
,p_name=>'COMMENTS'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'COMMENTS'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXTAREA'
,p_heading=>'Comments'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>120
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>4000
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_lov_type=>'NONE'
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000333)
,p_name=>'APEX$ROW_ACTION'
,p_session_state_data_type=>'VARCHAR2'
,p_item_type=>'NATIVE_ROW_ACTION'
,p_display_sequence=>0
,p_use_as_row_header=>false
,p_required_patch=>wwv_flow_imp.id(9700000000000060)
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(9700000000000334)
,p_name=>'APEX$ROW_SELECTOR'
,p_session_state_data_type=>'VARCHAR2'
,p_item_type=>'NATIVE_ROW_SELECTOR'
,p_display_sequence=>5
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'enable_multi_select', 'Y',
  'hide_control', 'N',
  'show_select_all', 'Y')).to_clob
,p_use_as_row_header=>false
,p_required_patch=>wwv_flow_imp.id(9700000000000060)
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(9700000000000340)
,p_internal_uid=>1700000000000340
,p_is_editable=>true
,p_edit_operations=>'u'
,p_lost_update_check_type=>'VALUES'
,p_submit_checked_rows=>false
,p_lazy_loading=>false
,p_requires_filter=>false
,p_select_first_row=>true
,p_fixed_row_height=>true
,p_pagination_type=>'SCROLL'
,p_show_total_row_count=>true
,p_show_toolbar=>true
,p_enable_save_public_report=>false
,p_enable_subscriptions=>true
,p_enable_flashback=>true
,p_define_chart_view=>true
,p_enable_download=>true
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>true
,p_fixed_header=>'PAGE'
,p_show_icon_view=>false
,p_show_detail_view=>false
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(9700000000000341)
,p_interactive_grid_id=>wwv_flow_imp.id(9700000000000340)
,p_static_id=>'20001'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(9700000000000342)
,p_report_id=>wwv_flow_imp.id(9700000000000341)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000350)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(9700000000000321)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000351)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(9700000000000322)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000352)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(9700000000000323)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000353)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(9700000000000324)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000354)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(9700000000000325)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000355)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(9700000000000326)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000356)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>7
,p_column_id=>wwv_flow_imp.id(9700000000000327)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000357)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>8
,p_column_id=>wwv_flow_imp.id(9700000000000328)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000358)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>9
,p_column_id=>wwv_flow_imp.id(9700000000000329)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000359)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>10
,p_column_id=>wwv_flow_imp.id(9700000000000330)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000360)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>11
,p_column_id=>wwv_flow_imp.id(9700000000000331)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000361)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>12
,p_column_id=>wwv_flow_imp.id(9700000000000332)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(9700000000000362)
,p_view_id=>wwv_flow_imp.id(9700000000000342)
,p_display_seq=>0
,p_column_id=>wwv_flow_imp.id(9700000000000333)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000380)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(9700000000000300)
,p_button_name=>'P2_BACK_BUTTON'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Back to My Team'
,p_button_position=>'PREVIOUS'
,p_button_redirect_url=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:::'
,p_icon_css_classes=>'fa-lg fa-step-backward'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000370)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(9700000000000320)
,p_process_type=>'NATIVE_IG_DML'
,p_process_name=>'P2_RESPONSIBILITY - Save Interactive Grid Data'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000370
);
end;
/
prompt --application/pages/page_00003
begin
wwv_flow_imp_page.create_page(
 p_id=>3
,p_name=>'Review Cycles'
,p_alias=>'REVIEW-CYCLES'
,p_step_title=>'Review Cycles'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(9700000000000051)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000399)
,p_plug_name=>'P3_FIELD_WIDTH_CSS'
,p_plug_display_sequence=>5
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'htp.p(''<style>'');',
'htp.p(''.t-Form-fieldContainer input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]),'');',
'htp.p(''.t-Form-fieldContainer select'');',
'htp.p(''{ max-width:400px; width:400px; }'');',
'htp.p(''</style>'');'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000400)
,p_plug_name=>'P3_OPEN_NEW_CYCLE'
,p_title=>'Open New Cycle'
,p_icon_css_classes=>'fa-lg fa-calendar-plus-o'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000401)
,p_name=>'P3_NEW_CYCLE_NAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(9700000000000400)
,p_prompt=>'Cycle Name'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>120
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000402)
,p_name=>'P3_NEW_PERIOD_START'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(9700000000000400)
,p_prompt=>'Period Start'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000403)
,p_name=>'P3_NEW_PERIOD_END'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(9700000000000400)
,p_prompt=>'Period End'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000404)
,p_name=>'P3_NEW_DUE_DATE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(9700000000000400)
,p_prompt=>'Due Date'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000405)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(9700000000000400)
,p_button_name=>'OPEN_CYCLE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Open Cycle'
,p_button_position=>'CREATE'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000410)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Open New Cycle'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'   l_cycle_id number;',
'begin',
'   if :REQUEST = ''OPEN_CYCLE'' then',
'      if :P3_NEW_CYCLE_NAME is null',
'         or :P3_NEW_PERIOD_START is null',
'         or :P3_NEW_PERIOD_END is null',
'         or :P3_NEW_DUE_DATE is null then',
'         raise_application_error(-20010,',
'            ''Cycle name, period start, period end, and due date are all required.'');',
'      end if;',
'      if to_date(:P3_NEW_PERIOD_END) < to_date(:P3_NEW_PERIOD_START) then',
'         raise_application_error(-20011,',
'            ''Period end cannot be earlier than period start.'');',
'      end if;',
'      xxcti_uar_cycle_pkg.open_cycle(',
'         p_cycle_name   => :P3_NEW_CYCLE_NAME,',
'         p_period_start => to_date(:P3_NEW_PERIOD_START),',
'         p_period_end   => to_date(:P3_NEW_PERIOD_END),',
'         p_due_date     => to_date(:P3_NEW_DUE_DATE),',
'         p_cycle_id     => l_cycle_id',
'      );',
'   end if;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000410
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000450)
,p_plug_name=>'P3_MANAGE_EXISTING_CYCLE'
,p_title=>'Close or Delete a Cycle'
,p_icon_css_classes=>'fa-lg fa-cogs'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_location=>null
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000451)
,p_name=>'P3_ACTION_CYCLE_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(9700000000000450)
,p_prompt=>'Cycle'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select cycle_name || '' ('' || status || '')'' as d,',
'       cycle_id as r',
'from xxcti_uar_review_cycles',
'order by period_start desc'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Select a cycle -'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000452)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Default Current Open Cycle'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :P3_ACTION_CYCLE_ID is null then',
'   :P3_ACTION_CYCLE_ID := xxcti_uar_cycle_pkg.current_open_cycle;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>1700000000000452
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000453)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(9700000000000450)
,p_button_name=>'CLOSE_CYCLE'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Close Cycle'
,p_button_position=>'CREATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000454)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(9700000000000450)
,p_button_name=>'DELETE_CYCLE'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Delete Cycle (permanent -- no undo)'
,p_button_position=>'DELETE'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(9700000000000458)
,p_name=>'Confirm Close Cycle'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(9700000000000453)
,p_bind_type=>'bind'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(9700000000000459)
,p_event_id=>wwv_flow_imp.id(9700000000000458)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'if(confirm("Close this cycle? Managers will no longer be able to edit their reviews for it.")){apex.submit("CLOSE_CYCLE");}'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(9700000000000480)
,p_name=>'Confirm Delete Cycle'
,p_event_sequence=>20
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(9700000000000454)
,p_bind_type=>'bind'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(9700000000000481)
,p_event_id=>wwv_flow_imp.id(9700000000000480)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'if(confirm("Delete this cycle and ALL of its review items? This is permanent and cannot be undone.")){apex.submit("DELETE_CYCLE");}'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000455)
,p_process_sequence=>15
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Close Cycle'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :REQUEST = ''CLOSE_CYCLE'' then',
'   xxcti_uar_cycle_pkg.close_cycle(:P3_ACTION_CYCLE_ID);',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000455
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000456)
,p_process_sequence=>16
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Delete Cycle'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :REQUEST = ''DELETE_CYCLE'' then',
'   xxcti_uar_cycle_pkg.delete_cycle(:P3_ACTION_CYCLE_ID);',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000456
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(9700000000000420)
,p_name=>'P3_CYCLES'
,p_title=>'Cycles'
,p_template=>4072358936313175081
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--staticRowColors:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select c.cycle_id,',
'       c.cycle_name,',
'       c.period_start,',
'       c.period_end,',
'       c.due_date,',
'       c.status,',
'       c.created_date,',
'       c.closed_date,',
'       (select count(*) from xxcti_uar_review_items ri where ri.cycle_id = c.cycle_id) as total_items,',
'       (select count(*) from xxcti_uar_review_items ri where ri.cycle_id = c.cycle_id and ri.approval is not null) as completed_items',
'from xxcti_uar_review_cycles c',
'order by c.period_start desc'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No review cycles have been created yet.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_query_row_count_max=>500
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'Y'
,p_csv_output_link_text=>'Download'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000421)
,p_query_column_id=>1
,p_column_alias=>'CYCLE_ID'
,p_column_display_sequence=>1
,p_column_heading=>'Cycle Id'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000422)
,p_query_column_id=>2
,p_column_alias=>'CYCLE_NAME'
,p_column_display_sequence=>2
,p_column_heading=>'Cycle Name'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000423)
,p_query_column_id=>3
,p_column_alias=>'PERIOD_START'
,p_column_display_sequence=>3
,p_column_heading=>'Period Start'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000424)
,p_query_column_id=>4
,p_column_alias=>'PERIOD_END'
,p_column_display_sequence=>4
,p_column_heading=>'Period End'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000425)
,p_query_column_id=>5
,p_column_alias=>'DUE_DATE'
,p_column_display_sequence=>5
,p_column_heading=>'Due Date'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000426)
,p_query_column_id=>6
,p_column_alias=>'STATUS'
,p_column_display_sequence=>6
,p_column_heading=>'Status'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000427)
,p_query_column_id=>7
,p_column_alias=>'CREATED_DATE'
,p_column_display_sequence=>7
,p_column_heading=>'Created Date'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000428)
,p_query_column_id=>8
,p_column_alias=>'CLOSED_DATE'
,p_column_display_sequence=>8
,p_column_heading=>'Closed Date'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000429)
,p_query_column_id=>9
,p_column_alias=>'TOTAL_ITEMS'
,p_column_display_sequence=>9
,p_column_heading=>'Total Items'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000430)
,p_query_column_id=>10
,p_column_alias=>'COMPLETED_ITEMS'
,p_column_display_sequence=>10
,p_column_heading=>'Completed Items'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(9700000000000440)
,p_name=>'P3_MANAGER_COMPLETION'
,p_title=>'Manager Completion - Current Cycle'
,p_template=>4072358936313175081
,p_display_sequence=>40
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--staticRowColors:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select cp.manager_first_name || '' '' || cp.manager_last_name as manager_name,',
'       uwe.email_address,',
'       cp.total_items,',
'       cp.completed_items,',
'       cp.pct_complete',
'from xxcti_uar_cycle_progress cp',
'join xxcti_uar_workday_employee_mgr uwe',
'  on cp.manager_id = uwe.employee_id',
'where cp.cycle_id = xxcti_uar_cycle_pkg.current_open_cycle',
'order by cp.pct_complete'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No open cycle right now, or no managers have items assigned.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_query_row_count_max=>500
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'Y'
,p_csv_output_link_text=>'Download'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000441)
,p_query_column_id=>1
,p_column_alias=>'MANAGER_NAME'
,p_column_display_sequence=>1
,p_column_heading=>'Manager Name'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000442)
,p_query_column_id=>2
,p_column_alias=>'EMAIL_ADDRESS'
,p_column_display_sequence=>2
,p_column_heading=>'Email'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000443)
,p_query_column_id=>3
,p_column_alias=>'TOTAL_ITEMS'
,p_column_display_sequence=>3
,p_column_heading=>'Total Items'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000444)
,p_query_column_id=>4
,p_column_alias=>'COMPLETED_ITEMS'
,p_column_display_sequence=>4
,p_column_heading=>'Completed Items'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000445)
,p_query_column_id=>5
,p_column_alias=>'PCT_COMPLETE'
,p_column_display_sequence=>5
,p_column_heading=>'% Complete'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
end;
/
prompt --application/pages/page_00004
begin
wwv_flow_imp_page.create_page(
 p_id=>4
,p_name=>'Audit History'
,p_alias=>'AUDIT-HISTORY'
,p_step_title=>'Audit History'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(9700000000000051)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(9700000000000460)
,p_name=>'P4_AUDIT_HISTORY'
,p_title=>'Audit History'
,p_template=>4072358936313175081
,p_display_sequence=>10
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--staticRowColors:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select cy.cycle_name,',
'       cy.status as cycle_status,',
'       ri.review_item_id,',
'       ri.user_name,',
'       ri.employee_number,',
'       ri.responsibility,',
'       ri.application,',
'       ri.start_date,',
'       ri.end_date,',
'       ri.approval,',
'       ri.approver,',
'       ri.approval_date,',
'       ri.last_logon,',
'       ri.comments,',
'       uwem.manager_first_name,',
'       uwem.manager_last_name,',
'       uwem.manager_id,',
'       b.email_address as manager_email',
'from xxcti_uar_review_items ri',
'join xxcti_uar_review_cycles cy',
'  on ri.cycle_id = cy.cycle_id',
'join xxcti_uar_workday_employee_mgr uwem',
'  on ri.employee_number = to_char(uwem.employee_id)',
'left join xxcti_uar_workday_employee_mgr b',
'  on uwem.manager_id = b.employee_id',
'order by cy.period_start desc, ri.approval_date desc'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No audit history yet.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_query_row_count_max=>10000
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'Y'
,p_csv_output_link_text=>'Download'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000461)
,p_query_column_id=>1
,p_column_alias=>'CYCLE_NAME'
,p_column_display_sequence=>1
,p_column_heading=>'Cycle'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000462)
,p_query_column_id=>2
,p_column_alias=>'CYCLE_STATUS'
,p_column_display_sequence=>2
,p_column_heading=>'Cycle Status'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000463)
,p_query_column_id=>3
,p_column_alias=>'REVIEW_ITEM_ID'
,p_column_display_sequence=>3
,p_column_heading=>'Review Item Id'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000464)
,p_query_column_id=>4
,p_column_alias=>'USER_NAME'
,p_column_display_sequence=>4
,p_column_heading=>'User Name'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000465)
,p_query_column_id=>5
,p_column_alias=>'EMPLOYEE_NUMBER'
,p_column_display_sequence=>5
,p_column_heading=>'Employee Number'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000466)
,p_query_column_id=>6
,p_column_alias=>'RESPONSIBILITY'
,p_column_display_sequence=>6
,p_column_heading=>'Responsibility'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000467)
,p_query_column_id=>7
,p_column_alias=>'APPLICATION'
,p_column_display_sequence=>7
,p_column_heading=>'Application'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000468)
,p_query_column_id=>8
,p_column_alias=>'START_DATE'
,p_column_display_sequence=>8
,p_column_heading=>'Start Date'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000469)
,p_query_column_id=>9
,p_column_alias=>'END_DATE'
,p_column_display_sequence=>9
,p_column_heading=>'End Date'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000470)
,p_query_column_id=>10
,p_column_alias=>'APPROVAL'
,p_column_display_sequence=>10
,p_column_heading=>'Approval'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000471)
,p_query_column_id=>11
,p_column_alias=>'APPROVER'
,p_column_display_sequence=>11
,p_column_heading=>'Approver'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000472)
,p_query_column_id=>12
,p_column_alias=>'APPROVAL_DATE'
,p_column_display_sequence=>12
,p_column_heading=>'Approval Date'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000473)
,p_query_column_id=>13
,p_column_alias=>'LAST_LOGON'
,p_column_display_sequence=>13
,p_column_heading=>'Last Logon'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000474)
,p_query_column_id=>14
,p_column_alias=>'COMMENTS'
,p_column_display_sequence=>14
,p_column_heading=>'Comments'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000475)
,p_query_column_id=>15
,p_column_alias=>'MANAGER_FIRST_NAME'
,p_column_display_sequence=>15
,p_column_heading=>'Manager First Name'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000476)
,p_query_column_id=>16
,p_column_alias=>'MANAGER_LAST_NAME'
,p_column_display_sequence=>16
,p_column_heading=>'Manager Last Name'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000477)
,p_query_column_id=>17
,p_column_alias=>'MANAGER_ID'
,p_column_display_sequence=>17
,p_column_heading=>'Manager Id'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000478)
,p_query_column_id=>18
,p_column_alias=>'MANAGER_EMAIL'
,p_column_display_sequence=>18
,p_column_heading=>'Manager Email'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
end;
/
prompt --application/pages/page_00007
begin
wwv_flow_imp_page.create_page(
 p_id=>7
,p_name=>'Admin Users'
,p_alias=>'ADMIN-USERS'
,p_step_title=>'Admin Users'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(9700000000000051)
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000799)
,p_plug_name=>'P7_FIELD_WIDTH_CSS'
,p_plug_display_sequence=>5
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'htp.p(''<style>'');',
'htp.p(''.t-Form-fieldContainer input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]),'');',
'htp.p(''.t-Form-fieldContainer select'');',
'htp.p(''{ max-width:400px; width:400px; }'');',
'htp.p(''</style>'');'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000800)
,p_plug_name=>'P7_ADD_REMOVE_ADMIN'
,p_title=>'Add or Remove Admin'
,p_icon_css_classes=>'fa-lg fa-user-plus'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000801)
,p_name=>'P7_EMAIL'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(9700000000000800)
,p_prompt=>'Email Address'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>240
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000802)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(9700000000000800)
,p_button_name=>'ADD_ADMIN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Add Admin'
,p_button_position=>'CREATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000803)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(9700000000000800)
,p_button_name=>'REMOVE_ADMIN'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Remove Admin'
,p_button_position=>'DELETE'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(9700000000000805)
,p_name=>'Confirm Remove Admin'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(9700000000000803)
,p_bind_type=>'bind'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(9700000000000806)
,p_event_id=>wwv_flow_imp.id(9700000000000805)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'if(confirm("Remove admin access for this email address?")){apex.submit("REMOVE_ADMIN");}'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000810)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Add Admin'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :REQUEST = ''ADD_ADMIN'' then',
'   begin',
'      insert into xxcti_uar_admins (email_address) values (:P7_EMAIL);',
'      commit;',
'   exception',
'      when dup_val_on_index then',
'         null;',
'   end;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000810
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000811)
,p_process_sequence=>11
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Remove Admin'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :REQUEST = ''REMOVE_ADMIN'' then',
'   if upper(:P7_EMAIL) = upper(sys_context(''APEX$SESSION'',''APP_USER'')) then',
'      raise_application_error(-20002, ''You cannot remove your own admin access from here.'');',
'   end if;',
'   delete from xxcti_uar_admins where upper(email_address) = upper(:P7_EMAIL);',
'   commit;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000811
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(9700000000000820)
,p_name=>'P7_ADMINS'
,p_title=>'Current Admins'
,p_template=>4072358936313175081
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--staticRowColors:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select email_address, added_by, added_date',
'from xxcti_uar_admins',
'order by added_date desc'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No admins found -- that should not be possible if you are seeing this page.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_query_row_count_max=>500
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000821)
,p_query_column_id=>1
,p_column_alias=>'EMAIL_ADDRESS'
,p_column_display_sequence=>1
,p_column_heading=>'Email Address'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000822)
,p_query_column_id=>2
,p_column_alias=>'ADDED_BY'
,p_column_display_sequence=>2
,p_column_heading=>'Added By'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000823)
,p_query_column_id=>3
,p_column_alias=>'ADDED_DATE'
,p_column_display_sequence=>3
,p_column_heading=>'Added Date'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
);
end;
/
prompt --application/pages/page_09999
begin
wwv_flow_imp_page.create_page(
 p_id=>9999
,p_name=>'Login Page'
,p_alias=>'LOGIN'
,p_step_title=>'Oracle User Access Review - Log In'
,p_warn_on_unsaved_changes=>'N'
,p_first_item=>'AUTO_FIRST_ITEM'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2101157952850466385
,p_page_template_options=>'#DEFAULT#'
,p_page_is_public_y_n=>'Y'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000100)
,p_plug_name=>'Oracle User Access Review'
,p_region_template_options=>'#DEFAULT#:t-Login-region--headerTitle js-removeLandmark'
,p_plug_template=>2674157997338192145
,p_plug_display_sequence=>20
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000101)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(9700000000000100)
,p_button_name=>'LOGIN'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Sign In'
,p_button_position=>'NEXT'
,p_button_alignment=>'LEFT'
,p_grid_new_row=>'Y'
,p_grid_new_column=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000102)
,p_name=>'P9999_USERNAME'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(9700000000000100)
,p_prompt=>'Username'
,p_placeholder=>'Username'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_cMaxlength=>100
,p_tag_attributes=>'autocomplete="username"'
,p_label_alignment=>'RIGHT'
,p_field_template=>2040785906935475274
,p_item_icon_css_classes=>'fa-user'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000103)
,p_name=>'P9999_PASSWORD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(9700000000000100)
,p_prompt=>'Password'
,p_placeholder=>'Password'
,p_display_as=>'NATIVE_PASSWORD'
,p_cSize=>40
,p_cMaxlength=>100
,p_tag_attributes=>'autocomplete="current-password"'
,p_label_alignment=>'RIGHT'
,p_field_template=>2040785906935475274
,p_item_icon_css_classes=>'fa-key'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'submit_when_enter_pressed', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000104)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_INVOKE_API'
,p_process_name=>'Login'
,p_attribute_01=>'PLSQL_PACKAGE'
,p_attribute_03=>'APEX_AUTHENTICATION'
,p_attribute_04=>'LOGIN'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000104
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(9700000000000105)
,p_page_process_id=>wwv_flow_imp.id(9700000000000104)
,p_page_id=>9999
,p_name=>'p_username'
,p_direction=>'IN'
,p_data_type=>'VARCHAR2'
,p_has_default=>false
,p_display_sequence=>1
,p_value_type=>'ITEM'
,p_value=>'P9999_USERNAME'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(9700000000000106)
,p_page_process_id=>wwv_flow_imp.id(9700000000000104)
,p_page_id=>9999
,p_name=>'p_password'
,p_direction=>'IN'
,p_data_type=>'VARCHAR2'
,p_has_default=>false
,p_display_sequence=>2
,p_value_type=>'ITEM'
,p_value=>'P9999_PASSWORD'
);
wwv_flow_imp_shared.create_invokeapi_comp_param(
 p_id=>wwv_flow_imp.id(9700000000000107)
,p_page_process_id=>wwv_flow_imp.id(9700000000000104)
,p_page_id=>9999
,p_name=>'p_set_persistent_auth'
,p_direction=>'IN'
,p_data_type=>'BOOLEAN'
,p_has_default=>true
,p_display_sequence=>3
,p_value_type=>'API_DEFAULT'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000108)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_SESSION_STATE'
,p_process_name=>'Clear Page(s) Cache'
,p_attribute_01=>'CLEAR_CACHE_CURRENT_PAGE'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000108
);
end;
/
prompt --application/deployment/definition
begin
null;
end;
/
prompt --application/deployment/checks
begin
null;
end;
/
prompt --application/deployment/buildoptions
begin
null;
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
