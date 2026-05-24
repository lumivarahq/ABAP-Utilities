class zcl_au_timer definition
  public
  final
  create private.

  public section.
    "! Start a high-resolution stopwatch:
    "!   data(lo_timer) = zcl_au_timer=>start( ).
    "!   ... work ...
    "!   write lo_timer->elapsed_text( ).
    class-methods start
      returning
        value(ro_timer) type ref to zcl_au_timer.

    "! Elapsed microseconds since start( ). Monotonic - safe to call repeatedly.
    methods elapsed_microseconds
      returning
        value(rv_microseconds) type i.

    methods elapsed_seconds
      returning
        value(rv_seconds) type decfloat34.

    "! Human-readable elapsed time, e.g. "1234.567 ms".
    methods elapsed_text
      returning
        value(rv_text) type string.

  private section.
    data mo_runtime type ref to if_abap_runtime.
    data mv_total   type i.

    methods constructor.
endclass.


class zcl_au_timer implementation.
  method constructor.
    mo_runtime = cl_abap_runtime=>create_hr_timer( ).
  endmethod.


  method start.
    ro_timer = new zcl_au_timer( ).
  endmethod.


  method elapsed_microseconds.
    " get_runtime( ) returns the delta since the previous call; accumulate it so
    " every call reports the total time since start( ).
    mv_total       = mv_total + mo_runtime->get_runtime( ).
    rv_microseconds = mv_total.
  endmethod.


  method elapsed_seconds.
    rv_seconds = elapsed_microseconds( ) / 1000000.
  endmethod.


  method elapsed_text.
    rv_text = |{ conv decfloat34( elapsed_microseconds( ) ) / 1000 decimals = 3 } ms|.
  endmethod.
endclass.
