class zcl_au_wrap_gen definition
  public
  final
  create public.

  public section.
    "! Generate a Clean Core "released wrapper" facade class around a non-released
    "! API (a classic function module or an internal class). The generated class
    "! is the single, ATC-exempted place that touches the non-released object;
    "! everyone else depends on this stable, released signature.
    "!
    "! Paste the result into a new global class and adapt the signature + the one
    "! call inside the method.
    "!
    "! @parameter iv_class_name  | name of the facade class, e.g. ZCL_PRICING_FACADE
    "! @parameter iv_method_name | the facade method, default `execute`
    "! @parameter iv_target      | the wrapped FM or class=>method (for the TODO)
    "! @parameter iv_description | optional ABAP Doc summary
    class-methods facade
      importing
        !iv_class_name   type string
        !iv_method_name  type string default `execute`
        !iv_target       type string
        !iv_description  type string optional
      returning
        value(rv_source) type string
      raising
        zcx_au_error.
endclass.


class zcl_au_wrap_gen implementation.
  method facade.
    if iv_class_name is initial or iv_target is initial.
      zcx_au_error=>raise( |Class name and wrapped target are required| ) ##NO_TEXT.
    endif.

    data(lv_lf) = cl_abap_char_utilities=>newline.
    data(lv_desc) = cond string( when iv_description is not initial
                                 then iv_description
                                 else |Released facade around { iv_target }| ).

    data lt_src type string_table.
    append |"! { lv_desc }| to lt_src.
    append |"! Clean Core wrapper: the only ATC-exempted call to the non-released| to lt_src.
    append |"! API lives here; callers depend solely on this released class.| to lt_src.
    append |class { iv_class_name } definition| to lt_src.
    append |  public| to lt_src.
    append |  final| to lt_src.
    append |  create public.| to lt_src.
    append || to lt_src.
    append |  public section.| to lt_src.
    append |    class-methods { iv_method_name }| to lt_src.
    append |      importing !iv_input        type string| to lt_src.
    append |      returning value(rv_output) type string| to lt_src.
    append |      raising   zcx_au_error.| to lt_src.
    append |endclass.| to lt_src.
    append || to lt_src.
    append || to lt_src.
    append |class { iv_class_name } implementation.| to lt_src.
    append |  method { iv_method_name }.| to lt_src.
    append |    " TODO adapt the signature to the real inputs/outputs.| to lt_src.
    append |    " The ONLY place allowed to touch the non-released API ({ iv_target }):| to lt_src.
    append |    "   call function '{ iv_target }' exporting ... importing ... .| to lt_src.
    append |    "   or:  rv_output = { iv_target }( ... ).| to lt_src.
    append |    " Map any failure to a single exception type for callers:| to lt_src.
    append |    "   if sy-subrc <> 0. zcx_au_error=>raise_from_sy( ). endif.| to lt_src.
    append |  endmethod.| to lt_src.
    append |endclass.| to lt_src.

    rv_source = concat_lines_of( table = lt_src
                                 sep   = lv_lf ).
  endmethod.
endclass.
