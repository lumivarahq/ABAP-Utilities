class zcl_au_logger definition
  public
  final
  create private.

  public section.
    interfaces zif_au_log.

    "! Create a logger bound to an Application Log object/subobject.
    "! Maintain the log object with transaction SLG0.
    "! @parameter iv_object    | BAL log object (SLG0); blank = generic log
    "! @parameter iv_subobject | BAL subobject (SLG0)
    "! @parameter iv_extnumber | external id shown in transaction SLG1
    class-methods create
      importing
        !iv_object    type balobj_d  optional
        !iv_subobject type balsubobj optional
        !iv_extnumber type balnrext  optional
      returning
        value(ro_log) type ref to zif_au_log
      raising
        zcx_au_error.

  private section.
    data mv_handle type balloghndl.

    methods constructor
      importing
        !iv_object    type balobj_d
        !iv_subobject type balsubobj
        !iv_extnumber type balnrext
      raising
        zcx_au_error.

    methods add_text
      importing
        !iv_type type symsgty
        !iv_text type string.
endclass.


class zcl_au_logger implementation.
  method create.
    ro_log = new zcl_au_logger( iv_object    = iv_object
                                iv_subobject = iv_subobject
                                iv_extnumber = iv_extnumber ).
  endmethod.


  method constructor.
    data(ls_log) = value bal_s_log( object    = iv_object
                                    subobject = iv_subobject
                                    extnumber = iv_extnumber
                                    aluser    = sy-uname
                                    alprog    = sy-cprog ).

    call function 'BAL_LOG_CREATE'
      exporting
        i_s_log                 = ls_log
      importing
        e_log_handle            = mv_handle
      exceptions
        log_header_inconsistent = 1
        others                  = 2.
    if sy-subrc <> 0.
      zcx_au_error=>raise( `Application log could not be created (BAL_LOG_CREATE).` ) ##NO_TEXT.
    endif.
  endmethod.


  method add_text.
    call function 'BAL_LOG_MSG_ADD_FREE_TEXT'
      exporting
        i_log_handle     = mv_handle
        i_msgty          = iv_type
        i_text           = iv_text
      exceptions
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        others           = 4.
  endmethod.


  method zif_au_log~info.
    add_text( iv_type = 'I' iv_text = iv_text ).
    ro_self = me.
  endmethod.


  method zif_au_log~success.
    add_text( iv_type = 'S' iv_text = iv_text ).
    ro_self = me.
  endmethod.


  method zif_au_log~warning.
    add_text( iv_type = 'W' iv_text = iv_text ).
    ro_self = me.
  endmethod.


  method zif_au_log~error.
    add_text( iv_type = 'E' iv_text = iv_text ).
    ro_self = me.
  endmethod.


  method zif_au_log~add_exception.
    data(lo_exc) = io_exception.
    while lo_exc is bound.
      add_text( iv_type = 'E'
                iv_text = lo_exc->get_text( ) ).
      lo_exc = lo_exc->previous.
    endwhile.
    ro_self = me.
  endmethod.


  method zif_au_log~add_bapiret.
    loop at it_return into data(ls_ret).
      data(ls_msg) = value bal_s_msg( msgty = ls_ret-type
                                      msgid = ls_ret-id
                                      msgno = ls_ret-number
                                      msgv1 = ls_ret-message_v1
                                      msgv2 = ls_ret-message_v2
                                      msgv3 = ls_ret-message_v3
                                      msgv4 = ls_ret-message_v4 ).
      call function 'BAL_LOG_MSG_ADD'
        exporting
          i_log_handle = mv_handle
          i_s_msg      = ls_msg
        exceptions
          others       = 0.
    endloop.
    ro_self = me.
  endmethod.


  method zif_au_log~add_from_sy.
    data(ls_msg) = value bal_s_msg( msgty = sy-msgty
                                    msgid = sy-msgid
                                    msgno = sy-msgno
                                    msgv1 = sy-msgv1
                                    msgv2 = sy-msgv2
                                    msgv3 = sy-msgv3
                                    msgv4 = sy-msgv4 ).
    call function 'BAL_LOG_MSG_ADD'
      exporting
        i_log_handle = mv_handle
        i_s_msg      = ls_msg
      exceptions
        others       = 0.
    ro_self = me.
  endmethod.


  method zif_au_log~save.
    data(lt_handles) = value bal_t_logh( ( mv_handle ) ).
    data lt_lognumbers type bal_t_lgnm.

    call function 'BAL_DB_SAVE'
      exporting
        i_t_log_handle   = lt_handles
      importing
        e_new_lognumbers = lt_lognumbers
      exceptions
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        others           = 4.
    if sy-subrc <> 0.
      zcx_au_error=>raise( `Application log could not be saved (BAL_DB_SAVE).` ) ##NO_TEXT.
    endif.

    if iv_commit = abap_true.
      commit work.
    endif.

    read table lt_lognumbers index 1 into data(ls_lognumber).
    if sy-subrc = 0.
      rv_lognumber = ls_lognumber-lognumber.
    endif.
  endmethod.


  method zif_au_log~handle.
    rv_handle = mv_handle.
  endmethod.
endclass.
