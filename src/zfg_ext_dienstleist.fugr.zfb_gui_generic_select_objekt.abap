FUNCTION zfb_gui_generic_select_objekt.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ID_TITLE) TYPE  CLIKE OPTIONAL
*"     REFERENCE(ID_ACTIVITY) TYPE  RECA1_ACTIVITY
*"     REFERENCE(ID_DIENSTLEISTUNG) TYPE  ZDDIENSTLEISTUNG DEFAULT
*"       'MEAS'
*"  EXPORTING
*"     REFERENCE(EF_CANCEL) TYPE  ABAP_BOOL
*"     REFERENCE(ET_OBJEKTLISTE) TYPE  Z_T_ZST_OBJEKTLISTE
*"     VALUE(ET_TAB) TYPE  Z_T_ZTEXD_FLACHE
*"     VALUE(P_LIEF) TYPE  ZCUS_EXTLIEF-EXT_DIENSTLIF
*"     VALUE(P_DATE) TYPE  SY-DATUM
*"     VALUE(P_ANDGR) TYPE  ZTEXD_FLACHE-EXT_AENDGRUND
*"     VALUE(P_PROJ) TYPE  ZTEXD_FLACHE-PROJEKTNAME
*"     VALUE(P_AUFTR) TYPE  ZTEXD_FLACHE-AUFTR_VERM
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

* BODY
  DATA: ls_misperiode      TYPE zsmisperiode.
  FIELD-SYMBOLS <ls_objektliste> LIKE LINE OF et_objektliste.
  DATA rs_vibdro           TYPE vibdro.

  gd_activity       = id_activity.
  gd_dienstleistung = id_dienstleistung.

  gs_gui-title = id_title.
  IF gs_gui-title IS INITIAL.
    gs_gui-title = 'Objekte Selektieren'(ti3).
  ENDIF.

  CALL SCREEN '5100'
    STARTING AT 1 1.

  IF gf_cancel = abap_false.
*   Get MIS Periode zum Planbeginn
    zcl_pdmis_services=>get_periode(
    EXPORTING
      id_laufdatum  = pr_date
    CHANGING
      cs_misperiode = ls_misperiode
      ).

***  Selektions-PARAMETER ***************************
*    P_LIEF TYPE ZCUS_EXTLIEF-EXT_DIENSTLIF,
*    P_MEAS TYPE ZCUS_EXTMEAS-MEAS,
*    P_DATE TYPE SY-DATUM DEFAULT SY-DATUM.

*    SELECT-OPTIONS:

*    P_XMBEZ     FOR ZTZMIS_ME-XMBEZ,
*    P_ORT02     FOR ZTZMIS_ME-ORT02,
*    SIEDLUNG    FOR ZTZMIS_ME-SIEDLUNG,
*    P_PSTLZ     FOR ZTZMIS_ME-PSTLZ,
*    P_ORT01     FOR ZTZMIS_ME-ORT01,
*    P_STRAS     FOR ZTZMIS_ME-STRAS,
*    P_HAUSNR    FOR ZTZMIS_ME-HAUSNR.

*    P_BUKRS FOR ZTZMIS_ME-BUKRS,
*    P_SWENR FOR ZTZMIS_ME-SWENR,
*    P_SGRNR FOR ZTZMIS_ME-SGRNR,
*    P_SGENR FOR ZTZMIS_ME-SGENR,
*    P_SMENR FOR ZTZMIS_ME-SMENR,
*    P_KDST  FOR ZTZMIS_ME-KDST.
*    P_SNUNR FOR ZTZMIS_ME-SNUNR.
***  Selektions-PARAMETER ***************************

*   Set Parameter
    p_lief   = pr_lief.
    p_date   = pr_date.
    p_andgr  = pr_andgr.
    p_proj   = pr_proj.
    p_auftr  = pr_auftr.


    IF id_activity = reca1_activity-create.
* Get Customizing zur Bemessung
      DATA: et_cust_meas_x TYPE z_t_zv_dbextmeas_x,
            ls_cust_meas_x LIKE LINE OF et_cust_meas_x.

      zcl_cust_zv_dbextmeas=>get_list_by_dienstleistung_x(
      EXPORTING
        id_dienstleistung = id_dienstleistung
      IMPORTING
        et_list_x         = et_cust_meas_x
      EXCEPTIONS
        not_found         = 1
        OTHERS            = 2
        ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING error.
      ENDIF.

*     Get Customising zu Select-Nutzungsarten
      DATA: ls_snunr           LIKE LINE OF p_snunr.
      DATA: et_cust_snunr TYPE STANDARD TABLE OF  tivbdmeasro,
            ls_cust_snunr LIKE LINE OF et_cust_snunr.
*     Get Customizing zum Nutzungsart und Bemessung
      SELECT * FROM tivbdmeasro INTO TABLE et_cust_snunr
      FOR ALL ENTRIES IN et_cust_meas_x
      WHERE meas       = et_cust_meas_x-meas
      AND  usageforro <> ' '.
      IF et_cust_snunr[] IS INITIAL.
        MESSAGE e004(zext_dienstl) WITH 'ZV_DBEXTMEAS' 'TIVBDMEASRO' RAISING error.
*   Cust Bemessungsart & : Einstellungen pro Nutzungsart nicht definiert &
      ENDIF.


*     Dupletten löschen
      IF p_snunr[] IS INITIAL.
        LOOP AT et_cust_snunr INTO ls_cust_snunr.
          CLEAR ls_snunr.
          ls_snunr-sign   = 'I'.
          ls_snunr-option = 'EQ'.
          ls_snunr-low    = ls_cust_snunr-snunr.
          APPEND ls_snunr TO p_snunr.
        ENDLOOP.
      ENDIF.

*     GET MIS-Objekte
      DATA: lt_zv_get_mis_me TYPE STANDARD TABLE OF zv_get_mis_me,
            ls_zv_get_mis_me LIKE LINE OF lt_zv_get_mis_me.

      SELECT * FROM  zv_get_mis_me INTO TABLE lt_zv_get_mis_me
                     WHERE gjahr = ls_misperiode-gjahr
                       AND monat = ls_misperiode-monat
                       AND bukrs IN p_bukrs
                       AND swenr IN p_swenr
                       AND sgenr IN p_sgenr
                       AND sgrnr IN p_sgrnr
                       AND smenr IN p_smenr
                       AND kdst  IN p_kdst
                       AND snunr IN p_snunr
*                       AND XMBEZ IN P_XMBEZ
                       AND ort02 IN p_ort02
*                       AND SIEDLUNG IN SIEDLUNG
                       AND pstlz IN p_pstlz
                       AND ort01 IN p_ort01
                       AND stras IN p_stras
                       AND hausnr IN p_hausnr.

      IF sy-subrc = 0.
        LOOP AT lt_zv_get_mis_me INTO ls_zv_get_mis_me.
          APPEND INITIAL LINE TO et_objektliste ASSIGNING <ls_objektliste>.
          MOVE-CORRESPONDING ls_zv_get_mis_me TO <ls_objektliste>.
*         Get Objnr
          cl_redb_vibdro=>get_detail(
            EXPORTING
              id_bukrs            = ls_zv_get_mis_me-bukrs
              id_swenr            = ls_zv_get_mis_me-swenr
              id_smenr            = ls_zv_get_mis_me-smenr
            RECEIVING
              rs_detail           = rs_vibdro
            EXCEPTIONS
              not_found           = 1
              OTHERS              = 2
                 ).
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            .
          ENDIF.

          <ls_objektliste>-objnr = rs_vibdro-objnr.

*         Set Counter für die Objektsummierung
          <ls_objektliste>-zcount = 1.

*         Get Icon
          PERFORM get_icon USING    <ls_objektliste>-snunr
                                    <ls_objektliste>-xksnunr
                           CHANGING <ls_objektliste>-icon_detail.

        ENDLOOP.

      ENDIF.

    ELSE. " Activity = '02' and Activity = '03'

      DATA: range_lief     TYPE RANGE OF zd_ext_dienstlif,
            ls_range_lief  LIKE LINE OF range_lief,
            range_andgr	   TYPE RANGE OF ztexd_flache-ext_aendgrund,
            range_proj     TYPE RANGE OF ztexd_flache-projektname,
            range_auftr	   TYPE RANGE OF ztexd_flache-auftr_verm,
            ls_range_andgr LIKE LINE OF range_andgr,
            ls_range_proj  LIKE LINE OF range_proj,
            ls_range_auftr LIKE LINE OF range_auftr.

*     Filter auf Dienstleister
      IF p_lief IS NOT INITIAL.
        ls_range_lief-sign   = 'I'.
        ls_range_lief-option = 'EQ'.
        ls_range_lief-low    = p_lief.
        APPEND ls_range_lief TO range_lief.
      ENDIF.

*     Filter auf Änderungsgrund
      IF p_andgr IS NOT INITIAL.
        ls_range_andgr-sign   = 'I'.
        ls_range_andgr-option = 'EQ'.
        ls_range_andgr-low    = p_andgr.
        APPEND ls_range_andgr TO range_andgr.
      ENDIF.

*     Filter auf Projekt
      IF p_proj IS NOT INITIAL.
        ls_range_proj-sign   = 'I'.
        ls_range_proj-option = 'EQ'.
        ls_range_proj-low    = p_proj.
        APPEND ls_range_proj TO range_proj.
      ENDIF.

*     Filter auf Auftrag
      IF p_auftr IS NOT INITIAL.
        ls_range_auftr-sign   = 'I'.
        ls_range_auftr-option = 'EQ'.
        ls_range_auftr-low    = p_auftr.
        APPEND ls_range_auftr TO range_auftr.
      ENDIF.

      REFRESH et_objektliste.

      SELECT *  FROM ztexd_flache INTO  TABLE et_tab
       WHERE ( bukrs IN p_bukrs )
         AND ( swenr IN p_swenr )
         AND ( sgenr IN p_sgenr )
         AND ( sgrnr IN p_sgrnr )
         AND ( smenr IN p_smenr )
         AND ( kdst  IN p_kdst )
         AND ( ext_dienstlif IN range_lief )
         AND ( ext_aendgrund IN range_andgr )
         AND ( projektname   IN range_proj )
         AND ( auftr_verm    IN range_auftr )
         AND ( snunr         IN p_snunr )
         AND ( meas          IN p_meas )
*         AND ( XMBEZ IN P_XMBEZ )
         AND ( city2 IN p_ort02 )
*         AND ( SIEDLUNG IN SIEDLUNG )
         AND ( post_code1 IN p_pstlz )
         AND ( city1 IN p_ort01 )
         AND ( street IN p_stras )
         AND ( house_num1 IN p_hausnr ) .






    ENDIF.

  ENDIF.

  gd_repid = sy-repid.

  PERFORM at_selection_screen_ranges     IN PROGRAM (gd_repid) IF FOUND.


  ef_cancel = gf_cancel.

ENDFUNCTION.
