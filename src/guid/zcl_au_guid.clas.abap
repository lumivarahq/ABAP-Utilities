class zcl_au_guid definition
  public
  final
  create public.

  public section.
    "! New UUID as a 32-character upper-case hex string.
    class-methods c32
      returning
        value(rv_guid) type sysuuid_c32
      raising
        cx_uuid_error.

    "! New UUID as a 22-character (base64-like) string.
    class-methods c22
      returning
        value(rv_guid) type sysuuid_c22
      raising
        cx_uuid_error.

    "! New UUID as raw 16 bytes (RAW16) - the form used for key fields.
    class-methods x16
      returning
        value(rv_guid) type sysuuid_x16
      raising
        cx_uuid_error.
endclass.


class zcl_au_guid implementation.
  method c32.
    rv_guid = cl_system_uuid=>create_uuid_c32_static( ).
  endmethod.


  method c22.
    rv_guid = cl_system_uuid=>create_uuid_c22_static( ).
  endmethod.


  method x16.
    rv_guid = cl_system_uuid=>create_uuid_x16_static( ).
  endmethod.
endclass.
