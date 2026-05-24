interface zif_au_log
  public.

  "! Fluent application-log abstraction. All "add" methods return the
  "! logger itself so calls can be chained:
  "!   lo_log->info( `start` )->warning( `careful` )->save( ).

  methods info
    importing
      !iv_text       type string
    returning
      value(ro_self) type ref to zif_au_log.

  methods success
    importing
      !iv_text       type string
    returning
      value(ro_self) type ref to zif_au_log.

  methods warning
    importing
      !iv_text       type string
    returning
      value(ro_self) type ref to zif_au_log.

  methods error
    importing
      !iv_text       type string
    returning
      value(ro_self) type ref to zif_au_log.

  "! Add an exception together with its full "previous" chain.
  methods add_exception
    importing
      !io_exception  type ref to cx_root
    returning
      value(ro_self) type ref to zif_au_log.

  "! Add all rows of a BAPIRET2 return table.
  methods add_bapiret
    importing
      !it_return     type bapiret2_t
    returning
      value(ro_self) type ref to zif_au_log.

  "! Add the message currently held in the sy-msg* fields.
  methods add_from_sy
    returning
      value(ro_self) type ref to zif_au_log.

  "! Persist the log to the database (BAL).
  methods save
    importing
      !iv_commit          type abap_bool default abap_true
    returning
      value(rv_lognumber) type balognr
    raising
      zcx_au_error.

  "! The underlying BAL log handle (for advanced/native use).
  methods handle
    returning
      value(rv_handle) type balloghndl.

endinterface.
