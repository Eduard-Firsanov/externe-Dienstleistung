CLASS zcl_pd_ext_dienstl_db_mod DEFINITION
  PUBLIC
  INHERITING FROM zcl_dpd_mod_dbt
  CREATE PUBLIC .

*"* public components of class ZCL_PD_EXT_DIENSTL_DB_MOD
*"* do not include other source files here!!!
  PUBLIC SECTION.
    TYPE-POOLS abap .
    TYPE-POOLS icon .
    TYPE-POOLS reca1 .
    TYPE-POOLS zheiz .

    ALIASES get_attribute
      FOR zif_dpd_tree_object~get_attribute .
    ALIASES get_commands
      FOR zif_dpd_tree_object~get_commands .
    ALIASES get_sub_objects
      FOR zif_dpd_tree_object~get_sub_objects .
    ALIASES user_command
      FOR zif_dpd_tree_object~user_command .

    TYPES:
      ty_t_zdgeraete_id TYPE STANDARD TABLE OF zdgeraete_id .
    TYPES:
      ty_t_heizung TYPE STANDARD TABLE OF zst_heizung_dialog .

    METHODS set_optionen
      IMPORTING
        !is_optionen TYPE zst_heizung_is_optionen .

    METHODS delete_sub_objekt
        REDEFINITION .
    METHODS refresh
        REDEFINITION .
    METHODS zif_dpd_tree_object~user_command
        REDEFINITION .
PROTECTED SECTION.
*"* protected components of class ZCL_PD_EXT_DIENSTL_DB_MOD
*"* do not include other source files here!!!
PRIVATE SECTION.
*"* private components of class ZCL_PD_EXT_DIENSTL_DB_MOD
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_PD_EXT_DIENSTL_DB_MOD IMPLEMENTATION.


METHOD delete_sub_objekt.
*SUPER->DELETE_SUB_OBJEKT(
*    IO_OBJECT = IO_OBJECT
*       ).
ENDMETHOD.


METHOD refresh.

* Datedeklaration für dynamische Select
  DATA:

    lt_seloption           TYPE bapi_re_t_seloption_int,
    ls_seloption           LIKE LINE OF lt_seloption,
    lo_cx_sy_error         TYPE REF TO cx_sy_sql_error,

    lt_field_seloption     TYPE re_st_seloption,
    ls_field_sel_real_from LIKE LINE OF lt_field_seloption,
    ls_field_sel_real_to   LIKE LINE OF lt_field_seloption,
    ls_field_seloption     LIKE LINE OF lt_field_seloption,
    lt_where_clause        TYPE TABLE OF rsdswhere,
    ls_where_range         TYPE REF TO data,
    ls_detail_period       TYPE recadaterange,

    ld_text                TYPE c LENGTH 200.


  FIELD-SYMBOLS:
  <ls_where_range>       TYPE any.


*    CALL METHOD SUPER->REFRESH.
  FIELD-SYMBOLS: <outtab>     TYPE STANDARD TABLE,
                 <table_line> TYPE any.


  ASSIGN me->mdt_outtab->* TO <outtab>.



*   Get Selectoptionen für Dynamischen Select
  lt_seloption = me->get_selectoptions( ).

*
  CALL METHOD cl_reca_bapi_services=>transform_range_to_wheretab
    EXPORTING
      it_seloption    = lt_seloption
      id_structname   = '<LS_WHERE_RANGE>' " actual name of fsymbol
    IMPORTING
      et_where_clause = lt_where_clause
      es_where_range  = ls_where_range
    EXCEPTIONS
      error           = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    RAISE error.
  ENDIF.

*   select from database
  TRY.

      ASSIGN ls_where_range->* TO <ls_where_range>.
      SELECT    *
      FROM    (me->m_tabname)
      INTO CORRESPONDING FIELDS OF TABLE <outtab>
      WHERE   (lt_where_clause).


    CATCH cx_sy_dynamic_osql_semantics INTO lo_cx_sy_error.

      ld_text = lo_cx_sy_error->get_longtext( ).
      MESSAGE e001(recabc)
      WITH ld_text(50) ld_text+50(50) ld_text+100(50) ld_text+150(50)
      RAISING error.

  ENDTRY.





*   provide lookup data from decorators
  IF NOT me->mo_dec_final IS INITIAL.
    me->mo_dec_final->refresh_data( ).
    LOOP AT <outtab> ASSIGNING <table_line>.
      me->mo_dec_final->get_fields(
      CHANGING ch_struc = <table_line> ).
    ENDLOOP.
  ENDIF.

ENDMETHOD.


METHOD set_optionen.
*  MS_OPTIONEN = IS_OPTIONEN.
ENDMETHOD.


METHOD zif_dpd_tree_object~user_command.


  CALL METHOD super->zif_dpd_tree_object~user_command
    EXPORTING
      i_ucomm = i_ucomm.

* Component entwicklung
  CHECK i_ucomm <> zif_dpd_tree_object=>mc_open AND i_ucomm <> zif_dpd_tree_object=>mc_refresh AND i_ucomm <> zif_dpd_tree_object=>mc_save AND
        i_ucomm <> 'CMD_ZIF_DPD_TREE_OBJECT_CLOSE'.



ENDMETHOD.
ENDCLASS.
