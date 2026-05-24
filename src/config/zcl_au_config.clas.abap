class zcl_au_config definition
  public
  final
  create public.

  public section.
    types:
      begin of ty_range,
        sign   type c length 1,
        option type c length 2,
        low    type string,
        high   type string,
      end of ty_range,
      tt_range type standard table of ty_range with default key.

    "! Single parameter value from TVARVC (maintained in transaction STVARV,
    "! type "Parameter"). Returns empty if the name is unknown.
    class-methods get_value
      importing
        !iv_name        type rvari_vnam
      returning
        value(rv_value) type string.

    "! Select-option style ranges from TVARVC (type "Selection option"),
    "! ready to drop into an ABAP SQL WHERE ... IN @rt_range.
    class-methods get_range
      importing
        !iv_name        type rvari_vnam
      returning
        value(rt_range) type tt_range.

    "! Feature toggle: true if the parameter value is X / TRUE / 1 / YES / ON.
    class-methods is_enabled
      importing
        !iv_name          type rvari_vnam
      returning
        value(rv_enabled) type abap_bool.
endclass.


class zcl_au_config implementation.
  method get_value.
    select single low from tvarvc
      where name = @iv_name and type = 'P'
      into @rv_value.
  endmethod.


  method get_range.
    " Read the raw TVARVC rows, then map TVARVC-OPTI to the range component
    " OPTION (avoids relying on a SQL column alias named "option").
    select sign, opti, low, high from tvarvc
      where name = @iv_name and type = 'S'
      order by numb
      into table @data(lt_raw).

    rt_range = corresponding #( lt_raw mapping option = opti ).
  endmethod.


  method is_enabled.
    data(lv_value) = to_upper( get_value( iv_name ) ).
    rv_enabled = xsdbool(    lv_value = 'X'
                          or lv_value = 'TRUE'
                          or lv_value = '1'
                          or lv_value = 'YES'
                          or lv_value = 'ON' ).
  endmethod.
endclass.
