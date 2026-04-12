*"* use this source file for any macro definitions you need
*"* in the implementation part of the class

INCLUDE ifrecamsg.


DEFINE mac_occupancy_insert_detail.

* set object data
  MOVE-CORRESPONDING lo_rental_object->ms_detail TO &1.

* usage type
  &1-usagetype = lo_rental_object->ms_detail-snunr.

* set pool space if existing
  IF lo_rental_object->ms_detail-rotype = rebd1_rotype-rentalspace.
    CALL METHOD lo_rental_object->get_hier_info
      IMPORTING
        ed_norups = &1-psno.
  ENDIF.

END-OF-DEFINITION.
