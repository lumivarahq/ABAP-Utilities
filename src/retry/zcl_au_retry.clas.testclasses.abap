" A stub unit of work that fails the first N times, then succeeds. Used to prove
" the retry loop both retries and eventually gives up.
class ltcl_flaky definition.
  public section.
    interfaces zif_au_runnable.
    methods constructor importing iv_fail_times type i.
    data mv_calls type i read-only.
  private section.
    data mv_fail_times type i.
endclass.

class ltcl_flaky implementation.
  method constructor.
    mv_fail_times = iv_fail_times.
  endmethod.
  method zif_au_runnable~run.
    mv_calls = mv_calls + 1.
    if mv_calls <= mv_fail_times.
      zcx_au_error=>raise( |transient failure { mv_calls }| ).
    endif.
  endmethod.
endclass.


class ltcl_retry definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods succeeds_after_retries for testing.
    methods gives_up_after_max     for testing.
endclass.

class ltcl_retry implementation.
  method succeeds_after_retries.
    " fails twice, succeeds on the third attempt
    data(lo_action) = new ltcl_flaky( iv_fail_times = 2 ).
    zcl_au_retry=>run( io_action       = lo_action
                       iv_max_attempts = 3
                       iv_wait_seconds = 0 ).      " no real waiting in tests
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lo_action->mv_calls ).
  endmethod.

  method gives_up_after_max.
    data(lo_action) = new ltcl_flaky( iv_fail_times = 99 ).
    try.
        zcl_au_retry=>run( io_action       = lo_action
                           iv_max_attempts = 3
                           iv_wait_seconds = 0 ).
        cl_abap_unit_assert=>fail( 'expected ZCX_AU_ERROR after max attempts' ).
      catch zcx_au_error.
        cl_abap_unit_assert=>assert_equals( exp = 3 act = lo_action->mv_calls ).
    endtry.
  endmethod.
endclass.
