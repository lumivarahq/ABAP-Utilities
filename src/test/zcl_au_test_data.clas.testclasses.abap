class ltcl_test_data definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods int_in_range    for testing.
    methods string_length   for testing.
    methods date_in_range   for testing.
endclass.


class ltcl_test_data implementation.
  method int_in_range.
    do 50 times.
      data(lv) = zcl_au_test_data=>random_int( iv_min = 5 iv_max = 9 ).
      cl_abap_unit_assert=>assert_true( xsdbool( lv >= 5 and lv <= 9 ) ).
    enddo.
  endmethod.

  method string_length.
    cl_abap_unit_assert=>assert_equals(
      exp = 12
      act = strlen( zcl_au_test_data=>random_string( 12 ) ) ).
  endmethod.

  method date_in_range.
    do 50 times.
      data(lv) = zcl_au_test_data=>random_date( iv_from = '20260101' iv_to = '20260131' ).
      cl_abap_unit_assert=>assert_true( xsdbool( lv >= '20260101' and lv <= '20260131' ) ).
    enddo.
  endmethod.
endclass.
