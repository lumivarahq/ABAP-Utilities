class ltcl_base64 definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods encode_known   for testing.
    methods string_roundtrip for testing.
    methods binary_roundtrip for testing.
endclass.


class ltcl_base64 implementation.
  method encode_known.
    cl_abap_unit_assert=>assert_equals(
      exp = `YWJj`
      act = zcl_au_base64=>encode_string( `abc` ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = `SGVsbG8=`
      act = zcl_au_base64=>encode_string( `Hello` ) ).
  endmethod.

  method string_roundtrip.
    cl_abap_unit_assert=>assert_equals(
      exp = `Hello, ABAP! 0123456789`
      act = zcl_au_base64=>decode_to_string( zcl_au_base64=>encode_string( `Hello, ABAP! 0123456789` ) ) ).
  endmethod.

  method binary_roundtrip.
    data(lv_x) = conv xstring( 'DEADBEEF' ).
    cl_abap_unit_assert=>assert_equals(
      exp = lv_x
      act = zcl_au_base64=>decode( zcl_au_base64=>encode( lv_x ) ) ).
  endmethod.
endclass.
