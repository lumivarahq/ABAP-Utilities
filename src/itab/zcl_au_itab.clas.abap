class zcl_au_itab definition
  public
  final
  create public.

  public section.
    "! Remove duplicate rows in place: sorts the table, then deletes adjacent
    "! duplicates comparing all fields. Generic for any standard table.
    "! (Most ATC "nested loop / linear search" findings are better fixed with
    "!  table expressions or sorted/hashed tables - see docs/internal-tables-cookbook.md.)
    class-methods distinct
      changing
        !ct_table type standard table.

    "! Number of distinct rows, without modifying the input table.
    class-methods count_distinct
      importing
        !it_table       type standard table
      returning
        value(rv_count) type i.

    "! True if the table has at least one row (reads better than IS NOT INITIAL
    "! in fluent expressions).
    class-methods has_rows
      importing
        !it_table        type any table
      returning
        value(rv_result) type abap_bool.
endclass.


class zcl_au_itab implementation.
  method distinct.
    sort ct_table.
    delete adjacent duplicates from ct_table comparing all fields.
  endmethod.


  method count_distinct.
    " Clone the table TYPE at runtime: CREATE DATA ... LIKE resolves the generic
    " parameter's *dynamic* type (a static "DATA x LIKE it_table" would not
    " compile, because the formal parameter's type is generic). We copy the rows
    " into the clone so the caller's table is never modified.
    data lr_copy type ref to data.
    field-symbols <copy> type standard table.

    create data lr_copy like it_table.
    assign lr_copy->* to <copy>.
    <copy> = it_table.

    sort <copy>.
    delete adjacent duplicates from <copy> comparing all fields.
    rv_count = lines( <copy> ).
  endmethod.


  method has_rows.
    rv_result = xsdbool( it_table is not initial ).
  endmethod.
endclass.
