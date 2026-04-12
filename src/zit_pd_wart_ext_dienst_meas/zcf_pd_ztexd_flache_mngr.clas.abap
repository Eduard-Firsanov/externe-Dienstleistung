CLASS zcf_pd_ztexd_flache_mngr DEFINITION
  PUBLIC
  INHERITING FROM cf_reca_object
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    TYPE-POOLS abap .
    TYPE-POOLS reca1 .

    CLASS-METHODS check_authority
      IMPORTING
        !id_activity TYPE reca1_activity DEFAULT reca1_activity-display
      EXCEPTIONS
        error .
    CLASS-METHODS find_by_dienstleistung
      IMPORTING
        !id_dienstleistung TYPE zddienstleistung
        !id_activity       TYPE reca1_activity
        !id_auth_check     TYPE abap_bool
        !id_enqueue        TYPE abap_bool
        !if_reset_buffer   TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_instance) TYPE REF TO zif_pd_ztexd_flache_mngr
      EXCEPTIONS
        error .
    CLASS-METHODS find_by_tab
      IMPORTING
        !id_dienstleistung TYPE zddienstleistung
        !it_tab            TYPE z_t_ztexd_flache OPTIONAL
        !id_activity       TYPE reca1_activity
        !id_auth_check     TYPE abap_bool
        !id_enqueue        TYPE abap_bool
      RETURNING
        VALUE(ro_instance) TYPE REF TO zif_pd_ztexd_flache_mngr
      EXCEPTIONS
        error .
PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.



CLASS ZCF_PD_ZTEXD_FLACHE_MNGR IMPLEMENTATION.


METHOD check_authority.


  AUTHORITY-CHECK OBJECT 'ZDINSTLEIS' ID 'DIENSTLEIS' FIELD 'MEAS'
                                      ID 'ACTVT'  FIELD id_activity.
  IF sy-subrc <> 0.
    MESSAGE e075(zit_xs) WITH '"ZDINSTLEIS"' id_activity RAISING error.
*   Keine Berechtigung & zum & von Bemessungen.
  ENDIF.

ENDMETHOD.


METHOD find_by_dienstleistung.

* PRECONDITION
  IF  id_dienstleistung IS INITIAL.
    mac_invalid_precondition.
  ENDIF.

* check Berechtigung
  IF id_auth_check = abap_true.
    check_authority(
      EXPORTING
        id_activity = id_activity
      EXCEPTIONS
        error       = 1
        OTHERS      = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      RAISING error.
    ENDIF.
  ENDIF.

* create instance
  CALL METHOD create_by_intfname
    EXPORTING
      id_intfname = 'ZIF_PD_ZTEXD_FLACHE_MNGR'
      id_subtype  = 'DIENST'
    IMPORTING
      eo_instance = ro_instance.

* initialize instance
  CALL METHOD ro_instance->init_by_dienstleistung(
      id_dienstleistung = id_dienstleistung
      id_activity       = id_activity
      id_auth_check     = id_auth_check
      id_enqueue        = id_enqueue
    ).

ENDMETHOD.


METHOD find_by_tab.

* PRECONDITION
  IF  id_dienstleistung IS INITIAL.
    mac_invalid_precondition.
  ENDIF.

* check Berechtigung
  IF id_auth_check = abap_true.
    check_authority(
      EXPORTING
        id_activity = id_activity
      EXCEPTIONS
        error       = 1
        OTHERS      = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      RAISING error.
    ENDIF.
  ENDIF.

* create instance
  CALL METHOD create_by_intfname
    EXPORTING
      id_intfname = 'ZIF_PD_ZTEXD_FLACHE_MNGR'
      id_subtype  = 'DIENST'
    IMPORTING
      eo_instance = ro_instance.

* initialize instance
  CALL METHOD ro_instance->init_by_guidtab(
      id_dienstleistung = id_dienstleistung
      it_tab            = it_tab
      id_activity       = id_activity
      id_auth_check     = id_auth_check
      id_enqueue        = id_enqueue
    ).

ENDMETHOD.
ENDCLASS.
