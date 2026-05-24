class zcl_au_csv definition
  public
  final
  create public.

  public section.
    "! Serialize any internal table into CSV text (RFC-4180 style quoting).
    "! @parameter it_table     | source internal table (structured line type)
    "! @parameter iv_separator | field separator, default comma
    "! @parameter iv_header    | write a header row with the component names
    class-methods from_table
      importing
        !it_table        type any table
        !iv_separator    type c default ','
        !iv_header       type abap_bool default abap_true
      returning
        value(rv_csv)    type string.

    "! Parse CSV text into an internal table.
    "! With a header row, columns are matched to components by name
    "! (case-insensitive); otherwise they are mapped by position.
    "! Field values must already be in internal format (e.g. dates as YYYYMMDD).
    class-methods to_table
      importing
        !iv_csv          type string
        !iv_separator    type c default ','
        !iv_header       type abap_bool default abap_true
      changing
        !ct_table        type standard table.

  private section.
    types tt_record type standard table of string_table with default key.

    class-methods escape
      importing
        !iv_field        type string
        !iv_separator    type c
      returning
        value(rv_result) type string.

    class-methods parse
      importing
        !iv_csv           type string
        !iv_separator     type c
      returning
        value(rt_records) type tt_record.
endclass.


class zcl_au_csv implementation.
  method from_table.
    data(lo_table)  = cast cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( it_table ) ).
    data(lo_struct) = cast cl_abap_structdescr( lo_table->get_table_line_type( ) ).
    data(lt_comp)   = lo_struct->get_components( ).

    data lt_lines type string_table.

    if iv_header = abap_true.
      data lt_head type string_table.
      loop at lt_comp into data(ls_comp).
        append escape( iv_field     = to_lower( ls_comp-name )
                       iv_separator  = iv_separator ) to lt_head.
      endloop.
      append concat_lines_of( table = lt_head
                              sep   = iv_separator ) to lt_lines.
    endif.

    field-symbols <row>   type any.
    field-symbols <field> type any.
    loop at it_table assigning <row>.
      data lt_fields type string_table.
      clear lt_fields.
      loop at lt_comp into ls_comp.
        assign component ls_comp-name of structure <row> to <field>.
        append escape( iv_field     = |{ <field> }|
                       iv_separator  = iv_separator ) to lt_fields.
      endloop.
      append concat_lines_of( table = lt_fields
                              sep   = iv_separator ) to lt_lines.
    endloop.

    rv_csv = concat_lines_of( table = lt_lines
                              sep   = cl_abap_char_utilities=>cr_lf ).
  endmethod.


  method escape.
    rv_result = iv_field.
    if iv_field cs iv_separator
        or iv_field cs '"'
        or iv_field cs cl_abap_char_utilities=>cr_lf
        or iv_field cs cl_abap_char_utilities=>newline.
      rv_result = |"{ replace( val = iv_field sub = '"' with = '""' occ = 0 ) }"|.
    endif.
  endmethod.


  method parse.
    data lv_field    type string.
    data lt_fields   type string_table.
    data(lv_quoted)  = abap_false.
    data(lv_len)     = strlen( iv_csv ).
    data(lv_i)       = 0.
    data(lv_started) = abap_false.
    data(lv_cr)      = cl_abap_char_utilities=>cr_lf(1).
    data(lv_lf)      = cl_abap_char_utilities=>newline.

    while lv_i < lv_len.
      data(lv_ch) = substring( val = iv_csv off = lv_i len = 1 ).
      lv_started = abap_true.

      if lv_quoted = abap_true.
        if lv_ch = '"'.
          if lv_i + 1 < lv_len and substring( val = iv_csv off = lv_i + 1 len = 1 ) = '"'.
            lv_field = lv_field && '"'.
            lv_i = lv_i + 1.
          else.
            lv_quoted = abap_false.
          endif.
        else.
          lv_field = lv_field && lv_ch.
        endif.

      else.
        case lv_ch.
          when '"'.
            lv_quoted = abap_true.
          when iv_separator.
            append lv_field to lt_fields.
            clear lv_field.
          when lv_cr.
            " ignore - the record is terminated on the following LF
          when lv_lf.
            append lv_field to lt_fields.
            append lt_fields to rt_records.
            clear: lv_field, lt_fields, lv_started.
          when others.
            lv_field = lv_field && lv_ch.
        endcase.
      endif.

      lv_i = lv_i + 1.
    endwhile.

    " flush the trailing record (file may not end with a newline)
    if lv_started = abap_true or lv_field is not initial or lt_fields is not initial.
      append lv_field to lt_fields.
      append lt_fields to rt_records.
    endif.
  endmethod.


  method to_table.
    clear ct_table.

    data(lt_records) = parse( iv_csv        = iv_csv
                              iv_separator  = iv_separator ).
    if lt_records is initial.
      return.
    endif.

    data lr_line type ref to data.
    create data lr_line like line of ct_table.
    field-symbols <line> type any.
    assign lr_line->* to <line>.

    data(lo_struct) = cast cl_abap_structdescr( cl_abap_typedescr=>describe_by_data( <line> ) ).
    data(lt_comp)   = lo_struct->get_components( ).

    " column index -> target component name
    data lt_mapping type standard table of abap_compname with default key.
    data(lv_first)  = 1.

    if iv_header = abap_true.
      read table lt_records index 1 into data(lt_header).
      loop at lt_header into data(lv_head).
        data(lv_target) = value abap_compname( ).
        loop at lt_comp into data(ls_comp).
          if to_upper( ls_comp-name ) = to_upper( condense( lv_head ) ).
            lv_target = ls_comp-name.
            exit.
          endif.
        endloop.
        append lv_target to lt_mapping.
      endloop.
      lv_first = 2.
    else.
      loop at lt_comp into ls_comp.
        append ls_comp-name to lt_mapping.
      endloop.
    endif.

    field-symbols <field> type any.
    loop at lt_records into data(lt_row) from lv_first.
      clear <line>.
      loop at lt_row into data(lv_value).
        data(lv_col) = sy-tabix.
        read table lt_mapping index lv_col into data(lv_name).
        if sy-subrc <> 0 or lv_name is initial.
          continue.
        endif.
        assign component lv_name of structure <line> to <field>.
        if sy-subrc = 0.
          <field> = lv_value.
        endif.
      endloop.
      insert <line> into table ct_table.
    endloop.
  endmethod.
endclass.
