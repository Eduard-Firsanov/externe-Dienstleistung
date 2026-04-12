FUNCTION zfb_gui_ext_leist_pbo.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ID_ACTIVITY) TYPE  SY-UCOMM
*"     REFERENCE(IF_READONLY) TYPE  FLAG OPTIONAL
*"     REFERENCE(IO_NAVIGATION_DATA) TYPE REF TO
*"        CL_RECA_DATA_CONTAINER OPTIONAL
*"     REFERENCE(IO_CURRENT_NAV_DATA) TYPE REF TO
*"        CL_RECA_DATA_CONTAINER OPTIONAL
*"  EXPORTING
*"     VALUE(ES_SUBSCREEN) TYPE  RECASCREEN
*"----------------------------------------------------------------------



  DATA:
    lf_locked_all  TYPE recabool,
    lo_flache_mngr TYPE REF TO  zif_pd_ztexd_flache_mngr,
    ok_code        TYPE sytcode.

* set current subscreen
  es_subscreen-repid = sy-repid.
  es_subscreen-dynnr = '2000'.

  gd_anwactivity = id_activity.

  IF go_flache_mngr IS BOUND.
    ok_code = gd_anwactivity.
    PERFORM on_save USING ok_code. " F.E. um Speicher zu prüfen
  ENDIF.


  CLEAR: go_flache_mngr, gs_gui_buffer-grid_do_change.



  CALL FUNCTION 'RECA_GUI_MSGLIST_INIT'.


  CASE gd_anwactivity.

    WHEN 'MEAS_ANL'.

      PERFORM on_meas_anl.

    WHEN 'MEAS_ANZ' OR 'MEAS_HELP_1'.

      PERFORM on_meas_aend
                  USING
                     reca1_activity-display.

    WHEN 'MEAS_AEND'.

      PERFORM on_meas_aend
                  USING
                     reca1_activity-change.


  ENDCASE.



*   new fieldcat
  PERFORM grid_new_fieldcat.


  IF  go_flache_mngr IS NOT BOUND.
    SUBMIT zpr_ext_dienstleist_start AND RETURN.
  ENDIF.

  CHECK go_flache_mngr IS BOUND.

* set activity to objects one or force display mode
  IF if_readonly = abap_true.
    gd_activity = reca1_activity-display.
    gf_readonly = abap_true.
  ELSE.
    gd_activity = go_flache_mngr->md_activity.
    gf_readonly = abap_false.
*   locked?
    CALL METHOD go_flache_mngr->get_fieldstatus
      EXPORTING
        id_status     = reca1_fieldstatuscontext-locked
      IMPORTING
        ef_locked_all = lf_locked_all.
    IF lf_locked_all = abap_true.
      gd_activity = reca1_activity-display.
    ENDIF.
    IF gd_activity = reca1_activity-display.
      gf_readonly = abap_true.
    ENDIF.
  ENDIF.

* do/remember navigation
  IF io_navigation_data IS BOUND.
    PERFORM do_navigation
    USING io_navigation_data.
  ENDIF.
  go_navigation_data      = io_navigation_data.
  go_current_nav_data     = io_current_nav_data.


ENDFUNCTION.
