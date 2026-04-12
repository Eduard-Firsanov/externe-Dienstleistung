*---------------------------------------------------------------------*
*    program for:   VIEWFRAME_ZV_VERZEICHNIS
*---------------------------------------------------------------------*
FUNCTION viewframe_zv_verzeichnis      .

  DATA: enqueue_processed TYPE c. "flag: view enqueued by VIEWFRAME_...

*-<<<-------------------------------------------------------------->>>>*
* Entrypoint after changing maintenance mode (show <--> update)        *
*-<<<-------------------------------------------------------------->>>>*
  DO.
*----------------------------------------------------------------------*
* Select data from database                                            *
*----------------------------------------------------------------------*
    CALL FUNCTION 'VIEWPROC_ZV_VERZEICHNIS'
      EXPORTING
        fcode                     = read
        view_action               = view_action
        view_name                 = view_name
      TABLES
        excl_cua_funct            = excl_cua_funct
        extract                   = zv_verzeichnis_extract
        total                     = zv_verzeichnis_total
        x_header                  = x_header
        x_namtab                  = x_namtab
        dba_sellist               = dba_sellist
        dpl_sellist               = dpl_sellist
        corr_keytab               = e071k_tab
      EXCEPTIONS
        missing_corr_number       = 1
        no_value_for_subset_ident = 2.
    CASE sy-subrc.
      WHEN 1.
        RAISE missing_corr_number.
      WHEN 2.
        RAISE no_value_for_subset_ident.
    ENDCASE.
*-<<<-------------------------------------------------------------->>>>*
* Entrypoint after saving data into database                           *
* Entrypoint after refreshing selected entries from database           *
*-<<<-------------------------------------------------------------->>>>*
    DO.
*----------------------------------------------------------------------*
* Edit data                                                            *
*----------------------------------------------------------------------*
      DO.
        CALL FUNCTION 'VIEWPROC_ZV_VERZEICHNIS'
          EXPORTING
            fcode                     = edit
            view_action               = maint_mode
            view_name                 = view_name
            corr_number               = corr_number
          IMPORTING
            ucomm                     = function
            update_required           = status_zv_verzeichnis-upd_flag
          TABLES
            excl_cua_funct            = excl_cua_funct
            extract                   = zv_verzeichnis_extract
            total                     = zv_verzeichnis_total
            x_header                  = x_header
            x_namtab                  = x_namtab
            dba_sellist               = dba_sellist
            dpl_sellist               = dpl_sellist
            corr_keytab               = e071k_tab
          EXCEPTIONS
            missing_corr_number       = 1
            no_value_for_subset_ident = 2.
        CASE sy-subrc.
          WHEN 1.
            IF maint_mode EQ transportieren AND view_action EQ aendern.
              MOVE view_action TO maint_mode.
            ELSE.
              PERFORM before_leaving_frame_function
                                         USING x_header-frm_bf_end.
              RAISE missing_corr_number.
            ENDIF.
          WHEN 2.
            RAISE no_value_for_subset_ident.
          WHEN OTHERS.
            EXIT.
        ENDCASE.
      ENDDO.
*----------------------------------------------------------------------*
*  Handle usercommands...                                              *
*  ...at first handle commands which could cause loss of data          *
*----------------------------------------------------------------------*
      IF function EQ back. function = end. ENDIF.
      IF ( function EQ switch_to_show_mode OR
           function EQ get_another_view    OR
           function EQ switch_transp_to_upd_mode OR
           function EQ end ) AND
status_zv_verzeichnis-upd_flag NE space.
        PERFORM beenden.
        CASE sy-subrc.
          WHEN 0.
            CALL FUNCTION 'VIEWPROC_ZV_VERZEICHNIS'
              EXPORTING
                fcode                     = save
                view_action               = maint_mode
                view_name                 = view_name
                corr_number               = corr_number
              IMPORTING
                update_required           = status_zv_verzeichnis-upd_flag
              TABLES
                excl_cua_funct            = excl_cua_funct
                extract                   = zv_verzeichnis_extract
                total                     = zv_verzeichnis_total
                x_header                  = x_header
                x_namtab                  = x_namtab
                dba_sellist               = dba_sellist
                dpl_sellist               = dpl_sellist
                corr_keytab               = e071k_tab
              EXCEPTIONS
                missing_corr_number       = 1
                no_value_for_subset_ident = 2
                saving_correction_failed  = 3.
            CASE sy-subrc.
              WHEN 0.
                IF status_zv_verzeichnis-upd_flag EQ space. EXIT. ENDIF.
              WHEN 1. RAISE missing_corr_number.
              WHEN 2. RAISE no_value_for_subset_ident.
              WHEN 3.
            ENDCASE.
          WHEN 8. EXIT.
          WHEN 12.
        ENDCASE.
*----------------------------------------------------------------------*
*  ...2nd: transport request                                           *
*----------------------------------------------------------------------*
      ELSEIF function EQ transport.
        IF status_zv_verzeichnis-upd_flag NE space.
          PERFORM transportieren.
          CASE sy-subrc.
            WHEN 0.
              CALL FUNCTION 'VIEWPROC_ZV_VERZEICHNIS'
                EXPORTING
                  fcode                     = save
                  view_action               = maint_mode
                  view_name                 = view_name
                  corr_number               = corr_number
                IMPORTING
                  update_required           =
                                              status_zv_verzeichnis-upd_flag
                TABLES
                  excl_cua_funct            = excl_cua_funct
                  extract                   = zv_verzeichnis_extract
                  total                     = zv_verzeichnis_total
                  x_header                  = x_header
                  x_namtab                  = x_namtab
                  dba_sellist               = dba_sellist
                  dpl_sellist               = dpl_sellist
                  corr_keytab               = e071k_tab
                EXCEPTIONS
                  missing_corr_number       = 1
                  no_value_for_subset_ident = 2
                  saving_correction_failed  = 3.
              CASE sy-subrc.
                WHEN 0. maint_mode = transportieren.
                WHEN 1. RAISE missing_corr_number.
                WHEN 2. RAISE no_value_for_subset_ident.
                WHEN 3.
              ENDCASE.
            WHEN 8.
              EXIT.
            WHEN 12.
          ENDCASE.
        ELSE.
          maint_mode = transportieren.
        ENDIF.
*----------------------------------------------------------------------*
*  ...now reset or save requests                                       *
*----------------------------------------------------------------------*
      ELSEIF function EQ reset_list  OR
             function EQ reset_entry OR
             function EQ save.
*----------------------------------------------------------------------*
*  Refresh selected entries from database or save data into database   *
*----------------------------------------------------------------------*
        CALL FUNCTION 'VIEWPROC_ZV_VERZEICHNIS'
          EXPORTING
            fcode                     = function
            view_action               = maint_mode
            view_name                 = view_name
            corr_number               = corr_number
          IMPORTING
            update_required           = status_zv_verzeichnis-upd_flag
          TABLES
            excl_cua_funct            = excl_cua_funct
            extract                   = zv_verzeichnis_extract
            total                     = zv_verzeichnis_total
            x_header                  = x_header
            x_namtab                  = x_namtab
            dba_sellist               = dba_sellist
            dpl_sellist               = dpl_sellist
            corr_keytab               = e071k_tab
          EXCEPTIONS
            missing_corr_number       = 1
            no_value_for_subset_ident = 2
            saving_correction_failed  = 3.
        CASE sy-subrc.
          WHEN 1. RAISE missing_corr_number.
          WHEN 2. RAISE no_value_for_subset_ident.
          WHEN 3.
        ENDCASE.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
*----------------------------------------------------------------------*
*  ...now other commands...                                            *
*----------------------------------------------------------------------*
    CASE function.
      WHEN switch_to_show_mode.
*     change maintenance mode from update to show
        PERFORM enqueue USING 'D' x_header-frm_af_enq.    "dequeue view
        CLEAR enqueue_processed.
        view_action = anzeigen.
      WHEN switch_to_update_mode.
*     change maintenance mode from show to update
        PERFORM enqueue USING 'E' x_header-frm_af_enq.    "enqueue view
        IF sy-subrc EQ 0.
          MOVE 'X' TO enqueue_processed.
          view_action = aendern.
        ENDIF.
      WHEN switch_transp_to_upd_mode.
*     change maintenance mode from transport to update
        view_action = aendern.
      WHEN transport.
*     change maintenance mode from update to transport
        view_action = transportieren.
      WHEN OTHERS.
        IF enqueue_processed NE space.
          PERFORM enqueue USING 'D' x_header-frm_af_enq.  "dequeue view
        ENDIF.
        PERFORM before_leaving_frame_function USING x_header-frm_bf_end.
        EXIT.
    ENDCASE.
  ENDDO.
ENDFUNCTION.
