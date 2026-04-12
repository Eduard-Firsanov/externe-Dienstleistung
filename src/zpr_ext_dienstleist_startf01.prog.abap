*----------------------------------------------------------------------*
***INCLUDE ZPR_EXT_DIENSTLEIST_STARTF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  STATUS_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM status_0100 .

  IF gd_status_flag IS INITIAL.
    PERFORM set_status
                USING
                   reca1_activity-rename.

    SET TITLEBAR  'MAIN'.

    gd_status_flag = abap_true.
  ENDIF.

ENDFORM.                    " STATUS_0100
*&---------------------------------------------------------------------*
*&      Module  PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_0100 OUTPUT.


  CALL FUNCTION 'ZFB_EXT_DIENSTLEIST_START'
    IMPORTING
      es_subscreen = gs_subscreen.


ENDMODULE.                 " PBO_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PAI_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_0100 INPUT.


  PERFORM pai_0100.

ENDMODULE.                 " PAI_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  PAI_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_0100 .
  DATA:
   ld_okcode    LIKE gd_okcode.

  ld_okcode = gd_okcode.
  CLEAR gd_okcode.

  CASE ld_okcode.

    WHEN reca2_okcode_appl-back OR
         'ENDE' OR
         reca2_okcode_appl-exit.

      CLEAR ld_okcode.

      LEAVE PROGRAM.

  ENDCASE.
ENDFORM.                    " PAI_0100
*&---------------------------------------------------------------------*
*&      Form  START_OF_SELEKTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM start_of_selektion .

  CALL SCREEN 100.

ENDFORM.                    " START_OF_SELEKTION
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialization .

ENDFORM.                    " INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  set_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RECA1_ACTIVITY_DISPLAY  text
*----------------------------------------------------------------------*
FORM set_status  USING    p_id_activity TYPE reca1_activity.

  DATA:
    lt_excl_ucomm TYPE syucomm_t,
    ls_ucomm      TYPE syucomm.

  IF p_id_activity = reca1_activity-display.
    APPEND 'SAVE' TO lt_excl_ucomm.
  ELSEIF p_id_activity = reca1_activity-rename.
    APPEND 'SAVE' TO lt_excl_ucomm.
    APPEND 'BACK' TO lt_excl_ucomm.
    APPEND 'ENDE' TO lt_excl_ucomm.
  ENDIF.

  SET PF-STATUS 'DEFAULT_AEND' OF PROGRAM sy-repid  " Anzeigen
       EXCLUDING  lt_excl_ucomm IMMEDIATELY.

ENDFORM.                    " set_status
