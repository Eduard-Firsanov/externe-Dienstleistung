CLASS zcl_get_ztexd_flache DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CLASS-METHODS class_constructor .
    TYPE-POOLS abap .
    CLASS-METHODS check_key
      IMPORTING
        !id_dienstleistung   TYPE ztexd_flache-dienstleistung
        !id_objnr            TYPE ztexd_flache-objnr
        !id_meas             TYPE ztexd_flache-meas
        !id_meas_guid        TYPE ztexd_flache-meas_guid
        !if_bypassing_buffer TYPE abap_bool OPTIONAL
        !if_reset_buffer     TYPE abap_bool OPTIONAL
        !id_max_buffer_size  TYPE i DEFAULT 1000
      EXCEPTIONS
        not_found .
    CLASS-METHODS exists
      IMPORTING
        !id_dienstleistung   TYPE ztexd_flache-dienstleistung
        !id_objnr            TYPE ztexd_flache-objnr
        !id_meas             TYPE ztexd_flache-meas
        !id_meas_guid        TYPE ztexd_flache-meas_guid
        !if_bypassing_buffer TYPE abap_bool OPTIONAL
        !if_reset_buffer     TYPE abap_bool OPTIONAL
        !id_max_buffer_size  TYPE i DEFAULT 1000
      RETURNING
        VALUE(rf_exists)     TYPE abap_bool .
    CLASS-METHODS get_detail
      IMPORTING
        !id_dienstleistung   TYPE ztexd_flache-dienstleistung
        !id_objnr            TYPE ztexd_flache-objnr
        !id_meas             TYPE ztexd_flache-meas
        !id_meas_guid        TYPE ztexd_flache-meas_guid
        !if_bypassing_buffer TYPE abap_bool OPTIONAL
        !if_reset_buffer     TYPE abap_bool OPTIONAL
        !id_max_buffer_size  TYPE i DEFAULT 1000
      RETURNING
        VALUE(rs_detail)     TYPE ztexd_flache
      EXCEPTIONS
        not_found .
    CLASS-METHODS get_list
      IMPORTING
        !if_bypassing_buffer TYPE abap_bool OPTIONAL
        !if_reset_buffer     TYPE abap_bool OPTIONAL
        !id_max_buffer_size  TYPE i DEFAULT 1000
      EXPORTING
        !et_list             TYPE z_t_ztexd_flache .
    CLASS-METHODS get_list_by_dienstleistung
      IMPORTING
        !id_dienstleistung   TYPE ztexd_flache-dienstleistung
        !if_bypassing_buffer TYPE abap_bool OPTIONAL
        !if_reset_buffer     TYPE abap_bool OPTIONAL
        !id_max_buffer_size  TYPE i DEFAULT 1000
      EXPORTING
        !et_list             TYPE z_t_ztexd_flache .
    CLASS-METHODS get_list_by_objnr
      IMPORTING
        !id_dienstleistung   TYPE ztexd_flache-dienstleistung
        !id_objnr            TYPE ztexd_flache-objnr
        !if_bypassing_buffer TYPE abap_bool OPTIONAL
        !if_reset_buffer     TYPE abap_bool OPTIONAL
        !id_max_buffer_size  TYPE i DEFAULT 1000
      EXPORTING
        !et_list             TYPE z_t_ztexd_flache .
    CLASS-METHODS get_list_by_meas
      IMPORTING
        !id_dienstleistung   TYPE ztexd_flache-dienstleistung
        !id_objnr            TYPE ztexd_flache-objnr
        !id_meas             TYPE ztexd_flache-meas
        !if_bypassing_buffer TYPE abap_bool OPTIONAL
        !if_reset_buffer     TYPE abap_bool OPTIONAL
        !id_max_buffer_size  TYPE i DEFAULT 1000
      EXPORTING
        !et_list             TYPE z_t_ztexd_flache .
    CLASS-METHODS transfer_to_buffer
      IMPORTING
        !is_detail          TYPE ztexd_flache OPTIONAL
        !it_list            TYPE z_t_ztexd_flache OPTIONAL
        !id_partkey_index   TYPE i DEFAULT -1
        !if_as_not_found    TYPE abap_bool OPTIONAL
        !if_reset_buffer    TYPE abap_bool OPTIONAL
        !id_max_buffer_size TYPE i DEFAULT 1000 .
    CLASS-METHODS get_buffer_size
      RETURNING
        VALUE(rd_buffer_size) TYPE i .
    CLASS-METHODS reset_buffer .
PROTECTED SECTION.
PRIVATE SECTION.

  CONSTANTS mc_data_source TYPE ddobjname VALUE 'ZTEXD_FLACHE'. "#EC NOTEXT
  CLASS-DATA mt_buffer TYPE tt_buffer .
  CLASS-DATA ms_buffer_hl TYPE ts_buffer_hl .
  CLASS-DATA mt_acc_partkey_buffer TYPE tt_acc_partkey_buffer .

  CLASS-METHODS select_single
    IMPORTING
      !id_dienstleistung     TYPE ztexd_flache-dienstleistung
      !id_objnr              TYPE ztexd_flache-objnr
      !id_meas               TYPE ztexd_flache-meas
      !id_meas_guid          TYPE ztexd_flache-meas_guid
      !if_insert_into_buffer TYPE abap_bool DEFAULT abap_true
    EXPORTING
      !es_detail             TYPE ztexd_flache
      !ef_not_found          TYPE abap_bool .
  CLASS-METHODS insert_into_all_buffers
    IMPORTING
      !is_buffer_hl       TYPE ts_buffer_hl
      !if_check_existence TYPE abap_bool OPTIONAL .
  CLASS-METHODS is_partkey_buffered
    IMPORTING
      !is_acc_partkey_buffer TYPE ts_acc_partkey_buffer_hl
    RETURNING
      VALUE(rf_buffered)     TYPE abap_bool .
ENDCLASS.



CLASS ZCL_GET_ZTEXD_FLACHE IMPLEMENTATION.


METHOD check_key.
  DATA ld_dienstleistung TYPE ztexd_flache-dienstleistung.

* BODY
  IF if_bypassing_buffer = abap_true.
    SELECT SINGLE dienstleistung FROM ztexd_flache
      INTO  ld_dienstleistung
      WHERE    ( dienstleistung = id_dienstleistung )
        AND    ( objnr = id_objnr )
        AND    ( meas = id_meas )
        AND    ( meas_guid = id_meas_guid )
*{   REPLACE        C44K967448                                        1
      .
*}   REPLACE
    IF sy-subrc <> 0.
      CALL METHOD cl_redb_buffer_registry=>raise_not_found
        EXPORTING
          id_tabname = mc_data_source
          id_text    = TEXT-001
          id_key01   = id_dienstleistung
          id_key02   = id_objnr
          id_key03   = id_meas
          id_key04   = id_meas_guid
        EXCEPTIONS
          not_found  = 1
          OTHERS     = 2.
    ENDIF.
  ELSE.
    CALL METHOD get_detail
      EXPORTING
        id_dienstleistung   = id_dienstleistung
        id_objnr            = id_objnr
        id_meas             = id_meas
        id_meas_guid        = id_meas_guid
        if_reset_buffer     = if_reset_buffer
        if_bypassing_buffer = if_bypassing_buffer
        id_max_buffer_size  = id_max_buffer_size
*               RECEIVING
*       rs_detail           =
      EXCEPTIONS
        not_found           = 1
        OTHERS              = 2.
  ENDIF.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            RAISING not_found.
  ENDIF.

ENDMETHOD.


METHOD class_constructor.

  CLASS:
    cl_redb_buffer_registry DEFINITION LOAD,
    cl_oo_include_naming    DEFINITION LOAD.

  DATA:
    lo_naming   TYPE REF TO if_oo_clif_incl_naming,
    ld_progname TYPE syrepid.

* BODY
* get this class name
  ld_progname = sy-repid.
  lo_naming   = cl_oo_include_naming=>get_instance_by_include(
                  progname = ld_progname ).

* register class
  CALL METHOD cl_redb_buffer_registry=>register(
      id_clsname = lo_naming->cifkey-clsname ).

ENDMETHOD.


METHOD exists.
  DATA ld_dienstleistung TYPE ztexd_flache-dienstleistung.

* BODY
  IF if_bypassing_buffer = abap_true.
    SELECT SINGLE dienstleistung FROM ztexd_flache
      INTO  ld_dienstleistung
      WHERE    ( dienstleistung = id_dienstleistung )
        AND    ( objnr = id_objnr )
        AND    ( meas = id_meas )
        AND    ( meas_guid = id_meas_guid )
*{   REPLACE        C44K967448                                        1
      .
*}   REPLACE
  ELSE.
    CALL METHOD get_detail
      EXPORTING
        id_dienstleistung   = id_dienstleistung
        id_objnr            = id_objnr
        id_meas             = id_meas
        id_meas_guid        = id_meas_guid
        if_reset_buffer     = if_reset_buffer
        if_bypassing_buffer = if_bypassing_buffer
        id_max_buffer_size  = id_max_buffer_size
*               RECEIVING
*       rs_detail           =
      EXCEPTIONS
        not_found           = 1
        OTHERS              = 2.
  ENDIF.
  IF sy-subrc = 0.
    rf_exists = abap_true.
  ENDIF.

ENDMETHOD.


METHOD get_buffer_size.

* BODY
  DESCRIBE TABLE mt_buffer LINES rd_buffer_size.

ENDMETHOD.


METHOD get_detail.

  DATA lf_not_found TYPE abap_bool.

* BODY
  IF if_reset_buffer = abap_true.
    CALL METHOD reset_buffer( ).
  ENDIF.

  IF if_bypassing_buffer = abap_true.
*   force read bypassing buffer
    CALL METHOD select_single
      EXPORTING
        id_dienstleistung     = id_dienstleistung
        id_objnr              = id_objnr
        id_meas               = id_meas
        id_meas_guid          = id_meas_guid
        if_insert_into_buffer = abap_false
      IMPORTING
        es_detail             = rs_detail
        ef_not_found          = lf_not_found.
  ELSE.
*   check headerline buffer
    IF      ( ms_buffer_hl-dienstleistung = id_dienstleistung )
        AND ( ms_buffer_hl-objnr = id_objnr )
        AND ( ms_buffer_hl-meas = id_meas )
        AND ( ms_buffer_hl-meas_guid = id_meas_guid )
        .
*     entry found
      IF ( ms_buffer_hl-_not_found = abap_false ) AND
         ( NOT ms_buffer_hl IS INITIAL          ).
        MOVE-CORRESPONDING ms_buffer_hl TO rs_detail.       "#EC ENHOK
      ELSE.
        lf_not_found = abap_true.
      ENDIF.
    ELSE.
*     check table buffer
      READ TABLE mt_buffer INTO ms_buffer_hl WITH TABLE KEY
                   dienstleistung = id_dienstleistung
                   objnr = id_objnr
                   meas = id_meas
                   meas_guid = id_meas_guid
                    .
      IF sy-subrc = 0.
*       entry found
        IF ms_buffer_hl-_not_found = abap_false.
          MOVE-CORRESPONDING ms_buffer_hl TO rs_detail.     "#EC ENHOK
        ELSE.
          lf_not_found = abap_true.
        ENDIF.
      ELSE.
*       check table buffer boundaries
        IF id_max_buffer_size > 0.
          IF get_buffer_size( ) >= id_max_buffer_size.
            CALL METHOD reset_buffer( ).
          ENDIF.
        ENDIF.
*       get entry from database
        CALL METHOD select_single
          EXPORTING
            id_dienstleistung     = id_dienstleistung
            id_objnr              = id_objnr
            id_meas               = id_meas
            id_meas_guid          = id_meas_guid
            if_insert_into_buffer = abap_true
          IMPORTING
            es_detail             = rs_detail
            ef_not_found          = lf_not_found.
      ENDIF.
    ENDIF.
  ENDIF.

* not found exception
  IF lf_not_found = abap_true.
    CALL METHOD cl_redb_buffer_registry=>raise_not_found
      EXPORTING
        id_tabname = mc_data_source
        id_text    = TEXT-001
        id_key01   = id_dienstleistung
        id_key02   = id_objnr
        id_key03   = id_meas
        id_key04   = id_meas_guid
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING not_found.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD get_list.

  DATA: ls_acc_partkey_buffer LIKE LINE OF mt_acc_partkey_buffer,
        ls_detail             LIKE LINE OF et_list.
  FIELD-SYMBOLS <ls_buffer>   LIKE LINE OF mt_buffer.

* INIT RESULTS
  CLEAR et_list.

* BODY
  IF if_reset_buffer = abap_true.
    CALL METHOD reset_buffer( ).
  ENDIF.

  IF if_bypassing_buffer = abap_true.
*   force read bypassing buffer
    SELECT     *
      INTO     TABLE et_list
      FROM     ztexd_flache.                            "#EC CI_NOWHERE
  ELSE.
*   check table buffer for accesses with partial key
    CLEAR ls_acc_partkey_buffer.
    ls_acc_partkey_buffer-_partkey_index = '00'.
    IF is_partkey_buffered( ls_acc_partkey_buffer ) = abap_false.
*     access not found - read and transfer to buffer
*     read from database with partial key

* Quick Fix Append ORDER BY PRIMARY KEY to the SELECT statement
* 30.04.2024 09:37:29 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*      SELECT     *
*        INTO     TABLE et_list
*        FROM     ztexd_flache.    "#EC CI_NOWHERE

      SELECT     *
              INTO     TABLE et_list
              FROM     ztexd_flache ORDER BY PRIMARY KEY . "#EC CI_NOWHERE

* End of Quick Fix

      IF sy-subrc = 0.
*       check table buffer boundaries
        IF id_max_buffer_size > 0.
          IF get_buffer_size( ) >= id_max_buffer_size.
            CALL METHOD reset_buffer( ).
          ENDIF.
        ENDIF.
        CALL METHOD transfer_to_buffer
          EXPORTING
            it_list            = et_list
            if_reset_buffer    = abap_false
            id_max_buffer_size = 0.
      ENDIF.
*     add to table buffer for accesses with partial key
      INSERT ls_acc_partkey_buffer INTO TABLE mt_acc_partkey_buffer.
    ELSE.
*     access found - get data from table buffer
      LOOP AT mt_buffer ASSIGNING <ls_buffer>
                        WHERE _not_found = abap_false.
        MOVE-CORRESPONDING <ls_buffer> TO ls_detail.        "#EC ENHOK
        APPEND ls_detail TO et_list.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD get_list_by_dienstleistung.

  DATA: ls_acc_partkey_buffer LIKE LINE OF mt_acc_partkey_buffer,
        ls_detail             LIKE LINE OF et_list.
  FIELD-SYMBOLS <ls_buffer>   LIKE LINE OF mt_buffer.

* INIT RESULTS
  CLEAR et_list.

* BODY
  IF if_reset_buffer = abap_true.
    CALL METHOD reset_buffer( ).
  ENDIF.

  IF if_bypassing_buffer = abap_true.
*   force read bypassing buffer
    SELECT     *
      INTO     TABLE et_list
      FROM     ztexd_flache
      WHERE    ( dienstleistung = id_dienstleistung ).
  ELSE.
*   check table buffer for accesses with partial key
    CLEAR ls_acc_partkey_buffer.
    ls_acc_partkey_buffer-_partkey_index = '01'.
    ls_acc_partkey_buffer-dienstleistung = id_dienstleistung.
    IF is_partkey_buffered( ls_acc_partkey_buffer ) = abap_false.
*     access not found - read and transfer to buffer
*     read from database with partial key

* Quick Fix Append ORDER BY PRIMARY KEY to the SELECT statement
* 30.04.2024 09:37:29 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*      SELECT     *
*        INTO     TABLE et_list
*        FROM     ztexd_flache
*        WHERE    ( dienstleistung = id_dienstleistung ).

      SELECT     *
              INTO     TABLE et_list
              FROM     ztexd_flache
              WHERE    ( dienstleistung = id_dienstleistung ) ORDER BY PRIMARY KEY .

* End of Quick Fix

      IF sy-subrc = 0.
*       check table buffer boundaries
        IF id_max_buffer_size > 0.
          IF get_buffer_size( ) >= id_max_buffer_size.
            CALL METHOD reset_buffer( ).
          ENDIF.
        ENDIF.
        CALL METHOD transfer_to_buffer
          EXPORTING
            it_list            = et_list
            if_reset_buffer    = abap_false
            id_max_buffer_size = 0.
      ENDIF.
*     add to table buffer for accesses with partial key
      INSERT ls_acc_partkey_buffer INTO TABLE mt_acc_partkey_buffer.
    ELSE.
*     access found - get data from table buffer
      LOOP AT mt_buffer ASSIGNING <ls_buffer>
                        WHERE dienstleistung = id_dienstleistung.
        IF <ls_buffer>-_not_found = abap_false.
          MOVE-CORRESPONDING <ls_buffer> TO ls_detail.      "#EC ENHOK
          APPEND ls_detail TO et_list.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD get_list_by_meas.

  DATA: ls_acc_partkey_buffer LIKE LINE OF mt_acc_partkey_buffer,
        ls_detail             LIKE LINE OF et_list.
  FIELD-SYMBOLS <ls_buffer>   LIKE LINE OF mt_buffer.

* INIT RESULTS
  CLEAR et_list.

* BODY
  IF if_reset_buffer = abap_true.
    CALL METHOD reset_buffer( ).
  ENDIF.

  IF if_bypassing_buffer = abap_true.
*   force read bypassing buffer
    SELECT     *
      INTO     TABLE et_list
      FROM     ztexd_flache
      WHERE    ( dienstleistung = id_dienstleistung )
        AND    ( objnr = id_objnr )
        AND    ( meas = id_meas ).
  ELSE.
*   check table buffer for accesses with partial key
    CLEAR ls_acc_partkey_buffer.
    ls_acc_partkey_buffer-_partkey_index = '03'.
    ls_acc_partkey_buffer-dienstleistung = id_dienstleistung.
    ls_acc_partkey_buffer-objnr = id_objnr.
    ls_acc_partkey_buffer-meas = id_meas.
    IF is_partkey_buffered( ls_acc_partkey_buffer ) = abap_false.
*     access not found - read and transfer to buffer
*     read from database with partial key

* Quick Fix Append ORDER BY PRIMARY KEY to the SELECT statement
* 30.04.2024 09:37:29 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*      SELECT     *
*        INTO     TABLE et_list
*        FROM     ztexd_flache
*        WHERE    ( dienstleistung = id_dienstleistung )
*          AND    ( objnr = id_objnr )
*          AND    ( meas = id_meas ).

      SELECT     *
              INTO     TABLE et_list
              FROM     ztexd_flache
              WHERE    ( dienstleistung = id_dienstleistung )
                AND    ( objnr = id_objnr )
                AND    ( meas = id_meas ) ORDER BY PRIMARY KEY .

* End of Quick Fix

      IF sy-subrc = 0.
*       check table buffer boundaries
        IF id_max_buffer_size > 0.
          IF get_buffer_size( ) >= id_max_buffer_size.
            CALL METHOD reset_buffer( ).
          ENDIF.
        ENDIF.
        CALL METHOD transfer_to_buffer
          EXPORTING
            it_list            = et_list
            if_reset_buffer    = abap_false
            id_max_buffer_size = 0.
      ENDIF.
*     add to table buffer for accesses with partial key
      INSERT ls_acc_partkey_buffer INTO TABLE mt_acc_partkey_buffer.
    ELSE.
*     access found - get data from table buffer
      LOOP AT mt_buffer ASSIGNING <ls_buffer>
                        WHERE dienstleistung = id_dienstleistung
                          AND objnr = id_objnr
                          AND meas = id_meas.
        IF <ls_buffer>-_not_found = abap_false.
          MOVE-CORRESPONDING <ls_buffer> TO ls_detail.      "#EC ENHOK
          APPEND ls_detail TO et_list.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD get_list_by_objnr.

  DATA: ls_acc_partkey_buffer LIKE LINE OF mt_acc_partkey_buffer,
        ls_detail             LIKE LINE OF et_list.
  FIELD-SYMBOLS <ls_buffer>   LIKE LINE OF mt_buffer.

* INIT RESULTS
  CLEAR et_list.

* BODY
  IF if_reset_buffer = abap_true.
    CALL METHOD reset_buffer( ).
  ENDIF.

  IF if_bypassing_buffer = abap_true.
*   force read bypassing buffer
    SELECT     *
      INTO     TABLE et_list
      FROM     ztexd_flache
      WHERE    ( dienstleistung = id_dienstleistung )
        AND    ( objnr = id_objnr ).
  ELSE.
*   check table buffer for accesses with partial key
    CLEAR ls_acc_partkey_buffer.
    ls_acc_partkey_buffer-_partkey_index = '02'.
    ls_acc_partkey_buffer-dienstleistung = id_dienstleistung.
    ls_acc_partkey_buffer-objnr = id_objnr.
    IF is_partkey_buffered( ls_acc_partkey_buffer ) = abap_false.
*     access not found - read and transfer to buffer
*     read from database with partial key

* Quick Fix Append ORDER BY PRIMARY KEY to the SELECT statement
* 30.04.2024 09:37:29 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*      SELECT     *
*        INTO     TABLE et_list
*        FROM     ztexd_flache
*        WHERE    ( dienstleistung = id_dienstleistung )
*          AND    ( objnr = id_objnr ).

      SELECT     *
              INTO     TABLE et_list
              FROM     ztexd_flache
              WHERE    ( dienstleistung = id_dienstleistung )
                AND    ( objnr = id_objnr ) ORDER BY PRIMARY KEY .

* End of Quick Fix

      IF sy-subrc = 0.
*       check table buffer boundaries
        IF id_max_buffer_size > 0.
          IF get_buffer_size( ) >= id_max_buffer_size.
            CALL METHOD reset_buffer( ).
          ENDIF.
        ENDIF.
        CALL METHOD transfer_to_buffer
          EXPORTING
            it_list            = et_list
            if_reset_buffer    = abap_false
            id_max_buffer_size = 0.
      ENDIF.
*     add to table buffer for accesses with partial key
      INSERT ls_acc_partkey_buffer INTO TABLE mt_acc_partkey_buffer.
    ELSE.
*     access found - get data from table buffer
      LOOP AT mt_buffer ASSIGNING <ls_buffer>
                        WHERE dienstleistung = id_dienstleistung
                          AND objnr = id_objnr.
        IF <ls_buffer>-_not_found = abap_false.
          MOVE-CORRESPONDING <ls_buffer> TO ls_detail.      "#EC ENHOK
          APPEND ls_detail TO et_list.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD insert_into_all_buffers.

  STATICS:             "for better performance only
    sd_operation TYPE char1,
    sd_tabix     TYPE sytabix.

  FIELD-SYMBOLS:
    <ls_buffer_hl> LIKE LINE OF mt_buffer.

* BODY
* update table data buffer
  IF if_check_existence = abap_false.
    sd_operation = 'I'.
    INSERT is_buffer_hl INTO TABLE mt_buffer.
  ELSE.
    READ TABLE mt_buffer ASSIGNING <ls_buffer_hl>
               WITH TABLE KEY
               dienstleistung = is_buffer_hl-dienstleistung
               objnr = is_buffer_hl-objnr
               meas = is_buffer_hl-meas
               meas_guid = is_buffer_hl-meas_guid
               .
    IF sy-subrc <> 0.
*     entry not found => INSERT
      sd_tabix = sy-tabix.
      sd_operation = 'I'.
      INSERT is_buffer_hl INTO mt_buffer INDEX sd_tabix.
    ELSE.
*     entry found => MODIFY
      sd_tabix = sy-tabix.
      IF <ls_buffer_hl> <> is_buffer_hl.
        sd_operation = 'M'.
        MODIFY mt_buffer FROM is_buffer_hl INDEX sd_tabix.
      ELSE.
        CLEAR sd_operation.
      ENDIF.
    ENDIF.
  ENDIF.

* update other buffers
  IF sd_operation = 'M'.
  ENDIF.

  IF ( is_buffer_hl-_not_found = abap_false ) AND
     ( NOT sd_operation IS INITIAL ).
  ENDIF.

ENDMETHOD.


METHOD is_partkey_buffered.

  DATA:
    ls_acc_partkey LIKE is_acc_partkey_buffer,
    ld_field_index TYPE syindex.

  FIELD-SYMBOLS:
    <ld_field>     TYPE any.

* PRECONDITION
  CHECK mt_acc_partkey_buffer IS NOT INITIAL.

* BODY
  ls_acc_partkey = is_acc_partkey_buffer.
  DO.
    READ TABLE mt_acc_partkey_buffer TRANSPORTING NO FIELDS
               WITH TABLE KEY table_line = ls_acc_partkey.
    IF sy-subrc = 0.
*     access found
      rf_buffered = abap_true.
      EXIT.
    ELSE.
      IF ls_acc_partkey-_partkey_index = '00'.
*       1st key field reached
        EXIT.
      ELSE.
*       try access of previous (general) partial key
        ld_field_index = ls_acc_partkey-_partkey_index + 1.
        ASSIGN COMPONENT ld_field_index
                         OF STRUCTURE ls_acc_partkey
                         TO <ld_field>.
        CLEAR <ld_field>.
        SUBTRACT 1 FROM ls_acc_partkey-_partkey_index.
      ENDIF.
    ENDIF.
  ENDDO.

ENDMETHOD.


METHOD reset_buffer.

* BODY
  CLEAR mt_buffer.
  CLEAR ms_buffer_hl.
  CLEAR mt_acc_partkey_buffer.

ENDMETHOD.


METHOD select_single.

* INIT RESULTS
  CLEAR es_detail.
  ef_not_found = abap_false.

* BODY
* the one and only select for this selection type
*=======================================================================
  SELECT     *
    INTO     es_detail
    FROM     ztexd_flache UP TO 1 ROWS
    WHERE    ( dienstleistung = id_dienstleistung )
      AND    ( objnr = id_objnr )
      AND    ( meas = id_meas )
      AND    ( meas_guid = id_meas_guid )
      .
    EXIT.
  ENDSELECT.
*=======================================================================
  IF sy-subrc <> 0.
    ef_not_found = abap_true.
  ENDIF.

* buffer handling
  IF if_insert_into_buffer = abap_true.
    IF ef_not_found = abap_false.
*     entry found
      MOVE-CORRESPONDING es_detail TO ms_buffer_hl.         "#EC ENHOK
      ms_buffer_hl-_not_found = abap_false.
    ELSE.
*     mark entry as 'not found'
      CLEAR ms_buffer_hl.
      ms_buffer_hl-dienstleistung = id_dienstleistung.
      ms_buffer_hl-objnr = id_objnr.
      ms_buffer_hl-meas = id_meas.
      ms_buffer_hl-meas_guid = id_meas_guid.
      ms_buffer_hl-_not_found = abap_true.
    ENDIF.
*   add entry to table buffer
    CALL METHOD insert_into_all_buffers(
        is_buffer_hl = ms_buffer_hl ).
  ENDIF.

ENDMETHOD.


METHOD transfer_to_buffer.

  DATA:
    ls_acc_partkey_buffer LIKE LINE OF mt_acc_partkey_buffer,
    ld_field_index        TYPE syindex.

  FIELD-SYMBOLS:
    <ls_detail> LIKE is_detail,
    <ld_field>  TYPE any.

* BODY
  IF if_reset_buffer = abap_true.
    CALL METHOD reset_buffer( ).
  ELSE.
*   check table buffer boundaries before transfering data
    IF id_max_buffer_size > 0.
      IF get_buffer_size( ) >= id_max_buffer_size.
        CALL METHOD reset_buffer( ).
      ENDIF.
    ENDIF.
  ENDIF.

  ms_buffer_hl-_not_found = if_as_not_found.
* transfer data from list
  LOOP AT it_list ASSIGNING <ls_detail>.
    MOVE-CORRESPONDING <ls_detail> TO ms_buffer_hl.         "#EC ENHOK
    CALL METHOD insert_into_all_buffers(
        is_buffer_hl       = ms_buffer_hl
        if_check_existence = abap_true ).
  ENDLOOP.
* transfer data from structure
  IF NOT is_detail IS INITIAL.
    MOVE-CORRESPONDING is_detail TO ms_buffer_hl.           "#EC ENHOK
    CALL METHOD insert_into_all_buffers(
        is_buffer_hl       = ms_buffer_hl
        if_check_existence = abap_true ).
  ENDIF.

* buffer access as partial key too
* (so next GET_LIST_BY_... should read from buffer)
  IF ( id_partkey_index >= 0 ) AND ( id_partkey_index <= 9 ).
    IF is_detail IS NOT INITIAL.
      ASSIGN is_detail TO <ls_detail>.
    ELSEIF it_list IS NOT INITIAL.
      READ TABLE it_list INDEX 1 ASSIGNING <ls_detail>.
    ENDIF.
    IF <ls_detail> IS ASSIGNED.
      MOVE-CORRESPONDING <ls_detail> TO ls_acc_partkey_buffer. "#EC ENHOK
      ls_acc_partkey_buffer-_partkey_index = id_partkey_index.
      ld_field_index = id_partkey_index + 2.
      DO.
        ASSIGN COMPONENT ld_field_index
                         OF STRUCTURE ls_acc_partkey_buffer
                         TO <ld_field>.
        IF ( sy-subrc = 0 ) AND ( <ld_field> IS ASSIGNED ).
          CLEAR <ld_field>.
          ADD 1 TO ld_field_index.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
      IF is_partkey_buffered( ls_acc_partkey_buffer ) = abap_false.
        INSERT ls_acc_partkey_buffer INTO TABLE mt_acc_partkey_buffer.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.
