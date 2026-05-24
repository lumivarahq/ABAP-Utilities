class ltcl_analytics_gen definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods odata        for testing.
    methods cube         for testing.
    methods extraction   for testing.
    methods empty_raises for testing.

    methods sample returning value(rt) type zcl_au_analytics_gen=>tt_field.
endclass.


class ltcl_analytics_gen implementation.
  method odata.
    data(ls) = zcl_au_analytics_gen=>odata_export( iv_entity      = `Sales`
                                                   iv_data_source = `ztsales`
                                                   it_fields      = sample( ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-cds_view cs `define root view entity ZC_Sales` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-service_definition cs `expose ZC_Sales as Sales` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-connect_steps cs `OData feed` ) ).
  endmethod.

  method cube.
    data(lv) = zcl_au_analytics_gen=>analytics_cube( iv_entity      = `Sales`
                                                     iv_data_source = `ztsales`
                                                     it_fields      = sample( ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv cs `@Analytics.dataCategory: #CUBE` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv cs `@DefaultAggregation: #SUM` ) ).
  endmethod.

  method extraction.
    data(lv) = zcl_au_analytics_gen=>extraction_view( iv_entity      = `Sales`
                                                      iv_data_source = `ztsales`
                                                      it_fields      = sample( ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv cs `@Analytics.dataExtraction.enabled: true` ) ).
  endmethod.

  method empty_raises.
    data lt type zcl_au_analytics_gen=>tt_field.
    try.
        zcl_au_analytics_gen=>odata_export( iv_entity = `X` iv_data_source = `zt` it_fields = lt ).
        cl_abap_unit_assert=>fail( 'expected ZCX_AU_ERROR' ).
      catch zcx_au_error.
    endtry.
  endmethod.

  method sample.
    rt = value #( ( name = `region`  is_key = abap_true )
                  ( name = `product` is_key = abap_true )
                  ( name = `revenue` is_measure = abap_true ) ).
  endmethod.
endclass.
