report zau_demo.

" A small tour wiring several AU utilities together. Run it (SE38/ADT) to see
" the helpers in action; cl_demo_output renders the collected lines.

start-of-selection.
  data(lo_profiler) = new zcl_au_profiler( ).
  data lt_out type string_table.

  lo_profiler->start( 'demo run' ).

  " --- correlation id (GUID) -------------------------------------------------
  try.
      append |Correlation id : { zcl_au_guid=>c32( ) }| to lt_out.
    catch cx_root.
      append |Correlation id : <uuid error>| to lt_out.
  endtry.

  " --- strings, dates, numbers ----------------------------------------------
  append |snake_case     : { zcl_au_string=>to_snake_case( `SalesOrderItem` ) }| to lt_out.
  append |masked card    : { zcl_au_string=>mask( `4111111111111111` ) }| to lt_out.
  append |ISO date       : { zcl_au_date=>to_iso( '20260524' ) }| to lt_out.
  append |working days   : { zcl_au_date=>workdays_between( iv_from = '20260525' iv_to = '20260531' ) }| to lt_out.
  append |grouped amount : { zcl_au_number=>format_grouped( '1234567.5' ) }| to lt_out.

  " --- validation ------------------------------------------------------------
  append |valid e-mail?  : { zcl_au_validate=>is_email( `jane@example.com` ) }| to lt_out.
  append |valid card?    : { zcl_au_validate=>luhn_ok( `4111111111111111` ) }| to lt_out.

  " --- diff ------------------------------------------------------------------
  append || to lt_out.
  append `Diff (before/after):` to lt_out.
  append zcl_au_diff=>to_text( zcl_au_diff=>tables(
           it_a = value #( ( `line1` ) ( `line2` )         ( `line3` ) )
           it_b = value #( ( `line1` ) ( `line2 changed` ) ( `line3` ) ) ) ) to lt_out.

  lo_profiler->stop( 'demo run' ).

  " --- profile ---------------------------------------------------------------
  append || to lt_out.
  append `Profile (slowest first):` to lt_out.
  append lo_profiler->report_text( ) to lt_out.

  cl_demo_output=>display_text( concat_lines_of( table = lt_out
                                                 sep   = cl_abap_char_utilities=>newline ) ).
