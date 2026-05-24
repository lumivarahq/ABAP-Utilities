class zcl_au_message definition
  public
  final
  create public.

  public section.
    "! Resolve a message-class (T100) message into its formatted text.
    class-methods text_from_t100
      importing
        !iv_msgid      type symsgid
        !iv_msgno      type symsgno
        !iv_v1         type symsgv optional
        !iv_v2         type symsgv optional
        !iv_v3         type symsgv optional
        !iv_v4         type symsgv optional
      returning
        value(rv_text) type string.

    "! Formatted text of the message currently in the sy-msg* fields.
    class-methods text_from_sy
      returning
        value(rv_text) type string.

    "! Build a single BAPIRET2 line (incl. the resolved message text).
    class-methods bapiret
      importing
        !iv_type         type symsgty
        !iv_msgid        type symsgid
        !iv_msgno        type symsgno
        !iv_v1           type symsgv optional
        !iv_v2           type symsgv optional
        !iv_v3           type symsgv optional
        !iv_v4           type symsgv optional
      returning
        value(rs_return) type bapiret2.

    "! Build a BAPIRET2 line from the current sy-msg* fields.
    class-methods bapiret_from_sy
      returning
        value(rs_return) type bapiret2.

    "! True if the table contains an error (E), abort (A) or dump (X) row.
    class-methods has_errors
      importing
        !it_return       type bapiret2_t
      returning
        value(rv_result) type abap_bool.

    "! Concatenate all message texts of a BAPIRET2 table.
    class-methods concat
      importing
        !it_return       type bapiret2_t
        !iv_separator    type string default ` / `
      returning
        value(rv_text)   type string.
endclass.


class zcl_au_message implementation.
  method text_from_t100.
    message id iv_msgid type 'I' number iv_msgno
      with iv_v1 iv_v2 iv_v3 iv_v4
      into rv_text.
  endmethod.


  method text_from_sy.
    message id sy-msgid type 'I' number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      into rv_text.
  endmethod.


  method bapiret.
    rs_return = value bapiret2( type       = iv_type
                                id         = iv_msgid
                                number     = iv_msgno
                                message_v1 = iv_v1
                                message_v2 = iv_v2
                                message_v3 = iv_v3
                                message_v4 = iv_v4
                                message    = text_from_t100( iv_msgid = iv_msgid
                                                             iv_msgno = iv_msgno
                                                             iv_v1    = iv_v1
                                                             iv_v2    = iv_v2
                                                             iv_v3    = iv_v3
                                                             iv_v4    = iv_v4 ) ).
  endmethod.


  method bapiret_from_sy.
    rs_return = bapiret( iv_type  = sy-msgty
                         iv_msgid = sy-msgid
                         iv_msgno = sy-msgno
                         iv_v1    = sy-msgv1
                         iv_v2    = sy-msgv2
                         iv_v3    = sy-msgv3
                         iv_v4    = sy-msgv4 ).
  endmethod.


  method has_errors.
    rv_result = xsdbool( line_exists( it_return[ type = 'E' ] )
                      or line_exists( it_return[ type = 'A' ] )
                      or line_exists( it_return[ type = 'X' ] ) ).
  endmethod.


  method concat.
    loop at it_return into data(ls_return).
      rv_text = cond #( when rv_text is initial
                        then ls_return-message
                        else rv_text && iv_separator && ls_return-message ).
    endloop.
  endmethod.
endclass.
