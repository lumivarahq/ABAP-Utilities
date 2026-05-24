class ltcl_csv definition final
  for testing
  duration short
  risk level harmless.

  private section.
    types:
      begin of ty_row,
        id   type i,
        name type string,
        city type string,
      end of ty_row,
      tt_row type standard table of ty_row with default key.

    methods header_row     for testing.
    methods quoting        for testing.
    methods roundtrip      for testing.
    methods roundtrip_pos  for testing.
endclass.


class ltcl_csv implementation.
  method header_row.
    data(lt) = value tt_row( ( id = 1 name = `Ann`  city = `Berlin` ) ).
    data(lv_csv) = zcl_au_csv=>from_table( lt ).
    " header line uses the (lower-case) component names
    cl_abap_unit_assert=>assert_char_cp(
      exp = `id,name,city*`
      act = lv_csv ).
  endmethod.

  method quoting.
    data(lt) = value tt_row( ( id = 1 name = `Doe, John` city = `A"B` ) ).
    data(lv_csv) = zcl_au_csv=>from_table( it_table = lt iv_header = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      exp = |1,"Doe, John","A""B"|
      act = lv_csv ).
  endmethod.

  method roundtrip.
    data(lt_in) = value tt_row( ( id = 1 name = `Doe, John` city = `A"B` )
                                ( id = 2 name = `Ann`       city = `Berlin` ) ).
    data(lv_csv) = zcl_au_csv=>from_table( lt_in ).

    data lt_out type tt_row.
    zcl_au_csv=>to_table( exporting iv_csv = lv_csv
                          changing  ct_table = lt_out ).

    cl_abap_unit_assert=>assert_equals( exp = lt_in act = lt_out ).
  endmethod.

  method roundtrip_pos.
    data(lt_in) = value tt_row( ( id = 7 name = `Zoe` city = `Rome` ) ).
    data(lv_csv) = zcl_au_csv=>from_table( it_table = lt_in iv_header = abap_false ).

    data lt_out type tt_row.
    zcl_au_csv=>to_table( exporting iv_csv   = lv_csv
                                    iv_header = abap_false
                          changing  ct_table = lt_out ).

    cl_abap_unit_assert=>assert_equals( exp = lt_in act = lt_out ).
  endmethod.
endclass.
