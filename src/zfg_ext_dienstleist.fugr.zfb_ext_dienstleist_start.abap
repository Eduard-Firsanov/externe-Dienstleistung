FUNCTION zfb_ext_dienstleist_start.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(ES_SUBSCREEN) TYPE  RECASCREEN
*"--------------------------------------------------------------------



** set current subscreen
  es_subscreen-repid = sy-repid.
  es_subscreen-dynnr = '100'.




ENDFUNCTION.
