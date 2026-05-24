class zcl_au_batch definition
  public
  final
  create public.

  public section.
    "! A 1-based [from, to] slice of a larger set.
    types:
      begin of ty_bounds,
        index type i,
        from  type i,
        to    type i,
      end of ty_bounds,
      tt_bounds type standard table of ty_bounds with default key,
      tt_chunks type standard table of string_table with default key.

    "! Compute the 1-based [from, to] ranges needed to process iv_total items in
    "! packages of iv_size (last package may be smaller). Use it to chunk
    "! FOR ALL ENTRIES drivers, commit every N, or page through a result set.
    class-methods bounds
      importing
        !iv_total       type i
        !iv_size        type i
      returning
        value(rt_bounds) type tt_bounds
      raising
        zcx_au_error.

    "! Split a string table into chunks of at most iv_size rows.
    class-methods chunks
      importing
        !it_table        type string_table
        !iv_size         type i
      returning
        value(rt_chunks) type tt_chunks
      raising
        zcx_au_error.
endclass.


class zcl_au_batch implementation.
  method bounds.
    if iv_size <= 0.
      zcx_au_error=>raise( |Package size must be > 0 (got { iv_size })| ) ##NO_TEXT.
    endif.

    data(lv_from) = 1.
    data(lv_index) = 0.
    while lv_from <= iv_total.
      lv_index = lv_index + 1.
      append value #( index = lv_index
                      from  = lv_from
                      to    = nmin( val1 = lv_from + iv_size - 1
                                    val2 = iv_total ) ) to rt_bounds.
      lv_from = lv_from + iv_size.
    endwhile.
  endmethod.


  method chunks.
    if iv_size <= 0.
      zcx_au_error=>raise( |Chunk size must be > 0 (got { iv_size })| ) ##NO_TEXT.
    endif.

    data lt_current type string_table.
    loop at it_table into data(lv_line).
      append lv_line to lt_current.
      if lines( lt_current ) = iv_size.
        append lt_current to rt_chunks.
        clear lt_current.
      endif.
    endloop.
    if lt_current is not initial.
      append lt_current to rt_chunks.
    endif.
  endmethod.
endclass.
