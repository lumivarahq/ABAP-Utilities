class zcx_au_error definition
  public
  inheriting from cx_static_check
  create public.

  public section.
    interfaces if_t100_message.

    "! Generic message "&1&2&3&4" of message class 00 - used so that an
    "! arbitrary free text can be carried by a T100-based exception.
    constants:
      begin of free_text,
        msgid type symsgid value '00',
        msgno type symsgno value '398',
        attr1 type scx_attrname value 'MV_V1',
        attr2 type scx_attrname value 'MV_V2',
        attr3 type scx_attrname value 'MV_V3',
        attr4 type scx_attrname value 'MV_V4',
      end of free_text.

    data mv_text type string read-only.
    data mv_v1 type symsgv read-only.
    data mv_v2 type symsgv read-only.
    data mv_v3 type symsgv read-only.
    data mv_v4 type symsgv read-only.

    methods constructor
      importing
        !textid   like if_t100_message=>t100key optional
        !previous like previous optional
        !text     type string optional
        !v1       type symsgv optional
        !v2       type symsgv optional
        !v3       type symsgv optional
        !v4       type symsgv optional.

    "! Raise an exception carrying an arbitrary free text.
    "! @parameter text     | the message text (first 200 chars shown as short text)
    "! @parameter previous | optional previous exception for the chain
    class-methods raise
      importing
        !text     type string
        !previous type ref to cx_root optional
      raising
        zcx_au_error.

    "! Raise an exception from a message-class message (T100).
    class-methods raise_t100
      importing
        !msgid    type symsgid
        !msgno    type symsgno
        !v1       type symsgv optional
        !v2       type symsgv optional
        !v3       type symsgv optional
        !v4       type symsgv optional
        !previous type ref to cx_root optional
      raising
        zcx_au_error.

    "! Raise an exception from the current sy-msg* fields
    "! (e.g. right after a classic MESSAGE / function module call).
    class-methods raise_from_sy
      raising
        zcx_au_error.

    "! Returns the full (untruncated) text when the exception was raised
    "! via RAISE; otherwise the resolved T100 short text.
    methods get_full_text
      returning
        value(rv_text) type string.
endclass.


class zcx_au_error implementation.
  method constructor.
    super->constructor( previous = previous ).
    me->if_t100_message~t100key = cond #( when textid is initial
                                          then free_text
                                          else textid ).
    me->mv_text = text.
    me->mv_v1 = v1.
    me->mv_v2 = v2.
    me->mv_v3 = v3.
    me->mv_v4 = v4.
  endmethod.


  method raise.
    data lv_len type i.

    lv_len = strlen( text ).

    raise exception type zcx_au_error
      exporting
        textid   = free_text
        previous = previous
        text     = text
        v1       = cond #( when lv_len > 0
                           then substring( val = text off = 0
                                           len = nmin( val1 = 50 val2 = lv_len ) ) )
        v2       = cond #( when lv_len > 50
                           then substring( val = text off = 50
                                           len = nmin( val1 = 50 val2 = lv_len - 50 ) ) )
        v3       = cond #( when lv_len > 100
                           then substring( val = text off = 100
                                           len = nmin( val1 = 50 val2 = lv_len - 100 ) ) )
        v4       = cond #( when lv_len > 150
                           then substring( val = text off = 150
                                           len = nmin( val1 = 50 val2 = lv_len - 150 ) ) ).
  endmethod.


  method raise_t100.
    raise exception type zcx_au_error
      exporting
        textid   = value #( msgid = msgid
                            msgno = msgno
                            attr1 = 'MV_V1'
                            attr2 = 'MV_V2'
                            attr3 = 'MV_V3'
                            attr4 = 'MV_V4' )
        previous = previous
        v1       = v1
        v2       = v2
        v3       = v3
        v4       = v4.
  endmethod.


  method raise_from_sy.
    data lv_text type string.

    " snapshot the sy fields before MESSAGE ... INTO overwrites them
    data(ls_sy) = value symsg( msgty = sy-msgty
                               msgid = sy-msgid
                               msgno = sy-msgno
                               msgv1 = sy-msgv1
                               msgv2 = sy-msgv2
                               msgv3 = sy-msgv3
                               msgv4 = sy-msgv4 ).

    message id ls_sy-msgid type ls_sy-msgty number ls_sy-msgno
      with ls_sy-msgv1 ls_sy-msgv2 ls_sy-msgv3 ls_sy-msgv4
      into lv_text.

    raise exception type zcx_au_error
      exporting
        textid = value #( msgid = ls_sy-msgid
                          msgno = ls_sy-msgno
                          attr1 = 'MV_V1'
                          attr2 = 'MV_V2'
                          attr3 = 'MV_V3'
                          attr4 = 'MV_V4' )
        text   = lv_text
        v1     = ls_sy-msgv1
        v2     = ls_sy-msgv2
        v3     = ls_sy-msgv3
        v4     = ls_sy-msgv4.
  endmethod.


  method get_full_text.
    rv_text = cond #( when mv_text is not initial
                      then mv_text
                      else if_message~get_text( ) ).
  endmethod.
endclass.
