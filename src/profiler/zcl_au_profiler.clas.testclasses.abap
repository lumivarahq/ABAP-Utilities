class ltcl_profiler definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods sorts_slowest_first for testing.
    methods aggregates          for testing.
    methods reset_clears         for testing.
endclass.


class ltcl_profiler implementation.
  method sorts_slowest_first.
    data(lo) = new zcl_au_profiler( ).
    lo->record( iv_step = `SELECT_A` iv_micros = 4000000 ).
    lo->record( iv_step = `SELECT_A` iv_micros = 2000000 ).
    lo->record( iv_step = `LOOP_B`   iv_micros = 1000000 ).

    data(lt) = lo->report( ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt ) ).
    " slowest first
    cl_abap_unit_assert=>assert_equals( exp = `SELECT_A` act = lt[ 1 ]-step ).
    cl_abap_unit_assert=>assert_equals( exp = `LOOP_B`   act = lt[ 2 ]-step ).
    " percent is highest for the slowest
    cl_abap_unit_assert=>assert_true( xsdbool( lt[ 1 ]-percent > lt[ 2 ]-percent ) ).
  endmethod.

  method aggregates.
    data(lo) = new zcl_au_profiler( ).
    lo->record( iv_step = `X` iv_micros = 4000000 ).
    lo->record( iv_step = `X` iv_micros = 2000000 ).

    data(lt) = lo->report( ).
    data(ls) = lt[ 1 ].
    cl_abap_unit_assert=>assert_equals( exp = 2       act = ls-count ).
    cl_abap_unit_assert=>assert_equals( exp = 6000000 act = ls-total_us ).
    cl_abap_unit_assert=>assert_equals( exp = 3000000 act = ls-avg_us ).
    cl_abap_unit_assert=>assert_equals( exp = 2000000 act = ls-min_us ).
    cl_abap_unit_assert=>assert_equals( exp = 4000000 act = ls-max_us ).
  endmethod.

  method reset_clears.
    data(lo) = new zcl_au_profiler( ).
    lo->record( iv_step = `X` iv_micros = 1000 ).
    lo->reset( ).
    cl_abap_unit_assert=>assert_initial( act = lo->report( ) ).
  endmethod.
endclass.
