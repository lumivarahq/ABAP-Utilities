class zcl_au_guard definition
  public
  final
  create public.

  public section.
    "! Guard clauses for fail-fast precondition checks at the start of a method.
    "! They make a method's contract explicit and turn silent bad input into a
    "! clear ZCX_AU_ERROR (cf. Guava Preconditions / .NET ArgumentException).
    "!
    "!   method post_invoice.
    "!     zcl_au_guard=>not_initial( iv_value = is_invoice-customer iv_name = `customer` ).
    "!     zcl_au_guard=>that( iv_condition = xsdbool( is_invoice-amount > 0 )
    "!                         iv_message   = `amount must be positive` ).
    "!     ...

    "! Raise unless the (boolean) condition holds.
    class-methods that
      importing
        !iv_condition type abap_bool
        !iv_message   type string
      raising
        zcx_au_error.

    "! Raise if the value is initial (empty string, 0, blank, initial structure).
    class-methods not_initial
      importing
        !iv_value type any
        !iv_name  type string default `value`
      raising
        zcx_au_error.

    "! Raise if the internal table is empty.
    class-methods not_empty
      importing
        !it_table type any table
        !iv_name  type string default `table`
      raising
        zcx_au_error.
endclass.


class zcl_au_guard implementation.
  method that.
    if iv_condition = abap_false.
      zcx_au_error=>raise( iv_message ).
    endif.
  endmethod.


  method not_initial.
    " IS INITIAL works for any data type, so this guard is fully generic.
    if iv_value is initial.
      zcx_au_error=>raise( |{ iv_name } must not be initial| ) ##NO_TEXT.
    endif.
  endmethod.


  method not_empty.
    if it_table is initial.
      zcx_au_error=>raise( |{ iv_name } must not be empty| ) ##NO_TEXT.
    endif.
  endmethod.
endclass.
