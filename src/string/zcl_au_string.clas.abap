class zcl_au_string definition
  public
  final
  create public.

  public section.
    "! Split a string into a table of lines at a separator.
    class-methods split_to_table
      importing
        !iv_string         type string
        !iv_separator      type string default ','
      returning
        value(rt_table)    type string_table.

    "! Join a table of strings into a single string with a separator.
    class-methods join
      importing
        !it_table          type string_table
        !iv_separator      type string default ','
      returning
        value(rv_string)   type string.

    "! Mask a string, leaving only the last iv_visible characters readable.
    "! Useful for logging sensitive data (IBAN, card numbers, ...).
    class-methods mask
      importing
        !iv_string         type string
        !iv_visible        type i default 4
        !iv_mask_char      type c default '*'
      returning
        value(rv_masked)   type string.

    "! Replace every occurrence of iv_what with iv_with.
    class-methods replace_all
      importing
        !iv_string         type string
        !iv_what           type string
        !iv_with           type string
      returning
        value(rv_result)   type string.

    "! True if the string contains digits only (no sign, no decimals).
    class-methods is_numeric
      importing
        !iv_string         type string
      returning
        value(rv_result)   type abap_bool.

    "! "OrderItem" / "order item" / "order-item" -> "order_item".
    class-methods to_snake_case
      importing
        !iv_string         type string
      returning
        value(rv_result)   type string.

    "! "order_item" / "order item" -> "orderItem".
    class-methods to_camel_case
      importing
        !iv_string         type string
      returning
        value(rv_result)   type string.

    "! "order_item" / "order item" -> "OrderItem".
    class-methods to_pascal_case
      importing
        !iv_string         type string
      returning
        value(rv_result)   type string.

    "! Pad on the left up to iv_length using a single pad character.
    class-methods lpad
      importing
        !iv_string         type string
        !iv_length         type i
        !iv_pad            type c default ' '
      returning
        value(rv_result)   type string.

    "! Pad on the right up to iv_length using a single pad character.
    class-methods rpad
      importing
        !iv_string         type string
        !iv_length         type i
        !iv_pad            type c default ' '
      returning
        value(rv_result)   type string.

    "! ALPHA conversion - add leading zeros ("42" -> "0000000042").
    class-methods alpha_in
      importing
        !iv_value          type clike
      returning
        value(rv_result)   type string.

    "! ALPHA conversion - remove leading zeros ("0000000042" -> "42").
    class-methods alpha_out
      importing
        !iv_value          type clike
      returning
        value(rv_result)   type string.

    "! Truncate a string and append an ellipsis when it is too long.
    class-methods truncate
      importing
        !iv_string         type string
        !iv_length         type i
        !iv_ellipsis       type string default `...`
      returning
        value(rv_result)   type string.

  private section.
    class-methods capitalize_word
      importing
        !iv_word         type string
      returning
        value(rv_result) type string.

    class-methods split_words
      importing
        !iv_string       type string
      returning
        value(rt_words)  type string_table.
endclass.


class zcl_au_string implementation.
  method split_to_table.
    split iv_string at iv_separator into table rt_table.
  endmethod.


  method join.
    rv_string = concat_lines_of( table = it_table
                                 sep   = iv_separator ).
  endmethod.


  method mask.
    data(lv_len) = strlen( iv_string ).
    if lv_len <= iv_visible or iv_visible < 0.
      rv_masked = iv_string.
      return.
    endif.
    data(lv_hidden) = lv_len - iv_visible.
    rv_masked = repeat( val = iv_mask_char
                        occ = lv_hidden )
             && substring( val = iv_string
                           off = lv_hidden
                           len = iv_visible ).
  endmethod.


  method replace_all.
    rv_result = replace( val  = iv_string
                         sub  = iv_what
                         with = iv_with
                         occ  = 0 ).
  endmethod.


  method is_numeric.
    rv_result = xsdbool( iv_string is not initial
                         and matches( val   = iv_string
                                      regex = `\d+` ) ).
  endmethod.


  method split_words.
    " normalise the usual separators to a single space, then split
    data(lv_norm) = replace( val = iv_string regex = `[_\-]` with = ` ` occ = 0 ).
    " insert a space between a lower/digit and an upper-case letter
    lv_norm = replace( val   = lv_norm
                       regex = `([a-z0-9])([A-Z])`
                       with  = `$1 $2`
                       occ   = 0 ).
    split condense( lv_norm ) at ` ` into table rt_words.
    delete rt_words where table_line is initial.
  endmethod.


  method capitalize_word.
    if iv_word is initial.
      return.
    endif.
    rv_result = to_upper( substring( val = iv_word off = 0 len = 1 ) )
             && to_lower( substring( val = iv_word off = 1 ) ).
  endmethod.


  method to_snake_case.
    rv_result = to_lower( concat_lines_of( table = split_words( iv_string )
                                           sep   = `_` ) ).
  endmethod.


  method to_pascal_case.
    loop at split_words( iv_string ) into data(lv_word).
      rv_result = rv_result && capitalize_word( lv_word ).
    endloop.
  endmethod.


  method to_camel_case.
    data(lt_words) = split_words( iv_string ).
    loop at lt_words into data(lv_word).
      if sy-tabix = 1.
        rv_result = to_lower( lv_word ).
      else.
        rv_result = rv_result && capitalize_word( lv_word ).
      endif.
    endloop.
  endmethod.


  method lpad.
    rv_result = iv_string.
    data(lv_len) = strlen( iv_string ).
    if lv_len < iv_length.
      rv_result = repeat( val = iv_pad
                          occ = iv_length - lv_len )
               && iv_string.
    endif.
  endmethod.


  method rpad.
    rv_result = iv_string.
    data(lv_len) = strlen( iv_string ).
    if lv_len < iv_length.
      rv_result = iv_string
               && repeat( val = iv_pad
                          occ = iv_length - lv_len ).
    endif.
  endmethod.


  method alpha_in.
    rv_result = |{ iv_value alpha = in }|.
  endmethod.


  method alpha_out.
    rv_result = |{ iv_value alpha = out }|.
  endmethod.


  method truncate.
    if strlen( iv_string ) <= iv_length.
      rv_result = iv_string.
      return.
    endif.
    data(lv_keep) = iv_length - strlen( iv_ellipsis ).
    if lv_keep < 0.
      lv_keep = 0.
    endif.
    rv_result = substring( val = iv_string
                           off = 0
                           len = lv_keep )
             && iv_ellipsis.
  endmethod.
endclass.
