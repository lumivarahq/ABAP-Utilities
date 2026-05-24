class zcl_au_hash definition
  public
  final
  create public.

  public section.
    "! MD5 hex digest of a string (UTF-8 bytes). Use only for checksums/keys,
    "! never for passwords or security tokens.
    class-methods md5
      importing
        !iv_data       type string
      returning
        value(rv_hash) type string
      raising
        zcx_au_error.

    "! SHA-1 hex digest of a string (UTF-8 bytes).
    class-methods sha1
      importing
        !iv_data       type string
      returning
        value(rv_hash) type string
      raising
        zcx_au_error.

    "! SHA-256 hex digest of a string (UTF-8 bytes).
    class-methods sha256
      importing
        !iv_data       type string
      returning
        value(rv_hash) type string
      raising
        zcx_au_error.

    "! Hex digest of raw bytes with any algorithm supported by
    "! CL_ABAP_MESSAGE_DIGEST (e.g. 'SHA512').
    class-methods hash_binary
      importing
        !iv_data       type xstring
        !iv_algorithm  type string default 'SHA256'
      returning
        value(rv_hash) type string
      raising
        zcx_au_error.

  private section.
    class-methods hash_string
      importing
        !iv_data       type string
        !iv_algorithm  type string
      returning
        value(rv_hash) type string
      raising
        zcx_au_error.
endclass.


class zcl_au_hash implementation.
  method md5.
    rv_hash = hash_string( iv_data = iv_data iv_algorithm = 'MD5' ).
  endmethod.


  method sha1.
    rv_hash = hash_string( iv_data = iv_data iv_algorithm = 'SHA1' ).
  endmethod.


  method sha256.
    rv_hash = hash_string( iv_data = iv_data iv_algorithm = 'SHA256' ).
  endmethod.


  method hash_string.
    rv_hash = hash_binary(
      iv_data      = cl_abap_conv_codepage=>create_out( codepage = `UTF-8` )->convert( source = iv_data )
      iv_algorithm = iv_algorithm ).
  endmethod.


  method hash_binary.
    try.
        cl_abap_message_digest=>calculate_hash_for_raw(
          exporting
            if_algorithm   = iv_algorithm
            if_data        = iv_data
          importing
            ef_hashxstring = data(lv_hash_x) ).
      catch cx_root into data(lx_error).
        zcx_au_error=>raise( text     = lx_error->get_text( )
                             previous = lx_error ).
    endtry.
    rv_hash = to_lower( |{ lv_hash_x }| ).
  endmethod.
endclass.
