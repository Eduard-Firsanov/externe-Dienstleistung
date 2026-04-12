*---------------------------------------------------------------------*
*    program for:   VIEWPROC_ZV_EXTMEAS
*---------------------------------------------------------------------*
FUNCTION viewproc_zv_extmeas           .
*----------------------------------------------------------------------*
* Initialization: set field-symbols etc.                               *
*----------------------------------------------------------------------*
  IF last_view_info NE view_name.
    ASSIGN zv_extmeas TO <table1>.
    ASSIGN *zv_extmeas TO <initial>.
    ASSIGN status_zv_extmeas TO <status>.
    PERFORM initialisieren.
  ENDIF.
  PERFORM justify_action_mode.
  MOVE: view_action TO maint_mode,
        corr_number TO corr_nbr.

*----------------------------------------------------------------------*
* Get data from database                                               *
*----------------------------------------------------------------------*
  IF fcode EQ read OR fcode EQ read_and_edit.
    PERFORM prepare_read_request.
    IF x_header-frm_rp_get NE space.
      PERFORM (x_header-frm_rp_get) IN PROGRAM.
    ELSE.
      PERFORM get_data_zv_extmeas.
    ENDIF.
    IF fcode EQ read_and_edit. fcode = edit. ENDIF.
  ENDIF.

  CASE fcode.
    WHEN  edit.                          " Edit read data
      PERFORM call_dynpro.
      PERFORM check_upd.
*....................................................................*

    WHEN save.                           " Write data into database
      PERFORM prepare_saving.
      IF <status>-upd_flag NE space.
        IF x_header-frm_rp_upd NE space.
          PERFORM (x_header-frm_rp_upd) IN PROGRAM.
        ELSE.
          IF sy-subrc EQ 0.
            PERFORM db_upd_zv_extmeas.
          ENDIF.
        ENDIF.
        PERFORM after_saving.
      ENDIF.
*....................................................................*

    WHEN reset_list.     " Refresh all marked entries of EXTRACT from db
      PERFORM reset_entries USING list_bild.
*....................................................................*

    WHEN reset_entry.               " Refresh single entry from database
      PERFORM reset_entries USING detail_bild.
*.......................................................................
  ENDCASE.
  MOVE status_zv_extmeas-upd_flag TO update_required.
ENDFUNCTION.
