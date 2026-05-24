class ltcl_semver definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods parse_full     for testing.
    methods parse_partial  for testing.
    methods parse_suffix   for testing.
    methods comparisons    for testing.
    methods at_least_check for testing.
    methods invalid_raises for testing.
endclass.


class ltcl_semver implementation.
  method parse_full.
    cl_abap_unit_assert=>assert_equals(
      exp = value zcl_au_semver=>ty_version( major = 1 minor = 2 patch = 3 )
      act = zcl_au_semver=>parse( `1.2.3` ) ).
  endmethod.

  method parse_partial.
    cl_abap_unit_assert=>assert_equals(
      exp = value zcl_au_semver=>ty_version( major = 2 minor = 0 patch = 0 )
      act = zcl_au_semver=>parse( `2` ) ).
  endmethod.

  method parse_suffix.
    cl_abap_unit_assert=>assert_equals(
      exp = value zcl_au_semver=>ty_version( major = 1 minor = 2 patch = 3 )
      act = zcl_au_semver=>parse( `1.2.3-beta.1+build5` ) ).
  endmethod.

  method comparisons.
    cl_abap_unit_assert=>assert_equals( exp = -1 act = zcl_au_semver=>compare( iv_a = `1.2.0` iv_b = `1.10.0` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1  act = zcl_au_semver=>compare( iv_a = `2.0.0` iv_b = `1.9.9` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 0  act = zcl_au_semver=>compare( iv_a = `1.4.2` iv_b = `1.4.2` ) ).
  endmethod.

  method at_least_check.
    cl_abap_unit_assert=>assert_true(  zcl_au_semver=>at_least( iv_version = `1.4.0` iv_minimum = `1.2.0` ) ).
    cl_abap_unit_assert=>assert_false( zcl_au_semver=>at_least( iv_version = `1.1.0` iv_minimum = `1.2.0` ) ).
  endmethod.

  method invalid_raises.
    try.
        zcl_au_semver=>parse( `1.x.0` ).
        cl_abap_unit_assert=>fail( 'expected ZCX_AU_ERROR' ).
      catch zcx_au_error.
    endtry.
  endmethod.
endclass.
