*---------------------------------------------------------------------*
*    view related FORM routines
*---------------------------------------------------------------------*
*...processing: ZV_AENDGRUND....................................*
FORM get_data_zv_aendgrund.
  PERFORM vim_fill_wheretab.
*.read data from database.............................................*
  REFRESH total.
  CLEAR   total.
  SELECT * FROM zcus_extaendgr WHERE
(vim_wheretab) .
    CLEAR zv_aendgrund .
    zv_aendgrund-mandt =
    zcus_extaendgr-mandt .
    zv_aendgrund-dienstleistung =
    zcus_extaendgr-dienstleistung .
    zv_aendgrund-ext_aendgrund =
    zcus_extaendgr-ext_aendgrund .
    SELECT SINGLE * FROM zcus_extaendgrt WHERE
dienstleistung = zcus_extaendgr-dienstleistung AND
ext_aendgrund = zcus_extaendgr-ext_aendgrund AND
spras = sy-langu .
    IF sy-subrc EQ 0.
      zv_aendgrund-aendgrund_bez =
      zcus_extaendgrt-aendgrund_bez .
    ENDIF.
    <vim_total_struc> = zv_aendgrund.
    APPEND total.
  ENDSELECT.
  SORT total BY <vim_xtotal_key>.
  <status>-alr_sorted = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF x_header-selection NE space.
    PERFORM check_dynamic_select_options.
  ELSEIF x_header-delmdtflag NE space.
    PERFORM build_mainkey_tab.
  ENDIF.
  REFRESH extract.
ENDFORM.
*---------------------------------------------------------------------*
FORM db_upd_zv_aendgrund .
*.process data base updates/inserts/deletes.........................*
  LOOP AT total.
    CHECK <action> NE original.
    MOVE <vim_total_struc> TO zv_aendgrund.
    IF <action> = update_geloescht.
      <action> = geloescht.
    ENDIF.
    CASE <action>.
      WHEN neuer_geloescht.
        IF status_zv_aendgrund-st_delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key>.
          IF sy-subrc EQ 0.
            DELETE extract INDEX sy-tabix.
          ENDIF.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN geloescht.
        SELECT SINGLE FOR UPDATE * FROM zcus_extaendgr WHERE
        dienstleistung = zv_aendgrund-dienstleistung AND
        ext_aendgrund = zv_aendgrund-ext_aendgrund .
        IF sy-subrc = 0.
          DELETE zcus_extaendgr .
        ENDIF.
        DELETE FROM zcus_extaendgrt WHERE
        dienstleistung = zcus_extaendgr-dienstleistung AND
        ext_aendgrund = zcus_extaendgr-ext_aendgrund .
        IF status-delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key> BINARY SEARCH.
          DELETE extract INDEX sy-tabix.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN OTHERS.
        SELECT SINGLE FOR UPDATE * FROM zcus_extaendgr WHERE
        dienstleistung = zv_aendgrund-dienstleistung AND
        ext_aendgrund = zv_aendgrund-ext_aendgrund .
        IF sy-subrc <> 0.   "insert preprocessing: init WA
          CLEAR zcus_extaendgr.
        ENDIF.
        zcus_extaendgr-mandt =
        zv_aendgrund-mandt .
        zcus_extaendgr-dienstleistung =
        zv_aendgrund-dienstleistung .
        zcus_extaendgr-ext_aendgrund =
        zv_aendgrund-ext_aendgrund .
        IF sy-subrc = 0.
          UPDATE zcus_extaendgr .
        ELSE.
          INSERT zcus_extaendgr .
        ENDIF.
        SELECT SINGLE FOR UPDATE * FROM zcus_extaendgrt WHERE
        dienstleistung = zcus_extaendgr-dienstleistung AND
        ext_aendgrund = zcus_extaendgr-ext_aendgrund AND
        spras = sy-langu .
        IF sy-subrc <> 0.   "insert preprocessing: init WA
          CLEAR zcus_extaendgrt.
          zcus_extaendgrt-dienstleistung =
          zcus_extaendgr-dienstleistung .
          zcus_extaendgrt-ext_aendgrund =
          zcus_extaendgr-ext_aendgrund .
          zcus_extaendgrt-spras =
          sy-langu .
        ENDIF.
        zcus_extaendgrt-aendgrund_bez =
        zv_aendgrund-aendgrund_bez .
        IF sy-subrc = 0.
          UPDATE zcus_extaendgrt .
        ELSE.
          INSERT zcus_extaendgrt .
        ENDIF.
        READ TABLE extract WITH KEY <vim_xtotal_key>.
        IF sy-subrc EQ 0.
          <xact> = original.
          MODIFY extract INDEX sy-tabix.
        ENDIF.
        <action> = original.
        MODIFY total.
    ENDCASE.
  ENDLOOP.
  CLEAR: status_zv_aendgrund-upd_flag,
  status_zv_aendgrund-upd_checkd.
  MESSAGE s018(sv).
ENDFORM.
*---------------------------------------------------------------------*
FORM read_single_zv_aendgrund.
  SELECT SINGLE * FROM zcus_extaendgr WHERE
dienstleistung = zv_aendgrund-dienstleistung AND
ext_aendgrund = zv_aendgrund-ext_aendgrund .
  zv_aendgrund-mandt =
  zcus_extaendgr-mandt .
  zv_aendgrund-dienstleistung =
  zcus_extaendgr-dienstleistung .
  zv_aendgrund-ext_aendgrund =
  zcus_extaendgr-ext_aendgrund .
  SELECT SINGLE * FROM zcus_extaendgrt WHERE
dienstleistung = zcus_extaendgr-dienstleistung AND
ext_aendgrund = zcus_extaendgr-ext_aendgrund AND
spras = sy-langu .
  IF sy-subrc EQ 0.
    zv_aendgrund-aendgrund_bez =
    zcus_extaendgrt-aendgrund_bez .
  ELSE.
    CLEAR sy-subrc.
    CLEAR zv_aendgrund-aendgrund_bez .
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
FORM corr_maint_zv_aendgrund USING VALUE(cm_action) rc.
  DATA: retcode     LIKE sy-subrc, count TYPE i, trsp_keylen TYPE syfleng.
  FIELD-SYMBOLS: <tab_key_x> TYPE x.
  CLEAR rc.
  MOVE zv_aendgrund-dienstleistung TO
  zcus_extaendgr-dienstleistung .
  MOVE zv_aendgrund-ext_aendgrund TO
  zcus_extaendgr-ext_aendgrund .
  MOVE zv_aendgrund-mandt TO
  zcus_extaendgr-mandt .
  corr_keytab             =  e071k.
  corr_keytab-objname     = 'ZCUS_EXTAENDGR'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN corr_keytab-tabkey TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN zcus_extaendgr TO <tab_key_x> CASTING.
  PERFORM vim_get_trspkeylen
    USING 'ZCUS_EXTAENDGR'
    CHANGING trsp_keylen.
  <vim_corr_keyx>(trsp_keylen) = <tab_key_x>(trsp_keylen).
  PERFORM update_corr_keytab USING cm_action retcode.
  ADD: retcode TO rc, 1 TO count.
  IF rc LT count AND cm_action NE pruefen.
    CLEAR rc.
  ENDIF.

  MOVE zcus_extaendgr-dienstleistung TO
  zcus_extaendgrt-dienstleistung .
  MOVE zcus_extaendgr-ext_aendgrund TO
  zcus_extaendgrt-ext_aendgrund .
  MOVE sy-langu TO
  zcus_extaendgrt-spras .
  MOVE zv_aendgrund-mandt TO
  zcus_extaendgrt-mandt .
  corr_keytab             =  e071k.
  corr_keytab-objname     = 'ZCUS_EXTAENDGRT'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN corr_keytab-tabkey TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN zcus_extaendgrt TO <tab_key_x> CASTING.
  PERFORM vim_get_trspkeylen
    USING 'ZCUS_EXTAENDGRT'
    CHANGING trsp_keylen.
  <vim_corr_keyx>(trsp_keylen) = <tab_key_x>(trsp_keylen).
  PERFORM update_corr_keytab USING cm_action retcode.
  ADD: retcode TO rc, 1 TO count.
  IF rc LT count AND cm_action NE pruefen.
    CLEAR rc.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZV_AKTIVIT......................................*
FORM get_data_zv_aktivit.
  PERFORM vim_fill_wheretab.
*.read data from database.............................................*
  REFRESH total.
  CLEAR   total.
  SELECT * FROM zcus_aktivit WHERE
(vim_wheretab) .
    CLEAR zv_aktivit .
    zv_aktivit-mandt =
    zcus_aktivit-mandt .
    zv_aktivit-aktivitaet =
    zcus_aktivit-aktivitaet .
    zv_aktivit-update_fl =
    zcus_aktivit-update_fl .
    zv_aktivit-update_value_null =
    zcus_aktivit-update_value_null .
    SELECT SINGLE * FROM zcus_aktivitt WHERE
aktivitaet = zcus_aktivit-aktivitaet AND
spras = sy-langu .
    IF sy-subrc EQ 0.
      zv_aktivit-aktivitaetbez =
      zcus_aktivitt-aktivitaetbez .
    ENDIF.
    <vim_total_struc> = zv_aktivit.
    APPEND total.
  ENDSELECT.
  SORT total BY <vim_xtotal_key>.
  <status>-alr_sorted = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF x_header-selection NE space.
    PERFORM check_dynamic_select_options.
  ELSEIF x_header-delmdtflag NE space.
    PERFORM build_mainkey_tab.
  ENDIF.
  REFRESH extract.
ENDFORM.
*---------------------------------------------------------------------*
FORM db_upd_zv_aktivit .
*.process data base updates/inserts/deletes.........................*
  LOOP AT total.
    CHECK <action> NE original.
    MOVE <vim_total_struc> TO zv_aktivit.
    IF <action> = update_geloescht.
      <action> = geloescht.
    ENDIF.
    CASE <action>.
      WHEN neuer_geloescht.
        IF status_zv_aktivit-st_delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key>.
          IF sy-subrc EQ 0.
            DELETE extract INDEX sy-tabix.
          ENDIF.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN geloescht.
        SELECT SINGLE FOR UPDATE * FROM zcus_aktivit WHERE
        aktivitaet = zv_aktivit-aktivitaet .
        IF sy-subrc = 0.
          DELETE zcus_aktivit .
        ENDIF.
        DELETE FROM zcus_aktivitt WHERE
        aktivitaet = zcus_aktivit-aktivitaet .
        IF status-delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key> BINARY SEARCH.
          DELETE extract INDEX sy-tabix.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN OTHERS.
        SELECT SINGLE FOR UPDATE * FROM zcus_aktivit WHERE
        aktivitaet = zv_aktivit-aktivitaet .
        IF sy-subrc <> 0.   "insert preprocessing: init WA
          CLEAR zcus_aktivit.
        ENDIF.
        zcus_aktivit-mandt =
        zv_aktivit-mandt .
        zcus_aktivit-aktivitaet =
        zv_aktivit-aktivitaet .
        zcus_aktivit-update_fl =
        zv_aktivit-update_fl .
        zcus_aktivit-update_value_null =
        zv_aktivit-update_value_null .
        IF sy-subrc = 0.
          UPDATE zcus_aktivit .
        ELSE.
          INSERT zcus_aktivit .
        ENDIF.
        SELECT SINGLE FOR UPDATE * FROM zcus_aktivitt WHERE
        aktivitaet = zcus_aktivit-aktivitaet AND
        spras = sy-langu .
        IF sy-subrc <> 0.   "insert preprocessing: init WA
          CLEAR zcus_aktivitt.
          zcus_aktivitt-aktivitaet =
          zcus_aktivit-aktivitaet .
          zcus_aktivitt-spras =
          sy-langu .
        ENDIF.
        zcus_aktivitt-aktivitaetbez =
        zv_aktivit-aktivitaetbez .
        IF sy-subrc = 0.
          UPDATE zcus_aktivitt .
        ELSE.
          INSERT zcus_aktivitt .
        ENDIF.
        READ TABLE extract WITH KEY <vim_xtotal_key>.
        IF sy-subrc EQ 0.
          <xact> = original.
          MODIFY extract INDEX sy-tabix.
        ENDIF.
        <action> = original.
        MODIFY total.
    ENDCASE.
  ENDLOOP.
  CLEAR: status_zv_aktivit-upd_flag,
  status_zv_aktivit-upd_checkd.
  MESSAGE s018(sv).
ENDFORM.
*---------------------------------------------------------------------*
FORM read_single_entry_zv_aktivit.
  SELECT SINGLE * FROM zcus_aktivit WHERE
aktivitaet = zv_aktivit-aktivitaet .
  zv_aktivit-mandt =
  zcus_aktivit-mandt .
  zv_aktivit-aktivitaet =
  zcus_aktivit-aktivitaet .
  zv_aktivit-update_fl =
  zcus_aktivit-update_fl .
  zv_aktivit-update_value_null =
  zcus_aktivit-update_value_null .
  SELECT SINGLE * FROM zcus_aktivitt WHERE
aktivitaet = zcus_aktivit-aktivitaet AND
spras = sy-langu .
  IF sy-subrc EQ 0.
    zv_aktivit-aktivitaetbez =
    zcus_aktivitt-aktivitaetbez .
  ELSE.
    CLEAR sy-subrc.
    CLEAR zv_aktivit-aktivitaetbez .
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
FORM corr_maint_zv_aktivit USING VALUE(cm_action) rc.
  DATA: retcode     LIKE sy-subrc, count TYPE i, trsp_keylen TYPE syfleng.
  FIELD-SYMBOLS: <tab_key_x> TYPE x.
  CLEAR rc.
  MOVE zv_aktivit-aktivitaet TO
  zcus_aktivit-aktivitaet .
  MOVE zv_aktivit-mandt TO
  zcus_aktivit-mandt .
  corr_keytab             =  e071k.
  corr_keytab-objname     = 'ZCUS_AKTIVIT'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN corr_keytab-tabkey TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN zcus_aktivit TO <tab_key_x> CASTING.
  PERFORM vim_get_trspkeylen
    USING 'ZCUS_AKTIVIT'
    CHANGING trsp_keylen.
  <vim_corr_keyx>(trsp_keylen) = <tab_key_x>(trsp_keylen).
  PERFORM update_corr_keytab USING cm_action retcode.
  ADD: retcode TO rc, 1 TO count.
  IF rc LT count AND cm_action NE pruefen.
    CLEAR rc.
  ENDIF.

  MOVE zcus_aktivit-aktivitaet TO
  zcus_aktivitt-aktivitaet .
  MOVE sy-langu TO
  zcus_aktivitt-spras .
  MOVE zv_aktivit-mandt TO
  zcus_aktivitt-mandt .
  corr_keytab             =  e071k.
  corr_keytab-objname     = 'ZCUS_AKTIVITT'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN corr_keytab-tabkey TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN zcus_aktivitt TO <tab_key_x> CASTING.
  PERFORM vim_get_trspkeylen
    USING 'ZCUS_AKTIVITT'
    CHANGING trsp_keylen.
  <vim_corr_keyx>(trsp_keylen) = <tab_key_x>(trsp_keylen).
  PERFORM update_corr_keytab USING cm_action retcode.
  ADD: retcode TO rc, 1 TO count.
  IF rc LT count AND cm_action NE pruefen.
    CLEAR rc.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZV_DIENSTLEIST..................................*
FORM get_data_zv_dienstleist.
  PERFORM vim_fill_wheretab.
*.read data from database.............................................*
  REFRESH total.
  CLEAR   total.
  SELECT * FROM zcus_dienstl WHERE
(vim_wheretab) .
    CLEAR zv_dienstleist .
    zv_dienstleist-mandt =
    zcus_dienstl-mandt .
    zv_dienstleist-dienstleistung =
    zcus_dienstl-dienstleistung .
    zv_dienstleist-sortorder =
    zcus_dienstl-sortorder .
    zv_dienstleist-tabname =
    zcus_dienstl-tabname .
    zv_dienstleist-disp_structname =
    zcus_dienstl-disp_structname .
    SELECT SINGLE * FROM zcus_dienstlt WHERE
dienstleistung = zcus_dienstl-dienstleistung AND
spras = sy-langu .
    IF sy-subrc EQ 0.
      zv_dienstleist-dienstleistbez =
      zcus_dienstlt-dienstleistbez .
    ENDIF.
    <vim_total_struc> = zv_dienstleist.
    APPEND total.
  ENDSELECT.
  SORT total BY <vim_xtotal_key>.
  <status>-alr_sorted = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF x_header-selection NE space.
    PERFORM check_dynamic_select_options.
  ELSEIF x_header-delmdtflag NE space.
    PERFORM build_mainkey_tab.
  ENDIF.
  REFRESH extract.
ENDFORM.
*---------------------------------------------------------------------*
FORM db_upd_zv_dienstleist .
*.process data base updates/inserts/deletes.........................*
  LOOP AT total.
    CHECK <action> NE original.
    MOVE <vim_total_struc> TO zv_dienstleist.
    IF <action> = update_geloescht.
      <action> = geloescht.
    ENDIF.
    CASE <action>.
      WHEN neuer_geloescht.
        IF status_zv_dienstleist-st_delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key>.
          IF sy-subrc EQ 0.
            DELETE extract INDEX sy-tabix.
          ENDIF.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN geloescht.
        SELECT SINGLE FOR UPDATE * FROM zcus_dienstl WHERE
        dienstleistung = zv_dienstleist-dienstleistung .
        IF sy-subrc = 0.
          DELETE zcus_dienstl .
        ENDIF.
        DELETE FROM zcus_dienstlt WHERE
        dienstleistung = zcus_dienstl-dienstleistung .
        IF status-delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key> BINARY SEARCH.
          DELETE extract INDEX sy-tabix.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN OTHERS.
        SELECT SINGLE FOR UPDATE * FROM zcus_dienstl WHERE
        dienstleistung = zv_dienstleist-dienstleistung .
        IF sy-subrc <> 0.   "insert preprocessing: init WA
          CLEAR zcus_dienstl.
        ENDIF.
        zcus_dienstl-mandt =
        zv_dienstleist-mandt .
        zcus_dienstl-dienstleistung =
        zv_dienstleist-dienstleistung .
        zcus_dienstl-sortorder =
        zv_dienstleist-sortorder .
        zcus_dienstl-tabname =
        zv_dienstleist-tabname .
        zcus_dienstl-disp_structname =
        zv_dienstleist-disp_structname .
        IF sy-subrc = 0.
          UPDATE zcus_dienstl .
        ELSE.
          INSERT zcus_dienstl .
        ENDIF.
        SELECT SINGLE FOR UPDATE * FROM zcus_dienstlt WHERE
        dienstleistung = zcus_dienstl-dienstleistung AND
        spras = sy-langu .
        IF sy-subrc <> 0.   "insert preprocessing: init WA
          CLEAR zcus_dienstlt.
          zcus_dienstlt-dienstleistung =
          zcus_dienstl-dienstleistung .
          zcus_dienstlt-spras =
          sy-langu .
        ENDIF.
        zcus_dienstlt-dienstleistbez =
        zv_dienstleist-dienstleistbez .
        IF sy-subrc = 0.
          UPDATE zcus_dienstlt .
        ELSE.
          INSERT zcus_dienstlt .
        ENDIF.
        READ TABLE extract WITH KEY <vim_xtotal_key>.
        IF sy-subrc EQ 0.
          <xact> = original.
          MODIFY extract INDEX sy-tabix.
        ENDIF.
        <action> = original.
        MODIFY total.
    ENDCASE.
  ENDLOOP.
  CLEAR: status_zv_dienstleist-upd_flag,
  status_zv_dienstleist-upd_checkd.
  MESSAGE s018(sv).
ENDFORM.
*---------------------------------------------------------------------*
FORM read_single_zv_dienstleist.
  SELECT SINGLE * FROM zcus_dienstl WHERE
dienstleistung = zv_dienstleist-dienstleistung .
  zv_dienstleist-mandt =
  zcus_dienstl-mandt .
  zv_dienstleist-dienstleistung =
  zcus_dienstl-dienstleistung .
  zv_dienstleist-sortorder =
  zcus_dienstl-sortorder .
  zv_dienstleist-tabname =
  zcus_dienstl-tabname .
  zv_dienstleist-disp_structname =
  zcus_dienstl-disp_structname .
  SELECT SINGLE * FROM zcus_dienstlt WHERE
dienstleistung = zcus_dienstl-dienstleistung AND
spras = sy-langu .
  IF sy-subrc EQ 0.
    zv_dienstleist-dienstleistbez =
    zcus_dienstlt-dienstleistbez .
  ELSE.
    CLEAR sy-subrc.
    CLEAR zv_dienstleist-dienstleistbez .
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
FORM corr_maint_zv_dienstleist USING VALUE(cm_action) rc.
  DATA: retcode     LIKE sy-subrc, count TYPE i, trsp_keylen TYPE syfleng.
  FIELD-SYMBOLS: <tab_key_x> TYPE x.
  CLEAR rc.
  MOVE zv_dienstleist-dienstleistung TO
  zcus_dienstl-dienstleistung .
  MOVE zv_dienstleist-mandt TO
  zcus_dienstl-mandt .
  corr_keytab             =  e071k.
  corr_keytab-objname     = 'ZCUS_DIENSTL'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN corr_keytab-tabkey TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN zcus_dienstl TO <tab_key_x> CASTING.
  PERFORM vim_get_trspkeylen
    USING 'ZCUS_DIENSTL'
    CHANGING trsp_keylen.
  <vim_corr_keyx>(trsp_keylen) = <tab_key_x>(trsp_keylen).
  PERFORM update_corr_keytab USING cm_action retcode.
  ADD: retcode TO rc, 1 TO count.
  IF rc LT count AND cm_action NE pruefen.
    CLEAR rc.
  ENDIF.

  MOVE zcus_dienstl-dienstleistung TO
  zcus_dienstlt-dienstleistung .
  MOVE sy-langu TO
  zcus_dienstlt-spras .
  MOVE zv_dienstleist-mandt TO
  zcus_dienstlt-mandt .
  corr_keytab             =  e071k.
  corr_keytab-objname     = 'ZCUS_DIENSTLT'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN corr_keytab-tabkey TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN zcus_dienstlt TO <tab_key_x> CASTING.
  PERFORM vim_get_trspkeylen
    USING 'ZCUS_DIENSTLT'
    CHANGING trsp_keylen.
  <vim_corr_keyx>(trsp_keylen) = <tab_key_x>(trsp_keylen).
  PERFORM update_corr_keytab USING cm_action retcode.
  ADD: retcode TO rc, 1 TO count.
  IF rc LT count AND cm_action NE pruefen.
    CLEAR rc.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZV_EXTLIEF......................................*
FORM get_data_zv_extlief.
  PERFORM vim_fill_wheretab.
*.read data from database.............................................*
  REFRESH total.
  CLEAR   total.
  SELECT * FROM zcus_extlief WHERE
(vim_wheretab) .
    CLEAR zv_extlief .
    zv_extlief-mandt =
    zcus_extlief-mandt .
    zv_extlief-dienstleistung =
    zcus_extlief-dienstleistung .
    zv_extlief-ext_dienstlif =
    zcus_extlief-ext_dienstlif .
    SELECT SINGLE * FROM zcus_extlieft WHERE
dienstleistung = zcus_extlief-dienstleistung AND
ext_dienstlif = zcus_extlief-ext_dienstlif AND
spras = sy-langu .
    IF sy-subrc EQ 0.
      zv_extlief-ext_dienstlifbez =
      zcus_extlieft-ext_dienstlifbez .
    ENDIF.
    <vim_total_struc> = zv_extlief.
    APPEND total.
  ENDSELECT.
  SORT total BY <vim_xtotal_key>.
  <status>-alr_sorted = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF x_header-selection NE space.
    PERFORM check_dynamic_select_options.
  ELSEIF x_header-delmdtflag NE space.
    PERFORM build_mainkey_tab.
  ENDIF.
  REFRESH extract.
ENDFORM.
*---------------------------------------------------------------------*
FORM db_upd_zv_extlief .
*.process data base updates/inserts/deletes.........................*
  LOOP AT total.
    CHECK <action> NE original.
    MOVE <vim_total_struc> TO zv_extlief.
    IF <action> = update_geloescht.
      <action> = geloescht.
    ENDIF.
    CASE <action>.
      WHEN neuer_geloescht.
        IF status_zv_extlief-st_delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key>.
          IF sy-subrc EQ 0.
            DELETE extract INDEX sy-tabix.
          ENDIF.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN geloescht.
        SELECT SINGLE FOR UPDATE * FROM zcus_extlief WHERE
        dienstleistung = zv_extlief-dienstleistung AND
        ext_dienstlif = zv_extlief-ext_dienstlif .
        IF sy-subrc = 0.
          DELETE zcus_extlief .
        ENDIF.
        DELETE FROM zcus_extlieft WHERE
        dienstleistung = zcus_extlief-dienstleistung AND
        ext_dienstlif = zcus_extlief-ext_dienstlif .
        IF status-delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key> BINARY SEARCH.
          DELETE extract INDEX sy-tabix.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN OTHERS.
        SELECT SINGLE FOR UPDATE * FROM zcus_extlief WHERE
        dienstleistung = zv_extlief-dienstleistung AND
        ext_dienstlif = zv_extlief-ext_dienstlif .
        IF sy-subrc <> 0.   "insert preprocessing: init WA
          CLEAR zcus_extlief.
        ENDIF.
        zcus_extlief-mandt =
        zv_extlief-mandt .
        zcus_extlief-dienstleistung =
        zv_extlief-dienstleistung .
        zcus_extlief-ext_dienstlif =
        zv_extlief-ext_dienstlif .
        IF sy-subrc = 0.
          UPDATE zcus_extlief .
        ELSE.
          INSERT zcus_extlief .
        ENDIF.
        SELECT SINGLE FOR UPDATE * FROM zcus_extlieft WHERE
        dienstleistung = zcus_extlief-dienstleistung AND
        ext_dienstlif = zcus_extlief-ext_dienstlif AND
        spras = sy-langu .
        IF sy-subrc <> 0.   "insert preprocessing: init WA
          CLEAR zcus_extlieft.
          zcus_extlieft-dienstleistung =
          zcus_extlief-dienstleistung .
          zcus_extlieft-ext_dienstlif =
          zcus_extlief-ext_dienstlif .
          zcus_extlieft-spras =
          sy-langu .
        ENDIF.
        zcus_extlieft-ext_dienstlifbez =
        zv_extlief-ext_dienstlifbez .
        IF sy-subrc = 0.
          UPDATE zcus_extlieft .
        ELSE.
          INSERT zcus_extlieft .
        ENDIF.
        READ TABLE extract WITH KEY <vim_xtotal_key>.
        IF sy-subrc EQ 0.
          <xact> = original.
          MODIFY extract INDEX sy-tabix.
        ENDIF.
        <action> = original.
        MODIFY total.
    ENDCASE.
  ENDLOOP.
  CLEAR: status_zv_extlief-upd_flag,
  status_zv_extlief-upd_checkd.
  MESSAGE s018(sv).
ENDFORM.
*---------------------------------------------------------------------*
FORM read_single_entry_zv_extlief.
  SELECT SINGLE * FROM zcus_extlief WHERE
dienstleistung = zv_extlief-dienstleistung AND
ext_dienstlif = zv_extlief-ext_dienstlif .
  zv_extlief-mandt =
  zcus_extlief-mandt .
  zv_extlief-dienstleistung =
  zcus_extlief-dienstleistung .
  zv_extlief-ext_dienstlif =
  zcus_extlief-ext_dienstlif .
  SELECT SINGLE * FROM zcus_extlieft WHERE
dienstleistung = zcus_extlief-dienstleistung AND
ext_dienstlif = zcus_extlief-ext_dienstlif AND
spras = sy-langu .
  IF sy-subrc EQ 0.
    zv_extlief-ext_dienstlifbez =
    zcus_extlieft-ext_dienstlifbez .
  ELSE.
    CLEAR sy-subrc.
    CLEAR zv_extlief-ext_dienstlifbez .
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
FORM corr_maint_zv_extlief USING VALUE(cm_action) rc.
  DATA: retcode     LIKE sy-subrc, count TYPE i, trsp_keylen TYPE syfleng.
  FIELD-SYMBOLS: <tab_key_x> TYPE x.
  CLEAR rc.
  MOVE zv_extlief-dienstleistung TO
  zcus_extlief-dienstleistung .
  MOVE zv_extlief-ext_dienstlif TO
  zcus_extlief-ext_dienstlif .
  MOVE zv_extlief-mandt TO
  zcus_extlief-mandt .
  corr_keytab             =  e071k.
  corr_keytab-objname     = 'ZCUS_EXTLIEF'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN corr_keytab-tabkey TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN zcus_extlief TO <tab_key_x> CASTING.
  PERFORM vim_get_trspkeylen
    USING 'ZCUS_EXTLIEF'
    CHANGING trsp_keylen.
  <vim_corr_keyx>(trsp_keylen) = <tab_key_x>(trsp_keylen).
  PERFORM update_corr_keytab USING cm_action retcode.
  ADD: retcode TO rc, 1 TO count.
  IF rc LT count AND cm_action NE pruefen.
    CLEAR rc.
  ENDIF.

  MOVE zcus_extlief-dienstleistung TO
  zcus_extlieft-dienstleistung .
  MOVE zcus_extlief-ext_dienstlif TO
  zcus_extlieft-ext_dienstlif .
  MOVE sy-langu TO
  zcus_extlieft-spras .
  MOVE zv_extlief-mandt TO
  zcus_extlieft-mandt .
  corr_keytab             =  e071k.
  corr_keytab-objname     = 'ZCUS_EXTLIEFT'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN corr_keytab-tabkey TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN zcus_extlieft TO <tab_key_x> CASTING.
  PERFORM vim_get_trspkeylen
    USING 'ZCUS_EXTLIEFT'
    CHANGING trsp_keylen.
  <vim_corr_keyx>(trsp_keylen) = <tab_key_x>(trsp_keylen).
  PERFORM update_corr_keytab USING cm_action retcode.
  ADD: retcode TO rc, 1 TO count.
  IF rc LT count AND cm_action NE pruefen.
    CLEAR rc.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZV_EXTMEAS......................................*
FORM get_data_zv_extmeas.
  PERFORM vim_fill_wheretab.
*.read data from database.............................................*
  REFRESH total.
  CLEAR   total.
  SELECT * FROM zcus_extmeas WHERE
(vim_wheretab) .
    CLEAR zv_extmeas .
    zv_extmeas-mandt =
    zcus_extmeas-mandt .
    zv_extmeas-dienstleistung =
    zcus_extmeas-dienstleistung .
    zv_extmeas-meas =
    zcus_extmeas-meas .
    SELECT SINGLE * FROM tivbdmeas WHERE
meas = zcus_extmeas-meas .
    IF sy-subrc EQ 0.
      SELECT SINGLE * FROM tivbdmeast WHERE
meas = tivbdmeas-meas AND
spras = sy-langu .
      IF sy-subrc EQ 0.
        zv_extmeas-xmmeas =
        tivbdmeast-xmmeas .
      ENDIF.
    ENDIF.
    <vim_total_struc> = zv_extmeas.
    APPEND total.
  ENDSELECT.
  SORT total BY <vim_xtotal_key>.
  <status>-alr_sorted = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF x_header-selection NE space.
    PERFORM check_dynamic_select_options.
  ELSEIF x_header-delmdtflag NE space.
    PERFORM build_mainkey_tab.
  ENDIF.
  REFRESH extract.
ENDFORM.
*---------------------------------------------------------------------*
FORM db_upd_zv_extmeas .
*.process data base updates/inserts/deletes.........................*
  LOOP AT total.
    CHECK <action> NE original.
    MOVE <vim_total_struc> TO zv_extmeas.
    IF <action> = update_geloescht.
      <action> = geloescht.
    ENDIF.
    CASE <action>.
      WHEN neuer_geloescht.
        IF status_zv_extmeas-st_delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key>.
          IF sy-subrc EQ 0.
            DELETE extract INDEX sy-tabix.
          ENDIF.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN geloescht.
        SELECT SINGLE FOR UPDATE * FROM zcus_extmeas WHERE
        dienstleistung = zv_extmeas-dienstleistung AND
        meas = zv_extmeas-meas .
        IF sy-subrc = 0.
          DELETE zcus_extmeas .
        ENDIF.
        IF status-delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key> BINARY SEARCH.
          DELETE extract INDEX sy-tabix.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN OTHERS.
        SELECT SINGLE FOR UPDATE * FROM zcus_extmeas WHERE
        dienstleistung = zv_extmeas-dienstleistung AND
        meas = zv_extmeas-meas .
        IF sy-subrc <> 0.   "insert preprocessing: init WA
          CLEAR zcus_extmeas.
        ENDIF.
        zcus_extmeas-mandt =
        zv_extmeas-mandt .
        zcus_extmeas-dienstleistung =
        zv_extmeas-dienstleistung .
        zcus_extmeas-meas =
        zv_extmeas-meas .
        IF sy-subrc = 0.
          UPDATE zcus_extmeas .
        ELSE.
          INSERT zcus_extmeas .
        ENDIF.
        READ TABLE extract WITH KEY <vim_xtotal_key>.
        IF sy-subrc EQ 0.
          <xact> = original.
          MODIFY extract INDEX sy-tabix.
        ENDIF.
        <action> = original.
        MODIFY total.
    ENDCASE.
  ENDLOOP.
  CLEAR: status_zv_extmeas-upd_flag,
  status_zv_extmeas-upd_checkd.
  MESSAGE s018(sv).
ENDFORM.
*---------------------------------------------------------------------*
FORM read_single_entry_zv_extmeas.
  SELECT SINGLE * FROM zcus_extmeas WHERE
dienstleistung = zv_extmeas-dienstleistung AND
meas = zv_extmeas-meas .
  zv_extmeas-mandt =
  zcus_extmeas-mandt .
  zv_extmeas-dienstleistung =
  zcus_extmeas-dienstleistung .
  zv_extmeas-meas =
  zcus_extmeas-meas .
  SELECT SINGLE * FROM tivbdmeas WHERE
meas = zcus_extmeas-meas .
  IF sy-subrc EQ 0.
    SELECT SINGLE * FROM tivbdmeast WHERE
meas = tivbdmeas-meas AND
spras = sy-langu .
    IF sy-subrc EQ 0.
      zv_extmeas-xmmeas =
      tivbdmeast-xmmeas .
    ELSE.
      CLEAR sy-subrc.
      CLEAR zv_extmeas-xmmeas .
    ENDIF.
  ELSE.
    CLEAR sy-subrc.
    CLEAR zv_extmeas-xmmeas .
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
FORM corr_maint_zv_extmeas USING VALUE(cm_action) rc.
  DATA: retcode     LIKE sy-subrc, count TYPE i, trsp_keylen TYPE syfleng.
  FIELD-SYMBOLS: <tab_key_x> TYPE x.
  CLEAR rc.
  MOVE zv_extmeas-dienstleistung TO
  zcus_extmeas-dienstleistung .
  MOVE zv_extmeas-meas TO
  zcus_extmeas-meas .
  MOVE zv_extmeas-mandt TO
  zcus_extmeas-mandt .
  corr_keytab             =  e071k.
  corr_keytab-objname     = 'ZCUS_EXTMEAS'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN corr_keytab-tabkey TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN zcus_extmeas TO <tab_key_x> CASTING.
  PERFORM vim_get_trspkeylen
    USING 'ZCUS_EXTMEAS'
    CHANGING trsp_keylen.
  <vim_corr_keyx>(trsp_keylen) = <tab_key_x>(trsp_keylen).
  PERFORM update_corr_keytab USING cm_action retcode.
  ADD: retcode TO rc, 1 TO count.
  IF rc LT count AND cm_action NE pruefen.
    CLEAR rc.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
FORM compl_zv_extmeas USING workarea.
*      provides (read-only) fields from secondary tables related
*      to primary tables by foreignkey relationships
  zcus_extmeas-mandt =
  zv_extmeas-mandt .
  zcus_extmeas-dienstleistung =
  zv_extmeas-dienstleistung .
  zcus_extmeas-meas =
  zv_extmeas-meas .
  SELECT SINGLE * FROM tivbdmeas WHERE
meas = zcus_extmeas-meas .
  IF sy-subrc EQ 0.
    SELECT SINGLE * FROM tivbdmeast WHERE
meas = tivbdmeas-meas AND
spras = sy-langu .
    IF sy-subrc EQ 0.
      zv_extmeas-xmmeas =
      tivbdmeast-xmmeas .
    ELSE.
      CLEAR sy-subrc.
      CLEAR zv_extmeas-xmmeas .
    ENDIF.
  ELSE.
    CLEAR sy-subrc.
    CLEAR zv_extmeas-xmmeas .
  ENDIF.
ENDFORM.
*...processing: ZV_EXTSNUNR.....................................*
FORM get_data_zv_extsnunr.
  PERFORM vim_fill_wheretab.
*.read data from database.............................................*
  REFRESH total.
  CLEAR   total.
  SELECT * FROM zcus_extsnunr WHERE
(vim_wheretab) .
    CLEAR zv_extsnunr .
    zv_extsnunr-mandt =
    zcus_extsnunr-mandt .
    zv_extsnunr-dienstleistung =
    zcus_extsnunr-dienstleistung .
    zv_extsnunr-meas =
    zcus_extsnunr-meas .
    zv_extsnunr-snunr =
    zcus_extsnunr-snunr .
    SELECT SINGLE * FROM tiv01 WHERE
snunr = zcus_extsnunr-snunr .
    IF sy-subrc EQ 0.
      SELECT SINGLE * FROM tiv0a WHERE
snunr = tiv01-snunr AND
spras = sy-langu .
      IF sy-subrc EQ 0.
        zv_extsnunr-xmbez =
        tiv0a-xmbez .
      ENDIF.
    ENDIF.
    <vim_total_struc> = zv_extsnunr.
    APPEND total.
  ENDSELECT.
  SORT total BY <vim_xtotal_key>.
  <status>-alr_sorted = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF x_header-selection NE space.
    PERFORM check_dynamic_select_options.
  ELSEIF x_header-delmdtflag NE space.
    PERFORM build_mainkey_tab.
  ENDIF.
  REFRESH extract.
ENDFORM.
*---------------------------------------------------------------------*
FORM db_upd_zv_extsnunr .
*.process data base updates/inserts/deletes.........................*
  LOOP AT total.
    CHECK <action> NE original.
    MOVE <vim_total_struc> TO zv_extsnunr.
    IF <action> = update_geloescht.
      <action> = geloescht.
    ENDIF.
    CASE <action>.
      WHEN neuer_geloescht.
        IF status_zv_extsnunr-st_delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key>.
          IF sy-subrc EQ 0.
            DELETE extract INDEX sy-tabix.
          ENDIF.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN geloescht.
        SELECT SINGLE FOR UPDATE * FROM zcus_extsnunr WHERE
        dienstleistung = zv_extsnunr-dienstleistung AND
        meas = zv_extsnunr-meas AND
        snunr = zv_extsnunr-snunr .
        IF sy-subrc = 0.
          DELETE zcus_extsnunr .
        ENDIF.
        IF status-delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key> BINARY SEARCH.
          DELETE extract INDEX sy-tabix.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN OTHERS.
        SELECT SINGLE FOR UPDATE * FROM zcus_extsnunr WHERE
        dienstleistung = zv_extsnunr-dienstleistung AND
        meas = zv_extsnunr-meas AND
        snunr = zv_extsnunr-snunr .
        IF sy-subrc <> 0.   "insert preprocessing: init WA
          CLEAR zcus_extsnunr.
        ENDIF.
        zcus_extsnunr-mandt =
        zv_extsnunr-mandt .
        zcus_extsnunr-dienstleistung =
        zv_extsnunr-dienstleistung .
        zcus_extsnunr-meas =
        zv_extsnunr-meas .
        zcus_extsnunr-snunr =
        zv_extsnunr-snunr .
        IF sy-subrc = 0.
          UPDATE zcus_extsnunr .
        ELSE.
          INSERT zcus_extsnunr .
        ENDIF.
        READ TABLE extract WITH KEY <vim_xtotal_key>.
        IF sy-subrc EQ 0.
          <xact> = original.
          MODIFY extract INDEX sy-tabix.
        ENDIF.
        <action> = original.
        MODIFY total.
    ENDCASE.
  ENDLOOP.
  CLEAR: status_zv_extsnunr-upd_flag,
  status_zv_extsnunr-upd_checkd.
  MESSAGE s018(sv).
ENDFORM.
*---------------------------------------------------------------------*
FORM read_single_zv_extsnunr.
  SELECT SINGLE * FROM zcus_extsnunr WHERE
dienstleistung = zv_extsnunr-dienstleistung AND
meas = zv_extsnunr-meas AND
snunr = zv_extsnunr-snunr .
  zv_extsnunr-mandt =
  zcus_extsnunr-mandt .
  zv_extsnunr-dienstleistung =
  zcus_extsnunr-dienstleistung .
  zv_extsnunr-meas =
  zcus_extsnunr-meas .
  zv_extsnunr-snunr =
  zcus_extsnunr-snunr .
  SELECT SINGLE * FROM tiv01 WHERE
snunr = zcus_extsnunr-snunr .
  IF sy-subrc EQ 0.
    SELECT SINGLE * FROM tiv0a WHERE
snunr = tiv01-snunr AND
spras = sy-langu .
    IF sy-subrc EQ 0.
      zv_extsnunr-xmbez =
      tiv0a-xmbez .
    ELSE.
      CLEAR sy-subrc.
      CLEAR zv_extsnunr-xmbez .
    ENDIF.
  ELSE.
    CLEAR sy-subrc.
    CLEAR zv_extsnunr-xmbez .
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
FORM corr_maint_zv_extsnunr USING VALUE(cm_action) rc.
  DATA: retcode     LIKE sy-subrc, count TYPE i, trsp_keylen TYPE syfleng.
  FIELD-SYMBOLS: <tab_key_x> TYPE x.
  CLEAR rc.
  MOVE zv_extsnunr-dienstleistung TO
  zcus_extsnunr-dienstleistung .
  MOVE zv_extsnunr-meas TO
  zcus_extsnunr-meas .
  MOVE zv_extsnunr-snunr TO
  zcus_extsnunr-snunr .
  MOVE zv_extsnunr-mandt TO
  zcus_extsnunr-mandt .
  corr_keytab             =  e071k.
  corr_keytab-objname     = 'ZCUS_EXTSNUNR'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN corr_keytab-tabkey TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN zcus_extsnunr TO <tab_key_x> CASTING.
  PERFORM vim_get_trspkeylen
    USING 'ZCUS_EXTSNUNR'
    CHANGING trsp_keylen.
  <vim_corr_keyx>(trsp_keylen) = <tab_key_x>(trsp_keylen).
  PERFORM update_corr_keytab USING cm_action retcode.
  ADD: retcode TO rc, 1 TO count.
  IF rc LT count AND cm_action NE pruefen.
    CLEAR rc.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
FORM compl_zv_extsnunr USING workarea.
*      provides (read-only) fields from secondary tables related
*      to primary tables by foreignkey relationships
  zcus_extsnunr-mandt =
  zv_extsnunr-mandt .
  zcus_extsnunr-dienstleistung =
  zv_extsnunr-dienstleistung .
  zcus_extsnunr-meas =
  zv_extsnunr-meas .
  zcus_extsnunr-snunr =
  zv_extsnunr-snunr .
  SELECT SINGLE * FROM tiv01 WHERE
snunr = zcus_extsnunr-snunr .
  IF sy-subrc EQ 0.
    SELECT SINGLE * FROM tiv0a WHERE
snunr = tiv01-snunr AND
spras = sy-langu .
    IF sy-subrc EQ 0.
      zv_extsnunr-xmbez =
      tiv0a-xmbez .
    ELSE.
      CLEAR sy-subrc.
      CLEAR zv_extsnunr-xmbez .
    ENDIF.
  ELSE.
    CLEAR sy-subrc.
    CLEAR zv_extsnunr-xmbez .
  ENDIF.
ENDFORM.
*...processing: ZV_VERZEICHNIS..................................*
FORM get_data_zv_verzeichnis.
  PERFORM vim_fill_wheretab.
*.read data from database.............................................*
  REFRESH total.
  CLEAR   total.
  SELECT * FROM zcus_extdirect WHERE
(vim_wheretab) .
    CLEAR zv_verzeichnis .
    zv_verzeichnis-mandt =
    zcus_extdirect-mandt .
    zv_verzeichnis-dienstleistung =
    zcus_extdirect-dienstleistung .
    zv_verzeichnis-ext_dierectory =
    zcus_extdirect-ext_dierectory .
    <vim_total_struc> = zv_verzeichnis.
    APPEND total.
  ENDSELECT.
  SORT total BY <vim_xtotal_key>.
  <status>-alr_sorted = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF x_header-selection NE space.
    PERFORM check_dynamic_select_options.
  ELSEIF x_header-delmdtflag NE space.
    PERFORM build_mainkey_tab.
  ENDIF.
  REFRESH extract.
ENDFORM.
*---------------------------------------------------------------------*
FORM db_upd_zv_verzeichnis .
*.process data base updates/inserts/deletes.........................*
  LOOP AT total.
    CHECK <action> NE original.
    MOVE <vim_total_struc> TO zv_verzeichnis.
    IF <action> = update_geloescht.
      <action> = geloescht.
    ENDIF.
    CASE <action>.
      WHEN neuer_geloescht.
        IF status_zv_verzeichnis-st_delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key>.
          IF sy-subrc EQ 0.
            DELETE extract INDEX sy-tabix.
          ENDIF.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN geloescht.
        SELECT SINGLE FOR UPDATE * FROM zcus_extdirect WHERE
        dienstleistung = zv_verzeichnis-dienstleistung AND
        ext_dierectory = zv_verzeichnis-ext_dierectory .
        IF sy-subrc = 0.
          DELETE zcus_extdirect .
        ENDIF.
        IF status-delete EQ geloescht.
          READ TABLE extract WITH KEY <vim_xtotal_key> BINARY SEARCH.
          DELETE extract INDEX sy-tabix.
        ENDIF.
        DELETE total.
        IF x_header-delmdtflag NE space.
          PERFORM delete_from_mainkey_tab.
        ENDIF.
      WHEN OTHERS.
        SELECT SINGLE FOR UPDATE * FROM zcus_extdirect WHERE
        dienstleistung = zv_verzeichnis-dienstleistung AND
        ext_dierectory = zv_verzeichnis-ext_dierectory .
        IF sy-subrc <> 0.   "insert preprocessing: init WA
          CLEAR zcus_extdirect.
        ENDIF.
        zcus_extdirect-mandt =
        zv_verzeichnis-mandt .
        zcus_extdirect-dienstleistung =
        zv_verzeichnis-dienstleistung .
        zcus_extdirect-ext_dierectory =
        zv_verzeichnis-ext_dierectory .
        IF sy-subrc = 0.
          UPDATE zcus_extdirect .
        ELSE.
          INSERT zcus_extdirect .
        ENDIF.
        READ TABLE extract WITH KEY <vim_xtotal_key>.
        IF sy-subrc EQ 0.
          <xact> = original.
          MODIFY extract INDEX sy-tabix.
        ENDIF.
        <action> = original.
        MODIFY total.
    ENDCASE.
  ENDLOOP.
  CLEAR: status_zv_verzeichnis-upd_flag,
  status_zv_verzeichnis-upd_checkd.
  MESSAGE s018(sv).
ENDFORM.
*---------------------------------------------------------------------*
FORM read_single_zv_verzeichnis.
  SELECT SINGLE * FROM zcus_extdirect WHERE
dienstleistung = zv_verzeichnis-dienstleistung AND
ext_dierectory = zv_verzeichnis-ext_dierectory .
  zv_verzeichnis-mandt =
  zcus_extdirect-mandt .
  zv_verzeichnis-dienstleistung =
  zcus_extdirect-dienstleistung .
  zv_verzeichnis-ext_dierectory =
  zcus_extdirect-ext_dierectory .
ENDFORM.
*---------------------------------------------------------------------*
FORM corr_maint_zv_verzeichnis USING VALUE(cm_action) rc.
  DATA: retcode     LIKE sy-subrc, count TYPE i, trsp_keylen TYPE syfleng.
  FIELD-SYMBOLS: <tab_key_x> TYPE x.
  CLEAR rc.
  MOVE zv_verzeichnis-dienstleistung TO
  zcus_extdirect-dienstleistung .
  MOVE zv_verzeichnis-ext_dierectory TO
  zcus_extdirect-ext_dierectory .
  MOVE zv_verzeichnis-mandt TO
  zcus_extdirect-mandt .
  corr_keytab             =  e071k.
  corr_keytab-objname     = 'ZCUS_EXTDIRECT'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN corr_keytab-tabkey TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN zcus_extdirect TO <tab_key_x> CASTING.
  PERFORM vim_get_trspkeylen
    USING 'ZCUS_EXTDIRECT'
    CHANGING trsp_keylen.
  <vim_corr_keyx>(trsp_keylen) = <tab_key_x>(trsp_keylen).
  PERFORM update_corr_keytab USING cm_action retcode.
  ADD: retcode TO rc, 1 TO count.
  IF rc LT count AND cm_action NE pruefen.
    CLEAR rc.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
