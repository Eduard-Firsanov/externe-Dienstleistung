*----------------------------------------------------------------------*
***INCLUDE LZFG_EXT_DIENSTLEISTO02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PBO_TITLE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_title OUTPUT.
* BODY
  CALL FUNCTION 'RECA_GUI_SET_POPUP_PFSTATUS'.

  CALL FUNCTION 'RECA_GUI_SET_TITLEBAR'
    EXPORTING
      id_text1 = gs_gui-title.

ENDMODULE.                 " PBO_TITLE  OUTPUT
