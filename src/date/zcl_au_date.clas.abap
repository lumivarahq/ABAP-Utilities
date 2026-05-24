class zcl_au_date definition
  public
  final
  create public.

  public section.
    types:
      begin of ty_date_time,
        date type d,
        time type t,
      end of ty_date_time.

    constants gc_monday    type i value 1 ##NO_TEXT.
    constants gc_friday    type i value 5 ##NO_TEXT.
    constants gc_saturday  type i value 6 ##NO_TEXT.
    constants gc_sunday    type i value 7 ##NO_TEXT.

    "! Number of days between two dates (to - from).
    class-methods days_between
      importing
        !iv_from         type d
        !iv_to           type d
      returning
        value(rv_days)   type i.

    class-methods add_days
      importing
        !iv_date         type d
        !iv_days         type i
      returning
        value(rv_date)   type d.

    "! Add (or subtract, with a negative value) calendar months.
    "! The day is clamped to the last day of the target month
    "! (e.g. 31-Jan + 1 month = 28/29-Feb).
    class-methods add_months
      importing
        !iv_date         type d
        !iv_months       type i
      returning
        value(rv_date)   type d.

    class-methods first_day_of_month
      importing
        !iv_date         type d
      returning
        value(rv_date)   type d.

    class-methods last_day_of_month
      importing
        !iv_date         type d
      returning
        value(rv_date)   type d.

    "! Day of week, ISO-8601 numbering: Monday = 1 ... Sunday = 7.
    class-methods weekday
      importing
        !iv_date           type d
      returning
        value(rv_weekday)  type i.

    class-methods is_weekend
      importing
        !iv_date         type d
      returning
        value(rv_result) type abap_bool.

    "! Count of working days (Mon-Fri) in the closed interval [from, to].
    "! Public holidays are NOT considered - see the module README for the
    "! factory-calendar extension point.
    class-methods workdays_between
      importing
        !iv_from         type d
        !iv_to           type d
      returning
        value(rv_days)   type i.

    "! Format a date as ISO-8601 "YYYY-MM-DD".
    class-methods to_iso
      importing
        !iv_date         type d
      returning
        value(rv_iso)    type string.

    "! Parse an ISO-8601 "YYYY-MM-DD" string into a date.
    class-methods from_iso
      importing
        !iv_iso          type string
      returning
        value(rv_date)   type d.

    "! Age in completed years on a given key date. The key date is explicit (no
    "! sy-datum default) so the class stays clean-core safe and testable - pass
    "! ZCL_AU_CONTEXT=>today( ) for "today".
    class-methods age
      importing
        !iv_birthday   type d
        !iv_on         type d
      returning
        value(rv_age)  type i.

    "! Current high-resolution UTC time stamp.
    class-methods now
      returning
        value(rv_timestamp) type timestampl.

    "! Split a time stamp into date and time in the requested time zone.
    class-methods timestamp_to_date_time
      importing
        !iv_timestamp    type timestampl
        !iv_time_zone    type timezone default 'UTC'
      returning
        value(rs_result) type ty_date_time.

  private section.
    constants gc_ref_monday type d value '20200106' ##NO_TEXT.

    class-methods build_date
      importing
        !iv_year       type i
        !iv_month      type i
        !iv_day        type i
      returning
        value(rv_date) type d.

    class-methods last_day_in
      importing
        !iv_year       type i
        !iv_month      type i
      returning
        value(rv_date) type d.
endclass.


class zcl_au_date implementation.
  method days_between.
    rv_days = iv_to - iv_from.
  endmethod.


  method add_days.
    rv_date = iv_date + iv_days.
  endmethod.


  method build_date.
    data lv_str type c length 8.
    lv_str = |{ iv_year  width = 4 pad = '0' align = right }|
          && |{ iv_month width = 2 pad = '0' align = right }|
          && |{ iv_day   width = 2 pad = '0' align = right }|.
    rv_date = lv_str.
  endmethod.


  method last_day_in.
    data(lv_next_year)  = cond i( when iv_month = 12 then iv_year + 1 else iv_year ).
    data(lv_next_month) = cond i( when iv_month = 12 then 1 else iv_month + 1 ).
    rv_date = build_date( iv_year  = lv_next_year
                          iv_month = lv_next_month
                          iv_day   = 1 ) - 1.
  endmethod.


  method add_months.
    data(lv_day)   = conv i( iv_date+6(2) ).
    data(lv_index) = conv i( iv_date+0(4) ) * 12 + conv i( iv_date+4(2) ) - 1 + iv_months.
    data(lv_year)  = lv_index div 12.
    data(lv_month) = lv_index mod 12 + 1.

    data(lv_last)     = last_day_in( iv_year  = lv_year
                                     iv_month = lv_month ).
    data(lv_last_day) = conv i( lv_last+6(2) ).

    rv_date = build_date( iv_year  = lv_year
                          iv_month = lv_month
                          iv_day   = nmin( val1 = lv_day
                                           val2 = lv_last_day ) ).
  endmethod.


  method first_day_of_month.
    rv_date = iv_date.
    rv_date+6(2) = '01'.
  endmethod.


  method last_day_of_month.
    rv_date = last_day_in( iv_year  = conv i( iv_date+0(4) )
                           iv_month = conv i( iv_date+4(2) ) ).
  endmethod.


  method weekday.
    " Days since a known Monday (2020-01-06), taken mod 7. ABAP MOD with a
    " positive divisor always returns 0..6 (even for dates before the reference),
    " so +1 maps Monday->1 ... Sunday->7 (ISO-8601) without any branching.
    rv_weekday = ( iv_date - gc_ref_monday ) mod 7 + 1.
  endmethod.


  method is_weekend.
    rv_result = xsdbool( weekday( iv_date ) >= gc_saturday ).
  endmethod.


  method workdays_between.
    data(lv_day) = iv_from.
    while lv_day <= iv_to.
      if weekday( lv_day ) <= gc_friday.
        rv_days = rv_days + 1.
      endif.
      lv_day = lv_day + 1.
    endwhile.
  endmethod.


  method to_iso.
    rv_iso = |{ iv_date date = iso }|.
  endmethod.


  method from_iso.
    rv_date = iv_iso(4) && iv_iso+5(2) && iv_iso+8(2).
  endmethod.


  method age.
    rv_age = conv i( iv_on+0(4) ) - conv i( iv_birthday+0(4) ).
    if iv_on+4(4) < iv_birthday+4(4).
      rv_age = rv_age - 1.
    endif.
  endmethod.


  method now.
    get time stamp field rv_timestamp.
  endmethod.


  method timestamp_to_date_time.
    convert time stamp iv_timestamp time zone iv_time_zone
      into date rs_result-date time rs_result-time.
  endmethod.
endclass.
