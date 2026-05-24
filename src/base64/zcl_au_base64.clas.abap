class zcl_au_base64 definition
  public
  final
  create public.

  public section.
    "! Base64-encode raw bytes.
    class-methods encode
      importing
        !iv_data         type xstring
      returning
        value(rv_base64) type string.

    "! Base64-decode into raw bytes.
    class-methods decode
      importing
        !iv_base64     type string
      returning
        value(rv_data) type xstring.

    "! Base64-encode a string (UTF-8).
    class-methods encode_string
      importing
        !iv_text         type string
      returning
        value(rv_base64) type string.

    "! Base64-decode into a string (UTF-8).
    class-methods decode_to_string
      importing
        !iv_base64     type string
      returning
        value(rv_text) type string.
endclass.


class zcl_au_base64 implementation.
  method encode.
    rv_base64 = cl_web_http_utility=>encode_x_base64( iv_data ).
  endmethod.


  method decode.
    rv_data = cl_web_http_utility=>decode_x_base64( iv_base64 ).
  endmethod.


  method encode_string.
    rv_base64 = cl_web_http_utility=>encode_x_base64(
      cl_abap_conv_codepage=>create_out( codepage = `UTF-8` )->convert( source = iv_text ) ).
  endmethod.


  method decode_to_string.
    rv_text = cl_abap_conv_codepage=>create_in( codepage = `UTF-8`
      )->convert( source = cl_web_http_utility=>decode_x_base64( iv_base64 ) ).
  endmethod.
endclass.
