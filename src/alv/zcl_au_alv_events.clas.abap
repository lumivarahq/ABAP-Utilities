class zcl_au_alv_events definition
  public
  final
  create public.

  public section.
    "! Wire the double-click and hotspot (link-click) events of a SALV grid to a
    "! ZIF_AU_ALV_HANDLER. You do not need to keep the returned instance: the SALV
    "! event registration holds a reference and keeps it alive.
    "!
    "!   data(lo_alv) = zcl_au_alv=>factory( changing ct_table = lt ).
    "!   new zcl_au_alv_events( io_alv = lo_alv io_handler = me ).
    "!   lo_alv->display( ).
    methods constructor
      importing
        !io_alv     type ref to cl_salv_table
        !io_handler type ref to zif_au_alv_handler.

  private section.
    data mo_handler type ref to zif_au_alv_handler.

    methods on_double_click for event double_click of cl_salv_events_table
      importing !row !column.

    methods on_link_click for event link_click of cl_salv_events_table
      importing !row !column.
endclass.


class zcl_au_alv_events implementation.
  method constructor.
    mo_handler = io_handler.
    data(lo_events) = io_alv->get_event( ).
    set handler on_double_click for lo_events.
    set handler on_link_click   for lo_events.
  endmethod.


  method on_double_click.
    mo_handler->on_double_click( iv_row    = row
                                 iv_column = column ).
  endmethod.


  method on_link_click.
    mo_handler->on_link_click( iv_row    = row
                               iv_column = column ).
  endmethod.
endclass.
