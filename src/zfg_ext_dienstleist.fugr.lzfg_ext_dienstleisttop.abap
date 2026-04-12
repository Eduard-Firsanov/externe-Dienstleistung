FUNCTION-POOL zfg_ext_dienstleist         MESSAGE-ID zheizung.

TYPE-POOLS: reca1.

INCLUDE: ifrecaalv,ifrecamsg,
         zpr_pdmis_show_bild_top,
         ifreis_ca_range.

DATA gs_subscreen        TYPE recascreen.
DATA: gd_okcode TYPE sy-ucomm,
*             calling program
      gd_repid  TYPE syrepid.

DATA: g_subscreen_dynnr TYPE sy-dynnr,
      g_gui_status      TYPE gui_status,
      gs_optionen       TYPE zst_heizung_is_optionen,
      gt_heizung        TYPE z_t_zst_heizung_is.


* Selektionsbild für Immobilienobjekte
INCLUDE zin_objekt_selection.


DATA:
      go_msglist       TYPE REF TO if_reca_message_list.

*----------------------------------------------------------------------*
*       CLASS lcl_con_dynpro_screen DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_con_dynpro_screen DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING i_model       TYPE REF TO zif_dpd_tree_object
                  i_new_status  TYPE sy-pfkey
                  i_new_dynnr   TYPE sy-dynnr
                  i_main_dynnr  TYPE sy-dynnr
                  i_main_status TYPE sy-pfkey,
      pai
        IMPORTING i_ucomm TYPE sy-ucomm
                  i_data  TYPE any,
      pbo
        EXPORTING e_data TYPE any.
    CLASS-METHODS:
      create_controller
        IMPORTING i_model       TYPE REF TO zif_dpd_tree_object
                  i_new_status  TYPE sy-pfkey
                  i_new_dynnr   TYPE sy-dynnr
                  i_main_dynnr  TYPE sy-dynnr
                  i_main_status TYPE sy-pfkey,
      class_pai
        IMPORTING i_dynnr TYPE sy-dynnr
                  i_ucomm TYPE sy-ucomm
                  i_data  TYPE any,
      class_pbo
        IMPORTING i_dynnr TYPE sy-dynnr
        EXPORTING e_data  TYPE any.
  PRIVATE SECTION.
    DATA:
      m_title           TYPE text100,
      mo_model          TYPE REF TO zif_dpd_tree_object,
      mdt_outtab        TYPE REF TO data,
      m_dynnr_main      TYPE sy-dynnr,
      m_gui_status_main TYPE sy-pfkey.
    TYPES:
      BEGIN OF mty_screen_controllers,
        dynnr        TYPE sy-dynnr,
        o_controller TYPE REF TO lcl_con_dynpro_screen,
      END OF mty_screen_controllers.
    CLASS-DATA:
          mt_scr_contr TYPE SORTED TABLE OF
          mty_screen_controllers
          WITH UNIQUE KEY dynnr.
ENDCLASS.                    "lcl_con_dynpro_screen DEFINITION
*------------------------------------------------------------*
*       CLASS lcl_con_alv DEFINITION
*------------------------------------------------------------*
*
*------------------------------------------------------------*
CLASS lcl_con_alv DEFINITION.

  PUBLIC SECTION.

    METHODS: constructor IMPORTING
                           i_model     TYPE REF TO zif_dpd_tree_object
                           id_activity TYPE reca1_activity OPTIONAL.

    EVENTS: data_changed      EXPORTING VALUE(e_modified) TYPE flag.

  PROTECTED SECTION.
    DATA:
      mo_alv        TYPE REF TO cl_gui_alv_grid,
      mo_container  TYPE REF TO cl_gui_docking_container,
      mdt_outtab    TYPE REF TO data,
      m_title       TYPE text100,
      m_disp_str    TYPE tabname,
      m_tabname     TYPE tabname,
      mo_model      TYPE REF TO zif_dpd_tree_object, " Heizung Model für DB bearbeitung
      md_modified	  TYPE	char01,
      mt_good_cells TYPE  lvc_t_modi.

    DATA: md_activity  TYPE reca1_activity.
    METHODS:
      on_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,

      handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row
                  e_column,
      on_data_changed FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING e_modified
                  et_good_cells,
      on_data_changed_prot FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed,
      on_user_command FOR EVENT user_command
        OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      on_menu_button FOR EVENT menu_button OF cl_gui_alv_grid
        IMPORTING e_object
                  e_ucomm,
      on_hotspot_click FOR EVENT hotspot_click
        OF cl_gui_alv_grid
        IMPORTING es_row_no
                  e_column_id,
      on_before_user_command FOR EVENT before_user_command
        OF cl_gui_alv_grid
        IMPORTING
          e_ucomm,
      free,
      vertrag_notiz_edit,
      get_fcat IMPORTING i_disp_struc_name TYPE c
                         i_dbtab           TYPE c
               EXPORTING et_fcat           TYPE lvc_t_fcat,

      get_layout  IMPORTING i_disp_struc_name TYPE c
                  EXPORTING es_layout         TYPE lvc_s_layo,

      get_excluding_functions
        EXPORTING et_excluding TYPE  ui_functions.

    METHODS:   set_variant IMPORTING id_variant TYPE disvariant-variant
                                     id_handle  TYPE disvariant-handle OPTIONAL
                                     id_report  TYPE disvariant-report DEFAULT  sy-cprog
                           EXPORTING es_variant TYPE disvariant.

ENDCLASS.                    "lcl_con_alv DEFINITION

*------------------------------------------------------------*
*       CLASS lcl_con_dd DEFINITION
*------------------------------------------------------------*
*
*------------------------------------------------------------*
CLASS lcl_con_dd
DEFINITION.
  PUBLIC SECTION.
    METHODS: constructor IMPORTING
                           i_model TYPE REF TO zif_dpd_tree_object.
  PRIVATE SECTION.
    DATA:
      mo_dd        TYPE REF TO cl_dd_document,
      mo_container TYPE REF TO cl_gui_docking_container,
      mdt_outtab   TYPE REF TO data,
      m_title      TYPE text100,
      m_disp_str   TYPE tabname,
      m_tabname    TYPE tabname,
      mo_model     TYPE REF TO zif_dpd_tree_object.
    METHODS:
      on_clicked FOR EVENT clicked
        OF cl_dd_button_element
        IMPORTING sender,
      refresh_display,
      free,
      get_fcat   IMPORTING i_disp_struc_name TYPE c
                           i_dbtab           TYPE c
                 EXPORTING et_fcat           TYPE lvc_t_fcat.
ENDCLASS.                    "lcl_con_dd DEFINITION


*------------------------------------------------------------*
* CLASS lcl_con_empty_containers
*------------------------------------------------------------*
CLASS lcl_con_empty_containers DEFINITION.
  PUBLIC SECTION.
    METHODS: constructor IMPORTING
                           i_model TYPE REF TO zif_dpd_tree_object,
      on_clicked
        FOR EVENT clicked
        OF cl_dd_button_element
        IMPORTING sender.
    DATA: o_dd      TYPE REF TO cl_dd_document,
          container TYPE REF TO cl_gui_docking_container.
ENDCLASS.                    "lcl_view DEFINITION



















































*------------------------------------------------------------*
*       CLASS lcl_view IMPLEMENTATION
*------------------------------------------------------------*
*
*------------------------------------------------------------*
CLASS lcl_con_empty_containers IMPLEMENTATION.
*-------------- on_clicked
  METHOD on_clicked.
    DATA: lo_button TYPE REF TO cl_dd_button_element.
    lo_button = sender.
    CASE lo_button->name.
      WHEN 'CLOSE'.
        zcl_dpd_dock_container_factory=>destroy_container(
        me->container ).
        CLEAR me->container.
    ENDCASE.
  ENDMETHOD.                    "on_clicked

*-------------- constructor
  METHOD constructor.
    DATA: lo_form      TYPE REF TO cl_dd_form_area,
          lo_button    TYPE REF TO cl_dd_button_element,
          l_caption    TYPE sdydo_text_element,
          l_count_char TYPE char10,
          lo_data      TYPE REF TO data,
          l_side       TYPE i.
*   get attributes from the model
    i_model->get_attribute(
    EXPORTING i_name  = 'M_SIDE'
    IMPORTING e_value = l_side ).
    i_model->get_attribute(
    EXPORTING i_name  = 'M_CAPTION'
    IMPORTING e_value = l_caption ).
*   get new container from factory
    me->container =
    zcl_dpd_dock_container_factory=>get_container( l_side ).
*   create caption text (use container counter too)
    l_count_char = zcl_dpd_dock_container_factory=>m_count.
    CONCATENATE l_caption ' #' l_count_char INTO l_caption.
    CONDENSE l_caption.
    CREATE OBJECT me->o_dd.
*   display DD in the new container
    me->o_dd->display_document( parent = me->container ).
    me->o_dd->add_form( IMPORTING formarea = lo_form ).
    lo_form->add_button( EXPORTING sap_icon = 'ICON_CLOSE'
      name     = 'CLOSE'
    IMPORTING button   = lo_button ).
    lo_form->add_text( text      = l_caption
    sap_style = 'heading' ).
    SET HANDLER me->on_clicked FOR lo_button.
    me->o_dd->merge_document( ).
    me->o_dd->display_document( reuse_control = 'X' ).
  ENDMETHOD.                    "constructor
ENDCLASS.                    "lcl_view IMPLEMENTATION

*------------------------------------------------------------*
*       CLASS lcl_main_program
*------------------------------------------------------------*
*
*------------------------------------------------------------*
CLASS lcl_main_program DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS: run_main_program.
    METHODS: constructor.
  PRIVATE SECTION.
    DATA:
      mo_tree    TYPE REF TO cl_gui_simple_tree,
      mo_app_mod TYPE REF TO zcl_pd_ext_dienstl_app_mod,
      md_changed TYPE char1.
    CLASS-DATA:
          mo_main_program TYPE REF TO lcl_main_program.

    METHODS: on_double_click
      FOR EVENT node_double_click
      OF cl_gui_simple_tree
      IMPORTING node_key,
      on_expand_no_children
        FOR EVENT expand_no_children
        OF cl_gui_simple_tree
        IMPORTING node_key,
      on_menu_request
        FOR EVENT node_context_menu_request
        OF cl_gui_simple_tree
        IMPORTING menu node_key,
      on_menu_select
        FOR EVENT node_context_menu_select
        OF cl_gui_simple_tree
        IMPORTING node_key fcode,
      on_data_changed FOR EVENT data_changed OF lcl_con_alv
        IMPORTING e_modified.
ENDCLASS.                    "lcl_main_program
*------------------------------------------------------------*
*       CLASS lcl_main_program IMPLEMENTATION
*------------------------------------------------------------*
*
*------------------------------------------------------------*
CLASS lcl_main_program IMPLEMENTATION.
*--------------------------- run_main_program
  METHOD run_main_program.
    IF lcl_main_program=>mo_main_program IS INITIAL.
      CREATE OBJECT lcl_main_program=>mo_main_program.
    ENDIF.
  ENDMETHOD.                    "run_main_program

*--------------------------- constructor
  METHOD constructor.
    DATA:
      l_event         TYPE cntl_simple_event,
      lt_events       TYPE cntl_simple_events,
      lt_tree_nodes   TYPE STANDARD TABLE OF node_str,
      ls_node_key     TYPE tv_nodekey,
      lt_tree_objects TYPE TABLE OF REF TO zif_dpd_tree_object,
      lo_container    TYPE REF TO cl_gui_docking_container,
      lo_object       TYPE REF TO zif_dpd_tree_object.      "#EC NEEDED

*------ get MVC model
    me->mo_app_mod = zcl_pd_ext_dienstl_app_mod=>get_app_mod(
               ).
*------ create container and tree
    CREATE OBJECT lo_container
      EXPORTING
        extension = 350
        side      = lo_container->dock_at_left.
    CREATE OBJECT me->mo_tree
      EXPORTING
        parent              = lo_container
        node_selection_mode = mo_tree->node_sel_mode_single.
*   register events
    l_event-eventid =
    cl_gui_column_tree=>eventid_node_double_click.
    APPEND l_event TO lt_events.
    l_event-eventid =
    cl_gui_column_tree=>eventid_expand_no_children.
    APPEND l_event TO lt_events.
    l_event-eventid =
    cl_gui_column_tree=>eventid_node_context_menu_req.
    APPEND l_event TO lt_events.
    me->mo_tree->set_registered_events( lt_events ).
    SET HANDLER: me->on_double_click       FOR me->mo_tree,
    me->on_expand_no_children FOR me->mo_tree,
    me->on_menu_request       FOR me->mo_tree,
    me->on_menu_select        FOR me->mo_tree.

*------ create nodes
    lt_tree_objects = me->mo_app_mod->get_tree_objects( ).
    LOOP AT lt_tree_objects INTO lo_object.

      IF ls_node_key IS INITIAL.
        ls_node_key = lo_object->ms_node-node_key.
      ENDIF.

      APPEND lo_object->ms_node TO lt_tree_nodes.

    ENDLOOP.

    me->mo_tree->add_nodes(
    EXPORTING node_table           = lt_tree_nodes
      table_structure_name = 'NODE_STR' ).

    me->on_expand_no_children( ls_node_key ).

    "   Expand Flächenänderung
    me->on_expand_no_children( 'MEAS' ).

    me->mo_tree->expand_root_nodes(
        EXPORTING
          level_count         = 0
          expand_subtree      = abap_true
        EXCEPTIONS
          failed              = 1
          illegal_level_count = 2
          cntl_system_error   = 3
          OTHERS              = 4
             ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF ls_node_key IS NOT INITIAL AND 1 = 2.

      lo_object = me->mo_app_mod->get_tree_object( ls_node_key ).

      IF lo_object IS BOUND.
        lo_object->user_command( zif_dpd_tree_object=>mc_open ).

        CALL METHOD me->mo_tree->expand_node
          EXPORTING
            node_key    = ls_node_key
            level_count = 1.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "constructor

*--------------------------- on_menu_request
  METHOD on_menu_request.
    DATA:
      l_text     TYPE gui_text,
      ld_icon    TYPE icon_d,
      lo_object  TYPE REF TO zif_dpd_tree_object,
      ld_tabname TYPE tabname.




    CHECK node_key NP 'EC*'. "we dont' want empty containers


    IF sy-subrc = 0.

      lo_object = me->mo_app_mod->get_tree_object( node_key ).

      lo_object->get_attribute(
       EXPORTING i_name  = 'M_TABNAME'
       IMPORTING e_value = ld_tabname ).

      CASE ld_tabname.
        WHEN 'ZTKUEVERTRAG'.
          l_text = 'Heizanlage zum KÜO-Vertrag bearbeiten'.
          ld_icon = '@0Z@'.
          menu->add_function( fcode = zheiz_eink_aktion-mc_edit_conect_k
          icon  = ld_icon
          text  = l_text
          ).
          l_text = 'Heizanlage zum KÜO-Vertrag anzeigen'.
          ld_icon = '@0Z@'.
          menu->add_function( fcode = zheiz_eink_aktion-mc_anz_conect_k
          icon  = ld_icon
          text  = l_text
          ).
        WHEN 'ZTWRTVERTRAG'.
          l_text = 'Heizanlage zum Wart.-Vertrag bearbeiten'.
          ld_icon = '@0Z@'.
          menu->add_function( fcode = zheiz_eink_aktion-mc_edit_conect_w
          icon  = ld_icon
          text  = l_text
          ).
          l_text = 'Heizanlage zum Wart.-Vertrag anzeigen'.
          ld_icon = '@0Z@'.
          menu->add_function( fcode = zheiz_eink_aktion-mc_anz_conect_w
          icon  = ld_icon
          text  = l_text
          ).
        WHEN OTHERS.
          RETURN.
      ENDCASE.
    ENDIF.
  ENDMETHOD.                    "on_menu_request

*--------------------------- on_double_click
  METHOD on_double_click.

    DATA:
      lo_con_alv   TYPE REF TO lcl_con_alv,
      lo_empty_con TYPE REF TO lcl_con_empty_containers,
      lo_object_db TYPE REF TO zcl_pd_modernisierung_app_mod,
      lo_object    TYPE REF TO zif_dpd_tree_object,
      io_gmod_mod  TYPE REF TO  zcl_pd_modernisierung_db_mod.
*    DATA: LO_CONT_TRG TYPE REF TO CL_GUI_DOCKING_CONTAINER. "#EC NEEDED
*    DATA: LT_RSPARAMS TYPE STANDARD TABLE OF RSPARAMS,
*          LS_RSPARAMS TYPE RSPARAMS.

    lo_object = me->mo_app_mod->get_tree_object( node_key ).

    IF lo_object IS BOUND.
******************************************************************************************
      IF lo_object->ms_node-node_key CP 'DIENST_CUST'.
        CALL TRANSACTION 'ZTR_CUST_DIENST'.

******************************************************************************************


      ELSEIF lo_object->ms_node-node_key+5(5) CP 'ANL'  OR
             lo_object->ms_node-node_key+5(5) CP 'ANZ'  OR
             lo_object->ms_node-node_key+5(5) CP 'AEND' OR
             lo_object->ms_node-node_key+5(5) CP 'SET'  OR
             lo_object->ms_node-node_key+5(5) CP 'UPL'  OR
             lo_object->ms_node-node_key+5(5) CP 'DOW'  OR
             lo_object->ms_node-node_key+5(5) CP 'HELP_' .

        IF 1 = 2. " E.Firsanov umstig auf GUI-FB

          lo_object->user_command( zif_dpd_tree_object=>mc_open ).

*         Alle Kontainer löschen
          zcl_dpd_dock_container_factory=>hide_all( ).
          gs_subscreen-dynnr = '0200'.
          g_gui_status      = 'MAIN'.

*        generic ALV controller for DBT (database table) models
          CREATE OBJECT lo_con_alv
            EXPORTING
              i_model     = lo_object
              id_activity = reca1_activity-change.

          SET HANDLER me->on_data_changed FOR lo_con_alv.

          LEAVE TO SCREEN 100.

        ELSE.
          DATA id_activity         TYPE sy-ucomm.

          id_activity = lo_object->ms_node-node_key.

          CALL FUNCTION 'ZFB_GUI_EXT_LEIST_PBO'
            EXPORTING
              id_activity  = id_activity
*             IF_READONLY  = IF_READONLY
            IMPORTING
              es_subscreen = gs_subscreen.

          LEAVE TO SCREEN 100.

        ENDIF.
******************************************************************************************
      ELSE.


      ENDIF.

    ENDIF.

  ENDMETHOD.                    "on_double_click

*--------------------------- on_menu_select.
  METHOD on_menu_select.

    DATA:
      lo_con_alv       TYPE REF TO lcl_con_alv,
      lo_empty_con     TYPE REF TO lcl_con_empty_containers, "#EC NEEDED
      lo_object        TYPE REF TO zif_dpd_tree_object,
      lo_sub_obj       TYPE REF TO zif_dpd_tree_object,
      lo_object_sub_db TYPE REF TO zcl_pd_bw_db_mod,
      lo_object_db     TYPE REF TO zcl_pd_bw_db_mod.
    DATA: lo_cont_trg  TYPE REF TO cl_gui_docking_container. "#EC NEEDED
    DATA: mt_main_where TYPE ddbt_val,
          ld_activity   TYPE reca1_activity VALUE '03'.


    g_subscreen_dynnr = '0200'.
    g_gui_status      = 'MAIN'.





    lo_object = me->mo_app_mod->get_tree_object( node_key ).

    IF lo_object IS BOUND.
      lo_object->user_command( zif_dpd_tree_object=>mc_open ).
    ELSE.
      RETURN.
    ENDIF.

*   Alle Kontainer löschen
    zcl_dpd_dock_container_factory=>hide_all( ).

*   generic ALV controller for DBT (database table) models
    CREATE OBJECT lo_con_alv
      EXPORTING
        i_model     = lo_object
        id_activity = reca1_activity-change.



    CASE fcode.
      WHEN zheiz_eink_aktion-mc_edit_conect_w.

        lo_object->get_attribute(
        EXPORTING i_name  = 'MT_MAIN_WHERE'
        IMPORTING e_value = mt_main_where ).


        me->mo_app_mod->get_sub_object(
        EXPORTING
          id_subtype    = 'W'
          it_main_where = mt_main_where
          RECEIVING
          ro_object     = lo_sub_obj
        EXCEPTIONS
          error         = 1
          OTHERS        = 2
          ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

*      Set Activity
        ld_activity = reca1_activity-change.

      WHEN zheiz_eink_aktion-mc_anz_conect_w.

        lo_object->get_attribute(
         EXPORTING i_name  = 'MT_MAIN_WHERE'
         IMPORTING e_value = mt_main_where ).


        me->mo_app_mod->get_sub_object(
        EXPORTING
          id_subtype    = 'W'
          it_main_where = mt_main_where
        RECEIVING
          ro_object     = lo_sub_obj
        EXCEPTIONS
          error         = 1
          OTHERS        = 2
          ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      WHEN zheiz_eink_aktion-mc_edit_conect_k.
*     Set Activity
        ld_activity = reca1_activity-change.
      WHEN zheiz_eink_aktion-mc_anz_conect_k.
    ENDCASE.


    CHECK   lo_sub_obj IS BOUND.

    lo_sub_obj->user_command( zif_dpd_tree_object=>mc_open ).

*   Set Info-Optionen
    lo_object_sub_db ?= lo_sub_obj.
    lo_object_sub_db->set_optionen( is_optionen = gs_optionen   ).

*  Set Subobjek dem Parent
    lo_object_db ?= lo_object.
    lo_object_db->set_save_refresh( io_object = lo_object_sub_db ).

*  Set Parent dem dem Subobjekt
    lo_object_db ?= lo_object.
    lo_object_sub_db->set_save_refresh( io_object = lo_object_db ).


*   generic ALV controller for DBT (database table) models
    CREATE OBJECT lo_con_alv
      EXPORTING
        i_model     = lo_sub_obj
        id_activity = ld_activity.

    LEAVE TO SCREEN 100.
  ENDMETHOD.                    "on_menu_select

*--------------------------- on_expand_no_children
  METHOD on_expand_no_children.
    DATA:
      lt_new_objects TYPE zif_dpd_tree_object=>ty_t_objects,
      lt_new_nodes   TYPE TABLE OF node_str,
      lo_object      TYPE REF TO zif_dpd_tree_object.
*   find the corresponding MVC model object
    lo_object = me->mo_app_mod->get_tree_object( node_key ).
    IF NOT sy-subrc = 0. EXIT. ENDIF.
*   get the object's children (subobjects)
    lt_new_objects = lo_object->get_sub_objects( ).
*   append new objects to the objects table attribute
    me->mo_app_mod->add_tree_objects( lt_new_objects ).
*   append new nodes to the command tree
    LOOP AT lt_new_objects INTO lo_object.
      APPEND: lo_object->ms_node TO lt_new_nodes.
    ENDLOOP.
    me->mo_tree->add_nodes(
    table_structure_name = 'NODE_STR'
    node_table           = lt_new_nodes ).
  ENDMETHOD.                    "on_expand_no_children

  METHOD on_data_changed.

    md_changed = e_modified.

  ENDMETHOD.                    "ON_DATA_CHANGED
ENDCLASS.                 "lcl_main_program IMPLEMENTATION

*------------------------------------------------------------*
*       CLASS lcl_con_alv IMPLEMENTATION
*------------------------------------------------------------*
*
*------------------------------------------------------------*
*------------------------------------------------------------*
*       CLASS lcl_con_alv IMPLEMENTATION
*------------------------------------------------------------*
*
*------------------------------------------------------------*
CLASS lcl_con_alv IMPLEMENTATION.
*---------------- constructor
  METHOD constructor.
    DATA:
      ls_layout            TYPE lvc_s_layo,
      lo_data              TYPE REF TO data,
      lt_fcat              TYPE lvc_t_fcat,
      lt_sort              TYPE  lvc_t_sort,
      ls_variant           TYPE disvariant,
      lt_toolbar_excluding TYPE  ui_functions.


    FIELD-SYMBOLS:
    <t_outtab>        TYPE STANDARD TABLE.
    me->mo_model = i_model.
*   get model's attributes
    i_model->get_attribute(
    EXPORTING i_name  = 'M_DISP_STRUC_NAME'
    IMPORTING e_value = me->m_disp_str ).
    i_model->get_attribute(
    EXPORTING i_name  = 'M_TABNAME'
    IMPORTING e_value = me->m_tabname ).
    i_model->get_attribute(
    EXPORTING i_name  = 'M_CAPTION'
    IMPORTING e_value = me->m_title ).
    i_model->get_attribute(
    EXPORTING i_name  = 'MDT_OUTTAB'
    IMPORTING e_value = me->mdt_outtab ).
    ASSIGN me->mdt_outtab->* TO <t_outtab>.

*   set Aktivity
    IF id_activity IS NOT INITIAL.
      md_activity = id_activity.
    ELSE.
      md_activity = reca1_activity-display.
    ENDIF.

*   create ALV grid object
    IF me->mo_container IS INITIAL.
      me->mo_container =
      zcl_dpd_dock_container_factory=>get_container(
      cl_gui_docking_container=>dock_at_top ).
      CREATE OBJECT me->mo_alv
        EXPORTING
          i_parent = me->mo_container.
*     set event handling methods
      SET HANDLER: me->on_toolbar          FOR me->mo_alv,
                   me->handle_double_click FOR me->mo_alv,
                   me->on_data_changed     FOR me->mo_alv,
                   me->on_data_changed_prot FOR me->mo_alv,
                   me->on_menu_button      FOR me->mo_alv,
                   me->on_user_command     FOR me->mo_alv,
                   me->on_hotspot_click    FOR me->mo_alv,
                   me->on_before_user_command FOR me->mo_alv.
    ENDIF.

*   get fcat (disable display-only fields)
    me->get_fcat( EXPORTING i_disp_struc_name = me->m_disp_str
                            i_dbtab           = me->m_tabname
                  IMPORTING et_fcat           = lt_fcat ).


*   Die Feldcatalog kann noch mal überabeitet werden
    me->mo_model->adapt_fieldcatalog(
      EXPORTING
        id_structure_name = me->m_disp_str
      CHANGING
        ct_fieldcatalog   = lt_fcat
           ).


*   Der Sort anpassen
    me->mo_model->adapt_sort( CHANGING ct_sort = lt_sort ).


*   Get Layout
    me->get_layout( EXPORTING i_disp_struc_name = me->m_disp_str
                    IMPORTING es_layout         = ls_layout ).


*    Set Varinant
    CONCATENATE 'MEAS' me->m_disp_str INTO  ls_variant-report.

    me->set_variant( EXPORTING    id_variant  = ls_variant-variant
                                  id_report   = ls_variant-report
                     IMPORTING    es_variant  = ls_variant ).


*   display result
    IF <t_outtab> IS ASSIGNED AND lt_fcat IS NOT INITIAL.
      CONCATENATE me->m_title 'ALV view'(alv)
      INTO ls_layout-grid_title SEPARATED BY ' - '.


*    Excluding funktionen
      me->get_excluding_functions( IMPORTING et_excluding = lt_toolbar_excluding ).

*     In Subklassen anpassen
      me->mo_model->adapt_excluding_funct( CHANGING ct_excluding = lt_toolbar_excluding ).


*     each return results in an event
      CALL METHOD me->mo_alv->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_enter.

      CALL METHOD me->mo_alv->set_table_for_first_display
        EXPORTING
          i_bypassing_buffer   = 'X'
          i_save               = 'A'
          i_default            = 'X'
          is_layout            = ls_layout
          is_variant           = ls_variant
          it_toolbar_excluding = lt_toolbar_excluding
        CHANGING
          it_outtab            = <t_outtab>
          it_fieldcatalog      = lt_fcat
          it_sort              = lt_sort.

    ENDIF.
  ENDMETHOD.                    "constructor

*---------------- on_toolbar
  METHOD on_toolbar.
    DATA: lt_buttons TYPE ttb_button,
          ls_button  LIKE LINE OF lt_buttons.

    FIELD-SYMBOLS: <ls_button> TYPE stb_button.

*  separator
    CLEAR ls_button.
    MOVE 3 TO ls_button-butn_type.
    APPEND ls_button TO e_object->mt_toolbar.


*   get buttons from model
    lt_buttons = me->mo_model->get_commands( ).
*   Prüfe Aktivität
    LOOP AT  lt_buttons ASSIGNING <ls_button>.
      IF md_activity = reca1_activity-display.
        IF <ls_button>-function <> 'CMD_ZIF_DPD_TREE_OBJECT_REFRESH' AND
          <ls_button>-function  <> 'CMD_ZIF_DPD_TREE_OBJECT_CLOSE'    AND
          <ls_button>-function  <> 'MENU_HEIZ'.
          <ls_button>-disabled = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.


    APPEND LINES OF lt_buttons TO e_object->mt_toolbar.



  ENDMETHOD.                    "on_toolbar



  METHOD on_before_user_command.
* E_UCOMM
* break b56322.
  ENDMETHOD.                    "on_BEFORE_USER_COMMAND





  METHOD on_menu_button.

    DATA: ld_tabname TYPE tabname.

    CASE e_ucomm.
      WHEN zheiz_eink_aktion-mc_menu_heiz. "  Bearbeiten Heizungsdatenbank .

        CALL METHOD e_object->add_function
          EXPORTING
            fcode    = zheiz_eink_aktion-mc_edit_heiz " Ändern Heizungsdatenbank
            text     = 'Ändern'
            icon     = icon_change
            disabled = ' '.

        CALL METHOD e_object->add_function
          EXPORTING
            fcode    = zheiz_eink_aktion-mc_anz_heiz " Anzeigen Heizungsdatenbank
            text     = 'Anzeigen'
            icon     = icon_display
            disabled = ' '.


      WHEN OTHERS.

    ENDCASE.



  ENDMETHOD.                    "on_menu_button

*---------------- on_user_command
  METHOD on_user_command.
    DATA: lt_index_row TYPE lvc_t_row,
          ls_index_row TYPE lvc_s_row,
          lt_index     TYPE re_t_tabix,
          ld_refresch  TYPE flag.

    DATA:
          lc_st_text_facade_edit_c TYPE sy-ucomm
          VALUE 'CMD_VERTRAG_NOTIZ_EDIT'.

*   Get Selektierte Zeile
    CALL METHOD mo_alv->get_selected_rows
      IMPORTING
        et_index_rows = lt_index_row.

*       ignore sums etc.
    DELETE lt_index_row WHERE rowtype IS NOT INITIAL.

    LOOP AT lt_index_row INTO ls_index_row.
      APPEND ls_index_row-index TO lt_index.
    ENDLOOP.



*   pass command to model
    me->mo_model->user_command(
      EXPORTING
        i_ucomm       = e_ucomm
        it_tabix      = lt_index
        it_good_cells = mt_good_cells
      IMPORTING
         cd_refresch  = ld_refresch
           ).

    IF ld_refresch = abap_true.
      me->mo_alv->refresh_table_display( )."refr view
    ENDIF.

*   do specific tasks
    CASE e_ucomm.
      WHEN zif_dpd_tree_object=>mc_save.
*        MESSAGE I605(01). "Data saved
*      Löschen von gespeicherten änderungen
        CLEAR: md_modified, mt_good_cells[].
      WHEN zif_dpd_tree_object=>mc_refresh.
        me->mo_alv->refresh_table_display( )."refr view
*       Löschen von gespeicherten änderungen
        CLEAR: md_modified, mt_good_cells[].
      WHEN lc_st_text_facade_edit_c.
        me->vertrag_notiz_edit( ).
      WHEN zif_dpd_tree_object=>mc_close.
        DATA: ld_text   TYPE seu_objkey,
              ld_answer TYPE c.
        ld_text = 'Geänderte Daten gehen verloren!'.
        CALL FUNCTION 'O2_POPUP_SAVE_DATA'
          EXPORTING
            p_pagename = ld_text
          IMPORTING
            p_answer   = ld_answer.
        "A" = Anwender hat Abbrechen gewählt
        "J" = Anwender hat den Verarbeitungsschritt bestätigt
        "N" = Anwender hat den Verarbeitungsschritt zurückgenommen

        IF ld_answer = 'J' OR ld_answer = 'A'.
          RETURN.
        ENDIF.

        me->free( ).


      WHEN OTHERS.

*    MESSAGE 'Functionalität nicht implementiert' TYPE 'I'.
    ENDCASE.
  ENDMETHOD.                    "on_user_command
  METHOD on_hotspot_click.
*  IMPORTING ES_ROW_NO
*            E_COLUMN,

    me->mo_model->on_hotspot_click(
*       E_ROW     = E_ROW
    e_column_id  = e_column_id
    es_row_no    = es_row_no
    ed_aktivity  = md_activity
    ).

*    IF MD_ACTIVITY = RECA1_ACTIVITY-CHANGE.
*      ME->ON_USER_COMMAND( ZIF_DPD_TREE_OBJECT=>MC_REFRESH ).
*    ENDIF.

*   Refresch
    DATA: ls_stable   TYPE  lvc_s_stbl.
    ls_stable-row = abap_true.
    ls_stable-col = abap_true.

*   Refresch
    me->mo_alv->refresh_table_display( is_stable = ls_stable )."refr view

  ENDMETHOD.                    "on_HANDLE_HOTSPOT_CLICK


*---------------- free
  METHOD free.
    me->mo_alv->free( ).
    zcl_dpd_dock_container_factory=>destroy_container(
    me->mo_container ).
    CLEAR: me->mo_alv, me->mo_container.
  ENDMETHOD.                    "free

*---------------- flight_schedule_st_text_edit
  METHOD vertrag_notiz_edit.
    DATA: t_sel_rows  TYPE lvc_t_row,
          s_thead     TYPE thead,
          l_cmd_edit  TYPE sy-ucomm,
          l_caption   TYPE text50,
          o_st_editor TYPE REF TO zcl_dpd_st_text_editor.
    FIELD-SYMBOLS:
      <outtab>   TYPE STANDARD TABLE,
      <line>     TYPE any,
      <l_carrid> TYPE any,
      <l_connid> TYPE any,
      <sel_row>  TYPE lvc_s_row.
    me->mo_alv->get_selected_rows(
    IMPORTING et_index_rows = t_sel_rows ).
    READ TABLE t_sel_rows INDEX 1 ASSIGNING <sel_row>.
    IF sy-subrc <> 0. EXIT. ENDIF.
    ASSIGN me->mdt_outtab->* TO <outtab>.
    READ TABLE <outtab> ASSIGNING <line>
    INDEX <sel_row>-index.
    ASSIGN COMPONENT:
    'CARRID' OF STRUCTURE <line> TO <l_carrid>,
    'CONNID' OF STRUCTURE <line> TO <l_connid>.
    CONCATENATE 'ZDPD_FL_' <l_carrid> <l_connid>
    INTO s_thead-tdname.
    s_thead-tdobject = 'TEXT'.
    s_thead-tdid     = 'ST'.
    s_thead-tdspras  = sy-langu.
    CONCATENATE
    'Comment for flight' <l_carrid> <l_connid>
    INTO l_caption SEPARATED BY space.
    CREATE OBJECT o_st_editor
      EXPORTING
        is_thead  = s_thead
        i_caption = l_caption.
    o_st_editor->show( ).
  ENDMETHOD.                    "flight_schedule_st_text_edit

* =====================================================================
  METHOD handle_double_click.
* =====================================================================
    FIELD-SYMBOLS:
    <t_outtab>        TYPE STANDARD TABLE.
    ASSIGN me->mdt_outtab->* TO <t_outtab>.

    FIELD-SYMBOLS: <ls_outtab> TYPE any.

    DATA: BEGIN OF ls_mv,
            bukrs         TYPE bukrs,
            smive_aktuell TYPE zsmive_aktuell,
          END OF ls_mv.
    DATA: ls_immo_key   TYPE zsvimi01_key,
          ld_objnr      TYPE recaobjnr,
          ls_navigation TYPE reca_wb_navigation.

*   TRACE
    mac_trace_alv_event.

    READ TABLE <t_outtab> ASSIGNING <ls_outtab> INDEX e_row.

    MOVE-CORRESPONDING <ls_outtab> TO ls_immo_key.

    CASE e_column-fieldname.
      WHEN 'SWENR' .
        CLEAR ls_navigation.

* Quick Fix Replace this statement by a SELECT statement with ORDER BY
* 30.04.2024 09:37:31 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*        SELECT SINGLE OBJNR FROM VIBDBE INTO LD_OBJNR WHERE BUKRS = LS_IMMO_KEY-BUKRS
*                                                        AND SWENR = LS_IMMO_KEY-SWENR.

        SELECT objnr FROM vibdbe INTO ld_objnr UP TO 1 ROWS WHERE bukrs = ls_immo_key-bukrs
         AND swenr = ls_immo_key-swenr
         ORDER BY PRIMARY KEY .
        ENDSELECT.
* End of Quick Fix

        ls_navigation-gotofirstscreen = abap_true.

        CALL FUNCTION 'RECA_GUI_BUSOBJ_APPL'
          EXPORTING
            id_activity          = reca1_activity-display
            id_objtype           = ld_objnr(2)
            id_objnr             = ld_objnr
            is_navigation_data   = ls_navigation
            if_new_internal_mode = abap_true
          EXCEPTIONS
            OTHERS               = 0.

      WHEN  'SGENR'.
        CLEAR ls_navigation.
        ls_navigation-gotofirstscreen = abap_true.


* Quick Fix Replace this statement by a SELECT statement with ORDER BY
* 30.04.2024 09:37:31 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*        SELECT SINGLE OBJNR FROM VIBDBU INTO LD_OBJNR WHERE BUKRS = LS_IMMO_KEY-BUKRS
*        AND SWENR = LS_IMMO_KEY-SWENR
*        AND SGENR = LS_IMMO_KEY-SGENR.

        SELECT objnr FROM vibdbu INTO ld_objnr UP TO 1 ROWS WHERE bukrs = ls_immo_key-bukrs
         AND swenr = ls_immo_key-swenr AND sgenr = ls_immo_key-sgenr
         ORDER BY PRIMARY KEY .
        ENDSELECT.
* End of Quick Fix

        ls_navigation-gotofirstscreen = abap_true.

        CALL FUNCTION 'RECA_GUI_BUSOBJ_APPL'
          EXPORTING
            id_activity          = reca1_activity-display
            id_objtype           = ld_objnr(2)
            id_objnr             = ld_objnr
            is_navigation_data   = ls_navigation
            if_new_internal_mode = abap_true
          EXCEPTIONS
            OTHERS               = 0.

      WHEN  'SMENR'.
        CLEAR ls_navigation.
        ls_navigation-gotofirstscreen = abap_true.


* Quick Fix Replace this statement by a SELECT statement with ORDER BY
* 30.04.2024 09:37:31 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*        SELECT SINGLE OBJNR FROM VIBDRO INTO LD_OBJNR WHERE BUKRS = LS_IMMO_KEY-BUKRS
*        AND SWENR = LS_IMMO_KEY-SWENR
*        AND SMENR = LS_IMMO_KEY-SMENR.

        SELECT objnr FROM vibdro INTO ld_objnr UP TO 1 ROWS WHERE bukrs = ls_immo_key-bukrs
         AND swenr = ls_immo_key-swenr AND smenr = ls_immo_key-smenr
         ORDER BY PRIMARY KEY .
        ENDSELECT.
* End of Quick Fix

        ls_navigation-gotofirstscreen = abap_true.

        CALL FUNCTION 'RECA_GUI_BUSOBJ_APPL'
          EXPORTING
            id_activity          = reca1_activity-display
            id_objtype           = ld_objnr(2)
            id_objnr             = ld_objnr
            is_navigation_data   = ls_navigation
            if_new_internal_mode = abap_true
          EXCEPTIONS
            OTHERS               = 0.

      WHEN 'SMIVE_AKTUELL'.

        MOVE-CORRESPONDING <ls_outtab> TO ls_mv.


* Quick Fix Replace this statement by a SELECT statement with ORDER BY
* 30.04.2024 09:37:31 DEB56322
* Transport XS4K900004 W-20240402: P1CL3 ATC P44 Objekte                     => PS4
* Replaced Code:
*        SELECT SINGLE OBJNR FROM VICNCN INTO LD_OBJNR WHERE BUKRS  = LS_MV-BUKRS
*                                                 AND RECNNR = LS_MV-SMIVE_AKTUELL.

        SELECT objnr FROM vicncn INTO ld_objnr UP TO 1 ROWS WHERE bukrs = ls_mv-bukrs
         AND recnnr = ls_mv-smive_aktuell
         ORDER BY PRIMARY KEY .
        ENDSELECT.
* End of Quick Fix

        IF sy-subrc = 0.
*            LS_NAVIGATION-GOTOFIRSTSCREEN = ABAP_TRUE.
          ls_navigation-dynid = 'REGC41'.
          CALL FUNCTION 'RECA_GUI_BUSOBJ_APPL'
            EXPORTING
              id_activity          = reca1_activity-display
              id_objtype           = ld_objnr(2)
              id_objnr             = ld_objnr
              is_navigation_data   = ls_navigation
              if_new_internal_mode = abap_true
            EXCEPTIONS
              OTHERS               = 0.
        ENDIF.

*        WHEN-OTHERS.

    ENDCASE.

  ENDMETHOD.                    "handle_double_click

  METHOD on_data_changed.
    "  E_MODIFIED     Type char1
    "  ET_GOOD_CELLS  Type  LVC_T_MODI

    md_modified   = e_modified.
    APPEND LINES OF et_good_cells TO mt_good_cells.
    SORT mt_good_cells BY row_id.

    RAISE EVENT data_changed EXPORTING e_modified = md_modified.

  ENDMETHOD.                    "on_data_changed

  METHOD on_data_changed_prot.
    " ER_DATA_CHANGED	Type Ref To	CL_ALV_CHANGED_DATA_PROTOCOL
    IF er_data_changed  IS BOUND.
      me->mo_model->on_data_changed( io_data_changed = er_data_changed  ).
    ENDIF.
  ENDMETHOD.                    "on_data_changed_prot

*------------------- get_fcat
  METHOD get_fcat.

    DEFINE mac_alv_fc_pos_set1.                                              " set next position for field (ascending)
*--> &1 = fieldname
*----------------------------------------------------------------------

      READ TABLE et_fcat ASSIGNING <ls_fcat>
      WITH KEY fieldname = &1.
*     the field MUST be present -> program error
      ASSERT FIELDS 'FIELDNAME' ld_colpos &1
      CONDITION sy-subrc = 0.

      <ls_fcat>-col_pos = ld_colpos.
      ADD 1 TO ld_colpos.

    END-OF-DEFINITION.

    DATA:
          ld_colpos         TYPE sytabix.                   "#EC NEEDED

    DATA: lt_dbtab_fcat      TYPE lvc_t_fcat.
    FIELD-SYMBOLS:
    <ls_fcat>          TYPE lvc_s_fcat.
*   create fieldcatalog for display
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = i_disp_struc_name
        i_client_never_display = 'X'
        i_bypassing_buffer     = 'X'
      CHANGING
        ct_fieldcat            = et_fcat.
*   only fields from DDIC table are enabled for input
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = i_dbtab
        i_client_never_display = 'X'
        i_bypassing_buffer     = 'X'
      CHANGING
        ct_fieldcat            = lt_dbtab_fcat.
    LOOP AT et_fcat ASSIGNING <ls_fcat>.
      READ TABLE lt_dbtab_fcat
           WITH KEY fieldname = <ls_fcat>-fieldname
           TRANSPORTING NO FIELDS.


*         Ausblenden
      IF ( <ls_fcat>-fieldname = 'MANDT'    ) OR
         ( <ls_fcat>-fieldname = 'HASNOTE'  ) OR
         ( <ls_fcat>-fieldname = 'DATEINFO' ) OR
         ( <ls_fcat>-fieldname = 'RERF'     ) OR
         ( <ls_fcat>-fieldname = 'DERF'     ) OR
         ( <ls_fcat>-fieldname = 'TERF'     ) OR
         ( <ls_fcat>-fieldname = 'REHER'    ) OR
*         ( <LS_FCAT>-FIELDNAME = 'RBEAR'    ) OR
*         ( <LS_FCAT>-FIELDNAME = 'DBEAR'    ) OR
*         ( <LS_FCAT>-FIELDNAME = 'TBEAR'    ) OR
*         ( <LS_FCAT>-FIELDNAME = 'RBHER'    ) OR
         ( <ls_fcat>-fieldname = 'CONECTSTORT'    ) OR
         ( <ls_fcat>-fieldname = 'TNOTIZ'    ) OR
         ( <ls_fcat>-fieldname = 'ICONNOTIZ'    ) OR
         ( <ls_fcat>-fieldname = 'OBJGUID'    ) .
        <ls_fcat>-tech   = abap_true.

      ENDIF.






*    felder ausblenden
      CASE <ls_fcat>-fieldname.
        WHEN 'MANDT' OR
             'GUID' OR
             'OBJNR' OR
             'OBJNRSUM' OR
             'PLANW03SUM' OR
             'TABCOLOR'.
          <ls_fcat>-tech   = abap_true.
      ENDCASE.

    ENDLOOP.




**   set positions for fields
*      MAC_ALV_FC_POS_SET1:
*      'ICON_DETAIL'.
*      'ANLAGEN_ID',
*      'INBETRIEBNAHME',
*      'AUSBAU_STILLL',
*      'HEIZGRUP',
*      'BUKRS',
*      'SWENR',
*      'SGENR',
*      'SMENR',
*      'KDST'.
*
*      MAC_ALV_FC_POS_SET1:
*      'ICON_ANGSL',
*      'CITY1',
*      'CITY2',
*      'POST_CODE1',
*      'STREET',
*      'HOUSE_NUM1',
*      'HEIZFLAECHE',
*      'MEASUNIT',
*      'NVS',
*      'WEG',
*      'MIETEREIGENTUM',
*      'ICONHASNOTE',
*      'KESSELHERSTELLER',
*      'KESSELTYP',
*      'KESSELBAUJAHR',
*      'HEIZUNGSART',
*      'NENNLEISTUNG',
*      'ENERGIEART',
*      'KESSEL_STANDORT',
*      'BRENNERHERSTEL',
*      'BRENNERTYP',
*      'BRENNERBAUJAHR',
*      'GEBLAESE'.
**      'WASSERWARMESPE',
**      'WWS_HERSTELLER',
**      'GROESSE_LITER',
**      'EX_WAERMTAU_TYP'.

  ENDMETHOD.                    "get_fcat

  METHOD get_layout.

* 4. get and modify layout
    CALL METHOD mo_alv->get_frontend_layout
      IMPORTING
        es_layout = es_layout.

    es_layout-zebra      = 'X'.
    es_layout-sel_mode   = 'A'.
*    ES_LAYOUT-EDIT       = ABAP_FALSE.
*    ES_LAYOUT-NO_ROWMOVE = ABAP_TRUE.
    es_layout-cwidth_opt = 'X'. "always
    es_layout-smalltitle = abap_false.
    es_layout-ctab_fname = 'COLORTAB'.
    es_layout-stylefname = 'STYLETAB'.
  ENDMETHOD.                    "get_layout


  METHOD get_excluding_functions.
    "  EXPORTING ET_EXCLUDING Type  UI_FUNCTIONS

    DATA:
          ls_excl_func      TYPE ui_func.

* Grafik
    ls_excl_func = cl_gui_alv_grid=>mc_fc_graph.
    APPEND ls_excl_func TO et_excluding.

* Menu Button View
    ls_excl_func = cl_gui_alv_grid=>mc_mb_view.
    APPEND ls_excl_func TO et_excluding.

* Info-Button
    ls_excl_func = cl_gui_alv_grid=>mc_fc_info.
    APPEND ls_excl_func TO et_excluding.

* Eingaben prüfen
    ls_excl_func = cl_gui_alv_grid=>mc_fc_check.
    APPEND ls_excl_func TO et_excluding.

* Aktualisieren
    ls_excl_func = cl_gui_alv_grid=>mc_fc_refresh.
    APPEND ls_excl_func TO et_excluding.


* Copy
    ls_excl_func = cl_gui_alv_grid=>mc_fc_loc_copy.
    APPEND ls_excl_func TO et_excluding.

** Zeile anhängen
*    LS_EXCL_FUNC = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
*    APPEND LS_EXCL_FUNC TO ET_EXCLUDING.

** Zeile kopieren
*    LS_EXCL_FUNC = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
*    APPEND LS_EXCL_FUNC TO ET_EXCLUDING.

** Zeile löschen
*    LS_EXCL_FUNC = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
*    APPEND LS_EXCL_FUNC TO ET_EXCLUDING.
* Ausschneiden
    ls_excl_func = cl_gui_alv_grid=>mc_fc_loc_cut.
    APPEND ls_excl_func TO et_excluding.



* Zeile einfügen
    ls_excl_func = cl_gui_alv_grid=>mc_fc_loc_insert_row.
    APPEND ls_excl_func TO et_excluding.

* Zeile bewegen
    ls_excl_func = cl_gui_alv_grid=>mc_fc_loc_move_row.
    APPEND ls_excl_func TO et_excluding.

* Undo
    ls_excl_func = cl_gui_alv_grid=>mc_fc_loc_undo.
    APPEND ls_excl_func TO et_excluding.

* Paste
    ls_excl_func = cl_gui_alv_grid=>mc_fc_loc_paste.
    APPEND ls_excl_func TO et_excluding.

* Neue Zeile
    ls_excl_func = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
    APPEND ls_excl_func TO et_excluding.

  ENDMETHOD.                    "GET_EXCLUDING_FUNCTIONS

  METHOD set_variant.
*  ID_VARIANT	Importing
*  ID_HANDLE  Importing optional
*  ID_REPORT  Importing optional
*   es_variant exporting
    DATA:
      ls_variant     TYPE disvariant,
      ls_variant_old TYPE disvariant.

* BODY
    ls_variant-variant  = id_variant.

    IF id_handle IS SUPPLIED.
      ls_variant-handle = id_handle.
    ELSE.
      ls_variant-handle = es_variant-handle.
    ENDIF.

    IF id_report IS INITIAL.
      ls_variant-report = sy-cprog.
    ELSE.
      ls_variant-report = id_report.
    ENDIF.

    ls_variant-username = sy-uname.

    IF id_variant IS NOT INITIAL.
*   check if variant is valid for handle
      CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
        EXPORTING
          i_save        = 'A'
        CHANGING
          cs_variant    = ls_variant
        EXCEPTIONS
          wrong_input   = 1
          not_found     = 2
          program_error = 3
          OTHERS        = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        .
      ENDIF.
    ENDIF.

    IF es_variant <> ls_variant.

      ls_variant_old = es_variant.
      es_variant = ls_variant.

*      RAISE EVENT VARIANT_CHANGED
*        EXPORTING
*          IS_DISVARIANT_OLD = LS_VARIANT_OLD
*          IS_DISVARIANT_NEW = ES_VARIANT.

    ENDIF.


  ENDMETHOD.                    "SET_VARIANT


ENDCLASS.                    "lcl_con_alv IMPLEMENTATION

*------------------------------------------------------------*
*       CLASS lcl_con_dd IMPLEMENTATION
*------------------------------------------------------------*
*
*------------------------------------------------------------*
CLASS lcl_con_dd IMPLEMENTATION.
*---------------- constructor
  METHOD constructor.
    me->mo_model = i_model.
*   get model's attributes
    i_model->get_attribute(
    EXPORTING i_name  = 'M_DISP_STRUC_NAME'
    IMPORTING e_value = me->m_disp_str ).
    i_model->get_attribute(
    EXPORTING i_name  = 'M_TABNAME'
    IMPORTING e_value = me->m_tabname ).
    i_model->get_attribute(
    EXPORTING i_name  = 'M_CAPTION'
    IMPORTING e_value = me->m_title ).
    i_model->get_attribute(
    EXPORTING i_name  = 'MDT_OUTTAB'
    IMPORTING e_value = me->mdt_outtab ).
    IF me->mo_container IS INITIAL.
*   get main docking container
      me->mo_container = zcl_dpd_dock_container_factory=>get_container(
      cl_gui_docking_container=>dock_at_top ).
*   create DD control
      CREATE OBJECT me->mo_dd.
      me->mo_dd->display_document( parent = me->mo_container ).
    ENDIF.
    me->refresh_display( ).
  ENDMETHOD.                    "constructor

*---------------- on_clicked
  METHOD on_clicked.
    DATA: lo_button TYPE REF TO cl_dd_button_element.
    lo_button = sender.
    CASE lo_button->name.
      WHEN zif_dpd_tree_object=>mc_refresh.
        me->mo_model->user_command(
        zif_dpd_tree_object=>mc_refresh ).
        me->refresh_display( ). "refr view
      WHEN zif_dpd_tree_object=>mc_close.
        me->free( ).
      WHEN OTHERS.
        MESSAGE 'Function not implemented' TYPE 'I'.
    ENDCASE.
  ENDMETHOD.                    "on_clicked

*---------------- refresh_display
  METHOD refresh_display.
    DATA:
      lo_dd_table     TYPE REF TO cl_dd_table_element,
      lo_column       TYPE REF TO cl_dd_area,
      lo_form         TYPE REF TO cl_dd_form_area,
      lo_button       TYPE REF TO cl_dd_button_element,
      l_column_count  TYPE i,
      l_heading       TYPE sdydo_text_element,
      l_text          TYPE sdydo_text_element,
      lt_fcat         TYPE lvc_t_fcat,
      lo_data         TYPE REF TO data,
      lt_buttons      TYPE ttb_button,
      ls_button       LIKE LINE OF lt_buttons,
      l_btn_name      TYPE sdydo_element_name,
      l_btn_icon_name TYPE icon-name,
      lo_object       TYPE REF TO object.
    FIELD-SYMBOLS:
      <t_outtab>    TYPE STANDARD TABLE,
      <outtab_line> TYPE any,
      <field>       TYPE any,
      <ls_fcat>     LIKE LINE OF lt_fcat.
*   refresh model data
    me->mo_model->user_command(
    zif_dpd_tree_object=>mc_refresh ).
    ASSIGN: me->mdt_outtab->* TO <t_outtab>.
    IF NOT <t_outtab> IS ASSIGNED. EXIT. ENDIF.
    me->mo_dd->initialize_document( ).
    me->mo_dd->add_form( IMPORTING formarea = lo_form ).
* add header
    CONCATENATE me->m_title 'DD view'(ddv)
    INTO l_text SEPARATED BY ' - '.
    lo_form->add_text( text      = l_text
    sap_style = 'heading' ).
* add command buttons
    lo_form->line_with_layout( start = 'X' ).
    lt_buttons = me->mo_model->get_commands( ).
    LOOP AT lt_buttons INTO ls_button.
      l_btn_name = ls_button-function.
      CLEAR l_btn_icon_name.
      SELECT SINGLE name FROM icon INTO l_btn_icon_name
      WHERE id = ls_button-icon."ICON table fully buffered
      lo_form->add_button(
      EXPORTING sap_icon = l_btn_icon_name
        name     = l_btn_name
      IMPORTING button   = lo_button ).
      SET HANDLER me->on_clicked FOR lo_button.
    ENDLOOP.
*--- create table within dd control
*   get fcat
    me->get_fcat( EXPORTING i_disp_struc_name = me->m_disp_str
      i_dbtab           = me->m_tabname
    IMPORTING et_fcat           = lt_fcat ).
    DESCRIBE TABLE lt_fcat LINES l_column_count.
    me->mo_dd->add_table(
    EXPORTING
      no_of_columns               = l_column_count
      cell_background_transparent = space
      with_heading                = 'X'
    IMPORTING
      table                       = lo_dd_table ).
*   create columns with headers
    LOOP AT lt_fcat ASSIGNING <ls_fcat>.
      l_heading = <ls_fcat>-scrtext_s.
      lo_dd_table->add_column( heading = l_heading ).
    ENDLOOP.
*   fill table with data
    LOOP AT <t_outtab> ASSIGNING <outtab_line>.
      IF sy-tabix > 1.
        lo_dd_table->new_row( ).
      ENDIF.
      DO.
        ASSIGN COMPONENT sy-index
        OF STRUCTURE <outtab_line> TO <field>.
        IF sy-subrc <> 0. EXIT. ENDIF.
        READ TABLE lo_dd_table->table_of_columns
        INTO lo_object INDEX sy-index.
        lo_column ?= lo_object.
        WRITE <field> TO l_text.
        lo_column->add_text( text = l_text ).
      ENDDO.
    ENDLOOP.
*   refresh document display
    me->mo_dd->merge_document( ).
    me->mo_dd->display_document( reuse_control = 'X' ).
  ENDMETHOD.                    "refresh_display

*---------------- free
  METHOD free.
    zcl_dpd_dock_container_factory=>destroy_container(
    me->mo_container ).
    CLEAR: me->mo_dd, me->mo_container.
  ENDMETHOD.                    "free

*------------------- get_fcat
  METHOD get_fcat.
    DATA: lt_dbtab_fcat      TYPE lvc_t_fcat.
    FIELD-SYMBOLS:
    <ls_fcat>          TYPE lvc_s_fcat.
* create fieldcatalog for display
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = i_disp_struc_name
        i_client_never_display = 'X'
        i_bypassing_buffer     = 'X'
      CHANGING
        ct_fieldcat            = et_fcat.
* only fields from DDIC table are enabled for input
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = i_dbtab
        i_client_never_display = 'X'
        i_bypassing_buffer     = 'X'
      CHANGING
        ct_fieldcat            = lt_dbtab_fcat.
    LOOP AT et_fcat ASSIGNING <ls_fcat>.
      READ TABLE lt_dbtab_fcat
      WITH KEY fieldname = <ls_fcat>-fieldname
      TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        <ls_fcat>-edit = 'X'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "get_fcat

ENDCLASS.                    "lcl_con_dd IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS lcl_con_dynpro_screen IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_con_dynpro_screen IMPLEMENTATION.
  METHOD pai.
    DATA:
          l_fname    TYPE string.
    FIELD-SYMBOLS:
      <line>     TYPE any,
      <t_outtab> TYPE table,
      <field>    TYPE any.                                  "#EC *
*   pass screen structure to 1st line of model's OUTTAB
    ASSIGN me->mdt_outtab->* TO <t_outtab>.
    READ TABLE <t_outtab> INDEX 1 ASSIGNING <line>.
    <line> = i_data.
    CASE i_ucomm.
      WHEN 'SAVE'.
*       tell to the model object to save data
        me->mo_model->user_command( mo_model->mc_save ).
        MESSAGE 'Data was saved' TYPE 'I'.
      WHEN 'BACK'.
        g_subscreen_dynnr = me->m_dynnr_main.
        g_gui_status      = me->m_gui_status_main.
        zcl_dpd_dock_container_factory=>unhide_all( ).
    ENDCASE.
  ENDMETHOD.                    "zif_dpd_dynpro_screen~pai

  METHOD pbo.
    FIELD-SYMBOLS:
      <line>     TYPE any,
      <t_outtab> TYPE table.
*   take OUTTAB's first line and pass to screen
    ASSIGN me->mdt_outtab->* TO <t_outtab>.
    READ TABLE <t_outtab> INDEX 1 ASSIGNING <line>.
    e_data = <line>.
  ENDMETHOD.                    "zif_dpd_dynpro_screen~pbo

  METHOD constructor.
*   get model object's attributes
    i_model->get_attribute(
    EXPORTING i_name  = 'M_CAPTION'
    IMPORTING e_value = me->m_title ).
    i_model->get_attribute(
    EXPORTING i_name  = 'MDT_OUTTAB'
    IMPORTING e_value = me->mdt_outtab ).
*   pass importing parameters to own attributes
    me->mo_model          = i_model.
    me->m_dynnr_main      = i_main_dynnr.
    me->m_gui_status_main = i_main_status.
    g_gui_status          = i_new_status.
    g_subscreen_dynnr     = i_new_dynnr.
  ENDMETHOD.                    "constructor

  METHOD create_controller.
    DATA:
      lo_controller   TYPE REF TO lcl_con_dynpro_screen,
      ls_screen_contr TYPE mty_screen_controllers.
    CREATE OBJECT lo_controller
      EXPORTING
        i_model       = i_model
        i_new_status  = i_new_status
        i_new_dynnr   = i_new_dynnr
        i_main_dynnr  = i_main_dynnr
        i_main_status = i_main_status.
    ls_screen_contr-o_controller = lo_controller.
    ls_screen_contr-dynnr        = i_new_dynnr.
    MODIFY TABLE lcl_con_dynpro_screen=>mt_scr_contr
    FROM ls_screen_contr.
    IF sy-subrc <> 0.
      INSERT ls_screen_contr
      INTO TABLE lcl_con_dynpro_screen=>mt_scr_contr.
    ENDIF.
  ENDMETHOD.                    "create_controller

  METHOD class_pai.
    FIELD-SYMBOLS:
    <ls_screen_contr> LIKE LINE OF mt_scr_contr.
    READ TABLE lcl_con_dynpro_screen=>mt_scr_contr
    ASSIGNING <ls_screen_contr>
    WITH KEY dynnr = i_dynnr.
    <ls_screen_contr>-o_controller->pai(
    i_ucomm = i_ucomm
    i_data  = i_data ).
  ENDMETHOD.                    "class_pai

  METHOD class_pbo.
    FIELD-SYMBOLS:
    <ls_screen_contr> LIKE LINE OF mt_scr_contr.
    READ TABLE lcl_con_dynpro_screen=>mt_scr_contr
    ASSIGNING <ls_screen_contr>
    WITH KEY dynnr = i_dynnr.
    <ls_screen_contr>-o_controller->pbo(
    IMPORTING e_data = e_data ).
  ENDMETHOD.                    "class_pbo
ENDCLASS.                    "lcl_con_dynpro_screen IMPLEMENTATION
