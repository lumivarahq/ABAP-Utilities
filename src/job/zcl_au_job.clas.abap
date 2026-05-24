class zcl_au_job definition
  public
  final
  create public.

  public section.
    "! Schedule a report to run in a background job in one call
    "! (JOB_OPEN -> SUBMIT ... VIA JOB -> JOB_CLOSE).
    "! @parameter iv_jobname           | name shown in SM37
    "! @parameter iv_report            | program to run
    "! @parameter it_selection         | selection-screen parameters (RSPARAMS)
    "! @parameter iv_start_immediately | start now (else released, scheduled later)
    "! @parameter iv_target_server     | optional batch server / server group
    "! @parameter rv_jobcount          | the created job number (with jobname identifies the job)
    class-methods run_report
      importing
        !iv_jobname           type btcjob
        !iv_report            type syrepid
        !it_selection         type rsparams_tt optional
        !iv_start_immediately type abap_bool default abap_true
        !iv_target_server     type btcsrvname optional
      returning
        value(rv_jobcount)    type btcjobcnt
      raising
        zcx_au_error.
endclass.


class zcl_au_job implementation.
  method run_report.
    data lv_jobcount type btcjobcnt.

    call function 'JOB_OPEN'
      exporting
        jobname          = iv_jobname
      importing
        jobcount         = lv_jobcount
      exceptions
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        others           = 4.
    if sy-subrc <> 0.
      zcx_au_error=>raise( |JOB_OPEN failed for { iv_jobname } (rc={ sy-subrc })| ) ##NO_TEXT.
    endif.

    submit (iv_report)
      with selection-table it_selection
      via job iv_jobname number lv_jobcount
      and return.
    if sy-subrc <> 0.
      zcx_au_error=>raise( |SUBMIT of { iv_report } failed (rc={ sy-subrc })| ) ##NO_TEXT.
    endif.

    call function 'JOB_CLOSE'
      exporting
        jobcount             = lv_jobcount
        jobname              = iv_jobname
        strtimmed            = iv_start_immediately
        targetserver         = iv_target_server
      exceptions
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        invalid_target       = 8
        others               = 9.
    if sy-subrc <> 0.
      zcx_au_error=>raise( |JOB_CLOSE failed for { iv_jobname } (rc={ sy-subrc })| ) ##NO_TEXT.
    endif.

    rv_jobcount = lv_jobcount.
  endmethod.
endclass.
