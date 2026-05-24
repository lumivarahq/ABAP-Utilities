class zcl_au_validate definition
  public
  final
  create public.

  public section.
    "! Pragmatic syntactic e-mail check (not RFC-exhaustive, but catches typos).
    class-methods is_email
      importing
        !iv_value        type string
      returning
        value(rv_result) type abap_bool.

    "! Luhn checksum (credit-card numbers, some national IDs). Spaces are ignored.
    class-methods luhn_ok
      importing
        !iv_digits       type string
      returning
        value(rv_result) type abap_bool.

    "! IBAN validation: length + the ISO-7064 mod-97 check. Spaces ignored,
    "! case-insensitive.
    class-methods is_iban
      importing
        !iv_value        type string
      returning
        value(rv_result) type abap_bool.

  private section.
    constants c_alnum type string
      value `0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ` ##NO_TEXT.
endclass.


class zcl_au_validate implementation.
  method is_email.
    rv_result = xsdbool( matches(
      val   = iv_value
      regex = `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}` ) ).
  endmethod.


  method luhn_ok.
    data(lv_digits) = replace( val = iv_digits sub = ` ` with = `` occ = 0 ).
    if lv_digits is initial or not matches( val = lv_digits regex = `\d+` ).
      return.
    endif.

    data lv_sum    type i.
    data(lv_double) = abap_false.
    data(lv_len)    = strlen( lv_digits ).
    do lv_len times.
      " walk from the rightmost digit leftwards
      data(lv_pos) = lv_len - sy-index.
      data(lv_n)   = conv i( lv_digits+lv_pos(1) ).
      if lv_double = abap_true.
        lv_n = lv_n * 2.
        if lv_n > 9.
          lv_n = lv_n - 9.
        endif.
      endif.
      lv_sum   = lv_sum + lv_n.
      lv_double = xsdbool( lv_double = abap_false ).   " double every 2nd digit
    enddo.

    rv_result = xsdbool( lv_sum mod 10 = 0 ).
  endmethod.


  method is_iban.
    data(lv_iban) = to_upper( replace( val = iv_value sub = ` ` with = `` occ = 0 ) ).
    data(lv_len)  = strlen( lv_iban ).
    if lv_len < 15 or lv_len > 34.
      return.
    endif.

    " move the first 4 characters (country + check digits) to the end
    data(lv_rearranged) = lv_iban+4 && lv_iban(4).

    " replace each character by its value (0-9 stay, A=10 ... Z=35) -> digit string
    data lv_numeric type string.
    do strlen( lv_rearranged ) times.
      data(lv_off) = sy-index - 1.
      data(lv_value) = find( val = c_alnum
                             sub = lv_rearranged+lv_off(1) ).
      if lv_value < 0.
        return.                                    " invalid character
      endif.
      lv_numeric = lv_numeric && |{ lv_value }|.
    enddo.

    " mod-97 over the (very long) digit string, computed piecewise
    data lv_mod type i.
    do strlen( lv_numeric ) times.
      data(lv_pos) = sy-index - 1.
      lv_mod = ( lv_mod * 10 + conv i( lv_numeric+lv_pos(1) ) ) mod 97.
    enddo.

    rv_result = xsdbool( lv_mod = 1 ).
  endmethod.
endclass.
