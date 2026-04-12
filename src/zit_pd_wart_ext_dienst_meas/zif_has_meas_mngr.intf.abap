INTERFACE zif_has_meas_mngr
  PUBLIC .


  DATA mto_bus_object TYPE re_t_if_reca_bus_object .

  METHODS get_meascn_mngr
    IMPORTING
      !id_objnr            TYPE recaobjnr
    RETURNING
      VALUE(ro_bus_object) TYPE REF TO if_reca_bus_object
    EXCEPTIONS
      error .
ENDINTERFACE.
