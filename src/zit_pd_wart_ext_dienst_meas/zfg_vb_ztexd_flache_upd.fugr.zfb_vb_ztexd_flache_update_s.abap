FUNCTION zfb_vb_ztexd_flache_update_s.
*"--------------------------------------------------------------------
*"*"Verbuchungsfunktionsbaustein:
*"
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(IS_ZTEXD_FLACHE) TYPE  ZTEXD_FLACHE
*"     VALUE(ID_OPERATION) TYPE  CDCHNGIND
*"  EXCEPTIONS
*"      DB_FAILURE
*"      DB_OPERATION_UNKNOWN
*"--------------------------------------------------------------------

  CASE id_operation.
    WHEN 'I'.   APPEND is_ztexd_flache TO gt_buffer_i.
    WHEN 'U'.   APPEND is_ztexd_flache TO gt_buffer_u.
    WHEN 'D'.   APPEND is_ztexd_flache TO gt_buffer_d.
    WHEN space.
    WHEN OTHERS.
      MESSAGE a101(redb) WITH 'ZTEXD_FLACHE' id_operation
              RAISING db_operation_unknown.
  ENDCASE.

  IF ( sy-oncom = 'S'                                     ) OR
     ( cf_reca_storable=>mc_collect_data_for_update = ' ' ).
    PERFORM buffer_update.
  ELSE.
    PERFORM buffer_update ON COMMIT.
    PERFORM buffer_clear  ON ROLLBACK.
  ENDIF.






ENDFUNCTION.
