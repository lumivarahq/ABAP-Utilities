class ltcl_wrap_gen definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods generates_facade for testing.
    methods missing_args     for testing.
endclass.


class ltcl_wrap_gen implementation.
  method generates_facade.
    data(lv) = zcl_au_wrap_gen=>facade( iv_class_name  = `ZCL_PRICING_FACADE`
                                        iv_method_name = `get_price`
                                        iv_target      = `PRICING_FM` ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv cs `class ZCL_PRICING_FACADE definition` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv cs `method get_price.` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv cs `PRICING_FM` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv cs `raising   zcx_au_error.` ) ).
  endmethod.

  method missing_args.
    try.
        zcl_au_wrap_gen=>facade( iv_class_name = `` iv_target = `X` ).
        cl_abap_unit_assert=>fail( 'expected ZCX_AU_ERROR' ).
      catch zcx_au_error.
    endtry.
  endmethod.
endclass.
