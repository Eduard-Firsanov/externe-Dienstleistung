INTERFACE zif_has_ext_flache_mngr
  PUBLIC .


  DATA md_activity TYPE reca1_activity .
  DATA mf_auth_check TYPE abap_bool .
  DATA mf_enqueue TYPE abap_bool .
  DATA mo_ext_flache_mngr TYPE REF TO zif_pd_ztexd_flache_mngr .

  METHODS get_ext_flache_mngr
    IMPORTING
      !id_dienstleistung        TYPE zddienstleistung
      !it_tab                   TYPE z_t_ztexd_flache
    RETURNING
      VALUE(ro_ext_flache_mngr) TYPE REF TO zif_pd_ztexd_flache_mngr
    EXCEPTIONS
      error .
ENDINTERFACE.
