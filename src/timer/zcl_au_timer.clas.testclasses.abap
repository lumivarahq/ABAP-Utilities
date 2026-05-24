class ltcl_timer definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods elapsed_non_negative for testing.
endclass.


class ltcl_timer implementation.
  method elapsed_non_negative.
    data(lo_timer) = zcl_au_timer=>start( ).
    data lv_sink type i.
    do 1000 times.
      lv_sink = lv_sink + sy-index.
    enddo.
    cl_abap_unit_assert=>assert_true( xsdbool( lo_timer->elapsed_microseconds( ) >= 0 ) ).
  endmethod.
endclass.
