FORM buffer_update.
  IF gt_buffer_d IS NOT INITIAL.
    DELETE ztexd_flache FROM TABLE gt_buffer_d.
    IF sy-subrc <> 0.
      PERFORM buffer_clear.
      MESSAGE a100(redb) WITH 'ZTEXD_FLACHE' 'D' sy-subrc
              RAISING db_failure.
    ENDIF.
  ENDIF.
  IF gt_buffer_i IS NOT INITIAL.
    INSERT ztexd_flache FROM TABLE gt_buffer_i
                          ACCEPTING DUPLICATE KEYS.
    IF sy-subrc <> 0.
      PERFORM buffer_clear.
      MESSAGE a100(redb) WITH 'ZTEXD_FLACHE' 'I' sy-subrc
              RAISING db_failure.
    ENDIF.
  ENDIF.
  IF gt_buffer_u IS NOT INITIAL.
    UPDATE ztexd_flache FROM TABLE gt_buffer_u.
    IF sy-subrc <> 0.
      PERFORM buffer_clear.
      MESSAGE a100(redb) WITH 'ZTEXD_FLACHE' 'U' sy-subrc
              RAISING db_failure.
    ENDIF.
  ENDIF.
  PERFORM buffer_clear.
ENDFORM.


FORM buffer_clear.
  CLEAR gt_buffer_i.
  CLEAR gt_buffer_u.
  CLEAR gt_buffer_d.
ENDFORM.
