*&---------------------------------------------------------------------*
*&  Include           ZIN_OBJEKT_SELECTION
*&---------------------------------------------------------------------*
DATA: gf_cancel TYPE abap_bool,
      BEGIN OF gs_gui,
        title     TYPE zdsytitle,
        subscreen TYPE recascreen,
      END   OF gs_gui.

DATA: gd_activity       TYPE reca1_activity,
      gd_dienstleistung TYPE zddienstleistung.

TABLES: ztzmis_me,
        ztexd_flache,
        zcus_extlief, "  Cust: Ext. Dienstleistungslieferant
        zcus_extmeas. "  Cust: Ext. Dienstleistungslieferant

SELECTION-SCREEN BEGIN OF SCREEN 5000 AS SUBSCREEN. "NESTING LEVEL 4.
  SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-f01.
    PARAMETER: pr_lief  TYPE zcus_extlief-ext_dienstlif MATCHCODE OBJECT zsh_extlief ,
               pr_andgr TYPE ztexd_flache-ext_aendgrund,
               pr_proj  TYPE ztexd_flache-projektname MATCHCODE OBJECT zsh_projektname,
               pr_auftr TYPE ztexd_flache-auftr_verm,
               pr_date  TYPE stichtag DEFAULT sy-datum MODIF ID gr1.
  SELECTION-SCREEN END OF BLOCK b0.

  SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-gsa ##TEXT_POOL.
    SELECT-OPTIONS:
*    P_XMBEZ     FOR ZTZMIS_ME-XMBEZ,
       p_ort01     FOR ztzmis_me-ort01,
       p_ort02     FOR ztzmis_me-ort02,
*    SIEDLUNG    FOR ZTZMIS_ME-SIEDLUNG,
       p_pstlz     FOR ztzmis_me-pstlz,
       p_stras     FOR ztzmis_me-stras,
       p_hausnr    FOR ztzmis_me-hausnr.
  SELECTION-SCREEN END OF BLOCK a1.

  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-g01.
    SELECT-OPTIONS:
        p_bukrs FOR ztzmis_me-bukrs,
        p_swenr FOR ztzmis_me-swenr,
        p_sgrnr FOR ztzmis_me-sgrnr,
        p_sgenr FOR ztzmis_me-sgenr,
        p_smenr FOR ztzmis_me-smenr,
        p_kdst  FOR ztzmis_me-kdst,
        p_snunr FOR ztexd_flache-snunr MATCHCODE OBJECT zsh_rebdusagetype ,
        p_meas  FOR ztexd_flache-meas MODIF ID gr2.

  SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN END OF SCREEN 5000.






AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF gd_activity <> reca1_activity-create.
      IF screen-group1 CP 'GR1'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.

      IF screen-group1 CP 'GR2'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.

    ELSE.
      IF screen-name = 'PR_LIEF'.
        screen-required = 1.
        MODIFY SCREEN.
      ENDIF.

      IF screen-group1 CP 'GR2'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.

    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON pr_lief.
  PERFORM check_parameter USING 'PR_LIEF'
                                pr_lief.

AT SELECTION-SCREEN ON pr_andgr.
  PERFORM check_parameter USING  'PR_ANDGR'
                                 pr_andgr.


AT SELECTION-SCREEN ON pr_auftr.
  PERFORM check_parameter USING 'PR_AUFTR'
                                pr_auftr.
