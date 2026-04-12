CLASS zch_ext_controller_mngr DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

*"* public components of class ZCH_EXT_CONTROLLER_MNGR
*"* do not include other source files here!!!
  PUBLIC SECTION.
    TYPE-POOLS reca0 .
    TYPE-POOLS reca1 .
    TYPE-POOLS reor0 .

    INTERFACES if_reca_static_event_handler .

    ALIASES set_handler
      FOR if_reca_static_event_handler~set_handler .
PROTECTED SECTION.
*"* protected components of class ZCH_EXT_CONTROLLER_MNGR
*"* do not include other source files here!!!
PRIVATE SECTION.

  CLASS-METHODS notice_mngr_after_activate
    FOR EVENT period_after_activate OF cl_recn_notice_mngr
    IMPORTING
      !is_detail_before
      !is_detail_after
      !sender .
  CLASS-METHODS _ext_dienstleist_bemessung_1
    IMPORTING
      !is_detail_before TYPE recn_notice
      !is_detail        TYPE recn_notice
      !io_notice_mngr   TYPE REF TO if_recn_notice_mngr .
  TYPE-POOLS abap .
  CLASS-METHODS _ext_dienstleist_bemessung_2
    IMPORTING
      !id_recnendabs     TYPE recncnendabs
      !id_recnendabs_old TYPE recncnendabs
      !is_detail         TYPE recn_contract
      !if_in_update_task TYPE abap_bool DEFAULT abap_true .
  CLASS-METHODS _ext_dienstleist_bemessung_3
    IMPORTING
      !is_detail_old TYPE rebd_rental_object
      !is_detail     TYPE rebd_rental_object .
  CLASS-METHODS contract_after_store
    FOR EVENT after_store OF cl_recn_contract
    IMPORTING
      !if_in_update_task
      !sender .
  CLASS-METHODS notice_mngr_after_deactivate
    FOR EVENT period_after_deactivate OF cl_recn_notice_mngr
    IMPORTING
      !is_detail_before
      !is_detail_after
      !sender .
  CLASS-METHODS find_notice_for_contract
    IMPORTING
      !i_contract      TYPE REF TO if_recn_contract
    RETURNING
      VALUE(rs_notice) TYPE recn_notice .
  CLASS-METHODS me_after_store
    FOR EVENT after_store OF cl_rebd_rental_object
    IMPORTING
      !if_in_update_task
      !sender .
ENDCLASS.



CLASS ZCH_EXT_CONTROLLER_MNGR IMPLEMENTATION.


METHOD contract_after_store.

  DATA:
*   manager
    lo_contract   TYPE REF TO if_recn_contract,
    lo_bus_object TYPE REF TO if_reca_bus_object.
  DATA:
*   relevant fields for occupancy
    ls_detail         TYPE recn_contract,
    ls_detail_old     TYPE recn_contract,
    ld_recnendabs     TYPE recncnendabs,
    ld_recnendabs_old TYPE recncnendabs.

  DATA rs_notice  TYPE recn_notice.

* get object manager
  lo_contract ?= sender.


  ls_detail = lo_contract->get_detail( ).

** is Vertrag Zeitlich beendet?
*  CHECK CL_RECA_DATE=>IS_DATETO_INITIAL( ID_DATETO = LS_DETAIL-RECNENDABS ) = ABAP_FALSE.


  ls_detail_old = lo_contract->get_detail_old( ).

  ld_recnendabs     = ls_detail-recnendabs.
  ld_recnendabs_old = ls_detail_old-recnendabs.


  IF ld_recnendabs <> ld_recnendabs_old.

*   Check ob zum Vertragsende die Kündigung vorhanden
    rs_notice = zch_ext_controller_mngr=>find_notice_for_contract( i_contract = lo_contract ). " EF 14246
    CHECK: rs_notice-ntactive = abap_true AND               " EF 14246
           rs_notice-ntper    = ld_recnendabs.              " EF 14246


*   Ext. Dienstleistung Bemessungänderung
    zch_ext_controller_mngr=>_ext_dienstleist_bemessung_2(
        id_recnendabs     = ld_recnendabs
        id_recnendabs_old = ld_recnendabs_old
        is_detail         = ls_detail
           ).

  ENDIF.


ENDMETHOD.


METHOD find_notice_for_contract.

* Kündigungsmanager
  DATA lo_notice_mngr TYPE REF TO if_recn_notice_mngr.
  lo_notice_mngr = i_contract->get_notice_mngr( ).

* Liste aller Kündigungen
  DATA lt_list TYPE re_t_notice.
  lo_notice_mngr->get_list( IMPORTING et_list = lt_list ).

* Aktive von heute suchen
  FIELD-SYMBOLS <notice> TYPE recn_notice.
  LOOP AT lt_list ASSIGNING <notice> WHERE ntactive = abap_true.
    rs_notice = <notice>.
    RETURN.
  ENDLOOP.

ENDMETHOD.


METHOD if_reca_static_event_handler~set_handler.

  SET HANDLER:
    notice_mngr_after_activate       FOR ALL INSTANCES,
    notice_mngr_after_deactivate     FOR ALL INSTANCES,
    contract_after_store             FOR ALL INSTANCES,
    me_after_store                   FOR ALL INSTANCES.

ENDMETHOD.


METHOD me_after_store.

  DATA:
*   manager
    lo_rental_object TYPE REF TO if_rebd_rental_object,
    lo_bus_object    TYPE REF TO if_reca_bus_object.
  DATA:
*   relevant fields for occupancy
    ls_detail     TYPE rebd_rental_object,
    ls_detail_old TYPE rebd_rental_object.

* get object manager
  lo_rental_object ?= sender.


  ls_detail = lo_rental_object->get_detail( ).

  ls_detail_old = lo_rental_object->get_detail_old( ).



  IF ls_detail <> ls_detail_old.

** Ext. Dienstleistung Bemessungänderung
    zch_ext_controller_mngr=>_ext_dienstleist_bemessung_3(
        is_detail_old = ls_detail_old
        is_detail     = ls_detail
           ).


  ENDIF.


ENDMETHOD.


METHOD notice_mngr_after_activate.

  DATA:
*   manager
    lo_notice_mngr TYPE REF TO if_recn_notice_mngr,
    lo_bus_object  TYPE REF TO if_reca_bus_object.
  DATA:
*   relevant fields for occupancy
    ls_rebdocnotice        TYPE recn_notice,
    ls_rebdocnotice_before TYPE recn_notice.

* get object manager
  lo_notice_mngr ?= sender.
* get parent
  lo_bus_object  ?= lo_notice_mngr->mo_parent.
  CHECK lo_bus_object->md_objtype = reca1_objtype-contract.

* relevant for occupancy?
  MOVE-CORRESPONDING is_detail_after        TO ls_rebdocnotice.
  MOVE-CORRESPONDING is_detail_before TO ls_rebdocnotice_before.
  CHECK ls_rebdocnotice <> ls_rebdocnotice_before.


** Ext. Dienstleistung Bemessungänderung
*  ZCH_EXT_CONTROLLER_MNGR=>_EXT_DIENSTLEIST_BEMESSUNG_1(
*      IS_DETAIL_BEFORE = LS_REBDOCNOTICE_BEFORE
*      IS_DETAIL        = LS_REBDOCNOTICE
*      IO_NOTICE_MNGR   = LO_NOTICE_MNGR
*         ).


ENDMETHOD.


METHOD notice_mngr_after_deactivate.

  DATA:
*   manager
    lo_notice_mngr TYPE REF TO if_recn_notice_mngr,
    lo_bus_object  TYPE REF TO if_reca_bus_object.
  DATA:
*   relevant fields for occupancy
    ls_rebdocnotice        TYPE recn_notice,
    ls_rebdocnotice_before TYPE recn_notice.

* get object manager
  lo_notice_mngr ?= sender.
* get parent
  lo_bus_object  ?= lo_notice_mngr->mo_parent.
  CHECK lo_bus_object->md_objtype = reca1_objtype-contract.

* relevant for occupancy?
  MOVE-CORRESPONDING is_detail_after       TO ls_rebdocnotice.
  MOVE-CORRESPONDING is_detail_before TO ls_rebdocnotice_before.
  CHECK ls_rebdocnotice <> ls_rebdocnotice_before.


* Ext. Dienstleistung Bemessungänderung
  zch_ext_controller_mngr=>_ext_dienstleist_bemessung_1(
      is_detail_before = ls_rebdocnotice_before
      is_detail        = ls_rebdocnotice
      io_notice_mngr   = lo_notice_mngr
         ).


ENDMETHOD.


METHOD _ext_dienstleist_bemessung_1.

  DATA  id_dienstleistung  TYPE zddienstleistung VALUE 'MEAS'.
  DATA: ls_flaeche TYPE ztexd_flache, "  Externe Dienstleistung Flächenänderung SAP
        lt_flaeche TYPE STANDARD TABLE OF ztexd_flache.
  DATA  it_guid            TYPE re_t_guid.
  DATA  ro_instance        TYPE REF TO zif_pd_ztexd_flache_mngr.
  DATA: ld_infoart         TYPE zdextinfoart. " Infoart Ext. Dienstleistung

* Get Bemessungsobjekt
  SELECT  * FROM ztexd_flache INTO ls_flaeche
    WHERE dienstleistung = id_dienstleistung
    AND   bukrs          = io_notice_mngr->mo_parent->ms_detail-bukrs
    AND   smive_aktuell  = io_notice_mngr->mo_parent->ms_detail-recnnr.
*    AND   ME_UPDATE_FLAG = ABAP_FALSE.


*   Get Dinstleistung Manager
    APPEND ls_flaeche TO lt_flaeche.

  ENDSELECT.


  CHECK  (  sy-batch <> 'X'           AND
            sy-binpt <> 'X'           AND
            sy-tcode <> 'SM35'        AND
            sy-tcode <> 'SM36'        AND
            sy-tcode <> 'SM37'        AND
            sy-tcode <> 'RERAPP'      AND
            sy-tcode <> 'RERAPPRV'    AND
            sy-tcode <> 'RERAALCN'    AND
            sy-tcode <> 'RERAALCNRV'  AND
            sy-tcode <> 'RESCSE'      AND
            sy-tcode <> 'RESCCH'      AND
            sy-tcode <> 'RESCBC'      AND
            sy-tcode <> 'RESCFIX'     AND
            sy-tcode <> 'RECDCGOL'    AND
            sy-tcode <> 'RECDCH'      AND
            sy-tcode <> 'RESCRV'      AND
            sy-tcode <> 'RESCAJ'      AND
            sy-tcode <> 'REAJPR'      AND
            sy-tcode <> 'REAJCH'      AND
            sy-tcode <> 'REAJRV'      AND
            sy-tcode <> 'REAJPRCEA'   AND
            sy-tcode <> 'REAJCHCEA'   AND
            sy-tcode <> 'REAJRVCEA'   AND
            sy-tcode <> 'ZTROBJCHANGE' AND
            sy-tcode <> 'ZTR_DTCA_MIG').
*           Keine Validierung bei der Umsymbolisierung
  CHECK     ( sy-tcode <>	'ZRECSRTPR' AND sy-tcode <>	'ZRECSRTCR' )
  AND       ( sy-cprog <> 'SAPMSSY1' ). " Paralle Prozess.




  "	Da die Flächenänderung bei Änderungsaktivität #ja# erfolgt und auch bei der Stornierung / Verschiebung
  " eines Kündigungsdatums erhalten bleibt, würde ich bitten noch eine Validierung bei der Stornierung / Verschiebung
  " eines Kündigungsdatums zu ergänzen, welche (sofern das Mietobjekt in der Änderungshistorie hinterlegt ist)
  " einen Warnhinweis #Sie haben das Kündigungsdatum geändert. Es ist bereits eine Anpassung der Fläche erfolgt.
  " Bitte passen Sie auf dem Mietobjekt unter Bemessungen das Gültigkeitsdatum der neuen Fläche an bzw. löschen
  " die neue Fläche, wenn die Kündigung aufgehoben wurde# ausgibt.

  "  Validierung
  READ TABLE  lt_flaeche INTO ls_flaeche WITH KEY me_update_flag = abap_true.
  IF sy-subrc = 0.
    MESSAGE i032 DISPLAY LIKE 'W'.
*  Es ist bereits eine Anpassung der Fläche erfolgt.
  ENDIF.







ENDMETHOD.


METHOD _ext_dienstleist_bemessung_2.

  DATA id_dienstleistung  TYPE zddienstleistung VALUE 'MEAS'.
  DATA: ls_flaeche        TYPE ztexd_flache. "  Externe Dienstleistung Flächenänderung SAP
  DATA it_tab             TYPE z_t_ztexd_flache.
  DATA ro_instance        TYPE REF TO zif_pd_ztexd_flache_mngr.
  DATA: ld_infoart        TYPE zdextinfoart. " Infoart Ext. Dienstleistung





*  Kündigung wurde aktiviert
  IF ( id_recnendabs  <> id_recnendabs_old  ).



* E.Firsanov Get Bemessungsobjekt  " EF 18924
    SELECT * FROM ztexd_flache AS meas                      " EF 18924
      INNER JOIN vibdobjass AS ass                          " EF 18924
      ON meas~objnr = ass~objnrtrg                          " EF 18924
      WHERE ass~objasstype = '10'                           " EF 18924
        AND ass~objnrsrc = @is_detail-objnr                 " EF 18924
        AND meas~dienstleistung = @id_dienstleistung        " EF 18924
        AND meas~me_update_flag = @abap_false               " EF 18924
      INTO CORRESPONDING FIELDS OF TABLE @it_tab.           " EF 18924

*    SELECT  * FROM ZTEXD_FLACHE                             " EF 18924
*      INTO LS_FLAECHE                                       " EF 18924
*      WHERE DIENSTLEISTUNG = ID_DIENSTLEISTUNG              " EF 18924
*      AND   BUKRS          = IS_DETAIL-BUKRS                " EF 18924
*      AND   SMIVE_AKTUELL  = IS_DETAIL-RECNNR               " EF 18924
*      AND   ME_UPDATE_FLAG = ABAP_FALSE.                    " EF 18924
*
**     Get Dinstleistung Manager
*      APPEND LS_FLAECHE TO IT_TAB.                          " EF 18924
*
*    ENDSELECT.                                              " EF 18924


    CHECK it_tab[] IS NOT INITIAL.



    zcf_pd_ztexd_flache_mngr=>find_by_tab(
      EXPORTING
        id_dienstleistung = id_dienstleistung
        it_tab            = it_tab
        id_activity       = reca1_activity-change
        id_auth_check     = abap_false
        id_enqueue        = abap_false
      RECEIVING
        ro_instance       = ro_instance
      EXCEPTIONS
        error             = 1
        OTHERS            = 2 ##SUBRC_OK
           ).

    CHECK ro_instance IS BOUND.


    " Get Key
    ls_flaeche = it_tab[ 1 ]. "#EC CI_NOORDER                               " EF 18924

    ro_instance->mv_laufzeitende_set(
        is_key            = ls_flaeche-key
        id_recnendabs     = id_recnendabs
        id_recnendabs_old = id_recnendabs_old
        is_detail         = is_detail
        if_in_update_task = if_in_update_task
           ).




*  Store
    IF ro_instance->is_modified( ) = abap_true.
      ro_instance->store(
       EXPORTING
         if_in_update_task = abap_false
         if_force_check    = abap_false
       EXCEPTIONS
         error             = 1
         OTHERS            = 2 ##SUBRC_OK
         ).
    ENDIF.


  ENDIF.


ENDMETHOD.


METHOD _ext_dienstleist_bemessung_3.

  DATA id_dienstleistung  TYPE zddienstleistung VALUE 'MEAS'.
  DATA: ls_flaeche        TYPE ztexd_flache. "  Externe Dienstleistung Flächenänderung SAP
  DATA it_tab             TYPE z_t_ztexd_flache.
  DATA ro_instance        TYPE REF TO zif_pd_ztexd_flache_mngr.
  DATA: ld_infoart        TYPE zdextinfoart. " Infoart Ext. Dienstleistung

* Get Bemessungsobjekt
  SELECT  * FROM ztexd_flache INTO ls_flaeche
    WHERE dienstleistung = id_dienstleistung
    AND   bukrs          = is_detail-bukrs
    AND   swenr          = is_detail-swenr
    AND   smenr          = is_detail-smenr
    AND   me_update_flag = abap_false.

    CHECK sy-subrc = 0.

* Get Dinstleistung Manager
    APPEND ls_flaeche TO it_tab.

  ENDSELECT.

*  Sind Stammdaten geändert
  IF ( is_detail  <> is_detail_old  ) AND
     ( it_tab[] IS NOT INITIAL ).


    zcf_pd_ztexd_flache_mngr=>find_by_tab(
      EXPORTING
        id_dienstleistung = id_dienstleistung
        it_tab            = it_tab
        id_activity       = reca1_activity-change
        id_auth_check     = abap_false
        id_enqueue        = abap_false
      RECEIVING
        ro_instance       = ro_instance
      EXCEPTIONS
        error             = 1
        OTHERS            = 2 ##SUBRC_OK
           ).

    CHECK ro_instance IS BOUND.



    ro_instance->me_stammaend_set( is_detail = is_detail ).


*  Store
    IF ro_instance->is_modified( ) = abap_true.
      ro_instance->store(
       EXPORTING
         if_in_update_task = abap_false
         if_force_check    = abap_false
       EXCEPTIONS
         error             = 1
         OTHERS            = 2 ##SUBRC_OK
         ).
    ENDIF.

*    IF LS_FLAECHE-AKTIVITAET = 'info'.
*
*      ZCL_EXTDIENST_SERVICES=>SENDE_INFO_EMAIL(
*        EXPORTING
*          IS_LIST           = LS_FLAECHE
*          IO_MSGLIST        = LO_MSGLIST
*          IS_DETAIL         = IS_DETAIL
*          ID_INFOART        = lD_INFOART
*        CHANGING
*          CD_INFO_VERWALTER = LS_FLAECHE-INFO_VERWALTER
*        EXCEPTIONS
*          ERROR             = 1
*          OTHERS            = 2
*             ).
*      IF SY-SUBRC <> 0.
**     build icon for Update
*        CALL FUNCTION 'ICON_CREATE'
*          EXPORTING
*            NAME   = 'ICON_MAIL'
*            INFO   = TEXT-FEE
*          IMPORTING
*            RESULT = LS_FLAECHE-INFO_VERWALTER
*          EXCEPTIONS
*            OTHERS = 0.
*
*
*      ENDIF.
*    ELSE.
*
**   Bemessung update
*      ZCL_EXTDIENST_SERVICES=>FLAECHE_ME_UPDATEN(
*        EXPORTING
*          IS_LIST           = LS_FLAECHE
*          IO_MSGLIST        = LO_MSGLIST
*          ID_KUENDIGUNG     = ABAP_TRUE
*          ID_NTPER          = IS_DETAIL-NTPER
*          ID_NTSTORNO       = ABAP_FALSE
*        CHANGING
*          CD_VALIDFROM      = LS_FLAECHE-VALIDFROM
*          CD_VALIDTO        = LS_FLAECHE-VALIDTO
*          CD_ME_UPDATE      = LS_FLAECHE-ME_UPDATE
*          CD_ME_UPDATE_FLAG = LS_FLAECHE-ME_UPDATE_FLAG
*        EXCEPTIONS
*          ERROR             = 1
*          OTHERS            = 2
*             ).
*    ENDIF.
*  ELSE.
*
**   Storno Bemessung in ME bei MV-Kündigungsstorno
*    ZCL_EXTDIENST_SERVICES=>FLAECHE_ME_UPDATEN(
*    EXPORTING
*      IS_LIST           = LS_FLAECHE
*      IO_MSGLIST        = LO_MSGLIST
*      ID_KUENDIGUNG     = ABAP_TRUE
*      ID_NTPER          = IS_DETAIL-NTPER
*      ID_NTSTORNO       = ABAP_TRUE
*    CHANGING
*      CD_VALIDFROM      = LS_FLAECHE-VALIDFROM
*      CD_VALIDTO        = LS_FLAECHE-VALIDTO
*      CD_ME_UPDATE      = LS_FLAECHE-ME_UPDATE
*      CD_ME_UPDATE_FLAG = LS_FLAECHE-ME_UPDATE_FLAG
*    EXCEPTIONS
*      ERROR             = 1
*      OTHERS            = 2
*      ).
*
*  ENDIF.
*
** Objektliste updaten
*  RO_INSTANCE->OBJEKTLISTE_CHANGE(
*    EXPORTING
*      IS_LIST = LS_FLAECHE
*    EXCEPTIONS
*      ERROR   = 1
*      OTHERS  = 2
*         ).
*
*
**  Store
*  IF RO_INSTANCE->IS_MODIFIED( ) = ABAP_TRUE.
*    RO_INSTANCE->STORE(
*     EXPORTING
*       IF_IN_UPDATE_TASK = ABAP_TRUE
*       IF_FORCE_CHECK    = ABAP_FALSE
*     EXCEPTIONS
*       ERROR             = 1
*       OTHERS            = 2
*       ).
  ENDIF.


ENDMETHOD.
ENDCLASS.
