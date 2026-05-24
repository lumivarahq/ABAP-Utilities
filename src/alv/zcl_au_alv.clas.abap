class zcl_au_alv definition
  public
  final
  create public.

  public section.
    "! One-call full-screen ALV grid - a drop-in replacement for the classic
    "! REUSE_ALV_GRID_DISPLAY. Columns are width-optimized, the grid is striped
    "! and all standard ALV functions (sort, filter, export, layout) are on.
    "!
    "!   zcl_au_alv=>display( changing ct_table = lt_data ).
    class-methods display
      importing
        !iv_title type lvc_title optional
      changing
        !ct_table type standard table
      raising
        cx_salv_msg.

    "! Build a pre-configured SALV instance (functions on, optimized, striped,
    "! layout save enabled) so the caller can tweak it before ->display( ).
    class-methods factory
      importing
        !iv_title     type lvc_title optional
      changing
        !ct_table     type standard table
      returning
        value(ro_alv) type ref to cl_salv_table
      raising
        cx_salv_msg.

    "! Reuse an existing classic field catalog (LVC) on a SALV instance.
    "! This is the bridge for a REUSE_ALV -> SALV migration: keep the field
    "! catalog you already build and apply texts, visibility and hotspots to
    "! the modern grid. Unknown / missing columns are ignored.
    class-methods apply_lvc_fieldcat
      importing
        !io_alv  type ref to cl_salv_table
        !it_fcat type lvc_t_fcat.

    "! Set all three column titles (short/medium/long) from one text.
    class-methods set_column_title
      importing
        !io_alv    type ref to cl_salv_table
        !iv_column type lvc_fname
        !iv_title  type string.

    class-methods hide_column
      importing
        !io_alv    type ref to cl_salv_table
        !iv_column type lvc_fname.
endclass.


class zcl_au_alv implementation.
  method factory.
    cl_salv_table=>factory(
      importing
        r_salv_table = ro_alv
      changing
        t_table      = ct_table ).

    ro_alv->get_functions( )->set_all( abap_true ).
    ro_alv->get_columns( )->set_optimize( abap_true ).
    ro_alv->get_display_settings( )->set_striped_pattern( abap_true ).

    if iv_title is not initial.
      ro_alv->get_display_settings( )->set_list_header( iv_title ).
    endif.

    data(lo_layout) = ro_alv->get_layout( ).
    lo_layout->set_key( value #( report = sy-repid ) ).
    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
  endmethod.


  method display.
    data(lo_alv) = factory( exporting iv_title = iv_title
                            changing  ct_table = ct_table ).
    lo_alv->display( ).
  endmethod.


  method set_column_title.
    try.
        data(lo_col) = io_alv->get_columns( )->get_column( iv_column ).
        lo_col->set_short_text(  conv #( iv_title ) ).
        lo_col->set_medium_text( conv #( iv_title ) ).
        lo_col->set_long_text(   conv #( iv_title ) ).
      catch cx_salv_not_found.
        " column not in the result table - nothing to title
    endtry.
  endmethod.


  method hide_column.
    try.
        io_alv->get_columns( )->get_column( iv_column )->set_visible( abap_false ).
      catch cx_salv_not_found.
    endtry.
  endmethod.


  method apply_lvc_fieldcat.
    data(lo_columns) = io_alv->get_columns( ).

    loop at it_fcat into data(ls_fcat).
      try.
          data(lo_col) = cast cl_salv_column_table( lo_columns->get_column( ls_fcat-fieldname ) ).
        catch cx_salv_not_found.
          continue.
      endtry.

      if ls_fcat-no_out = abap_true or ls_fcat-tech = abap_true.
        lo_col->set_visible( abap_false ).
      endif.
      if ls_fcat-scrtext_l is not initial.
        lo_col->set_long_text( ls_fcat-scrtext_l ).
      elseif ls_fcat-reptext is not initial.
        lo_col->set_long_text( conv #( ls_fcat-reptext ) ).
      endif.
      if ls_fcat-scrtext_m is not initial.
        lo_col->set_medium_text( ls_fcat-scrtext_m ).
      endif.
      if ls_fcat-scrtext_s is not initial.
        lo_col->set_short_text( ls_fcat-scrtext_s ).
      endif.
      if ls_fcat-hotspot = abap_true.
        lo_col->set_cell_type( if_salv_c_cell_type=>hotspot ).
      endif.
    endloop.
  endmethod.
endclass.
