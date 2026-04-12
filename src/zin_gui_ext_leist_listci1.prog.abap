*&---------------------------------------------------------------------*
*&  Include           ZIN_GUI_EXT_LEIST_LISTCI1
*&---------------------------------------------------------------------*
*=======================================================================
CLASS lcl_event_receiver IMPLEMENTATION.
*=======================================================================


*-----------------------------------------------------------------------
  METHOD handle_data_changed.
*-----------------------------------------------------------------------

*   local data
    DATA: ld_code TYPE syucomm.

*   set code
    ld_code = gc_ok_code-grid_enter.

*   dynamic break-point
    mac_trace_alv_event.

    go_changed_data_protocol = er_data_changed.

*   do PAI if smth has changed
    CALL METHOD cl_gui_cfw=>set_new_ok_code(
        new_code = ld_code ).

  ENDMETHOD.                    "handle_data_changed

*-----------------------------------------------------------------------
  METHOD handle_double_click.
*-----------------------------------------------------------------------

    DATA:
      ld_index  TYPE sytabix,
      ld_fcode  TYPE syucomm,
      lf_obj    TYPE recabool,
      lf_objekt TYPE recabool.

*   TRACE
    mac_trace_alv_event.


*   BODY
    IF e_row-index > 0.


*     Navigation zu RE-Objekten
      IF e_column-fieldname = 'SWENR' OR
         e_column-fieldname = 'SGENR' OR
         e_column-fieldname = 'RECNNR' OR
         e_column-fieldname = 'SMIVE_AKTUELL' OR
         e_column-fieldname =  'SMENR' .

        ld_index = e_row-index.
        PERFORM objekt_navigation USING e_column-fieldname
                                        ld_index.
        IF e_column-fieldname = 'SMIVE_AKTUELL'.
          lf_objekt = ' '.
        ELSE.
          lf_objekt = abap_true.
        ENDIF.
      ENDIF.

*     set new row
      ld_index = e_row-index.
      PERFORM current_row_set
      USING ld_index.

**     show detail
*      GO_GUI_DYNPSUBSCR_FRAME->SET_HIDE_BOTTOM( ABAP_FALSE ).

      IF lf_objekt = abap_true.
        " Objekt wurde schon angezeigt
      ELSEIF lf_obj = abap_true.
*        LD_FCODE = GC_OK_CODE-GRID_OBJECT.

      ELSEIF e_column-fieldname = 'ICON_DETAIL'.
*     show Protokoll
        PERFORM step_msglist USING e_column-fieldname
                                   ld_index.


      ELSE.
        ld_fcode = gc_ok_code-grid_enter.
      ENDIF.

      cl_gui_cfw=>set_new_ok_code( new_code = ld_fcode ).

      gs_gui_buffer-grid_do_get_data = abap_true.

    ENDIF.

  ENDMETHOD.                    "handle_double_click


*-----------------------------------------------------------------------
  METHOD handle_hotspot_click.
*-----------------------------------------------------------------------

*   TRACE
    mac_trace_alv_event.

*   BODY
    CALL METHOD handle_double_click
      EXPORTING
        e_row    = e_row_id
        e_column = e_column_id.

  ENDMETHOD.                    "handle_hotspot_click


* ---------------------------------------------------------------------
  METHOD handle_menu_button.
* ---------------------------------------------------------------------

    DATA:
      ld_fcode       TYPE ui_func,
      ld_text        TYPE gui_text,
      ld_text_grp    TYPE gui_text,
      lt_costspos_x  TYPE re_t_costspos_x,
      ls_costspos_x  TYPE reaj_costspos_x,
      lo_menu        TYPE REF TO cl_ctmenu,
      lo_menu_grp    TYPE REF TO cl_ctmenu,
      ld_costsposgrp TYPE reajcostsposgrp,
      lf_disabled    TYPE recabool.

*   pressed menu?
    CASE e_ucomm.

*     insert menu
      WHEN gc_ok_code-set_excel.
*
*       disable flag
        lf_disabled = abap_false.
*        IF NOT LS_DETAIL_X-PROCESSEXTID IS INITIAL.
*          LF_DISABLED = ABAP_TRUE.
*        ENDIF.

*       first entry: rental object
        ld_fcode = gc_ok_code-excel_upl.
        ld_text  = TEXT-upl.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode    = ld_fcode
            text     = ld_text
            disabled = lf_disabled.

*       second entry: contract
        ld_fcode = gc_ok_code-excel_dow.
        ld_text  = TEXT-dow.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode    = ld_fcode
            text     = ld_text
            disabled = lf_disabled.



      WHEN gc_ok_code-set_aktiv.

*       disable flag
        lf_disabled = abap_false.


*      first entry: rental object
        ld_fcode = gc_ok_code-set_ja.
        ld_text  = TEXT-mp1.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode    = ld_fcode
            text     = ld_text
            disabled = lf_disabled.


*       second entry: contract
        ld_fcode = gc_ok_code-set_sofort.
        ld_text  = TEXT-mp2.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode    = ld_fcode
            text     = ld_text
            disabled = lf_disabled.


        ld_fcode = gc_ok_code-set_nein.
        ld_text  = TEXT-mp3.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode    = ld_fcode
            text     = ld_text
            disabled = lf_disabled.


        ld_fcode = gc_ok_code-set_info.
        ld_text  = TEXT-mp4.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode    = ld_fcode
            text     = ld_text
            disabled = lf_disabled.


        ld_fcode = gc_ok_code-set_pruefen.
        ld_text  = TEXT-mp5.
        CALL METHOD e_object->add_function
          EXPORTING
            fcode    = ld_fcode
            text     = ld_text
            disabled = lf_disabled.

    ENDCASE.


  ENDMETHOD.                    "handle_menu_button


*-----------------------------------------------------------------------
  METHOD handle_toolbar.
*-----------------------------------------------------------------------

    TYPE-POOLS:
    cntb,
    icon.

    STATICS:
    sd_icon_help    TYPE icon_d.

    DATA:
      lt_button      TYPE ttb_button,
      ls_button      TYPE stb_button,
      lf_enabled     TYPE abap_bool,
      lf_enabled_but TYPE abap_bool.

    DEFINE mac_add_button.
      CLEAR ls_button.
      ls_button-butn_type = &1.
      ls_button-function  = &2.
      ls_button-icon      = &3.
      ls_button-text      = &4.
      ls_button-quickinfo = &5.
      IF &6 = abap_true.
        ls_button-disabled  = abap_false.
      ELSE.
        ls_button-disabled  = abap_true.
      ENDIF.
      APPEND ls_button TO lt_button.
    END-OF-DEFINITION.

*   TRACE
    mac_trace_alv_event.

*   BODY

*   add buttons for change mode
    IF gd_activity <> reca1_activity-display AND
       gs_gui_buffer-grid_do_excel = abap_false.
      IF gs_gui_buffer-grid_do_detail = abap_true.
        lf_enabled = abap_false.
      ELSE.
        lf_enabled = abap_true.
      ENDIF.
    ELSE.
      lf_enabled = abap_false.
    ENDIF.


    lf_enabled_but = lf_enabled.


    IF gd_anwactivity = 'MEAS_AEND'.
*   Objektliste ändern
      mac_add_button cntb_btype_button gc_ok_code-list_aend
      icon_change_text  TEXT-003  TEXT-003  lf_enabled_but.
      lf_enabled_but = lf_enabled.
    ENDIF.

*   Aktualisieren
    mac_add_button cntb_btype_button gc_ok_code-list_refresh
    icon_refresh  TEXT-sor  TEXT-sor  lf_enabled_but.

*   Delete
    mac_add_button cntb_btype_button gc_ok_code-list_del
    icon_delete_row  TEXT-sol  TEXT-sol  lf_enabled_but.
    lf_enabled_but = lf_enabled.



*   separator
    mac_add_button cntb_btype_sep   ''  ''  ''  ''  lf_enabled.


    IF gd_anwactivity = 'MEAS_AEND'.
      IF gs_gui_buffer-grid_do_change = abap_true.
*     Aktivität Massenänderung
        mac_add_button cntb_btype_menu gc_ok_code-set_aktiv
        icon_mass_change  TEXT-006  TEXT-006  abap_true.
      ELSE.
*     Aktivität Massenänderung
        mac_add_button cntb_btype_menu gc_ok_code-set_aktiv
        icon_mass_change  TEXT-006  TEXT-006  abap_false.
      ENDIF.
    ENDIF.

*   separator
    mac_add_button cntb_btype_sep   ''  ''  ''  ''  lf_enabled.


    IF gd_anwactivity = 'MEAS_AEND'.
*   Excel Import/Export
      mac_add_button cntb_btype_menu gc_ok_code-set_excel
      icon_xxl  TEXT-004  TEXT-004  lf_enabled_but.
      lf_enabled_but = lf_enabled.
    ENDIF.


*   separator
    mac_add_button cntb_btype_sep   ''  ''  ''  ''  lf_enabled.

    IF gd_anwactivity = 'MEAS_AEND'.
*     SAP-Stammdaten Upate
      mac_add_button cntb_btype_button gc_ok_code-sap_update
      icon_assign  TEXT-005  TEXT-005  lf_enabled_but.
      lf_enabled_but = lf_enabled.
    ENDIF.

*   separator
    mac_add_button cntb_btype_sep   ''  ''  ''  ''  lf_enabled.

*   add these buttons at the beginning of the toolbar
    INSERT LINES OF lt_button INTO e_object->mt_toolbar INDEX 1.
    CLEAR lt_button.
*
*   add help button at the end of the toolbar
    IF sd_icon_help IS INITIAL.
      CALL METHOD cl_recac_icon=>get_icon
        EXPORTING
          id_iconfor    = reca1_iconfor-others
          id_iconforkey = reca1_iconforkey-system_help
          id_default    = icon_system_help
        RECEIVING
          rd_icon_id    = sd_icon_help.
    ENDIF.
    mac_add_button cntb_btype_button  gc_ok_code-grid_help
    sd_icon_help       ''  TEXT-hlp  abap_true.
    APPEND ls_button TO e_object->mt_toolbar.

  ENDMETHOD.                    "handle_toolbar


*-----------------------------------------------------------------------
  METHOD handle_user_command.
*-----------------------------------------------------------------------

    DATA:
          lf_process_pai TYPE abap_bool.

*   TRACE
    mac_trace_alv_event.

*   BODY
    lf_process_pai = abap_true.
    CASE e_ucomm.

      WHEN gc_ok_code-grid_help.
        lf_process_pai = abap_false.
        PERFORM on_help.

    ENDCASE.

*   force pai-processing
    IF lf_process_pai = abap_true.
      cl_gui_cfw=>set_new_ok_code( new_code = e_ucomm ).
    ENDIF.

  ENDMETHOD.                    "handle_user_command

  METHOD handle_after_refresh.

*   TRACE
    mac_trace_alv_event.

    IF 1 = 2 .
*   force pai-processing
      cl_gui_cfw=>set_new_ok_code( new_code = 'REFRESH_TAB' ).
    ENDIF.
  ENDMETHOD.                    "HANDLE_AFTER_REFRESH

  METHOD    handle_onf4.
*--> E_FIELDNAME  Type  LVC_FNAME
*--> E_FIELDVALUE Type  LVC_VALUE
*--> ES_ROW_NO  Type  LVC_S_ROID
*--> ER_EVENT_DATA  Type Ref To CL_ALV_EVENT_DATA
*--> ET_BAD_CELLS Type  LVC_T_MODI
*--> E_DISPLAY  Type  CHAR01

    DATA: lt_outtab_assobj  TYPE STANDARD TABLE OF zst_assobj_dialog,
          lt_fieldcat       TYPE slis_t_fieldcat_alv,
          ld_structure_name TYPE  dd02l-tabname VALUE 'ZST_ASSOBJ_DIALOG',
          g_exit(1)         TYPE c,
          gs_selfield       TYPE slis_selfield,
          ld_selection      TYPE char1,
          rd_gruppe_cust    TYPE char10.

    DATA:   ld_code              TYPE syucomm.

    FIELD-SYMBOLS: <ls_grid_data>     LIKE LINE OF gt_grid_data,
                   <ls_outtab_assobj> LIKE LINE OF lt_outtab_assobj.


*    CASE E_FIELDNAME.
*      WHEN 'IDENT_KEY'.
*
*
*        IF E_DISPLAY = ABAP_TRUE.
*          LD_SELECTION = ABAP_FALSE.
*        ELSE.
*          LD_SELECTION = ABAP_TRUE.
*        ENDIF.
*
*        PERFORM GET_FIELDCATALOG USING LD_STRUCTURE_NAME
*                                 CHANGING LT_FIELDCAT.
*
*        READ TABLE GT_GRID_DATA ASSIGNING <LS_GRID_DATA> INDEX ES_ROW_NO-ROW_ID.
*
*        SELECT * FROM ZDV_ASSOBJ_SH  INTO CORRESPONDING FIELDS OF TABLE LT_OUTTAB_ASSOBJ
*                                                        WHERE KESSEL_GUID = <LS_GRID_DATA>-KESSEL_GUID.
*
*
*        CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
*          EXPORTING
*            I_TITLE               = 'Get Kontierungsobjekt'
*            I_SELECTION           = LD_SELECTION
*            I_ZEBRA               = 'X'
*            I_CHECKBOX_FIELDNAME  = 'SELFELD'
*            I_SCREEN_START_COLUMN = 5
*            I_SCREEN_START_LINE   = 5
*            I_SCREEN_END_COLUMN   = 100
*            I_SCREEN_END_LINE     = 12
*            I_TABNAME             = 'LT_OUTTAB_ASSOBJ'
**           I_STRUCTURE_NAME      = 'ZST_ALV_SELECT_STANDORT'
*            IT_FIELDCAT           = LT_FIELDCAT
**           IS_PRIVATE            = GS_PRIVATE
*          IMPORTING
*            ES_SELFIELD           = GS_SELFIELD
*            E_EXIT                = G_EXIT
*          TABLES
*            T_OUTTAB              = LT_OUTTAB_ASSOBJ
*          EXCEPTIONS
*            PROGRAM_ERROR         = 1
*            OTHERS                = 2.
*        IF SY-SUBRC <> 0.
*          MESSAGE I000(0K) WITH SY-SUBRC.
*        ENDIF.
*
*
*        IF  G_EXIT = ABAP_FALSE.
*
*          DELETE LT_OUTTAB_ASSOBJ WHERE SELFELD = ' '.
*          IF LINES( LT_OUTTAB_ASSOBJ ) > 1.
*            MESSAGE I111 DISPLAY LIKE 'E' .
**           Selektieren Sie bitte genau einen Eintrag in der Liste
*          ELSE.
*            " Wert übernehmen
*            READ TABLE LT_OUTTAB_ASSOBJ ASSIGNING <LS_OUTTAB_ASSOBJ> INDEX 1.
*            MOVE-CORRESPONDING <LS_OUTTAB_ASSOBJ> TO <LS_GRID_DATA>-ASSOBJ.
*
*            GO_ANLAGE_MNGR->ANLAGE_UPDATE( IS_DETAIL = <LS_GRID_DATA>-ZPD_ZTGMOD_ANLAGE ).
*
*
*            GO_ANLAGE_MNGR->ANLAGE_REFRESH(
*             EXPORTING
*               IS_DETAIL         = <LS_GRID_DATA>-ZPD_ZTGMOD_ANLAGE
*               ID_SET_KONTIERUNG = ABAP_TRUE
*             EXCEPTIONS
*               ERROR     = 1
*               OTHERS    = 2
*                  ).
*            IF SY-SUBRC <> 0.
*              MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
*                            .
*            ENDIF.
*
**           get data and refresh
*            GS_GUI_BUFFER-GRID_DO_GET_DATA  = ABAP_TRUE.
*            GS_GUI_BUFFER-GRID_DO_REFRESH   = ABAP_TRUE.
*
*          ENDIF.
*        ENDIF.
*
*      WHEN OTHERS.
*        RETURN.
*    ENDCASE.

* Erreignis wurde behandelt
    er_event_data->m_event_handled = abap_true.

  ENDMETHOD.                    "HANDLE_ONF4

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION
