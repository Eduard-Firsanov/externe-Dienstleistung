INTERFACE zif_pd_ztexd_flache_mngr
  PUBLIC .


  INTERFACES if_reca_object .
  INTERFACES if_reca_storable .
  INTERFACES zif_has_meas_mngr .

  ALIASES md_activity
    FOR if_reca_storable~md_activity .
  ALIASES mf_archived
    FOR if_reca_storable~mf_archived .
  ALIASES mf_auth_check
    FOR if_reca_storable~mf_auth_check .
  ALIASES mf_enqueue
    FOR if_reca_storable~mf_enqueue .
  ALIASES add_child
    FOR if_reca_storable~add_child .
  ALIASES check_all
    FOR if_reca_storable~check_all .
  ALIASES free
    FOR if_reca_storable~free .
  ALIASES get_children
    FOR if_reca_storable~get_children .
  ALIASES get_extension
    FOR if_reca_storable~get_extension .
  ALIASES get_fieldstatus
    FOR if_reca_storable~get_fieldstatus .
  ALIASES init_by_template
    FOR if_reca_storable~init_by_template .
  ALIASES is_fieldstatus_set
    FOR if_reca_storable~is_fieldstatus_set .
  ALIASES is_modified
    FOR if_reca_storable~is_modified .
  ALIASES is_ok
    FOR if_reca_storable~is_ok .
  ALIASES register_all_children
    FOR if_reca_storable~register_all_children .
  ALIASES release
    FOR if_reca_storable~release .
  ALIASES store
    FOR if_reca_storable~store .
  ALIASES after_store
    FOR if_reca_storable~after_store .
  ALIASES before_store
    FOR if_reca_storable~before_store .
  ALIASES on_check_all
    FOR if_reca_storable~on_check_all .

  DATA md_dienstleistung TYPE zddienstleistung .
  DATA mf_reset_buffer TYPE abap_bool .

  METHODS init_by_dienstleistung
    IMPORTING
      !id_dienstleistung TYPE zddienstleistung
      !id_activity       TYPE reca1_activity
      !id_auth_check     TYPE abap_bool
      !id_enqueue        TYPE abap_bool
      !if_reset_buffer   TYPE abap_bool DEFAULT abap_false .
  METHODS init_by_guidtab
    IMPORTING
      !id_dienstleistung TYPE zddienstleistung
      !it_tab            TYPE z_t_ztexd_flache OPTIONAL
      !id_activity       TYPE reca1_activity
      !id_auth_check     TYPE abap_bool
      !id_enqueue        TYPE abap_bool .
  METHODS check_key
    EXCEPTIONS
      not_found .
  METHODS count
    RETURNING
      VALUE(rd_count) TYPE i .
  METHODS exists
    IMPORTING
      !is_key          TYPE zstexd_flache_key
    RETURNING
      VALUE(rf_exists) TYPE abap_bool .
  METHODS get_ident
    IMPORTING
      !is_detail      TYPE zpd_ztexd_flache
    RETURNING
      VALUE(rd_ident) TYPE recaident
    EXCEPTIONS
      error .
  METHODS get_detail
    IMPORTING
      !is_key          TYPE zstexd_flache_key
    RETURNING
      VALUE(rs_detail) TYPE zpd_ztexd_flache
    EXCEPTIONS
      not_found .
  METHODS set_status_icon
    IMPORTING
      !io_msglist     TYPE REF TO if_reca_message_list
      !is_detail      TYPE zpd_ztexd_flache
    CHANGING
      !cd_status_icon TYPE recaiconmarked .
  METHODS get_detail_x
    IMPORTING
      !is_key            TYPE zstexd_flache_key OPTIONAL
    RETURNING
      VALUE(rs_detail_x) TYPE zpd_ztexd_flache_x
    EXCEPTIONS
      not_found .
  METHODS get_list
    EXPORTING
      !et_list TYPE z_t_ztexd_flache .
  METHODS get_list_x
    EXPORTING
      !et_list_x TYPE z_t_ztexd_flache_x .
  METHODS get_text
    IMPORTING
      !id_langu      TYPE sylangu DEFAULT sy-langu
    RETURNING
      VALUE(rd_text) TYPE string
    EXCEPTIONS
      not_found .
  METHODS objektliste_create
    IMPORTING
      !id_dienstleistung TYPE zddienstleistung
      !id_lief           TYPE zcus_extlief-ext_dienstlif OPTIONAL
      !id_seldate        TYPE sy-datum OPTIONAL
      !id_andgr          TYPE ztexd_flache-ext_aendgrund OPTIONAL
      !id_proj           TYPE ztexd_flache-projektname OPTIONAL
      !id_auftr          TYPE ztexd_flache-auftr_verm OPTIONAL
      !ist_objektliste   TYPE zst_objektliste
      !io_msglist        TYPE REF TO if_reca_message_list
    EXCEPTIONS
      error .
  METHODS get_msglist
    IMPORTING
      !is_key           TYPE zstexd_flache_key
    CHANGING
      VALUE(co_msglist) TYPE REF TO if_reca_message_list .
  METHODS objektliste_change
    IMPORTING
      !is_list TYPE zpd_ztexd_flache
    EXCEPTIONS
      error .
  METHODS objektliste_excel_upl
    IMPORTING
      !it_excel_tab TYPE z_t_ztexd_flache
      !io_msglist   TYPE REF TO if_reca_message_list .
  METHODS objektliste_refresh
    IMPORTING
      !is_list TYPE zpd_ztexd_flache
    EXCEPTIONS
      error .
  METHODS objektliste_delete
    IMPORTING
      !is_key TYPE ztexd_flache-key
    EXCEPTIONS
      error .
  METHODS store_messages
    IMPORTING
      !if_in_update_task TYPE recabool
      VALUE(io_msglist)  TYPE REF TO if_reca_message_list
    EXCEPTIONS
      error .
  METHODS check_delete_objekt
    IMPORTING
      !is_detail            TYPE zpd_ztexd_flache
    RETURNING
      VALUE(rd_alowed_flag) TYPE recabool .
  METHODS mv_kuendigung_set
    IMPORTING
      !is_key           TYPE zstexd_flache_key
      !is_detail_before TYPE recn_notice
      !is_detail        TYPE recn_notice
    EXCEPTIONS
      error .
  METHODS me_flaeche_updaten
    IMPORTING
      !it_meas    TYPE z_t_ztexd_flache
      !io_msglist TYPE REF TO if_reca_message_list
    EXCEPTIONS
      error .
  METHODS mv_laufzeitende_set
    IMPORTING
      !is_key            TYPE zstexd_flache_key
      !id_recnendabs     TYPE recncnendabs
      !id_recnendabs_old TYPE recncnendabs
      !is_detail         TYPE recn_contract
      !if_in_update_task TYPE abap_bool DEFAULT abap_true .
  METHODS me_stammaend_set
    IMPORTING
      !is_detail TYPE rebd_rental_object
    EXCEPTIONS
      error .
ENDINTERFACE.
