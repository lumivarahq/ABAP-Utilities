class zcl_au_email definition
  public
  final
  create private.

  public section.
    "! Fluent e-mail builder over BCS (CL_BCS). Example:
    "!   zcl_au_email=>create(
    "!     )->subject( `Report ready`
    "!     )->to( `jane@example.com`
    "!     )->body_html( `<h1>Done</h1>`
    "!     )->attach_text( iv_filename = `data.csv` iv_content = lv_csv iv_type = 'CSV'
    "!     )->send( ).
    class-methods create
      returning
        value(ro_email) type ref to zcl_au_email.

    methods subject
      importing !iv_subject     type string
      returning value(ro_email) type ref to zcl_au_email.

    "! Optional explicit sender (defaults to the current user if omitted).
    methods from
      importing !iv_address     type string
      returning value(ro_email) type ref to zcl_au_email.

    methods to
      importing !iv_address     type string
      returning value(ro_email) type ref to zcl_au_email.

    methods cc
      importing !iv_address     type string
      returning value(ro_email) type ref to zcl_au_email.

    methods body_text
      importing !iv_text        type string
      returning value(ro_email) type ref to zcl_au_email.

    methods body_html
      importing !iv_html        type string
      returning value(ro_email) type ref to zcl_au_email.

    "! Add a text attachment (e.g. CSV, TXT, XML).
    methods attach_text
      importing !iv_filename    type string
                !iv_content     type string
                !iv_type        type soodk-objtp default 'TXT'
      returning value(ro_email) type ref to zcl_au_email.

    "! Add a binary attachment (e.g. PDF, XLSX).
    methods attach_binary
      importing !iv_filename    type string
                !iv_content     type xstring
                !iv_type        type soodk-objtp default 'BIN'
      returning value(ro_email) type ref to zcl_au_email.

    "! Build and send the mail. Returns abap_true if accepted for all recipients.
    methods send
      importing !iv_commit       type abap_bool default abap_true
      returning value(rv_sent)   type abap_bool
      raising   zcx_au_error.

  private section.
    constants: c_to type c length 2 value 'TO',
               c_cc type c length 2 value 'CC'.

    types:
      begin of ty_recipient,
        address type string,
        kind    type c length 2,
      end of ty_recipient,
      begin of ty_attachment,
        filename  type string,
        type      type soodk-objtp,
        is_binary type abap_bool,
        text      type string,
        bin       type xstring,
      end of ty_attachment.

    data mv_subject     type string.
    data mv_from        type string.
    data mv_body        type string.
    data mv_is_html     type abap_bool.
    data mt_recipients  type standard table of ty_recipient with default key.
    data mt_attachments type standard table of ty_attachment with default key.

    methods to_soli
      importing !iv_string     type string
      returning value(rt_soli) type soli_tab.
endclass.


class zcl_au_email implementation.
  method create.
    ro_email = new zcl_au_email( ).
  endmethod.


  method subject.
    mv_subject = iv_subject.
    ro_email = me.
  endmethod.


  method from.
    mv_from = iv_address.
    ro_email = me.
  endmethod.


  method to.
    append value #( address = iv_address kind = c_to ) to mt_recipients.
    ro_email = me.
  endmethod.


  method cc.
    append value #( address = iv_address kind = c_cc ) to mt_recipients.
    ro_email = me.
  endmethod.


  method body_text.
    mv_body    = iv_text.
    mv_is_html = abap_false.
    ro_email   = me.
  endmethod.


  method body_html.
    mv_body    = iv_html.
    mv_is_html = abap_true.
    ro_email   = me.
  endmethod.


  method attach_text.
    append value #( filename  = iv_filename
                    type      = iv_type
                    is_binary = abap_false
                    text      = iv_content ) to mt_attachments.
    ro_email = me.
  endmethod.


  method attach_binary.
    append value #( filename  = iv_filename
                    type      = iv_type
                    is_binary = abap_true
                    bin       = iv_content ) to mt_attachments.
    ro_email = me.
  endmethod.


  method to_soli.
    data(lv_len) = strlen( iv_string ).
    data(lv_off) = 0.
    while lv_off < lv_len.
      data(lv_chunk) = nmin( val1 = 255 val2 = lv_len - lv_off ).
      append value soli( line = substring( val = iv_string
                                           off = lv_off
                                           len = lv_chunk ) ) to rt_soli.
      lv_off = lv_off + lv_chunk.
    endwhile.
    if rt_soli is initial.
      append value soli( ) to rt_soli.
    endif.
  endmethod.


  method send.
    try.
        data(lo_send) = cl_bcs=>create_persistent( ).

        data(lo_doc) = cl_document_bcs=>create_document(
          i_type    = cond #( when mv_is_html = abap_true then 'HTM' else 'RAW' )
          i_text    = to_soli( mv_body )
          i_subject = conv so_obj_des( mv_subject ) ).

        loop at mt_attachments into data(ls_att).
          if ls_att-is_binary = abap_true.
            lo_doc->add_attachment(
              i_attachment_type    = ls_att-type
              i_attachment_subject = conv sood-objdes( ls_att-filename )
              i_att_content_hex    = cl_bcs_convert=>xstring_to_solix( ls_att-bin ) ).
          else.
            lo_doc->add_attachment(
              i_attachment_type    = ls_att-type
              i_attachment_subject = conv sood-objdes( ls_att-filename )
              i_att_content_text   = to_soli( ls_att-text ) ).
          endif.
        endloop.

        lo_send->set_document( lo_doc ).

        if mv_from is not initial.
          lo_send->set_sender(
            cl_cam_address_bcs=>create_internet_address( conv ad_smtpadr( mv_from ) ) ).
        endif.

        loop at mt_recipients into data(ls_rcpt).
          lo_send->add_recipient(
            i_recipient = cl_cam_address_bcs=>create_internet_address( conv ad_smtpadr( ls_rcpt-address ) )
            i_copy      = xsdbool( ls_rcpt-kind = c_cc ) ).
        endloop.

        lo_send->set_send_immediately( abap_true ).
        rv_sent = lo_send->send( i_with_error_screen = abap_true ).

        if iv_commit = abap_true.
          commit work.
        endif.

      catch cx_bcs into data(lx_bcs).
        zcx_au_error=>raise( text     = lx_bcs->get_text( )
                             previous = lx_bcs ).
    endtry.
  endmethod.
endclass.
