class zcl_au_clock definition
  public
  final
  create private.

  public section.
    interfaces zif_au_clock.

    "! The real, system clock - returns the actual current time.
    class-methods system
      returning
        value(ro_clock) type ref to zif_au_clock.

    "! A frozen clock for tests - always returns the given moment, so behaviour
    "! that depends on "now" becomes deterministic.
    "!   data(lo_clock) = zcl_au_clock=>fixed( CONV timestampl( '20260524120000' ) ).
    class-methods fixed
      importing
        !iv_timestamp   type timestampl
      returning
        value(ro_clock) type ref to zif_au_clock.

  private section.
    " 0 means "use the system clock"; any other value freezes the clock.
    data mv_fixed type timestampl.

    methods constructor
      importing
        !iv_fixed type timestampl.
endclass.


class zcl_au_clock implementation.
  method constructor.
    mv_fixed = iv_fixed.
  endmethod.


  method system.
    ro_clock = new zcl_au_clock( iv_fixed = 0 ).
  endmethod.


  method fixed.
    ro_clock = new zcl_au_clock( iv_fixed = iv_timestamp ).
  endmethod.


  method zif_au_clock~now_timestamp.
    if mv_fixed = 0.
      get time stamp field rv_timestamp.        " current UTC moment
    else.
      rv_timestamp = mv_fixed.                   " frozen moment (tests)
    endif.
  endmethod.


  method zif_au_clock~now_date.
    " Derive the date from the single source of truth (the time stamp) so that a
    " fixed clock yields a fixed date. CONVERT TIME STAMP needs a data object, so
    " materialise the time stamp into a local first.
    data(lv_timestamp) = zif_au_clock~now_timestamp( ).
    convert time stamp lv_timestamp time zone 'UTC'
      into date rv_date.
  endmethod.


  method zif_au_clock~now_time.
    data(lv_timestamp) = zif_au_clock~now_timestamp( ).
    convert time stamp lv_timestamp time zone 'UTC'
      into time rv_time.
  endmethod.
endclass.
