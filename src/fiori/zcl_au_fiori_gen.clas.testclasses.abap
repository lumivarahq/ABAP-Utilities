class ltcl_fiori_gen definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods generates_all_artifacts for testing.
    methods no_fields_raises        for testing.
endclass.


class ltcl_fiori_gen implementation.
  method generates_all_artifacts.
    data(lt_fields) = value zcl_au_fiori_gen=>tt_field(
      ( name = `id`   label = `ID`   is_key = abap_true  position = 10 )
      ( name = `name` label = `Name` is_key = abap_false position = 20 ) ).

    data(ls) = zcl_au_fiori_gen=>generate( iv_entity      = `Product`
                                           iv_data_source = `ztproduct`
                                           it_fields      = lt_fields ).

    " interface view
    cl_abap_unit_assert=>assert_true( xsdbool( ls-interface_view cs `define root view entity ZI_Product` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-interface_view cs `select from ztproduct` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-interface_view cs `key id` ) ).
    " projection view
    cl_abap_unit_assert=>assert_true( xsdbool( ls-projection_view cs `define root view entity ZC_Product` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-projection_view cs `as projection on ZI_Product` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-projection_view cs `lineItem` ) ).
    " behavior
    cl_abap_unit_assert=>assert_true( xsdbool( ls-behavior cs `persistent table ztproduct` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-behavior cs `create;` ) ).
    " service
    cl_abap_unit_assert=>assert_true( xsdbool( ls-service_definition cs `expose ZC_Product as Product` ) ).
  endmethod.

  method no_fields_raises.
    data lt_empty type zcl_au_fiori_gen=>tt_field.
    try.
        zcl_au_fiori_gen=>generate( iv_entity      = `X`
                                    iv_data_source = `zt`
                                    it_fields      = lt_empty ).
        cl_abap_unit_assert=>fail( 'expected ZCX_AU_ERROR for empty field list' ).
      catch zcx_au_error.
    endtry.
  endmethod.
endclass.
