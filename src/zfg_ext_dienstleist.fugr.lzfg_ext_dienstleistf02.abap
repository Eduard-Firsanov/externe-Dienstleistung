*----------------------------------------------------------------------*
***INCLUDE LZFG_EXT_DIENSTLEISTF02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_ICON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LS_OBJEKTLISTE>_SNUNR  text
*      -->P_<LS_OBJEKTLISTE>_XKSNUNR  text
*      <--P_<LS_OBJEKTLISTE>_ICON_DETAIL  text
*----------------------------------------------------------------------*
FORM get_icon
  USING
      id_snunr  TYPE snunr
      id_xksnunr  TYPE xkbez
CHANGING
      rd_icon.

  TYPE-POOLS:
  icon.

  DATA:
    ld_icon      TYPE icon_d,
    ld_text      TYPE c LENGTH 40, "fixme
    ld_quickinfo TYPE icont-quickinfo.

  STATICS: mt_r_snunr_stp TYPE  /datrain/fl_ttr_snunr,
           mt_r_snunr_gew TYPE  /datrain/fl_ttr_snunr.

* INIT RESULTS
  CLEAR rd_icon.
  IF mt_r_snunr_stp IS INITIAL.
    DATA:
      rt_snunrint TYPE RANGE OF snunrint,
      rs_snunrint LIKE LINE OF rt_snunrint,
      ls_tiv01    TYPE tiv01,
      ls_r_snunr  LIKE LINE OF mt_r_snunr_stp.

    IF mt_r_snunr_stp[] IS INITIAL.
* Nutzungsarten der Stellplätze 04,05,09
* interne Nutzungsart
      REFRESH rt_snunrint.
      rs_snunrint-option = 'EQ'.
      rs_snunrint-sign   = 'I'.

      rs_snunrint-low = '03'. "Gewerbe
      APPEND rs_snunrint TO rt_snunrint.
      rs_snunrint-low = '04'. "Stellplatz gew.
      APPEND rs_snunrint TO rt_snunrint.
      rs_snunrint-low = '05'. "Stellplatz priv.
      APPEND rs_snunrint TO rt_snunrint.
      rs_snunrint-low = '09'. "Stellplatz gem.
      APPEND rs_snunrint TO rt_snunrint.

      SELECT *
      FROM   tiv01
      INTO   ls_tiv01
      WHERE  snunrint IN rt_snunrint.

        ls_r_snunr-option = 'EQ'.
        ls_r_snunr-sign   = 'I'.
        ls_r_snunr-low    = ls_tiv01-snunr.

        IF ls_tiv01-snunrint = '03'. "Gewerbe
          APPEND ls_r_snunr TO mt_r_snunr_gew.
        ELSE.
          APPEND ls_r_snunr TO mt_r_snunr_stp.
        ENDIF.

      ENDSELECT.
    ENDIF.
  ENDIF.

* Icon bestimmen

  IF id_snunr IN mt_r_snunr_stp.
    ld_icon = icon_car.
  ELSEIF id_snunr IN mt_r_snunr_gew.
    ld_icon = icon_workplace. "Bürostuhl
  ELSE.
    "Standardicon MO nachlesen 'ICON_LIFE_EVENTS'
    ld_icon = cl_recac_icon=>get_icon(
    id_iconfor    = reca1_iconfor-objtype       "'1'
    id_iconforkey = reca1_objtype-rental_object "'IM'
    ).
  ENDIF.


  rd_icon = cl_reca_gui_services=>create_icon(
  id_icon       = ld_icon
  id_quickinfo  = id_xksnunr
  ).

ENDFORM.                    " GET_ICON
