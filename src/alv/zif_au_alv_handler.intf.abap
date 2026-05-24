interface zif_au_alv_handler
  public.

  "! Implement this in your report/class to react to ALV interactions, then wire
  "! it up with ZCL_AU_ALV_EVENTS. Row is the 1-based index in the result table.

  methods on_double_click
    importing
      !iv_row    type i
      !iv_column type lvc_fname.

  methods on_link_click
    importing
      !iv_row    type i
      !iv_column type lvc_fname.

endinterface.
