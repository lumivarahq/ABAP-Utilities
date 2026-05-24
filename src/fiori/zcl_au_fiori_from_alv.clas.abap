class zcl_au_fiori_from_alv definition
  public
  final
  create public.

  public section.
    "! Bridge for an ALV -> Fiori migration: turn a classic ALV field catalog
    "! (LVC) into Fiori field definitions, then feed them to
    "! ZCL_AU_FIORI_GEN=>generate( ). Hidden/technical columns are skipped, the
    "! ALV key flag becomes the CDS key, and the column text becomes the label.
    "!
    "!   data(lt_fields) = zcl_au_fiori_from_alv=>fields( lt_fcat ).
    "!   data(ls_app)    = zcl_au_fiori_gen=>generate(
    "!     iv_entity = `Order` iv_data_source = `ztorder` it_fields = lt_fields ).
    "!
    "! On-premise: references the LVC field-catalog type.
    class-methods fields
      importing
        !it_fcat         type lvc_t_fcat
      returning
        value(rt_fields) type zcl_au_fiori_gen=>tt_field.
endclass.


class zcl_au_fiori_from_alv implementation.
  method fields.
    data(lv_position) = 10.
    loop at it_fcat into data(ls_fcat).
      " drop columns that are not shown in the ALV
      if ls_fcat-no_out = abap_true or ls_fcat-tech = abap_true.
        continue.
      endif.
      append value #(
        name     = to_lower( ls_fcat-fieldname )
        label    = cond #( when ls_fcat-scrtext_l is not initial then ls_fcat-scrtext_l
                           when ls_fcat-reptext   is not initial then ls_fcat-reptext
                           else ls_fcat-fieldname )
        is_key   = ls_fcat-key
        position = lv_position ) to rt_fields.
      lv_position = lv_position + 10.
    endloop.
  endmethod.
endclass.
