class ltcl_feature_flag definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods enabled_and_disabled for testing.
    methods case_insensitive      for testing.
endclass.


class ltcl_feature_flag implementation.
  method enabled_and_disabled.
    data(lo_flags) = zcl_au_feature_flag=>from_enabled( value #( ( `NEW_PRICING` ) ( `BETA_UI` ) ) ).
    cl_abap_unit_assert=>assert_true(  lo_flags->is_enabled( `NEW_PRICING` ) ).
    cl_abap_unit_assert=>assert_false( lo_flags->is_enabled( `NOT_THERE` ) ).
  endmethod.

  method case_insensitive.
    data(lo_flags) = zcl_au_feature_flag=>from_enabled( value #( ( `New_Pricing` ) ) ).
    cl_abap_unit_assert=>assert_true( lo_flags->is_enabled( `new_pricing` ) ).
  endmethod.
endclass.
