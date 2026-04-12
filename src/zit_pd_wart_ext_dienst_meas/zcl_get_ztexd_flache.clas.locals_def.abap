TYPE-POOLS:
  abap.

TYPES:
* buffer for table data
  BEGIN OF ts_buffer_hl.
    INCLUDE TYPE ztexd_flache.
TYPES: _not_found TYPE abap_bool,
  END OF ts_buffer_hl,

  tt_buffer TYPE SORTED TABLE OF ts_buffer_hl
            WITH UNIQUE KEY dienstleistung
                            objnr
                            meas
                            meas_guid
  .

TYPES:
* buffer for accesses with partial key
  BEGIN OF ts_acc_partkey_buffer_hl,
    _partkey_index TYPE numc2,
    dienstleistung TYPE ztexd_flache-dienstleistung, "objnr
    objnr          TYPE ztexd_flache-objnr, "meas
    meas           TYPE ztexd_flache-meas, "meas_guid
  END OF ts_acc_partkey_buffer_hl,

  tt_acc_partkey_buffer TYPE HASHED TABLE OF ts_acc_partkey_buffer_hl
                        WITH UNIQUE KEY table_line.

TYPES:
* buffer for mapping guid => table data
  BEGIN OF ts_map_guid_buffer_hl,
    _map_guid      TYPE recaguid,
    dienstleistung TYPE ztexd_flache-dienstleistung,
    objnr          TYPE ztexd_flache-objnr,
    meas           TYPE ztexd_flache-meas,
    meas_guid      TYPE ztexd_flache-meas_guid,
    _not_found     TYPE abap_bool,
  END OF ts_map_guid_buffer_hl,

  tt_map_guid_buffer TYPE HASHED TABLE OF ts_map_guid_buffer_hl
                     WITH UNIQUE KEY _map_guid.
