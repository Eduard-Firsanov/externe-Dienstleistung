*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZV_AENDGRUND....................................*
TABLES: zv_aendgrund, *zv_aendgrund. "view work areas
CONTROLS: tctrl_zv_aendgrund
TYPE TABLEVIEW USING SCREEN '0004'.
DATA: BEGIN OF status_zv_aendgrund. "state vector
        INCLUDE STRUCTURE vimstatus.
DATA: END OF status_zv_aendgrund.
* Table for entries selected to show on screen
DATA: BEGIN OF zv_aendgrund_extract OCCURS 0010.
        INCLUDE STRUCTURE zv_aendgrund.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_aendgrund_extract.
* Table for all entries loaded from database
DATA: BEGIN OF zv_aendgrund_total OCCURS 0010.
        INCLUDE STRUCTURE zv_aendgrund.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_aendgrund_total.

*...processing: ZV_AKTIVIT......................................*
TABLES: zv_aktivit, *zv_aktivit. "view work areas
CONTROLS: tctrl_zv_aktivit
TYPE TABLEVIEW USING SCREEN '0005'.
DATA: BEGIN OF status_zv_aktivit. "state vector
        INCLUDE STRUCTURE vimstatus.
DATA: END OF status_zv_aktivit.
* Table for entries selected to show on screen
DATA: BEGIN OF zv_aktivit_extract OCCURS 0010.
        INCLUDE STRUCTURE zv_aktivit.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_aktivit_extract.
* Table for all entries loaded from database
DATA: BEGIN OF zv_aktivit_total OCCURS 0010.
        INCLUDE STRUCTURE zv_aktivit.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_aktivit_total.

*...processing: ZV_DIENSTLEIST..................................*
TABLES: zv_dienstleist, *zv_dienstleist. "view work areas
CONTROLS: tctrl_zv_dienstleist
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF status_zv_dienstleist. "state vector
        INCLUDE STRUCTURE vimstatus.
DATA: END OF status_zv_dienstleist.
* Table for entries selected to show on screen
DATA: BEGIN OF zv_dienstleist_extract OCCURS 0010.
        INCLUDE STRUCTURE zv_dienstleist.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_dienstleist_extract.
* Table for all entries loaded from database
DATA: BEGIN OF zv_dienstleist_total OCCURS 0010.
        INCLUDE STRUCTURE zv_dienstleist.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_dienstleist_total.

*...processing: ZV_EXTLIEF......................................*
TABLES: zv_extlief, *zv_extlief. "view work areas
CONTROLS: tctrl_zv_extlief
TYPE TABLEVIEW USING SCREEN '0002'.
DATA: BEGIN OF status_zv_extlief. "state vector
        INCLUDE STRUCTURE vimstatus.
DATA: END OF status_zv_extlief.
* Table for entries selected to show on screen
DATA: BEGIN OF zv_extlief_extract OCCURS 0010.
        INCLUDE STRUCTURE zv_extlief.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_extlief_extract.
* Table for all entries loaded from database
DATA: BEGIN OF zv_extlief_total OCCURS 0010.
        INCLUDE STRUCTURE zv_extlief.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_extlief_total.

*...processing: ZV_EXTMEAS......................................*
TABLES: zv_extmeas, *zv_extmeas. "view work areas
CONTROLS: tctrl_zv_extmeas
TYPE TABLEVIEW USING SCREEN '0003'.
DATA: BEGIN OF status_zv_extmeas. "state vector
        INCLUDE STRUCTURE vimstatus.
DATA: END OF status_zv_extmeas.
* Table for entries selected to show on screen
DATA: BEGIN OF zv_extmeas_extract OCCURS 0010.
        INCLUDE STRUCTURE zv_extmeas.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_extmeas_extract.
* Table for all entries loaded from database
DATA: BEGIN OF zv_extmeas_total OCCURS 0010.
        INCLUDE STRUCTURE zv_extmeas.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_extmeas_total.

*...processing: ZV_EXTSNUNR.....................................*
TABLES: zv_extsnunr, *zv_extsnunr. "view work areas
CONTROLS: tctrl_zv_extsnunr
TYPE TABLEVIEW USING SCREEN '0006'.
DATA: BEGIN OF status_zv_extsnunr. "state vector
        INCLUDE STRUCTURE vimstatus.
DATA: END OF status_zv_extsnunr.
* Table for entries selected to show on screen
DATA: BEGIN OF zv_extsnunr_extract OCCURS 0010.
        INCLUDE STRUCTURE zv_extsnunr.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_extsnunr_extract.
* Table for all entries loaded from database
DATA: BEGIN OF zv_extsnunr_total OCCURS 0010.
        INCLUDE STRUCTURE zv_extsnunr.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_extsnunr_total.

*...processing: ZV_VERZEICHNIS..................................*
TABLES: zv_verzeichnis, *zv_verzeichnis. "view work areas
CONTROLS: tctrl_zv_verzeichnis
TYPE TABLEVIEW USING SCREEN '0007'.
DATA: BEGIN OF status_zv_verzeichnis. "state vector
        INCLUDE STRUCTURE vimstatus.
DATA: END OF status_zv_verzeichnis.
* Table for entries selected to show on screen
DATA: BEGIN OF zv_verzeichnis_extract OCCURS 0010.
        INCLUDE STRUCTURE zv_verzeichnis.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_verzeichnis_extract.
* Table for all entries loaded from database
DATA: BEGIN OF zv_verzeichnis_total OCCURS 0010.
        INCLUDE STRUCTURE zv_verzeichnis.
        INCLUDE STRUCTURE vimflagtab.
DATA: END OF zv_verzeichnis_total.

*.........table declarations:.................................*
TABLES: tiv01                          .
TABLES: tiv0a                          .
TABLES: tivbdmeas                      .
TABLES: tivbdmeast                     .
TABLES: zcus_aktivit                   .
TABLES: zcus_aktivitt                  .
TABLES: zcus_dienstl                   .
TABLES: zcus_dienstlt                  .
TABLES: zcus_extaendgr                 .
TABLES: zcus_extaendgrt                .
TABLES: zcus_extdirect                 .
TABLES: zcus_extlief                   .
TABLES: zcus_extlieft                  .
TABLES: zcus_extmeas                   .
TABLES: zcus_extsnunr                  .
