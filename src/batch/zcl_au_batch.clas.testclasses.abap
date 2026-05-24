class ltcl_batch definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods bounds_split    for testing.
    methods bounds_empty    for testing.
    methods bounds_bad_size for testing.
    methods chunking        for testing.
endclass.


class ltcl_batch implementation.
  method bounds_split.
    data(lt) = zcl_au_batch=>bounds( iv_total = 10 iv_size = 3 ).
    cl_abap_unit_assert=>assert_equals( exp = 4 act = lines( lt ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = value zcl_au_batch=>ty_bounds( index = 1 from = 1 to = 3 )
      act = lt[ 1 ] ).
    cl_abap_unit_assert=>assert_equals(
      exp = value zcl_au_batch=>ty_bounds( index = 4 from = 10 to = 10 )
      act = lt[ 4 ] ).
  endmethod.

  method bounds_empty.
    cl_abap_unit_assert=>assert_initial( act = zcl_au_batch=>bounds( iv_total = 0 iv_size = 5 ) ).
  endmethod.

  method bounds_bad_size.
    try.
        zcl_au_batch=>bounds( iv_total = 10 iv_size = 0 ).
        cl_abap_unit_assert=>fail( 'expected ZCX_AU_ERROR' ).
      catch zcx_au_error.
    endtry.
  endmethod.

  method chunking.
    data(lt) = zcl_au_batch=>chunks( it_table = value #( ( `a` ) ( `b` ) ( `c` ) ( `d` ) ( `e` ) )
                                     iv_size  = 2 ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt[ 1 ] ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( lt[ 3 ] ) ).
  endmethod.
endclass.
