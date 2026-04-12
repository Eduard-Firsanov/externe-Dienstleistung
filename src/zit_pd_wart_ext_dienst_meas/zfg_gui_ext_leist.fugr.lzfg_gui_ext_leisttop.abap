FUNCTION-POOL zfg_gui_ext_leist MESSAGE-ID zcontracting.


*=======================================================================
INCLUDE:
*=======================================================================
  ifrecamsg,
  ifrecabdt,
  ifrecaalv,
  zmacro_alv.
*=======================================================================
TYPE-POOLS:
*=======================================================================
  abap,         " general
  icon,         " icons
  zhz01,
  reca1,
  reca2,
  recaw,
  reaj4,
  cntb.



*=======================================================================
INCLUDE:      "local class for grid events
*=======================================================================
zin_gui_ext_leist_listcd1.
*=======================================================================
CONSTANTS:
*=======================================================================
  BEGIN OF gc_ok_code,
    tab_meas     TYPE sytcode VALUE 'TAB_MEAS',
    grid_enter   TYPE sytcode VALUE 'AJOB_G_ENT',
    grid_help    TYPE sytcode VALUE 'AJOB_G_HLP',
    meas_anl     TYPE  sytcode VALUE 'MEAS_ANL',
    meas_anz     TYPE  sytcode VALUE 'MEAS_ANZ',
    meas_upd     TYPE  sytcode VALUE 'MEAS_UPD',
    list_del     TYPE  sytcode VALUE 'LIST_DEL',
    list_refresh TYPE  sytcode VALUE 'LIST_REFRESH',
    list_aend    TYPE  sytcode VALUE 'LIST_AEND',
    set_excel    TYPE  sytcode VALUE 'SET_EXCEL',
    excel_upl    TYPE  sytcode VALUE 'EXCEL_UPL',
    excel_dow    TYPE  sytcode VALUE 'EXCEL_DOW',
    sap_update   TYPE  sytcode VALUE 'SAP_UPDATE',
    set_aktiv    TYPE  sytcode VALUE 'SET_AKTIV',
    set_ja       TYPE  sytcode VALUE 'SET_JA',
    set_sofort   TYPE  sytcode VALUE 'SET_SOFORT',
    set_nein     TYPE  sytcode VALUE 'SET_NEIN',
    set_info     TYPE  sytcode VALUE 'SET_INFO',
    set_pruefen  TYPE  sytcode VALUE 'SET_PRUEFEN',
  END OF gc_ok_code.

*=======================================================================
CONSTANTS:
*=======================================================================
  gc_classname            TYPE recaobjnameext VALUE 'ZCL_PD_GMOD_MNGR'.


*======================================================================
TYPES:
*======================================================================
  BEGIN OF gtype_s_menu,
    fcode    TYPE syucomm,
    text     TYPE gui_text,
    disabled TYPE abap_bool,
  END  OF gtype_s_menu,
  gtype_t_menu TYPE STANDARD TABLE OF gtype_s_menu.

*=======================================================================
DATA:         "gui information (buffered for pbo processing only)
*=======================================================================
  BEGIN OF gs_gui,
    subscreen TYPE recascreen,
  END OF gs_gui.


*=======================================================================
DATA:         "gui information (buffered for all pbo/pai-processing)
*=======================================================================
  BEGIN OF gs_gui_buffer,
*   will also be changed within the same business object
    current_key       TYPE zstexd_flache_key,
    grid_do_detail    TYPE abap_bool,
    grid_do_get_data  TYPE abap_bool,
    grid_do_refresh   TYPE abap_bool,
    grid_do_cwidthopt TYPE abap_bool,
    grid_do_init_pos  TYPE abap_bool,
    grid_do_toolbar   TYPE abap_bool,
    grid_do_change    TYPE abap_bool,
    grid_do_excel     TYPE abap_bool,
    grid_do_excel_upl TYPE abap_bool,
    grid_do_excel_dow TYPE abap_bool,
    grid_do_save      TYPE abap_bool,
  END OF gs_gui_buffer.


*=======================================================================
* Basic Objekten
*=======================================================================
DATA:
  go_flache_mngr           TYPE REF TO  zif_pd_ztexd_flache_mngr,
  go_changed_data_protocol TYPE REF TO cl_alv_changed_data_protocol,
  gd_activity              TYPE reca1_activity,
  gf_readonly              TYPE abap_bool,
  gf_gridonly              TYPE recabool VALUE abap_true,
  go_grid                  TYPE REF TO cl_gui_alv_grid,
  go_container_grid        TYPE REF TO cl_gui_custom_container,
  gd_anwactivity           TYPE sy-ucomm,

  go_msglist               TYPE REF TO if_reca_message_list ##NEEDED,






* for navigation on subscreen...
  go_current_nav_data      TYPE REF TO cl_reca_data_container, "#EC NEEDED
  go_navigation_data       TYPE REF TO cl_reca_data_container, "#EC NEEDED
  gs_navigation_data       TYPE zst_ext_dienst_navigation. " Navigationsinformation




*=======================================================================
DATA:         "grid data (buffered for all pbo/pai-processing)
*=======================================================================
  gt_grid_data TYPE TABLE OF zpd_ztexd_flache_x,
  gs_grid_data TYPE zpd_ztexd_flache_x.
