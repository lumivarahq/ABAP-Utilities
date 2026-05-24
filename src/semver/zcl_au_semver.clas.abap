class zcl_au_semver definition
  public
  final
  create public.

  public section.
    types:
      begin of ty_version,
        major type i,
        minor type i,
        patch type i,
      end of ty_version.

    "! Parse "MAJOR[.MINOR[.PATCH]]". A pre-release/build suffix (after '-' or '+')
    "! is ignored. Missing minor/patch default to 0.
    class-methods parse
      importing
        !iv_version       type string
      returning
        value(rs_version) type ty_version
      raising
        zcx_au_error.

    "! Compare two versions: -1 if a < b, 0 if equal, 1 if a > b.
    class-methods compare
      importing
        !iv_a         type string
        !iv_b         type string
      returning
        value(rv_cmp) type i
      raising
        zcx_au_error.

    "! True if iv_version >= iv_minimum (a simple dependency satisfaction check).
    class-methods at_least
      importing
        !iv_version      type string
        !iv_minimum      type string
      returning
        value(rv_result) type abap_bool
      raising
        zcx_au_error.

  private section.
    class-methods part
      importing
        !it_parts      type string_table
        !iv_index      type i
      returning
        value(rv_value) type i
      raising
        zcx_au_error.
endclass.


class zcl_au_semver implementation.
  method parse.
    " drop any -prerelease / +build suffix
    data(lv_core) = iv_version.
    data(lv_cut)  = find( val = lv_core regex = `[-+]` ).
    if lv_cut >= 0.
      lv_core = lv_core(lv_cut).
    endif.

    split lv_core at '.' into table data(lt_parts).
    if lines( lt_parts ) = 0 or lines( lt_parts ) > 3.
      zcx_au_error=>raise( |Invalid semantic version '{ iv_version }'| ) ##NO_TEXT.
    endif.

    rs_version-major = part( it_parts = lt_parts iv_index = 1 ).
    rs_version-minor = part( it_parts = lt_parts iv_index = 2 ).
    rs_version-patch = part( it_parts = lt_parts iv_index = 3 ).
  endmethod.


  method part.
    data(lv_raw) = condense( value string( it_parts[ iv_index ] optional ) ).
    if lv_raw is initial.
      return.                                  " missing minor/patch -> 0
    endif.
    if not matches( val = lv_raw regex = `\d+` ).
      zcx_au_error=>raise( |Version segment '{ lv_raw }' is not numeric| ) ##NO_TEXT.
    endif.
    rv_value = lv_raw.
  endmethod.


  method compare.
    data(ls_a) = parse( iv_a ).
    data(ls_b) = parse( iv_b ).

    rv_cmp = cond i(
      when ls_a-major <> ls_b-major then cond #( when ls_a-major > ls_b-major then 1 else -1 )
      when ls_a-minor <> ls_b-minor then cond #( when ls_a-minor > ls_b-minor then 1 else -1 )
      when ls_a-patch <> ls_b-patch then cond #( when ls_a-patch > ls_b-patch then 1 else -1 )
      else 0 ).
  endmethod.


  method at_least.
    rv_result = xsdbool( compare( iv_a = iv_version iv_b = iv_minimum ) >= 0 ).
  endmethod.
endclass.
