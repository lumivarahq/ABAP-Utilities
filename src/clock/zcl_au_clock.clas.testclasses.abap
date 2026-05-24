class ltcl_clock definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods fixed_is_deterministic for testing.
    methods system_is_bound        for testing.
endclass.


class ltcl_clock implementation.
  method fixed_is_deterministic.
    " A fixed clock must report exactly the frozen moment (UTC).
    data(lo_clock) = zcl_au_clock=>fixed( conv timestampl( '20260524120000' ) ).
    cl_abap_unit_assert=>assert_equals( exp = conv d( '20260524' )
                                        act = lo_clock->now_date( ) ).
    cl_abap_unit_assert=>assert_equals( exp = conv t( '120000' )
                                        act = lo_clock->now_time( ) ).
  endmethod.

  method system_is_bound.
    " The system clock should at least produce a non-initial, recent date.
    data(lo_clock) = zcl_au_clock=>system( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lo_clock->now_date( ) is not initial ) ).
  endmethod.
endclass.
