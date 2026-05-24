class zcl_au_rap_msg definition
  public
  final
  create public.

  public section.
    "! Factory helpers that build RAP messages (IF_ABAP_BEHV_MESSAGE) for the
    "! REPORTED / FAILED tables of a behavior implementation.
    "!
    "! Usage inside a behavior pool:
    "!   append value #( %tky = keys[ 1 ]-%tky
    "!                   %msg = zcl_au_rap_msg=>error(
    "!                            iv_msgid = 'ZFOO' iv_msgno = '001'
    "!                            iv_v1    = lv_id ) )
    "!          to reported-mybo.

    "! Message-class (T100) message with ERROR severity.
    class-methods error
      importing
        !iv_msgid     type symsgid
        !iv_msgno     type symsgno
        !iv_v1        type symsgv optional
        !iv_v2        type symsgv optional
        !iv_v3        type symsgv optional
        !iv_v4        type symsgv optional
      returning
        value(ro_msg) type ref to if_abap_behv_message.

    "! Message-class (T100) message with WARNING severity.
    class-methods warning
      importing
        !iv_msgid     type symsgid
        !iv_msgno     type symsgno
        !iv_v1        type symsgv optional
        !iv_v2        type symsgv optional
        !iv_v3        type symsgv optional
        !iv_v4        type symsgv optional
      returning
        value(ro_msg) type ref to if_abap_behv_message.

    "! Message-class (T100) message with INFORMATION severity.
    class-methods info
      importing
        !iv_msgid     type symsgid
        !iv_msgno     type symsgno
        !iv_v1        type symsgv optional
        !iv_v2        type symsgv optional
        !iv_v3        type symsgv optional
        !iv_v4        type symsgv optional
      returning
        value(ro_msg) type ref to if_abap_behv_message.

    "! Message-class (T100) message with SUCCESS severity.
    class-methods success
      importing
        !iv_msgid     type symsgid
        !iv_msgno     type symsgno
        !iv_v1        type symsgv optional
        !iv_v2        type symsgv optional
        !iv_v3        type symsgv optional
        !iv_v4        type symsgv optional
      returning
        value(ro_msg) type ref to if_abap_behv_message.

    "! Free-text ERROR message (no message class required).
    class-methods text_error
      importing
        !iv_text      type string
      returning
        value(ro_msg) type ref to if_abap_behv_message.

    "! Build an ERROR message from any exception text.
    class-methods from_exception
      importing
        !io_exception type ref to cx_root
      returning
        value(ro_msg) type ref to if_abap_behv_message.
endclass.


class zcl_au_rap_msg implementation.
  method error.
    ro_msg = cl_abap_behv=>new_message(
      id       = iv_msgid
      number   = iv_msgno
      severity = if_abap_behv_message=>severity-error
      v1       = iv_v1
      v2       = iv_v2
      v3       = iv_v3
      v4       = iv_v4 ).
  endmethod.


  method warning.
    ro_msg = cl_abap_behv=>new_message(
      id       = iv_msgid
      number   = iv_msgno
      severity = if_abap_behv_message=>severity-warning
      v1       = iv_v1
      v2       = iv_v2
      v3       = iv_v3
      v4       = iv_v4 ).
  endmethod.


  method info.
    ro_msg = cl_abap_behv=>new_message(
      id       = iv_msgid
      number   = iv_msgno
      severity = if_abap_behv_message=>severity-information
      v1       = iv_v1
      v2       = iv_v2
      v3       = iv_v3
      v4       = iv_v4 ).
  endmethod.


  method success.
    ro_msg = cl_abap_behv=>new_message(
      id       = iv_msgid
      number   = iv_msgno
      severity = if_abap_behv_message=>severity-success
      v1       = iv_v1
      v2       = iv_v2
      v3       = iv_v3
      v4       = iv_v4 ).
  endmethod.


  method text_error.
    ro_msg = cl_abap_behv=>new_message_with_text(
      severity = if_abap_behv_message=>severity-error
      text     = iv_text ).
  endmethod.


  method from_exception.
    ro_msg = cl_abap_behv=>new_message_with_text(
      severity = if_abap_behv_message=>severity-error
      text     = io_exception->get_text( ) ).
  endmethod.
endclass.
