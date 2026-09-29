prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file -- HAND-AUTHORED, built incrementally stage by
-- stage and tested after each stage (no live instance available while
-- writing it). See APEX_BUILD_GUIDE.md / README.md in this repo.
--
-- STAGE 0 (current): application shell, authentication, real authorization
-- schemes, Global Page, Login page, Page 1 (My Team Review).
-- Pages 2 (Employee Review), 3 (Review Cycles), 4 (Audit History) follow in
-- later stages once this imports and tests clean.
--
-- Deliberately simplified vs. the original app 104 for this first cut:
--   - No custom logo/app icons/PWA -- omitted p_logo_type/p_logo_text
--     entirely rather than guess at a valid token (original only ever shows
--     p_logo_type=>'IT', not the 'TEXT' this file originally guessed --
--     fixed 2026-09-29 after a bare import 400). Pure appearance either way,
--     add back later via the real App Builder UI once the app exists.
--   - p_checksum_salt was hand-typed as a 65-character hex string instead of
--     the original's 64 -- never mechanically counted at the time. Fixed
--     2026-09-29 with a properly generated, length-verified 64-char value
--     after re-reviewing the whole file line by line against a real,
--     repeated import failure (not a length-sensitive value that's safe to
--     eyeball, in hindsight).
--   - No "remember username" cookie on Login -- convenience feature, not
--     required for login to work.
--   - Page 1's employee list is a Classic Report, not an Interactive Grid --
--     functionally equivalent for a read-only display, and matches the
--     already-proven create_report_region/create_report_columns pattern
--     from the original app's admin pages instead of the larger IG call
--     chain.
--   - No progress-bar/no-open-cycle messaging region yet -- region-level
--     conditions have no precedent to check against in the original file;
--     the report's own p_query_no_data_found message covers the empty case
--     for now (it already reads correctly whether the empty result is
--     because there's no open cycle or because nothing's assigned yet).
--   - Employee ID is not yet a link to Page 2 -- Page 2 doesn't exist until
--     Stage 1. Wired up then.
--
-- CORRECTED 2026-09-29: p_default_workspace_id and p_default_owner/p_owner
-- were wrong -- assumed (copied from the original app 104 export) rather
-- than confirmed. Real values: workspace ct_bsg_apex (id 9805500296728652,
-- confirmed via a live export taken from it), schema XXUAR, not
-- XXAPEX_EBS/1376906471187634. Turned out NOT to be the actual cause of the
-- import failures (see next note) -- fixed anyway since it was still wrong.
--
-- ACTUAL ROOT CAUSE, FOUND 2026-09-29 via SQL Workshop -> SQL Scripts (which
-- surfaces real PL/SQL errors, unlike App Builder -> Import's opaque
-- CORS-flavored 400/403 wrapper): create_theme had an extra
-- ,p_version_scn=>... parameter that procedure does not accept -- added by
-- mistake during an earlier "restore dropped p_version_scn params" pass that
-- over-applied to a call it doesn't belong on (create_list,
-- create_security_scheme, create_acl_role, and create_authentication DO take
-- it; create_theme does not, confirmed against both the original app 104
-- export and a fresh f113.sql export from this same workspace). Caused
-- PLS-00306 "wrong number or types of arguments in call to 'CREATE_THEME'".
-- Removed. If App Builder Import ever throws an opaque error like this
-- again with no useful detail, try SQL Scripts first -- it gave the exact
-- line and error immediately.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.0'
,p_default_workspace_id=>9805500296728652
,p_default_application_id=>105
,p_default_id_offset=>3087771470140045
,p_default_owner=>'XXUAR'
);
end;
/

prompt APPLICATION 105 - Oracle User Access Review (Rebuild) -- Stage 0

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
 p_id=>wwv_flow_imp.id(105)
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
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--large:t-Form-fieldContainer--boldDisplay'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'case_sensitive', 'N',
  'fetch_on_search', 'N',
  'match_type', 'CONTAINS',
  'min_chars', '0')).to_clob
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
 p_id=>wwv_flow_imp.id(9700000000000230)
,p_name=>'P1_EMPLOYEES'
,p_template=>4072358936313175081
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--staticRowColors:t-Report--rowHighlight:t-Report--inline:t-Report--hideNoPagination'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
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
'  and ri.cycle_id = :P1_CYCLE_ID',
'order by uwe.employee_legal_last_name, uwe.employee_legal_first_name'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No access items to review right now -- either there''s no open review cycle, or nothing is assigned to your team yet.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_query_row_count_max=>500
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_prn_units=>'INCHES'
,p_prn_paper_size=>'LETTER'
,p_prn_width=>11
,p_prn_height=>8.5
,p_prn_orientation=>'HORIZONTAL'
,p_prn_page_header_font_color=>'#000000'
,p_prn_page_header_font_family=>'Helvetica'
,p_prn_page_header_font_weight=>'normal'
,p_prn_page_header_font_size=>'12'
,p_prn_page_footer_font_color=>'#000000'
,p_prn_page_footer_font_family=>'Helvetica'
,p_prn_page_footer_font_weight=>'normal'
,p_prn_page_footer_font_size=>'12'
,p_prn_header_bg_color=>'#EEEEEE'
,p_prn_header_font_color=>'#000000'
,p_prn_header_font_family=>'Helvetica'
,p_prn_header_font_weight=>'bold'
,p_prn_header_font_size=>'10'
,p_prn_body_bg_color=>'#FFFFFF'
,p_prn_body_font_color=>'#000000'
,p_prn_body_font_family=>'Helvetica'
,p_prn_body_font_weight=>'normal'
,p_prn_body_font_size=>'10'
,p_prn_border_width=>.5
,p_prn_page_header_alignment=>'CENTER'
,p_prn_page_footer_alignment=>'CENTER'
,p_prn_border_color=>'#666666'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000231)
,p_query_column_id=>1
,p_column_alias=>'EMPLOYEE_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000232)
,p_query_column_id=>2
,p_column_alias=>'EMPLOYEE_LEGAL_FIRST_NAME'
,p_column_display_sequence=>20
,p_column_heading=>'First Name'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000233)
,p_query_column_id=>3
,p_column_alias=>'EMPLOYEE_LEGAL_LAST_NAME'
,p_column_display_sequence=>30
,p_column_heading=>'Last Name'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000234)
,p_query_column_id=>4
,p_column_alias=>'EMPLOYEE_NUMBER'
,p_column_display_sequence=>40
,p_column_heading=>'Employee Number'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000235)
,p_query_column_id=>5
,p_column_alias=>'USER_NAME'
,p_column_display_sequence=>50
,p_column_heading=>'Oracle User Name'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9700000000000236)
,p_query_column_id=>6
,p_column_alias=>'REVIEW_COMPLETE'
,p_column_display_sequence=>60
,p_column_heading=>'Review Complete'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
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
