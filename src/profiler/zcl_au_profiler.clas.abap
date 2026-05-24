class zcl_au_profiler definition
  public
  final
  create public.

  public section.
    "! One aggregated line of the profile result.
    types:
      begin of ty_measurement,
        step     type string,        " the name you gave the block / query
        count    type i,             " how many times it ran
        total_us type i,             " total microseconds
        avg_us   type i,             " average microseconds per run
        min_us   type i,
        max_us   type i,
        percent  type decfloat34,     " share of the total measured time
      end of ty_measurement,
      tt_measurement type standard table of ty_measurement with default key.

    "! Start timing a named step (wrap a code block or a SELECT).
    methods start
      importing
        !iv_step type csequence.

    "! Stop the most recent matching start and accumulate the elapsed time.
    methods stop
      importing
        !iv_step type csequence.

    "! Record a measurement directly (microseconds). Use it to fold in a duration
    "! you measured elsewhere - and it is what start/stop call internally.
    methods record
      importing
        !iv_step   type csequence
        !iv_micros type i.

    "! Aggregated results, sorted slowest-first (total time descending) - the
    "! "which step took the longest" view.
    methods report
      returning
        value(rt_result) type tt_measurement.

    "! Human-readable, slowest-first report (for a log, the console, or an ALV
    "! title). Times are shown in milliseconds.
    methods report_text
      returning
        value(rv_text) type string.

    "! Clear all measurements (e.g. between runs).
    methods reset.

  private section.
    types:
      begin of ty_running,
        step     type string,
        start_us type i,
      end of ty_running,
      begin of ty_acc,
        step     type string,
        count    type i,
        total_us type i,
        min_us   type i,
        max_us   type i,
      end of ty_acc.

    " open start( ) calls, used as a stack so nested/repeated steps pair up
    data mt_running type standard table of ty_running with default key.
    data mt_acc     type sorted table of ty_acc with unique key step.

    methods now_us
      returning
        value(rv_us) type i.
endclass.


class zcl_au_profiler implementation.
  method now_us.
    " CPU microseconds since the first GET RUN TIME of the session (SE30-style).
    get run time field rv_us.
  endmethod.


  method start.
    append value #( step     = iv_step
                    start_us = now_us( ) ) to mt_running.
  endmethod.


  method stop.
    data(lv_now) = now_us( ).

    " find the most recent open start for this step (handles nesting/repeats)
    data lv_index type i.
    loop at mt_running transporting no fields where step = iv_step.
      lv_index = sy-tabix.
    endloop.
    if lv_index = 0.
      return.                                   " stop without a matching start
    endif.

    data(ls_running) = mt_running[ lv_index ].
    delete mt_running index lv_index.
    record( iv_step   = iv_step
            iv_micros = lv_now - ls_running-start_us ).
  endmethod.


  method record.
    read table mt_acc with key step = iv_step assigning field-symbol(<acc>).
    if sy-subrc <> 0.
      insert value #( step     = iv_step
                      count    = 1
                      total_us = iv_micros
                      min_us   = iv_micros
                      max_us   = iv_micros ) into table mt_acc.
      return.
    endif.

    <acc>-count    = <acc>-count + 1.
    <acc>-total_us = <acc>-total_us + iv_micros.
    if iv_micros < <acc>-min_us.
      <acc>-min_us = iv_micros.
    endif.
    if iv_micros > <acc>-max_us.
      <acc>-max_us = iv_micros.
    endif.
  endmethod.


  method report.
    data(lv_total_all) = reduce i( init s = 0
                                   for ls in mt_acc
                                   next s = s + ls-total_us ).

    loop at mt_acc into data(ls_acc).
      append value #( step     = ls_acc-step
                      count    = ls_acc-count
                      total_us = ls_acc-total_us
                      avg_us   = ls_acc-total_us / ls_acc-count
                      min_us   = ls_acc-min_us
                      max_us   = ls_acc-max_us
                      percent  = cond #( when lv_total_all > 0
                                         then ls_acc-total_us * 100 / lv_total_all
                                         else 0 ) ) to rt_result.
    endloop.

    sort rt_result by total_us descending.
  endmethod.


  method report_text.
    data(lv_lf) = cl_abap_char_utilities=>newline.
    data lt_lines type string_table.
    append |{ 'Step' width = 36 }  { 'Count' width = 6 align = right }  | &&
           |{ 'Total(ms)' width = 11 align = right }  { 'Avg(ms)' width = 9 align = right }  | &&
           |{ 'Max(ms)' width = 9 align = right }  { '%' width = 6 align = right }| to lt_lines.
    append repeat( val = '-' occ = 86 ) to lt_lines.

    loop at report( ) into data(ls).
      append |{ ls-step width = 36 }  { ls-count width = 6 align = right }  | &&
             |{ conv decfloat34( ls-total_us ) / 1000 decimals = 1 width = 11 align = right }  | &&
             |{ conv decfloat34( ls-avg_us ) / 1000 decimals = 1 width = 9 align = right }  | &&
             |{ conv decfloat34( ls-max_us ) / 1000 decimals = 1 width = 9 align = right }  | &&
             |{ ls-percent decimals = 1 width = 6 align = right }| to lt_lines.
    endloop.

    rv_text = concat_lines_of( table = lt_lines
                               sep   = lv_lf ).
  endmethod.


  method reset.
    clear: mt_running, mt_acc.
  endmethod.
endclass.
