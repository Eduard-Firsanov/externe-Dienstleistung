CLASS zcl_cust_zcus_extdirect DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    TYPE-POOLS abap .

    CLASS-METHODS check_key
      IMPORTING
        !id_dienstleistung TYPE zcust_zcus_extdirect-dienstleistung
        !id_ext_dierectory TYPE zcust_zcus_extdirect-ext_dierectory
      EXCEPTIONS
        not_found .
    CLASS-METHODS count
      RETURNING
        VALUE(rd_count) TYPE i .
    CLASS-METHODS exists
      IMPORTING
        !id_dienstleistung TYPE zcust_zcus_extdirect-dienstleistung
        !id_ext_dierectory TYPE zcust_zcus_extdirect-ext_dierectory
      RETURNING
        VALUE(rf_exists)   TYPE abap_bool .
    CLASS-METHODS get_detail
      IMPORTING
        !id_dienstleistung TYPE zcust_zcus_extdirect-dienstleistung
        !id_ext_dierectory TYPE zcust_zcus_extdirect-ext_dierectory
        !id_require        TYPE char1 DEFAULT ' '
      RETURNING
        VALUE(rs_detail)   TYPE zcust_zcus_extdirect
      EXCEPTIONS
        not_found .
    CLASS-METHODS get_detail_x
      IMPORTING
        !id_dienstleistung TYPE zcust_zcus_extdirect-dienstleistung
        !id_ext_dierectory TYPE zcust_zcus_extdirect-ext_dierectory
        !id_langu          TYPE sylangu DEFAULT sy-langu
        !id_xsearch        TYPE char1 DEFAULT '1'
        !id_require        TYPE char1 DEFAULT ' '
      RETURNING
        VALUE(rs_detail_x) TYPE zcust_zcus_extdirect_x
      EXCEPTIONS
        not_found .
    CLASS-METHODS get_list
      IMPORTING
        !id_require TYPE char1 DEFAULT ' '
      EXPORTING
        !et_list    TYPE z_t_zcus_extdirect
      EXCEPTIONS
        not_found .
    CLASS-METHODS get_list_x
      IMPORTING
        !id_langu   TYPE sylangu DEFAULT sy-langu
        !id_xsearch TYPE char1 DEFAULT '1'
        !id_require TYPE char1 DEFAULT ' '
      EXPORTING
        !et_list_x  TYPE z_t_zcus_extdirect_x
      EXCEPTIONS
        not_found .
    CLASS-METHODS get_list_by_dienstleistung
      IMPORTING
        !id_dienstleistung TYPE zcust_zcus_extdirect-dienstleistung
        !id_require        TYPE char1 DEFAULT ' '
      EXPORTING
        !et_list           TYPE z_t_zcus_extdirect
      EXCEPTIONS
        not_found .
    CLASS-METHODS get_list_by_dienstleistung_x
      IMPORTING
        !id_dienstleistung TYPE zcust_zcus_extdirect-dienstleistung
        !id_langu          TYPE sylangu DEFAULT sy-langu
        !id_xsearch        TYPE char1 DEFAULT '1'
        !id_require        TYPE char1 DEFAULT ' '
      EXPORTING
        !et_list_x         TYPE z_t_zcus_extdirect_x
      EXCEPTIONS
        not_found .
    CLASS-METHODS reset_buffer .
    CLASS-METHODS transfer_to_buffer
      IMPORTING
        !it_list TYPE z_t_zcus_extdirect .
PROTECTED SECTION.
PRIVATE SECTION.

  CONSTANTS mc_tabname TYPE tabname VALUE 'ZCUS_EXTDIRECT'. "#EC NOTEXT
  CLASS-DATA mt_buffer TYPE z_t_zcus_extdirect .
  CLASS-DATA ms_buffer_hl TYPE zcust_zcus_extdirect .
  CLASS-DATA mf_buffer_complete TYPE abap_bool .
  CLASS-DATA md_tabix_insert TYPE sytabix .

  CLASS-METHODS _fill_buffer_complete .
  CLASS-METHODS _select_single
    IMPORTING
      !id_dienstleistung TYPE zcust_zcus_extdirect-dienstleistung
      !id_ext_dierectory TYPE zcust_zcus_extdirect-ext_dierectory
    EXCEPTIONS
      not_found .
ENDCLASS.



CLASS ZCL_CUST_ZCUS_EXTDIRECT IMPLEMENTATION.


METHOD check_key.

* BODY
* headerline buffer usable?
  IF ( ms_buffer_hl-dienstleistung = id_dienstleistung ) AND
     ( ms_buffer_hl-ext_dierectory = id_ext_dierectory ) AND
     ( ms_buffer_hl IS NOT INITIAL ).

*   entry found in headerline buffer

  ELSE.

*   search table buffer
    READ TABLE mt_buffer INTO ms_buffer_hl
               WITH KEY dienstleistung = id_dienstleistung
                        ext_dierectory = id_ext_dierectory
               BINARY SEARCH.
    IF sy-subrc = 0.

*     entry found in table buffer

    ELSE.

      md_tabix_insert = sy-tabix.
      CALL METHOD _select_single
        EXPORTING
          id_dienstleistung = id_dienstleistung
          id_ext_dierectory = id_ext_dierectory
        EXCEPTIONS
          not_found         = 1
          OTHERS            = 2.
      IF sy-subrc = 0.
*       entry found in database
      ELSE.
*       entry not found
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                RAISING not_found.
      ENDIF.

    ENDIF.

  ENDIF.

ENDMETHOD.


METHOD count.

* BODY
  IF mf_buffer_complete <> abap_true.
    _fill_buffer_complete( ).
  ENDIF.

  rd_count = lines( mt_buffer ).

ENDMETHOD.


METHOD exists.

* BODY
* headerline buffer usable?
  IF ( ms_buffer_hl-dienstleistung = id_dienstleistung ) AND
     ( ms_buffer_hl-ext_dierectory = id_ext_dierectory ) AND
     ( ms_buffer_hl IS NOT INITIAL ).

*   entry found in headerline buffer
    rf_exists = abap_true.

  ELSE.

*   search table buffer
    READ TABLE mt_buffer INTO ms_buffer_hl
               WITH KEY dienstleistung = id_dienstleistung
                        ext_dierectory = id_ext_dierectory
               BINARY SEARCH.
    IF sy-subrc = 0.

*     entry found in table buffer
      rf_exists = abap_true.

    ELSE.

      md_tabix_insert = sy-tabix.
      CALL METHOD _select_single
        EXPORTING
          id_dienstleistung = id_dienstleistung
          id_ext_dierectory = id_ext_dierectory
        EXCEPTIONS
          not_found         = 1
          OTHERS            = 2.
      IF sy-subrc = 0.
*       entry found in database
        rf_exists = abap_true.
      ENDIF.

    ENDIF.

  ENDIF.

ENDMETHOD.


METHOD get_detail.

* PRECONDITION
  ASSERT id_require CA ' K'.

* BODY
* headerline buffer usable?
  IF ( ms_buffer_hl-dienstleistung = id_dienstleistung ) AND
     ( ms_buffer_hl-ext_dierectory = id_ext_dierectory ) AND
     ( ms_buffer_hl IS NOT INITIAL ).

*   entry found in headerline buffer
    rs_detail = ms_buffer_hl.

  ELSE.

*   search table buffer
    READ TABLE mt_buffer INTO ms_buffer_hl
               WITH KEY dienstleistung = id_dienstleistung
                        ext_dierectory = id_ext_dierectory
               BINARY SEARCH.
    IF sy-subrc = 0.

*     entry found in table buffer
      rs_detail = ms_buffer_hl.

    ELSE.

      md_tabix_insert = sy-tabix.
      CALL METHOD _select_single
        EXPORTING
          id_dienstleistung = id_dienstleistung
          id_ext_dierectory = id_ext_dierectory
        EXCEPTIONS
          not_found         = 1
          OTHERS            = 2.
      IF sy-subrc = 0.
*       entry found in database
        rs_detail = ms_buffer_hl.
      ELSE.
*       entry not found
        IF id_require = 'K'.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  RAISING not_found.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.

ENDMETHOD.


METHOD get_detail_x.

* PRECONDITION
  ASSERT ( id_langu IS NOT INITIAL  ) AND
         ( id_xsearch CA ' 123'     ) AND
         ( id_require CA ' KT'      ).

* BODY
* headerline buffer usable?
  IF ( ms_buffer_hl-dienstleistung = id_dienstleistung ) AND
     ( ms_buffer_hl-ext_dierectory = id_ext_dierectory ) AND
     ( ms_buffer_hl IS NOT INITIAL ).

*   entry found in headerline buffer
    rs_detail_x-zcust_zcus_extdirect = ms_buffer_hl.

  ELSE.

*   search table buffer
    READ TABLE mt_buffer INTO ms_buffer_hl
               WITH KEY dienstleistung = id_dienstleistung
                        ext_dierectory = id_ext_dierectory
               BINARY SEARCH.
    IF sy-subrc = 0.

*     entry found in table buffer
      rs_detail_x-zcust_zcus_extdirect = ms_buffer_hl.

    ELSE.

      md_tabix_insert = sy-tabix.
      CALL METHOD _select_single
        EXPORTING
          id_dienstleistung = id_dienstleistung
          id_ext_dierectory = id_ext_dierectory
        EXCEPTIONS
          not_found         = 1
          OTHERS            = 2.
      IF sy-subrc = 0.
*       entry found in database
        rs_detail_x-zcust_zcus_extdirect = ms_buffer_hl.
      ELSE.
*       entry not found
        IF id_require CA 'KT'.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  RAISING not_found.
        ELSE.
          RETURN.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDIF.

ENDMETHOD.


METHOD get_list.

* PRECONDITION
  ASSERT id_require CA ' L'.

* BODY
* complete buffer
  IF mf_buffer_complete <> abap_true.
    _fill_buffer_complete( ).
  ENDIF.

* copy table buffer
  IF mt_buffer IS NOT INITIAL.
    et_list[] = mt_buffer[].
  ELSE.
*   empty list
    CLEAR et_list.
    IF id_require = 'L'.
      MESSAGE e013(recabc)
              WITH TEXT-001 '' '' mc_tabname
              RAISING not_found.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD get_list_by_dienstleistung.

  FIELD-SYMBOLS:
    <ls_buffer> LIKE LINE OF mt_buffer.

* INIT RESULTS
  CLEAR et_list.

* PRECONDITION
  ASSERT id_require CA ' L'.

* BODY
* complete buffer
  IF mf_buffer_complete <> abap_true.
    _fill_buffer_complete( ).
  ENDIF.

* get first entry
  READ TABLE mt_buffer TRANSPORTING NO FIELDS
             WITH KEY dienstleistung = id_dienstleistung
             BINARY SEARCH.
  IF sy-subrc = 0.
*   copy relevant set of entries
    LOOP AT mt_buffer ASSIGNING <ls_buffer> FROM sy-tabix.
      IF <ls_buffer>-dienstleistung <> id_dienstleistung.
        EXIT.
      ENDIF.
      APPEND <ls_buffer> TO et_list.
    ENDLOOP.
  ELSE.
*   empty list
    IF id_require = 'L'.
      sy-msgv2 = id_dienstleistung.
      MESSAGE e014(recabc)
              WITH TEXT-001 sy-msgv2 space mc_tabname
              RAISING not_found.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD get_list_by_dienstleistung_x.

  DATA:
    ls_detail_x LIKE LINE OF et_list_x.

  FIELD-SYMBOLS:
    <ls_detail> LIKE LINE OF mt_buffer.

* INIT RESULTS
  CLEAR et_list_x.

* PRECONDITION
  ASSERT ( id_langu IS NOT INITIAL ) AND
         ( id_xsearch CA ' 123'    ) AND
         ( id_require CA ' L'      ).

* BODY
* complete buffer
  IF mf_buffer_complete <> abap_true.
    _fill_buffer_complete( ).
  ENDIF.

* get first entry
  READ TABLE mt_buffer TRANSPORTING NO FIELDS
             WITH KEY dienstleistung = id_dienstleistung
             BINARY SEARCH.
  IF sy-subrc = 0.
*   copy relevant set of entries and complete additional data
    LOOP AT mt_buffer ASSIGNING <ls_detail> FROM sy-tabix.
      IF ( <ls_detail>-dienstleistung <> id_dienstleistung ).
        EXIT.
      ELSE.
        ls_detail_x-zcust_zcus_extdirect = <ls_detail>.
        APPEND ls_detail_x TO et_list_x.
      ENDIF.
    ENDLOOP.
  ELSE.
*   empty list
    IF id_require = 'L'.
      sy-msgv2 = id_dienstleistung.
      MESSAGE e014(recabc)
              WITH TEXT-001 sy-msgv2 space mc_tabname
              RAISING not_found.
    ENDIF.
  ENDIF.

ENDMETHOD.


METHOD get_list_x.

  DATA:
    ls_detail_x LIKE LINE OF et_list_x.

  FIELD-SYMBOLS:
    <ls_detail> LIKE LINE OF mt_buffer.

* INIT RESULTS
  CLEAR et_list_x.

* PRECONDITION
  ASSERT ( id_langu IS NOT INITIAL ) AND
         ( id_xsearch CA ' 123'    ) AND
         ( id_require CA ' L'      ).

* BODY
* complete buffer
  IF mf_buffer_complete <> abap_true.
    _fill_buffer_complete( ).
  ENDIF.

* copy table buffer and complete additional data
  LOOP AT mt_buffer ASSIGNING <ls_detail>.
    ls_detail_x-zcust_zcus_extdirect = <ls_detail>.
    APPEND ls_detail_x TO et_list_x.
  ENDLOOP.

  IF ( et_list_x IS INITIAL ) AND
     ( id_require = 'L'     ).
*   empty list
    MESSAGE e013(recabc)
            WITH TEXT-001 '' '' mc_tabname
            RAISING not_found.
  ENDIF.

ENDMETHOD.


METHOD reset_buffer.

* BODY
  CLEAR mt_buffer.
  CLEAR ms_buffer_hl.
  mf_buffer_complete = abap_false.

ENDMETHOD.


METHOD transfer_to_buffer.

  DATA:
    lt_list_temp LIKE it_list.

* BODY
  reset_buffer( ).

  IF it_list IS NOT INITIAL.
    IF lines( it_list ) = 1.
      mt_buffer[] = it_list[].
    ELSE.
      lt_list_temp[] = it_list[].
      SORT lt_list_temp BY dienstleistung
                           ext_dierectory
                           .
      DELETE ADJACENT DUPLICATES FROM lt_list_temp
                 COMPARING dienstleistung
                           ext_dierectory
                           .
      mt_buffer[] = lt_list_temp[].
    ENDIF.
  ENDIF.

  mf_buffer_complete = abap_true.

ENDMETHOD.


METHOD _fill_buffer_complete.

* PRECONDITION
  CHECK mf_buffer_complete <> abap_true.

* BODY
* read from database
  SELECT     *
    INTO     CORRESPONDING FIELDS OF TABLE mt_buffer
    FROM     zcus_extdirect.          "#EC CI_SGLSELECT "#EC CI_GENBUFF

* sort separately (data source may be a view)
  SORT mt_buffer BY dienstleistung
                    ext_dierectory
                    .
  mf_buffer_complete = abap_true.

ENDMETHOD.


METHOD _select_single.

* BODY
  IF mf_buffer_complete <> abap_true.

*   read from database
    SELECT     SINGLE *
      INTO     CORRESPONDING FIELDS OF ms_buffer_hl
      FROM     zcus_extdirect
      WHERE  ( dienstleistung = id_dienstleistung )
        AND  ( ext_dierectory = id_ext_dierectory )
        .
    IF sy-subrc = 0.
*     insert into buffer
      INSERT ms_buffer_hl INTO mt_buffer INDEX md_tabix_insert.
      RETURN.
    ENDIF.

  ENDIF.

* not found (not buffered!)
  CONCATENATE id_dienstleistung
              id_ext_dierectory
              space              "for technical reason only
              INTO sy-msgv2 SEPARATED BY space.
  MESSAGE e010(recabc)
          WITH TEXT-001 sy-msgv2 '' mc_tabname
          RAISING not_found.

ENDMETHOD.
ENDCLASS.
