class zcl_au_zip definition
  public
  final
  create public.

  public section.
    "! Add a file (raw bytes) to the archive. Chainable.
    methods add
      importing
        !iv_name      type string
        !iv_content   type xstring
      returning
        value(ro_zip) type ref to zcl_au_zip.

    "! Serialize the archive to a single xstring (the .zip content).
    methods save
      returning
        value(rv_zip) type xstring.

    "! Open an existing archive from its bytes.
    class-methods load
      importing
        !iv_zip       type xstring
      returning
        value(ro_zip) type ref to zcl_au_zip
      raising
        zcx_au_error.

    "! Extract one entry by name.
    methods get
      importing
        !iv_name         type string
      returning
        value(rv_content) type xstring
      raising
        zcx_au_error.

    "! Names of all entries in the archive.
    methods names
      returning
        value(rt_names) type string_table.

  private section.
    data mo_zip type ref to cl_abap_zip.

    methods constructor.
endclass.


class zcl_au_zip implementation.
  method constructor.
    mo_zip = new cl_abap_zip( ).
  endmethod.


  method add.
    mo_zip->add( name    = iv_name
                 content = iv_content ).
    ro_zip = me.
  endmethod.


  method save.
    rv_zip = mo_zip->save( ).
  endmethod.


  method load.
    ro_zip = new zcl_au_zip( ).
    ro_zip->mo_zip->load(
      exporting
        zip             = iv_zip
      exceptions
        zip_parse_error = 1
        others          = 2 ).
    if sy-subrc <> 0.
      zcx_au_error=>raise( |Could not parse ZIP archive (rc={ sy-subrc })| ) ##NO_TEXT.
    endif.
  endmethod.


  method get.
    mo_zip->get(
      exporting
        name                    = iv_name
      importing
        content                 = rv_content
      exceptions
        zip_index_error         = 1
        zip_decompression_error = 2
        others                  = 3 ).
    if sy-subrc <> 0.
      zcx_au_error=>raise( |Entry '{ iv_name }' not found in ZIP (rc={ sy-subrc })| ) ##NO_TEXT.
    endif.
  endmethod.


  method names.
    loop at mo_zip->files into data(ls_file).
      append ls_file-name to rt_names.
    endloop.
  endmethod.
endclass.
