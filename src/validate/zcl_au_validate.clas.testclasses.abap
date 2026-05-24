class ltcl_validate definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods email for testing.
    methods luhn  for testing.
    methods iban  for testing.
endclass.


class ltcl_validate implementation.
  method email.
    cl_abap_unit_assert=>assert_true(  zcl_au_validate=>is_email( `jane.doe+x@example.co.uk` ) ).
    cl_abap_unit_assert=>assert_false( zcl_au_validate=>is_email( `not-an-email` ) ).
    cl_abap_unit_assert=>assert_false( zcl_au_validate=>is_email( `a@b` ) ).
  endmethod.

  method luhn.
    " well-known valid Visa test number
    cl_abap_unit_assert=>assert_true(  zcl_au_validate=>luhn_ok( `4111 1111 1111 1111` ) ).
    cl_abap_unit_assert=>assert_false( zcl_au_validate=>luhn_ok( `4111111111111112` ) ).
  endmethod.

  method iban.
    " published valid example IBANs
    cl_abap_unit_assert=>assert_true(  zcl_au_validate=>is_iban( `GB82 WEST 1234 5698 7654 32` ) ).
    cl_abap_unit_assert=>assert_true(  zcl_au_validate=>is_iban( `DE89370400440532013000` ) ).
    " wrong check digits
    cl_abap_unit_assert=>assert_false( zcl_au_validate=>is_iban( `GB82WEST12345698765431` ) ).
    cl_abap_unit_assert=>assert_false( zcl_au_validate=>is_iban( `TOO SHORT` ) ).
  endmethod.
endclass.
