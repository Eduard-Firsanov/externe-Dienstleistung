*"* local class implementation for public class
*"* use this source file for the implementation part of
*"* local helper classes


*&---------------------------------------------------------------------*
*&  Include          LCL_MOD_EXT_DIENST_ANW
*&---------------------------------------------------------------------*
CLASS lcl_mod_ext_dienst_anw IMPLEMENTATION.
*--------------------------- constructor
  METHOD constructor.


*-- SUPER constructor
    super->constructor(
    i_tabname         = 'ZTWARTPLANINFO' " Inhalt ist an der stelle ohne Bedeutung
    i_disp_struc_name = 'ZST_INFO_DIALOG'" Inhalt ist an der stelle ohne Bedeutung
    i_title           = 'externe Dienstleistung' ).


*   Set Classen Atribute
    md_cust_akt  = id_cust_akt.
    md_anwendung = id_anwendung.
    md_akt       = id_akt.

*     Get Customizing zur ext. Dienstleistung
    DATA: et_dienstl_x TYPE z_t_zcus_dienstl_x,
          ls_dienstl_x LIKE LINE OF et_dienstl_x.

    zcl_cust_zcus_dienstl=>get_list_x(
    IMPORTING
      et_list_x  = et_dienstl_x
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2
      ).
    IF sy-subrc <> 0.
      MESSAGE e001.
*       Customizing für Dienstleistung "ZTR_CUST_DIENST" nicht definiert.
    ENDIF.

    IF id_start = abap_true.
      me->zif_dpd_tree_object~ms_node-node_key  = 'DIENST_ANW'.
      me->zif_dpd_tree_object~ms_node-text      = 'externe Dienstleistung'.
      me->zif_dpd_tree_object~ms_node-exp_image = icon_resource.
      me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
      me->zif_dpd_tree_object~ms_node-isfolder = 'X'.
      me->zif_dpd_tree_object~ms_node-expander = 'X'.
      RETURN.
    ENDIF.

    IF md_cust_akt = 'CUST'.
      me->zif_dpd_tree_object~ms_node-node_key  = md_cust_akt.
      me->zif_dpd_tree_object~ms_node-text      = 'Customizing'.
      me->zif_dpd_tree_object~ms_node-exp_image = icon_working_plan.
      me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
      me->zif_dpd_tree_object~ms_node-isfolder = 'X'.
      me->zif_dpd_tree_object~ms_node-expander = 'X'.
    ENDIF.

    IF md_cust_akt = 'DIENST_CUST'.
      me->zif_dpd_tree_object~ms_node-node_key  = md_cust_akt.
      me->zif_dpd_tree_object~ms_node-text      = 'Customizing von Dienstleistungsabwicklung'.
      me->zif_dpd_tree_object~ms_node-exp_image = icon_working_plan.
      me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
    ENDIF.



    READ TABLE et_dienstl_x INTO ls_dienstl_x WITH KEY dienstleistung = md_anwendung.
    IF sy-subrc = 0.

      IF md_anwendung  = ls_dienstl_x-dienstleistung AND md_akt IS INITIAL.
        me->zif_dpd_tree_object~ms_node-node_key  = md_anwendung.
        CONCATENATE '"' md_anwendung '"' '-' ls_dienstl_x-dienstleistbez  INTO
       me->zif_dpd_tree_object~ms_node-text .
        me->zif_dpd_tree_object~ms_node-exp_image = icon_execute_object.
        me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
        me->zif_dpd_tree_object~ms_node-isfolder = 'X'.
        me->zif_dpd_tree_object~ms_node-expander = 'X'.
      ENDIF.

*   Set Serviceordner
      IF md_akt+5(4)  = 'HELP' AND md_akt+9(1)  <> '_'.
        me->zif_dpd_tree_object~ms_node-node_key  = md_akt.
        me->zif_dpd_tree_object~ms_node-text      = 'Ext. Dienstleistung Serviceprogramme'.
        me->zif_dpd_tree_object~ms_node-exp_image = icon_gos_services_attachment.
        me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
        me->zif_dpd_tree_object~ms_node-isfolder = 'X'.
        me->zif_dpd_tree_object~ms_node-expander = 'X'.
      ENDIF.

*   Set SubNods zum Serviceordner
      IF md_akt+5(6)  = 'HELP_1'.
        me->zif_dpd_tree_object~ms_node-node_key  = md_akt.
        me->zif_dpd_tree_object~ms_node-text      = 'Änderungshistorie'.
        me->zif_dpd_tree_object~ms_node-exp_image = icon_show_external_jobs.
        me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
        me->zif_dpd_tree_object~ms_node-isfolder = 'X'.
        me->zif_dpd_tree_object~ms_node-expander = abap_false.
      ENDIF.


      IF md_akt+5(3)  = 'ANL'.
        me->zif_dpd_tree_object~ms_node-node_key  = md_akt.
        me->zif_dpd_tree_object~ms_node-text      = 'Objektliste erstellen'.
        me->zif_dpd_tree_object~ms_node-exp_image = icon_write_file.
        me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
      ENDIF.

      IF md_akt+5(4)  = 'AEND'.
        me->zif_dpd_tree_object~ms_node-node_key  = md_akt.
        me->zif_dpd_tree_object~ms_node-text      = 'Objektliste bearbeiten'.
        me->zif_dpd_tree_object~ms_node-exp_image = icon_edit_file.
        me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
      ENDIF.
      IF md_akt+5(3)  = 'ANZ'.
        me->zif_dpd_tree_object~ms_node-node_key  = md_akt.
        me->zif_dpd_tree_object~ms_node-text      = 'Objektliste anzeigen'.
        me->zif_dpd_tree_object~ms_node-exp_image = icon_read_file.
        me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
      ENDIF.

      IF md_akt+5(3)  = 'SET'.
        me->zif_dpd_tree_object~ms_node-node_key  = md_akt.
        me->zif_dpd_tree_object~ms_node-text      = 'Excel Import/Export'.
        me->zif_dpd_tree_object~ms_node-exp_image = icon_xxl.
        me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
        me->zif_dpd_tree_object~ms_node-isfolder = 'X'.
        me->zif_dpd_tree_object~ms_node-expander = 'X'.
      ENDIF.

      IF md_akt+5(3)  = 'UPL'.
        me->zif_dpd_tree_object~ms_node-node_key  = md_akt.
        me->zif_dpd_tree_object~ms_node-text      = 'Datenübernahme von Excel'.
        me->zif_dpd_tree_object~ms_node-exp_image = icon_xxl.
        me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
      ENDIF.

      IF md_akt+5(3)  = 'DOW'.
        me->zif_dpd_tree_object~ms_node-node_key  = md_akt.
        me->zif_dpd_tree_object~ms_node-text      = 'Datenübertragung nach Excel'.
        me->zif_dpd_tree_object~ms_node-exp_image = icon_xxl.
        me->zif_dpd_tree_object~ms_node-n_image   =  me->zif_dpd_tree_object~ms_node-exp_image.
      ENDIF.



    ENDIF.
*    IF MD_AKT  = 'EMODRENDIT'.
*      ME->ZIF_DPD_TREE_OBJECT~MS_NODE-NODE_KEY  = MD_AKT.
*      ME->ZIF_DPD_TREE_OBJECT~MS_NODE-TEXT      = 'Renditenberechnung prüfen/korrigieren'.
*      ME->ZIF_DPD_TREE_OBJECT~MS_NODE-EXP_IMAGE = ICON_UNIT_COSTING.
*      ME->ZIF_DPD_TREE_OBJECT~MS_NODE-N_IMAGE   =  ME->ZIF_DPD_TREE_OBJECT~MS_NODE-EXP_IMAGE.
*    ENDIF.
*
*    IF MD_AKT  = 'STATISTIK'.
*      ME->ZIF_DPD_TREE_OBJECT~MS_NODE-NODE_KEY  = MD_AKT.
*      ME->ZIF_DPD_TREE_OBJECT~MS_NODE-TEXT      = 'EMOD-Statistiken'.
*      ME->ZIF_DPD_TREE_OBJECT~MS_NODE-EXP_IMAGE = ICON_STATISTICS.
*      ME->ZIF_DPD_TREE_OBJECT~MS_NODE-N_IMAGE   =  ME->ZIF_DPD_TREE_OBJECT~MS_NODE-EXP_IMAGE.
*    ENDIF.
  ENDMETHOD.                    "constructor

*----------------------- zif_dpd_tree_object~get_sub_objects
  METHOD zif_dpd_tree_object~get_sub_objects.

    DATA: lo_object      TYPE REF TO lcl_mod_ext_dienst_anw. " Design Patterns: Application Model
    DATA: ld_aktivitaet        TYPE sy-ucomm,
          ld_aktivitaet_parent TYPE sy-ucomm,
          ld_anwendung         TYPE char35.


    IF md_cust_akt IS INITIAL AND md_anwendung IS INITIAL.
*     create object
      CREATE OBJECT lo_object
        EXPORTING
          id_cust_akt = 'CUST'.

      lo_object->zif_dpd_tree_object~ms_node-relatkey =
      me->zif_dpd_tree_object~ms_node-node_key.
      APPEND lo_object TO rt_new_objects.

    ELSE.
      IF md_anwendung IS INITIAL.
*       create object
        CREATE OBJECT lo_object
          EXPORTING
            id_cust_akt = 'DIENST_CUST'.

        lo_object->zif_dpd_tree_object~ms_node-relatkey =
        me->zif_dpd_tree_object~ms_node-node_key.
        APPEND lo_object TO rt_new_objects.

      ENDIF.
    ENDIF.



*     Get Customizing zur ext. Dienstleistung
    DATA: et_dienstl_x TYPE z_t_zcus_dienstl_x,
          ls_dienstl_x LIKE LINE OF et_dienstl_x.

    zcl_cust_zcus_dienstl=>get_list_x(
      IMPORTING
        et_list_x  = et_dienstl_x
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE e001.
*       Customizing für Dienstleistung "ZTR_CUST_DIENST" nicht definiert.
    ENDIF.



    IF md_anwendung IS INITIAL AND md_cust_akt IS INITIAL.

*    Sortieren nach Reihnfolge
      SORT et_dienstl_x BY sortorder.

      LOOP AT et_dienstl_x INTO ls_dienstl_x.
        ld_anwendung = ls_dienstl_x-dienstleistung.
        CREATE OBJECT lo_object
          EXPORTING
            id_anwendung = ld_anwendung.


        lo_object->zif_dpd_tree_object~ms_node-relatkey =
        me->zif_dpd_tree_object~ms_node-node_key.
        APPEND lo_object TO rt_new_objects.

      ENDLOOP.


    ELSE.



      CHECK md_cust_akt IS INITIAL.


      READ TABLE et_dienstl_x INTO ls_dienstl_x WITH KEY dienstleistung = md_anwendung.
      IF sy-subrc = 0.

*       Prüfe ob die Subgruppe für Service aufgebaut werden soll
        CONCATENATE md_anwendung 'HELP' INTO ld_aktivitaet SEPARATED BY '_'.
        IF md_akt IS NOT INITIAL AND ld_aktivitaet = md_akt.
          " Set Subnodes für Dienstprogramme
          CONCATENATE ld_aktivitaet '1' INTO ld_aktivitaet SEPARATED BY '_'.
          CREATE OBJECT lo_object
            EXPORTING
              id_anwendung = md_anwendung
              id_akt       = ld_aktivitaet.

*     Set Selektionstabelle und Anzeige-Struktur
          lo_object->m_tabname         = ls_dienstl_x-tabname.
          lo_object->m_disp_struc_name = ls_dienstl_x-disp_structname.
          lo_object->m_caption         = ls_dienstl_x-dienstleistbez. "default capt.
*     create outtab dynamically
          CREATE DATA lo_object->mdt_outtab
                TYPE STANDARD TABLE OF (lo_object->m_disp_struc_name).

          lo_object->zif_dpd_tree_object~ms_node-relatkey =
          me->zif_dpd_tree_object~ms_node-node_key.
          APPEND lo_object TO rt_new_objects.


        ELSE.
          " Create Objektliste
          CONCATENATE md_anwendung 'ANL' INTO ld_aktivitaet SEPARATED BY '_'.
          CREATE OBJECT lo_object
            EXPORTING
              id_anwendung = md_anwendung
              id_akt       = ld_aktivitaet.

*     Set Selektionstabelle und Anzeige-Struktur
          lo_object->m_tabname         = ls_dienstl_x-tabname.
          lo_object->m_disp_struc_name = ls_dienstl_x-disp_structname.
          lo_object->m_caption         = ls_dienstl_x-dienstleistbez. "default capt.
*     create outtab dynamically
          CREATE DATA lo_object->mdt_outtab
                TYPE STANDARD TABLE OF (lo_object->m_disp_struc_name).

          lo_object->zif_dpd_tree_object~ms_node-relatkey =
          me->zif_dpd_tree_object~ms_node-node_key.
          APPEND lo_object TO rt_new_objects.



          " Liste Ändern
          CONCATENATE md_anwendung 'AEND' INTO ld_aktivitaet SEPARATED BY '_'.
          CREATE OBJECT lo_object
            EXPORTING
              id_anwendung = md_anwendung
              id_akt       = ld_aktivitaet.

*     Set Selektionstabelle und Anzeige-Struktur
          lo_object->m_tabname         = ls_dienstl_x-tabname.
          lo_object->m_disp_struc_name = ls_dienstl_x-disp_structname.
          lo_object->m_caption         = ls_dienstl_x-dienstleistbez. "default capt.
*     create outtab dynamically
          CREATE DATA lo_object->mdt_outtab
                TYPE STANDARD TABLE OF (lo_object->m_disp_struc_name).

          lo_object->zif_dpd_tree_object~ms_node-relatkey =
          me->zif_dpd_tree_object~ms_node-node_key.
          APPEND lo_object TO rt_new_objects.




          " Anzeigen Lieste
          CONCATENATE md_anwendung 'ANZ' INTO ld_aktivitaet SEPARATED BY '_'.
          CREATE OBJECT lo_object
            EXPORTING
              id_anwendung = md_anwendung
              id_akt       = ld_aktivitaet.

*     Set Selektionstabelle und Anzeige-Struktur
          lo_object->m_tabname         = ls_dienstl_x-tabname.
          lo_object->m_disp_struc_name = ls_dienstl_x-disp_structname.
          lo_object->m_caption         = ls_dienstl_x-dienstleistbez. "default capt.
*     create outtab dynamically
          CREATE DATA lo_object->mdt_outtab
                TYPE STANDARD TABLE OF (lo_object->m_disp_struc_name).

          lo_object->zif_dpd_tree_object~ms_node-relatkey =
          me->zif_dpd_tree_object~ms_node-node_key.
          APPEND lo_object TO rt_new_objects.

          " E.Firsanov Die Nods sind Obsolet. Excel-Aktivitäten sien in GUI-ALV integriert
*          " Set Dienstleistung
*          CONCATENATE MD_ANWENDUNG 'SET' INTO LD_AKTIVITAET SEPARATED BY '_'.
*          CREATE OBJECT LO_OBJECT
*            EXPORTING
*              ID_ANWENDUNG = MD_ANWENDUNG
*              ID_AKT       = LD_AKTIVITAET.
*
**     Set Selektionstabelle und Anzeige-Struktur
*          LO_OBJECT->M_TABNAME         = LS_DIENSTL_X-TABNAME.
*          LO_OBJECT->M_DISP_STRUC_NAME = LS_DIENSTL_X-DISP_STRUCTNAME.
*          LO_OBJECT->M_CAPTION         = LS_DIENSTL_X-DIENSTLEISTBEZ. "default capt.
**     create outtab dynamically
*          CREATE DATA LO_OBJECT->MDT_OUTTAB
*                TYPE STANDARD TABLE OF (LO_OBJECT->M_DISP_STRUC_NAME).
*
*          LO_OBJECT->ZIF_DPD_TREE_OBJECT~MS_NODE-RELATKEY =
*          ME->ZIF_DPD_TREE_OBJECT~MS_NODE-NODE_KEY.
*          APPEND LO_OBJECT TO RT_NEW_OBJECTS.

*****************************************************************************************
**         Set Subaktivitäten für Upload/Download
*          LD_AKTIVITAET_PARENT = LD_AKTIVITAET.
*
*          CONCATENATE MD_ANWENDUNG 'DOW' INTO LD_AKTIVITAET SEPARATED BY '_'.
*          CREATE OBJECT LO_OBJECT
*            EXPORTING
*              ID_ANWENDUNG = MD_ANWENDUNG
*              ID_AKT       = LD_AKTIVITAET.
*
**         Set Selektionstabelle und Anzeige-Struktur
*          LO_OBJECT->M_TABNAME         = LS_DIENSTL_X-TABNAME.
*          LO_OBJECT->M_DISP_STRUC_NAME = 'ZST_MEAS_EXCEL_ULOAD'.
*          LO_OBJECT->M_CAPTION         = LS_DIENSTL_X-DIENSTLEISTBEZ. "default capt.
**         create outtab dynamically
*          CREATE DATA LO_OBJECT->MDT_OUTTAB
*                TYPE STANDARD TABLE OF (LO_OBJECT->M_DISP_STRUC_NAME).
*
*          LO_OBJECT->ZIF_DPD_TREE_OBJECT~MS_NODE-RELATKEY = LD_AKTIVITAET_PARENT.
*          APPEND LO_OBJECT TO RT_NEW_OBJECTS.
*
*          CONCATENATE MD_ANWENDUNG 'UPL' INTO LD_AKTIVITAET SEPARATED BY '_'.
*          CREATE OBJECT LO_OBJECT
*            EXPORTING
*              ID_ANWENDUNG = MD_ANWENDUNG
*              ID_AKT       = LD_AKTIVITAET.
*
**     Set Selektionstabelle und Anzeige-Struktur
*          LO_OBJECT->M_TABNAME         = LS_DIENSTL_X-TABNAME.
*          LO_OBJECT->M_DISP_STRUC_NAME = LS_DIENSTL_X-DISP_STRUCTNAME.
*          LO_OBJECT->M_CAPTION         = LS_DIENSTL_X-DIENSTLEISTBEZ. "default capt.
**     create outtab dynamically
*          CREATE DATA LO_OBJECT->MDT_OUTTAB
*                TYPE STANDARD TABLE OF (LO_OBJECT->M_DISP_STRUC_NAME).
*
*          LO_OBJECT->ZIF_DPD_TREE_OBJECT~MS_NODE-RELATKEY = LD_AKTIVITAET_PARENT.
*          APPEND LO_OBJECT TO RT_NEW_OBJECTS.

***********************************************************************************************

          " Serviceprogramme
          CONCATENATE md_anwendung 'HELP' INTO ld_aktivitaet SEPARATED BY '_'.

          CREATE OBJECT lo_object
            EXPORTING
              id_anwendung = md_anwendung
              id_akt       = ld_aktivitaet.

*     Set Selektionstabelle und Anzeige-Struktur
          lo_object->m_tabname         = ls_dienstl_x-tabname.
          lo_object->m_disp_struc_name = ls_dienstl_x-disp_structname.
          lo_object->m_caption         = ls_dienstl_x-dienstleistbez. "default capt.
*     create outtab dynamically
          CREATE DATA lo_object->mdt_outtab
                TYPE STANDARD TABLE OF (lo_object->m_disp_struc_name).

          lo_object->zif_dpd_tree_object~ms_node-relatkey =
          me->zif_dpd_tree_object~ms_node-node_key.
          APPEND lo_object TO rt_new_objects.



        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "zif_dpd_tree_object~get_sub_objects

  METHOD get_re_objekte.
  ENDMETHOD.                    "GET_RE_OBJEKTE
  METHOD la_get_commands.
* DATA RT_COMMANDS TYPE TTB_BUTTON.

* CALL METHOD SUPER->ZIF_DPD_TREE_OBJECT~GET_COMMANDS( ).

    DATA: ls_button     TYPE stb_button.

**   'save' button
*    CLEAR LS_BUTTON.
*    LS_BUTTON-BUTN_TYPE = 0.  "button
*    LS_BUTTON-FUNCTION  = 'MEAS_SAVE'.
*    LS_BUTTON-ICON      = ICON_SYSTEM_SAVE.
*    LS_BUTTON-QUICKINFO = 'Sichern'.
*    LS_BUTTON-TEXT      = 'Sichern'.
*    APPEND LS_BUTTON TO RT_COMMANDS.

    IF me->md_akt = 'MEAS_ANL' OR me->md_akt = 'MEAS_AEND'.
*   'Separator' button
      CLEAR ls_button.
      ls_button-butn_type = 3.  "separator
      APPEND ls_button TO rt_commands.

*   'Delete' button
      CLEAR ls_button.
      ls_button-butn_type = 0.  "button
      ls_button-function  = 'MEAS_DELETE'.
      ls_button-icon      = icon_delete.
      ls_button-quickinfo = 'Eintrag löschen'.
      ls_button-text      = 'Eintrag löschen'.
      APPEND ls_button TO rt_commands.

    ENDIF.

*   'Separator' button
    CLEAR ls_button.
    ls_button-butn_type = 3.  "separator
    APPEND ls_button TO rt_commands.


*'refresh' button
    CLEAR ls_button.
    ls_button-butn_type = 0.  "button
    ls_button-function  = zif_dpd_tree_object~mc_refresh.
    ls_button-icon      = icon_refresh.
    ls_button-quickinfo = 'Daten aktualisieren'.
    ls_button-text      = 'Aktualisieren'.
    APPEND ls_button TO rt_commands.



  ENDMETHOD.                    "LA_GET_COMMANDS
  METHOD la_user_command.

*********** 'MEAS_ANL' *************************
*    DATA RO_INSTANCE       TYPE REF TO ZIF_PD_ZTEXD_FLACHE_MNGR.

    CALL FUNCTION 'RECA_GUI_MSGLIST_INIT'.

    CASE i_ucomm.

      WHEN 'MEAS_DELETE'.

        me->meas_delete(
        EXPORTING
          i_ucomm       = i_ucomm
          it_tabix      = it_tabix
          it_good_cells = it_good_cells
        IMPORTING
          cd_refresch   = cd_refresch
          ).

      WHEN 'CMD_ZIF_DPD_TREE_OBJECT_OPEN'.

        CASE md_akt.

          WHEN 'MEAS_ANL'.

            " Buffer initialisieren
            CLEAR: gs_gui_buffer-mo_meas.

            me->meas_anl(
              EXPORTING
                i_ucomm       = i_ucomm
                it_tabix      = it_tabix
                it_good_cells = it_good_cells
              IMPORTING
                cd_refresch   = cd_refresch
                ).


          WHEN 'MEAS_ANZ'.

            " Buffer initialisieren
            CLEAR: gs_gui_buffer-mo_meas.

*           Refresh aufrufen
            me->refresh_meas(
              EXPORTING
                id_activity = reca1_activity-display
              EXCEPTIONS
              error  = 1
              OTHERS = 2
              ).
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
            ENDIF.


          WHEN 'MEAS_AEND'.


            " Buffer initialisieren
            CLEAR: gs_gui_buffer-mo_meas.

*           Refresh aufrufen
            me->refresh_meas(
            EXPORTING
              id_activity = reca1_activity-change
            EXCEPTIONS
              error  = 1
              OTHERS = 2
              ).
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
            ENDIF.


          WHEN 'MEAS_DOW'. " Excel Download

            " Buffer initialisieren
            CLEAR: gs_gui_buffer-mo_meas.

            me->meas_dow(
            EXPORTING
              i_ucomm       = i_ucomm
              it_tabix      = it_tabix
              it_good_cells = it_good_cells
            IMPORTING
              cd_refresch   = cd_refresch
              ).

          WHEN 'MEAS_UPL'. " Excel Upload

            " Buffer initialisieren
            CLEAR: gs_gui_buffer-mo_meas.

            me->meas_set_excel(
            EXPORTING
              i_ucomm       = i_ucomm
              it_tabix      = it_tabix
              it_good_cells = it_good_cells
            IMPORTING
              cd_refresch   = cd_refresch
              ).


        ENDCASE.
      WHEN OTHERS.
        IF i_ucomm = 'CMD_ZIF_DPD_TREE_OBJECT_REFRESH' AND me->gs_gui_buffer-mo_meas IS BOUND.

*        Refresh aufrufen
          me->refresh_meas(
           EXPORTING
             id_activity = gs_gui_buffer-mo_meas->md_activity
           EXCEPTIONS
             error  = 1
             OTHERS = 2
             ).
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
          ENDIF.
        ELSE.
          CALL METHOD super->zif_dpd_tree_object~user_command
            EXPORTING
              i_ucomm = i_ucomm.
        ENDIF.
    ENDCASE.

  ENDMETHOD.                    "LA_USER_COMMAND

  METHOD on_hotspot_click.
*  E_ROW_ID Importing Type  LVC_S_ROW
*  E_COLUMN_ID  Importing Type  LVC_S_COL
*  ES_ROW_NO  Importing Type  LVC_S_ROID
*  ED_AKTIVITY  Importing Type  RECA1_ACTIVITY


  ENDMETHOD.                    "ON_HOTSPOT_CLICK
  METHOD refresh.
    CALL METHOD super->refresh.
  ENDMETHOD.                    "REFRESH

  METHOD refresh_meas.

    DATA:  lt_tab        TYPE z_t_ztexd_flache.

*********** 'MEAS_ANL' *************************
    DATA  ef_cancel      TYPE abap_bool.
    DATA: et_objektliste TYPE z_t_zst_objektliste,
          ls_objektliste LIKE LINE OF et_objektliste,
          p_lief         TYPE zcus_extlief-ext_dienstlif,
          p_meas         TYPE zcus_extmeas-meas,
          p_date         TYPE sy-datum.
*********** 'MEAS_ANL' *************************
*    DATA RO_INSTANCE       TYPE REF TO ZIF_PD_ZTEXD_FLACHE_MNGR.

*
    FIELD-SYMBOLS: <outtab>     TYPE  z_t_ztexd_flache_x,
                   <table_line> LIKE LINE OF <outtab>.

    DATA: lo_msglist       TYPE REF TO if_reca_message_list.
    DATA: lf_exists    TYPE recabool.

*   Get Messagesammler
    CALL METHOD cf_reca_message_list=>create
      RECEIVING
        ro_instance = lo_msglist.


    ASSIGN me->mdt_outtab->* TO <outtab>.

    CLEAR <outtab>[].

    IF gs_gui_buffer-mo_meas IS NOT BOUND.
      CALL FUNCTION 'ZFB_GUI_GENERIC_SELECT_OBJEKT'
        EXPORTING
          id_activity       = id_activity
          id_dienstleistung = 'MEAS'
        IMPORTING
          ef_cancel         = ef_cancel
          et_objektliste    = et_objektliste
          et_tab            = lt_tab.

*           Bearbeitung durch Benutzer abgebrochen
      IF ef_cancel = abap_true.
        RETURN.
      ENDIF.

*           Die Selektion ist leer
      IF lt_tab[] IS INITIAL.
        MESSAGE s002 DISPLAY LIKE 'E'.
*     Keine Datensätze zu Ihrer Selektion gefunden.
        RETURN.
      ENDIF.
    ENDIF.

    IF gs_gui_buffer-mo_meas IS NOT BOUND.
*   Finden Dienstleistungsmanager
      zcf_pd_ztexd_flache_mngr=>find_by_tab(
      EXPORTING
        id_dienstleistung = 'MEAS'
        it_tab            = lt_tab
        id_activity       = id_activity
        id_auth_check     = abap_true
        id_enqueue        = abap_true
        RECEIVING
        ro_instance       = gs_gui_buffer-mo_meas
      EXCEPTIONS
        error             = 1
        OTHERS            = 2
        ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.
    ENDIF.

    IF gs_gui_buffer-mo_meas IS BOUND.
*     Get Ausgabetabelle
      gs_gui_buffer-mo_meas->get_list_x(
        IMPORTING
          et_list_x = <outtab>
             ).
    ENDIF.

    CALL METHOD lo_msglist->has_messages_of_msgty
      EXPORTING
        id_msgty  = 'E'
      RECEIVING
        rf_exists = lf_exists.

    IF lf_exists = abap_true.

      PERFORM show_message_list IN PROGRAM saplzfg_ext_dienstleist
      USING lo_msglist.

    ENDIF.

    CLEAR lo_msglist.

  ENDMETHOD.                    "REFRESH

  METHOD la_adapt_fieldcatalog.
    mac_alv_fc_init ct_fieldcatalog.

    IF me->md_akt = 'MEAS_DOW' .
      LOOP AT <lt_fieldcatalog> ASSIGNING <ls_fieldcatalog>.
        CASE <ls_fieldcatalog>-fieldname.
*       Ausblenden Tech.
          WHEN
          'GUID'.
            <ls_fieldcatalog>-tech   = abap_true.
        ENDCASE.
      ENDLOOP.
    ELSE.
      LOOP AT <lt_fieldcatalog> ASSIGNING <ls_fieldcatalog>.
        CASE <ls_fieldcatalog>-fieldname.
*       Ausblenden Tech.
          WHEN
                  'COLORTAB'  OR
                  'STYLETAB'  OR
                  'ME_UPDATE_FLAG' OR
                  'SNUNR'     OR
                  'IDENT'     OR
                  'OBJNR'     OR
                  'MEAS_GUID' OR
                  'RERF'      OR
                  'DERF'      OR
                  'TERF'      OR
                  'REHER'     OR
                  'RBEAR'     OR
                  'DBEAR'     OR
                  'TBEAR'     OR
                  'RBHER'.
            <ls_fieldcatalog>-tech   = abap_true.

            " Ausblenden NO_OUT
          WHEN 'SGRNR' OR
               'KDST'.
            <ls_fieldcatalog>-no_out   = abap_true.
            " Set Eigenschaften
          WHEN 'ME_UPDATE'.
            mac_alv_fc_set_text 'Updateinfo'.
          WHEN 'DIENSTLEISTUNG'.
            <ls_fieldcatalog>-key        = abap_true.
            <ls_fieldcatalog>-key_sel    = abap_true.
            <ls_fieldcatalog>-fix_column = abap_true.
          WHEN 'MEAS'.
            <ls_fieldcatalog>-key     = abap_true.
            <ls_fieldcatalog>-fix_column = abap_true.
          WHEN 'BUKRS'.
            <ls_fieldcatalog>-key     = abap_true.
            <ls_fieldcatalog>-fix_column = abap_true.
          WHEN 'SWENR'.
            <ls_fieldcatalog>-key     = abap_true.
            <ls_fieldcatalog>-fix_column = abap_true.
          WHEN 'SGRNR'.
            <ls_fieldcatalog>-fix_column = abap_true.
            <ls_fieldcatalog>-key     = abap_true.
          WHEN 'SGENR'.
            <ls_fieldcatalog>-key     = abap_true.
            <ls_fieldcatalog>-fix_column = abap_true.
          WHEN 'SMENR'.
            <ls_fieldcatalog>-key     = abap_true.
            <ls_fieldcatalog>-fix_column = abap_true.
          WHEN 'MEASVALUE'.
            <ls_fieldcatalog>-emphasize = 'C100'.
          WHEN 'MEASUNIT'.
            <ls_fieldcatalog>-emphasize = 'C100'.
          WHEN 'VALIDTO'.
            <ls_fieldcatalog>-emphasize = 'C100'.
          WHEN 'AKTIVITAET'.
            <ls_fieldcatalog>-emphasize = 'C500'.
          WHEN 'MEASVALUE_NEU'.
            mac_alv_fc_set_text 'Größe neu'.
            <ls_fieldcatalog>-emphasize = 'C500'.
          WHEN 'MEASUNIT_NEU'.
            mac_alv_fc_set_text 'Einh neu'.
            <ls_fieldcatalog>-emphasize = 'C500'.
          WHEN 'VALIDFROM'.
            mac_alv_fc_set_text 'Gültig ab neu'.
            <ls_fieldcatalog>-emphasize = 'C500'.
          WHEN 'EXT_FERTDAT'.
            <ls_fieldcatalog>-emphasize = 'C500'.
          WHEN   'XKSNUNR'.
            mac_alv_fc_set_text 'Nutzungsart'.
          WHEN 'ICON_DETAIL'.
            mac_alv_fc_set_text 'Status'.
            <ls_fieldcatalog>-fix_column = abap_true.

          WHEN 'ZCOUNT'.
            <ls_fieldcatalog>-do_sum = abap_true.
        ENDCASE.
      ENDLOOP.

      mac_alv_fc_pos_set:
  'ICON_DETAIL',
  'DIENSTLEISTUNG',
  'MEAS',
  'BUKRS',
  'SWENR',
  'SGRNR',
  'SGENR',
  'SMENR',
  'KDST',
'XKSNUNR',
  'ZCOUNT',
  'STICHTAG',
  'EXT_DIENSTLIF',
  'EXT_AENDGRUND',
  'PROJEKTNAME',
  'IDENT',
  'XSMEAS',
  'MEASVALUE',
  'MEASUNIT',
  'VALIDTO',
  'AKTIVITAET',
  'EXT_FERTDAT',
  'MEASVALUE_NEU',
  'MEASUNIT_NEU',
  'VALIDFROM',
  'ME_UPDATE',
  'AUFTR_VERM'.
    ENDIF.
  ENDMETHOD.                    "LA_ADAPT_FIELDCATALOG
  METHOD get_selectoptions.
    DATA: ls_seloption TYPE bapi_re_seloption_int,
          ld_datum     TYPE sy-datum.



  ENDMETHOD.                    "GET_SELECTOPTIONS

  METHOD la_adapt_sort.
    "   Changing
    "    CT_SORT   Type  LVC_T_SORT

    DATA: ls_sort LIKE LINE OF ct_sort,
          lt_sort TYPE  lvc_t_sort.

    ls_sort-spos      = 1.
    ls_sort-fieldname = 'BUKRS'.
    ls_sort-subtot    = abap_false.
    APPEND ls_sort TO ct_sort.

    ls_sort-spos      = 2.
    ls_sort-fieldname = 'SWENR'.
    ls_sort-subtot    = abap_true.
    APPEND ls_sort TO ct_sort.

    ls_sort-spos      = 3.
    ls_sort-fieldname = 'EXT_DIENSTLIF'.
    ls_sort-subtot    = abap_false.
    APPEND ls_sort TO ct_sort.


  ENDMETHOD.                    "LA_ADAPT_SORT
  METHOD meas_anl.

    DATA: ls_tabix TYPE sytabix,
          dummy    TYPE string.
    DATA:  id_userkz    TYPE zuserkz.
    DATA:  lt_guid      TYPE re_t_guid.

***********'MEAS_ANL' *************************
    DATA: ef_cancel      TYPE abap_bool.
    DATA: et_objektliste TYPE z_t_zst_objektliste,
          ls_objektliste LIKE LINE OF et_objektliste,
          p_lief         TYPE zcus_extlief-ext_dienstlif,
          p_meas         TYPE zcus_extmeas-meas,
          p_date         TYPE sy-datum,
          p_andgr	       TYPE	ztexd_flache-ext_aendgrund,
          p_proj         TYPE ztexd_flache-projektname,
          p_auftr	       TYPE	ztexd_flache-auftr_verm.



    DATA: lo_msglist       TYPE REF TO if_reca_message_list.
    DATA: lf_exists    TYPE recabool.

*   Get Messagesammler
    CALL METHOD cf_reca_message_list=>create
      RECEIVING
        ro_instance = lo_msglist.


*   Finden Dienstleistungsmanager
    zcf_pd_ztexd_flache_mngr=>find_by_dienstleistung(
    EXPORTING
      id_dienstleistung = 'MEAS'
      id_activity       = reca1_activity-create
      id_auth_check     = abap_true
      id_enqueue        = abap_false
      RECEIVING
      ro_instance       = gs_gui_buffer-mo_meas
    EXCEPTIONS
      error             = 1
      OTHERS            = 2
      ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.


    CALL FUNCTION 'ZFB_GUI_GENERIC_SELECT_OBJEKT'
      EXPORTING
        id_activity       = reca1_activity-create
        id_dienstleistung = gs_gui_buffer-mo_meas->md_dienstleistung
      IMPORTING
        ef_cancel         = ef_cancel
        et_objektliste    = et_objektliste
        p_lief            = p_lief
        p_date            = p_date
        p_andgr           = p_andgr
        p_proj            = p_proj
        p_auftr           = p_auftr.


*   Bearbeitung durch Benutzer abgebrochen
    IF ef_cancel = abap_true.
      RETURN.
    ENDIF.


*   Die Selektion ist leer
    IF et_objektliste[] IS INITIAL.
      MESSAGE s002 DISPLAY LIKE 'E'.
*     Keine Datensätze zu Ihrer Selektion gefunden.
      RETURN.
    ENDIF.


    LOOP AT et_objektliste INTO ls_objektliste.

      gs_gui_buffer-mo_meas->objektliste_create(
      EXPORTING
        id_dienstleistung = gs_gui_buffer-mo_meas->md_dienstleistung
        id_lief           = p_lief
        id_seldate        = p_date
        id_andgr          = p_andgr
        id_proj           = p_proj
        id_auftr          = p_auftr
        ist_objektliste   = ls_objektliste
        io_msglist        = lo_msglist
      EXCEPTIONS
        error             = 1
        OTHERS            = 2
        ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        INTO dummy.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
        CONTINUE.
      ENDIF.

    ENDLOOP.

    IF gs_gui_buffer-mo_meas->is_modified( ) = abap_true.
      gs_gui_buffer-mo_meas->store(
      EXPORTING
        if_in_update_task = abap_false
        if_force_check    = abap_false
      EXCEPTIONS
        error             = 1
        OTHERS            = 2
        ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        INTO dummy.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.
    ENDIF.

*   Refresh aufrufen
    me->refresh_meas(
    EXPORTING
      id_activity = reca1_activity-change
    EXCEPTIONS
      error  = 1
      OTHERS = 2
      ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
    ENDIF.

    CALL METHOD lo_msglist->has_messages_of_msgty
      EXPORTING
        id_msgty  = 'E'
      RECEIVING
        rf_exists = lf_exists.

    IF lf_exists = abap_true.

      PERFORM show_message_list IN PROGRAM saplzfg_ext_dienstleist
        USING lo_msglist.

    ENDIF.

    CLEAR lo_msglist.
  ENDMETHOD.                    "MEAS_anl

  METHOD meas_delete.
    "  IMPORTING
    "     I_UCOMM	      TYPE  SY-UCOMM
    "     IT_TABIX      TYPE  RE_T_TABIX
    "     IT_GOOD_CELLS TYPE  LVC_T_MODI.

    DATA: ls_index         LIKE LINE OF it_tabix.
    DATA: dummy            TYPE string.
    DATA:
          lo_msglist       TYPE REF TO if_reca_message_list.


    FIELD-SYMBOLS: <outtab>     TYPE  z_t_ztexd_flache_x,
                   <table_line> LIKE LINE OF <outtab>.


    ASSIGN me->mdt_outtab->* TO <outtab>.


    IF it_tabix[] IS INITIAL.
      MESSAGE i003 DISPLAY LIKE 'E'.
*         Markieren Sie mindestens einen Eintrag in der Liste
      RETURN.
    ENDIF.


    CALL FUNCTION 'RECA_GUI_MSGLIST_INIT'.


*   Get Messagesammler
    CALL METHOD cf_reca_message_list=>create
      RECEIVING
        ro_instance = lo_msglist.



    LOOP AT it_tabix INTO ls_index.

      READ TABLE <outtab> ASSIGNING <table_line> INDEX ls_index.


      gs_gui_buffer-mo_meas->objektliste_delete(
      EXPORTING
        is_key   = <table_line>-key
      EXCEPTIONS
        error   = 1
        OTHERS  = 2
        ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        INTO dummy.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.



    ENDLOOP.




    IF gs_gui_buffer-mo_meas->is_modified( ) = abap_true AND
      lo_msglist->has_messages_of_msgty(
          id_msgty     = 'E'
          if_or_higher = abap_true
             ) = abap_false.

      gs_gui_buffer-mo_meas->store(
        EXPORTING
          if_in_update_task = abap_false
          if_force_check    = abap_false
        EXCEPTIONS
          error             = 1
          OTHERS            = 2
          ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        INTO dummy.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.
    ENDIF.

*  TO-DO Messageausgabe

*   Get Ausgabetabelle
    gs_gui_buffer-mo_meas->get_list_x(
    IMPORTING
      et_list_x = <outtab>
      ).

    cd_refresch = abap_true.

    CLEAR lo_msglist.


  ENDMETHOD.                    "MEAS_DELETE

  METHOD meas_set_excel.

    DATA:  lt_tab      TYPE z_t_ztexd_flache.
    DATA:  ld_upd_flag  TYPE flag.

*********** 'MEAS_ANL' *************************
    DATA  ef_cancel      TYPE abap_bool.
    DATA: et_objektliste TYPE z_t_zst_objektliste,
          ls_objektliste LIKE LINE OF et_objektliste,
          p_lief         TYPE zcus_extlief-ext_dienstlif,
          p_meas         TYPE zcus_extmeas-meas,
          p_date         TYPE sy-datum.
*********** 'MEAS_ANL' *************************
    DATA: ld_dienstleistung         TYPE zddienstleistung.

    " Set Dienstleistung
    ld_dienstleistung = md_anwendung.

*
    FIELD-SYMBOLS: <outtab>     TYPE  z_t_ztexd_flache_x,
                   <table_line> LIKE LINE OF <outtab>.

    DATA: lo_msglist       TYPE REF TO if_reca_message_list.
    DATA: lf_exists TYPE recabool,
          dummy     TYPE string.

*   Get Messagesammler
    CALL METHOD cf_reca_message_list=>create
      RECEIVING
        ro_instance = lo_msglist.


    ASSIGN me->mdt_outtab->* TO <outtab>.

    CLEAR <outtab>[].


    IF gs_gui_buffer-mo_meas IS NOT BOUND.
*     Finden Dienstleistungsmanager
      zcf_pd_ztexd_flache_mngr=>find_by_tab(
       EXPORTING
         id_dienstleistung = ld_dienstleistung
         it_tab            = lt_tab
         id_activity       = reca1_activity-change
         id_auth_check     = abap_true
         id_enqueue        = abap_true
         RECEIVING
         ro_instance       = gs_gui_buffer-mo_meas
       EXCEPTIONS
         error             = 1
         OTHERS            = 2
         ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.
    ENDIF.

*****************************************************************************
    DATA: ld_filename   TYPE string,
          ld_filelength TYPE i.
    DATA: anz_zeilen    TYPE i.
    DATA: anz_spalten_i TYPE i VALUE '29'.
    DATA: lt_excel_hlp  TYPE ztabline,
          lt_excel_hash TYPE z_t_dyn_dta_h,
          filename      TYPE rlgrap-filename.

    DATA: ld_path        TYPE sapb-sappoolinf,
          lt_excel_uload TYPE z_t_zst_meas_excel_uload.
    FIELD-SYMBOLS:
          <ls_excel_uload> LIKE LINE OF lt_excel_uload.


    DATA: ld_direktory   TYPE string.

*   Verzeichnis von Exceldateien
    DATA: et_cus_directory TYPE z_t_zcus_extdirect,
          ls_cus_directory LIKE LINE OF et_cus_directory.

    zcl_cust_zcus_extdirect=>get_list_by_dienstleistung(
      EXPORTING
        id_dienstleistung = ld_dienstleistung
      IMPORTING
        et_list           = et_cus_directory
      EXCEPTIONS
        not_found         = 1
        OTHERS            = 2
           ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error.
    ENDIF.

    READ TABLE et_cus_directory INTO ls_cus_directory INDEX 1.
    ld_direktory = ls_cus_directory-ext_dierectory.

*   Datainame übergeben
    zcl_dta_services=>get_path(
    EXPORTING
      initial_directory = ld_direktory
    CHANGING
      path              = ld_path
      ).

    ld_filename = ld_path.

    IF NOT ld_filename IS INITIAL.
      anz_zeilen = 65536.                "max. Grenze
      CLEAR filename.
      filename = ld_filename.
      CALL FUNCTION 'Z_EXCEL_TO_INTERNAL_TABLE'
        EXPORTING
          filename                = filename
          i_begin_col             = 1
          i_begin_row             = 1
          i_end_col               = anz_spalten_i
          i_end_row               = anz_zeilen
        TABLES
          intern                  = lt_excel_hlp
        EXCEPTIONS
          inconsistent_parameters = 1
          upload_ole              = 2
          OTHERS                  = 3.

      IF sy-subrc <> 0.
        MESSAGE i026(za) WITH ld_filename DISPLAY LIKE 'E'.
      ELSE.
*     Hashedtabelle aufbereiten
        INSERT LINES OF lt_excel_hlp INTO TABLE lt_excel_hash.
*     Excelmastertabelle aufbereiten
        set_excel(
         EXPORTING
           it_excel       = lt_excel_hash
         IMPORTING
           et_excel_uload = lt_excel_uload
           ).

      ENDIF.
    ENDIF.

*****************************************************************************
*   Zum Lieferant die zugeordnete Objekte lesen
    DATA: et_obj_lieferant_list TYPE z_t_ztexd_flache,
          ls_obj_lieferant_list LIKE LINE OF et_obj_lieferant_list.
    DATA: ld_text           TYPE string.

    zcl_get_ztexd_flache=>get_list_by_dienstleistung(
      EXPORTING
        id_dienstleistung   = ld_dienstleistung
        if_bypassing_buffer = abap_true
      IMPORTING
        et_list             = et_obj_lieferant_list
           ).

*    DELETE ET_OBJ_LIEFERANT_LIST WHERE  ( ME_UPDATE_FLAG = ABAP_TRUE ).

    REFRESH lt_tab[].

    LOOP AT lt_excel_uload ASSIGNING <ls_excel_uload>.
*     Check zuordnung zum Lieferant exists?
      READ TABLE et_obj_lieferant_list INTO ls_obj_lieferant_list WITH KEY
      meas          = <ls_excel_uload>-meas
      bukrs         = <ls_excel_uload>-bukrs
      sgenr         = <ls_excel_uload>-sgenr
      sgrnr         = <ls_excel_uload>-sgrnr
      smenr         = <ls_excel_uload>-smenr
      ext_dienstlif = <ls_excel_uload>-ext_dienstlif
      measvalue     = <ls_excel_uload>-measvalue.
      IF sy-subrc = 0.
        INSERT ls_obj_lieferant_list INTO TABLE lt_tab.
        <ls_excel_uload>-guid = ls_obj_lieferant_list-meas_guid.
        IF ls_obj_lieferant_list-me_update_flag = abap_true.
*          APPEND LS_OBJ_LIEFERANT_LIST-MEAS_GUID TO LT_GUID.
*          <LS_EXCEL_ULOAD>-GUID = LS_OBJ_LIEFERANT_LIST-MEAS_GUID.
*        ELSE.
          CONCATENATE <ls_excel_uload>-bukrs <ls_excel_uload>-sgenr  <ls_excel_uload>-smenr
          INTO ld_text SEPARATED BY '/'.
          CONCATENATE 'ME' ld_text 'Bemes:' <ls_excel_uload>-meas INTO ld_text SEPARATED BY ' '.
          MESSAGE w009 WITH ld_text ls_obj_lieferant_list-me_update INTO dummy.
*         Excel-Eintrag & wurde & importiert.
          lo_msglist->add_symsg( if_cumulate = abap_true ).
        ENDIF.
      ELSE.
        CONCATENATE <ls_excel_uload>-bukrs <ls_excel_uload>-sgenr  <ls_excel_uload>-smenr
         INTO ld_text SEPARATED BY '/'.
        CONCATENATE 'ME' ld_text 'Bemes:' <ls_excel_uload>-meas INTO ld_text SEPARATED BY ' '.
        MESSAGE e006 WITH ld_text 'ZTEXD_FLACHE' INTO dummy.
*       Excel-Eintrag & in die Tab. "&" wurde nicht gefunden. Bitte überprüfen.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.
    ENDLOOP.

    IF lt_tab[] IS NOT INITIAL.

      DATA id_activity       TYPE reca1_activity.

      zcf_pd_ztexd_flache_mngr=>find_by_tab(
        EXPORTING
          id_dienstleistung = ld_dienstleistung
          it_tab            = lt_tab
          id_activity       = reca1_activity-change
          id_auth_check     = abap_true
          id_enqueue        = abap_true
        RECEIVING
          ro_instance       = gs_gui_buffer-mo_meas
        EXCEPTIONS
          error             = 1
          OTHERS            = 2
             ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        INTO dummy.
        lo_msglist->add_symsg( if_cumulate = abap_true ).
      ENDIF.

      DATA: et_list TYPE z_t_ztexd_flache,
            ls_list LIKE LINE OF et_list.
      DATA id_aktivitaet      TYPE zcust_zcus_aktivit-aktivitaet.
      DATA rs_cus_aktivit     TYPE zcust_zcus_aktivit.


      gs_gui_buffer-mo_meas->get_list(
        IMPORTING
          et_list = et_list
             ).

*     Set Exceldaten in Objektliste
      LOOP AT et_list INTO ls_list WHERE me_update_flag = abap_false.
        " Messagesammler cleren
        lo_msglist->clear( ).
        READ TABLE lt_excel_uload ASSIGNING <ls_excel_uload> WITH KEY guid = ls_list-meas_guid.
        CHECK sy-subrc = 0.
        CLEAR ls_list-me_update.
        ls_list-aktivitaet    = <ls_excel_uload>-aktivitaet.
        " Check Aktivität
        id_aktivitaet = ls_list-aktivitaet.
        zcl_cust_zcus_aktivit=>get_detail(
          EXPORTING
            id_aktivitaet = id_aktivitaet
            id_require    = 'K'
          RECEIVING
            rs_detail     = rs_cus_aktivit
          EXCEPTIONS
            not_found     = 1
            OTHERS        = 2
               ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          INTO dummy.
          lo_msglist->add_symsg( if_cumulate = abap_true ).
          CLEAR ls_list-aktivitaet.
          ls_list-me_update = 'FEHLER: AKTIVITAET'.
        ENDIF.

        "  Update Infofelde
        ls_list-projektname   = <ls_excel_uload>-projektname.
        ls_list-ext_aendgrund = <ls_excel_uload>-ext_aendgrund.
        ls_list-auftr_verm    = <ls_excel_uload>-auftr_verm.
        "  Update Arbeitsfelder
        ls_list-measvalue_neu = <ls_excel_uload>-measvalue_neu.
        ls_list-measunit_neu  = <ls_excel_uload>-measunit_neu.
        ls_list-ext_fertdat   = <ls_excel_uload>-ext_fertdat.
        ls_list-measvalidfrom = ls_list-ext_fertdat.

        " ist Value-Neu initial
        IF ls_list-measvalue_neu IS INITIAL.
          MESSAGE e007 WITH 'MEASVALUE_NEU' ls_list-ident INTO dummy.
*         Das Feld & ist leer. Bitte die Excel-Tabelle & überprüfen
          lo_msglist->add_symsg( if_cumulate = abap_true ).
          ls_list-me_update = 'FEHLER: MEASVALUE_NEU leer'.
        ENDIF.

        CLEAR: ld_upd_flag.

        CASE ls_list-aktivitaet.
*****************************************************************************************************
          WHEN 'ja'.
*****************************************************************************************************
            IF ls_list-me_status = 'fremdgenutzt'.

              ld_upd_flag = abap_false.

              " Validfrom vird nach der Kündigun das Kündigung zum übernehmen
              ls_list-measvalidfrom = '00000000'.

              IF  ls_list-me_update(6) <> 'FEHLER'.
                ls_list-me_update = 'Warten auf MV-Kündigung'.
              ENDIF.

            ELSE.

              ld_upd_flag = abap_true.

              " ist Validfrom Initial?
              IF cl_reca_date=>is_datefrom_initial( id_datefrom = ls_list-measvalidfrom ) = abap_true.
                MESSAGE e007 WITH 'VALIDFROM' ls_list-ident INTO dummy.
*               Das Feld & ist leer. Bitte die Excel-Tabelle & überprüfen
                lo_msglist->add_symsg( if_cumulate = abap_true ).
                ls_list-me_update = 'FEHLER: VALIDFROM leer'.
                ld_upd_flag = abap_false.
              ENDIF.

              IF  ls_list-me_update(6) = 'FEHLER'.
                ld_upd_flag = abap_false.
              ENDIF.

            ENDIF.
*****************************************************************************************************
          WHEN 'nein'.
*****************************************************************************************************
            ld_upd_flag = abap_false.
            ls_list-me_update = 'Update nicht erforderlich'.
            " Messagesammler cleren
            lo_msglist->clear( ).

*****************************************************************************************************
          WHEN 'sofort'.
*****************************************************************************************************

            ld_upd_flag = abap_true.

            " Validfrom leer? dann Systemdatum
            IF cl_reca_date=>is_datefrom_initial( id_datefrom = ls_list-measvalidfrom ) = abap_true.
              ls_list-measvalidfrom = sy-datum.
            ENDIF.

            IF  ls_list-me_update(6) = 'FEHLER'.
              ld_upd_flag = abap_false.
            ENDIF.

*****************************************************************************************************
          WHEN 'info'.
*****************************************************************************************************
            ld_upd_flag = abap_false.
            IF ls_list-me_status = 'fremdgenutzt'.
              ls_list-me_update = 'Warten auf MV-Kündigung'.
            ELSE.
              ls_list-me_update = 'FEHLER: Ínfo bei Leerstand'.
            ENDIF.
*****************************************************************************************************
        ENDCASE.




*       Bemessung pflegen
        IF ld_upd_flag = abap_true.
          " ME Bemessungen updaten
*          ZCL_EXTDIENST_SERVICES=>FLAECHE_ME_UPDATEN(
*            EXPORTING
*              IS_LIST           = LS_LIST
*              IO_MSGLIST        = LO_MSGLIST
*            CHANGING
*              CD_VALIDFROM      = LS_LIST-MEASVALIDFROM
*              CD_VALIDTO        = LS_LIST-MEASVALIDTO
*              CD_ME_UPDATE      = LS_LIST-ME_UPDATE
*              CD_ME_UPDATE_FLAG = LS_LIST-ME_UPDATE_FLAG
*            EXCEPTIONS
*              ERROR             = 1
*              OTHERS            = 2
*                 ).
*          IF SY-SUBRC <> 0.
*            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
*            INTO DUMMY.
*            LO_MSGLIST->ADD_SYMSG( IF_CUMULATE = ABAP_TRUE ).
*          ENDIF.

        ENDIF.



        gs_gui_buffer-mo_meas->objektliste_change(
          EXPORTING
            is_list = ls_list
          EXCEPTIONS
            error   = 1
            OTHERS  = 2
               ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        INTO dummy.
          lo_msglist->add_symsg( if_cumulate = abap_true ).
        ENDIF.


      ENDLOOP.

      IF gs_gui_buffer-mo_meas->is_modified( ) = abap_true.
        gs_gui_buffer-mo_meas->store(
        EXPORTING
          if_in_update_task = abap_false
          if_force_check    = abap_false
        EXCEPTIONS
          error             = 1
          OTHERS            = 2
          ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          INTO dummy.
          lo_msglist->add_symsg( if_cumulate = abap_true ).
        ENDIF.


        cf_reca_storable=>commit(
          EXPORTING
            if_wait             = abap_true
            if_bapi             = abap_true
               ).

      ENDIF.

*     Refresh aufrufen
      me->refresh_meas(
      EXPORTING
        id_activity = reca1_activity-change
      EXCEPTIONS
        error  = 1
        OTHERS = 2
        ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
      ENDIF.

    ENDIF.

    CALL METHOD lo_msglist->has_messages_of_msgty
      EXPORTING
        id_msgty  = 'W'
      RECEIVING
        rf_exists = lf_exists.

    IF lf_exists = abap_true.

      PERFORM show_message_list IN PROGRAM saplzfg_ext_dienstleist
      USING lo_msglist.

    ENDIF.

    CLEAR lo_msglist.

  ENDMETHOD.                    "MEAS_SET_EXCEL

  METHOD meas_dow.

    DATA:  lt_tab        TYPE z_t_ztexd_flache.

*********** 'MEAS_ANL' *************************
    DATA  ef_cancel      TYPE abap_bool.
    DATA: et_objektliste TYPE z_t_zst_objektliste,
          ls_objektliste LIKE LINE OF et_objektliste,
          p_lief         TYPE zcus_extlief-ext_dienstlif,
          p_meas         TYPE zcus_extmeas-meas,
          p_date         TYPE sy-datum.
*********** 'MEAS_ANL' *************************
    DATA ro_instance       TYPE REF TO zif_pd_ztexd_flache_mngr.

    DATA: et_list_x	TYPE z_t_ztexd_flache_x,
          ls_list_x LIKE LINE OF et_list_x.

*
    FIELD-SYMBOLS: <outtab>     TYPE  z_t_zst_meas_excel_uload,
                   <table_line> LIKE LINE OF <outtab>.

    DATA: lo_msglist       TYPE REF TO if_reca_message_list.
    DATA: lf_exists    TYPE recabool.

*   Get Messagesammler
    CALL METHOD cf_reca_message_list=>create
      RECEIVING
        ro_instance = lo_msglist.


    ASSIGN me->mdt_outtab->* TO <outtab>.

    CLEAR <outtab>[].


    CALL FUNCTION 'ZFB_GUI_GENERIC_SELECT_OBJEKT'
      EXPORTING
        id_activity       = reca1_activity-display
        id_dienstleistung = 'MEAS'
      IMPORTING
        ef_cancel         = ef_cancel
        et_objektliste    = et_objektliste
        et_tab            = lt_tab.

*   Bearbeitung durch Benutzer abgebrochen
    IF ef_cancel = abap_true.
      RETURN.
    ENDIF.

*     Die Selektion ist leer
    IF lt_tab[] IS INITIAL.
      MESSAGE s002 DISPLAY LIKE 'E'.
*     Keine Datensätze zu Ihrer Selektion gefunden.
      RETURN.
    ENDIF.


*   Finden Dienstleistungsmanager
    zcf_pd_ztexd_flache_mngr=>find_by_tab(
      EXPORTING
        id_dienstleistung = 'MEAS'
        it_tab            = lt_tab
        id_activity       = reca1_activity-display
        id_auth_check     = abap_false
        id_enqueue        = abap_false
        RECEIVING
        ro_instance       = ro_instance
      EXCEPTIONS
        error             = 1
        OTHERS            = 2
        ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

*   Get Ausgabetabelle
    ro_instance->get_list_x(
    IMPORTING
      et_list_x = et_list_x
      ).

    LOOP AT et_list_x INTO ls_list_x WHERE aktivitaet = ' ' AND measvalue_neu IS INITIAL
                                       AND me_update(6) <> 'FEHLER'.
      APPEND INITIAL LINE TO <outtab> ASSIGNING <table_line>.
      MOVE-CORRESPONDING ls_list_x TO <table_line>.
      <table_line>-measunit_neu = ls_list_x-measunit.
    ENDLOOP.

*****************************************************************************


  ENDMETHOD.                    "MEAS_Download

  METHOD set_excel. "
    DATA: ls_excel TYPE ztabline_str,
          zeile    TYPE ztabline_str-row,
          spalte   TYPE ztabline_str-row,
          fehlvers TYPE i,
          ld_row   TYPE i.
    DATA: prozent_hpt TYPE i,
          text_hpt    TYPE rs38m-itex132,
          cnt         TYPE string.
    DATA: lf_cell_error TYPE abap_bool,
          ls_msg(132)   TYPE c.
*    DATA:     H_DAT(10)      TYPE C,
*              H_H_DAT(10)    TYPE C.


    FIELD-SYMBOLS:
      <fs>      TYPE any,
      <ls_list> LIKE LINE OF et_excel_uload.


* Startbedinung lesen mit Kopfzeile
    zeile  = '0002'.



    spalte = '0000'.


*
* DTA-Felder entschlüsseln
    DO .
*    Indikator prozent
      prozent_hpt = '100'.
      cnt = sy-tabix.
      CONCATENATE cnt ' -Excelzeile wird in SAP-DTA Tabelle zugeordnet'
      INTO text_hpt.

*   Indikator
      PERFORM indikator IN PROGRAM saplzfg_xsca_draw
      USING prozent_hpt
            text_hpt.

*   Lesezeile bestimmen index
      ld_row = sy-index.


      CHECK ld_row >= zeile.

*     Kontrollcheck bei Ende von Exceltabelle
      READ TABLE it_excel INTO ls_excel WITH KEY row = ld_row.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.


*     Exporttabelle wird aufgebaut
      APPEND INITIAL LINE TO et_excel_uload ASSIGNING <ls_list>.


      LOOP AT it_excel INTO ls_excel WHERE row = ld_row.
        ASSIGN COMPONENT ls_excel-col OF STRUCTURE <ls_list> TO <fs>.

*        Komma wird durch '.' ersetzt
        REPLACE ',' IN ls_excel-value WITH '.'.

*        Datum konvertieren
        IF ls_excel-col = 14 OR
           ls_excel-col = 16 OR
           ls_excel-col = 19 OR
           ls_excel-col = 26.
*          CLEAR: H_DAT, H_H_DAT.
*          WRITE LS_EXCEL-VALUE TO H_DAT.
*         Datum konvertieren
          CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
            EXPORTING
              date_external            = ls_excel-value
              accept_initial_date      = abap_true
            IMPORTING
              date_internal            = ls_excel-value
            EXCEPTIONS
              date_external_is_invalid = 1
              OTHERS                   = 2.
          IF sy-subrc <> 0.
*           Implement suitable error handling here
          ENDIF.

        ENDIF.

        <fs> = ls_excel-value.

*        Beim ImmoKey die Nummern konvertieren
        IF ls_excel-col BETWEEN 1 AND 5.
**        Beim Buchungskreis/WE/GE/ME führende Nullen hinzufügen
          CALL METHOD cl_reca_ddic_services=>do_conv_exit
            EXPORTING
              id_convexit        = 'ALPHA'
              if_only_if_defined = abap_false
              if_output          = abap_false
            CHANGING
              cd_field           = <fs>
            EXCEPTIONS
              error              = 1
              OTHERS             = 2.

        ENDIF.

*      Set  Bemessung
        IF ls_excel-col = 11.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = <fs>
            IMPORTING
              output = <fs>.
        ENDIF.

      ENDLOOP.


    ENDDO.
  ENDMETHOD.                    "SET_EXCEL
ENDCLASS.                    " LCL_MOD_DBT_EMOD_ANW IMPLEMENTATION
