class ltcl_dyn_sql definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods quote_escapes      for testing.
    methods allow_list_passes  for testing.
    methods allow_list_rejects for testing.
    methods column_valid       for testing.
endclass.


class ltcl_dyn_sql implementation.
  method quote_escapes.
    cl_abap_unit_assert=>assert_equals( exp = `'abc'` act = zcl_au_dyn_sql=>quote( 'abc' ) ).
    " an embedded quote must be doubled (this is what blocks injection)
    cl_abap_unit_assert=>assert_equals( exp = `'O''Brien'` act = zcl_au_dyn_sql=>quote( `O'Brien` ) ).
  endmethod.

  method allow_list_passes.
    cl_abap_unit_assert=>assert_equals(
      exp = `ASC`
      act = zcl_au_dyn_sql=>allowed( iv_value = `ASC` it_allowed = value #( ( `ASC` ) ( `DESC` ) ) ) ).
  endmethod.

  method allow_list_rejects.
    try.
        zcl_au_dyn_sql=>allowed( iv_value = `; DROP TABLE` it_allowed = value #( ( `ASC` ) ( `DESC` ) ) ).
        cl_abap_unit_assert=>fail( 'expected ZCX_AU_ERROR for value outside the allow-list' ).
      catch zcx_au_error.
    endtry.
  endmethod.

  method column_valid.
    " a valid identifier passes through (does not raise)
    cl_abap_unit_assert=>assert_not_initial( act = zcl_au_dyn_sql=>column( `MATNR` ) ).
  endmethod.
endclass.
