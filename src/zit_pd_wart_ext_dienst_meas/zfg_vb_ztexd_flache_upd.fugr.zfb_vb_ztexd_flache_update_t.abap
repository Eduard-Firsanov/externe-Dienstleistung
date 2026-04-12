FUNCTION zfb_vb_ztexd_flache_update_t.
*"--------------------------------------------------------------------
*"*"Verbuchungsfunktionsbaustein:
*"
*"*"Lokale Schnittstelle:
*"  TABLES
*"      IT_ZTEXD_FLACHE STRUCTURE  ZAZTEXD_FLACHE
*"  EXCEPTIONS
*"      DB_FAILURE
*"      DB_OPERATION_UNKNOWN
*"--------------------------------------------------------------------

  DATA          ls_buffer   TYPE ztexd_flache.
  FIELD-SYMBOLS <ls_buffer> LIKE LINE OF it_ztexd_flache[].

  CHECK it_ztexd_flache[] IS NOT INITIAL.

  LOOP AT it_ztexd_flache ASSIGNING <ls_buffer>.
    MOVE-CORRESPONDING <ls_buffer> TO ls_buffer.
    CASE <ls_buffer>-kz.
      WHEN 'I'.   APPEND ls_buffer TO gt_buffer_i.
      WHEN 'U'.   APPEND ls_buffer TO gt_buffer_u.
      WHEN 'D'.   APPEND ls_buffer TO gt_buffer_d.
      WHEN space.
      WHEN OTHERS.
        MESSAGE a101(redb) WITH 'ZTEXD_FLACHE' <ls_buffer>-kz
                RAISING db_operation_unknown.
    ENDCASE.
  ENDLOOP.

  IF ( sy-oncom = 'S'                                     ) OR
     ( cf_reca_storable=>mc_collect_data_for_update = ' ' ).
    PERFORM buffer_update.
  ELSE.
    PERFORM buffer_update ON COMMIT.
    PERFORM buffer_clear  ON ROLLBACK.
  ENDIF.






ENDFUNCTION.
