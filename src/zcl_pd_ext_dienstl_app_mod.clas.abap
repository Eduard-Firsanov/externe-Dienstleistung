CLASS zcl_pd_ext_dienstl_app_mod DEFINITION
  PUBLIC
  CREATE PROTECTED .

*"* public components of class ZCL_PD_EXT_DIENSTL_APP_MOD
*"* do not include other source files here!!!
  PUBLIC SECTION.

    CLASS-METHODS get_app_mod
      RETURNING
        VALUE(ro_app_mod) TYPE REF TO zcl_pd_ext_dienstl_app_mod .
    INTERFACE zif_dpd_tree_object LOAD .
    METHODS add_tree_objects
      IMPORTING
        !it_objects TYPE zif_dpd_tree_object=>ty_t_objects .
    METHODS get_tree_object
      IMPORTING
        !i_node_key      TYPE node_str-node_key
      RETURNING
        VALUE(ro_object) TYPE REF TO zif_dpd_tree_object .
    METHODS get_tree_objects
      RETURNING
        VALUE(rt_objects) TYPE zif_dpd_tree_object=>ty_t_objects .
    METHODS constructor .
    METHODS get_sub_object
      IMPORTING
        !id_subtype      TYPE zdsubtype DEFAULT 'W'
        !it_main_where   TYPE ddbt_val OPTIONAL
      RETURNING
        VALUE(ro_object) TYPE REF TO zif_dpd_tree_object
      EXCEPTIONS
        error .
PROTECTED SECTION.
*"* protected components of class ZCL_PD_EXT_DIENSTL_APP_MOD
*"* do not include other source files here!!!
PRIVATE SECTION.
*"* private components of class ZCL_PD_EXT_DIENSTL_APP_MOD
*"* do not include other source files here!!!

  INTERFACE zif_dpd_tree_object LOAD .
  DATA mt_active_objects TYPE zif_dpd_tree_object=>ty_t_objects .
  CLASS-DATA mo_app_mod TYPE REF TO zcl_pd_ext_dienstl_app_mod .
ENDCLASS.



CLASS ZCL_PD_EXT_DIENSTL_APP_MOD IMPLEMENTATION.


METHOD add_tree_objects.
  APPEND LINES OF it_objects TO me->mt_active_objects.
ENDMETHOD.


METHOD constructor.


  DATA: lo_ext_dienst      TYPE REF TO
                              lcl_mod_ext_dienst_anw.


* Info zur Wartung
  CREATE OBJECT lo_ext_dienst
    EXPORTING
      id_start = abap_true.
  APPEND lo_ext_dienst TO me->mt_active_objects.







ENDMETHOD.


METHOD get_app_mod.
* create application
  IF zcl_pd_ext_dienstl_app_mod=>mo_app_mod IS INITIAL.
    CREATE OBJECT zcl_pd_ext_dienstl_app_mod=>mo_app_mod.
  ENDIF.
  ro_app_mod = zcl_pd_ext_dienstl_app_mod=>mo_app_mod.

ENDMETHOD.


METHOD get_sub_object.
* redifinition und implementiereung in Subklassen
ENDMETHOD.


METHOD get_tree_object.
  READ TABLE me->mt_active_objects INTO ro_object
    WITH KEY table_line->ms_node-node_key = i_node_key.
ENDMETHOD.


METHOD get_tree_objects.
  rt_objects = me->mt_active_objects.
ENDMETHOD.
ENDCLASS.
