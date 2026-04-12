*----------------------------------------------------------------------*
***INCLUDE LZFB_GMOD_GUI_PLANF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DO_NAVIGATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IO_NAVIGATION_DATA  text
*----------------------------------------------------------------------*
FORM do_navigation
      USING io_navigation_data TYPE REF TO cl_reca_data_container.

*  DATA:
*        LS_NAVIGATION_DATA TYPE RECA_WB_NAVIGATION,
*        LS_KEY_NAV         TYPE REAJ_TASKOBJ_NAVIGATION_KEY.
*
** INIT RESULTS
** no navigation expected
*  CLEAR GS_NAVIGATION_DATA.
*
** PRECONDITION
*  CHECK GO_NAVIGATION_DATA IS BOUND.
*
** BODY
** get single-navigation data from container
** (navigate to line/field which corresponds to error message
**  TABLENAME/FIELDNAME/CONTEXT of ls_navigation_data will be used)
*  CALL METHOD GO_NAVIGATION_DATA->GET
*    EXPORTING
*      ID_ID     = RECAW_DATA_ID-NAVIGATION
*    IMPORTING
*      EX_DATA   = LS_NAVIGATION_DATA
*    EXCEPTIONS
*      NOT_FOUND = 1
*      OTHERS    = 2.
*  IF ( SY-SUBRC = 0 ).
*    IF ( LS_NAVIGATION_DATA-TABLENAME CS 'ZPD_ZTGMOD_AUSST_X' ).
*      MOVE-CORRESPONDING LS_NAVIGATION_DATA                 "#EC ENHOK
*      TO GS_NAVIGATION_DATA.
*      LS_KEY_NAV-KEY = LS_NAVIGATION_DATA-CONTEXT.
*      MOVE-CORRESPONDING LS_KEY_NAV-KEY                     "#EC ENHOK
*      TO GS_NAVIGATION_DATA-KEY.
**     set tabstrip
**       plan tab
*      GS_NAVIGATION_DATA-TABSTRIP = GC_OK_CODE-TAB_FLACHE.
*    ENDIF.
*  ENDIF.


ENDFORM.                    " DO_NAVIGATION
*&---------------------------------------------------------------------*
*&      Form  PBO_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pbo_1000 .

ENDFORM.                    " PBO_1000
*&---------------------------------------------------------------------*
*&      Form  PAI_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_1000 .

ENDFORM.                    " PAI_1000
*&---------------------------------------------------------------------*
*&      Form  ON_ENTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM on_enter .
* local data
  DATA:
        ls_grid_data  LIKE LINE OF gt_grid_data.


  CHECK go_flache_mngr->md_activity <> reca1_activity-display.

  DATA ls_good   LIKE LINE OF go_changed_data_protocol->mt_good_cells.

  CHECK go_changed_data_protocol IS BOUND.


  LOOP AT go_changed_data_protocol->mt_good_cells INTO ls_good.
    READ TABLE gt_grid_data INTO ls_grid_data INDEX ls_good-row_id.


*      TRY.
*        LD_CHECK = LS_GRID_DATA-VALUE.
*      CATCH CX_SY_CONVERSION_NO_NUMBER  INTO LX_CONV_ERR.
*        MESSAGE I017(ZGMOD) WITH LD_TEXT  DISPLAY LIKE 'E'.
**         Ungültiger Wert für Feld '&1'.
*        RETURN.
*      CATCH CX_SY_CONVERSION_OVERFLOW INTO LX_CONV_ERR.
*        MESSAGE I018(ZGMOD) WITH  LD_TEXT  DISPLAY LIKE 'E'.
**         Wert für Feld &1 außerhalb des zulässigen Bereichs.
*        RETURN.
*      ENDTRY.



    go_flache_mngr->objektliste_change(
      EXPORTING
        is_list = ls_grid_data-zpd_ztexd_flache
      EXCEPTIONS
        error   = 1
        OTHERS  = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


  ENDLOOP.


  gs_gui_buffer-grid_do_get_data = abap_true.

  CLEAR go_changed_data_protocol.


ENDFORM.                    " ON_ENTER
*=======================================================================
FORM do_okcode.
*=======================================================================

  DATA: ld_ok_code TYPE sytcode.

* TRACE
  mac_trace 'OKCODE'.

  " Excel ausblenden
  gs_gui_buffer-grid_do_excel     = abap_false.

* get ok-code
  mac_bdt_get_okcode_subscreen ld_ok_code abap_true.

  CALL FUNCTION 'RECA_GUI_MSGLIST_INIT'.
  CALL FUNCTION 'RECA_GUI_MSGLIST_HIDE'.



  CHECK ld_ok_code IS NOT INITIAL.

*  CHECK GO_FLACHE_MNGR->MO_PARENT->MD_ACTIVITY <> RECA1_ACTIVITY-DISPLAY.


  CHECK: ld_ok_code = gc_ok_code-meas_anl      OR
         ld_ok_code = gc_ok_code-meas_anz      OR
         ld_ok_code = gc_ok_code-meas_upd      OR
         ld_ok_code = gc_ok_code-list_refresh  OR
         ld_ok_code = gc_ok_code-list_del      OR
         ld_ok_code = gc_ok_code-list_aend     OR
         ld_ok_code = gc_ok_code-excel_upl     OR
         ld_ok_code = gc_ok_code-excel_dow     OR
         ld_ok_code = 'SAVE'                   OR
         ld_ok_code = 'BACK'                   OR
         ld_ok_code = gc_ok_code-sap_update    OR
         ld_ok_code = gc_ok_code-set_ja        OR
         ld_ok_code = gc_ok_code-set_sofort    OR
         ld_ok_code = gc_ok_code-set_nein      OR
         ld_ok_code = gc_ok_code-set_info      OR
         ld_ok_code = gc_ok_code-set_pruefen .




*
* ok-code processing
  CASE ld_ok_code.
*   ---------------------------- enter (ordinary pai/pbo is processing)
    WHEN gc_ok_code-meas_anl.
      CLEAR ld_ok_code.
      PERFORM on_meas_anl.

**   --------------------------------------------- user commands of grid
    WHEN gc_ok_code-list_refresh.
      CLEAR ld_ok_code.
      PERFORM on_list_refresh.


    WHEN gc_ok_code-list_del.
      CLEAR ld_ok_code.
      PERFORM on_meas_del.


    WHEN gc_ok_code-list_aend.
      CLEAR ld_ok_code.
      PERFORM on_list_aend.


    WHEN gc_ok_code-meas_upd.
      CLEAR ld_ok_code.
      PERFORM on_meas_upd.

**   --------------------------------------------- user commands of grid

    WHEN gc_ok_code-meas_anz.
      CLEAR ld_ok_code.
      PERFORM on_meas_anz.

    WHEN 'SAVE' OR 'BACK'.
      PERFORM on_save USING ld_ok_code.
      CLEAR ld_ok_code.

    WHEN gc_ok_code-excel_upl.
      CLEAR ld_ok_code.
      PERFORM on_meas_upl.


    WHEN gc_ok_code-excel_dow.
      CLEAR ld_ok_code.
      PERFORM on_meas_dow.


    WHEN gc_ok_code-sap_update.
      CLEAR ld_ok_code.
      PERFORM on_sap_update.

    WHEN  gc_ok_code-set_ja        OR
          gc_ok_code-set_sofort    OR
          gc_ok_code-set_nein      OR
          gc_ok_code-set_info      OR
          gc_ok_code-set_pruefen.

      PERFORM on_massenpflege USING ld_ok_code.

      CLEAR ld_ok_code.

  ENDCASE.

** Sicht Rentabilitätsberechnung aktualisieren
*  CALL FUNCTION 'ZFB_GMOD_GUI_RENT_NFC' .
*  CALL FUNCTION 'ZFB_GMOD_GUI_SA_RENT_NFC' .

* reset ok-code
  mac_bdt_set_okcode_subscreen ld_ok_code abap_true.

ENDFORM.                    "do_okcode
*&---------------------------------------------------------------------*
*&      Form  GRID_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM grid_get_data .

  DATA:
    lt_grid_data_new LIKE gt_grid_data[],
    lt_grid_data_old LIKE gt_grid_data[],
    ls_grid_data     LIKE LINE OF gt_grid_data.

  FIELD-SYMBOLS:
  <ls_grid_data>   LIKE LINE OF gt_grid_data.

* BODY
* get old grid data, but ignore current selection (icon)
  lt_grid_data_old[] = gt_grid_data[].
  CLEAR ls_grid_data.
  MODIFY lt_grid_data_old FROM ls_grid_data TRANSPORTING icon_detail
  WHERE icon_detail IS NOT INITIAL.
  SORT lt_grid_data_old BY key.

* build local grid data without current selection
  IF ( gs_gui_buffer-grid_do_get_data = abap_true ).

*   requery
    PERFORM grid_build_data
    CHANGING lt_grid_data_new.

*   sort by sequential number
    SORT lt_grid_data_new       BY key.

*   read only once in display mode within the same business object
    IF ( gd_activity = reca1_activity-display ).
      gs_gui_buffer-grid_do_get_data = abap_false.
    ENDIF.

*   optimize column width on change
    IF ( lt_grid_data_new[] <> lt_grid_data_old[] ).
      gs_gui_buffer-grid_do_refresh   = abap_true.
      gs_gui_buffer-grid_do_cwidthopt = abap_true.
    ENDIF.

  ELSE.

*   get data of previous read
    lt_grid_data_new[] = lt_grid_data_old[].

  ENDIF.

* set icon to mark row; if necessary adapt current index
  IF ( lt_grid_data_new IS INITIAL ).
    CLEAR gs_gui_buffer-current_key.
  ELSE.
*   get row to set icon
    READ TABLE lt_grid_data_new ASSIGNING <ls_grid_data>
    WITH KEY key = gs_gui_buffer-current_key.
    IF   sy-subrc <> 0
    OR gs_gui_buffer-current_key IS INITIAL.
*     invalid index - set to 1st row
      READ TABLE lt_grid_data_new INDEX 1
      ASSIGNING <ls_grid_data>.
      gs_gui_buffer-current_key = <ls_grid_data>-key.
    ENDIF.

*    <LS_GRID_DATA>-ICON_DETAIL = CL_RECA_GUI_ALV_SERVICES=>MD_ICON_MARK.
*
**   set quickinfo for non-marked rows
*    LS_GRID_DATA-ICON_DETAIL = CL_RECA_GUI_ALV_SERVICES=>MD_ICON_NOMARK.
    MODIFY lt_grid_data_new FROM ls_grid_data TRANSPORTING icon_detail
    WHERE icon_detail IS INITIAL.
  ENDIF.

* refresh grid data? (compare with selection)
  IF ( gs_gui_buffer-grid_do_refresh = abap_true ) OR
  ( gt_grid_data[] <> lt_grid_data_new[]        ).
    gt_grid_data[] = lt_grid_data_new[].
    gs_gui_buffer-grid_do_refresh = abap_true.
  ENDIF.

ENDFORM.                    " GRID_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  GRID_BUILD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_GRID_DATA_NEW  text
*----------------------------------------------------------------------*
FORM grid_build_data
  CHANGING et_grid_data_new LIKE gt_grid_data[].


  CHECK go_flache_mngr IS BOUND.

* sollen Default Warengruppen gelesen werden?
  IF  go_flache_mngr->count( ) = 0.
    RETURN.
  ENDIF.



* GET List
  go_flache_mngr->get_list_x(
    IMPORTING
      et_list_x = et_grid_data_new
         ).



  " Filter für Änderungshistorie
  IF  gd_anwactivity = 'MEAS_HELP_1' .
    DELETE et_grid_data_new WHERE me_update_flag = abap_false.
  ELSE.
    IF ( gd_anwactivity = 'MEAS_AEND' AND sy-ucomm <> 'SAP_UPDATE' ).
      DELETE et_grid_data_new WHERE me_update_flag = abap_true.
    ENDIF.
  ENDIF.

ENDFORM.                    " GRID_BUILD_DATA


*=======================================================================
FORM grid_refresh.
*=======================================================================

  STATICS:
    ss_stable TYPE lvc_s_stbl,
    ss_row_no TYPE lvc_s_roid.

* BODY
* check, if grid-control must be created
  IF ( go_grid IS NOT BOUND ) OR
  ( go_grid->is_alive( ) <>
  cl_gui_control=>state_alive ).

    PERFORM grid_create.

  ELSE.

*   optimize column width
    IF ( gs_gui_buffer-grid_do_cwidthopt = abap_true ) AND
    ( gs_gui_buffer-grid_do_refresh   = abap_true ).

      CALL METHOD cl_reca_gui_alv_services=>set_layout_cwidth_opt
        EXPORTING
          io_grid = go_grid.

    ENDIF.

*   refresh toolbar without refreshing entire grid
    IF ( gs_gui_buffer-grid_do_toolbar = abap_true  ) AND
    ( gs_gui_buffer-grid_do_refresh = abap_false ).

      go_grid->set_toolbar_interactive( ).

    ENDIF.

*   refresh grid
    IF gs_gui_buffer-grid_do_refresh = abap_true.

*     hold current cursor position?
      IF gs_gui_buffer-grid_do_init_pos = abap_true.
        CLEAR ss_stable.
      ELSE.
        ss_stable-row = abap_true.
        ss_stable-col = abap_true.
      ENDIF.

*     refresh data
      mac_trace_alv_call.
      CALL METHOD go_grid->refresh_table_display
        EXPORTING
          is_stable = ss_stable.

**     set current cell
*      PERFORM CURRENT_ROW_GET CHANGING SS_ROW_NO-ROW_ID.
*      IF SS_ROW_NO-ROW_ID > 0.
*        CALL METHOD GO_GRID->SET_CURRENT_CELL_VIA_ID
*          EXPORTING
*            IS_ROW_NO = SS_ROW_NO.
*      ENDIF.

    ENDIF.

  ENDIF.

* reset all display properties
  gs_gui_buffer-grid_do_cwidthopt = abap_false.
  gs_gui_buffer-grid_do_refresh   = abap_false.
  gs_gui_buffer-grid_do_init_pos  = abap_false.
  gs_gui_buffer-grid_do_toolbar   = abap_false.

ENDFORM.                    "grid_refresh


*=======================================================================
FORM grid_create.
*=======================================================================

  DATA:
    lt_fieldcatalog      TYPE lvc_t_fcat,
    lt_toolbar_excluding TYPE ui_functions,
    lt_sort              TYPE lvc_t_sort,
    ls_layout            TYPE lvc_s_layo,
    ls_variant           TYPE disvariant,
    ls_sort              LIKE LINE OF lt_sort,
    lt_qinfo             TYPE lvc_t_qinf,
    ls_qinfo             TYPE lvc_s_qinf,
    ld_type              TYPE reajadjmtasktype,
    ld_handle            TYPE slis_handl.
  DATA rs_detail_mv TYPE recn_contract.
  DATA: lt_f4                TYPE lvc_t_f4.

* 0. free grid-control, if control is not alive any more
  IF ( go_grid IS BOUND ).
    go_grid->free( ).
    go_container_grid->free( ).
  ENDIF.

* 1. field catalog
  IF  gs_gui_buffer-grid_do_excel_dow       = abap_true AND
      gs_gui_buffer-grid_do_excel           = abap_true.
    PERFORM grid_create_fieldcat_excel
    CHANGING lt_fieldcatalog.
  ELSE.
    PERFORM grid_create_fieldcat
    CHANGING lt_fieldcatalog.
  ENDIF.

* 2. create container
  CREATE OBJECT go_container_grid
    EXPORTING
      container_name = 'CC_ZTEXD_FLACHE_GRID'.
  mac_assert_ref go_container_grid.

* 3. create alv grid control
  CREATE OBJECT go_grid
    EXPORTING
      i_parent      = go_container_grid
      i_appl_events = abap_false.
  mac_assert_ref go_grid.

* 4. register event receiver
  SET HANDLER:
  lcl_event_receiver=>handle_toolbar        FOR go_grid,
  lcl_event_receiver=>handle_user_command   FOR go_grid,
  lcl_event_receiver=>handle_menu_button    FOR go_grid,
  lcl_event_receiver=>handle_hotspot_click  FOR go_grid,
  lcl_event_receiver=>handle_double_click   FOR go_grid,
  lcl_event_receiver=>handle_data_changed   FOR go_grid,
  lcl_event_receiver=>handle_onf4           FOR go_grid.

* 4.a F4-Behandlung für Felder registrieren
  PERFORM get_f4_fields CHANGING lt_f4.

  go_grid->register_f4_for_fields( it_f4 = lt_f4 ).

* 5. layout
  CALL METHOD go_grid->get_frontend_layout
    IMPORTING
      es_layout = ls_layout.

  ls_layout-cwidth_opt = abap_true.
  ls_layout-sel_mode   = 'A'.
  ls_layout-no_rowmark = abap_false.
  IF gf_gridonly = abap_true.
*    LS_LAYOUT-NO_TOOLBAR = ABAP_TRUE.
  ELSE.
    ls_layout-no_toolbar = abap_false.
  ENDIF.
  ls_layout-smalltitle = abap_false.
  ls_layout-ctab_fname = 'COLORTAB'.
  ls_layout-stylefname = 'STYLETAB'.


  ls_variant-log_group = 'EXME'.

* 6. default variant
  ls_variant-report   = sy-repid.
  ls_variant-handle   = ld_handle.
  ls_variant-username = sy-uname.

* macro
  ls_sort-spos = 1.
  DEFINE mac_append_sort.
    ls_sort-spos = ls_sort-spos + 1.
    ls_sort-fieldname = &1.
    ls_sort-up        = abap_false.
    ls_sort-down      = abap_true.
    ls_sort-subtot    = &2.
    APPEND ls_sort TO lt_sort.
  END-OF-DEFINITION.

* 8. sorting
*  MAC_APPEND_SORT 'CITY1'    ABAP_TRUE.
*  MAC_APPEND_SORT 'CITY2'    ABAP_TRUE.
*  MAC_APPEND_SORT 'HEIZGRUP' ABAP_FALSE.

* 9. toolbar exclusions
  PERFORM grid_create_toolbar_excluding
  CHANGING lt_toolbar_excluding.

* 10. color info
  CLEAR lt_qinfo.
  ls_qinfo-type = cl_salv_tooltip=>c_type_color.
  ls_qinfo-value = '500'.
  ls_qinfo-text = TEXT-500 ##TEXT_POOL.
  APPEND ls_qinfo TO lt_qinfo.
  ls_qinfo-value = '300'.
  ls_qinfo-text = TEXT-300 ##TEXT_POOL.
  APPEND ls_qinfo TO lt_qinfo.
  ls_qinfo-value = '310'.
  ls_qinfo-text = TEXT-310 ##TEXT_POOL.
  APPEND ls_qinfo TO lt_qinfo.
  ls_qinfo-value = '410'.
  ls_qinfo-text = TEXT-410 ##TEXT_POOL.
  APPEND ls_qinfo TO lt_qinfo.
  ls_qinfo-value = '201'.
  ls_qinfo-text = TEXT-201 ##TEXT_POOL.
  APPEND ls_qinfo TO lt_qinfo.
  ls_qinfo-value = '211'.
  ls_qinfo-text = TEXT-201 ##TEXT_POOL.
  APPEND ls_qinfo TO lt_qinfo.

* 11. each return results in an event
  IF gd_activity <> reca1_activity-display.
    CALL METHOD go_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.
  ENDIF.

* 12. first display (with filled outtab)
  mac_trace_alv_call.
  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      i_buffer_active      = ' '
      i_bypassing_buffer   = 'X'
      i_consistency_check  = ' '
      is_variant           = ls_variant
      i_save               = 'A'
      i_default            = 'X'
      is_layout            = ls_layout
      it_except_qinfo      = lt_qinfo
      it_toolbar_excluding = lt_toolbar_excluding
    CHANGING
      it_outtab            = gt_grid_data
      it_fieldcatalog      = lt_fieldcatalog
      it_sort              = lt_sort.

ENDFORM.                    "grid_create
*&---------------------------------------------------------------------*
*&      Form  GRID_CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_FIELDCATALOG  text
*----------------------------------------------------------------------*
FORM grid_create_fieldcat
     CHANGING et_fieldcatalog TYPE lvc_t_fcat.

  mac_alv_fc_init et_fieldcatalog.

* get default fieldcatalog via structure
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_buffer_active    = abap_false
      i_structure_name   = 'ZPD_ZTEXD_FLACHE_X'
      i_bypassing_buffer = abap_true
    CHANGING
      ct_fieldcat        = et_fieldcatalog.




  LOOP AT et_fieldcatalog ASSIGNING <ls_fieldcatalog>.

    CASE <ls_fieldcatalog>-fieldname.
*       Ausblenden Tech.
      WHEN
              'COLORTAB'       OR
              'STYLETAB'       OR
              'ME_UPDATE_FLAG' OR
              'SNUNR'          OR
              'IDENT'          OR
              'OBJNR'          OR
              'MEAS_GUID'      OR
              'RERF'           OR
              'DERF'           OR
              'TERF'           OR
              'REHER'          OR
              'RBEAR'          OR
              'DBEAR'          OR
              'TBEAR'          OR
              'RBHER'          OR
              'REFRESH_OBJ'    OR
              'ADRNR'          OR
              'ADRZUS'         OR
              'COUNTRY'        OR
              'REGION'         OR
              'MSGNUMBER'      .

        <ls_fieldcatalog>-tech   = abap_true.

        " Ausblenden NO_OUT
      WHEN 'KDST'.
        <ls_fieldcatalog>-no_out   = abap_true.
        " Set Eigenschaften
      WHEN 'ME_UPDATE'.
        mac_alv_fc_set_text 'Updateinfo' ##NO_TEXT.
      WHEN 'DIENSTLEISTUNG'.
        <ls_fieldcatalog>-key        = abap_true.
        <ls_fieldcatalog>-key_sel    = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.
      WHEN 'MEAS'.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.
      WHEN 'BUKRS'.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.
      WHEN 'SWENR'.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.
        <ls_fieldcatalog>-hotspot    = abap_true.
      WHEN 'SGRNR'.
        <ls_fieldcatalog>-fix_column = abap_true.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-hotspot    = abap_true.
        <ls_fieldcatalog>-no_out   = abap_true.
      WHEN 'SGENR'.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.
        <ls_fieldcatalog>-hotspot    = abap_true.
      WHEN 'SMENR'.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.
        <ls_fieldcatalog>-hotspot    = abap_true.
      WHEN 'MEASVALUE'.
        <ls_fieldcatalog>-emphasize = 'C100'.
      WHEN 'MEASUNIT'.
        <ls_fieldcatalog>-emphasize = 'C100'.
      WHEN 'MEASVALIDTO'.
        <ls_fieldcatalog>-emphasize = 'C100'.
      WHEN 'AKTIVITAET'.
        IF gs_gui_buffer-grid_do_change = abap_true.
          <ls_fieldcatalog>-edit      = abap_true.
        ELSE.
          <ls_fieldcatalog>-emphasize = 'C500'.
        ENDIF.
      WHEN 'MEASVALUE_NEU'.
        mac_alv_fc_set_text 'Größe neu' ##NO_TEXT.
        IF gs_gui_buffer-grid_do_change = abap_true.
          <ls_fieldcatalog>-edit      = abap_true.
        ELSE.
          <ls_fieldcatalog>-emphasize = 'C500'.
        ENDIF.
      WHEN 'MEASUNIT_NEU'.
        mac_alv_fc_set_text 'Einh neu' ##NO_TEXT.
        <ls_fieldcatalog>-emphasize = 'C500'.
      WHEN 'MEASVALIDFROM'.
        mac_alv_fc_set_text 'Gültig ab neu' ##NO_TEXT.
        <ls_fieldcatalog>-emphasize = 'C500'.
      WHEN 'EXT_FERTDAT'.
        mac_alv_fc_set_text 'Umsetzung per' ##NO_TEXT.
        IF gs_gui_buffer-grid_do_change = abap_true.
          <ls_fieldcatalog>-edit      = abap_true.
        ELSE.
          <ls_fieldcatalog>-emphasize = 'C500'.
        ENDIF.
      WHEN   'XKSNUNR'.
        mac_alv_fc_set_text 'Nutzungsart' ##NO_TEXT.
      WHEN 'ICON_DETAIL'.
        mac_alv_fc_set_text 'Status' ##NO_TEXT.
        <ls_fieldcatalog>-fix_column = abap_true.
        <ls_fieldcatalog>-icon       = abap_true.
        <ls_fieldcatalog>-hotspot    = abap_true.
      WHEN 'ZCOUNT'.
        <ls_fieldcatalog>-do_sum = abap_true.

      WHEN 'BELEGUNG_ICON'.
        <ls_fieldcatalog>-icon       = abap_true.
        mac_alv_fc_set_text 'Belegung' ##NO_TEXT.

      WHEN 'NAME_ORG1DBT'.
        mac_alv_fc_set_text 'Name1 Org.' ##NO_TEXT.

      WHEN 'NAME_ORG2DBT'.
        mac_alv_fc_set_text 'Name2 Org.' ##NO_TEXT.

      WHEN 'BEMERKUNG_KOM'.
        IF gs_gui_buffer-grid_do_change = abap_true.
          <ls_fieldcatalog>-edit      = abap_true.
        ENDIF.
      WHEN 'BEMERKUNG_LIEFERANT'.
*        IF GS_GUI_BUFFER-GRID_DO_CHANGE = ABAP_TRUE.
*          <LS_FIELDCATALOG>-EDIT      = ABAP_TRUE.
*        ELSE.
        <ls_fieldcatalog>-emphasize = 'C500'.
*        ENDIF.

      WHEN 'PLBEG_FROM'.
        mac_alv_fc_set_text 'Begehung' ##NO_TEXT.

    ENDCASE.

  ENDLOOP.


  mac_alv_fc_pos_set:
    'ICON_DETAIL',
    'DIENSTLEISTUNG',
    'MEAS',
    'BUKRS',
    'SWENR',
    'SGRNR',
    'SGENR',
    'SMENR',
    'KDST',
    'VALIDTO',
    'XKSNUNR',
    'ZCOUNT',
    'STICHTAG',
    'BEMERKUNG_KOM',
    'EXT_DIENSTLIF',
    'EXT_AENDGRUND',
    'PROJEKTNAME',
    'IDENT',
    'XSMEAS',
    'MEASVALUE',
    'MEASUNIT',
    'MEASVALIDTO',
    'AKTIVITAET',
    'EXT_FERTDAT',
    'MEASVALUE_NEU',
    'MEASUNIT_NEU',
    'MEASVALIDFROM',
    'BEMERKUNG_LIEFERANT',
    'ME_UPDATE',
    'ABWEICHUNG_M2',
    'ABWEICHUNG_PROZ',
    'AUFTR_VERM'.


ENDFORM.                    " GRID_CREATE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  GRID_CREATE_FIELDCAT_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ET_FIELDCATALOG  text
*----------------------------------------------------------------------*
FORM grid_create_fieldcat_excel
     CHANGING et_fieldcatalog TYPE lvc_t_fcat.

  mac_alv_fc_init et_fieldcatalog.


* get default fieldcatalog via structure
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_buffer_active    = abap_false
      i_structure_name   = 'ZPD_ZTEXD_FLACHE_X'
      i_bypassing_buffer = abap_true
    CHANGING
      ct_fieldcat        = et_fieldcatalog.




  LOOP AT et_fieldcatalog ASSIGNING <ls_fieldcatalog>.

    CASE <ls_fieldcatalog>-fieldname.
*       Ausblenden Tech.
      WHEN
              'COLORTAB'       OR
              'STYLETAB'       OR
              'ME_UPDATE_FLAG' OR
              'SNUNR'          OR
              'IDENT'          OR
              'OBJNR'          OR
              'RERF'           OR
              'DERF'           OR
              'TERF'           OR
              'REHER'          OR
              'RBEAR'          OR
              'DBEAR'          OR
              'TBEAR'          OR
              'RBHER'          OR
              'REFRESH_OBJ'    OR
              'ADRNR'          OR
              'ADRZUS'         OR
              'COUNTRY'        OR
              'REGION'         OR
              'ME_UPDATE'      OR
              'KDST'           OR
              'MSGNUMBER'      OR
              'STICHTAG'       OR
              'EXCEL_FLAG'     OR
              'ICON_DETAIL'    OR
              'BELEGUNG_ICON'  OR
              'INFO_VERWALTER' OR
              'DIENSTLEISTUNG' OR
              'ABWEICHUNG_M2'  OR
              'ABWEICHUNG_PROZ' OR

*              'NAME_ORG1DBT'   OR
*              'NAME_ORG2DBT'   OR
*              'NAME_LASTDBT'   OR
*              'NAME_FIRSTDBT'  OR
*              'POST_CODE1DBT'  OR
*              'CITY1DBT'       OR
*              'CITY2DBT'       OR
*              'STREETDBT'      OR
*              'HOUSE_NUM1DBT'  OR
              'INFO_VERWALTER' OR
              'MSGNUMBER'      OR
              'ICON_DETAIL'    OR
              'REFRESH_OBJ'    OR
*              'BEMERKUNG_LIEFERANT' OR
              'BEMERKUNG_KOM'  OR
              'XROLE'          OR
              'XNAME'          OR
              'TEL_NUMBER_LONG' OR
              'FAX_NUMBER_LONG' OR
              'SMTP_ADDR'      OR
              'FINART'         OR
              'XFIXFITCHARACT' OR
              'YBAUJAHR'       OR
              'ZCOUNT'.

        <ls_fieldcatalog>-tech   = abap_true.

*      WHEN 'DIENSTLEISTUNG'.
*        <LS_FIELDCATALOG>-KEY        = ABAP_TRUE.
*        <LS_FIELDCATALOG>-KEY_SEL    = ABAP_TRUE.
*        <LS_FIELDCATALOG>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'MEAS'.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.
      WHEN 'BUKRS'.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.
      WHEN 'SWENR'.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.
        <ls_fieldcatalog>-hotspot    = abap_true.
      WHEN 'SGRNR'.
        <ls_fieldcatalog>-fix_column = abap_true.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-hotspot    = abap_true.
      WHEN 'SGENR'.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.
        <ls_fieldcatalog>-hotspot    = abap_true.
      WHEN 'SMENR'.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.
        <ls_fieldcatalog>-hotspot    = abap_true.
      WHEN 'MEASVALUE'.
        <ls_fieldcatalog>-emphasize = 'C100'.
      WHEN 'MEASUNIT'.
        <ls_fieldcatalog>-emphasize = 'C100'.
      WHEN 'MEASVALIDTO'.
        <ls_fieldcatalog>-emphasize = 'C100'.
      WHEN 'AKTIVITAET'.
        <ls_fieldcatalog>-emphasize = 'C500'.
      WHEN 'MEASVALUE_NEU'.
        mac_alv_fc_set_text 'Größe neu' ##NO_TEXT.
        <ls_fieldcatalog>-emphasize = 'C500'.
      WHEN 'MEASUNIT_NEU'.
        mac_alv_fc_set_text 'Einh neu' ##NO_TEXT.
        <ls_fieldcatalog>-emphasize = 'C500'.
      WHEN 'MEASVALIDFROM'.
        mac_alv_fc_set_text 'Gültig ab neu' ##NO_TEXT.
        <ls_fieldcatalog>-emphasize = 'C500'.
      WHEN 'EXT_FERTDAT'.
        mac_alv_fc_set_text 'Umsetzung per' ##NO_TEXT.
        <ls_fieldcatalog>-emphasize = 'C500'.
      WHEN   'XKSNUNR'.
        mac_alv_fc_set_text 'Nutzungsart' ##NO_TEXT.
*      WHEN 'ICON_DETAIL'.
*        MAC_ALV_FC_SET_TEXT 'Status' ##NO_TEXT.
*        <LS_FIELDCATALOG>-FIX_COLUMN = ABAP_TRUE.
*        <LS_FIELDCATALOG>-ICON       = ABAP_TRUE.
*        <LS_FIELDCATALOG>-HOTSPOT    = ABAP_TRUE.
*      WHEN 'ZCOUNT'.
*        <LS_FIELDCATALOG>-DO_SUM = ABAP_TRUE.
*
*      WHEN 'BELEGUNG_ICON'.
*        <LS_FIELDCATALOG>-ICON       = ABAP_TRUE.
*        MAC_ALV_FC_SET_TEXT 'Belegung' ##NO_TEXT.

      WHEN 'MEAS_GUID'.
        mac_alv_fc_set_text 'ObjektKey' ##NO_TEXT.
        <ls_fieldcatalog>-key     = abap_true.
        <ls_fieldcatalog>-fix_column = abap_true.

      WHEN 'BEMERKUNG_LIEFERANT'.
        <ls_fieldcatalog>-emphasize = 'C500'.

    ENDCASE.

  ENDLOOP.


  mac_alv_fc_pos_set:
    'MEAS_GUID',
    'POST_CODE1',
    'CITY1',
    'CITY2',
    'STREET',
    'HOUSE_NUM1',
    'XSTOCKM',
    'XKLGESCH',
    'XKSNUNR',
    'PROJEKTNAME',
    'EXT_DIENSTLIF',
    'EXT_AENDGRUND',
    'AUFTR_VERM',
    'MEAS',
    'XSMEAS',
    'MEASVALUE',
    'MEASUNIT',
    'MEASVALIDTO',
    'AKTIVITAET',
    'EXT_FERTDAT',
    'BEMERKUNG_LIEFERANT',
    'MEASVALUE_NEU',
    'MEASUNIT_NEU',
    'MEASVALIDFROM',
    'DMIBEG_AKTUELL',
    'SMIVE_AKTUELL',
    'RECNENDABS',
    'NAME_ORG1DBT',
    'NAME_ORG2DBT',
    'NAME_LASTDBT',
    'NAME_FIRSTDBT',
    'POST_CODE1DBT',
    'CITY1DBT',
    'CITY2DBT',
    'STREETDBT',
    'HOUSE_NUM1DBT',
    'ME_STATUS',
    'BUKRS',
    'SWENR',
    'SGRNR',
    'SGENR',
    'SMENR'.


ENDFORM.                    " GRID_CREATE_FIELDCAT_EXCEL
*&---------------------------------------------------------------------*
*&      Form  ON_HELP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM on_help .
* local data
  DATA:
        ld_docname(30) TYPE c.

  CHECK 1 = 2.

* set doc name
  ld_docname = 'REAJ_ADJMTASK_OBJ_HELP'.
*  IF GO_ADJM_TASK->IS_CEA_ADJMTASK( ) = ABAP_TRUE.
*    LD_DOCNAME = 'REAJ_ADJMTASK_OBJ_CEA_HELP'.
*  ENDIF.

* display help popup
  CALL FUNCTION 'RECA_GUI_HELP_POPUP'
    EXPORTING
      id_docname    = ld_docname
    EXCEPTIONS
      doc_not_found = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    mac_symsg_send_as_type 'I'.
    RETURN.
  ENDIF.

ENDFORM.                    " ON_HELP
*&---------------------------------------------------------------------*
*&      Form  CURRENT_ROW_GET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_SS_ROW_NO_ROW_ID  text
*----------------------------------------------------------------------*
FORM current_row_get
CHANGING ed_index TYPE numeric.

* BODY
  READ TABLE gt_grid_data TRANSPORTING NO FIELDS
  WITH KEY key = gs_gui_buffer-current_key.
  "no binary search!!!
  IF sy-subrc = 0.
    ed_index = sy-tabix.
  ELSE.
    CLEAR ed_index.
  ENDIF.

ENDFORM.                    " CURRENT_ROW_GET
*&---------------------------------------------------------------------*
*&      Form  CURRENT_ROW_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_INDEX  text
*----------------------------------------------------------------------*
FORM current_row_set
USING VALUE(id_index) TYPE numeric.

* local data
  DATA:
    ls_grid_data LIKE LINE OF gt_grid_data,
    lf_costspos  TYPE recabool.

* clear grid data
  CLEAR gs_grid_data.


* BODY
  READ TABLE gt_grid_data INDEX id_index INTO ls_grid_data.
  IF sy-subrc = 0.
    gs_gui_buffer-current_key = ls_grid_data-key.
    gs_grid_data              = ls_grid_data.
  ELSE.
    CLEAR gs_gui_buffer-current_key.
  ENDIF.

ENDFORM.                    " CURRENT_ROW_SET
*&---------------------------------------------------------------------*
*&      Form  OBJEKT_NAVIGATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE           text
*      -->(ID_FIELDNAME)  text
*      -->VALUE           text
*      -->(ID_INDEX)      text
*----------------------------------------------------------------------*
FORM objekt_navigation
     USING VALUE(id_fieldname) TYPE fieldname
           VALUE(id_index)     TYPE numeric.

* local data
  DATA:
        ls_grid_data LIKE LINE OF gt_grid_data.
  DATA: ls_immo_key   TYPE zsvimi01_key,
        ld_objnr      TYPE recaobjnr,
        ls_navigation TYPE reca_wb_navigation.



* BODY
  READ TABLE gt_grid_data INDEX id_index INTO ls_grid_data.
  CHECK sy-subrc = 0.

  CASE id_fieldname.
    WHEN 'SWENR' .
      CLEAR ls_navigation.

* Quick Fix Replace this statement by a SELECT statement with ORDER BY
* 30.04.2024 09:37:31 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*      SELECT SINGLE OBJNR FROM VIBDBE INTO LD_OBJNR WHERE BUKRS = LS_GRID_DATA-BUKRS
*                                                      AND SWENR = LS_GRID_DATA-SWENR.

      SELECT objnr FROM vibdbe INTO ld_objnr UP TO 1 ROWS WHERE bukrs = ls_grid_data-bukrs
       AND swenr = ls_grid_data-swenr
       ORDER BY PRIMARY KEY .
      ENDSELECT.
* End of Quick Fix

      ls_navigation-gotofirstscreen = abap_true.

      CALL FUNCTION 'RECA_GUI_BUSOBJ_APPL'
        EXPORTING
          id_activity          = reca1_activity-display
          id_objtype           = ld_objnr(2)
          id_objnr             = ld_objnr
          is_navigation_data   = ls_navigation
          if_new_internal_mode = abap_true
        EXCEPTIONS
          OTHERS               = 0.

    WHEN  'SGENR'.
      CLEAR ls_navigation.
      ls_navigation-gotofirstscreen = abap_true.


* Quick Fix Replace this statement by a SELECT statement with ORDER BY
* 30.04.2024 09:37:31 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*      SELECT SINGLE OBJNR FROM VIBDBU INTO LD_OBJNR WHERE BUKRS = LS_GRID_DATA-BUKRS
*                                                      AND SWENR = LS_GRID_DATA-SWENR
*                                                      AND SGENR = LS_GRID_DATA-SGENR.

      SELECT objnr FROM vibdbu INTO ld_objnr UP TO 1 ROWS WHERE bukrs = ls_grid_data-bukrs
       AND swenr = ls_grid_data-swenr AND sgenr = ls_grid_data-sgenr
       ORDER BY PRIMARY KEY .
      ENDSELECT.
* End of Quick Fix

      ls_navigation-gotofirstscreen = abap_true.

      CALL FUNCTION 'RECA_GUI_BUSOBJ_APPL'
        EXPORTING
          id_activity          = reca1_activity-display
          id_objtype           = ld_objnr(2)
          id_objnr             = ld_objnr
          is_navigation_data   = ls_navigation
          if_new_internal_mode = abap_true
        EXCEPTIONS
          OTHERS               = 0.

    WHEN  'SMENR'.
      CLEAR ls_navigation.
      ls_navigation-gotofirstscreen = abap_true.


* Quick Fix Replace this statement by a SELECT statement with ORDER BY
* 30.04.2024 09:37:31 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*      SELECT SINGLE OBJNR FROM VIBDRO INTO LD_OBJNR WHERE BUKRS = LS_GRID_DATA-BUKRS
*                                                      AND SWENR = LS_GRID_DATA-SWENR
*                                                      AND SMENR = LS_GRID_DATA-SMENR.

      SELECT objnr FROM vibdro INTO ld_objnr UP TO 1 ROWS WHERE bukrs = ls_grid_data-bukrs
       AND swenr = ls_grid_data-swenr AND smenr = ls_grid_data-smenr
       ORDER BY PRIMARY KEY .
      ENDSELECT.
* End of Quick Fix

      ls_navigation-gotofirstscreen = abap_true.

      CALL FUNCTION 'RECA_GUI_BUSOBJ_APPL'
        EXPORTING
          id_activity          = reca1_activity-display
          id_objtype           = ld_objnr(2)
          id_objnr             = ld_objnr
          is_navigation_data   = ls_navigation
          if_new_internal_mode = abap_true
        EXCEPTIONS
          OTHERS               = 0.

    WHEN 'SMIVE_AKTUELL'.



* Quick Fix Replace this statement by a SELECT statement with ORDER BY
* 30.04.2024 09:37:31 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*      SELECT SINGLE OBJNR FROM VICNCN INTO LD_OBJNR WHERE BUKRS  = LS_GRID_DATA-BUKRS
*                                                      AND RECNNR = LS_GRID_DATA-SMIVE_AKTUELL.

      SELECT objnr FROM vicncn INTO ld_objnr UP TO 1 ROWS WHERE bukrs = ls_grid_data-bukrs
       AND recnnr = ls_grid_data-smive_aktuell
       ORDER BY PRIMARY KEY .
      ENDSELECT.
* End of Quick Fix

      IF sy-subrc = 0.
*            LS_NAVIGATION-GOTOFIRSTSCREEN = ABAP_TRUE.
        ls_navigation-dynid = 'REGC41'.
        CALL FUNCTION 'RECA_GUI_BUSOBJ_APPL'
          EXPORTING
            id_activity          = reca1_activity-display
            id_objtype           = ld_objnr(2)
            id_objnr             = ld_objnr
            is_navigation_data   = ls_navigation
            if_new_internal_mode = abap_true
          EXCEPTIONS
            OTHERS               = 0.

*           get data and refresh
        gs_gui_buffer-grid_do_get_data  = abap_true.
        gs_gui_buffer-grid_do_refresh   = abap_true.

      ENDIF.

*        WHEN-OTHERS.

  ENDCASE.
ENDFORM.                    "objekt_navigation

*&---------------------------------------------------------------------*
*&      Form  GRID_CREATE_TOOLBAR_EXCLUDING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_TOOLBAR_EXCLUDING  text
*----------------------------------------------------------------------*
FORM grid_create_toolbar_excluding
CHANGING et_toolbar_excluding TYPE ui_functions.

  DATA:
    ls_toolbar_excluding LIKE LINE OF et_toolbar_excluding,
    lf_sort_enable       TYPE recabool VALUE abap_false.

  DEFINE mac_add_tb_excl.
    ls_toolbar_excluding = &1.
    APPEND ls_toolbar_excluding TO et_toolbar_excluding.
  END-OF-DEFINITION.

* INIT RESULTS
  CLEAR et_toolbar_excluding.

*  MAC_ADD_TB_EXCL CL_GUI_ALV_GRID=>MC_FC_LOAD_VARIANT   .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_refresh.
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_loc_append_row .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_loc_copy       .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_loc_copy_row   .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_loc_cut        .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_loc_delete_row .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_loc_insert_row .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_loc_move_row   .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_loc_paste      .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_loc_paste_new_row .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_loc_undo        .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_print           .
  mac_add_tb_excl cl_gui_alv_grid=>mc_mb_subtot          .
  mac_add_tb_excl cl_gui_alv_grid=>mc_mb_sum             .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_graph           .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_help            .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_find            .
  mac_add_tb_excl cl_gui_alv_grid=>mc_fc_info            .



ENDFORM.                    " GRID_CREATE_TOOLBAR_EXCLUDING
*&---------------------------------------------------------------------*
*&      Form  GRID_NEW_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM grid_new_fieldcat .
* clear grid and container (for new fieldcatalog)
  IF go_grid IS BOUND.
    go_grid->free( ).
    CLEAR go_grid.
  ENDIF.
  IF go_container_grid IS BOUND.
    go_container_grid->free( ).
    CLEAR go_container_grid.
  ENDIF.

* get data and refresh
  gs_gui_buffer-grid_do_get_data  = abap_true.
  gs_gui_buffer-grid_do_refresh   = abap_true.
  gs_gui_buffer-grid_do_cwidthopt = abap_true.
  gs_gui_buffer-grid_do_init_pos  = abap_true.
  gs_gui_buffer-grid_do_toolbar   = abap_true.
  gs_gui_buffer-grid_do_excel     = abap_false.
  gs_gui_buffer-grid_do_excel_dow  = abap_false.
  gs_gui_buffer-grid_do_excel_upl  = abap_false.

ENDFORM.                    " GRID_NEW_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  ON_ADD_flache
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM on_meas_anl .

  DATA: ls_detail_x LIKE LINE OF gt_grid_data.

  DATA: ls_tabix TYPE sytabix,
        dummy    TYPE string.
  DATA:  id_userkz    TYPE zuserkz.
  DATA:  lt_guid      TYPE re_t_guid.

***********'MEAS_ANL' *************************
  DATA: ef_cancel      TYPE abap_bool.
  DATA: et_objektliste TYPE z_t_zst_objektliste,
        ls_objektliste LIKE LINE OF et_objektliste,
        p_lief         TYPE zcus_extlief-ext_dienstlif,
        p_meas         TYPE zcus_extmeas-meas,
        p_date         TYPE sy-datum,
        p_andgr	       TYPE	ztexd_flache-ext_aendgrund,
        p_proj         TYPE ztexd_flache-projektname,
        p_auftr	       TYPE	ztexd_flache-auftr_verm.



  PERFORM set_status(zpr_ext_dienstleist_start)
              USING
                 reca1_activity-create.


  DATA: lo_msglist       TYPE REF TO if_reca_message_list.
  DATA: lf_exists    TYPE recabool.


  IF gs_gui_buffer-grid_do_save     = abap_true AND
     go_flache_mngr->is_modified( ) = abap_true.
    MESSAGE i156 DISPLAY LIKE 'I'.
*   Es liegen ungesicherte Daten vor. Bitte zuerst speichern.
    RETURN.
  ENDIF.



*   Get Messagesammler
  CALL METHOD cf_reca_message_list=>create
    RECEIVING
      ro_instance = lo_msglist.


*   Finden Dienstleistungsmanager
  zcf_pd_ztexd_flache_mngr=>find_by_dienstleistung(
  EXPORTING
    id_dienstleistung = 'MEAS'
    id_activity       = reca1_activity-create
    id_auth_check     = abap_true
    id_enqueue        = abap_false
    if_reset_buffer   = abap_true
    RECEIVING
    ro_instance       = go_flache_mngr
  EXCEPTIONS
    error             = 1
    OTHERS            = 2
    ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.


  CALL FUNCTION 'ZFB_GUI_GENERIC_SELECT_OBJEKT'
    EXPORTING
      id_activity       = reca1_activity-create
      id_dienstleistung = 'MEAS'
    IMPORTING
      ef_cancel         = ef_cancel
      et_objektliste    = et_objektliste
      p_lief            = p_lief
      p_date            = p_date
      p_andgr           = p_andgr
      p_proj            = p_proj
      p_auftr           = p_auftr.


*   Bearbeitung durch Benutzer abgebrochen
  IF ef_cancel = abap_true.
    RETURN.
  ENDIF.


*   Die Selektion ist leer
  IF et_objektliste[] IS INITIAL.
    MESSAGE i002 DISPLAY LIKE 'E'.
*     Keine Datensätze zu Ihrer Selektion gefunden.
    RETURN.
  ENDIF.


  LOOP AT et_objektliste INTO ls_objektliste.

    go_flache_mngr->objektliste_create(
     EXPORTING
       id_dienstleistung = go_flache_mngr->md_dienstleistung
       id_lief           = p_lief
       id_seldate        = p_date
       id_andgr          = p_andgr
       id_proj           = p_proj
       id_auftr          = p_auftr
       ist_objektliste   = ls_objektliste
       io_msglist        = lo_msglist
     EXCEPTIONS
       error             = 1
       OTHERS            = 2
       ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      INTO dummy.
      lo_msglist->add_symsg( if_cumulate = abap_true ).
      CONTINUE.
    ENDIF.

  ENDLOOP.


  CALL METHOD lo_msglist->has_messages_of_msgty
    EXPORTING
      id_msgty  = 'E'
    RECEIVING
      rf_exists = lf_exists.

  IF lf_exists = abap_true.

    PERFORM show_message_list IN PROGRAM saplzfg_ext_dienstleist
      USING lo_msglist.

  ENDIF.

  CLEAR lo_msglist.


*   get data and refresh
  gs_gui_buffer-grid_do_get_data  = abap_true.
  gs_gui_buffer-grid_do_refresh   = abap_true.





ENDFORM.                    " ON_MEAS_ANL



*&---------------------------------------------------------------------*
*&      Form  STEP_MSGLIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_COLUMN_FIELDNAME  text
*      -->P_LD_INDEX  text
*----------------------------------------------------------------------*
FORM step_msglist
     USING VALUE(id_fieldname) TYPE fieldname
           VALUE(id_index)     TYPE numeric.

* local data
  DATA:
    ls_grid_data LIKE LINE OF gt_grid_data,
    lo_msglist   TYPE REF TO if_reca_message_list.


* BODY
  READ TABLE gt_grid_data INDEX id_index INTO ls_grid_data.
  CHECK sy-subrc = 0.


  CASE id_fieldname.
    WHEN 'ICON_DETAIL'.
      go_flache_mngr->get_msglist(
         EXPORTING
           is_key = ls_grid_data-key
         CHANGING
           co_msglist     = lo_msglist
              ).

    WHEN 'ICON_STATUS_GEN'.
  ENDCASE.

  CHECK ( lo_msglist IS BOUND ).

  CALL FUNCTION 'RECA_GUI_MSGLIST_POPUP'
    EXPORTING
      io_msglist          = lo_msglist
*     ID_TITLE            =
      if_popup            = abap_false
      if_profile_detlevel = abap_true.

ENDFORM.                    " STEP_MSGLIST
*&---------------------------------------------------------------------*
*&      Form  SHOW_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_message .


  IF go_msglist IS BOUND AND
     go_msglist->count( ) > 0.
    CALL FUNCTION 'RECA_GUI_MSGLIST_DISPLAY'
      EXPORTING
        io_msglist = go_msglist
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
*   Implement suitable error handling here
    ENDIF.
  ENDIF.

ENDFORM.                    " SHOW_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  ON_MEAS_UPD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM on_meas_upd .

* Get Markierung
  DATA: et_sel_index TYPE re_t_tabix,
        ed_sel_index LIKE LINE OF et_sel_index.

  cl_reca_gui_alv_services=>get_selected_rows(
  EXPORTING
    io_grid                = go_grid
    if_ignore_current_cell = abap_true
  IMPORTING
    et_sel_index           = et_sel_index
  EXCEPTIONS
    no_selection           = 1
    OTHERS                 = 2
    ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DATA: ls_grid_data LIKE LINE OF gt_grid_data.


*  LOOP AT ET_SEL_INDEX INTO ED_SEL_INDEX.
*    READ TABLE GT_GRID_DATA INTO LS_GRID_DATA INDEX ED_SEL_INDEX.
*
***   Prüfen, ob löschen erlaubt
**    RD_ALOWED_FLAG = GO_GMOD_MNGR->MO_ANLAGE_MNGR->CHECK_DELETE_ANLAGE( ID_KESSEL_GUID = LS_ANLAGE-ZPD_ZTGMOD_ANLAGE-KESSEL_GUID ).
**    IF RD_ALOWED_FLAG = ABAP_FALSE.
**      MESSAGE I031 WITH 'der Heizanlage' LS_ANLAGE-ZPD_ZTGMOD_ANLAGE-ANLAGEN_ID DISPLAY LIKE 'E'.
***   Löschen & ist nicht erlaubt weil Verträge bereits generiert sind.
**      CONTINUE.
**    ENDIF.
**
***   Löschen
**    GO_GMOD_MNGR->MO_ANLAGE_MNGR->ANLAGE_DELETE(
**          EXPORTING
**            IS_DETAIL = LS_ANLAGE-ZPD_ZTGMOD_ANLAGE
**          EXCEPTIONS
**            ERROR     = 1
**            OTHERS    = 2
**               ).
**    IF SY-SUBRC <> 0.
**      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**                    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
**    ENDIF.
*
*  ENDLOOP.

* get data and refresh
  gs_gui_buffer-grid_do_get_data  = abap_true.
  gs_gui_buffer-grid_do_refresh   = abap_true.

ENDFORM.                    " ON_MEAS_UPD

*&---------------------------------------------------------------------*
*&      Form  on_MEAS_AEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM on_meas_aend USING p_id_activity TYPE reca1_activity.


  DATA:  lt_tab      TYPE z_t_ztexd_flache.

*********** 'MEAS_ANL' *************************
  DATA  ef_cancel      TYPE abap_bool.
  DATA: et_objektliste TYPE z_t_zst_objektliste,
        ls_objektliste LIKE LINE OF et_objektliste,
        p_lief         TYPE zcus_extlief-ext_dienstlif,
        p_meas         TYPE zcus_extmeas-meas,
        p_date         TYPE sy-datum.
*********** 'MEAS_ANL' *************************



  PERFORM set_status(zpr_ext_dienstleist_start)
              USING
                 p_id_activity.


  DATA: lo_msglist       TYPE REF TO if_reca_message_list.
  DATA: lf_exists        TYPE recabool.



*   Get Messagesammler
  CALL METHOD cf_reca_message_list=>create
    RECEIVING
      ro_instance = lo_msglist.



  CALL FUNCTION 'ZFB_GUI_GENERIC_SELECT_OBJEKT'
    EXPORTING
      id_activity       = p_id_activity
      id_dienstleistung = 'MEAS'
    IMPORTING
      ef_cancel         = ef_cancel
      et_objektliste    = et_objektliste
      et_tab            = lt_tab.

*           Bearbeitung durch Benutzer abgebrochen
  IF ef_cancel = abap_true.
    RETURN.
  ENDIF.

*           Die Selektion ist leer
  IF lt_tab[] IS INITIAL.
    MESSAGE i002 DISPLAY LIKE 'E'.
*       Keine Datensätze zu Ihrer Selektion gefunden.
    RETURN.
  ENDIF.


*     Finden Dienstleistungsmanager
  zcf_pd_ztexd_flache_mngr=>find_by_tab(
    EXPORTING
      id_dienstleistung = 'MEAS'
      it_tab            = lt_tab
      id_activity       = p_id_activity
      id_auth_check     = abap_true
      id_enqueue        = abap_true
      RECEIVING
      ro_instance       = go_flache_mngr
    EXCEPTIONS
      error             = 1
      OTHERS            = 2
      ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  ENDIF.



  CALL METHOD lo_msglist->has_messages_of_msgty
    EXPORTING
      id_msgty  = 'E'
    RECEIVING
      rf_exists = lf_exists.

  IF lf_exists = abap_true.

    PERFORM show_message_list IN PROGRAM saplzfg_ext_dienstleist
      USING lo_msglist.

  ENDIF.

  CLEAR lo_msglist.

ENDFORM.                    " ON_MEAS_AEND

*&---------------------------------------------------------------------*
*&      Form  ON_LIST_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM on_list_refresh .


* Get Markierung
  DATA: et_sel_index TYPE re_t_tabix,
        ed_sel_index LIKE LINE OF et_sel_index.

  cl_reca_gui_alv_services=>get_selected_rows(
  EXPORTING
    io_grid                = go_grid
    if_ignore_current_cell = abap_true
  IMPORTING
    et_sel_index           = et_sel_index
  EXCEPTIONS
    no_selection           = 1
    OTHERS                 = 2
    ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DATA: ls_grid_data LIKE LINE OF gt_grid_data,
        et_list      TYPE z_t_ztexd_flache.


* Flächenmanager neu erzeugen. Damit wird die Daten noch mal von Datenbank gelesen
  go_flache_mngr->get_list(
    IMPORTING
      et_list = et_list
         ).

  " check ob Daten geändert sind und gespeichert werden
  PERFORM on_save USING gc_ok_code-list_refresh.

  CLEAR go_flache_mngr.

*  Finden Dienstleistungsmanager
  zcf_pd_ztexd_flache_mngr=>find_by_tab(
  EXPORTING
    id_dienstleistung = 'MEAS'
    it_tab            = et_list
    id_activity       = gd_activity
    id_auth_check     = abap_true
    id_enqueue        = abap_true
    RECEIVING
    ro_instance       = go_flache_mngr
  EXCEPTIONS
    error             = 1
    OTHERS            = 2
    ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  ENDIF.




  LOOP AT et_sel_index INTO ed_sel_index.
    READ TABLE gt_grid_data INTO ls_grid_data INDEX ed_sel_index.


    go_flache_mngr->objektliste_refresh(
      EXPORTING
        is_list = ls_grid_data-zpd_ztexd_flache
      EXCEPTIONS
        error   = 1
        OTHERS  = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    DISPLAY LIKE 'E'.

    ENDIF.



  ENDLOOP.

* get data and refresh
  gs_gui_buffer-grid_do_get_data  = abap_true.
  gs_gui_buffer-grid_do_refresh   = abap_true.

ENDFORM.                    " ON_LIST_REFRESH
*&---------------------------------------------------------------------*
*&      Form  GET_F4_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_F4  text
*----------------------------------------------------------------------*
FORM get_f4_fields  CHANGING p_lt_f4 TYPE lvc_t_f4.

  DATA: ls_f4    LIKE LINE OF p_lt_f4.

  REFRESH p_lt_f4.

** Vorbelegung
*  LS_F4-REGISTER   = 'X'.
*  LS_F4-GETBEFORE  = 'X'.
*  LS_F4-CHNGEAFTER = 'X'.
*  LS_F4-FIELDNAME = 'IDENT_KEY'.
*  APPEND LS_F4 TO P_LT_F4.


ENDFORM.                    " GET_F4_FIELDS
*&---------------------------------------------------------------------*
*&      Form  GET_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_STRUCTURE_NAME  text
*      <--P_LT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM get_fieldcatalog  USING  VALUE(p_ld_structure_name)
                       CHANGING p_lt_fieldcat TYPE slis_t_fieldcat_alv.



  DEFINE zmac_alv_fc_pos_set.                                              " set next position for field (ascending)
*--> &1 = fieldname
*----------------------------------------------------------------------

    READ TABLE p_lt_fieldcat ASSIGNING <ls_fieldcatalog>
      WITH KEY fieldname = &1.
* the field MUST be present -> program error
    ASSERT FIELDS 'FIELDNAME' ld_colpos &1
      CONDITION sy-subrc = 0.

    <ls_fieldcatalog>-col_pos = ld_colpos.
    ADD 1 TO ld_colpos.

  END-OF-DEFINITION.

  DATA:
    ld_colpos         TYPE sytabix.                         "#EC NEEDED



  FIELD-SYMBOLS: <ls_fieldcatalog> LIKE LINE OF p_lt_fieldcat.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     I_PROGRAM_NAME         =
*     I_INTERNAL_TABNAME     = L_TABNAME
      i_structure_name       = p_ld_structure_name
    CHANGING
      ct_fieldcat            = p_lt_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc NE 0.
    RAISE program_error.
  ENDIF.


  LOOP AT p_lt_fieldcat ASSIGNING <ls_fieldcatalog>.
    IF <ls_fieldcatalog>-fieldname  = 'IDENT_KEY'.
      <ls_fieldcatalog>-just      = 'L'.
      <ls_fieldcatalog>-outputlen = 20.
    ENDIF.

    IF <ls_fieldcatalog>-fieldname  = 'KESSEL_GUID' OR
      <ls_fieldcatalog>-fieldname  = 'ICON_DETAILASS' OR
      <ls_fieldcatalog>-fieldname  = 'ICON_OBJASSIGN'.
      <ls_fieldcatalog>-no_out      = abap_true.
      <ls_fieldcatalog>-tech        = abap_true.
    ENDIF.

  ENDLOOP.

*  ZMAC_ALV_FC_POS_SET:
*    'GPART',
*    'NAME_ORG1',
*    'CONTRACTING',
*    'LEISTUNG',
*    'VKTYP',
*    'XKARTBEZ',
*    'BUKRS'.
ENDFORM.                    " GET_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  ON_MEAS_ANZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM on_meas_anz .

ENDFORM.                    " ON_MEAS_ANZ
*&---------------------------------------------------------------------*
*&      Form  ON_LIST_AEND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM on_list_aend .

  gs_gui_buffer-grid_do_change = abap_true.

  CALL FUNCTION 'ZFB_GUI_EXT_LEIST_NFC'.

*   get data and refresh
  gs_gui_buffer-grid_do_get_data  = abap_true.
  gs_gui_buffer-grid_do_refresh   = abap_true.

ENDFORM.                    "
*&---------------------------------------------------------------------*
*&      Form  ON_MEAS_DEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM on_meas_del .
* Get Markierung
  DATA: et_sel_index TYPE re_t_tabix,
        ed_sel_index LIKE LINE OF et_sel_index.

  cl_reca_gui_alv_services=>get_selected_rows(
  EXPORTING
    io_grid                = go_grid
    if_ignore_current_cell = abap_true
  IMPORTING
    et_sel_index           = et_sel_index
  EXCEPTIONS
    no_selection           = 1
    OTHERS                 = 2
    ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DATA: rd_ident  TYPE recaident,
        dummy     TYPE string,
        lf_exists TYPE abap_bool.
  DATA: ls_grid_data   LIKE LINE OF gt_grid_data,
        rd_alowed_flag TYPE recabool.
  DATA: lo_msglist   TYPE REF TO if_reca_message_list,
        flag_meldung TYPE flag.
  DATA: ld_answer      TYPE c.

*   Get Messagesammler
  CALL METHOD cf_reca_message_list=>create
    RECEIVING
      ro_instance = lo_msglist.


  LOOP AT et_sel_index INTO ed_sel_index.

    READ TABLE gt_grid_data INTO ls_grid_data INDEX ed_sel_index.

*   Prüfen, ob löschen erlaubt
    rd_alowed_flag = go_flache_mngr->check_delete_objekt( is_detail = ls_grid_data-zpd_ztexd_flache ).
    IF rd_alowed_flag = abap_false.

      go_flache_mngr->get_ident(
        EXPORTING
          is_detail = ls_grid_data-zpd_ztexd_flache
        RECEIVING
          rd_ident  = rd_ident
        EXCEPTIONS
          error     = 1
          OTHERS    = 2
             ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
      ENDIF.

      MESSAGE e010(zext_dienstl) WITH rd_ident INTO dummy.
*     Löschen & ist nicht erlaubt, Bemessungen bereits an SAP übertragen sind.
      lo_msglist->add_symsg( if_cumulate = abap_true ).
      CONTINUE.

    ENDIF.

    IF flag_meldung = abap_false.
*       ask?
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar      = TEXT-lo1
          text_question = TEXT-lo2
        IMPORTING
          answer        = ld_answer.
*       go on, if ok
      CHECK ld_answer = '1'.
      flag_meldung = abap_true.
    ENDIF.

*   Löschen
    go_flache_mngr->objektliste_delete(
      EXPORTING
        is_key  = ls_grid_data-key
      EXCEPTIONS
        error   = 1
        OTHERS  = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO dummy.
      lo_msglist->add_symsg( if_cumulate = abap_true ).

    ELSE.

      go_flache_mngr->get_ident(
        EXPORTING
          is_detail = ls_grid_data-zpd_ztexd_flache
        RECEIVING
          rd_ident  = rd_ident
        EXCEPTIONS
          error     = 1
          OTHERS    = 2
             ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
      ENDIF.

      MESSAGE s011(zext_dienstl) WITH rd_ident 'Bemessung' ls_grid_data-zpd_ztexd_flache-meas INTO dummy ##NO_TEXT.
*     Die Objektdaten & sind erfolgreich gelöscht.
      lo_msglist->add_symsg( if_cumulate = abap_true ).

    ENDIF.



  ENDLOOP.


  CALL METHOD lo_msglist->has_messages_of_msgty
    EXPORTING
      id_msgty  = 'I'
    RECEIVING
      rf_exists = lf_exists.

  IF lf_exists = abap_true.

    PERFORM show_message_list IN PROGRAM saplzfg_ext_dienstleist
      USING lo_msglist.

  ENDIF.

  CLEAR lo_msglist.



* get data and refresh
  gs_gui_buffer-grid_do_get_data  = abap_true.
  gs_gui_buffer-grid_do_refresh   = abap_true.

ENDFORM.                    " ON_MEAS_DEL

*&---------------------------------------------------------------------*
*&      Form  ON_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM on_save USING p_ok_code TYPE sytcode.

  DATA p_answer TYPE char1.

  IF go_flache_mngr IS BOUND AND
     go_flache_mngr->is_modified( ) = abap_true.

    IF p_ok_code = 'BACK' OR
      p_ok_code = 'MEAS_AEND' OR
      p_ok_code = 'MEAS_ANZ' OR
      p_ok_code = 'MEAS_ANL' OR
      p_ok_code = 'LIST_REFRESH'.

*   Check Datenspreicher
      CALL FUNCTION 'ZFG_GENERIC_POPUP_SAVE_DATA'
        EXPORTING
          p_text   = ' '
        IMPORTING
          p_answer = p_answer.


      CASE p_answer.
        WHEN 'A'.  "A" = Anwender hat Abbrechen gewählt
          IF p_ok_code = 'BACK'.
            SUBMIT zpr_ext_dienstleist_start.
          ENDIF.
        WHEN 'N'.  "N" = Anwender hat den Verarbeitungsschritt zurückgenommen
          IF p_ok_code = 'BACK'.
            SUBMIT zpr_ext_dienstleist_start.
          ENDIF.
        WHEN 'J'.  "J" = Anwender hat den Verarbeitungsschritt bestätigt

          go_flache_mngr->store(
            EXPORTING
              if_in_update_task = abap_false
              if_force_check    = abap_false
            EXCEPTIONS
              error             = 1
              OTHERS            = 2
              ).
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.


          cf_reca_storable=>commit(
            EXPORTING
              if_wait             = abap_true
                 ).

          IF p_ok_code = 'BACK'.
            SUBMIT zpr_ext_dienstleist_start.
          ENDIF.
      ENDCASE.

    ELSE.

      go_flache_mngr->store(
        EXPORTING
          if_in_update_task = abap_false
          if_force_check    = abap_false
        EXCEPTIONS
          error             = 1
          OTHERS            = 2
          ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


      cf_reca_storable=>commit(
        EXPORTING
          if_wait             = abap_true
             ).


      gs_gui_buffer-grid_do_save = abap_false.

    ENDIF.

  ELSE.

    IF p_ok_code = 'BACK'.
      SUBMIT zpr_ext_dienstleist_start.
    ENDIF.

  ENDIF.

ENDFORM.                    " ON_SAVE
*&---------------------------------------------------------------------*
*&      Form  ON_MEAS_UPL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM on_meas_upl .

  DATA:  lt_tab      TYPE z_t_ztexd_flache.
  DATA:  ld_upd_flag  TYPE flag.

*********** 'MEAS_ANL' *************************
  DATA  ef_cancel      TYPE abap_bool.
  DATA: et_objektliste TYPE z_t_zst_objektliste,
        ls_objektliste LIKE LINE OF et_objektliste,
        p_lief         TYPE zcus_extlief-ext_dienstlif,
        p_meas         TYPE zcus_extmeas-meas,
        p_date         TYPE sy-datum.
*********** 'MEAS_ANL' *************************
  DATA: ld_dienstleistung         TYPE zddienstleistung.


  IF gs_gui_buffer-grid_do_save     = abap_true AND
     go_flache_mngr->is_modified( ) = abap_true.
    MESSAGE i156 DISPLAY LIKE 'I'.
*   Es liegen ungesicherte Daten vor. Bitte zuerst speichern.
    RETURN.
  ENDIF.


  " Set Dienstleistung
  ld_dienstleistung = 'MEAS'.


  DATA: lo_msglist       TYPE REF TO if_reca_message_list.
  DATA: lf_exists TYPE recabool,
        dummy     TYPE string.

*   Get Messagesammler
  CALL METHOD cf_reca_message_list=>create
    RECEIVING
      ro_instance = lo_msglist.




*     Finden Dienstleistungsmanager
  IF go_flache_mngr IS NOT BOUND.
    zcf_pd_ztexd_flache_mngr=>find_by_tab(
     EXPORTING
       id_dienstleistung = ld_dienstleistung
       it_tab            = lt_tab
       id_activity       = reca1_activity-change
       id_auth_check     = abap_true
       id_enqueue        = abap_true
       RECEIVING
       ro_instance       = go_flache_mngr
     EXCEPTIONS
       error             = 1
       OTHERS            = 2
       ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDIF.

*****************************************************************************
  DATA: ld_filename   TYPE string,
        ld_filelength TYPE i.
  DATA: anz_zeilen    TYPE i.
  DATA: anz_spalten_i TYPE i VALUE '43'.
  DATA: lt_excel_hlp  TYPE ztabline,
        lt_excel_hash TYPE z_t_dyn_dta_h,
        filename      TYPE string.

  DATA: ld_path        TYPE sapb-sappoolinf,
        lt_excel_uload TYPE z_t_ztexd_flache.
  FIELD-SYMBOLS:
        <ls_excel_uload> LIKE LINE OF lt_excel_uload.


  DATA: ld_direktory   TYPE string.

*   Verzeichnis von Exceldateien
  DATA: et_cus_directory TYPE z_t_zcus_extdirect,
        ls_cus_directory LIKE LINE OF et_cus_directory.

  zcl_cust_zcus_extdirect=>get_list_by_dienstleistung(
    EXPORTING
      id_dienstleistung = ld_dienstleistung
    IMPORTING
      et_list           = et_cus_directory
    EXCEPTIONS
      not_found         = 1
      OTHERS            = 2
         ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error.
  ENDIF.

  READ TABLE et_cus_directory INTO ls_cus_directory INDEX 1.
  ld_direktory = ls_cus_directory-ext_dierectory.

*   Datainame übergeben
  zcl_dta_services=>get_path(
  EXPORTING
    initial_directory = ld_direktory
  CHANGING
    path              = ld_path
    ).

  ld_filename = ld_path.

  IF NOT ld_filename IS INITIAL.
    anz_zeilen = 65536.                "max. Grenze
    CLEAR filename.
    filename = ld_filename.
    CALL FUNCTION 'Z_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = filename
        i_begin_col             = 1
        i_begin_row             = 1
        i_end_col               = anz_spalten_i
        i_end_row               = anz_zeilen
      TABLES
        intern                  = lt_excel_hlp
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.

    IF sy-subrc <> 0.
      MESSAGE i026(za) WITH ld_filename DISPLAY LIKE 'E'.
    ELSE.
*     Hashedtabelle aufbereiten
      INSERT LINES OF lt_excel_hlp INTO TABLE lt_excel_hash.
*     Excelmastertabelle aufbereiten
      PERFORM set_excel
         USING
          lt_excel_hash
        CHANGING
          lt_excel_uload.

    ENDIF.
  ENDIF.



* Set Excel-Daten in Objektliste
  go_flache_mngr->objektliste_excel_upl(
    EXPORTING
      it_excel_tab = lt_excel_uload
      io_msglist   = lo_msglist                             " EF 15160
         ).






  CALL METHOD lo_msglist->has_messages_of_msgty
    EXPORTING
      id_msgty  = 'W'
    RECEIVING
      rf_exists = lf_exists.

  IF lf_exists = abap_true.

    PERFORM show_message_list IN PROGRAM saplzfg_ext_dienstleist
    USING lo_msglist.

  ENDIF.


  CLEAR lo_msglist.

  gs_gui_buffer-grid_do_excel          = abap_false.
  gs_gui_buffer-grid_do_excel_dow      = abap_false.
  gs_gui_buffer-grid_do_excel_upl      = abap_false.
* get data and refresh
  gs_gui_buffer-grid_do_get_data  = abap_true.
  gs_gui_buffer-grid_do_refresh   = abap_true.


ENDFORM.                    " ON_MEAS_UPL
*&---------------------------------------------------------------------*
*&      Form  ON_MEAS_DOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM on_meas_dow .

  DATA:  lt_guid      TYPE re_t_guid.

*********** 'MEAS_ANL' *************************
  DATA  ef_cancel      TYPE abap_bool.
  DATA: et_objektliste TYPE z_t_zst_objektliste,
        ls_objektliste LIKE LINE OF et_objektliste,
        p_lief         TYPE zcus_extlief-ext_dienstlif,
        p_meas         TYPE zcus_extmeas-meas,
        p_date         TYPE sy-datum.
*********** 'MEAS_ANL' *************************
  DATA ro_instance       TYPE REF TO zif_pd_ztexd_flache_mngr.


  DATA: et_list_x TYPE z_t_ztexd_flache_x,
        ls_list_x LIKE LINE OF et_list_x.


  DATA: lo_msglist       TYPE REF TO if_reca_message_list.
  DATA: lf_exists    TYPE recabool.


  IF gs_gui_buffer-grid_do_save     = abap_true AND
     go_flache_mngr->is_modified( ) = abap_true.
    MESSAGE i156 DISPLAY LIKE 'I'.
*   Es liegen ungesicherte Daten vor. Bitte zuerst speichern.
    RETURN.
  ENDIF.


*   Get Messagesammler
  CALL METHOD cf_reca_message_list=>create
    RECEIVING
      ro_instance = lo_msglist.




*  LOOP AT ET_LIST_X INTO LS_LIST_X WHERE AKTIVITAET = ' ' AND MEASVALUE_NEU IS INITIAL
*                                     AND ME_UPDATE(6) <> 'FEHLER'.
*    APPEND INITIAL LINE TO <OUTTAB> ASSIGNING <TABLE_LINE>.
*    MOVE-CORRESPONDING LS_LIST_X TO <TABLE_LINE>.
*    <TABLE_LINE>-MEASUNIT_NEU = LS_LIST_X-MEASUNIT.
*  ENDLOOP.

*****************************************************************************

  CALL FUNCTION 'ZFB_GUI_EXT_LEIST_NFC'.

* get data and refresh
  gs_gui_buffer-grid_do_get_data  = abap_true.
  gs_gui_buffer-grid_do_refresh   = abap_true.
  gs_gui_buffer-grid_do_excel     = abap_true.
  gs_gui_buffer-grid_do_excel_dow  = abap_true.
  gs_gui_buffer-grid_do_excel_upl  = abap_false.

ENDFORM.                    " ON_MEAS_DOW
*&---------------------------------------------------------------------*
*&      Form  SET_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_EXCEL_HASH  text
*      <--P_LT_EXCEL_ULOAD  text
*----------------------------------------------------------------------*
FORM set_excel  USING    p_lt_excel_hash  TYPE z_t_dyn_dta_h
                CHANGING p_lt_excel_uload TYPE z_t_ztexd_flache.





  DATA: ls_excel TYPE ztabline_str,
        zeile    TYPE ztabline_str-row,
        spalte   TYPE ztabline_str-row,
        fehlvers TYPE i,
        ld_row   TYPE i.
  DATA: prozent_hpt TYPE i,
        text_hpt    TYPE rs38m-itex132,
        cnt         TYPE string.
  DATA: lf_cell_error TYPE abap_bool,
        ls_msg(132)   TYPE c.
*    DATA:     H_DAT(10)      TYPE C,
*              H_H_DAT(10)    TYPE C.


  FIELD-SYMBOLS:
    <fs>      TYPE any,
    <ls_list> LIKE LINE OF p_lt_excel_uload.


* Startbedinung lesen mit Kopfzeile
  zeile  = '0002'.



  spalte = '0000'.


*
* DTA-Felder entschlüsseln
  DO .
*    Indikator prozent
    prozent_hpt = '100'.
    cnt = sy-tabix.
    CONCATENATE cnt ' -Excelzeile wird in SAP-DTA Tabelle zugeordnet' ##NO_TEXT
    INTO text_hpt.

*   Indikator
    PERFORM indikator IN PROGRAM saplzfg_xsca_draw
    USING prozent_hpt
          text_hpt.

*   Lesezeile bestimmen index
    ld_row = sy-index.


    CHECK ld_row >= zeile.

*   Kontrollcheck bei Ende von Exceltabelle
    READ TABLE p_lt_excel_hash INTO ls_excel WITH KEY row = ld_row.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.


*   Exporttabelle wird aufgebaut
    APPEND INITIAL LINE TO p_lt_excel_uload ASSIGNING <ls_list>.


    LOOP AT p_lt_excel_hash INTO ls_excel WHERE row = ld_row.

      CASE ls_excel-col.
        WHEN 1.
          ASSIGN COMPONENT 'MEAS_GUID' OF STRUCTURE <ls_list> TO <fs>.

        WHEN 15.
          ASSIGN COMPONENT 'MEAS' OF STRUCTURE <ls_list> TO <fs>.

        WHEN 20. " Änd.Aktiv.
          ASSIGN COMPONENT 'AKTIVITAET' OF STRUCTURE <ls_list> TO <fs>.

        WHEN 21. " Umsetzung per
          ASSIGN COMPONENT 'EXT_FERTDAT' OF STRUCTURE <ls_list> TO <fs>.

        WHEN 22. " Bemerkung Lieferant
          ASSIGN COMPONENT 'BEMERKUNG_LIEFERANT' OF STRUCTURE <ls_list> TO <fs>.

        WHEN 23. " Größe neu
          ASSIGN COMPONENT 'MEASVALUE_NEU' OF STRUCTURE <ls_list> TO <fs>.

        WHEN 24. " Einh neu
          ASSIGN COMPONENT 'MEASUNIT_NEU' OF STRUCTURE <ls_list> TO <fs>.

*        WHEN 25. " Gültig ab neu
*          ASSIGN COMPONENT 'VALIDFROM' OF STRUCTURE <LS_LIST> TO <FS>.
        WHEN 39. " BUKRS
          ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <ls_list> TO <fs>.
        WHEN 40. " SWENR
          ASSIGN COMPONENT 'SWENR' OF STRUCTURE <ls_list> TO <fs>.
        WHEN 41. " SGRNR
          ASSIGN COMPONENT 'SGRNR' OF STRUCTURE <ls_list> TO <fs>.
        WHEN 42. " SGENR
          ASSIGN COMPONENT 'SGENR' OF STRUCTURE <ls_list> TO <fs>.
        WHEN 43. " SMENR
          ASSIGN COMPONENT 'SMENR' OF STRUCTURE <ls_list> TO <fs>.
        WHEN OTHERS.
          CONTINUE.
      ENDCASE.


*     Komma wird durch '.' ersetzt
      REPLACE ',' IN ls_excel-value WITH '.'.


*     Datum konvertieren
      IF ls_excel-col = 19 OR
         ls_excel-col = 21 OR
         ls_excel-col = 25.
*       CLEAR: H_DAT, H_H_DAT.
*       WRITE LS_EXCEL-VALUE TO H_DAT.
*       Datum konvertieren
        CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
          EXPORTING
            date_external            = ls_excel-value
            accept_initial_date      = abap_true
          IMPORTING
            date_internal            = ls_excel-value
          EXCEPTIONS
            date_external_is_invalid = 1
            OTHERS                   = 2.
        IF sy-subrc <> 0.
*           Implement suitable error handling here
        ENDIF.

      ENDIF.

      <fs> = ls_excel-value.


      IF ls_excel-col = 24.
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT' ##FM_SUBRC_OK
          EXPORTING
            input          = <fs>
            language       = sy-langu
          IMPORTING
            output         = <fs>
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
      ENDIF.

*     Beim ImmoKey die Nummern konvertieren
      IF ls_excel-col BETWEEN 39 AND 43.
**     Beim Buchungskreis/WE/GE/ME führende Nullen hinzufügen
        CALL METHOD cl_reca_ddic_services=>do_conv_exit ##FM_SUBRC_OK
          EXPORTING
            id_convexit        = 'ALPHA'
            if_only_if_defined = abap_false
            if_output          = abap_false
          CHANGING
            cd_field           = <fs>
          EXCEPTIONS
            error              = 1
            OTHERS             = 2 ##SUBRC_OK.

      ENDIF.

*      Set  Bemessung
      IF ls_excel-col = 15.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <fs>
          IMPORTING
            output = <fs>.
      ENDIF.

    ENDLOOP.


  ENDDO.


ENDFORM.                    " SET_EXCEL
*&---------------------------------------------------------------------*
*&      Form  ON_SAP_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM on_sap_update .

* Get Markierung
  DATA: et_sel_index TYPE re_t_tabix,
        ed_sel_index LIKE LINE OF et_sel_index.


  IF gs_gui_buffer-grid_do_save     = abap_true AND
     go_flache_mngr->is_modified( ) = abap_true.
    MESSAGE i156 DISPLAY LIKE 'I'.
*   Es liegen ungesicherte Daten vor. Bitte zuerst speichern.
    RETURN.
  ENDIF.




  DATA: lo_msglist       TYPE REF TO if_reca_message_list.
  DATA: lf_exists TYPE recabool,
        dummy     TYPE string.





  cl_reca_gui_alv_services=>get_selected_rows(
    EXPORTING
      io_grid                = go_grid
      if_ignore_current_cell = abap_true
    IMPORTING
      et_sel_index           = et_sel_index
    EXCEPTIONS
      no_selection           = 1
      OTHERS                 = 2
      ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DATA: ls_grid_data LIKE LINE OF gt_grid_data,
        lt_meas      TYPE z_t_ztexd_flache,
        ls_meas      LIKE LINE OF lt_meas.



*   Get Messagesammler
  CALL METHOD cf_reca_message_list=>create
    RECEIVING
      ro_instance = lo_msglist.



  LOOP AT et_sel_index INTO ed_sel_index.
    READ TABLE gt_grid_data INTO ls_grid_data INDEX ed_sel_index.


    APPEND ls_grid_data-zpd_ztexd_flache TO lt_meas.


  ENDLOOP.


  CHECK lt_meas[] IS NOT INITIAL.

  SORT lt_meas BY dienstleistung objnr.

  go_flache_mngr->me_flaeche_updaten(
   EXPORTING
     it_meas    = lt_meas
     io_msglist = lo_msglist
   EXCEPTIONS
     error  = 1
     OTHERS = 2
     ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    INTO dummy.
    lo_msglist->add_symsg( if_cumulate = abap_true ).
  ENDIF.

  " Save notwendig
  gs_gui_buffer-grid_do_save     = abap_true.

  CALL METHOD lo_msglist->has_messages_of_msgty
    EXPORTING
      id_msgty  = 'W'
    RECEIVING
      rf_exists = lf_exists.

  IF lf_exists = abap_true.

    PERFORM show_message_list IN PROGRAM saplzfg_ext_dienstleist
    USING lo_msglist.

  ENDIF.


  CLEAR lo_msglist.



* get data and refresh
  gs_gui_buffer-grid_do_get_data  = abap_true.
  gs_gui_buffer-grid_do_refresh   = abap_true.


ENDFORM.                    " ON_SAP_UPDATE
*&---------------------------------------------------------------------*
*&      Form  ON_MASSENPFLEGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LD_OK_CODE  text
*----------------------------------------------------------------------*
FORM on_massenpflege  USING    p_ld_ok_code TYPE sytcode.

* Get Markierung
  DATA: et_sel_index TYPE re_t_tabix,
        ed_sel_index LIKE LINE OF et_sel_index.


  DATA: lo_msglist       TYPE REF TO if_reca_message_list.
  DATA: lf_exists TYPE recabool,
        dummy     TYPE string.

  cl_reca_gui_alv_services=>get_selected_rows(
  EXPORTING
    io_grid                = go_grid
    if_ignore_current_cell = abap_true
  IMPORTING
    et_sel_index           = et_sel_index
  EXCEPTIONS
    no_selection           = 1
    OTHERS                 = 2
    ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DATA: ls_grid_data LIKE LINE OF gt_grid_data.



*   Get Messagesammler
  CALL METHOD cf_reca_message_list=>create
    RECEIVING
      ro_instance = lo_msglist.



  LOOP AT et_sel_index INTO ed_sel_index.
    READ TABLE gt_grid_data INTO ls_grid_data INDEX ed_sel_index.

    CASE p_ld_ok_code.
      WHEN gc_ok_code-set_ja.
        ls_grid_data-aktivitaet = 'ja'.
      WHEN gc_ok_code-set_sofort.
        ls_grid_data-aktivitaet = 'sofort'.
      WHEN gc_ok_code-set_nein.
        ls_grid_data-aktivitaet = 'nein' ##NO_TEXT.
      WHEN gc_ok_code-set_info.
        ls_grid_data-aktivitaet = 'info' ##NO_TEXT.
      WHEN gc_ok_code-set_pruefen.
        ls_grid_data-aktivitaet = 'Prüfen' ##NO_TEXT.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.



    go_flache_mngr->objektliste_change(
     EXPORTING
       is_list = ls_grid_data-zpd_ztexd_flache
     EXCEPTIONS
       error   = 1
       OTHERS  = 2
       ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      INTO dummy.
      lo_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.


  ENDLOOP.


  CALL METHOD lo_msglist->has_messages_of_msgty
    EXPORTING
      id_msgty  = 'W'
    RECEIVING
      rf_exists = lf_exists.

  IF lf_exists = abap_true.

    PERFORM show_message_list IN PROGRAM saplzfg_ext_dienstleist
    USING lo_msglist.

  ENDIF.


  CLEAR lo_msglist.



* get data and refresh
  gs_gui_buffer-grid_do_get_data  = abap_true.
  gs_gui_buffer-grid_do_refresh   = abap_true.


ENDFORM.                    " ON_MASSENPFLEGE
