CLASS zcl_extdienst_services DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPE-POOLS reca0 .
    TYPE-POOLS reca1 .

    CLASS-METHODS get_path
      IMPORTING
        !initial_directory TYPE string
      CHANGING
        !path              TYPE sapb-sappoolinf .
    CLASS-METHODS flaeche_me_updaten
      IMPORTING
        !it_flache         TYPE z_t_ztexd_flache
        !io_msglist        TYPE REF TO if_reca_message_list
      CHANGING
        !cd_me_update      TYPE char50
        !cd_me_update_flag TYPE flag
      EXCEPTIONS
        error .
    CLASS-METHODS sende_info_email
      IMPORTING
        !is_list           TYPE ztexd_flache
        !io_msglist        TYPE REF TO if_reca_message_list
        !is_detail         TYPE recn_notice
        !id_infoart        TYPE zdextinfoart
      CHANGING
        !cd_info_verwalter TYPE zdinfo_verwalter
      EXCEPTIONS
        error .
    CLASS-METHODS get_we_partner
      IMPORTING
        !i_bukrs          TYPE bukrs
        !i_swenr          TYPE swenr
        !io_msglist       TYPE REF TO if_reca_message_list OPTIONAL
        !it_role          TYPE bup_t_role
      RETURNING
        VALUE(rt_partner) TYPE z_t_zemod_partrel
      EXCEPTIONS
        error .
    CLASS-METHODS get_mv_partner
      IMPORTING
        !id_bukrs      TYPE bukrs
        !id_recnnr     TYPE recnnr
        !it_rolle      TYPE bup_t_role
        !is_stichtag   TYPE sy-datum
      EXPORTING
        !et_mv_partner TYPE z_t_zvcnbpadress
      EXCEPTIONS
        error .
PROTECTED SECTION.
PRIVATE SECTION.

  CLASS-METHODS get_adresline
    RETURNING
      VALUE(rd_adrline) TYPE string .
ENDCLASS.



CLASS ZCL_EXTDIENST_SERVICES IMPLEMENTATION.


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
      cf_reca_bus_object=>find_by_objnr(
        EXPORTING
          id_objnr       = ls_flache-objnr
          id_activity    = reca1_activity-change
          if_enqueue     = abap_false
        RECEIVING
          ro_instance    = ro_instance
        EXCEPTIONS
          error          = 1
          OTHERS         = 2
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

*    Save ME
    io_has_meas->store(
       EXPORTING
         if_in_update_task = abap_true
       EXCEPTIONS
         error             = 1
         OTHERS            = 2
            ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      RAISING error.
    ENDIF.

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


METHOD get_adresline.
*  DATA: LD_ORTSTR TYPE STRING.
*
*  CLEAR RD_ADRLINE.
*  IF MS_DETAIL-OBJ_ADR IS NOT INITIAL.
*    CONCATENATE MS_DETAIL-CITY1 ',' INTO LD_ORTSTR.
*    CONCATENATE MS_DETAIL-POST_CODE1  LD_ORTSTR
*                MS_DETAIL-STREET  MS_DETAIL-HOUSE_NUM1 INTO RD_ADRLINE
*                SEPARATED BY ' '.
*  ENDIF.
ENDMETHOD.


METHOD get_mv_partner.

* GET Partner von WE
  DATA: ls_rolle      LIKE LINE OF it_rolle,
        ls_mv_partner LIKE LINE OF et_mv_partner,
        rt_rolle      TYPE RANGE OF bu_partnerrole,
        lsr_rolle     LIKE LINE OF rt_rolle,
        ld_validfrom  TYPE datum,
        ld_timefrom   TYPE uzeit,
        ld_validto    TYPE datum,
        ld_timeto     TYPE uzeit,
        ld_tabix      TYPE sy-tabix.


  CHECK it_rolle[] IS NOT INITIAL.

  LOOP AT it_rolle INTO ls_rolle.
    CLEAR lsr_rolle.
    lsr_rolle-sign   = 'I'.
    lsr_rolle-option = 'EQ'.
    lsr_rolle-low    = ls_rolle.
    APPEND lsr_rolle TO rt_rolle.
  ENDLOOP.


  SELECT * FROM zvcnbpadress INTO TABLE et_mv_partner WHERE bukrs  = id_bukrs
                                                        AND recnnr = id_recnnr
                                                        AND  role IN rt_rolle
                                                        AND validfrom < is_stichtag
                                                        AND validto   > is_stichtag..

  CLEAR ld_tabix.

  LOOP AT et_mv_partner INTO ls_mv_partner.

    ld_tabix = sy-tabix.
    CLEAR: ld_validfrom, ld_validto, ld_timefrom, ld_timeto.

*   convert it to date and time in desired timezone
    CONVERT TIME STAMP ls_mv_partner-addr_from TIME ZONE sy-zonlo
    INTO DATE ld_validfrom TIME ld_timefrom.

    CONVERT TIME STAMP ls_mv_partner-addr_to TIME ZONE sy-zonlo
    INTO DATE ld_validto  TIME ld_timeto.

    " E.Firsanov Gültig to konvertierern
    IF ld_validto = '00000000'.
      ld_validto = '99991231'.
    ENDIF.

    IF is_stichtag NOT BETWEEN ld_validfrom AND ld_validto.
      DELETE et_mv_partner INDEX ld_tabix.
    ENDIF.

  ENDLOOP.



ENDMETHOD.


METHOD get_path.
  DATA: file_table    TYPE filetable,
        ls_file_table TYPE file_table,
        rc            TYPE i.

  cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      window_title            = 'Datai anzeigen'
      initial_directory       = initial_directory
      file_filter             = '*.xls*'
      multiselection          = abap_false
    CHANGING
      file_table              = file_table
      rc                      = rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5
         ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    READ TABLE file_table INTO ls_file_table INDEX 1.
    path =  ls_file_table-filename.
  ENDIF.
ENDMETHOD.


METHOD get_we_partner.


********************************************************************
* GET Zugeordnete Immobilienobjekte um Partner auf WE zu finden
********************************************************************


* Daten löschen
  REFRESH rt_partner.

  FIELD-SYMBOLS <ls_list> LIKE LINE OF rt_partner.


  DATA: lt_user_list   TYPE  z_t_zcemod_tm,
        ls_user_list   TYPE  zcemod_tm,
        return         TYPE STANDARD TABLE OF  bapiret2,
        ls_return      LIKE LINE OF return,
        ls_user_adress TYPE bapiaddr3.


* GET Partner von WE
  DATA: ro_instance_we  TYPE REF TO if_rebd_business_entity,
        lo_partner_mngr TYPE REF TO if_rebp_partner_mngr,
        lo_partner      TYPE REF TO if_rebp_partner,
        ls_islocked     TYPE bapislockd,
        lo_has_partner  TYPE REF TO if_rebp_has_partner,
        dummy           TYPE string.
  DATA: lt_objrel_x     TYPE re_t_bp_objrel_x,
        ls_objrel_x     TYPE rebp_objrel_x,
        iv_username     TYPE syuname,
        ls_mail_address TYPE recacommmailpar,
        ls_tel_address  TYPE recacommtelpar,
        ls_fax_address  TYPE recacommfaxpar,
        ld_partner_guid TYPE bu_partner_guid.
  DATA:   ld_role            LIKE LINE OF it_role.

  cf_rebd_business_entity=>find(
  EXPORTING
    id_bukrs       = i_bukrs
    id_swenr       = i_swenr
    RECEIVING
    ro_instance    = ro_instance_we
  EXCEPTIONS
    error          = 1
    OTHERS         = 2
    ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    RAISING error.
  ENDIF.

  lo_has_partner   ?= ro_instance_we.
* partner
  CALL METHOD cf_rebp_partner_mngr=>find_by_parent
    EXPORTING
      io_parent   = lo_has_partner
    RECEIVING
      ro_instance = lo_partner_mngr.

  CALL METHOD lo_partner_mngr->get_list_x
    IMPORTING
      et_list_x = lt_objrel_x.

* Partner auf Gültigkeit filtern

  cl_reca_bapi_services=>filter_list_by_detail_period(
  EXPORTING
    id_seldate_from        = sy-datum
    id_seldate_to          = sy-datum
    id_seldate_min         = reca0_date-min
    id_seldate_max         = reca0_date-max
  CHANGING
    ct_list                = lt_objrel_x
    ).



*  DATA: ET_PART_CUST             TYPE Z_T_ZDV_PART,
*        LS_PART_CUST             LIKE LINE OF ET_PART_CUST.
  DATA: ld_uname  TYPE sy-uname.

*  ZCL_GET_ZDV_PART=>GET_LIST(
*  IMPORTING
*    ET_LIST             = ET_PART_CUST
*    ).

* WE-Partner ins Ausgabetabelle schreiben
  LOOP AT it_role INTO ld_role .

*   Existiert Partner in die Rolle?
    READ TABLE lt_objrel_x INTO ls_objrel_x WITH KEY role = ld_role.
    IF sy-subrc <> 0.
*     Fehler
    ENDIF.


*   Get Part-GUID
    SELECT SINGLE partner_guid FROM but000 INTO ld_partner_guid WHERE partner = ls_objrel_x-partner.
    IF sy-subrc = 0.
*     check Ausnahme Tabelle
      SELECT SINGLE bname FROM zdt_bupartus INTO iv_username
               WHERE partner = ls_objrel_x-partner.
      IF sy-subrc NE 0.
        CALL FUNCTION 'BP_CENTRALPERSON_GET'
          EXPORTING
            iv_bu_partner_guid  = ld_partner_guid
          IMPORTING
            ev_username         = iv_username
          EXCEPTIONS
            no_central_person   = 1
            no_business_partner = 2
            no_id               = 3
            OTHERS              = 4.
        IF sy-subrc <> 0 OR iv_username IS INITIAL.

          IF io_msglist IS BOUND.
            MESSAGE e097(zemod) WITH ls_objrel_x-partner ls_objrel_x-role INTO dummy.
*           Beim Partner & Rolle & ist Identifikation von Benutzername nicht gepflegt
            io_msglist->add_symsg( if_cumulate = abap_true ).
          ELSE.
            MESSAGE e097(zemod) WITH ls_objrel_x-partner ls_objrel_x-role RAISING error.
*         Beim Partner & Rolle & ist Identifikation von Benutzername nicht gepflegt
          ENDIF.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

*   prüfe ob Benutzer auf der Maschine gesperrt
    CLEAR ls_islocked.
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = iv_username
      IMPORTING
        islocked = ls_islocked
      TABLES
        return   = return.

    IF ls_islocked-local_lock = 'L' OR ls_islocked-glob_lock = 'L'.
      IF sy-sysid = 'PS4'.
        IF io_msglist IS BOUND.
          MESSAGE e098(zemod) WITH iv_username ls_objrel_x-xname sy-sysid INTO dummy.
*         Der Benutzer &1 (&2) ist weiterhin auf &3 gesperrt
          io_msglist->add_symsg( if_cumulate = abap_true ).
        ELSE.
          MESSAGE e098(zemod) WITH iv_username ls_objrel_x-xname sy-sysid RAISING error.
*         Der Benutzer &1 ist weiterhin auf &2 gesperrt
        ENDIF.
      ELSE.
        IF io_msglist IS BOUND.
          MESSAGE e098(zemod) WITH iv_username ls_objrel_x-xname sy-sysid INTO dummy.
*         Der Benutzer &1 (&2) ist weiterhin auf &3 gesperrt
          io_msglist->add_symsg( if_cumulate = abap_true ).
        ELSE.
          MESSAGE e098(zemod) WITH iv_username ls_objrel_x-xname sy-sysid RAISING error.
*         Der Benutzer &1 ist weiterhin auf &2 gesperrt
        ENDIF.
      ENDIF.

      CONTINUE.
    ENDIF.

    CALL METHOD cf_rebp_partner=>find
      EXPORTING
        id_partner  = ls_objrel_x-partner
      RECEIVING
        ro_instance = lo_partner
      EXCEPTIONS
        OTHERS      = 0.
    IF sy-subrc <> 0.
      IF sy-sysid = 'PS4'.
        IF io_msglist IS BOUND.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          INTO dummy.
          io_msglist->add_symsg( if_cumulate = abap_true ).
        ELSE.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          RAISING error.
        ENDIF.
      ELSE.
        IF io_msglist IS BOUND.
          MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          INTO dummy.
          io_msglist->add_symsg( if_cumulate = abap_true ).
        ELSE.
          MESSAGE ID sy-msgid TYPE 'W' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          RAISING error.
        ENDIF.
      ENDIF.
      CONTINUE.
    ENDIF.

    CHECK lo_partner IS BOUND. "

*   Get Kommunikationsdaten
    CALL METHOD lo_partner->get_communication_data
      IMPORTING
        es_mail_address = ls_mail_address
        es_tel_address  = ls_tel_address
        es_fax_address  = ls_fax_address
      EXCEPTIONS
        OTHERS          = 0.



*   Set Partner Daten
    APPEND INITIAL LINE TO rt_partner ASSIGNING <ls_list>.
    <ls_list>-objnr            = ro_instance_we->ms_detail-objnr.
    <ls_list>-bname            = iv_username.
    <ls_list>-userkz           = ''.
    <ls_list>-validfrom        = ls_objrel_x-validfrom.
    <ls_list>-xrole            = ls_objrel_x-xrole.
    <ls_list>-xname            = ls_objrel_x-xname.
    <ls_list>-validto          = ls_objrel_x-validto.
    <ls_list>-partner          = ls_objrel_x-partner.
    <ls_list>-role             = ls_objrel_x-role.
    <ls_list>-tel_number_long  = ls_tel_address-tel_number_long.
    <ls_list>-fax_number_long  = ls_fax_address-fax_number_long.
    <ls_list>-smtp_addr        = ls_mail_address-smtp_addr.


  ENDLOOP.






  DATA: ls_kdst_key  TYPE zst_kdst_key.
* Get Profitcenter
  DATA rd_prctr   TYPE rebd_business_entity_x-prctr.
  rd_prctr = ro_instance_we->get_profit_center(
  ).
  ls_kdst_key-team  = rd_prctr+3(1).
  ls_kdst_key-rteam = rd_prctr+3(2).
  ls_kdst_key-kdst  = rd_prctr+3(3).






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
        ld_string      TYPE string.

  CONSTANTS:
  lc_bcs_rqst      TYPE bcs_rqst VALUE 'N'.

  DATA: gd_text_update TYPE string,
        ld_date_c(10)  TYPE c.

* Set Titel
  IF sy-sysid = 'PS4'.
    ld_title = 'Beauftragung eine Vermessung'.
  ELSE.
    CONCATENATE 'TEST!!!' sy-sysid 'Beauftragung eine Vermessung' INTO ld_title SEPARATED BY ' '.
  ENDIF.

* Set Text
  CLEAR ls_text.

  cl_reca_date=>convert_date_to_string(
    EXPORTING
      id_date        = is_detail-ntper
    IMPORTING
      ed_date_string = ed_date_string
         ).
  CONCATENATE is_list-bukrs is_list-smive_aktuell INTO ld_string SEPARATED BY '/'.
  CONCATENATE 'Mietvertrag:' ld_string INTO ld_string SEPARATED BY ' '.
  CONCATENATE ld_string 'ist zum' ed_date_string 'gekündigt.'  INTO ls_text SEPARATED BY ' '.
  APPEND ls_text TO lt_text.

  CONCATENATE 'Beantragen Sie bitte bei' is_list-ext_dienstlif 'die Vermessung.'
  INTO ls_text SEPARATED BY ' '.
  APPEND ls_text TO lt_text.

  CLEAR ls_text.
  APPEND ls_text TO lt_text.

  ls_text = 'Dieses Schreiben wurde maschinell erstellt, bei Fragen wenden Sie sich bitte an Herrn Reinhardt.'.
  APPEND ls_text TO lt_text.



* GET Empfänger
  DATA: it_role     TYPE bup_t_role.
  DATA: rt_partner TYPE z_t_zemod_partrel,
        ls_partner LIKE LINE OF rt_partner.

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

  READ TABLE rt_partner INTO ls_partner INDEX 1.
  IF sy-subrc = 0.
*    " SAP-Infomail in Workspace
*    RD_RECIPIENT      = LS_PARTNER-BNAME.
*      APPEND LD_RECIPIENT    TO LT_ADDRESS_SAP.
    " SMTP Outlook Nachricht
    IF sy-uname = 'DEB56322'.
      ls_address_mail   = 'Eduard.Firsanov@immeo.de'.
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
      ls_address_mail   = 'Eduard.Firsanov@immeo.de'.
    ELSE.
      ls_address_mail   = 'Joern.Reinhardt@immeo.de'.
    ENDIF.
    APPEND ls_address_mail TO lt_address_mail.
  ENDIF.


  zcl_admin_services=>email_senden_neu_convert(
  EXPORTING
    id_betreff       = ld_title
    it_text          = lt_text
    it_addresses     = lt_address_mail
    it_file          = lt_file
    if_commit_work   = abap_false
    id_bcs_rqst      = lc_bcs_rqst
    it_address_user	 = lt_address_sap
    id_sender        = 'ZBATCH'
  EXCEPTIONS
    error        = 1
    OTHERS       = 2
    ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
    RAISING error.
  ELSE.
*     build icon for Update
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name   = 'ICON_MAIL'
        info   = TEXT-oke
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
    INTO cd_info_verwalter
    SEPARATED BY ' '.

  ENDIF.



ENDMETHOD.
ENDCLASS.
