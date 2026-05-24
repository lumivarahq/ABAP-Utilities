class ltcl_string definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods split_and_join for testing.
    methods mask_default   for testing.
    methods mask_short     for testing.
    methods snake_case     for testing.
    methods camel_case     for testing.
    methods pascal_case    for testing.
    methods numeric        for testing.
    methods padding        for testing.
    methods alpha          for testing.
    methods truncate_long  for testing.
endclass.


class ltcl_string implementation.
  method split_and_join.
    data(lt) = zcl_au_string=>split_to_table( iv_string = `a,b,c` ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( lt ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = `a-b-c`
      act = zcl_au_string=>join( it_table = lt iv_separator = `-` ) ).
  endmethod.

  method mask_default.
    " 10 chars, keep last 4 -> 6 mask chars + "7890"
    cl_abap_unit_assert=>assert_equals(
      exp = `******7890`
      act = zcl_au_string=>mask( `1234567890` ) ).
  endmethod.

  method mask_short.
    " nothing to hide -> returned unchanged
    cl_abap_unit_assert=>assert_equals(
      exp = `12`
      act = zcl_au_string=>mask( iv_string = `12` iv_visible = 4 ) ).
  endmethod.

  method snake_case.
    cl_abap_unit_assert=>assert_equals(
      exp = `order_item`
      act = zcl_au_string=>to_snake_case( `OrderItem` ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = `order_item`
      act = zcl_au_string=>to_snake_case( `Order Item` ) ).
  endmethod.

  method camel_case.
    cl_abap_unit_assert=>assert_equals(
      exp = `orderItem`
      act = zcl_au_string=>to_camel_case( `order_item` ) ).
  endmethod.

  method pascal_case.
    cl_abap_unit_assert=>assert_equals(
      exp = `OrderItem`
      act = zcl_au_string=>to_pascal_case( `order-item` ) ).
  endmethod.

  method numeric.
    cl_abap_unit_assert=>assert_true( zcl_au_string=>is_numeric( `12345` ) ).
    cl_abap_unit_assert=>assert_false( zcl_au_string=>is_numeric( `12a45` ) ).
    cl_abap_unit_assert=>assert_false( zcl_au_string=>is_numeric( `` ) ).
  endmethod.

  method padding.
    cl_abap_unit_assert=>assert_equals(
      exp = `00042`
      act = zcl_au_string=>lpad( iv_string = `42` iv_length = 5 iv_pad = '0' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = `42   `
      act = zcl_au_string=>rpad( iv_string = `42` iv_length = 5 ) ).
  endmethod.

  method alpha.
    cl_abap_unit_assert=>assert_equals(
      exp = `0000000042`
      act = zcl_au_string=>alpha_in( '42' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = `42`
      act = zcl_au_string=>alpha_out( '0000000042' ) ).
  endmethod.

  method truncate_long.
    cl_abap_unit_assert=>assert_equals(
      exp = `Hello...`
      act = zcl_au_string=>truncate( iv_string = `Hello World` iv_length = 8 ) ).
  endmethod.
endclass.
