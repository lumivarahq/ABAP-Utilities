class ltcl_itab definition final
  for testing
  duration short
  risk level harmless.

  private section.
    types:
      begin of ty_row,
        id   type i,
        name type string,
      end of ty_row,
      tt_row type standard table of ty_row with default key.

    methods distinct_in_place for testing.
    methods count_only        for testing.
    methods rows              for testing.
endclass.


class ltcl_itab implementation.
  method distinct_in_place.
    data(lt) = value tt_row( ( id = 1 name = `a` )
                             ( id = 1 name = `a` )
                             ( id = 2 name = `b` ) ).
    zcl_au_itab=>distinct( changing ct_table = lt ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = lines( lt ) ).
  endmethod.

  method count_only.
    data(lt) = value tt_row( ( id = 1 name = `a` )
                             ( id = 1 name = `a` )
                             ( id = 2 name = `b` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 2 act = zcl_au_itab=>count_distinct( lt ) ).
    " input is unchanged by count_distinct
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt ) ).
  endmethod.

  method rows.
    data lt type tt_row.
    cl_abap_unit_assert=>assert_false( zcl_au_itab=>has_rows( lt ) ).
    append value #( id = 1 ) to lt.
    cl_abap_unit_assert=>assert_true( zcl_au_itab=>has_rows( lt ) ).
  endmethod.
endclass.
