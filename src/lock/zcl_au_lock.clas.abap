class zcl_au_lock definition
  public
  final
  create public.

  public section.
    constants mode_exclusive type c length 1 value 'E' ##NO_TEXT.
    constants mode_shared    type c length 1 value 'S' ##NO_TEXT.
    constants mode_cumulate  type c length 1 value 'X' ##NO_TEXT.

    "! Set a generic SAP lock (ENQUEUE) on a name + key. Retries while the entry
    "! is held by someone else, then raises if it stays locked.
    "! @parameter iv_name | the lock name (e.g. a table name)
    "! @parameter iv_key  | the lock argument (e.g. the key value)
    "! @parameter iv_mode | E exclusive (default), S shared, X exclusive cumulative
    class-methods lock
      importing
        !iv_name type eqegraname
        !iv_key  type clike
        !iv_mode type c default 'E'
      raising
        zcx_au_error.

    "! Release a generic SAP lock (DEQUEUE). Safe to call even if not locked.
    class-methods unlock
      importing
        !iv_name type eqegraname
        !iv_key  type clike
        !iv_mode type c default 'E'.
endclass.


class zcl_au_lock implementation.
  method lock.
    data(lv_garg) = conv eqegraarg( iv_key ).

    call function 'ENQUEUE'
      exporting
        gname          = iv_name
        garg           = lv_garg
        gmode          = iv_mode
        _scope         = '2'
        _wait          = abap_true
      exceptions
        foreign_lock   = 1
        system_failure = 2
        others         = 3.

    if sy-subrc <> 0.
      zcx_au_error=>raise(
        |Could not lock { iv_name } '{ iv_key }' (rc={ sy-subrc }, held by { sy-msgv1 })| ) ##NO_TEXT.
    endif.
  endmethod.


  method unlock.
    data(lv_garg) = conv eqegraarg( iv_key ).

    call function 'DEQUEUE'
      exporting
        gname  = iv_name
        garg   = lv_garg
        gmode  = iv_mode
        _scope = '3'.
  endmethod.
endclass.
