*----------------------------------------------------------------------*
***INCLUDE LZFG_EXT_DIENSTLEISTF03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_PARAMETER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PR_LIEF  text
*----------------------------------------------------------------------*
FORM check_parameter  USING   p_param TYPE string
                              p_value .


  IF p_value IS INITIAL.
    RETURN.
  ENDIF.


  CASE p_param.
    WHEN 'PR_LIEF'.

      DATA: rs_detail        TYPE zcust_zcus_extlief,
            id_ext_dienstlif TYPE zcust_zcus_extlief-ext_dienstlif.
      id_ext_dienstlif = p_value.
      zcl_cust_zcus_extlief=>get_detail(
        EXPORTING
          id_dienstleistung = gd_dienstleistung
          id_ext_dienstlif  = id_ext_dienstlif
          id_require        = 'K'
        RECEIVING
          rs_detail         = rs_detail
        EXCEPTIONS
          not_found         = 1
          OTHERS            = 2
             ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'PR_ANDGR'.

      DATA id_ext_aendgrund  TYPE zcust_zcus_extaendgr-ext_aendgrund.
      DATA rs_detail_andgr   TYPE zcust_zcus_extaendgr.
      id_ext_aendgrund = p_value.
      zcl_cust_zcus_extaendgr=>get_detail(
        EXPORTING
          id_dienstleistung = gd_dienstleistung
          id_ext_aendgrund  = id_ext_aendgrund
          id_require        = 'K'
        RECEIVING
          rs_detail         = rs_detail_andgr
        EXCEPTIONS
          not_found         = 1
          OTHERS            = 2
             ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN 'PR_AUFTR'.

      cl_reca_ddic_doma=>check_value(
        EXPORTING
          id_name   = 'ZDAUFTR_VERM'
          id_value  = p_value
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2
             ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " CHECK_PARAMETER
