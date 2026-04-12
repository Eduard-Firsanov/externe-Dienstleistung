*----------------------------------------------------------------------*
***INCLUDE LZFG_EXT_DIENSTLEISTF04.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SHOW_MESSAGE_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LO_MSGLIST  text
*----------------------------------------------------------------------*
FORM show_message_list
USING io_msglist    TYPE REF TO if_reca_message_list.

  CALL FUNCTION 'RECA_GUI_MSGLIST_INIT'.

  CALL FUNCTION 'RECA_GUI_MSGLIST_DISPLAY'
    EXPORTING
      io_msglist = io_msglist
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  ENDIF.

ENDFORM.                    " SHOW_MESSAGE_LIST
