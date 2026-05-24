class zcl_au_context definition
  public
  final
  create public.

  public section.
    "! Released, clean-core-safe replacements for the restricted system fields.
    "! Prefer these over sy-uname / sy-datum / sy-uzeit so the code stays
    "! ABAP-Cloud ready (see docs/clean-core-atc-cookbook.md).

    "! Technical name of the current user (replaces sy-uname).
    class-methods user
      returning
        value(rv_user) type syuname.

    "! Current system date (replaces sy-datum).
    class-methods today
      returning
        value(rv_date) type d.

    "! Current system time (replaces sy-uzeit).
    class-methods time_now
      returning
        value(rv_time) type t.

    "! Time zone of the current user.
    class-methods time_zone
      returning
        value(rv_time_zone) type timezone.
endclass.


class zcl_au_context implementation.
  method user.
    rv_user = cl_abap_context_info=>get_user_technical_name( ).
  endmethod.


  method today.
    rv_date = cl_abap_context_info=>get_system_date( ).
  endmethod.


  method time_now.
    rv_time = cl_abap_context_info=>get_system_time( ).
  endmethod.


  method time_zone.
    rv_time_zone = cl_abap_context_info=>get_user_time_zone( ).
  endmethod.
endclass.
