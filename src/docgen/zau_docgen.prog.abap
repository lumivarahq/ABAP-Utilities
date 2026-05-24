report zau_docgen.

parameters p_class type seoclsname obligatory.

start-of-selection.
  try.
      cl_demo_output=>display_text( zcl_au_docgen=>for_class( p_class ) ).
    catch zcx_au_error into data(lx_error).
      message lx_error->get_text( ) type 'E'.
  endtry.
