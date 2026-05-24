class ltcl_guard definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods that_raises_on_false for testing.
    methods that_passes_on_true  for testing.
    methods not_initial_raises   for testing.
    methods not_empty_raises     for testing.
endclass.


class ltcl_guard implementation.
  method that_raises_on_false.
    try.
        zcl_au_guard=>that( iv_condition = abap_false iv_message = `nope` ).
        cl_abap_unit_assert=>fail( 'expected ZCX_AU_ERROR' ).
      catch zcx_au_error into data(lx).
        cl_abap_unit_assert=>assert_equals( exp = `nope` act = lx->get_full_text( ) ).
    endtry.
  endmethod.

  method that_passes_on_true.
    " must NOT raise
    zcl_au_guard=>that( iv_condition = abap_true iv_message = `ignored` ).
  endmethod.

  method not_initial_raises.
    try.
        zcl_au_guard=>not_initial( iv_value = `` iv_name = `customer` ).
        cl_abap_unit_assert=>fail( 'expected ZCX_AU_ERROR' ).
      catch zcx_au_error.
    endtry.
    " a filled value passes
    zcl_au_guard=>not_initial( iv_value = `4711` ).
  endmethod.

  method not_empty_raises.
    data lt_empty type string_table.
    try.
        zcl_au_guard=>not_empty( it_table = lt_empty iv_name = `items` ).
        cl_abap_unit_assert=>fail( 'expected ZCX_AU_ERROR' ).
      catch zcx_au_error.
    endtry.
  endmethod.
endclass.
