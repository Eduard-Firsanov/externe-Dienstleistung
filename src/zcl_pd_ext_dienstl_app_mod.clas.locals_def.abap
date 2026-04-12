*"* use this source file for any type declarations (class
*"* definitions, interfaces or data types) you need for method
*"* implementation or private method's signature

TYPE-POOLS: icon.


*----------------------------------------------------------------------*
*       CLASS LCL_MOD_EXT_DIENST_ANW
*----------------------------------------------------------------------*
*       Externe Dienstleistung
*----------------------------------------------------------------------*
CLASS lcl_mod_ext_dienst_anw
               DEFINITION INHERITING FROM zcl_pd_ext_dienstl_db_mod.


  PUBLIC SECTION.
    ALIASES:  la_get_commands FOR zif_dpd_tree_object~get_commands,
              la_user_command FOR zif_dpd_tree_object~user_command,
              la_adapt_fieldcatalog FOR zif_dpd_tree_object~adapt_fieldcatalog,
              la_adapt_sort   FOR zif_dpd_tree_object~adapt_sort,
              on_hotspot_click  FOR zif_dpd_tree_object~on_hotspot_click,
              la_button_click FOR zif_dpd_tree_object~button_click.


    METHODS:
      constructor IMPORTING id_start     TYPE flag OPTIONAL
                            id_cust_akt  TYPE sy-ucomm OPTIONAL
                            id_anwendung TYPE char35 OPTIONAL
                            id_akt       TYPE sy-ucomm OPTIONAL,
      zif_dpd_tree_object~get_sub_objects REDEFINITION,
      la_get_commands       REDEFINITION,
      la_user_command       REDEFINITION,
      on_hotspot_click      REDEFINITION,
      refresh               REDEFINITION,
      la_adapt_fieldcatalog REDEFINITION,
      get_selectoptions     REDEFINITION,
      la_adapt_sort         REDEFINITION,
      get_re_objekte.

  PROTECTED SECTION.
    DATA:
      BEGIN OF gs_gui_buffer,
        mo_meas TYPE REF TO zif_pd_ztexd_flache_mngr, " Flächenänderung SAP: Bassistabelle-Manager (ZTEXD_FLACHE)
      END OF gs_gui_buffer.

  PRIVATE SECTION.

    METHODS: refresh_meas
      IMPORTING
                 id_activity TYPE reca1_activity
      EXCEPTIONS error,

      meas_anl
        IMPORTING
                   i_ucomm       TYPE  sy-ucomm
                   it_tabix      TYPE  re_t_tabix
                   it_good_cells TYPE  lvc_t_modi
        EXPORTING
                   cd_refresch   TYPE  flag
        EXCEPTIONS error,

      meas_delete
        IMPORTING
                   i_ucomm       TYPE  sy-ucomm
                   it_tabix      TYPE  re_t_tabix
                   it_good_cells TYPE  lvc_t_modi
        EXPORTING
                   cd_refresch   TYPE  flag
        EXCEPTIONS error,

      meas_set_excel
        IMPORTING
                   i_ucomm       TYPE  sy-ucomm
                   it_tabix      TYPE  re_t_tabix
                   it_good_cells TYPE  lvc_t_modi
        EXPORTING
                   cd_refresch   TYPE  flag
        EXCEPTIONS error,

      set_excel
        IMPORTING
          it_excel       TYPE  z_t_dyn_dta_h
        EXPORTING
          et_excel_uload TYPE z_t_zst_meas_excel_uload, " Ext. Dienstleistung Excel Upload

      meas_dow
        IMPORTING
                   i_ucomm       TYPE  sy-ucomm
                   it_tabix      TYPE  re_t_tabix
                   it_good_cells TYPE  lvc_t_modi
        EXPORTING
                   cd_refresch   TYPE  flag
        EXCEPTIONS error.


    DATA: md_cust_akt  TYPE sy-ucomm,
          md_anwendung TYPE char35,
          md_akt       TYPE sy-ucomm.



ENDCLASS.                    "LCL_MOD_DBT_emod_anw
