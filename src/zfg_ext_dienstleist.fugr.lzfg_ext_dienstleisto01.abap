*----------------------------------------------------------------------*
***INCLUDE LZFG_HEIZUNG_EINKAUFO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  S0100_START  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE s0100_start OUTPUT.
  lcl_main_program=>run_main_program( ).
  IF gs_subscreen-dynnr IS INITIAL.
    gs_subscreen-dynnr = '0200'.
*    G_GUI_STATUS      = 'MAIN'.
  ENDIF.
  IF gs_subscreen-repid IS INITIAL.
    gs_subscreen-repid = sy-repid.
  ENDIF.
ENDMODULE.                 " S0100_START  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  BILD_INITIALISIEREN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE bild_initialisieren OUTPUT.
  PERFORM bild_initialisieren.
ENDMODULE.                 " BILD_INITIALISIEREN  OUTPUT
