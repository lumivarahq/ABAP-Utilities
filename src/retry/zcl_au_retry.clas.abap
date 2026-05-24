class zcl_au_retry definition
  public
  final
  create public.

  public section.
    "! Run io_action, retrying when it raises, until it succeeds or the attempts
    "! are exhausted. A resilience helper for transient failures (network, locks,
    "! RFC) - comparable to Polly (.NET) or resilience4j (Java).
    "!
    "! @parameter io_action       | the unit of work (see ZIF_AU_RUNNABLE)
    "! @parameter iv_max_attempts | total attempts incl. the first (>= 1)
    "! @parameter iv_wait_seconds | delay before the next attempt (0 = no wait)
    "! @parameter iv_exponential  | double the delay after each failure (backoff)
    "! @raising   zcx_au_error    | wraps the last error once attempts are spent
    class-methods run
      importing
        !io_action       type ref to zif_au_runnable
        !iv_max_attempts type i default 3
        !iv_wait_seconds type i default 1
        !iv_exponential  type abap_bool default abap_true
      raising
        zcx_au_error.
endclass.


class zcl_au_retry implementation.
  method run.
    data(lv_attempt) = 1.
    data(lv_wait)    = iv_wait_seconds.

    do.
      try.
          io_action->run( ).
          return.                              " success - we are done
        catch cx_root into data(lx_error).
          " Out of attempts: surface the last error (chained) and give up.
          if lv_attempt >= iv_max_attempts.
            zcx_au_error=>raise(
              text     = |Action failed after { iv_max_attempts } attempt(s): { lx_error->get_text( ) }|
              previous = lx_error ) ##NO_TEXT.
          endif.

          " Otherwise wait (optionally with exponential back-off) and try again.
          if lv_wait > 0.
            wait up to lv_wait seconds.
          endif.
          lv_attempt = lv_attempt + 1.
          if iv_exponential = abap_true.
            lv_wait = lv_wait * 2.
          endif.
      endtry.
    enddo.
  endmethod.
endclass.
