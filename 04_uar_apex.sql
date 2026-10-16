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

prompt APPLICATION 530 - Oracle User Access Review V2
--
-- Application Export:
--   Application:     530
--   Name:            Oracle User Access Review V2
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
,p_name=>nvl(wwv_flow_application_install.get_application_name,'Oracle User Access Review V2')
,p_alias=>nvl(wwv_flow_application_install.get_application_alias,'UAR-V2')
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
,p_flow_version=>'Release 2.0'
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
,p_list_item_link_target=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.:1:::'
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
prompt --workspace/credentials/creation_apex_dev_pmo
begin
wwv_imp_workspace.create_credential(
 p_id=>wwv_flow_imp.id(10878677230346892)
,p_name=>'Creation APEX - DEV - PMO'
,p_static_id=>'Creation_APEX_DEV_PMO'
,p_authentication_type=>'BASIC'
,p_prompt_on_install=>true
);
end;
/
prompt --application/shared_components/security/authentications/azure_ad_sso
begin
wwv_flow_imp_shared.create_authentication(
 p_id=>wwv_flow_imp.id(9700000000000010)
,p_name=>'Azure AD SSO'
,p_scheme_type=>'NATIVE_SOCIAL'
,p_attribute_01=>wwv_flow_imp.id(10878677230346892)
,p_attribute_02=>'OPENID_CONNECT'
,p_attribute_03=>'https://login.microsoftonline.com/5d859f82-437e-44bc-9c59-494f57d7e5d0/v2.0/.well-known/openid-configuration'
,p_attribute_07=>'openid,email,profile'
,p_attribute_09=>'email'
,p_attribute_11=>'N'
,p_attribute_13=>'Y'
,p_invalid_session_type=>'LOGIN'
,p_post_auth_process=>'XXCTI_UAR_SSO_POST_AUTH'
,p_use_secure_cookie_yn=>'Y'
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
 p_id=>wwv_flow_imp.id(9700000000000190)
,p_plug_name=>'P1_TITLE'
,p_title=>'My Team Review'
,p_icon_css_classes=>'fa-check-square-o'
,p_region_template_options=>'#DEFAULT#:t-HeroRegion--noPadding'
,p_plug_template=>2674017834225413037
,p_plug_display_sequence=>1
,p_location=>null
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
'   htp.p(''<style>.uar-greeting{font-size:1.1rem;font-weight:600;color:#2E75B6;margin:4px 0 10px;}'');',
'   htp.p(''.t-HeroRegion:has(.fa-check-square-o){margin-bottom:3em;}</style>'');',
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
,p_plug_name=>'P1_INSTRUCTIONS'
,p_plug_display_sequence=>6
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'htp.p(''<div class="uar-instructions" style="background:#F5F8FA;border-left:3px solid #2E75B6;padding:12px 16px;margin:0 0 16px;border-radius:0 4px 4px 0;">'');',
'htp.p(''<strong>How to use this page:</strong> Below is the list of employees currently '');',
'htp.p(''assigned to you for this cycle. Click an employee''''s ID to open their access items '');',
'htp.p(''for review. Once every item below shows as complete, use the '');',
'htp.p(''<strong>Submit My Review</strong> button above to finalize your submission before '');',
'htp.p(''the due date for this review cycle.'');',
'htp.p(''</div>'');'))
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
'         htp.p(''Complete Review By: <strong>'' || to_char(l_due_date,''Mon DD, YYYY'') || ''</strong>'');',
'         htp.p('' &mdash; <strong style="color:'' || l_color || '';">'' || l_label || ''</strong>'');',
'         htp.p(''</div>'');',
'      end if;',
'   end if;',
'end;'))
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000200)
,p_name=>'P1_MANAGER'
,p_item_sequence=>10
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
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
'if xxcti_uar_security_pkg.is_admin = ''N'' then',
'   :P1_MANAGER := xxcti_uar_security_pkg.resolve_employee_id;',
'elsif :P1_MANAGER is null then',
'   :P1_MANAGER := xxcti_uar_security_pkg.resolve_employee_id;',
'end if;',
':P1_CYCLE_ID := xxcti_uar_cycle_pkg.current_open_cycle;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>1700000000000220
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000260)
,p_process_sequence=>15
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Compute Submit Eligibility'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P1_CAN_SUBMIT := null;',
'if :P1_CYCLE_ID is not null then',
'   begin',
'      select case when pct_complete = 100 then ''Y'' end',
'        into :P1_CAN_SUBMIT',
'        from xxcti_uar_cycle_progress',
'       where cycle_id = :P1_CYCLE_ID',
'         and manager_id = :P1_MANAGER;',
'   exception when no_data_found then',
'      :P1_CAN_SUBMIT := null;',
'   end;',
'   if xxcti_uar_cycle_pkg.manager_signed_off(:P1_CYCLE_ID, :P1_MANAGER) = ''Y'' then',
'      :P1_CAN_SUBMIT := null;',
'   end if;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>1700000000000260
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000270)
,p_plug_name=>'P1_PROGRESS'
,p_title=>'Review Progress'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch'
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'   l_total     number;',
'   l_completed number;',
'   l_pct       number;',
'   l_hue       number;',
'begin',
'   begin',
'      select total_items, completed_items, pct_complete',
'        into l_total, l_completed, l_pct',
'        from xxcti_uar_cycle_progress',
'       where cycle_id = :P1_CYCLE_ID',
'         and manager_id = :P1_MANAGER;',
'   exception when no_data_found then',
'      l_total := null;',
'   end;',
'',
'   if l_total is null then',
'      htp.p(''No items to review yet for this cycle.'');',
'   else',
'      l_hue := round(nvl(l_pct, 0) * 1.2);',
'      htp.p(''<div style="margin:0 0 4px;font-size:.9rem;">'' || l_completed || '' of '' || l_total ||',
'            '' items reviewed ('' || round(nvl(l_pct,0)) || ''%)</div>'');',
'      htp.p(''<div style="background:#E2E2E2;border-radius:6px;height:18px;width:100%;overflow:hidden;">'');',
'      htp.p(''<div style="background:hsl('' || l_hue || '',70%,45%);height:100%;width:'' ||',
'            round(nvl(l_pct,0)) || ''%;transition:width .3s;"></div>'');',
'      htp.p(''</div>'');',
'   end if;',
'end;'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000261)
,p_plug_name=>'P1_SUBMIT_STATUS'
,p_plug_display_sequence=>22
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'   l_submitted_date date;',
'begin',
'   if :P1_CYCLE_ID is not null then',
'      if xxcti_uar_cycle_pkg.manager_signed_off(:P1_CYCLE_ID, :P1_MANAGER) = ''Y'' then',
'         begin',
'            select submitted_date into l_submitted_date',
'              from xxcti_uar_manager_signoffs',
'             where cycle_id = :P1_CYCLE_ID',
'               and manager_id = :P1_MANAGER;',
'         exception when no_data_found then',
'            l_submitted_date := null;',
'         end;',
'         htp.p(''<div class="uar-submit-status" style="background:#EAF4EC;border-left:3px solid #1A7C4F;padding:10px 14px;margin:0 0 16px;border-radius:0 4px 4px 0;">'');',
'         htp.p(''You submitted your review on <strong>'' || to_char(l_submitted_date,''Mon DD, YYYY'') || ''</strong>. An admin can reopen it if you need to make a change.'');',
'         htp.p(''</div>'');',
'      elsif :P1_CAN_SUBMIT is null then',
'         htp.p(''<div class="uar-submit-status" style="background:#F5F8FA;border-left:3px solid #2E75B6;padding:10px 14px;margin:0 0 16px;border-radius:0 4px 4px 0;">'');',
'         htp.p(''Complete every item below before you can submit your review.'');',
'         htp.p(''</div>'');',
'      end if;',
'   end if;',
'end;'))
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000263)
,p_name=>'P1_CAN_SUBMIT'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(9700000000000270)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000264)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(9700000000000270)
,p_button_name=>'SUBMIT_REVIEW'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Submit My Review'
,p_button_position=>'CREATE'
,p_button_condition=>'P1_CAN_SUBMIT'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(9700000000000266)
,p_name=>'Confirm Submit Review'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(9700000000000264)
,p_bind_type=>'bind'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(9700000000000267)
,p_event_id=>wwv_flow_imp.id(9700000000000266)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'if(confirm("Submit your review? You will not be able to make further changes unless an admin reopens it.")){apex.submit("SUBMIT_REVIEW");}'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000265)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Submit Review'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :REQUEST = ''SUBMIT_REVIEW'' then',
'   xxcti_uar_cycle_pkg.submit_review(:P1_CYCLE_ID, :P1_MANAGER);',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000265
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
'    ri.user_name,',
'    comp.review_complete,',
'    apex_page.get_url(',
'       p_page => 2,',
'       p_items => ''P2_EMPLOYEE_ID,P2_CYCLE_ID'',',
'       p_values => to_char(uwe.employee_id) || '','' || to_char(:P1_CYCLE_ID),',
'       p_clear_cache => ''2''',
'    ) as employee_url',
'from xxcti_uar_workday_employee_mgr uwe',
'join xxcti_uar_review_items ri',
'  on to_char(uwe.employee_id) = ri.employee_number',
'left join completeness comp',
'  on ri.employee_number = comp.employee_number',
'where uwe.manager_id = :P1_MANAGER',
'  and ri.cycle_id = :P1_CYCLE_ID'))
,p_plug_source_type=>'NATIVE_IR'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(9700000000000290)
,p_max_row_count=>'500'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_download_formats=>'CSV:HTML:XLSX'
,p_enable_mail_download=>'Y'
,p_owner=>'ADMIN'
,p_internal_uid=>9700000000000290
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000291)
,p_db_column_name=>'EMPLOYEE_ID'
,p_display_order=>1
,p_column_identifier=>'A'
,p_column_label=>'Employee ID'
,p_column_html_expression=>'<a href="#EMPLOYEE_URL#">#EMPLOYEE_ID#</a>'
,p_column_type=>'NUMBER'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000292)
,p_db_column_name=>'EMPLOYEE_LEGAL_FIRST_NAME'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'First Name'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000293)
,p_db_column_name=>'EMPLOYEE_LEGAL_LAST_NAME'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Last Name'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000294)
,p_db_column_name=>'USER_NAME'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Oracle User Name'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000295)
,p_db_column_name=>'REVIEW_COMPLETE'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'Review Complete'
,p_column_type=>'STRING'
,p_column_alignment=>'CENTER'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000296)
,p_db_column_name=>'EMPLOYEE_URL'
,p_display_order=>99
,p_column_identifier=>'F'
,p_column_label=>'Employee URL'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(9700000000000297)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'uar1rpt'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'EMPLOYEE_ID:EMPLOYEE_LEGAL_FIRST_NAME:EMPLOYEE_LEGAL_LAST_NAME:USER_NAME:REVIEW_COMPLETE:EMPLOYEE_URL'
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
 p_id=>wwv_flow_imp.id(9700000000000309)
,p_plug_name=>'P2_BACK_BUTTON_SPACING_CSS'
,p_plug_display_sequence=>1
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'htp.p(''<style>[data-otel-label="P2_BACK_BUTTON"]{margin-top:20px;}'');',
'htp.p(''.t-HeroRegion:has(.fa-list-ul){margin-bottom:3em;}</style>'');'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000300)
,p_plug_name=>'P2_EMPLOYEE_REVIEW'
,p_title=>'&P2_EMPLOYEE_NAME.''s Access Review'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000303)
,p_name=>'P2_EMPLOYEE_NAME'
,p_item_sequence=>25
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
'if xxcti_uar_cycle_pkg.can_edit_item(:P2_EMPLOYEE_ID, :P2_CYCLE_ID) = ''N'' then',
'   apex_util.redirect_url(apex_page.get_url(p_page => 1));',
'end if;',
'',
'begin',
'   select employee_legal_first_name || '' '' || employee_legal_last_name',
'     into :P2_EMPLOYEE_NAME',
'     from xxcti_uar_workday_employee_mgr',
'    where to_char(employee_id) = :P2_EMPLOYEE_ID;',
'exception when no_data_found then',
'   :P2_EMPLOYEE_NAME := :P2_EMPLOYEE_ID;',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>1700000000000310
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000311)
,p_plug_name=>'P2_INSTRUCTIONS'
,p_plug_display_sequence=>20
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'htp.p(''<div class="uar-instructions" style="background:#F5F8FA;border-left:3px solid #2E75B6;padding:12px 16px;margin:0 0 16px;border-radius:0 4px 4px 0;">'');',
'htp.p(''<strong>How to complete this review:</strong> For each access item below, review the '');',
'htp.p(''responsibility and application listed, then click <strong>Approve</strong> or '');',
'htp.p(''<strong>Deny</strong>. Approve saves immediately. Deny opens a short form requiring a '');',
'htp.p(''comment explaining why, before it saves.'');',
'htp.p(''When finished with this employee, click <strong>Back to My Team</strong> above to '');',
'htp.p(''continue reviewing your other employees and submit your review once every item is '');',
'htp.p(''complete.'');',
'htp.p(''</div>'');'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000320)
,p_plug_name=>'P2_RESPONSIBILITY'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>30
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ri.responsibility,',
'       ri.application,',
'       ri.last_logon,',
'       nvl(ri.approval, ''Pending'') as approval_display,',
'       ri.comments,',
'       ri.review_item_id,',
'       apex_page.get_url(',
'          p_page => 8,',
'          p_items => ''P8_REVIEW_ITEM_ID,P8_RETURN_EMPLOYEE_ID,P8_RETURN_CYCLE_ID'',',
'          p_values => ri.review_item_id || '','' || :P2_EMPLOYEE_ID || '','' || :P2_CYCLE_ID,',
'          p_clear_cache => ''8''',
'       ) as deny_url,',
'       case when xxcti_uar_cycle_pkg.can_edit_item(ri.employee_number, ri.cycle_id) = ''N''',
'            then ''inline'' else ''none'' end as locked_display,',
'       case when xxcti_uar_cycle_pkg.can_edit_item(ri.employee_number, ri.cycle_id) = ''N''',
'            then ''none'' else ''inline'' end as unlocked_display,',
'       case when ri.approval is not null then ''inline'' else ''none'' end as undo_display',
'  from xxcti_uar_review_items ri',
' where ri.employee_number = :P2_EMPLOYEE_ID',
'   and ri.cycle_id = :P2_CYCLE_ID',
' order by ri.responsibility, ri.application'))
,p_plug_source_type=>'NATIVE_IR'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(9700000000000340)
,p_max_row_count=>'500'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_owner=>'ADMIN'
,p_internal_uid=>9700000000000340
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000321)
,p_db_column_name=>'RESPONSIBILITY'
,p_display_order=>1
,p_column_identifier=>'A'
,p_column_label=>'Responsibility'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000322)
,p_db_column_name=>'APPLICATION'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Application'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000323)
,p_db_column_name=>'LAST_LOGON'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Last Used'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000324)
,p_db_column_name=>'APPROVAL_DISPLAY'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Approval'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000326)
,p_db_column_name=>'REVIEW_ITEM_ID'
,p_display_order=>5
,p_column_identifier=>'F'
,p_column_label=>' '
,p_column_html_expression=>'<span style="display:#LOCKED_DISPLAY#;white-space:nowrap;color:#888;">Locked</span><span style="display:#UNLOCKED_DISPLAY#;white-space:nowrap;"><button type="button" class="t-Button t-Button--small t-Button--success" onclick="uarApproveItem(#REVIEW_ITEM_ID#)">Approve</button> <a class="t-Button t-Button--small t-Button--danger" onclick="uarSaveScrollPos()" href="#DENY_URL#">Deny</a> <span style="display:#UNDO_DISPLAY#;"><button type="button" class="t-Button t-Button--small t-Button--simple" onclick="uarResetItem(#REVIEW_ITEM_ID#)">Undo</button></span></span>'
,p_column_type=>'STRING'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000325)
,p_db_column_name=>'COMMENTS'
,p_display_order=>6
,p_column_identifier=>'E'
,p_column_label=>'Denial Reason'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000342)
,p_db_column_name=>'DENY_URL'
,p_display_order=>97
,p_column_identifier=>'G'
,p_column_label=>'Deny URL'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000343)
,p_db_column_name=>'LOCKED_DISPLAY'
,p_display_order=>98
,p_column_identifier=>'H'
,p_column_label=>'Locked Display'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000344)
,p_db_column_name=>'UNLOCKED_DISPLAY'
,p_display_order=>99
,p_column_identifier=>'I'
,p_column_label=>'Unlocked Display'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000345)
,p_db_column_name=>'UNDO_DISPLAY'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Undo Display'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(9700000000000341)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'uar2rpt'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'RESPONSIBILITY:APPLICATION:LAST_LOGON:APPROVAL_DISPLAY:REVIEW_ITEM_ID:COMMENTS:DENY_URL:LOCKED_DISPLAY:UNLOCKED_DISPLAY:UNDO_DISPLAY'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000395)
,p_name=>'P2_ACTION_ITEM_ID'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(9700000000000300)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000396)
,p_plug_name=>'P2_APPROVE_SCRIPT'
,p_plug_display_sequence=>35
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'htp.p(''<script>'');',
'htp.p(''function uarSaveScrollPos(){'');',
'htp.p(''  sessionStorage.setItem("uar_scroll_pos", window.scrollY);'');',
'htp.p(''}'');',
'htp.p(''function uarApproveItem(id){'');',
'htp.p(''  uarSaveScrollPos();'');',
'htp.p(''  apex.item("P2_ACTION_ITEM_ID").setValue(id);'');',
'htp.p(''  apex.submit("APPROVE_ITEM");'');',
'htp.p(''}'');',
'htp.p(''function uarResetItem(id){'');',
'htp.p(''  if (!confirm("Reset this item back to Pending?")) { return; }'');',
'htp.p(''  uarSaveScrollPos();'');',
'htp.p(''  apex.item("P2_ACTION_ITEM_ID").setValue(id);'');',
'htp.p(''  apex.submit("RESET_ITEM");'');',
'htp.p(''}'');',
'htp.p(''window.addEventListener("load", function(){'');',
'htp.p(''  var pos = sessionStorage.getItem("uar_scroll_pos");'');',
'htp.p(''  if (pos !== null) {'');',
'htp.p(''    window.scrollTo(0, parseInt(pos, 10));'');',
'htp.p(''    sessionStorage.removeItem("uar_scroll_pos");'');',
'htp.p(''  }'');',
'htp.p(''});'');',
'htp.p(''</script>'');'))
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000397)
,p_process_sequence=>15
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Approve Item'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :REQUEST = ''APPROVE_ITEM'' then',
'   update xxcti_uar_review_items',
'      set approval = ''Approved'',',
'          comments = null',
'    where review_item_id = :P2_ACTION_ITEM_ID',
'      and employee_number = :P2_EMPLOYEE_ID',
'      and cycle_id = :P2_CYCLE_ID;',
'   commit;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000397
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000398)
,p_process_sequence=>17
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reset Item'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :REQUEST = ''RESET_ITEM'' then',
'   update xxcti_uar_review_items',
'      set approval = null,',
'          comments = null',
'    where review_item_id = :P2_ACTION_ITEM_ID',
'      and employee_number = :P2_EMPLOYEE_ID',
'      and cycle_id = :P2_CYCLE_ID;',
'   commit;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000398
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000380)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(9700000000000320)
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
 p_id=>wwv_flow_imp.id(9700000000000191)
,p_plug_name=>'P3_TITLE'
,p_title=>'Review Cycles'
,p_icon_css_classes=>'fa-calendar'
,p_region_template_options=>'#DEFAULT#:t-HeroRegion--noPadding'
,p_plug_template=>2674017834225413037
,p_plug_display_sequence=>1
,p_location=>null
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
'htp.p(''.t-HeroRegion:has(.fa-calendar){margin-bottom:3em;}'');',
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000530)
,p_plug_name=>'P3_REOPEN_SUBMISSION'
,p_title=>'Reopen a Manager''s Submission'
,p_icon_css_classes=>'fa-lg fa-unlock'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>35
,p_location=>null
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000531)
,p_name=>'P3_REOPEN_MANAGER_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(9700000000000530)
,p_prompt=>'Manager'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select m.employee_legal_first_name || '' '' || m.employee_legal_last_name as d,',
'       s.manager_id as r',
'from xxcti_uar_manager_signoffs s',
'join xxcti_uar_workday_employee_mgr m',
'  on m.employee_id = s.manager_id',
'where s.cycle_id = xxcti_uar_cycle_pkg.current_open_cycle',
'order by 1'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Select a manager -'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000532)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(9700000000000530)
,p_button_name=>'REOPEN_SUBMISSION'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Reopen Submission'
,p_button_position=>'CREATE'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000533)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Reopen Submission'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :REQUEST = ''REOPEN_SUBMISSION'' then',
'   xxcti_uar_cycle_pkg.reopen_review(',
'      xxcti_uar_cycle_pkg.current_open_cycle,',
'      :P3_REOPEN_MANAGER_ID',
'   );',
'   :P3_REOPEN_MANAGER_ID := null;',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000533
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000440)
,p_plug_name=>'P3_MANAGER_COMPLETION'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>40
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select cp.manager_first_name || '' '' || cp.manager_last_name as manager_name,',
'       uwe.email_address,',
'       cp.total_items,',
'       cp.completed_items,',
'       cp.pct_complete,',
'       case when so.manager_id is not null then ''Yes'' else ''No'' end as submitted,',
'       so.submitted_date,',
'       apex_page.get_url(',
'          p_page => 1,',
'          p_items => ''P1_MANAGER'',',
'          p_values => to_char(cp.manager_id),',
'          p_clear_cache => ''1''',
'       ) as manager_url',
'from xxcti_uar_cycle_progress cp',
'join xxcti_uar_workday_employee_mgr uwe',
'  on cp.manager_id = uwe.employee_id',
'left join xxcti_uar_manager_signoffs so',
'  on so.cycle_id = cp.cycle_id',
' and so.manager_id = cp.manager_id',
'where cp.cycle_id = xxcti_uar_cycle_pkg.current_open_cycle',
'order by cp.pct_complete'))
,p_plug_source_type=>'NATIVE_IR'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(9700000000000540)
,p_max_row_count=>'500'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_download_formats=>'CSV:HTML:XLSX'
,p_enable_mail_download=>'Y'
,p_owner=>'ADMIN'
,p_internal_uid=>9700000000000540
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000541)
,p_db_column_name=>'MANAGER_NAME'
,p_display_order=>1
,p_column_identifier=>'A'
,p_column_label=>'Manager Name'
,p_column_html_expression=>'<a href="#MANAGER_URL#">#MANAGER_NAME#</a>'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000542)
,p_db_column_name=>'EMAIL_ADDRESS'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Email'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000543)
,p_db_column_name=>'TOTAL_ITEMS'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Total Items'
,p_column_type=>'NUMBER'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000544)
,p_db_column_name=>'COMPLETED_ITEMS'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Completed Items'
,p_column_type=>'NUMBER'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000545)
,p_db_column_name=>'PCT_COMPLETE'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'% Complete'
,p_column_type=>'NUMBER'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000546)
,p_db_column_name=>'SUBMITTED'
,p_display_order=>6
,p_column_identifier=>'F'
,p_column_label=>'Submitted'
,p_column_type=>'STRING'
,p_column_alignment=>'CENTER'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000547)
,p_db_column_name=>'SUBMITTED_DATE'
,p_display_order=>7
,p_column_identifier=>'G'
,p_column_label=>'Submitted Date'
,p_column_type=>'DATE'
,p_column_alignment=>'CENTER'
,p_format_mask=>'DD-Mon-YYYY'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000548)
,p_db_column_name=>'MANAGER_URL'
,p_display_order=>99
,p_column_identifier=>'H'
,p_column_label=>'Manager URL'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(9700000000000549)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'uar3rpt'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'MANAGER_NAME:EMAIL_ADDRESS:TOTAL_ITEMS:COMPLETED_ITEMS:PCT_COMPLETE:SUBMITTED:SUBMITTED_DATE:MANAGER_URL'
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
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000192)
,p_plug_name=>'P4_TITLE'
,p_title=>'Audit History'
,p_icon_css_classes=>'fa-database-lock'
,p_region_template_options=>'#DEFAULT#:t-HeroRegion--noPadding'
,p_plug_template=>2674017834225413037
,p_plug_display_sequence=>1
,p_location=>null
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000194)
,p_plug_name=>'P4_TITLE_SPACING_CSS'
,p_plug_display_sequence=>2
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'htp.p(''<style>.t-HeroRegion:has(.fa-database-lock){margin-bottom:3em;}</style>'');'))
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000460)
,p_plug_name=>'P4_AUDIT_HISTORY'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
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
,p_plug_source_type=>'NATIVE_IR'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(9700000000000493)
,p_max_row_count=>'500'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_download_formats=>'CSV:HTML:XLSX'
,p_enable_mail_download=>'Y'
,p_owner=>'ADMIN'
,p_internal_uid=>9700000000000493
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000500)
,p_db_column_name=>'CYCLE_NAME'
,p_display_order=>1
,p_column_identifier=>'A'
,p_column_label=>'Cycle'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000501)
,p_db_column_name=>'CYCLE_STATUS'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Cycle Status'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000502)
,p_db_column_name=>'REVIEW_ITEM_ID'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Review Item Id'
,p_column_type=>'NUMBER'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000503)
,p_db_column_name=>'USER_NAME'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'User Name'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000504)
,p_db_column_name=>'EMPLOYEE_NUMBER'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'Employee Number'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000505)
,p_db_column_name=>'RESPONSIBILITY'
,p_display_order=>6
,p_column_identifier=>'F'
,p_column_label=>'Responsibility'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000506)
,p_db_column_name=>'APPLICATION'
,p_display_order=>7
,p_column_identifier=>'G'
,p_column_label=>'Application'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000507)
,p_db_column_name=>'START_DATE'
,p_display_order=>8
,p_column_identifier=>'H'
,p_column_label=>'Start Date'
,p_column_type=>'DATE'
,p_column_alignment=>'CENTER'
,p_format_mask=>'DD-Mon-YYYY'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000508)
,p_db_column_name=>'END_DATE'
,p_display_order=>9
,p_column_identifier=>'I'
,p_column_label=>'End Date'
,p_column_type=>'DATE'
,p_column_alignment=>'CENTER'
,p_format_mask=>'DD-Mon-YYYY'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000509)
,p_db_column_name=>'APPROVAL'
,p_display_order=>10
,p_column_identifier=>'J'
,p_column_label=>'Approval'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000510)
,p_db_column_name=>'APPROVER'
,p_display_order=>11
,p_column_identifier=>'K'
,p_column_label=>'Approver'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000511)
,p_db_column_name=>'APPROVAL_DATE'
,p_display_order=>12
,p_column_identifier=>'L'
,p_column_label=>'Approval Date'
,p_column_type=>'DATE'
,p_column_alignment=>'CENTER'
,p_format_mask=>'DD-Mon-YYYY'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000512)
,p_db_column_name=>'LAST_LOGON'
,p_display_order=>13
,p_column_identifier=>'M'
,p_column_label=>'Last Logon'
,p_column_type=>'DATE'
,p_column_alignment=>'CENTER'
,p_format_mask=>'DD-Mon-YYYY'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000513)
,p_db_column_name=>'COMMENTS'
,p_display_order=>14
,p_column_identifier=>'N'
,p_column_label=>'Comments'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000514)
,p_db_column_name=>'MANAGER_FIRST_NAME'
,p_display_order=>15
,p_column_identifier=>'O'
,p_column_label=>'Manager First Name'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000515)
,p_db_column_name=>'MANAGER_LAST_NAME'
,p_display_order=>16
,p_column_identifier=>'P'
,p_column_label=>'Manager Last Name'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000516)
,p_db_column_name=>'MANAGER_ID'
,p_display_order=>17
,p_column_identifier=>'Q'
,p_column_label=>'Manager Id'
,p_column_type=>'NUMBER'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9700000000000517)
,p_db_column_name=>'MANAGER_EMAIL'
,p_display_order=>18
,p_column_identifier=>'R'
,p_column_label=>'Manager Email'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(9700000000000518)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'uar4rpt'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CYCLE_NAME:CYCLE_STATUS:REVIEW_ITEM_ID:USER_NAME:EMPLOYEE_NUMBER:RESPONSIBILITY:APPLICATION:START_DATE:END_DATE:APPROVAL:APPROVER:APPROVAL_DATE:LAST_LOGON:COMMENTS:MANAGER_FIRST_NAME:MANAGER_LAST_NAME:MANAGER_ID:MANAGER_EMAIL'
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
 p_id=>wwv_flow_imp.id(9700000000000193)
,p_plug_name=>'P7_TITLE'
,p_title=>'Admin Users'
,p_icon_css_classes=>'fa-user-plus'
,p_region_template_options=>'#DEFAULT#:t-HeroRegion--noPadding'
,p_plug_template=>2674017834225413037
,p_plug_display_sequence=>1
,p_location=>null
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
'htp.p(''.t-HeroRegion:has(.fa-user-plus){margin-bottom:3em;}'');',
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
prompt --application/pages/page_00008
begin
wwv_flow_imp_page.create_page(
 p_id=>8
,p_name=>'Deny Item'
,p_alias=>'DENY-ITEM'
,p_step_title=>'Deny Item'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000901)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Enforce Ownership and Load Context'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if xxcti_uar_security_pkg.can_review(:P8_RETURN_EMPLOYEE_ID) = ''N'' then',
'   apex_util.redirect_url(apex_page.get_url(p_page => 1));',
'end if;',
'',
'if xxcti_uar_cycle_pkg.can_edit_item(:P8_RETURN_EMPLOYEE_ID, :P8_RETURN_CYCLE_ID) = ''N'' then',
'   apex_util.redirect_url(apex_page.get_url(p_page => 1));',
'end if;',
'',
'begin',
'   select responsibility, application',
'     into :P8_RESPONSIBILITY_DISPLAY, :P8_APPLICATION_DISPLAY',
'     from xxcti_uar_review_items',
'    where review_item_id = :P8_REVIEW_ITEM_ID;',
'exception when no_data_found then',
'   apex_util.redirect_url(apex_page.get_url(p_page => 1));',
'end;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>1700000000000901
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000902)
,p_plug_name=>'P8_DENY_ITEM'
,p_title=>'Deny Access Item'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9700000000000912)
,p_plug_name=>'P8_FIELD_WIDTH_CSS'
,p_plug_display_sequence=>5
,p_plug_source_type=>'NATIVE_PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'htp.p(''<style>'');',
'htp.p(''.t-Region:has(#P8_COMMENTS){max-width:50ch;}'');',
'htp.p(''</style>'');'))
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000903)
,p_name=>'P8_REVIEW_ITEM_ID'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(9700000000000902)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000904)
,p_name=>'P8_RETURN_EMPLOYEE_ID'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(9700000000000902)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000905)
,p_name=>'P8_RETURN_CYCLE_ID'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(9700000000000902)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000906)
,p_name=>'P8_RESPONSIBILITY_DISPLAY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(9700000000000902)
,p_prompt=>'Responsibility'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'Y',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000907)
,p_name=>'P8_APPLICATION_DISPLAY'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(9700000000000902)
,p_prompt=>'Application'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>40
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'Y',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9700000000000908)
,p_name=>'P8_COMMENTS'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(9700000000000902)
,p_prompt=>'Reason for Denial'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>40
,p_cMaxlength=>4000
,p_cHeight=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_required=>true
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000909)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(9700000000000902)
,p_button_name=>'CONFIRM_DENY'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Confirm Deny'
,p_button_position=>'CREATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9700000000000910)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(9700000000000902)
,p_button_name=>'CANCEL'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancel'
,p_button_position=>'CLOSE'
,p_button_redirect_url=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.::P2_EMPLOYEE_ID,P2_CYCLE_ID:&P8_RETURN_EMPLOYEE_ID.,&P8_RETURN_CYCLE_ID.'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9700000000000911)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Confirm Deny'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'if :REQUEST = ''CONFIRM_DENY'' then',
'   update xxcti_uar_review_items',
'      set approval = ''Denied'',',
'          comments = :P8_COMMENTS',
'    where review_item_id = :P8_REVIEW_ITEM_ID',
'      and employee_number = :P8_RETURN_EMPLOYEE_ID',
'      and cycle_id = :P8_RETURN_CYCLE_ID;',
'   commit;',
'   apex_util.redirect_url(apex_page.get_url(',
'      p_page => 2,',
'      p_items => ''P2_EMPLOYEE_ID,P2_CYCLE_ID'',',
'      p_values => :P8_RETURN_EMPLOYEE_ID || '','' || :P8_RETURN_CYCLE_ID',
'   ));',
'end if;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>1700000000000911
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
