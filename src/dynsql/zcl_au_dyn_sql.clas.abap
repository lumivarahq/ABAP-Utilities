class zcl_au_dyn_sql definition
  public
  final
  create public.

  public section.
    "! Helpers that make dynamic ABAP SQL safe against injection. The golden rule
    "! is still: use host variables (@value, @itab) for *values*. Use these only
    "! when the column/table NAME or a literal value is genuinely dynamic.

    "! Quote a literal value for a dynamic WHERE (encloses in single quotes and
    "! doubles embedded quotes). Wraps CL_ABAP_DYN_PRG=>QUOTE.
    "!   |{ col } = { zcl_au_dyn_sql=>quote( iv_user_input ) }|
    class-methods quote
      importing
        !iv_value        type simple
      returning
        value(rv_quoted) type string.

    "! Validate a dynamic column name (rejects anything that is not a valid
    "! identifier, e.g. "MATNR; DROP ..."). Raises if invalid.
    class-methods column
      importing
        !iv_name       type clike
      returning
        value(rv_name) type string
      raising
        zcx_au_error.

    "! Enforce an allow-list for any dynamic token (column, sort order, table).
    "! Returns the value if it is in it_allowed, otherwise raises.
    class-methods allowed
      importing
        !iv_value       type csequence
        !it_allowed     type string_table
      returning
        value(rv_value) type string
      raising
        zcx_au_error.
endclass.


class zcl_au_dyn_sql implementation.
  method quote.
    rv_quoted = cl_abap_dyn_prg=>quote( iv_value ).
  endmethod.


  method column.
    try.
        rv_name = cl_abap_dyn_prg=>check_column_name( iv_name ).
      catch cx_root into data(lx_error).
        zcx_au_error=>raise( text     = |Invalid column name '{ iv_name }'|
                             previous = lx_error ) ##NO_TEXT.
    endtry.
  endmethod.


  method allowed.
    if not line_exists( it_allowed[ table_line = iv_value ] ).
      zcx_au_error=>raise( |Value '{ iv_value }' is not in the allow-list| ) ##NO_TEXT.
    endif.
    rv_value = iv_value.
  endmethod.
endclass.
