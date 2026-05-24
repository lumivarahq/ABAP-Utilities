class ltcl_fiori_gen definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods generates_all_artifacts for testing.
    methods no_fields_raises        for testing.
    methods read_only_has_no_bdef   for testing.
    methods value_help_view         for testing.
    methods metadata_extension_ddlx for testing.

    methods sample_fields returning value(rt) type zcl_au_fiori_gen=>tt_field.
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

  method read_only_has_no_bdef.
    data(ls) = zcl_au_fiori_gen=>generate( iv_entity        = `Product`
                                           iv_data_source   = `ztproduct`
                                           it_fields        = sample_fields( )
                                           iv_with_behavior = abap_false ).
    " a read-only list still has views + service, but no behavior
    cl_abap_unit_assert=>assert_not_initial( act = ls-projection_view ).
    cl_abap_unit_assert=>assert_initial( act = ls-behavior ).
    cl_abap_unit_assert=>assert_initial( act = ls-projection_behavior ).
  endmethod.

  method value_help_view.
    data(ls) = zcl_au_fiori_gen=>value_help( iv_entity      = `Currency`
                                             iv_data_source = `ztcurrency`
                                             iv_key_field   = `code`
                                             iv_text_field  = `name` ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-view cs `define view entity ZI_VH_Currency` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-view cs `key code` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-annotation cs `valueHelpDefinition` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( ls-annotation cs `ZI_VH_Currency` ) ).
  endmethod.

  method metadata_extension_ddlx.
    data(lv) = zcl_au_fiori_gen=>metadata_extension( iv_entity = `Product`
                                                     it_fields = sample_fields( ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv cs `annotate entity ZC_Product with` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv cs `@UI.lineItem` ) ).
  endmethod.

  method sample_fields.
    rt = value #( ( name = `id`   label = `ID`   is_key = abap_true  position = 10 )
                  ( name = `name` label = `Name` is_key = abap_false position = 20 ) ).
  endmethod.
endclass.
