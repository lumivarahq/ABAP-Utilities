class zcl_au_diff definition
  public
  final
  create public.

  public section.
    "! One line of a diff. kind: ' ' = unchanged, '-' = only in A, '+' = only in B.
    types:
      begin of ty_line,
        kind type c length 1,
        text type string,
      end of ty_line,
      tt_line type standard table of ty_line with default key.

    "! Line diff of two string tables, using a Longest-Common-Subsequence so that
    "! unchanged lines line up even when lines are inserted/removed.
    class-methods tables
      importing
        !it_a          type string_table
        !it_b          type string_table
      returning
        value(rt_diff) type tt_line.

    "! Line diff of two strings (split at newline).
    class-methods texts
      importing
        !iv_a          type string
        !iv_b          type string
      returning
        value(rt_diff) type tt_line.

    "! Render a diff as text: each line prefixed with its kind (' '/'-'/'+').
    class-methods to_text
      importing
        !it_diff       type tt_line
      returning
        value(rv_text) type string.

    "! True if the two tables are identical line-for-line.
    class-methods are_equal
      importing
        !it_a           type string_table
        !it_b           type string_table
      returning
        value(rv_equal) type abap_bool.
endclass.


class zcl_au_diff implementation.
  method tables.
    data(lv_n)    = lines( it_a ).
    data(lv_m)    = lines( it_b ).
    data(lv_cols) = lv_m + 1.

    " DP matrix of LCS lengths, flattened: cell (i,j) at index i*cols + j + 1
    " (i in 0..n, j in 0..m), all initialised to 0.
    data lt_dp type standard table of i.
    do ( lv_n + 1 ) * lv_cols times.
      append 0 to lt_dp.
    enddo.

    data(lv_i) = lv_n - 1.
    while lv_i >= 0.
      data(lv_j) = lv_m - 1.
      while lv_j >= 0.
        assign lt_dp[ lv_i * lv_cols + lv_j + 1 ] to field-symbol(<cell>).
        if it_a[ lv_i + 1 ] = it_b[ lv_j + 1 ].
          <cell> = lt_dp[ ( lv_i + 1 ) * lv_cols + lv_j + 1 ] + 1.
        else.
          <cell> = nmax( val1 = lt_dp[ ( lv_i + 1 ) * lv_cols + lv_j + 1 ]
                         val2 = lt_dp[ lv_i * lv_cols + ( lv_j + 1 ) + 1 ] ).
        endif.
        lv_j = lv_j - 1.
      endwhile.
      lv_i = lv_i - 1.
    endwhile.

    " backtrack from (0,0) to build the diff
    lv_i = 0.
    lv_j = 0.
    while lv_i < lv_n and lv_j < lv_m.
      if it_a[ lv_i + 1 ] = it_b[ lv_j + 1 ].
        append value #( kind = ` ` text = it_a[ lv_i + 1 ] ) to rt_diff.
        lv_i = lv_i + 1.
        lv_j = lv_j + 1.
      elseif lt_dp[ ( lv_i + 1 ) * lv_cols + lv_j + 1 ] >= lt_dp[ lv_i * lv_cols + ( lv_j + 1 ) + 1 ].
        append value #( kind = `-` text = it_a[ lv_i + 1 ] ) to rt_diff.
        lv_i = lv_i + 1.
      else.
        append value #( kind = `+` text = it_b[ lv_j + 1 ] ) to rt_diff.
        lv_j = lv_j + 1.
      endif.
    endwhile.

    while lv_i < lv_n.
      append value #( kind = `-` text = it_a[ lv_i + 1 ] ) to rt_diff.
      lv_i = lv_i + 1.
    endwhile.
    while lv_j < lv_m.
      append value #( kind = `+` text = it_b[ lv_j + 1 ] ) to rt_diff.
      lv_j = lv_j + 1.
    endwhile.
  endmethod.


  method texts.
    split iv_a at cl_abap_char_utilities=>newline into table data(lt_a).
    split iv_b at cl_abap_char_utilities=>newline into table data(lt_b).
    rt_diff = tables( it_a = lt_a it_b = lt_b ).
  endmethod.


  method to_text.
    data lt_lines type string_table.
    loop at it_diff into data(ls_line).
      append |{ ls_line-kind }{ ls_line-text }| to lt_lines.
    endloop.
    rv_text = concat_lines_of( table = lt_lines
                               sep   = cl_abap_char_utilities=>newline ).
  endmethod.


  method are_equal.
    rv_equal = xsdbool( it_a = it_b ).
  endmethod.
endclass.
