class zcl_au_json definition
  public
  final
  create public.

  public section.
    "! Serialize any ABAP data into a JSON string.
    "! Thin convenience wrapper around /UI2/CL_JSON.
    "! For ABAP Cloud / clean-core projects prefer the "ajson" library
    "! (see the core module README).
    "! @parameter iv_compress  | drop initial (empty) fields from the output
    "! @parameter iv_camelcase | map ABAP_FIELD_NAMES to camelCase keys
    class-methods serialize
      importing
        !iv_data       type any
        !iv_compress   type abap_bool default abap_true
        !iv_camelcase  type abap_bool default abap_true
      returning
        value(rv_json) type string.

    "! Deserialize a JSON string into an ABAP data object.
    "! cs_data must be typed to match the expected JSON shape.
    class-methods deserialize
      importing
        !iv_json      type string
        !iv_camelcase type abap_bool default abap_true
      changing
        !cs_data      type any.
endclass.


class zcl_au_json implementation.
  method serialize.
    rv_json = /ui2/cl_json=>serialize(
      data        = iv_data
      compress    = iv_compress
      pretty_name = cond #( when iv_camelcase = abap_true
                            then /ui2/cl_json=>pretty_mode-camel_case
                            else /ui2/cl_json=>pretty_mode-none ) ).
  endmethod.


  method deserialize.
    /ui2/cl_json=>deserialize(
      exporting
        json        = iv_json
        pretty_name = cond #( when iv_camelcase = abap_true
                              then /ui2/cl_json=>pretty_mode-camel_case
                              else /ui2/cl_json=>pretty_mode-none )
      changing
        data        = cs_data ).
  endmethod.
endclass.
