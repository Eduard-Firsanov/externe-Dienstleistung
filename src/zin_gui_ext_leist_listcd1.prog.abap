*&---------------------------------------------------------------------*
*&  Include           ZIN_GUI_EXT_LEIST_LISTCD1
*&---------------------------------------------------------------------*
*=======================================================================
CLASS lcl_event_receiver DEFINITION.                        "#EC *
*=======================================================================
  PUBLIC SECTION.
    CLASS-METHODS:

      handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING
          er_data_changed,                                  "#EC NEEDED

      handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row                                     "#EC NEEDED
                  e_column,                                 "#EC NEEDED

      handle_hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id                                  "#EC NEEDED
                  e_column_id,                              "#EC NEEDED

      handle_menu_button
        FOR EVENT menu_button OF cl_gui_alv_grid
        IMPORTING e_object                                  "#EC NEEDED
                  e_ucomm,                                  "#EC NEEDED

      handle_onf4
        FOR EVENT onf4 OF cl_gui_alv_grid
        IMPORTING
          e_fieldname                                       "#EC NEEDED
          e_fieldvalue                                      "#EC NEEDED
          es_row_no                                         "#EC NEEDED
          er_event_data                                     "#EC NEEDED
          et_bad_cells                                      "#EC NEEDED
          e_display,                                        "#EC NEEDED


      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object                                  "#EC NEEDED
                  e_interactive,                            "#EC NEEDED

      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,                                  "#EC NEEDED

      handle_after_refresh
        FOR EVENT after_refresh OF cl_gui_alv_grid.

*      HANDLE_BUTTON_CLICK  FOR EVENT BUTTON_CLICK
*                    OF        CL_GUI_ALV_GRID
*                    IMPORTING ES_COL_ID                     "#EC NEEDED
*                              ES_ROW_NO.                    "#EC NEEDED



ENDCLASS.                    "lcl_event_receiver DEFINITION
