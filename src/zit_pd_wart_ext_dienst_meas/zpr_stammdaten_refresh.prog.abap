*&---------------------------------------------------------------------*
*& Report  ZPR_STAMMDATEN_REFRESH
*&
*&---------------------------------------------------------------------*
*&
*& E.Firsanov Das Programm aktualisiert die Stammdaten
*& (für Nachtjob konzipiert) 17.05.2018
*& E.Firsanov Performansverbesserung 23.05.2020
*&---------------------------------------------------------------------*

REPORT zpr_stammdaten_refresh MESSAGE-ID zext_dienstl.

*=======================================================================
INCLUDE:
*======================================================================
  ifrecamsg.

TYPE-POOLS:
      abap,
      reca1.

TABLES ztexd_flache.

*=======================================================================
* Basic Objekten
*=======================================================================
DATA:
  go_flache_mngr TYPE REF TO  zif_pd_ztexd_flache_mngr,

  go_msglist     TYPE REF TO if_reca_message_list,
  dummy          TYPE string.

*=======================================================================
DATA:         "grid data (buffered for all pbo/pai-processing)
*=======================================================================
  gt_grid_data TYPE z_t_ztexd_flache,
  gs_grid_data TYPE ztexd_flache,
  et_list      TYPE z_t_ztexd_flache.

*2  Wohnfläche
*3  Nutzfläche
*4  Heizfläche


SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETER: p_seltag  TYPE ztexd_flache-stichtag DEFAULT sy-datum,
             p_meas    TYPE ztexd_flache-meas MATCHCODE OBJECT zsh_extmeas DEFAULT '0002'.

  SELECTION-SCREEN SKIP.
  PARAMETERS:
    p_mode                    TYPE recaprocessmode
    AS LISTBOX VISIBLE LENGTH 30
    DEFAULT 'E'    OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b01.



START-OF-SELECTION.

*  Finden Dienstleistungsmanager
  zcf_pd_ztexd_flache_mngr=>find_by_dienstleistung(
    EXPORTING
      id_dienstleistung = 'MEAS'
      id_activity       = reca1_activity-change
      id_auth_check     = abap_false
      id_enqueue        = abap_false
      if_reset_buffer   = abap_true
    RECEIVING
      ro_instance       = go_flache_mngr
     EXCEPTIONS
       error             = 1
       OTHERS            = 2
         ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  " Get Daten
  go_flache_mngr->get_list(
    IMPORTING
      et_list = gt_grid_data
         ).


END-OF-SELECTION.

* log
  CALL METHOD cf_reca_message_list=>create
    RECEIVING
      ro_instance = go_msglist.



  DELETE gt_grid_data WHERE me_update_flag = abap_true.     " EF 17744
  DELETE gt_grid_data WHERE meas <> p_meas.                 " EF 17744


  LOOP AT gt_grid_data INTO gs_grid_data.

    go_flache_mngr->objektliste_refresh(
    EXPORTING
      is_list = gs_grid_data
    EXCEPTIONS
      error   = 1
      OTHERS  = 2
      ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      INTO dummy.
      go_msglist->add_symsg( if_cumulate = abap_true ).
      CONTINUE.
    ENDIF.

  ENDLOOP.


  go_flache_mngr->if_reca_storable~store(
    EXPORTING
      if_in_update_task = abap_true
      if_force_check    = abap_false
    EXCEPTIONS
      error             = 1
      OTHERS            = 2
      ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    INTO dummy.
    go_msglist->add_symsg( if_cumulate = abap_true ).
  ENDIF.


  IF p_mode = 'E'.

    cf_reca_storable=>commit(
    ).

    CALL METHOD go_msglist->add
      EXPORTING
        id_msgty = 'I'
        id_msgid = 'RECABC'
        id_msgno = '000'
        id_msgv1 = 'Änderungen durchgeführt' ##NO_TEXT.

  ELSE.
    CALL METHOD go_msglist->add
      EXPORTING
        id_msgty = 'I'
        id_msgid = 'RECABC'
        id_msgno = '000'
        id_msgv1 = 'Testlauf: Keine Änderungen' ##NO_TEXT.

  ENDIF.






  CALL FUNCTION 'RECA_GUI_MSGLIST_POPUP'
    EXPORTING
      io_msglist          = go_msglist
      id_title            = 'Protokoll' ##NO_TEXT
      if_popup            = abap_false
      if_profile_detlevel = abap_true
      id_expand_level     = 2.

  go_msglist->store( ).
  cf_reca_storable=>commit( ).
  go_msglist->free( ).
