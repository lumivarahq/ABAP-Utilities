class zcl_au_test_data definition
  public
  final
  create public.

  public section.
    "! Random integer in the closed interval [min, max].
    class-methods random_int
      importing
        !iv_min         type i default 0
        !iv_max         type i default 1000000
      returning
        value(rv_value) type i.

    "! Random alphanumeric string of the requested length.
    class-methods random_string
      importing
        !iv_length       type i default 10
      returning
        value(rv_string) type string.

    "! Random date in the closed interval [from, to].
    class-methods random_date
      importing
        !iv_from       type d default '20000101'
        !iv_to         type d default '20301231'
      returning
        value(rv_date) type d.

    class-methods random_bool
      returning
        value(rv_value) type abap_bool.

  private section.
    constants gc_charset type string
      value `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789` ##NO_TEXT.
endclass.


class zcl_au_test_data implementation.
  method random_int.
    rv_value = cl_abap_random_int=>create( seed = cl_abap_random=>seed( )
                                           min  = iv_min
                                           max  = iv_max )->get_next( ).
  endmethod.


  method random_string.
    data(lo_random) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( )
                                                   min  = 0
                                                   max  = strlen( gc_charset ) - 1 ).
    do iv_length times.
      rv_string = rv_string && substring( val = gc_charset
                                          off = lo_random->get_next( )
                                          len = 1 ).
    enddo.
  endmethod.


  method random_date.
    data(lv_span) = iv_to - iv_from.
    if lv_span <= 0.
      rv_date = iv_from.
      return.
    endif.
    rv_date = iv_from + random_int( iv_min = 0
                                    iv_max = lv_span ).
  endmethod.


  method random_bool.
    rv_value = xsdbool( random_int( iv_min = 0 iv_max = 1 ) = 1 ).
  endmethod.
endclass.
