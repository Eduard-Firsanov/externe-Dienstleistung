CLASS zcl_pd_ztexd_flache_mngr DEFINITION
  PUBLIC
  INHERITING FROM cl_reca_storable
  CREATE PROTECTED

  GLOBAL FRIENDS cf_reca_object .

  PUBLIC SECTION.
    TYPE-POOLS reca1 .

    INTERFACES zif_has_meas_mngr .
    INTERFACES zif_pd_ztexd_flache_mngr .

    ALIASES md_dienstleistung
      FOR zif_pd_ztexd_flache_mngr~md_dienstleistung .
    ALIASES mto_bus_object
      FOR zif_has_meas_mngr~mto_bus_object .
    ALIASES check_key
      FOR zif_pd_ztexd_flache_mngr~check_key .
    ALIASES count
      FOR zif_pd_ztexd_flache_mngr~count .
    ALIASES exists
      FOR zif_pd_ztexd_flache_mngr~exists .
    ALIASES objektliste_change
      FOR zif_pd_ztexd_flache_mngr~objektliste_change .
    ALIASES objektliste_create
      FOR zif_pd_ztexd_flache_mngr~objektliste_create .
    ALIASES objektliste_delete
      FOR zif_pd_ztexd_flache_mngr~objektliste_delete .
PROTECTED SECTION.

  ALIASES mf_reset_buffer
    FOR zif_pd_ztexd_flache_mngr~mf_reset_buffer .
  ALIASES get_detail
    FOR zif_pd_ztexd_flache_mngr~get_detail .
  ALIASES get_detail_x
    FOR zif_pd_ztexd_flache_mngr~get_detail_x .
  ALIASES get_list
    FOR zif_pd_ztexd_flache_mngr~get_list .
  ALIASES get_list_x
    FOR zif_pd_ztexd_flache_mngr~get_list_x .
  ALIASES get_meascn_mngr
    FOR zif_has_meas_mngr~get_meascn_mngr .
  ALIASES get_msglist
    FOR zif_pd_ztexd_flache_mngr~get_msglist .
  ALIASES get_text
    FOR zif_pd_ztexd_flache_mngr~get_text .
  ALIASES init_by_parent
    FOR zif_pd_ztexd_flache_mngr~init_by_dienstleistung .
  ALIASES store_messages
    FOR zif_pd_ztexd_flache_mngr~store_messages .

  DATA mt_list TYPE z_t_ztexd_flache .
  DATA mt_list_old TYPE z_t_ztexd_flache .

  METHODS flaeche_me_updaten
    IMPORTING
      !it_flache         TYPE z_t_ztexd_flache
      !io_msglist        TYPE REF TO if_reca_message_list
    CHANGING
      !cd_me_update      TYPE char50
      !cd_me_update_flag TYPE flag
    EXCEPTIONS
      error .
  METHODS fill_buffer .
  METHODS _set_status_icon
    IMPORTING
      !io_msglist     TYPE REF TO if_reca_message_list
      !is_detail      TYPE zpd_ztexd_flache
    CHANGING
      !cd_status_icon TYPE recaiconmarked .
  METHODS _get_msglist
    CHANGING
      !co_msglist   TYPE REF TO if_reca_message_list
      !dc_msgnumber TYPE balnrext OPTIONAL .
  METHODS _store_messages
    IMPORTING
      !if_in_update_task TYPE recabool
      VALUE(io_msglist)  TYPE REF TO if_reca_message_list
    EXCEPTIONS
      error .
  METHODS _get_debitorendaten
    IMPORTING
      !is_list     TYPE ztexd_flache
      !io_msglist  TYPE REF TO if_reca_message_list
      !id_stichtag TYPE stichtag
    CHANGING
      !cs_list_dbt TYPE zst_debitorenstamm .
  METHODS _get_wohnverwalterdaten
    IMPORTING
      !is_list     TYPE ztexd_flache
      !io_msglist  TYPE REF TO if_reca_message_list
      !id_stichtag TYPE stichtag
    CHANGING
      !cs_list_wv  TYPE zst_partrel_tab .
  METHODS _objekt_refresh
    IMPORTING
      !is_list    TYPE ztexd_flache
      !io_msglist TYPE REF TO if_reca_message_list
    CHANGING
      !cs_list    TYPE ztexd_flache-tab .

  METHODS me_check_all
      REDEFINITION .
  METHODS me_is_modified
      REDEFINITION .
  METHODS me_store_prepare
      REDEFINITION .
  METHODS me_store_write
      REDEFINITION .
PRIVATE SECTION.

  METHODS get_belegung_zu_kw
    IMPORTING
      !id_objnr          TYPE recaobjnr
      !id_vondat         TYPE dvondat
      !id_bisdat         TYPE dbisdat
    RETURNING
      VALUE(rs_belegung) TYPE recp_occupancy_c
    EXCEPTIONS
      error .
  METHODS get_folgevertrag
    IMPORTING
      !id_stichtag     TYPE sy-datum
      !is_me_key       TYPE vibdro_key
      !id_recnendabs   TYPE recncnendabs
    CHANGING
      !cd_folgevertrag TYPE zd_folgevertrag .
  METHODS set_belegung_icon
    IMPORTING
      !id_stichtag      TYPE sy-datum
      !id_recnendabs    TYPE recncnendabs
    CHANGING
      !cd_belegung_icon TYPE recaiconmarked .
  METHODS sende_info_email
    IMPORTING
      !is_list           TYPE ztexd_flache
      !io_msglist        TYPE REF TO if_reca_message_list
      !id_recnendabs     TYPE recncnendabs
      !id_infoart        TYPE zdextinfoart
      !if_in_update_task TYPE abap_bool DEFAULT abap_true
    CHANGING
      !cd_info_verwalter TYPE zdinfo_verwalter
    EXCEPTIONS
      error .
  METHODS sende_info_email_grundriss
    IMPORTING
      !is_list           TYPE ztexd_flache
      !io_msglist        TYPE REF TO if_reca_message_list
      !id_recnendabs     TYPE recncnendabs
      !id_infoart        TYPE zdextinfoart
      !if_in_update_task TYPE abap_bool DEFAULT abap_true
    CHANGING
      !cd_info_verwalter TYPE zdinfo_verwalter
    EXCEPTIONS
      error .
  METHODS get_valid_to
    IMPORTING
      !is_detail        TYPE zpd_ztexd_flache
    RETURNING
      VALUE(rd_validto) TYPE zdrebdvalidto
    EXCEPTIONS
      error .
  METHODS me_detail_x
    IMPORTING
      !is_detail         TYPE zpd_ztexd_flache
    RETURNING
      VALUE(is_vibdro_x) TYPE rebd_rental_object_x
    EXCEPTIONS
      error .
  METHODS set_indo_wohnverwalter
    IMPORTING
      !subrc             TYPE sy-subrc
      !id_infoart        TYPE zdextinfoart
      !id_recnendabs     TYPE recncnendabs
      !id_kuendgrud      TYPE recnntreason
    CHANGING
      !cd_info_verwalter TYPE zdinfo_verwalter .
  METHODS get_ident
    IMPORTING
      !is_detail      TYPE zpd_ztexd_flache
    RETURNING
      VALUE(rd_ident) TYPE recaident
    EXCEPTIONS
      error .
  METHODS get_ident_mv
    IMPORTING
      !id_intreno     TYPE recaintreno
    RETURNING
      VALUE(rd_ident) TYPE recaident
    EXCEPTIONS
      error .
ENDCLASS.



CLASS ZCL_PD_ZTEXD_FLACHE_MNGR IMPLEMENTATION.


METHOD fill_buffer.

  DATA ls_list LIKE LINE OF mt_list.

* BODY

  zcl_get_ztexd_flache=>get_list_by_dienstleistung(
    EXPORTING
      id_dienstleistung   = md_dienstleistung
      if_reset_buffer     = mf_reset_buffer
      id_max_buffer_size  = 0
    IMPORTING
      et_list             = mt_list
         ).

ENDMETHOD.


METHOD flaeche_me_updaten.

  DATA: ro_instance TYPE REF TO if_reca_bus_object,
        io_has_meas TYPE REF TO  if_rebd_has_meas,
        dummy       TYPE string.

  DATA: it_meas_upd TYPE bapi_re_t_measurement_intc,
        ls_meas_upd LIKE LINE OF it_meas_upd.
  DATA  ld_meas        TYPE rebdmeas.
  DATA: et_measurement TYPE bapi_re_t_measurement_int,
        ls_meas        LIKE LINE OF et_measurement.
  DATA: ld_validfrom TYPE rebdmeasvalidfrom,
        ld_validto   TYPE rebdmeasvalidto.
  DATA: ld_meas_update TYPE flag,
        gd_text_update TYPE string,
        ld_date_c(10)  TYPE c.


  DATA: lt_cust TYPE STANDARD TABLE OF zcus_aktivit,
        ls_cust LIKE LINE OF lt_cust.

  DATA: ls_flache LIKE LINE OF it_flache.


* Get Customizing
  SELECT * FROM zcus_aktivit INTO TABLE lt_cust.



  CLEAR: cd_me_update,
         cd_me_update_flag.


  REFRESH: it_meas_upd, et_measurement.

  LOOP AT it_flache INTO ls_flache.

    IF ro_instance IS NOT BOUND.

      get_meascn_mngr(
         EXPORTING
           id_objnr      = ls_flache-objnr
         RECEIVING
           ro_bus_object = ro_instance
         EXCEPTIONS
           error         = 1
           OTHERS        = 2
              ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING error.
      ENDIF.

    ENDIF.

    io_has_meas ?= ro_instance.




*   Get Bemessung
    CALL FUNCTION 'REBD_API_MEASUREMENT_GET'
      EXPORTING
        io_has_meas    = io_has_meas
      IMPORTING
        et_measurement = et_measurement.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_flache-meas
      IMPORTING
        output = ld_meas.

*   Tabelle bereinigen
    DELETE et_measurement WHERE meas <> ld_meas.



*   Filter auf aktuelle einträge
    cl_reca_bapi_services=>filter_list_by_detail_period(
      EXPORTING
        id_seldate_from        = ls_flache-measvalidto
        id_seldate_to          = ls_flache-measvalidfrom
        id_seldate_min         = reca0_date-min
        id_seldate_max         = reca0_date-max
      CHANGING
        ct_list                = et_measurement
           ).


    CLEAR: ld_validfrom,
            ld_validto.



    " Check Bemessung soll beendet werden?
    READ TABLE et_measurement INTO ls_meas WITH KEY measvalue = ls_flache-measvalue
                                                    validto   = ls_flache-measvalidto.
    IF sy-subrc <> 0.

*   Updatetabele aufbereiten
      CLEAR ls_meas.
      READ TABLE et_measurement INTO ls_meas INDEX 1.
      IF sy-subrc = 0.
*      Bemessung beenden
        CLEAR ls_meas_upd.
        MOVE-CORRESPONDING ls_meas TO ls_meas_upd.
        ls_meas_upd-changeind = 'U'.
        ls_meas_upd-validto   = ls_flache-measvalidto.
        APPEND ls_meas_upd TO it_meas_upd.
      ENDIF.
    ELSE.
      MESSAGE i028 WITH ld_meas ls_flache-measvalue ls_flache-measvalidto INTO dummy.
*     Bemessung & & wurde zum & beendet.
      io_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.


    " Check Nneu Bemessung soll einfügt werden?
    READ TABLE et_measurement INTO ls_meas WITH KEY measvalue = ls_flache-measvalue_neu
                                                    validto   = ls_flache-measvalidfrom.
    IF sy-subrc <> 0.

*   Neu Bemessung einfügen
      CLEAR ls_meas_upd.
      ls_meas_upd-changeind = 'I'.
      ls_meas_upd-meas      = ld_meas.
      ls_meas_upd-validfrom = ls_flache-measvalidfrom.
      ls_meas_upd-validto   = reca0_date-max.
      ls_meas_upd-measvalue = ls_flache-measvalue_neu.
      ls_meas_upd-measunit  = ls_flache-measunit_neu.

      APPEND ls_meas_upd TO it_meas_upd.
    ELSE.
      MESSAGE i029 WITH ld_meas ls_flache-measvalue ls_flache-measvalidfrom INTO dummy.
*   Bemessung & wurde zum & angelegt.
    ENDIF.

  ENDLOOP.


  IF it_meas_upd[] IS NOT INITIAL.
*   Bemessungen updaten
    CALL FUNCTION 'REBD_API_MEASUREMENT_CHG'
      EXPORTING
        io_has_meas    = io_has_meas
        it_measurement = it_meas_upd
        io_msglist     = io_msglist.
  ENDIF.

* Sind Fehler vorhanden?
  IF io_msglist->has_messages_of_msgty(
      id_msgty     = 'E'
         ) = abap_false.

**    Save ME
*    IO_HAS_MEAS->STORE(
*       EXPORTING
*         IF_IN_UPDATE_TASK = ABAP_TRUE
*       EXCEPTIONS
*         ERROR             = 1
*         OTHERS            = 2
*            ).
*    IF SY-SUBRC <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
*      RAISING ERROR.
*    ENDIF.

*     build icon for Update
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name   = 'ICON_ALLOW'
        info   = TEXT-oku
      IMPORTING
        result = gd_text_update
      EXCEPTIONS
        OTHERS = 0.

*     build Datum
    CALL METHOD cl_reca_date=>as_char
      EXPORTING
        id_date = sy-datum
      RECEIVING
        rd_date = ld_date_c.


    CONCATENATE gd_text_update
    'am'
    ld_date_c
    INTO cd_me_update
    SEPARATED BY ' '.

*     Set Status und Updateflag
    cd_me_update_flag = abap_true.

  ELSE.
*   build icon for Update
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name   = 'ICON_REJECT'
        info   = TEXT-fel
      IMPORTING
        result = gd_text_update
      EXCEPTIONS
        OTHERS = 0.

*     build Datum
    CALL METHOD cl_reca_date=>as_char
      EXPORTING
        id_date = sy-datum
      RECEIVING
        rd_date = ld_date_c.


    CONCATENATE TEXT-fel
    'am'
    ld_date_c
    INTO cd_me_update
    SEPARATED BY ' '.

*     Set Status und Updateflag
    cd_me_update_flag = abap_false.
  ENDIF.


ENDMETHOD.


  METHOD get_belegung_zu_kw.
    DATA: lo_object        TYPE REF TO if_rebd_rental_object.
    DATA: lt_occupancy TYPE  recp_t_occupancy_c,
          ls_occupancy TYPE  recp_occupancy_c.
    DATA: lt_occupancy_all TYPE recp_t_occupancy_c.
    DATA: ls_parameter TYPE zst_param_belegung,
          go_flag      TYPE flag.
    DATA: lt_occupancy_objekt TYPE recp_t_occupancy_c.
*   aspect occupancy


* Übergabeparameter initialisieren
    CLEAR: rs_belegung.

    CHECK id_objnr(2) = 'IM'.

* Objekt erzeugen
    cf_rebd_rental_object=>find_by_objnr(
    EXPORTING
      id_objnr       = id_objnr
      RECEIVING
      ro_instance    = lo_object
    EXCEPTIONS
      error          = 1
      OTHERS         = 2
      ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

*   Belegung der ME lesen
    zcl_get_stammdaten_fx=>get_occupancy_list(
    EXPORTING
      io_has_occupancy = lo_object
      id_seldate       = id_bisdat
      id_seldate_min   = id_vondat
      id_seldate_max   = id_bisdat
      id_langu         = sy-langu
    IMPORTING
      et_occupancy     = lt_occupancy
      et_occupancy_all = lt_occupancy_all
      ).

    SORT lt_occupancy_all BY occfrom DESCENDING.

    READ TABLE lt_occupancy_all INDEX 1 INTO rs_belegung.

  ENDMETHOD.


METHOD get_folgevertrag.

  DATA: ls_zvmv2me_all TYPE zvmv2me_all,
        ed_date_string TYPE string.

  CLEAR cd_folgevertrag.

  SELECT SINGLE * FROM zvmv2me_all INTO ls_zvmv2me_all WHERE bukrs_me = is_me_key-bukrs "#EC WARNOK
                                                 AND swenr_me = is_me_key-swenr
                                                 AND smenr_me = is_me_key-smenr
                                                 AND recnbeg >= id_stichtag.
  IF sy-subrc = 0.

    cl_reca_date=>convert_date_to_string(
      EXPORTING
        id_date        = ls_zvmv2me_all-recnbeg
      IMPORTING
        ed_date_string = ed_date_string
           ).

    CONCATENATE 'folgevertrag:' ls_zvmv2me_all-recnnr 'zum' ed_date_string INTO cd_folgevertrag SEPARATED BY ' '.
  ENDIF.

ENDMETHOD.


METHOD get_ident.

  DATA: lo_bo             TYPE REF TO if_reca_bus_object.


  CALL METHOD cf_reca_bus_object=>FIND_BY_objnr
    EXPORTING
      id_objnr    = is_detail-objnr
    RECEIVING
      ro_instance = lo_bo
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING error.
  ENDIF.

  CALL METHOD lo_bo->get_ident
    IMPORTING
      ed_ident = rd_ident.

ENDMETHOD.


METHOD get_ident_mv.

  DATA: lo_bo             TYPE REF TO if_reca_bus_object.


  CALL METHOD cf_reca_bus_object=>find_by_intreno
    EXPORTING
      id_intreno  = id_intreno
    RECEIVING
      ro_instance = lo_bo
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING error.
  ENDIF.

  CALL METHOD lo_bo->get_ident
    IMPORTING
      ed_ident = rd_ident.

ENDMETHOD.


METHOD get_valid_to.

  DATA: ld_objnr TYPE recaobjnr,
        lo_ro    TYPE REF TO if_rebd_rental_object.



  CALL METHOD cf_rebd_rental_object=>find_by_objnr
    EXPORTING
      id_objnr    = is_detail-objnr
    RECEIVING
      ro_instance = lo_ro
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING error.
  ENDIF.

  DATA cd_validfrom TYPE recadatefrom.
  DATA cd_validto   TYPE recadateto.

  lo_ro->get_valid_period(
    EXPORTING
      if_object_period = abap_false " mit objekthierarhie
*    IF_OLD           = ABAP_FALSE
    IMPORTING
      ed_validfrom     =  cd_validfrom
      ed_validto       =  cd_validto
         ).


  rd_validto = cd_validto.

ENDMETHOD.


METHOD me_check_all.

ENDMETHOD.


METHOD me_detail_x.

  DATA: ld_objnr TYPE recaobjnr,
        lo_ro    TYPE REF TO if_rebd_rental_object.



  CALL METHOD cf_rebd_rental_object=>find_by_objnr
    EXPORTING
      id_objnr    = is_detail-objnr
    RECEIVING
      ro_instance = lo_ro
    EXCEPTIONS
      error       = 1
      OTHERS      = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING error.
  ENDIF.


  is_vibdro_x = lo_ro->get_detail_x(
      id_keydate  = sy-datum
         ).


ENDMETHOD.


METHOD me_is_modified.
  SORT mt_list     BY key.
  SORT mt_list_old BY key.
  IF mt_list[] <> mt_list_old[].
    rf_modified = 'X'.
  ENDIF.
ENDMETHOD.


METHOD me_store_prepare.
  FIELD-SYMBOLS <ls_list> LIKE LINE OF mt_list.

* Ruser Vorbelegen
  LOOP AT  mt_list ASSIGNING <ls_list>.
    IF ( md_activity = reca1_activity-create ).
      CLEAR <ls_list>-ruser.
    ENDIF.

    CALL METHOD cl_reca_user=>set_ruser
      CHANGING
        cs_ruser = <ls_list>-ruser.

  ENDLOOP.

ENDMETHOD.


METHOD me_store_write.

  DATA: lt_flache_old TYPE STANDARD TABLE OF zaztexd_flache, " ZTEXD_FLACHE Externe Dienstleistung Flächenänderung SAP
        lt_flache_neu TYPE STANDARD TABLE OF zaztexd_flache, " ZTEXD_FLACHE Externe Dienstleistung Flächenänderung SAP
        ls_flache     TYPE ztexd_flache.

  IF mt_list[] IS NOT INITIAL.
    APPEND LINES OF mt_list TO lt_flache_neu.
  ENDIF.

  IF mt_list_old[] IS NOT INITIAL.
    APPEND LINES OF mt_list_old TO lt_flache_old.
  ENDIF.

  SORT lt_flache_neu BY  key.
  SORT lt_flache_old BY  key.


  CALL FUNCTION 'CHANGEDOCUMENT_PREPARE_TABLES'
    EXPORTING
      check_indicator        = ' '
      tablename              = 'ZTEXD_FLACHE'
    TABLES
      table_new              = lt_flache_neu
      table_old              = lt_flache_old
    EXCEPTIONS
      nametab_error          = 1
      wrong_structure_length = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE e001(recabc) WITH 'Fehler im FuBa CHANGEDOCUMENT_PREPARE_TABLES'(002) ##TEXT_POOL
    'ZTEXD_FLACHE' '' '' RAISING error.
  ENDIF.

* Update  Klagefall
  IF if_in_update_task = abap_true.


    CALL FUNCTION 'ZFB_VB_ZTEXD_FLACHE_UPDATE_T' IN UPDATE TASK
      TABLES
        it_ztexd_flache = lt_flache_old.

    CALL FUNCTION 'ZFB_VB_ZTEXD_FLACHE_UPDATE_T' IN UPDATE TASK
      TABLES
        it_ztexd_flache = lt_flache_neu.


  ELSE.


    CALL FUNCTION 'ZFB_VB_ZTEXD_FLACHE_UPDATE_T'
      TABLES
        it_ztexd_flache      = lt_flache_old
      EXCEPTIONS
        db_failure           = 1
        db_operation_unknown = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error.
    ENDIF.


    CALL FUNCTION 'ZFB_VB_ZTEXD_FLACHE_UPDATE_T'
      TABLES
        it_ztexd_flache      = lt_flache_neu
      EXCEPTIONS
        db_failure           = 1
        db_operation_unknown = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error.
    ENDIF.


  ENDIF.

  mt_list_old[] = mt_list[].

ENDMETHOD.


METHOD sende_info_email.

  DATA:
    lt_text TYPE zcl_admin_services=>lt_text,
    ls_text LIKE LINE OF lt_text.
  DATA: lt_note         TYPE bcsy_text,
        lt_address_mail TYPE zcl_admin_services=>t_addesses,
        ls_address_mail LIKE LINE OF lt_address_mail,
        lt_address_sap  TYPE zcl_admin_services=>t_address_user,
        ls_address_sap  LIKE LINE OF lt_address_sap,
        lt_file         TYPE zcl_admin_services=>lt_file.
  DATA: ld_recipient TYPE sy-uname,
        lt_zuserkz   TYPE z_t_zuserkz,
        ld_zuserkz   TYPE zuserkz.
  DATA: ld_title   TYPE string,
        ld_adrline TYPE string,
        ld_ident   TYPE string.
  DATA: ms_address TYPE bapiaddr3,
        return     TYPE STANDARD TABLE OF bapiret2.
  DATA: ed_date_string TYPE string,
        ld_string      TYPE string,
        ld_string_name TYPE string,
        dummy          TYPE string.

  CONSTANTS:
  lc_bcs_rqst      TYPE bcs_rqst VALUE 'N'.

  DATA: gd_text_update TYPE string,
        ld_date_c(10)  TYPE c.
  DATA: it_rolle TYPE bup_t_role,
        ls_rolle LIKE LINE OF it_rolle.
  DATA: et_mv_partner TYPE z_t_zvcnbpadress,
        ls_mv_partner LIKE LINE OF et_mv_partner.

  DATA es_partner        TYPE zst_vtmdt_partner.


  IF id_infoart = 'KV'. "  Kündigung Vertrag
* Set Titel
    IF sy-sysid = 'PS4'.
      ld_title = 'Beauftragung eines Aufmaßes' ##NO_TEXT.
    ELSE.
      CONCATENATE 'TEST!!!' sy-sysid 'Beauftragung eines Aufmaßes' INTO ld_title SEPARATED BY ' ' ##NO_TEXT.
    ENDIF.


* Set Text
    CLEAR ls_text.

    cl_reca_date=>convert_date_to_string(
      EXPORTING
        id_date        = id_recnendabs
      IMPORTING
        ed_date_string = ed_date_string
           ).
    CONCATENATE is_list-bukrs is_list-smive_aktuell INTO ld_string SEPARATED BY '/'.
    CONCATENATE 'Mietvertrag:' ld_string INTO ld_string SEPARATED BY ' ' ##NO_TEXT.
    CONCATENATE ld_string 'wurde zum' ed_date_string 'gekündigt.'  INTO ls_text SEPARATED BY ' ' ##NO_TEXT.
    APPEND ls_text TO lt_text.

    CLEAR ls_text.
    APPEND ls_text TO lt_text.
    CLEAR ls_text.
    APPEND ls_text TO lt_text.


    ls_rolle = 'TR0600'.
    APPEND ls_rolle TO it_rolle.
    ls_rolle = 'TR0601'.
    APPEND ls_rolle TO it_rolle.


    zcl_extdienst_services=>get_mv_partner(
      EXPORTING
        id_bukrs      = is_list-bukrs
        id_recnnr     = is_list-smive_aktuell
        it_rolle      = it_rolle
        is_stichtag   = is_list-stichtag
      IMPORTING
        et_mv_partner = et_mv_partner
      EXCEPTIONS
        error         = 1
        OTHERS        = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO dummy.
      io_msglist->add_symsg( if_cumulate = abap_true ).
      RETURN.
    ENDIF.

    ls_text = 'Mietobjekt:'  ##NO_TEXT.
    APPEND ls_text TO lt_text.


    CLEAR ls_text.
    CONCATENATE 'MO-Nutzungsart' is_list-xksnunr ##NO_TEXT
    INTO ls_text SEPARATED BY ':  '.
    APPEND ls_text TO lt_text.




*    CLEAR LD_STRING.
*    CONCATENATE IS_LIST-STREET IS_LIST-HOUSE_NUM1 INTO LD_STRING SEPARATED BY ' '.
*    CONCATENATE LD_STRING IS_LIST-POST_CODE1 IS_LIST-CITY1 INTO LD_STRING SEPARATED BY ', '.
    CLEAR ls_text.
    ls_text = TEXT-adr.
    REPLACE '&1' IN ls_text WITH is_list-street.
    REPLACE '&2' IN ls_text WITH is_list-house_num1.
    REPLACE '&3' IN ls_text WITH is_list-post_code1.
    REPLACE '&4' IN ls_text WITH is_list-city1.
*    CONCATENATE LS_TEXT CL_ABAP_CHAR_UTILITIES=>BACKSPACE into LS_TEXT.
    APPEND ls_text TO lt_text.





    CLEAR ls_text.
    CONCATENATE 'Geschoß des MO' is_list-xstockm ##NO_TEXT
    INTO ls_text SEPARATED BY ':  '.
    APPEND ls_text TO lt_text.



    CLEAR ls_text.
    CONCATENATE 'Lage im Geschoß des MO' is_list-xklgesch ##NO_TEXT
    INTO ls_text SEPARATED BY ':  '.
    APPEND ls_text TO lt_text.



    CLEAR ld_string.
    CONCATENATE is_list-projektname is_list-ext_dienstlif INTO ld_string SEPARATED BY '/'.

    CLEAR ls_text.
    CONCATENATE 'Projektname/Dienstleister' ld_string
    INTO ls_text SEPARATED BY ':  '.
    APPEND ls_text TO lt_text.


    CLEAR ls_text.
    APPEND ls_text TO lt_text.

    ls_text = 'Mieter:' ##NO_TEXT .
    APPEND ls_text TO lt_text.



    LOOP AT et_mv_partner INTO ls_mv_partner.

*      CLEAR: LD_STRING_NAME.
*      CONCATENATE LS_MV_PARTNER-NAME_FIRST LS_MV_PARTNER-NAME_LAST INTO LD_STRING_NAME SEPARATED BY ' '.
*
*      CLEAR: LD_STRING.
*      CONCATENATE LS_MV_PARTNER-STREET LS_MV_PARTNER-HOUSE_NUM1 INTO LD_STRING SEPARATED BY ' '.
*      CONCATENATE LD_STRING LS_MV_PARTNER-POST_CODE1 LS_MV_PARTNER-CITY1 INTO LD_STRING SEPARATED BY ', '.
*      CLEAR LS_TEXT.
*      CONCATENATE LD_STRING_NAME LD_STRING
*      INTO LS_TEXT SEPARATED BY ',  '.
*      APPEND LS_TEXT TO LT_TEXT.
*    CLEAR LS_TEXT.
*    APPEND LS_TEXT TO LT_TEXT.
      CLEAR ls_text.
      ls_text = TEXT-adp.
      REPLACE '&1' IN ls_text WITH ls_mv_partner-name_first.
      REPLACE '&2' IN ls_text WITH ls_mv_partner-name_last.
      REPLACE '&3' IN ls_text WITH is_list-street.
      REPLACE '&4' IN ls_text WITH is_list-house_num1.
      REPLACE '&5' IN ls_text WITH is_list-post_code1.
      REPLACE '&6' IN ls_text WITH is_list-city1.
      APPEND ls_text TO lt_text.

      " Kommunikationsdaten von Mierer  " EF 19092

      zcl_vtm_dt_services=>get_partnerdaten(                " EF 19092
        EXPORTING                                           " EF 19092
          id_partner        = ls_mv_partner-partner         " EF 19092
        IMPORTING                                           " EF 19092
          es_partner        = es_partner                    " EF 19092
        EXCEPTIONS                                          " EF 19092
          error             = 1                             " EF 19092
          OTHERS            = 2                             " EF 19092
             ).                                             " EF 19092
      IF sy-subrc <> 0.                                     " EF 19092
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno   " EF 19092
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4            " EF 19092
        RAISING error.                                      " EF 19092
      ENDIF.                                                " EF 19092


      CLEAR ls_text.                                        " EF 19092
      ls_text = |Kommunikation: { ls_mv_partner-name_first } { ls_mv_partner-name_last } |. " EF 19092
      APPEND ls_text TO lt_text.                            " EF 19092
      CLEAR ls_text.                                        " EF 19092
      ls_text = |Telefon: { es_partner-festnetz }|.         " EF 19092
      APPEND ls_text TO lt_text.                            " EF 19092
      ls_text = |Mobiltelefon: { es_partner-mobil } |.      " EF 19092
      APPEND ls_text TO lt_text.                            " EF 19092
      ls_text = |E-Mail-Adresse: { es_partner-email } |.    " EF 19092
      APPEND ls_text TO lt_text.                            " EF 19092

      CLEAR ls_text.                                        " EF 19092
      APPEND ls_text TO lt_text.                            " EF 19092


    ENDLOOP.

    CLEAR ls_text.
    APPEND ls_text TO lt_text.
    CLEAR ls_text.
    APPEND ls_text TO lt_text.



    CONCATENATE 'Beantragen Sie bitte' 'ein Aufmaß.' ##NO_TEXT
    INTO ls_text SEPARATED BY ' '.
    APPEND ls_text TO lt_text.

    CLEAR ls_text.
    APPEND ls_text TO lt_text.

    ls_text = 'Dieses Schreiben wurde maschinell erstellt, bei Fragen wenden Sie sich bitte an PM-Support – Thorsten Zier (intern: 471).'  ##NO_TEXT.
    APPEND ls_text TO lt_text.

*  LS_TEXT = 'an BM/T5TF - Herrn Reinhardt (Durchwahl 614).'.
*  APPEND LS_TEXT TO LT_TEXT.






  ELSE. " 'KS'. "  Stornierung/Löschung Kündigung


* Set Titel
    IF sy-sysid = 'PS4'.
      ld_title = 'Rücknahme Beauftragung eines Aufmaßes' ##NO_TEXT.
    ELSE.
      CONCATENATE 'TEST!!!' sy-sysid 'Rücknahme Beauftragung eines Aufmaßes' INTO ld_title SEPARATED BY ' ' ##NO_TEXT.
    ENDIF.


* Set Text
    CLEAR ls_text.

    cl_reca_date=>convert_date_to_string(
      EXPORTING
        id_date        = id_recnendabs
      IMPORTING
        ed_date_string = ed_date_string
           ).
    CONCATENATE is_list-bukrs is_list-smive_aktuell INTO ld_string SEPARATED BY '/'.
    CONCATENATE 'Mietvertrag:' ld_string INTO ld_string SEPARATED BY ' ' ##NO_TEXT.
    CONCATENATE ld_string 'eine Kündigung wurde zurückgenommen.'  INTO ls_text SEPARATED BY ' ' ##NO_TEXT.
    APPEND ls_text TO lt_text.

    CLEAR ls_text.
    APPEND ls_text TO lt_text.
    CLEAR ls_text.
    APPEND ls_text TO lt_text.


    ls_rolle = 'TR0600'.
    APPEND ls_rolle TO it_rolle.
    ls_rolle = 'TR0601'.
    APPEND ls_rolle TO it_rolle.


    zcl_extdienst_services=>get_mv_partner(
      EXPORTING
        id_bukrs      = is_list-bukrs
        id_recnnr     = is_list-smive_aktuell
        it_rolle      = it_rolle
        is_stichtag   = is_list-stichtag
      IMPORTING
        et_mv_partner = et_mv_partner
      EXCEPTIONS
        error         = 1
        OTHERS        = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO dummy.
      io_msglist->add_symsg( if_cumulate = abap_true ).
      RETURN.
    ENDIF.

    ls_text = 'Mietobjekt:'  ##NO_TEXT.
    APPEND ls_text TO lt_text.

    CLEAR ls_text.
    CONCATENATE 'MO-Nutzungsart' is_list-xksnunr ##NO_TEXT
    INTO ls_text SEPARATED BY ':  '.
    APPEND ls_text TO lt_text.




*    CLEAR LD_STRING.
*    CONCATENATE IS_LIST-STREET IS_LIST-HOUSE_NUM1 INTO LD_STRING SEPARATED BY ' '.
*    CONCATENATE LD_STRING IS_LIST-POST_CODE1 IS_LIST-CITY1 INTO LD_STRING SEPARATED BY ', '.
    CLEAR ls_text.
    ls_text = TEXT-adr.
    REPLACE '&1' IN ls_text WITH is_list-street.
    REPLACE '&2' IN ls_text WITH is_list-house_num1.
    REPLACE '&3' IN ls_text WITH is_list-post_code1.
    REPLACE '&4' IN ls_text WITH is_list-city1.
*    CONCATENATE LS_TEXT CL_ABAP_CHAR_UTILITIES=>BACKSPACE into LS_TEXT.
    APPEND ls_text TO lt_text.





    CLEAR ls_text.
    CONCATENATE 'Geschoß des MO' is_list-xstockm ##NO_TEXT
    INTO ls_text SEPARATED BY ':  '.
    APPEND ls_text TO lt_text.



    CLEAR ls_text.
    CONCATENATE 'Lage im Geschoß des MO' is_list-xklgesch ##NO_TEXT
    INTO ls_text SEPARATED BY ':  '.
    APPEND ls_text TO lt_text.



    CLEAR ld_string.
    CONCATENATE is_list-projektname is_list-ext_dienstlif INTO ld_string SEPARATED BY '/'.

    CLEAR ls_text.
    CONCATENATE 'Projektname/Dienstleister' ld_string ##NO_TEXT
    INTO ls_text SEPARATED BY ':  '.
    APPEND ls_text TO lt_text.


    CLEAR ls_text.
    APPEND ls_text TO lt_text.

    ls_text = 'Mieter:'  ##NO_TEXT.
    APPEND ls_text TO lt_text.


    LOOP AT et_mv_partner INTO ls_mv_partner.

*      CLEAR: LD_STRING_NAME.
*      CONCATENATE LS_MV_PARTNER-NAME_FIRST LS_MV_PARTNER-NAME_LAST INTO LD_STRING_NAME SEPARATED BY ' '.
*
*      CLEAR: LD_STRING.
*      CONCATENATE LS_MV_PARTNER-STREET LS_MV_PARTNER-HOUSE_NUM1 INTO LD_STRING SEPARATED BY ' '.
*      CONCATENATE LD_STRING LS_MV_PARTNER-POST_CODE1 LS_MV_PARTNER-CITY1 INTO LD_STRING SEPARATED BY ', '.
*      CLEAR LS_TEXT.
*      CONCATENATE LD_STRING_NAME LD_STRING
*      INTO LS_TEXT SEPARATED BY ', '.
*      APPEND LS_TEXT TO LT_TEXT.


      CLEAR ls_text.
      ls_text = TEXT-adp.
      REPLACE '&1' IN ls_text WITH ls_mv_partner-name_first.
      REPLACE '&2' IN ls_text WITH ls_mv_partner-name_last.
      REPLACE '&3' IN ls_text WITH is_list-street.
      REPLACE '&4' IN ls_text WITH is_list-house_num1.
      REPLACE '&5' IN ls_text WITH is_list-post_code1.
      REPLACE '&6' IN ls_text WITH is_list-city1.
      APPEND ls_text TO lt_text.

    ENDLOOP.

    CLEAR ls_text.
    APPEND ls_text TO lt_text.
    CLEAR ls_text.
    APPEND ls_text TO lt_text.


    CLEAR ls_text.
    ls_text = 'Nehmen Sie bitte die ggf. bereits erfolgte Beauftragung eines Aufmaßes zurück.' ##NO_TEXT.
    APPEND ls_text TO lt_text.

    CLEAR ls_text.
    APPEND ls_text TO lt_text.

    ls_text = 'Dieses Schreiben wurde maschinell erstellt, bei Fragen wenden Sie sich bitte an PM-Support – Thorsten Zier (intern: 471).'  ##NO_TEXT.
    APPEND ls_text TO lt_text.

*  LS_TEXT = 'an BM/T5TF - Herrn Reinhardt (Durchwahl 614).'.
*  APPEND LS_TEXT TO LT_TEXT.
  ENDIF.


*   GET Empfänger
  DATA: it_role     TYPE bup_t_role.
  DATA: rt_partner TYPE z_t_zemod_partrel,
        ls_partner LIKE LINE OF rt_partner.

  IF is_list-zzusr15 = abap_false.
    " E.Firsanov CH2303-0099 Prozessanpassung Grundrissanforderung
    " Die automatisierte Mail, welche aktuell bei „INFO“ an die Rolle des WV (YYZ002) geht muss auf die Rolle des VM (YYZ004) abgeändert werden.
    " Zier Thorsten 30.03.2023 Steuerung über die Orte
    IF  is_list-city1 =   'Ahrensburg' OR
        is_list-city1 =   'Berlin' OR
        is_list-city1 =   'Blankenfelde-Mahlow' OR
        is_list-city1 =   'Dresden' OR
        is_list-city1 =   'Erkner' OR
        is_list-city1 =   'Hamburg' OR
        is_list-city1 =   'Leipzig' OR
        is_list-city1 =   'Potsdam' OR
        is_list-city1 =   'Radebeul' OR
        is_list-city1 =   'Schönefeld' OR
        is_list-city1 =   'Wentorf'.
      APPEND 'YYZ004' TO it_role.   " Vermieter
    ELSE.
      APPEND 'YYZ002' TO it_role. " Wohnungsverwalter
    ENDIF.

    zcl_extdienst_services=>get_we_partner( ##SUBRC_OK
      EXPORTING
        i_bukrs    = is_list-bukrs
        i_swenr    = is_list-swenr
        io_msglist = io_msglist
        it_role    = it_role
      RECEIVING
        rt_partner = rt_partner
      EXCEPTIONS
        error      = 1
        OTHERS     = 2
           ).

    READ TABLE rt_partner INTO ls_partner INDEX 1.
    IF sy-subrc = 0.
*    " SAP-Infomail in Workspace
*    RD_RECIPIENT      = LS_PARTNER-BNAME.
*      APPEND LD_RECIPIENT    TO LT_ADDRESS_SAP.
      " SMTP Outlook Nachricht
      IF sy-uname = 'B56322'.
        ls_address_mail   = 'Eduard.Firsanov@covivio.immo' ##NO_TEXT.
      ELSE.
        ls_address_mail   = ls_partner-smtp_addr.
      ENDIF.
      APPEND ls_address_mail TO lt_address_mail.
    ELSE.
*    " SAP-Infomail in Workspace
*    RD_RECIPIENT      = LS_PARTNER-BNAME.
*      APPEND LD_RECIPIENT    TO LT_ADDRESS_SAP.
      " SMTP Outlook Nachricht
      IF sy-uname = 'B56322'.
        ls_address_mail   = 'Eduard.Firsanov@covivio.immo' ##NO_TEXT.
*      ELSE.
*        LS_ADDRESS_MAIL   = 'thorsten.zier@covivio.immo' ##NO_TEXT.
      ENDIF.
      APPEND ls_address_mail TO lt_address_mail.
    ENDIF.
  ELSE.
    " Vermietungsstop die E-Mail an Tom Abbel / Ulf Illbruck
    IF sy-uname = 'B56322'.
      ls_address_mail   = 'Eduard.Firsanov@covivio.immo' ##NO_TEXT.
    ENDIF.
    ls_address_mail   = 'tom.abbel@covivio.immo' ##NO_TEXT.
    APPEND ls_address_mail TO lt_address_mail.
    ls_address_mail   = 'ulf.illbruck@covivio.immo' ##NO_TEXT.
    APPEND ls_address_mail TO lt_address_mail.
    ls_address_mail   = 'ansgar.krupp@covivio.immo' ##NO_TEXT.
    APPEND ls_address_mail TO lt_address_mail.

  ENDIF.


  DATA: ld_emal_sofort TYPE flag.

  IF if_in_update_task = abap_false.
    ld_emal_sofort = abap_true.
  ELSE.
    ld_emal_sofort = abap_false.
  ENDIF.


  zcl_admin_services=>email_senden_neu_convert(
   EXPORTING
     id_betreff       = ld_title
     it_text          = lt_text
     it_addresses     = lt_address_mail
     it_file          = lt_file
     if_commit_work   = ld_emal_sofort
     id_bcs_rqst      = lc_bcs_rqst
     it_address_user   = lt_address_sap
     id_sender        = 'ZBATCH'
   EXCEPTIONS
     error        = 1
     OTHERS       = 2
     ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    RAISING error.
  ENDIF.



ENDMETHOD.


METHOD sende_info_email_grundriss.

  DATA:
    lt_text TYPE zcl_admin_services=>lt_text,
    ls_text LIKE LINE OF lt_text.
  DATA: lt_note         TYPE bcsy_text,
        lt_address_mail TYPE zcl_admin_services=>t_addesses,
        ls_address_mail LIKE LINE OF lt_address_mail,
        lt_address_sap  TYPE zcl_admin_services=>t_address_user,
        ls_address_sap  LIKE LINE OF lt_address_sap,
        lt_file         TYPE zcl_admin_services=>lt_file.
  DATA: ld_recipient TYPE sy-uname,
        lt_zuserkz   TYPE z_t_zuserkz,
        ld_zuserkz   TYPE zuserkz.
  DATA: ld_title   TYPE string,
        ld_adrline TYPE string,
        ld_ident   TYPE string.
  DATA: ms_address TYPE bapiaddr3,
        return     TYPE STANDARD TABLE OF bapiret2.
  DATA: ed_date_string TYPE string,
        ld_string      TYPE string,
        ld_string_name TYPE string,
        dummy          TYPE string.

  CONSTANTS:
  lc_bcs_rqst      TYPE bcs_rqst VALUE 'N'.

  DATA: gd_text_update TYPE string,
        ld_date_c(10)  TYPE c.
  DATA: it_rolle TYPE bup_t_role,
        ls_rolle LIKE LINE OF it_rolle.
  DATA: et_mv_partner TYPE z_t_zvcnbpadress,
        ls_mv_partner LIKE LINE OF et_mv_partner.

  DATA es_partner        TYPE zst_vtmdt_partner.

  " E.Firsanov EMail soll nicht ausgeführt werden, weil in Kündigungsworkflow Step EMAIL_BEAUFTRAGUNG_GRUNDRISS aufgerufen wird.
  CHECK 1 = 2. " EF CH2312-0040 Doppelte PointLine Anfragen
  IF id_infoart = 'KV'. "  Kündigung Vertrag
* Set Titel
    IF sy-sysid = 'PS4'.
      ld_title = 'Beauftragung farbig / möblierter Grundriss' ##NO_TEXT.
    ELSE.
      CONCATENATE 'TEST!!!' sy-sysid 'Beauftragung farbig / möblierter Grundriss' INTO ld_title SEPARATED BY ' ' ##NO_TEXT.
    ENDIF.


* Set Text
    CLEAR ls_text.
    ls_text = |Sehr geehrte Damen und Herren,|.
    APPEND ls_text TO lt_text.
    CLEAR ls_text.
    APPEND ls_text TO lt_text.


    ls_text = |für das u.g. Mietobjekt bitten wir um Erstellung eines farbigen / möblierten Grundrisses.|.
    APPEND ls_text TO lt_text.

    CLEAR ls_text.
    APPEND ls_text TO lt_text.
    CLEAR ls_text.
    APPEND ls_text TO lt_text.



    ls_text = |Mietobjekt:  { is_list-bukrs }/{ is_list-swenr }/{ is_list-smenr }|  ##NO_TEXT.
    APPEND ls_text TO lt_text.


    CLEAR ls_text.
    ls_text = |MO-Nutzungsart:  { is_list-xksnunr }|. ##NO_TEXT
    APPEND ls_text TO lt_text.




    CLEAR ls_text.
    ls_text = TEXT-adr.
    REPLACE '&1' IN ls_text WITH is_list-street.
    REPLACE '&2' IN ls_text WITH is_list-house_num1.
    REPLACE '&3' IN ls_text WITH is_list-post_code1.
    REPLACE '&4' IN ls_text WITH is_list-city1.
    APPEND ls_text TO lt_text.



    CLEAR ls_text.
    ls_text = |Geschoß des MO:  { is_list-xstockm }|. ##NO_TEXT
    APPEND ls_text TO lt_text.



    CLEAR ls_text.
    CONCATENATE 'Lage im Geschoß des MO' is_list-xklgesch ##NO_TEXT
    INTO ls_text SEPARATED BY ':  '.
    APPEND ls_text TO lt_text.


* List of PHIOS
    TYPES: BEGIN OF tp_phio_list,
             lo_class  TYPE sdok_phcl,
             loio_id   TYPE sdok_docid,
             ph_class  TYPE sdok_phcl,
             phio_id   TYPE sdok_docid,
             file_name TYPE sdok_filnm,
             doc_key   TYPE dms_doc_key,
           END OF tp_phio_list.
    DATA: lt_phios TYPE TABLE OF tp_phio_list,
          ls_phios TYPE tp_phio_list,
          lt_url   TYPE sdokcompurls,
          ld_url   TYPE saeuri.


    " Get Bild Grundriss
    " Get PDF Xstring
    DATA(rd_xstring) = zcl_bild_services=>get_dokument_zum_objekt(
          id_bukrs   = is_list-bukrs
          id_swenr   = is_list-swenr
          id_sgenr   = is_list-sgenr
          id_smenr   = is_list-smenr
          id_type    = '03' " Grundriss
          ).
    IF rd_xstring IS NOT INITIAL.
      " Set PDF
      APPEND INITIAL LINE TO lt_file ASSIGNING FIELD-SYMBOL(<ls_file>).

      " Get Filename Energieausweis
      DATA(ld_filename) = |Grundriss_03_{ is_list-bukrs }_{ is_list-swenr }_{ is_list-smenr }.jpg|.

      <ls_file>-checkbox = abap_true.
      <ls_file>-filename = ld_filename.
      <ls_file>-content  = rd_xstring.

    ENDIF.


    CLEAR ls_text.
    APPEND ls_text TO lt_text.
    CLEAR ls_text.
    APPEND ls_text TO lt_text.

    CLEAR ls_text.
    ls_text =  |Mit freundlichen Grüßen|.
    APPEND ls_text TO lt_text.
    CLEAR ls_text.
    APPEND ls_text TO lt_text.

    CLEAR ls_text.
    ls_text =   |Covivio Immobilien GmbH|.
    APPEND ls_text TO lt_text.

    CLEAR ls_text.
    APPEND ls_text TO lt_text.


    ls_text = |Dieses Schreiben wurde maschinell erstellt, bei Fragen wenden Sie sich bitte an PM-Support – Thorsten Zier (0208/97064-471).| ##NO_TEXT.
    APPEND ls_text TO lt_text.



  ENDIF.

*   GET Empfänger
  DATA: rt_partner TYPE z_t_zemod_partrel,
        ls_partner LIKE LINE OF rt_partner.

  ls_address_mail   = 'einzelbegehung@pointline.de ' ##NO_TEXT.
  APPEND ls_address_mail TO lt_address_mail.
  ls_address_mail   = 'werkstudenten@covivio.immo'.##NO_TEXT.
  APPEND ls_address_mail TO lt_address_mail.



  DATA: ld_emal_sofort TYPE flag.

  IF if_in_update_task = abap_false.
    ld_emal_sofort = abap_true.
  ELSE.
    ld_emal_sofort = abap_false.
  ENDIF.


  zcl_admin_services=>email_senden_neu_convert(
   EXPORTING
     id_betreff       = ld_title
     it_text          = lt_text
     it_addresses     = lt_address_mail
     it_file          = lt_file
     if_commit_work   = ld_emal_sofort
     id_bcs_rqst      = lc_bcs_rqst
     it_address_user   = lt_address_sap
     id_sender        = 'ZBATCH'
   EXCEPTIONS
     error        = 1
     OTHERS       = 2
     ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    RAISING error.
  ENDIF.



ENDMETHOD.


METHOD set_belegung_icon.

  IF cl_reca_date=>is_dateto_initial( id_dateto = id_recnendabs ) = abap_false.
    cd_belegung_icon = icon_wf_unlink.
  ELSE.
    IF ( id_stichtag >= id_recnendabs AND
         cl_reca_date=>is_dateto_initial( id_dateto = id_recnendabs ) = abap_false ) OR
       ( cl_reca_date=>is_dateto_initial( id_dateto = id_recnendabs ) = abap_true ).
      cd_belegung_icon = icon_wf_link.
    ELSE.
      cd_belegung_icon = icon_wf_unlink.
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD set_indo_wohnverwalter.

  DATA: gd_text_update TYPE string,
        ld_date_c(10)  TYPE c.

  IF subrc <> 0.

*         build icon for Update
    IF id_kuendgrud <> '74'. " SAP-Kdg. wg Verkauf, Abbruch     " EF 18924
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name   = 'ICON_MAIL'
*         INFO   = TEXT-FEE
        IMPORTING
          result = gd_text_update
        EXCEPTIONS
          OTHERS = 0.

      CONCATENATE gd_text_update
      TEXT-fee
      INTO cd_info_verwalter
      SEPARATED BY ' '.
    ELSE.                                                   " EF 18924
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name   = 'ICON_INFORMATION' " EF 18924
*         INFO   = TEXT-FEE
        IMPORTING
          result = gd_text_update
        EXCEPTIONS
          OTHERS = 0.

      CONCATENATE gd_text_update
      TEXT-fee
      INTO cd_info_verwalter
      SEPARATED BY ' '.
    ENDIF.
  ELSE.                                                     " EF 18924

*     build icon for Update
    IF id_kuendgrud <> '74'. " SAP-Kdg. wg Verkauf, Abbruch     " EF 18924
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name   = 'ICON_MAIL'
*         INFO   = TEXT-OKE
        IMPORTING
          result = gd_text_update
        EXCEPTIONS
          OTHERS = 0.
    ELSE.                                                   " EF 18924
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          name   = 'ICON_INFORMATION' " EF 18924
*         INFO   = TEXT-FEE
        IMPORTING
          result = gd_text_update
        EXCEPTIONS
          OTHERS = 0.
    ENDIF.                                                  " EF 18924

    IF id_infoart = 'KV'.

*     build Datum
      CALL METHOD cl_reca_date=>as_char
        EXPORTING
          id_date = id_recnendabs
        RECEIVING
          rd_date = ld_date_c.

      CONCATENATE gd_text_update
      'Kündigung Vertrag' ##NO_TEXT
      'zum'
      ld_date_c
      INTO cd_info_verwalter
      SEPARATED BY ' '.

    ELSE.
*     build Datum
      CALL METHOD cl_reca_date=>as_char
        EXPORTING
          id_date = sy-datum
        RECEIVING
          rd_date = ld_date_c.
      CONCATENATE gd_text_update
      'Stornierung/Löschung Kündigung' ##NO_TEXT
      'am'
      ld_date_c
      INTO cd_info_verwalter
      SEPARATED BY ' '.
    ENDIF.
  ENDIF.
ENDMETHOD.


  METHOD zif_has_meas_mngr~get_meascn_mngr.

    READ TABLE mto_bus_object INTO ro_bus_object WITH KEY table_line->md_objnr = id_objnr.
    IF sy-subrc <> 0.
      cf_reca_bus_object=>find_by_objnr(
      EXPORTING
        id_objnr       = id_objnr
        id_activity    = reca1_activity-change
        if_enqueue     = abap_false
        RECEIVING
        ro_instance    = ro_bus_object
      EXCEPTIONS
        error          = 1
        OTHERS         = 2
        ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING error.
      ENDIF.

*   register as child
      add_child( ro_bus_object ).

      APPEND ro_bus_object TO mto_bus_object. "  Manager für MEASCN

    ENDIF.

  ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~check_delete_objekt.

  DATA: ld_cnt   TYPE sy-index,
        ld_objnr TYPE recaobjnr,
        lt_list  TYPE z_t_ztcontr_anlage,
        ls_list  LIKE LINE OF lt_list.

  FIELD-SYMBOLS <ls_list> LIKE LINE OF mt_list.

  READ TABLE mt_list ASSIGNING <ls_list> WITH TABLE KEY key = is_detail-key.

  IF <ls_list>-me_update_flag = abap_false.
    rd_alowed_flag = abap_true.
  ELSE.
    rd_alowed_flag = abap_false.
  ENDIF.


ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~check_key.

* BODY

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~count.

* BODY
  rd_count = lines( mt_list ).

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~exists.

  READ TABLE mt_list TRANSPORTING NO FIELDS WITH KEY ('KEY2')
  COMPONENTS  dienstleistung = is_key-dienstleistung
              objnr          = is_key-objnr
              meas           = is_key-meas
              meas_guid      = is_key-meas_guid
  .
  IF sy-subrc = 0.
    rf_exists = abap_true.
  ELSE.
    rf_exists = abap_false.
  ENDIF.

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~get_detail.

* BODY
  READ TABLE mt_list INTO rs_detail WITH KEY ('KEY2')
        COMPONENTS dienstleistung  = is_key-dienstleistung
                          objnr     = is_key-objnr
                          meas      = is_key-meas
                          meas_guid = is_key-meas_guid.

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~get_detail_x.

  DATA:
    lt_color_1 TYPE lvc_t_scol,
    lt_color_2 TYPE lvc_t_scol,
    lt_color_3 TYPE lvc_t_scol,
    ls_color   TYPE lvc_s_scol,
    ls_style   TYPE lvc_s_styl.

  DATA rs_detail TYPE zpd_ztexd_flache.

  get_detail(
  EXPORTING
    is_key    = is_key
    RECEIVING
    rs_detail = rs_detail
  EXCEPTIONS
    not_found = 1
    OTHERS    = 2
    ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    RAISING not_found.
  ENDIF.

  rs_detail_x-zpd_ztexd_flache = rs_detail.

  CLEAR rs_detail_x-styletab[].
  CLEAR rs_detail_x-colortab[].

  CLEAR ls_style.
  ls_style-fieldname = 'ME_UPDATE'.
  ls_style-style     = '00000020'. " bold
  INSERT ls_style INTO TABLE rs_detail_x-styletab[].


  CLEAR ls_style.
  ls_style-fieldname = 'MEASVALUE'.
  ls_style-style     = '00000020'. " bold
  INSERT ls_style INTO TABLE rs_detail_x-styletab[].


  " E.F Wenn Update SAP durchgeführt keine Änderung mehr möglich
  CLEAR ls_style.
  ls_style-fieldname = 'AKTIVITAET'.
  ls_style-style     = '00000020'. " bold
  IF rs_detail_x-me_update_flag = abap_true OR rs_detail_x-me_update(7) = 'FEHLER:'.
    ls_style-style     = ls_style-style + cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.
  INSERT ls_style INTO TABLE rs_detail_x-styletab[].

  IF rs_detail_x-me_update_flag = abap_true OR rs_detail_x-me_update(7) = 'FEHLER:'.
    CLEAR ls_color.
    ls_color-fname     = 'AKTIVITAET'.
    ls_color-color-col = 5.
    ls_color-color-int = 0.
    ls_color-color-inv = 0.
    INSERT ls_color INTO TABLE rs_detail_x-colortab.
  ENDIF.


  CLEAR ls_style.
  ls_style-fieldname = 'MEASVALUE_NEU'.
  ls_style-style     = '00000020'. " bold
  IF rs_detail_x-me_update_flag = abap_true OR rs_detail_x-me_update(7) = 'FEHLER:'.
    ls_style-style     = ls_style-style + cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.
  INSERT ls_style INTO TABLE rs_detail_x-styletab[].

  IF rs_detail_x-me_update_flag = abap_true OR rs_detail_x-me_update(7) = 'FEHLER:'.
    CLEAR ls_color.
    ls_color-fname     = 'MEASVALUE_NEU'.
    ls_color-color-col = 5.
    ls_color-color-int = 0.
    ls_color-color-inv = 0.
    INSERT ls_color INTO TABLE rs_detail_x-colortab.
  ENDIF.


  CLEAR ls_style.
  ls_style-fieldname = 'EXT_FERTDAT'.
  ls_style-style     = '00000020'. " bold
  IF rs_detail_x-aktivitaet <> 'sofort'.
    ls_style-style     = ls_style-style + cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.
  INSERT ls_style INTO TABLE rs_detail_x-styletab[].

  IF rs_detail_x-me_update_flag = abap_true OR rs_detail_x-me_update(7) = 'FEHLER:'.
    CLEAR ls_color.
    ls_color-fname     = 'EXT_FERTDAT'.
    ls_color-color-col = 5.
    ls_color-color-int = 0.
    ls_color-color-inv = 0.
    INSERT ls_color INTO TABLE rs_detail_x-colortab.
  ENDIF.


* Set Icone
  IF rs_detail_x-icon_detail IS INITIAL .
    rs_detail_x-icon_detail = icon_led_green. " OK
  ENDIF.

  IF rs_detail_x-me_update_flag = abap_true.
    IF rs_detail_x-icon_detail IS INITIAL .
      rs_detail_x-icon_detail = '@DF@'. " ICON_COMPLETE
    ENDIF.
    CLEAR ls_color.
    ls_color-fname     = 'ME_UPDATE'.
    ls_color-color-col = 5.
    ls_color-color-int = 0.
    ls_color-color-inv = 0.
    INSERT ls_color INTO TABLE rs_detail_x-colortab.
    CLEAR ls_color.
    ls_color-fname     = 'ICON_DETAIL'.
    ls_color-color-col = 5.
    ls_color-color-int = 0.
    ls_color-color-inv = 0.
    INSERT ls_color INTO TABLE rs_detail_x-colortab.

  ENDIF.

*  IF RS_DETAIL_X-AKTIVITAET = 'ja' AND RS_DETAIL_X-ME_STATUS = 'fremdgenutzt' AND RS_DETAIL_X-ME_UPDATE_FLAG = ABAP_FALSE.
*    IF RS_DETAIL_X-ICON_DETAIL IS INITIAL .
*      RS_DETAIL_X-ICON_DETAIL  = '@3O@'. " ICON_FINAL_DATE
*    ENDIF.
*    CLEAR LS_COLOR.
*    LS_COLOR-FNAME     = 'ME_UPDATE'.
*    LS_COLOR-COLOR-COL = 7.
*    LS_COLOR-COLOR-INT = 0.
*    LS_COLOR-COLOR-INV = 0.
*    INSERT LS_COLOR INTO TABLE RS_DETAIL_X-COLORTAB.
*    CLEAR LS_COLOR.
*    LS_COLOR-FNAME     = 'ICON_DETAIL'.
*    LS_COLOR-COLOR-COL = 7.
*    LS_COLOR-COLOR-INT = 0.
*    LS_COLOR-COLOR-INV = 0.
*    INSERT LS_COLOR INTO TABLE RS_DETAIL_X-COLORTAB.
*
*  ENDIF.

  IF rs_detail_x-me_update(7) = 'FEHLER:'.
    IF rs_detail_x-icon_detail IS INITIAL .
      rs_detail_x-icon_detail = '@3U@'. " ICON_BREAKPOINT
    ENDIF.
    CLEAR ls_color.
    ls_color-fname     = 'ME_UPDATE'.
    ls_color-color-col = 6.
    ls_color-color-int = 0.
    ls_color-color-inv = 0.
    INSERT ls_color INTO TABLE rs_detail_x-colortab.
    CLEAR ls_color.
    ls_color-fname     = 'ICON_DETAIL'.
    ls_color-color-col = 6.
    ls_color-color-int = 0.
    ls_color-color-inv = 0.
    INSERT ls_color INTO TABLE rs_detail_x-colortab.
  ENDIF.



  IF rs_detail_x-abweichung_m2 < 0.
    CLEAR ls_color.
    ls_color-fname     = 'ABWEICHUNG_M2'.
    ls_color-color-col = 6.
    ls_color-color-int = 0.
    ls_color-color-inv = 0.
    INSERT ls_color INTO TABLE rs_detail_x-colortab.

    CLEAR ls_color.
    ls_color-fname     = 'ABWEICHUNG_PROZ'.
    ls_color-color-col = 6.
    ls_color-color-int = 0.
    ls_color-color-inv = 0.
    INSERT ls_color INTO TABLE rs_detail_x-colortab.
  ENDIF.

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~get_ident.

  get_ident(
    EXPORTING
      is_detail = is_detail
    RECEIVING
      rd_ident  = rd_ident
    EXCEPTIONS
      error     = 1
      OTHERS    = 2
         ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING error.
  ENDIF.

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~get_list.

* BODY
  et_list[] = mt_list[].

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~get_list_x.
  DATA: lt_list_hash TYPE HASHED TABLE OF ztexd_flache WITH UNIQUE KEY dienstleistung
                                                                       objnr
                                                                       meas
                                                                       meas_guid.
  DATA: ls_list  LIKE LINE OF mt_list,
        ld_index TYPE sy-tabix.

  FIELD-SYMBOLS: <ls_list_x> LIKE LINE OF et_list_x.

  REFRESH et_list_x.

  INSERT LINES OF mt_list INTO TABLE lt_list_hash.

* BODY
  LOOP AT lt_list_hash INTO ls_list.

    APPEND INITIAL LINE TO et_list_x ASSIGNING <ls_list_x>.
    ld_index = sy-tabix.

    me->get_detail_x(
    EXPORTING
      is_key           = ls_list-key
      RECEIVING
      rs_detail_x      = <ls_list_x>
    EXCEPTIONS
      not_found        = 1
      OTHERS           = 2
      ).
    IF sy-subrc <> 0.
      DELETE et_list_x INDEX ld_index.
    ENDIF.

  ENDLOOP.

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~get_msglist.
  FIELD-SYMBOLS: <ls_list>    LIKE LINE OF mt_list.

  READ TABLE mt_list ASSIGNING <ls_list> WITH TABLE KEY key = is_key.

  _get_msglist(
      CHANGING
        co_msglist   = co_msglist
        dc_msgnumber = <ls_list>-msgnumber
           ).

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~get_text.

* BODY

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~init_by_dienstleistung.

* INIT RESULTS
  CLEAR mt_list.
  CLEAR mt_list_old.

* PRECONDITION
  IF id_dienstleistung IS INITIAL.
    mac_invalid_precondition.
  ENDIF.

* BODY
  md_activity     = id_activity.
  mf_auth_check   = id_auth_check.
  mf_enqueue      = id_enqueue.
  mf_reset_buffer = if_reset_buffer.


  md_dienstleistung  = id_dienstleistung.

* get stored list
  IF md_activity = reca1_activity-change.
    CALL METHOD fill_buffer( ).
  ENDIF.

* hold list to log changes
  IF md_activity <> reca1_activity-display.
    mt_list_old[] = mt_list[].
  ENDIF.

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~init_by_guidtab.

* INIT RESULTS
  CLEAR mt_list.
  CLEAR mt_list_old.

* PRECONDITION
  IF id_dienstleistung IS INITIAL.
    mac_invalid_precondition.
  ENDIF.

* BODY
  md_activity   = id_activity.
  mf_auth_check = id_auth_check.
  mf_enqueue    = id_enqueue.


  md_dienstleistung  = id_dienstleistung.

* get stored list
  IF it_tab[] IS NOT INITIAL.
    mt_list = it_tab.
  ELSE.
    me->fill_buffer(  ).
  ENDIF.

* hold list to log changes
  IF md_activity <> reca1_activity-display.
    mt_list_old[] = mt_list[].
  ENDIF.



ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~me_flaeche_updaten.


  DATA: lo_msglist TYPE REF TO if_reca_message_list,
        ld_fehler  TYPE flag,
        dummy      TYPE string.

  DATA: lt_cust       TYPE STANDARD TABLE OF zcus_aktivit,
        ls_cust       LIKE LINE OF lt_cust,
        ls_meas       LIKE LINE OF it_meas,
        lt_meas_upd   TYPE z_t_ztexd_flache,
        ls_meas_upd   LIKE LINE OF lt_meas_upd,
        ls_flache_upd LIKE LINE OF mt_list.




* Get Customizing
  SELECT * FROM zcus_aktivit INTO TABLE lt_cust.




  FIELD-SYMBOLS: <ls_list>     LIKE LINE OF mt_list,
                 <ls_list_upd> LIKE LINE OF mt_list.




  LOOP AT it_meas INTO ls_meas.


    READ TABLE mt_list ASSIGNING <ls_list> WITH TABLE KEY key = ls_meas-key.

    CHECK sy-subrc = 0.



    " create Massegesammler
    get_msglist(
      EXPORTING
        is_key     = <ls_list>-key
      CHANGING
        co_msglist = lo_msglist
           ).


    lo_msglist->clear( ).


    READ TABLE lt_cust INTO ls_cust WITH KEY aktivitaet = <ls_list>-aktivitaet.
    IF ls_cust-update_fl = abap_false.
      MESSAGE e026 WITH <ls_list>-aktivitaet INTO dummy.
*   Aktivität & ist für SAP_Update gesperrt (Customizing).
      lo_msglist->add_symsg( if_cumulate = abap_true ).
      ld_fehler = abap_true.
    ENDIF.


    IF <ls_list>-measvalue_neu IS INITIAL AND ls_cust-update_fl = abap_true AND ls_cust-update_value_null = abap_false.
      MESSAGE e000 WITH 'Bemessung neu ist initial. Bitte überprüfen' INTO dummy ##NO_TEXT.
*   & & & &
      lo_msglist->add_symsg( if_cumulate = abap_true ).
      ld_fehler = abap_true.
    ENDIF.

    IF cl_reca_date=>is_date_initial( id_date = <ls_list>-measvalidfrom ) = abap_true.
      MESSAGE e000 WITH 'Bemessung Gültig ab ist initial. Bitte überprüfen' INTO dummy ##NO_TEXT.
      lo_msglist->add_symsg( if_cumulate = abap_true ).
      ld_fehler = abap_true.
    ENDIF.

    IF cl_reca_date=>is_date_initial( id_date = <ls_list>-measvalidto ) = abap_true.
      MESSAGE e000 WITH 'Bemessung Gültig bis ist initial. Bitte überprüfen' INTO dummy ##NO_TEXT.
      lo_msglist->add_symsg( if_cumulate = abap_true ).
      ld_fehler = abap_true.
    ENDIF.

    IF ld_fehler = abap_true.
      io_msglist->add_from_instance(
           io_msglist        = lo_msglist
           if_cumulate       = abap_true
              ).
    ELSE.
      APPEND <ls_list> TO lt_meas_upd.
    ENDIF.

    AT END OF objnr.

      IF ld_fehler = abap_false AND lt_meas_upd[] IS NOT INITIAL.
        CLEAR ls_flache_upd.
*      Bemessung update
        flaeche_me_updaten(
           EXPORTING
             it_flache         = lt_meas_upd
             io_msglist        = lo_msglist
           CHANGING
             cd_me_update      = ls_flache_upd-me_update
             cd_me_update_flag = ls_flache_upd-me_update_flag
           EXCEPTIONS
             error             = 1
             OTHERS            = 2
                ).
        IF sy-subrc <> 0.
          lo_msglist->add_symsg( if_cumulate = abap_true ).
        ENDIF.

        " Status updaten
        LOOP AT lt_meas_upd INTO ls_meas_upd .
          READ TABLE mt_list ASSIGNING <ls_list_upd> WITH TABLE KEY key = ls_meas_upd-key.
          IF sy-subrc = 0.

            <ls_list_upd>-me_update      = ls_flache_upd-me_update.
            <ls_list_upd>-me_update_flag = ls_flache_upd-me_update_flag.

            io_msglist->add_from_instance(
            io_msglist        = lo_msglist
            if_cumulate       = abap_true
            ).


            " Set Status Icon
            _set_status_icon(
            EXPORTING
              io_msglist     = lo_msglist
              is_detail      = <ls_list_upd>
            CHANGING
              cd_status_icon = <ls_list_upd>-icon_detail
              ).

            store_messages(
            EXPORTING
              if_in_update_task = abap_false
              io_msglist        = lo_msglist
            EXCEPTIONS
              error             = 1
              OTHERS            = 2
              ).
            IF sy-subrc <> 0.
*           Implement suitable error handling here
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.



      REFRESH lt_meas_upd.

    ENDAT.

  ENDLOOP.

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~me_stammaend_set.

  DATA: lo_msglist TYPE REF TO if_reca_message_list,
        ld_fehler  TYPE flag,
        dummy      TYPE string.


  DATA: ld_infoart    TYPE zdextinfoart,
        ld_email_flag TYPE flag.

  DATA rd_ident   TYPE recaident.


  FIELD-SYMBOLS: <ls_list> LIKE LINE OF mt_list.


* Get ME-Objekt
  DATA: ro_rental_object TYPE REF TO if_rebd_rental_object,
        io_has_meas      TYPE REF TO  if_rebd_has_meas.

  DATA: et_measurement TYPE bapi_re_t_measurement_int,
        ls_meas        LIKE LINE OF et_measurement.
  DATA  ld_meas        TYPE rebdmeas.

  DATA: lo_belegung TYPE REF TO zcl_beleg_mod_decorator,
        ls_belegung TYPE        zsbelegung_leerstand.
  DATA: ls_misperiode	  TYPE zsmisperiode.








  LOOP AT mt_list ASSIGNING <ls_list> USING KEY ('KEY2')
                                      WHERE  dienstleistung = 'MEAS'
                                        AND  objnr          = is_detail-objnr.


    " create Massegesammler
    get_msglist(
      EXPORTING
        is_key     = <ls_list>-key
      CHANGING
        co_msglist = lo_msglist
           ).


    cf_rebd_rental_object=>find_by_objnr(
      EXPORTING
        id_objnr       = is_detail-objnr
        if_enqueue     = abap_false
      RECEIVING
        ro_instance    = ro_rental_object
      EXCEPTIONS
        error          = 1
        OTHERS         = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO dummy.
      lo_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.


*   Get Bemessungen
    io_has_meas ?= ro_rental_object.

*   Get Bemessung
    CALL FUNCTION 'REBD_API_MEASUREMENT_GET'
      EXPORTING
        io_has_meas    = io_has_meas
      IMPORTING
        et_measurement = et_measurement.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = <ls_list>-meas
      IMPORTING
        output = ld_meas.

*   Tabelle bereinigen
    DELETE et_measurement WHERE meas <> ld_meas.


    zcl_get_stammdaten_fx=>filter_list_by_seldate(
      EXPORTING
        id_fieldname_validfrom = 'VALIDFROM'
        id_fieldname_validto   = 'VALIDTO'
        id_seldate             = <ls_list>-stichtag
        id_seldate_min         = reca0_date-min
        id_seldate_max         = reca0_date-max
      CHANGING
        ct_list                = et_measurement
           ).
    READ TABLE et_measurement INTO ls_meas INDEX 1.
    IF sy-subrc = 0 AND ls_meas-measvalue <> <ls_list>-measvalue.
      " Set Aktualisierungsflag
      <ls_list>-refresh_obj = abap_true.
      <ls_list>-me_update   = 'ME Bemessungen geändert. Bitte Stammdaten aktualisieren.' ##NO_TEXT.

      get_ident(
        EXPORTING
          is_detail = <ls_list>
        RECEIVING
          rd_ident  = rd_ident
        EXCEPTIONS
          error     = 1
          OTHERS    = 2
             ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                      INTO dummy.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.

      MESSAGE s014 WITH rd_ident <ls_list>-measvalue ls_meas-measvalue INTO dummy.
*     Bitte ME-Stammdaten & aktualisieren. ME-Bemessung geändert Tool & ME &
      lo_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.





** Get Belegung
*
** Get Periode
*  ZCL_PDMIS_SERVICES=>GET_PERIODE(
*  EXPORTING
*    ID_LAUFDATUM  = <LS_LIST>-STICHTAG
*  CHANGING
*    CS_MISPERIODE = LS_MISPERIODE
*    ).
*
** Belegung und Leerstandsgrund
*  CREATE OBJECT LO_BELEGUNG.
*  IF LO_BELEGUNG IS BOUND.
*    LO_BELEGUNG->GET_BELEGUNG(
*    EXPORTING
*      ID_OBJNR             = <LS_LIST>-OBJNR
*      ID_VONDAT            = LS_MISPERIODE-VONDAT_B
*      ID_BISDAT            = LS_MISPERIODE-BISDAT_B
*    IMPORTING
*      ES_BELEGUNG          = LS_BELEGUNG
*      ).
*  ENDIF.
*  CLEAR: LO_BELEGUNG.
*




    " Set Status Icon
    _set_status_icon(
      EXPORTING
        io_msglist     = lo_msglist
        is_detail      = <ls_list>
      CHANGING
        cd_status_icon = <ls_list>-icon_detail
           ).

    store_messages(
      EXPORTING
        if_in_update_task = ABAP_false
        io_msglist        = lo_msglist
      EXCEPTIONS
        error             = 1
        OTHERS            = 2
           ).
    IF sy-subrc <> 0.
*           Implement suitable error handling here
    ENDIF.



  ENDLOOP.


ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~mv_kuendigung_set.

  DATA: lo_msglist TYPE REF TO if_reca_message_list,
        ld_fehler  TYPE flag,
        dummy      TYPE string.



  DATA: ld_infoart    TYPE zdextinfoart,
        ld_email_flag TYPE flag.

  DATA rd_ident   TYPE recaident.


  FIELD-SYMBOLS: <ls_list> LIKE LINE OF mt_list.

  LOOP AT mt_list ASSIGNING <ls_list>  USING KEY ('KEY2')
                                       WHERE   dienstleistung = is_key-dienstleistung
                                         AND   objnr          = is_key-objnr.


    " create Massegesammler
    get_msglist(
      EXPORTING
        is_key     = <ls_list>-key
      CHANGING
        co_msglist = lo_msglist
           ).


*   Kündigung wurde aktiviert
    IF ( is_detail-ntactive        = abap_true AND
         is_detail_before-ntactive = abap_false ).



      " prüfen ob zum Stichtag der Datenselektion die Wohnung noch belegt ist
      IF ( <ls_list>-stichtag >= <ls_list>-recnendabs AND
      cl_reca_date=>is_dateto_initial( id_dateto = <ls_list>-recnendabs ) = abap_false ).
*       Kündigung
        <ls_list>-me_status = 'Leerstehend' ##NO_TEXT.
      ELSE.
        <ls_list>-me_status = 'fremdgenutzt' ##NO_TEXT.
      ENDIF.

*     Set Icon für die Belegungsstatus
      set_belegung_icon(
        EXPORTING
          id_stichtag      = <ls_list>-stichtag
          id_recnendabs    = <ls_list>-recnendabs
        CHANGING
          cd_belegung_icon = <ls_list>-belegung_icon
             ).


      get_ident_mv(
        EXPORTING
          id_intreno = is_detail-intreno
        RECEIVING
          rd_ident   = rd_ident
        EXCEPTIONS
          error      = 1
          OTHERS     = 2
             ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO dummy.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.


      MESSAGE s012(zext_dienstl) WITH rd_ident sy-datum INTO dummy.
*     Kündigung von & wurde am & aktiviert

      lo_msglist->add_symsg( if_cumulate = abap_true ).

*      LD_INFOART = 'KV'. "  Kündigung Vertrag

*      CLEAR <LS_LIST>-INFO_VERWALTER.
*
*      IF <LS_LIST>-AKTIVITAET = 'info'.
*
*
*        IF LD_EMAIL_FLAG IS INITIAL.
*
*
*          SENDE_INFO_EMAIL(
*            EXPORTING
*              IS_LIST           = <LS_LIST>
*              IO_MSGLIST        = LO_MSGLIST
*              ID_RECNENDABS     = <LS_LIST>-RECNENDABS
*              ID_INFOART        = LD_INFOART
*            CHANGING
*              CD_INFO_VERWALTER = <LS_LIST>-INFO_VERWALTER
*            EXCEPTIONS
*              ERROR             = 1
*              OTHERS            = 2
*                 ).
*
*
*          SET_INDO_WOHNVERWALTER(
*             EXPORTING
*               SUBRC             = SY-SUBRC
*               ID_INFOART        = LD_INFOART
*             CHANGING
*               CD_INFO_VERWALTER = <LS_LIST>-INFO_VERWALTER
*                  ).
*
*          LD_EMAIL_FLAG = ABAP_TRUE.
*
*        ELSE.
*
*
*          SET_INDO_WOHNVERWALTER(
*            EXPORTING
*              SUBRC             = SY-SUBRC
*              ID_INFOART        = LD_INFOART
*            CHANGING
*              CD_INFO_VERWALTER = <LS_LIST>-INFO_VERWALTER
*                 ).
*
*        ENDIF.
*
*      ENDIF.

    ELSEIF ( is_detail-ntactive        = abap_false AND
             is_detail_before-ntactive = abap_true ).


*     Set Kündigung zum Datum
      <ls_list>-recnendabs = ' '.

*     Kündigung
      <ls_list>-me_status = 'fremdgenutzt'.

      get_ident_mv(
        EXPORTING
          id_intreno = is_detail-intreno
        RECEIVING
          rd_ident   = rd_ident
        EXCEPTIONS
          error      = 1
          OTHERS     = 2
             ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO dummy.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.

      MESSAGE s013(zext_dienstl) WITH rd_ident sy-datum INTO dummy.
*     Kündigung von & wurde am & deaktiviert

      lo_msglist->add_symsg( if_cumulate = abap_true ).

*     Set Icon für die Belegungsstatus
      set_belegung_icon(
        EXPORTING
          id_stichtag      = <ls_list>-stichtag
          id_recnendabs     = <ls_list>-recnendabs
        CHANGING
          cd_belegung_icon = <ls_list>-belegung_icon
             ).


*      LD_INFOART = 'KS'. "  Stornierung/Löschung Kündigung
*
*      IF <LS_LIST>-AKTIVITAET = 'info'.
*
*        CLEAR <LS_LIST>-INFO_VERWALTER.
*
*        IF LD_EMAIL_FLAG IS INITIAL.
*
*
*          SENDE_INFO_EMAIL(
*            EXPORTING
*              IS_LIST           = <LS_LIST>
*              IO_MSGLIST        = LO_MSGLIST
*              ID_RECNENDABS     = <LS_LIST>-RECNENDABS
*              ID_INFOART        = LD_INFOART
*            CHANGING
*              CD_INFO_VERWALTER = <LS_LIST>-INFO_VERWALTER
*            EXCEPTIONS
*              ERROR             = 1
*              OTHERS            = 2
*                 ).
*
*
*          SET_INDO_WOHNVERWALTER(
*             EXPORTING
*               SUBRC             = SY-SUBRC
*               ID_INFOART        = LD_INFOART
*             CHANGING
*               CD_INFO_VERWALTER = <LS_LIST>-INFO_VERWALTER
*                  ).
*
*
*          LD_EMAIL_FLAG = ABAP_TRUE.
*
*        ELSE.
*
*          SET_INDO_WOHNVERWALTER(
*             EXPORTING
*               SUBRC             = SY-SUBRC
*               ID_INFOART        = LD_INFOART
*             CHANGING
*               CD_INFO_VERWALTER = <LS_LIST>-INFO_VERWALTER
*                  ).
*
*        ENDIF.
*
*      ENDIF.

    ENDIF.


    " Set Status Icon
    _set_status_icon(
      EXPORTING
        io_msglist     = lo_msglist
        is_detail      = <ls_list>
      CHANGING
        cd_status_icon = <ls_list>-icon_detail
           ).

    store_messages(
      EXPORTING
        if_in_update_task = abap_false
        io_msglist        = lo_msglist
      EXCEPTIONS
        error             = 1
        OTHERS            = 2
           ).
    IF sy-subrc <> 0.
*           Implement suitable error handling here
    ENDIF.



  ENDLOOP.





ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~mv_laufzeitende_set.

  DATA: lo_msglist TYPE REF TO if_reca_message_list,
        ld_fehler  TYPE flag,
        dummy      TYPE string.

  DATA rd_ident   TYPE recaident.

  DATA ld_email_flag TYPE abap_bool.

  DATA: ld_infoart    TYPE zdextinfoart.


  FIELD-SYMBOLS: <ls_list> LIKE LINE OF mt_list.


  IF ( id_recnendabs  <> id_recnendabs_old  ).

    LOOP AT mt_list ASSIGNING <ls_list> USING KEY ('KEY2')
                                        WHERE   dienstleistung = is_key-dienstleistung
                                           AND  objnr          = is_key-objnr.



      " create Massegesammler
      get_msglist(
        EXPORTING
          is_key     = <ls_list>-key
        CHANGING
          co_msglist = lo_msglist
             ).


      get_ident_mv(
        EXPORTING
          id_intreno = is_detail-intreno
        RECEIVING
          rd_ident   = rd_ident
        EXCEPTIONS
          error      = 1
          OTHERS     = 2
             ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO dummy.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.


      MESSAGE s015(zext_dienstl) WITH rd_ident id_recnendabs_old id_recnendabs INTO dummy.
*     & Laufzeitende & wurde geändert &..

      lo_msglist->add_symsg( if_cumulate = abap_true ).


*     Set Kündigung zum Datum
      <ls_list>-recnendabs = id_recnendabs.

      IF ( <ls_list>-stichtag >= <ls_list>-recnendabs AND
      cl_reca_date=>is_dateto_initial( id_dateto = <ls_list>-recnendabs ) = abap_false ).
*       Kündigung
        <ls_list>-me_status = 'Leerstehend' ##NO_TEXT.
      ELSE.
        <ls_list>-me_status = 'fremdgenutzt' ##NO_TEXT.
      ENDIF.

*     Set Icon für die Belegungsstatus
      set_belegung_icon(
        EXPORTING
          id_stichtag      = <ls_list>-stichtag
          id_recnendabs     = <ls_list>-recnendabs
        CHANGING
          cd_belegung_icon = <ls_list>-belegung_icon
             ).

*     Kündigung wurde aktiviert
      IF <ls_list>-aktivitaet = 'info' ##NO_TEXT.

        IF ( cl_reca_date=>is_dateto_initial( id_dateto = <ls_list>-recnendabs ) = abap_false ).
          ld_infoart = 'KV'. "  Kündigung Vertrag
        ELSE.
          ld_infoart = 'KS'. "  Stornierung/Löschung Kündigung
        ENDIF.

        CLEAR <ls_list>-info_verwalter.

        " Get Vermietungsstopp

* Quick Fix Append ORDER BY PRIMARY KEY to the SELECT statement
* 30.04.2024 09:37:30 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*        SELECT  ZZUSR15 FROM VIBDRO
*        WHERE BUKRS = @<LS_LIST>-BUKRS
*          AND SWENR = @<LS_LIST>-SWENR
*          AND SMENR = @<LS_LIST>-SMENR
*          INTO @<LS_LIST>-ZZUSR15 UP TO 1 ROWS.

        SELECT zzusr15 FROM vibdro
         WHERE bukrs = @<ls_list>-bukrs
         AND swenr = @<ls_list>-swenr
         AND smenr = @<ls_list>-smenr ORDER BY PRIMARY KEY
         INTO @<ls_list>-zzusr15 UP TO 1 ROWS .
* End of Quick Fix

        ENDSELECT.

        IF ld_email_flag  IS INITIAL.

          IF is_detail-recnnotreason <> '74'. " SAP-Kdg. wg Verkauf, Abbruch     " EF 18924

            sende_info_email(
              EXPORTING
                is_list           = <ls_list>
                io_msglist        = lo_msglist
                id_recnendabs     = <ls_list>-recnendabs
                id_infoart        = ld_infoart
                if_in_update_task = if_in_update_task
              CHANGING
                cd_info_verwalter = <ls_list>-info_verwalter
              EXCEPTIONS
                error             = 1
                OTHERS            = 2
                   ).

            " Get Bild Grundriss
*              SELECT SINGLE ZZFILENAME
*              FROM DRAD
*              WHERE DRAD~DOKOB = 'VIBDRO'
*              AND DRAD~ZZBUKRS  = @<LS_LIST>-BUKRS
*              AND DRAD~ZZSWENR  = @<LS_LIST>-SWENR
*              AND DRAD~ZZSMENR  = @<LS_LIST>-SMENR
*              AND DRAD~ZZBILDTYPE = '13'
*              INTO @DATA(LD_DRAD).
*              IF SY-SUBRC <> 0.
*                " EF EMAIL-Beauftragung Grundriss CH2209-0012
*                SENDE_INFO_EMAIL_GRUNDRISS(
*                   EXPORTING
*                     IS_LIST           = <LS_LIST>
*                     IO_MSGLIST        = LO_MSGLIST
*                     ID_RECNENDABS     = <LS_LIST>-RECNENDABS
*                     ID_INFOART        = LD_INFOART
*                     IF_IN_UPDATE_TASK = IF_IN_UPDATE_TASK
*                   CHANGING
*                     CD_INFO_VERWALTER = <LS_LIST>-INFO_VERWALTER
*                   EXCEPTIONS
*                     ERROR             = 1
*                     OTHERS            = 2
*                        ).
*                IF SY-SUBRC <> 0.
**            Implement suitable error handling here
*                ENDIF.
*              ENDIF.
          ENDIF.                                            " EF 18924

          set_indo_wohnverwalter(
             EXPORTING
               subrc             = sy-subrc
               id_infoart        = ld_infoart
               id_recnendabs     = <ls_list>-recnendabs
               id_kuendgrud      = is_detail-recnnotreason  " EF 18924
             CHANGING
               cd_info_verwalter = <ls_list>-info_verwalter
                  ).


          ld_email_flag = abap_true.

        ELSE.

          set_indo_wohnverwalter(
             EXPORTING
               subrc             = sy-subrc
               id_infoart        = ld_infoart
               id_recnendabs     = <ls_list>-recnendabs
               id_kuendgrud      = is_detail-recnnotreason  " EF 18924
             CHANGING
               cd_info_verwalter = <ls_list>-info_verwalter
                  ).

        ENDIF.


      ENDIF.


      " Set Status Icon
      _set_status_icon(
        EXPORTING
          io_msglist     = lo_msglist
          is_detail      = <ls_list>
        CHANGING
          cd_status_icon = <ls_list>-icon_detail
             ).

      store_messages(
        EXPORTING
          if_in_update_task = abap_false
          io_msglist        = lo_msglist
        EXCEPTIONS
          error             = 1
          OTHERS            = 2
             ).
      IF sy-subrc <> 0.
*           Implement suitable error handling here
      ENDIF.

    ENDLOOP.

  ENDIF.


ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~objektliste_change.
  DATA: lo_msglist TYPE REF TO if_reca_message_list,
        ld_fehler  TYPE flag,
        dummy      TYPE string,
        ld_text    TYPE string.
  DATA: lt_cust TYPE STANDARD TABLE OF zcus_aktivit,
        ls_cust LIKE LINE OF lt_cust.

  DATA ro_instance    TYPE REF TO if_rebd_rental_object.
  DATA: lt_measurement TYPE  bapi_re_t_measurement_int,
        ls_measurement TYPE  bapi_re_measurement_int.

  FIELD-SYMBOLS: <ls_list> LIKE LINE OF mt_list.

  DATA: ld_prozentsatz  TYPE rebdmeasvalue.                 " ED 15443



* Get Customizing
  SELECT * FROM zcus_aktivit INTO TABLE lt_cust.


  READ TABLE mt_list ASSIGNING <ls_list> WITH TABLE KEY key = is_list-key.
  IF sy-subrc = 0.

    CLEAR ro_instance.

    " create Massegesammler
    get_msglist(
      EXPORTING
        is_key     = <ls_list>-key
      CHANGING
        co_msglist = lo_msglist
           ).

    DATA et_list_x    TYPE re_t_msg_x.

    lo_msglist->get_list_x(
      EXPORTING
        id_msgty     = 'E'
        if_or_higher = abap_true
      IMPORTING
        et_list_x    = et_list_x
        ).

    LOOP AT et_list_x INTO DATA(ls_list_x).

      lo_msglist->delete_message(
      EXPORTING
        id_msgnumber = ls_list_x-msgnumber
      EXCEPTIONS
        not_found    = 1
        OTHERS       = 2
        ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING error.
      ENDIF.

    ENDLOOP.

    IF <ls_list>-measvalue_neu <> is_list-measvalue_neu.
      CONCATENATE <ls_list>-ident 'Bemes:' <ls_list>-meas INTO ld_text SEPARATED BY ' ' ##NO_TEXT.
      MESSAGE s024 WITH ld_text <ls_list>-measvalue_neu sy-datum INTO dummy.
*      Eintrag & & wurde am & geändert.
      lo_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.


    <ls_list>-tab = is_list-tab.
    IF <ls_list>-measvalue_neu IS NOT INITIAL.
      <ls_list>-measunit_neu = <ls_list>-measunit.

      <ls_list>-abweichung_m2   = ( <ls_list>-measvalue_neu - <ls_list>-measvalue ).
      " EF Division durch 0 " EF 14726
      IF <ls_list>-measvalue_neu <> 0 AND <ls_list>-measvalue <> 0. " EF 14726
        ld_prozentsatz = ( <ls_list>-measvalue_neu * 100 / <ls_list>-measvalue - 100 ). " ED 15443
        IF ld_prozentsatz > 1000.                           " ED 15443
          <ls_list>-abweichung_proz = '999.99'.             " ED 15443
        ELSE.                                               " ED 15443
          <ls_list>-abweichung_proz = ld_prozentsatz.       " ED 15443
        ENDIF.                                              " ED 15443
*        <LS_LIST>-ABWEICHUNG_PROZ = ( <LS_LIST>-MEASVALUE_NEU * 100 / <LS_LIST>-MEASVALUE - 100 )." ED 15443
      ENDIF.                                                " EF 14726
    ELSE.
      <ls_list>-measunit_neu = ' '.
    ENDIF.


*   Set Valid-Daten
    IF cl_reca_date=>is_date_initial( id_date = <ls_list>-ext_fertdat ) = abap_false AND
     <ls_list>-aktivitaet = 'sofort'.
* Get Mietobjektreferenz
      cf_rebd_rental_object=>find_by_objnr( ##SUBRC_OK
        EXPORTING
          id_objnr       = <ls_list>-objnr
          id_activity    = reca1_activity-display
           if_enqueue     = abap_false
        RECEIVING
          ro_instance    = ro_instance
        EXCEPTIONS
          error          = 1
          OTHERS         = 2
             ).

      CHECK ro_instance IS BOUND.

      CALL FUNCTION 'API_RE_RO_GET_DETAIL'
        EXPORTING
          io_object           = ro_instance
          id_detail_data_from = <ls_list>-stichtag
          id_detail_data_to   = reca0_date-max
        IMPORTING
          et_measurement      = lt_measurement
        EXCEPTIONS
          error               = 1
          OTHERS              = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                      INTO dummy.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.

      CALL METHOD cl_reca_bapi_services=>filter_list_by_detail_period
        EXPORTING
          id_fieldname_validfrom = 'VALIDFROM'
          id_fieldname_validto   = 'VALIDTO'
          id_seldate_from        = <ls_list>-stichtag
          id_seldate_to          = reca0_date-max
          id_seldate_min         = '19980101'
          id_seldate_max         = '99991231'
        CHANGING
          ct_list                = lt_measurement.

      " sehr wichtig! es wird nur letzter gültigen Bemessung geändert.
      SORT lt_measurement BY meas validto DESCENDING.
      READ TABLE lt_measurement INTO ls_measurement WITH KEY meas      = <ls_list>-meas
                                                             measvalue = <ls_list>-measvalue.
      IF <ls_list>-ext_fertdat <= ls_measurement-validfrom.
        MESSAGE e030 WITH ls_measurement-validfrom INTO dummy.
*       Das Datum "Umsetzung per" soll größer als & sein.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ELSE.
        READ TABLE lt_cust INTO ls_cust WITH KEY aktivitaet = <ls_list>-aktivitaet.
        IF ls_cust-update_fl = abap_true.
          IF <ls_list>-measvalue_neu IS NOT INITIAL.
            <ls_list>-measvalidto   = <ls_list>-ext_fertdat - 1.
            <ls_list>-measvalidfrom = <ls_list>-ext_fertdat.
          ELSE.
            IF ls_cust-update_value_null  = abap_true.
              <ls_list>-measvalidto   = <ls_list>-ext_fertdat - 1.
              <ls_list>-measvalidfrom = <ls_list>-ext_fertdat.
            ELSE.
              MESSAGE e027 WITH 'sofort' '0' INTO dummy.
*           Datentransfer beim Aktivität & und Value & sind nicht zugelassen.
              lo_msglist->add_symsg( if_cumulate = abap_true ).
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      CLEAR <ls_list>-ext_fertdat.
    ENDIF.

* prüfen Aktivität Ja
    IF  <ls_list>-aktivitaet = 'ja'.
* GET MIETOBJEKTREFERENZ
      cf_rebd_rental_object=>find_by_objnr( ##SUBRC_OK
        EXPORTING
          id_objnr       = <ls_list>-objnr
          id_activity    = reca1_activity-display
           if_enqueue     = abap_false
        RECEIVING
          ro_instance    = ro_instance
        EXCEPTIONS
          error          = 1
          OTHERS         = 2
             ).

      CHECK ro_instance IS BOUND.

      CALL FUNCTION 'API_RE_RO_GET_DETAIL'
        EXPORTING
          io_object           = ro_instance
          id_detail_data_from = <ls_list>-stichtag
          id_detail_data_to   = reca0_date-max
        IMPORTING
          et_measurement      = lt_measurement
        EXCEPTIONS
          error               = 1
          OTHERS              = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                      INTO dummy.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.

      CALL METHOD cl_reca_bapi_services=>filter_list_by_detail_period
        EXPORTING
          id_fieldname_validfrom = 'VALIDFROM'
          id_fieldname_validto   = 'VALIDTO'
          id_seldate_from        = <ls_list>-stichtag
          id_seldate_to          = reca0_date-max
          id_seldate_min         = '19980101'
          id_seldate_max         = '99991231'
        CHANGING
          ct_list                = lt_measurement.

      " sehr wichtig! es wird nur letzter gültigen Bemessung geändert.
      SORT lt_measurement BY meas validto DESCENDING.
      READ TABLE lt_measurement INTO ls_measurement WITH KEY meas      = <ls_list>-meas
                                                             measvalue = <ls_list>-measvalue.
      IF cl_reca_date=>is_date_initial( id_date = <ls_list>-recnendabs ) = abap_false AND
        <ls_list>-recnendabs <= ls_measurement-validfrom.
        MESSAGE e031 WITH <ls_list>-recnendabs ls_measurement-validfrom INTO dummy.
*       Updatekonflikt "Kündigung zum" & soll größer Beginn akt. Bemessung & sein
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ELSE.

        READ TABLE lt_cust INTO ls_cust WITH KEY aktivitaet = <ls_list>-aktivitaet.
        IF ls_cust-update_fl = abap_true.
          IF <ls_list>-measvalue_neu IS NOT INITIAL.
            IF cl_reca_date=>is_date_initial( id_date = <ls_list>-recnendabs ) = abap_false.
              <ls_list>-measvalidto   = <ls_list>-recnendabs.
              <ls_list>-measvalidfrom = <ls_list>-recnendabs + 1.
            ELSE.                                           " EF 16445
              <ls_list>-measvalidto   = '00000000'.         " EF 16445
              <ls_list>-measvalidfrom = '00000000'.         " EF 16445
            ENDIF.
          ELSE.
            IF ls_cust-update_value_null  = abap_true.
              IF cl_reca_date=>is_date_initial( id_date = <ls_list>-recnendabs ) = abap_false.
                <ls_list>-measvalidto   = <ls_list>-recnendabs.
                <ls_list>-measvalidfrom = <ls_list>-recnendabs + 1.
              ELSE.                                         " EF 16445
                <ls_list>-measvalidto   = '00000000'.       " EF 16445
                <ls_list>-measvalidfrom = '00000000'.       " EF 16445
              ENDIF.
            ELSE.
              MESSAGE e027 WITH 'ja' '0' INTO dummy.
*           Datentransfer beim Aktivität & und Value & sind nicht zugelassen.
              lo_msglist->add_symsg( if_cumulate = abap_true ).
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    " Set Status Icon
    _set_status_icon(
      EXPORTING
        io_msglist     = lo_msglist
        is_detail      = <ls_list>
      CHANGING
        cd_status_icon = <ls_list>-icon_detail
           ).

    store_messages(
      EXPORTING
        if_in_update_task = abap_false
        io_msglist        = lo_msglist
      EXCEPTIONS
        error             = 1
        OTHERS            = 2
           ).
    IF sy-subrc <> 0.
*           Implement suitable error handling here
    ENDIF.

  ELSE.
    MESSAGE e001(zhwk_aufmass) WITH is_list-ident is_list-meas_guid RAISING error.
*   Leistungsposition &/& existiert nicht.
  ENDIF.
ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~objektliste_create.
  DATA: lo_msglist TYPE REF TO if_reca_message_list,
        ld_fehler  TYPE flag,
        dummy      TYPE string.


* Get Get Belegung
  DATA: lo_belegung   TYPE REF TO zcl_beleg_mod_decorator.
  DATA: es_belegung_leerstand TYPE zsbelegung_leerstand.

  DATA: is_rokey       TYPE vibdro_key,
        e_nutz_fin_art TYPE char100,
        e_finart       TYPE rebdfixfitcharact.

  FIELD-SYMBOLS <ls_list> LIKE LINE OF mt_list.

  ASSERT io_msglist IS BOUND.

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

  DATA: et_cust_snunr TYPE STANDARD TABLE OF  tivbdmeasro,
        ls_cust_snunr LIKE LINE OF et_cust_snunr,
        rd_ident      TYPE recaident,
        cd_imbestand  TYPE char1.
  DATA  ro_rental_object   TYPE REF TO if_rebd_rental_object.

*  Get Customizing zum Nutzungsart und Bemessung
  SELECT * FROM tivbdmeasro INTO TABLE et_cust_snunr
    FOR ALL ENTRIES IN et_cust_meas_x
     WHERE meas       = et_cust_meas_x-meas
      AND  usageforro <> ' '.
  IF et_cust_snunr[] IS INITIAL.
    MESSAGE e004(zext_dienstl) WITH 'ZV_DBEXTMEAS' 'TIVBDMEASRO' RAISING error.
*   Cust Bemessungsart & : Einstellungen pro Nutzungsart nicht definiert &
  ENDIF.

* Zum Lieferant die zugeordnete Objekte lesen
  DATA: et_ext_flache         TYPE z_t_ztexd_flache,
        et_obj_lieferant_list TYPE STANDARD TABLE OF ztexd_flache WITH UNIQUE HASHED KEY hashed_key
                                                                      COMPONENTS objnr
                                                                                 meas,
        ls_obj_lieferant_list LIKE LINE OF et_obj_lieferant_list.

  zcl_get_ztexd_flache=>get_list_by_dienstleistung(
    EXPORTING
      id_dienstleistung   = md_dienstleistung
*      IF_BYPASSING_BUFFER = ABAP_TRUE
      id_max_buffer_size  = 0
    IMPORTING
      et_list             = et_ext_flache
         ).

  DELETE et_ext_flache WHERE ( me_update_flag = abap_true ).

  INSERT LINES OF et_ext_flache INTO TABLE et_obj_lieferant_list.

* Pro Bemessung ein Satz aufbauen
  LOOP AT et_cust_snunr INTO ls_cust_snunr WHERE snunr = ist_objektliste-snunr.

*   Check zuordnung zum Lieferant exists?
    READ TABLE et_obj_lieferant_list INTO ls_obj_lieferant_list  WITH TABLE KEY hashed_key
                                                                     COMPONENTS objnr = ist_objektliste-objnr
                                                                                meas  = ls_cust_snunr-meas.
    IF sy-subrc = 0.
      MESSAGE e005(zext_dienstl) WITH ls_obj_lieferant_list-ext_dienstlif ls_obj_lieferant_list-ident ls_cust_snunr-meas
      INTO dummy.
*     Fehler! Es existiert bereits ein Eintrag zum Lieferant & & und Bemessung &.
      io_msglist->add_symsg( if_cumulate = abap_true ).
      CONTINUE.
    ENDIF.


    APPEND INITIAL LINE TO mt_list ASSIGNING <ls_list>.

*   Set Tabellenschlüssel
    <ls_list>-dienstleistung = id_dienstleistung.
    <ls_list>-objnr          = ist_objektliste-objnr.
    <ls_list>-meas           = ls_cust_snunr-meas.
    <ls_list>-meas_guid      = cl_reca_guid=>get_new_guid( ).


    " create Massegesammler
    get_msglist(
      EXPORTING
        is_key     = <ls_list>-key
      CHANGING
        co_msglist = lo_msglist
           ).

    lo_msglist->clear( ).



*   Set Tabelleneinträge
    MOVE-CORRESPONDING ist_objektliste TO <ls_list>.
    <ls_list>-ext_dienstlif  = id_lief.
    <ls_list>-ext_aendgrund  = id_andgr.
    <ls_list>-projektname    = id_proj.
    <ls_list>-auftr_verm     = id_auftr.
    IF id_seldate IS SUPPLIED.
      <ls_list>-stichtag       = id_seldate.
    ELSE.
      <ls_list>-stichtag       = sy-datum.
    ENDIF.

*   Get Immobilienobjekt
    cf_rebd_rental_object=>find(
    EXPORTING
      id_bukrs       = <ls_list>-bukrs
      id_swenr       = <ls_list>-swenr
      id_smenr       = <ls_list>-smenr
      RECEIVING
      ro_instance    = ro_rental_object
    EXCEPTIONS
      error          = 1
      OTHERS         = 2
      ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      INTO dummy.

      <ls_list>-me_update = 'FEHLER: ME Existiert nicht' ##NO_TEXT.
      lo_msglist->add_symsg( if_cumulate = abap_true ).
      ld_fehler = abap_true.
    ENDIF.

*   Get Objektident
    ro_rental_object->get_ident(
    IMPORTING
      ed_ident           = <ls_list>-ident
      ).



*    " Get ME Gültig bis
    get_valid_to(
    EXPORTING
      is_detail  = <ls_list>
      RECEIVING
      rd_validto = <ls_list>-validto
    EXCEPTIONS
      error      = 1
      OTHERS     = 2
      ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      INTO dummy.
      io_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.


*   Check Status
    zcl_pdmis_setdaten_services=>check_status(
      EXPORTING
        id_objnr           = <ls_list>-objnr
        id_bisdatum        = <ls_list>-stichtag
      CHANGING
        cd_imbestand       = cd_imbestand
           ).

    IF cd_imbestand = abap_false.
      MESSAGE e016 WITH <ls_list>-stichtag <ls_list>-ident INTO dummy.
*   Per & ist ME & verkauft oder nicht mehr gültig.

      <ls_list>-me_update = 'FEHLER: ME verkauft oder nicht mehr gültig' ##NO_TEXT.

      lo_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.

    IF <ls_list>-validto = '00000000'.
      <ls_list>-validto = '99991231'.
    ENDIF.

*   Objekt gültig bis Datum ?
    IF cl_reca_date=>is_dateto_initial( id_dateto = <ls_list>-validto ) = abap_false.
      MESSAGE w025 WITH <ls_list>-ident <ls_list>-validto INTO dummy.
*   Objekt & ist bis & gültig.
      lo_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.


*   Set Bemessungsbezeichnung
    READ TABLE et_cust_meas_x INTO ls_cust_meas_x WITH KEY meas = <ls_list>-meas.
    <ls_list>-xsmeas = ls_cust_meas_x-xmmeas.

*   Get Fläche zur Bemessung
    zcl_bdro_services=>get_meas_flaeche(
      EXPORTING
        id_objnr      = <ls_list>-objnr
        id_seldate    = <ls_list>-stichtag
        id_meas       = <ls_list>-meas
      IMPORTING
        ed_measunit   = <ls_list>-measunit
        ed_measvalue  = <ls_list>-measvalue
      EXCEPTIONS
        bemesung_leer = 1
        flaeche_leer  = 2
        OTHERS        = 3
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      INTO dummy.
      CONCATENATE 'FEHLER: Bemessung' <ls_list>-meas 'ist leer' INTO ##NO_TEXT
      <ls_list>-me_update SEPARATED BY ' '.
      lo_msglist->add_symsg( if_cumulate = abap_true ).
      ld_fehler = abap_true.
    ENDIF.


    " E.Firsanov wenn die ext. Fläche während der Kündigungsworkflow aktualisiert
    " werden soll wird bei vorhandene aktivierte! Kündigung  das Kündigungzum Datum als
    " Stichtag aufgenommen. " EF 16625
    get_belegung_zu_kw(                                     " EF 16625
    EXPORTING                                               " EF 16625
      id_objnr    = <ls_list>-objnr                           " EF  16625
      id_vondat   = <ls_list>-stichtag                      " EF 16625
      id_bisdat   = <ls_list>-stichtag                      " EF 16625
      RECEIVING                                             " EF 16625
    rs_belegung = DATA(rs_belegung)                         " EF 16625
    EXCEPTIONS                                              " EF 16625
      error       = 1                                       " EF 16625
      OTHERS      = 2                                       " EF 16625
      ).                                                    " EF 16625
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO dummy.
      io_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.

    IF rs_belegung-isvacant = abap_true AND                 " EF 16625
    rs_belegung-occfrom >= <ls_list>-stichtag.              " EF 16625
      <ls_list>-stichtag = rs_belegung-occfrom.             " EF 16625
    ENDIF.                                                  " EF 16625


*   Belegung und Leerstandsgrund
    CREATE OBJECT lo_belegung.
    IF lo_belegung IS BOUND.
*     EMOD-Leerstatus ermieteln.
      lo_belegung->get_belegung(
      EXPORTING
        id_objnr             = <ls_list>-objnr
        id_vondat            = <ls_list>-stichtag
        id_bisdat            = <ls_list>-stichtag
      IMPORTING
        es_belegung          = es_belegung_leerstand
        ).
    ENDIF.
    CLEAR: lo_belegung,
    <ls_list>-recnendabs.                                   " EF 15698

    <ls_list>-dmibeg_aktuell = es_belegung_leerstand-dmibeg_aktuell.
    <ls_list>-smive_aktuell  = es_belegung_leerstand-smive_aktuell.
    <ls_list>-me_status      = es_belegung_leerstand-me_status.



*  Vertragsendedatum aktualisieren
    IF <ls_list>-smive_aktuell IS NOT INITIAL.              " EF 14246
      cl_redb_vicncn=>get_detail(
      EXPORTING
        id_bukrs            = <ls_list>-bukrs
        id_recnnr           = <ls_list>-smive_aktuell
        RECEIVING
        rs_detail           = DATA(rs_vicncn)
      EXCEPTIONS
        not_found           = 1
        OTHERS              = 2
        ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        INTO dummy.
        io_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.

*   Check ob zum Vertragsende die Kündigung vorhanden
      IF rs_vicncn-recndaktku <> '00000000'.                " EF 14898
        "   Set Vertragsendedatum
        <ls_list>-recnendabs  = rs_vicncn-recnendabs.
      ENDIF.                                                " EF 14898
    ENDIF.                                                  " EF 14246


*   Ist MO Belegt?
    IF <ls_list>-me_status = 'fremdgenutzt' ##NO_TEXT.
      <ls_list>-measvalidto = '99991231'.
    ENDIF.

*   Set Kündigung zum
    IF <ls_list>-me_status = 'Leerstehend' ##NO_TEXT.
      IF cl_reca_date=>is_dateto_initial( id_dateto = ist_objektliste-dkuezu ) = abap_false.
        " prüfen ob zum Stichtag der Datenselektion die Wohnung noch belegt ist
        IF <ls_list>-stichtag <= ist_objektliste-dkuezu.
          <ls_list>-me_status = 'fremdgenutzt' ##NO_TEXT.
        ENDIF.
        <ls_list>-recnendabs  = ist_objektliste-dkuezu.
      ELSE.
        <ls_list>-recnendabs  = ist_objektliste-leerab - 1.
      ENDIF.
    ENDIF.


    " Get Mieterdaten
    IF <ls_list>-me_status = 'fremdgenutzt' ##NO_TEXT.
      _get_debitorendaten(
        EXPORTING
          is_list     = <ls_list>
          io_msglist  = lo_msglist
          id_stichtag = <ls_list>-stichtag
        CHANGING
          cs_list_dbt = <ls_list>-debitor
             ).
    ENDIF.


    " Get Detail_X zu ME
    DATA(rs_detail_x) = ro_rental_object->get_detail_x( ).


*   Text Geschoss
    <ls_list>-xstockm = rs_detail_x-xstockl.

*   Text Lage im Geschoss
    <ls_list>-xklgesch = rs_detail_x-xklgesch.



* Get Addresse von Objekt
    <ls_list>-adress-adrzus     = ist_objektliste-xmbez.
    <ls_list>-adress-city1      = ist_objektliste-ort01.
    <ls_list>-adress-city2      = ist_objektliste-ort02.
    <ls_list>-adress-post_code1 = ist_objektliste-pstlz.
    <ls_list>-adress-street     = ist_objektliste-stras.
    <ls_list>-adress-house_num1 = ist_objektliste-hausnr.


    " Get Daten von Wohnungsverwalter
    _get_wohnverwalterdaten(
       EXPORTING
         is_list     = <ls_list>
         io_msglist  = lo_msglist
         id_stichtag = <ls_list>-stichtag
       CHANGING
         cs_list_wv  = <ls_list>-wv
            ).

    CLEAR is_rokey.
    MOVE-CORRESPONDING ro_rental_object->ms_detail-key TO is_rokey.

*   Get Finanzierungsart
    zcl_cpro_service=>get_finanzart(
    EXPORTING
      is_rokey       = is_rokey
    IMPORTING
      e_nutz_fin_art = e_nutz_fin_art
      e_finart       = e_finart
      e_xfinart      = <ls_list>-xfixfitcharact
      ).

    <ls_list>-finart = e_nutz_fin_art.




* Get Begehung from
    zcl_cpro_service=>get_plbegehung(
    EXPORTING
      is_rokey     = is_rokey
    IMPORTING
      e_plbeg_from = <ls_list>-plbeg_from
      ).





*   Set Icon für die Belegungsstatus
    set_belegung_icon(
      EXPORTING
        id_stichtag       = <ls_list>-stichtag
        id_recnendabs     = <ls_list>-recnendabs
      CHANGING
        cd_belegung_icon = <ls_list>-belegung_icon
           ).



    " Set Status Icon
    _set_status_icon(
      EXPORTING
        io_msglist     = lo_msglist
        is_detail      = <ls_list>
      CHANGING
        cd_status_icon = <ls_list>-icon_detail
           ).



* Meldungen übertragen
    io_msglist->add_from_instance(
        io_msglist        = lo_msglist
        if_add_as_subnode = abap_false
        if_cumulate       = abap_true
           ).


    store_messages(
      EXPORTING
        if_in_update_task = abap_false
        io_msglist        = lo_msglist
      EXCEPTIONS
        error             = 1
        OTHERS            = 2
           ).
    IF sy-subrc <> 0.
*   Implement suitable error handling here
    ENDIF.


  ENDLOOP.



ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~objektliste_delete.

  DATA: rd_ident 	TYPE recaident.

  FIELD-SYMBOLS: <ls_list> LIKE LINE OF mt_list.

  READ TABLE mt_list ASSIGNING <ls_list> WITH TABLE KEY key = is_key.
  IF sy-subrc = 0.
    DELETE  mt_list WHERE key = is_key.
  ELSE.
    get_ident(
       EXPORTING
         is_detail = <ls_list>
       RECEIVING
         rd_ident  = rd_ident
       EXCEPTIONS
         error     = 1
         OTHERS    = 2
            ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
    ENDIF.

    MESSAGE e001(zhwk_aufmass) WITH rd_ident RAISING error.
*   Leistungsposition & existiert nicht.
  ENDIF.

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~objektliste_excel_upl.

  DATA: lo_msglist TYPE REF TO if_reca_message_list,
        ld_fehler  TYPE flag,
        dummy      TYPE string,
        ld_text    TYPE string.


  DATA: ls_excel                  LIKE LINE OF it_excel_tab.
  DATA: lt_cust TYPE STANDARD TABLE OF zcus_aktivit,
        ls_cust LIKE LINE OF lt_cust.

  DATA: ld_ident                TYPE string.
  DATA: ld_prozentsatz  TYPE rebdmeasvalue.                 " ED 15443

  FIELD-SYMBOLS: <ls_list> LIKE LINE OF mt_list.



* Get Customizing
  SELECT * FROM zcus_aktivit INTO TABLE lt_cust.



  LOOP AT it_excel_tab INTO ls_excel.


    READ TABLE mt_list ASSIGNING <ls_list> WITH KEY meas_guid = ls_excel-meas_guid.
    IF sy-subrc = 0.
      " create Massegesammler
      get_msglist(
        EXPORTING
          is_key     = <ls_list>-key
        CHANGING
          co_msglist = lo_msglist
             ).

      lo_msglist->clear( ).

      CLEAR: <ls_list>-measvalidto,
             <ls_list>-measvalidfrom,
             <ls_list>-ext_fertdat.

      <ls_list>-aktivitaet          = ls_excel-aktivitaet.
      <ls_list>-ext_aendgrund       = ls_excel-ext_aendgrund.
      <ls_list>-ext_fertdat         = ls_excel-ext_fertdat.
      <ls_list>-measvalue_neu       = ls_excel-measvalue_neu.
      <ls_list>-measunit_neu        = ls_excel-measunit_neu.
      <ls_list>-bemerkung_lieferant = ls_excel-bemerkung_lieferant.

      <ls_list>-abweichung_m2   = ( <ls_list>-measvalue_neu - <ls_list>-measvalue ).

      " EF Division durch 0 " EF 14726
      IF <ls_list>-measvalue_neu <> 0 AND                   " EF 14726
         <ls_list>-measvalue <> 0.                            " EF CH2208-0020
        ld_prozentsatz = ( <ls_list>-measvalue_neu * 100 / <ls_list>-measvalue - 100 ). " ED 15443
        IF ld_prozentsatz > 1000.                           " ED 15443
          <ls_list>-abweichung_proz = '999.99'.             " ED 15443
        ELSE.                                               " ED 15443
          <ls_list>-abweichung_proz = ld_prozentsatz.       " ED 15443
        ENDIF.                                              " ED 15443
*        <LS_LIST>-ABWEICHUNG_PROZ = ( <LS_LIST>-MEASVALUE_NEU * 100 / <LS_LIST>-MEASVALUE - 100 )." ED 15443
      ENDIF.

      CONCATENATE <ls_list>-ident 'Bemes:' <ls_list>-meas INTO ld_text SEPARATED BY ' ' ##NO_TEXT.
      MESSAGE s009 WITH ld_text <ls_list>-measvalue_neu sy-datum INTO dummy.
*     Excel-Eintrag & & wurde am & importiert.
      lo_msglist->add_symsg( if_cumulate = abap_true ).



*   Set Valid-Daten
      IF cl_reca_date=>is_date_initial( id_date = <ls_list>-ext_fertdat ) = abap_false AND
      <ls_list>-aktivitaet = 'sofort'.
        READ TABLE lt_cust INTO ls_cust WITH KEY aktivitaet = <ls_list>-aktivitaet.
        IF ls_cust-update_fl = abap_true.
          IF <ls_list>-measvalue_neu IS NOT INITIAL.
            <ls_list>-measvalidto   = <ls_list>-ext_fertdat - 1.
            <ls_list>-measvalidfrom = <ls_list>-ext_fertdat.
          ELSE.
            IF ls_cust-update_value_null  = abap_true.
              <ls_list>-measvalidto   = <ls_list>-ext_fertdat - 1.
              <ls_list>-measvalidfrom = <ls_list>-ext_fertdat.
            ELSE.
              MESSAGE e027 WITH 'sofort' '0' INTO dummy.
*           Datentransfer beim Aktivität & und Value & sind nicht zugelassen.
              lo_msglist->add_symsg( if_cumulate = abap_true ).
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR <ls_list>-ext_fertdat.
      ENDIF.

*     prüfen Aktivität Ja
      IF  <ls_list>-aktivitaet = 'ja'.
        READ TABLE lt_cust INTO ls_cust WITH KEY aktivitaet = <ls_list>-aktivitaet.
        IF ls_cust-update_fl = abap_true.
          IF <ls_list>-measvalue_neu IS NOT INITIAL.
            IF cl_reca_date=>is_date_initial( id_date = <ls_list>-recnendabs ) = abap_false.
              <ls_list>-measvalidto   = <ls_list>-recnendabs.
              <ls_list>-measvalidfrom = <ls_list>-recnendabs + 1.
            ENDIF.
          ELSE.
            IF ls_cust-update_value_null  = abap_true.
              IF cl_reca_date=>is_date_initial( id_date = <ls_list>-recnendabs ) = abap_false.
                <ls_list>-measvalidto   = <ls_list>-recnendabs.
                <ls_list>-measvalidfrom = <ls_list>-recnendabs + 1.
              ENDIF.
            ELSE.
              MESSAGE e027 WITH 'ja' '0' INTO dummy.
*             Datentransfer beim Aktivität & und Value & sind nicht zugelassen.
              lo_msglist->add_symsg( if_cumulate = abap_true ).
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.


      "  Jetzt die Aktivitätsdaten aktualisieren
      me->_objekt_refresh(
      EXPORTING
        is_list    = <ls_list>
        io_msglist = lo_msglist
      CHANGING
        cs_list    = <ls_list>-tab
        ).


      " Set Status Icon
      _set_status_icon(
        EXPORTING
          io_msglist     = lo_msglist
          is_detail      = <ls_list>
        CHANGING
          cd_status_icon = <ls_list>-icon_detail
             ).



      store_messages(
        EXPORTING
          if_in_update_task = abap_false
          io_msglist        = lo_msglist
        EXCEPTIONS
          error             = 1
          OTHERS            = 2
             ).
      IF sy-subrc <> 0.
*     Implement suitable error handling here
      ENDIF.






    ELSE.
      CLEAR ld_ident.
      CONCATENATE 'ME' ls_excel-bukrs ls_excel-swenr ls_excel-sgenr ls_excel-smenr INTO ld_ident SEPARATED BY '/'.
      MESSAGE e001(zhwk_aufmass) WITH 'Excel-Upload' ld_ident INTO dummy ##NO_TEXT.
*     Leistungsposition &/& existiert nicht.
      io_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.


  ENDLOOP.



ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~objektliste_refresh.

  DATA: lo_msglist TYPE REF TO if_reca_message_list,
        ld_fehler  TYPE flag,
        dummy      TYPE string.

  FIELD-SYMBOLS: <ls_list> LIKE LINE OF mt_list.

  READ TABLE mt_list ASSIGNING <ls_list> WITH TABLE KEY key = is_list-key.
  IF sy-subrc = 0.

    " E.Firsanov nur nicht Upgedatete Immobilienobjekte aktualisieren
    CHECK <ls_list>-me_update_flag = abap_false. "  EF 14246

    " create Massegesammler
    get_msglist(
      EXPORTING
        is_key     = <ls_list>-key
      CHANGING
        co_msglist = lo_msglist
           ).

*    LO_MSGLIST->CLEAR( ).

    DATA et_list_x    TYPE re_t_msg_x.

    lo_msglist->get_list_x(
       EXPORTING
         id_msgty     = 'E'
         if_or_higher = abap_true
       IMPORTING
         et_list_x    = et_list_x
            ).

    LOOP AT et_list_x INTO DATA(ls_list_x).

      lo_msglist->delete_message(
       EXPORTING
         id_msgnumber = ls_list_x-msgnumber
       EXCEPTIONS
         not_found    = 1
         OTHERS       = 2
                 ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING error.
      ENDIF.

    ENDLOOP.

*   Daten aktualisieren
    me->_objekt_refresh(
      EXPORTING
        is_list    = <ls_list>
        io_msglist = lo_msglist
      CHANGING
        cs_list    = <ls_list>-tab
           ).




    " Set Status Icon
    _set_status_icon(
      EXPORTING
        io_msglist     = lo_msglist
        is_detail      = <ls_list>
      CHANGING
        cd_status_icon = <ls_list>-icon_detail
           ).

    store_messages(
      EXPORTING
        if_in_update_task = abap_false
        io_msglist        = lo_msglist
      EXCEPTIONS
        error             = 1
        OTHERS            = 2
           ).
    IF sy-subrc <> 0.
*           Implement suitable error handling here
    ENDIF.



****************************************************************
    " E.Firsanov weiter nur wenn kein Fehler vorhanden
****************************************************************
    CHECK: <ls_list>-icon_detail <> icon_complete AND
           <ls_list>-icon_detail <> icon_breakpoint. "

* Jetzt die Aktivitätsdaten überprüfen
    objektliste_change(
      EXPORTING
        is_list = <ls_list>
      EXCEPTIONS
        error   = 1
        OTHERS  = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    RAISING error.
    ENDIF.


  ELSE.
    MESSAGE e001(zhwk_aufmass) WITH is_list-ident is_list-meas_guid RAISING error.
*   Leistungsposition &/& existiert nicht.
  ENDIF.

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~set_status_icon.

  _set_status_icon(
    EXPORTING
      io_msglist     = io_msglist
      is_detail      = is_detail
    CHANGING
      cd_status_icon = cd_status_icon
         ).

ENDMETHOD.


METHOD zif_pd_ztexd_flache_mngr~store_messages.
  _store_messages(
    EXPORTING
      if_in_update_task = if_in_update_task
      io_msglist        = io_msglist
    EXCEPTIONS
      error             = 1
      OTHERS            = 2
         ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            RAISING error.
  ENDIF.
ENDMETHOD.


METHOD _get_debitorendaten.

  DATA: it_rolle TYPE bup_t_role,
        ls_rolle LIKE LINE OF it_rolle,
        dummy    TYPE string.
  DATA: et_mv_partner TYPE z_t_zvcnbpadress,
        ls_mv_partner LIKE LINE OF et_mv_partner.


  CLEAR cs_list_dbt.



  ls_rolle = 'TR0600'.
  APPEND ls_rolle TO it_rolle.


  zcl_extdienst_services=>get_mv_partner(
    EXPORTING
      id_bukrs      = is_list-bukrs
      id_recnnr     = is_list-smive_aktuell
      it_rolle      = it_rolle
      is_stichtag   = id_stichtag
    IMPORTING
      et_mv_partner = et_mv_partner
    EXCEPTIONS
      error         = 1
      OTHERS        = 2
         ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  INTO dummy.
    io_msglist->add_symsg( if_cumulate = abap_true ).
    RETURN.
  ENDIF.


  READ TABLE et_mv_partner INTO ls_mv_partner INDEX 1.  "#EC CI_NOORDER
  MOVE-CORRESPONDING ls_mv_partner TO cs_list_dbt.

ENDMETHOD.


METHOD _get_msglist.
  DATA:
    ld_msgnumber TYPE recaguid.

  IF ( dc_msgnumber IS INITIAL ).
    ld_msgnumber = cl_reca_guid=>get_new_guid( ).
*    CALL FUNCTION 'GUID_CREATE'
*      IMPORTING
*        EV_GUID_16 = LD_MSGNUMBER.
    dc_msgnumber = ld_msgnumber.

    CALL METHOD cf_reca_message_list=>create
      EXPORTING
        id_object    = 'ZEXT_DIENST'
        id_subobject = 'MEAS'
        id_extnumber = dc_msgnumber
      RECEIVING
        ro_instance  = co_msglist.
  ELSE.
    CALL METHOD cf_reca_message_list=>find
      EXPORTING
        id_object    = 'ZEXT_DIENST'
        id_subobject = 'MEAS'
        id_extnumber = dc_msgnumber
      RECEIVING
        ro_instance  = co_msglist
      EXCEPTIONS
        error        = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      CLEAR dc_msgnumber.

      _get_msglist(
        CHANGING
          co_msglist   = co_msglist
          dc_msgnumber = dc_msgnumber
             ).

    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD _get_wohnverwalterdaten.

*   GET Empfänger
  DATA: it_role     TYPE bup_t_role.
  DATA: rt_partner TYPE z_t_zemod_partrel,
        ls_partner LIKE LINE OF rt_partner.

  CLEAR cs_list_wv.

  APPEND 'YYZ002' TO it_role.

  zcl_extdienst_services=>get_we_partner(
    EXPORTING
      i_bukrs    = is_list-bukrs
      i_swenr    = is_list-swenr
      io_msglist = io_msglist
      it_role    = it_role
    RECEIVING
      rt_partner = rt_partner
    EXCEPTIONS
      error      = 1
      OTHERS     = 2
         ).
  IF sy-subrc <> 0.
    io_msglist->add_symsg( if_cumulate = abap_true ).
  ENDIF.

  READ TABLE rt_partner INTO ls_partner INDEX 1.

  MOVE-CORRESPONDING ls_partner TO cs_list_wv.

ENDMETHOD.


METHOD _objekt_refresh.

  DATA: cd_imbestand TYPE char1,
        rd_ident     TYPE recaident,
        dummy        TYPE string.

* Prüfe ob Gebäude auswertet soll (Gebäudear 96 "fiktives Gebäude")
  DATA: ro_building TYPE REF TO if_rebd_building,
        ld_intreno  TYPE recaintreno.
  DATA  is_vibdro_x    TYPE rebd_rental_object_x.
  DATA: is_rokey       TYPE vibdro_key,
        e_nutz_fin_art TYPE char100,
        e_finart       TYPE rebdfixfitcharact.
  DATA rs_vicncn           TYPE vicncn.

  DATA ld_email_flag TYPE abap_bool.


  IF is_list-sgenr IS NOT INITIAL.
    cf_rebd_building=>find(
      EXPORTING
        id_bukrs       = is_list-bukrs
        id_swenr       = is_list-swenr
        id_sgenr       = is_list-sgenr
        if_enqueue     = abap_false
      RECEIVING
        ro_instance    = ro_building
      EXCEPTIONS
        error          = 1
        OTHERS         = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO dummy.
      io_msglist->add_symsg( if_cumulate = abap_true ).
      RETURN.
    ENDIF.

    IF ro_building IS BOUND.
      ld_intreno = ro_building->md_intreno.
    ENDIF.

  ENDIF.


* Get Detail-X Mietobjekt
  me_detail_x(
    EXPORTING
      is_detail   = is_list
    RECEIVING
      is_vibdro_x = is_vibdro_x
    EXCEPTIONS
      error       = 1
      OTHERS      = 2
         ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  INTO dummy.
    io_msglist->add_symsg( if_cumulate = abap_true ).
    RETURN.
  ENDIF.


* Get Ident-ME
  get_ident(
    EXPORTING
      is_detail = is_list
    RECEIVING
      rd_ident  = rd_ident
    EXCEPTIONS
      error     = 1
      OTHERS    = 2
         ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  INTO dummy.
    io_msglist->add_symsg( if_cumulate = abap_true ).
    RETURN.
  ENDIF.


  " Set Flag dass Refresch ausgeführt wurde
  cs_list-refresh_obj = abap_false.



* Set Aktualisierung per
  cs_list-stichtag = sy-datum.




  " Get ME Gültig bis
  get_valid_to(
    EXPORTING
      is_detail  = is_list
    RECEIVING
      rd_validto = cs_list-validto
    EXCEPTIONS
      error      = 1
      OTHERS     = 2
         ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                INTO dummy.
    io_msglist->add_symsg( if_cumulate = abap_true ).
  ENDIF.




* Check Status
  zcl_pdmis_setdaten_services=>check_status(
    EXPORTING
      id_objnr           = is_list-objnr
      id_bisdatum        = cs_list-stichtag
    CHANGING
      cd_imbestand       = cd_imbestand
         ).

  IF cd_imbestand = abap_false.
    MESSAGE e016 WITH cs_list-stichtag rd_ident INTO dummy.
*   Per & ist ME & verkauft oder nicht mehr gültig.
    io_msglist->add_symsg( if_cumulate = abap_true ).
    RETURN.
  ENDIF.





* Objekt gültig bis Datum ?
  IF cl_reca_date=>is_dateto_initial( id_dateto = cs_list-validto ) = abap_false.
    MESSAGE w025 WITH cs_list-ident cs_list-validto INTO dummy.
*   Objekt & ist bis & gültig.
    io_msglist->add_symsg( if_cumulate = abap_true ).
  ENDIF.




* Get Addresse von Objekt
  DATA rs_address TYPE zst_mis_adresse.
  READ TABLE zcl_mis_crgen_services=>mt_adresse INTO rs_address WITH TABLE KEY intreno = ld_intreno.
  IF sy-subrc <> 0.
    zcl_cpca_get_partner_addresse=>get_address_vibdbu(
      EXPORTING
        id_intreno = ld_intreno
      RECEIVING
        rs_address = rs_address-adress
      EXCEPTIONS
        error      = 1
        OTHERS     = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                INTO dummy.
      io_msglist->add_symsg( if_cumulate = abap_true ).
    ELSE.
      rs_address-intreno = ld_intreno.
      INSERT rs_address INTO TABLE zcl_mis_crgen_services=>mt_adresse.
    ENDIF.
  ENDIF.


  cs_list-adress = rs_address-adress.

  MESSAGE s017 WITH rd_ident cs_list-stichtag INTO dummy.
*   ME & Adressdaten sind zum & aktualisiert.
  io_msglist->add_symsg( if_cumulate = abap_true ).







*   Text Geschoss
  cs_list-xstockm = is_vibdro_x-xstockl.

*   Text Lage im Geschoss
  cs_list-xklgesch = is_vibdro_x-xklgesch.

  MESSAGE s018 WITH rd_ident cs_list-stichtag INTO dummy.
*   ME & Geschoss und Lage im Geschoss sind zum & aktualisiert.
  io_msglist->add_symsg( if_cumulate = abap_true ).






* Get Bemessung
  CLEAR cs_list-me_update.
*   Get Fläche zur Bemessung
  zcl_bdro_services=>get_meas_flaeche(
    EXPORTING
      id_objnr      = is_list-objnr
      id_seldate    = cs_list-stichtag
      id_meas       = is_list-meas
    IMPORTING
      ed_measunit   = cs_list-measunit
      ed_measvalue  = cs_list-measvalue
    EXCEPTIONS
      bemesung_leer = 1
      flaeche_leer  = 2
      OTHERS        = 3
         ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    INTO dummy.
    CONCATENATE 'FEHLER: Bemessung' is_list-meas 'ist leer' INTO ##NO_TEXT
    cs_list-me_update SEPARATED BY ' '.
    io_msglist->add_symsg( if_cumulate = abap_true ).
    RETURN.
  ENDIF.

  MESSAGE s019 WITH rd_ident is_list-meas cs_list-stichtag INTO dummy.
*   ME & Bemessng & ist zum & aktualisiert.
  io_msglist->add_symsg( if_cumulate = abap_true ).


  " E.Firsanov wenn die ext. Fläche während der Kündigungsworkflow aktualisiert
  " werden soll wird bei vorhandene aktivierte! Kündigung  das Kündigungzum Datum als
  " Stichtag aufgenommen. " EF 16625
  get_belegung_zu_kw(                                       " EF 16625
    EXPORTING                                               " EF 16625
      id_objnr    = is_list-objnr                           " EF  16625
      id_vondat   = cs_list-stichtag                        " EF 16625
      id_bisdat   = cs_list-stichtag                        " EF 16625
    RECEIVING                                               " EF 16625
      rs_belegung = DATA(rs_belegung)                       " EF 16625
    EXCEPTIONS                                              " EF 16625
      error       = 1                                       " EF 16625
      OTHERS      = 2                                       " EF 16625
         ).                                                 " EF 16625
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO dummy.
    io_msglist->add_symsg( if_cumulate = abap_true ).
  ENDIF.

  IF rs_belegung-isvacant = abap_true AND                   " EF 16625
  rs_belegung-occfrom >= cs_list-stichtag.                  " EF 16625
    cs_list-stichtag = rs_belegung-occfrom.                 " EF 16625
  ENDIF.                                                    " EF 16625

* Get Get Belegung
  DATA: lo_belegung   TYPE REF TO zcl_beleg_mod_decorator.
  DATA: es_belegung_leerstand TYPE zsbelegung_leerstand.
*   Belegung und Leerstandsgrund
  CREATE OBJECT lo_belegung.
  IF lo_belegung IS BOUND.
*     EMOD-Leerstatus ermieteln.
    lo_belegung->get_belegung(
    EXPORTING
      id_objnr             = is_list-objnr
      id_vondat            = cs_list-stichtag
      id_bisdat            = cs_list-stichtag
    IMPORTING
      es_belegung          = es_belegung_leerstand
      ).
  ENDIF.
  CLEAR: lo_belegung,
         cs_list-recnendabs.                                " EF 15698

  cs_list-dmibeg_aktuell = es_belegung_leerstand-dmibeg_aktuell.
  cs_list-smive_aktuell  = es_belegung_leerstand-smive_aktuell.
  cs_list-me_status      = es_belegung_leerstand-me_status.

*  Vertragsendedatum aktualisieren
  IF cs_list-smive_aktuell IS NOT INITIAL.                  " EF 14246
    cl_redb_vicncn=>get_detail(
      EXPORTING
        id_bukrs            = cs_list-bukrs
        id_recnnr           = cs_list-smive_aktuell
      RECEIVING
        rs_detail           = rs_vicncn
      EXCEPTIONS
        not_found           = 1
        OTHERS              = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                    INTO dummy.
      io_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.

*   Check ob zum Vertragsende die Kündigung vorhanden
    IF rs_vicncn-recndaktku <> '00000000'.                  " EF 14898
      "   Set Vertragsendedatum
      cs_list-recnendabs  = rs_vicncn-recnendabs.
    ENDIF.                                                  " EF 14898
  ENDIF.                                                    " EF 14246

  IF cs_list-me_status = 'fremdgenutzt'.

    IF cl_reca_date=>is_dateto_initial( id_dateto = cs_list-recnendabs ) = abap_false.
      IF ( cs_list-stichtag >= cs_list-recnendabs AND
      cl_reca_date=>is_dateto_initial( id_dateto = cs_list-recnendabs ) = abap_false ).
*       Kündigung
        cs_list-me_status = 'Leerstehend' ##NO_TEXT.
      ELSE.
        cs_list-me_status = 'fremdgenutzt' ##NO_TEXT.
      ENDIF.
    ENDIF.
  ENDIF.



*   Set Kündigung zum
  IF cs_list-me_status = 'Leerstehend' AND cl_reca_date=>is_dateto_initial( id_dateto = cs_list-recnendabs ) = abap_true.
    IF cl_reca_date=>is_dateto_initial( id_dateto = es_belegung_leerstand-dkuezu ) = abap_false.
      cs_list-recnendabs  = es_belegung_leerstand-dkuezu.
    ELSE.
      cs_list-recnendabs  = es_belegung_leerstand-leerab - 1.
    ENDIF.
  ENDIF.
  MESSAGE s020 WITH rd_ident  cs_list-stichtag INTO dummy.
*   ME & Belegung wurde zum & aktualisiert.
  io_msglist->add_symsg( if_cumulate = abap_true ).



  " prüfen ob zum Stichtag der Datenselektion die Wohnung noch belegt ist
  IF ( cs_list-stichtag >= cs_list-recnendabs AND
      cl_reca_date=>is_dateto_initial( id_dateto = cs_list-recnendabs ) = abap_false ).
*       Kündigung
    cs_list-me_status = 'Leerstehend' ##NO_TEXT.
  ELSE.
    cs_list-me_status = 'fremdgenutzt' ##NO_TEXT.
  ENDIF.




  " Get Mieterdaten
  IF cs_list-me_status = 'fremdgenutzt' ##NO_TEXT.
    _get_debitorendaten(
      EXPORTING
        is_list     = is_list
        io_msglist  = io_msglist
        id_stichtag = cs_list-stichtag
      CHANGING
        cs_list_dbt = cs_list-debitor
           ).

    IF cs_list-debitor IS NOT INITIAL.
      MESSAGE s021 WITH rd_ident  cs_list-stichtag INTO dummy.
*   ME & Debitorendaten wurde zum & aktualisiert.
      io_msglist->add_symsg( if_cumulate = abap_true ).
    ENDIF.
  ENDIF.





  " Get Daten von Wohnungsverwalter
  _get_wohnverwalterdaten(
     EXPORTING
       is_list     = is_list
       io_msglist  = io_msglist
       id_stichtag = cs_list-stichtag
     CHANGING
       cs_list_wv  = cs_list-wv
          ).
  IF cs_list-wv IS NOT INITIAL.
    MESSAGE s022 WITH rd_ident  cs_list-stichtag INTO dummy.
*   ME & Daten von Wohnungsverwaster wurde zum & aktualisiert.
    io_msglist->add_symsg( if_cumulate = abap_true ).
  ENDIF.




  CLEAR is_rokey.
  MOVE-CORRESPONDING is_vibdro_x-key TO is_rokey.


*   Get Finanzierungsart
  zcl_cpro_service=>get_finanzart(
  EXPORTING
    is_rokey       = is_rokey
  IMPORTING
    e_nutz_fin_art = e_nutz_fin_art
    e_finart       = e_finart
    e_xfinart      = cs_list-xfixfitcharact
    ).
  cs_list-finart = e_nutz_fin_art.


* Get Begehung from
  zcl_cpro_service=>get_plbegehung(
    EXPORTING
      is_rokey     = is_rokey
    IMPORTING
      e_plbeg_from = cs_list-plbeg_from
         ).


*   Get Baujahr
  IF ro_building IS BOUND.
    cs_list-ybaujahr    = ro_building->ms_detail-ybaujahr(4).
  ENDIF.

  MESSAGE s023 WITH rd_ident  cs_list-stichtag INTO dummy.
*   ME & Baujahr und Finanzierungsart wurden zum & aktualisiert.
  io_msglist->add_symsg( if_cumulate = abap_true ).


**     Kündigung wurde aktiviert
*  IF CS_LIST-AKTIVITAET = 'info' ##NO_TEXT AND
*  CS_LIST-INFO_VERWALTER IS INITIAL AND
*  CL_RECA_DATE=>IS_DATETO_INITIAL( ID_DATETO = CS_LIST-RECNENDABS ) = ABAP_FALSE.
*
*    IF ( CL_RECA_DATE=>IS_DATETO_INITIAL( ID_DATETO = CS_LIST-RECNENDABS ) = ABAP_FALSE ).
*      LD_INFOART = 'KV'. "  Kündigung Vertrag
*    ENDIF.
*
*    CLEAR CS_LIST-INFO_VERWALTER.
*
*
*    IF LD_EMAIL_FLAG IS INITIAL.
*
*      IF IS_DETAIL-RECNNOTREASON <> '74'. " SAP-Kdg. wg Verkauf, Abbruch     " EF 18924
*        SENDE_INFO_EMAIL(
*        EXPORTING
*          IS_LIST           = CS_LIST
*          IO_MSGLIST        = LO_MSGLIST
*          ID_RECNENDABS     = CS_LIST-RECNENDABS
*          ID_INFOART        = LD_INFOART
*          IF_IN_UPDATE_TASK = IF_IN_UPDATE_TASK
*        CHANGING
*          CD_INFO_VERWALTER = CS_LIST-INFO_VERWALTER
*        EXCEPTIONS
*          ERROR             = 1
*          OTHERS            = 2
*          ).
*      ENDIF.                                            " EF 18924
*
*      SET_INDO_WOHNVERWALTER(
*      EXPORTING
*        SUBRC             = SY-SUBRC
*        ID_INFOART        = LD_INFOART
*        ID_RECNENDABS     = CS_LIST-RECNENDABS
*        ID_KUENDGRUD      = IS_DETAIL-RECNNOTREASON" EF 18924
*      CHANGING
*        CD_INFO_VERWALTER = CS_LIST-INFO_VERWALTER
*        ).
*
*
*      LD_EMAIL_FLAG = ABAP_TRUE.
*
*    ELSE.
*
*      SET_INDO_WOHNVERWALTER(
*      EXPORTING
*        SUBRC             = SY-SUBRC
*        ID_INFOART        = LD_INFOART
*        ID_RECNENDABS     = CS_LIST-RECNENDABS
*        ID_KUENDGRUD      = IS_DETAIL-RECNNOTREASON" EF 18924
*      CHANGING
*        CD_INFO_VERWALTER = CS_LIST-INFO_VERWALTER
*        ).
*
*    ENDIF.
*
*
*  ENDIF.




*   Set Icon für die Belegungsstatus
  set_belegung_icon(
    EXPORTING
      id_stichtag       = cs_list-stichtag
      id_recnendabs     = cs_list-recnendabs
    CHANGING
      cd_belegung_icon = cs_list-belegung_icon
         ).


* Get Folgevertragsdaten Vertrag zum stichtag + suchen
  get_folgevertrag(
  EXPORTING
    id_stichtag      = cs_list-stichtag
    is_me_key        = is_rokey
    id_recnendabs    = cs_list-recnendabs
  CHANGING
    cd_folgevertrag  = cs_list-folgevertrag
    ).



ENDMETHOD.


METHOD _set_status_icon.

  DATA rs_statistics TYPE bal_s_scnt.

  rs_statistics = io_msglist->get_statistics( ).

  IF is_detail-me_update_flag = abap_true.
    cd_status_icon = icon_complete. " '@DF@'
    RETURN.
  ENDIF.

  IF is_detail-refresh_obj = abap_true.
    cd_status_icon = icon_workflow_wait_for_events. " Warten auf Ereignisse
    RETURN.
  ENDIF.


  " Error
  IF rs_statistics-msg_cnt_a <> 0 OR
     rs_statistics-msg_cnt_e <> 0.
    cd_status_icon = icon_breakpoint. "
    RETURN.
  ENDIF.

  " warnung
  IF rs_statistics-msg_cnt_w <> 0.
    cd_status_icon = icon_led_yellow. " Warnung
    RETURN.
  ENDIF.


* Set Icone
  cd_status_icon = icon_led_green. "

*  IF CL_RECA_DATE=>IS_DATETO_INITIAL( ID_DATETO = IS_DETAIL-VALIDTO ) = ABAP_FALSE.
*    CD_STATUS_ICON = ICON_LESS_RED. " Klein
*    RETURN.
*  ENDIF.
*
*
*
*
*  IF IS_DETAIL-AKTIVITAET = 'ja' AND IS_DETAIL-ME_STATUS = 'fremdgenutzt' AND IS_DETAIL-ME_UPDATE_FLAG = ABAP_FALSE.
*    CD_STATUS_ICON =  ICON_FINAL_DATE. " '@3O@'
*  ENDIF.


ENDMETHOD.


METHOD _store_messages.
* bye, bye if no message list or number are existing
  CHECK ( io_msglist IS BOUND                     ) AND
        ( io_msglist->md_extnumber IS NOT INITIAL ).

* store message list
  CALL METHOD io_msglist->store
    EXPORTING
      if_in_update_task = if_in_update_task
    EXCEPTIONS
      error             = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    mac_symsg_raise error.
  ENDIF.

* free message list
  IF if_in_update_task = abap_false.
    io_msglist->free( ).
    FREE io_msglist.
    CLEAR io_msglist.
  ENDIF.
ENDMETHOD.
ENDCLASS.
