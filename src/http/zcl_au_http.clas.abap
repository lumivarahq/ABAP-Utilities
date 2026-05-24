class zcl_au_http definition
  public
  final
  create public.

  public section.
    types:
      begin of ty_header,
        name  type string,
        value type string,
      end of ty_header,
      tt_header type standard table of ty_header with default key,
      begin of ty_response,
        code   type i,
        reason type string,
        body   type string,
      end of ty_response.

    "! HTTP GET. Returns status code, reason and response body.
    class-methods get
      importing
        !iv_url            type string
        !it_headers        type tt_header optional
      returning
        value(rs_response) type ty_response
      raising
        zcx_au_error.

    "! HTTP POST with a string body (set the Content-Type via it_headers).
    class-methods post
      importing
        !iv_url            type string
        !iv_body           type string
        !it_headers        type tt_header optional
      returning
        value(rs_response) type ty_response
      raising
        zcx_au_error.

    "! Generic request: iv_method = GET | POST | PUT | DELETE | PATCH.
    class-methods request
      importing
        !iv_url            type string
        !iv_method         type string default 'GET'
        !iv_body           type string optional
        !it_headers        type tt_header optional
      returning
        value(rs_response) type ty_response
      raising
        zcx_au_error.
endclass.


class zcl_au_http implementation.
  method get.
    rs_response = request( iv_url     = iv_url
                           iv_method  = 'GET'
                           it_headers = it_headers ).
  endmethod.


  method post.
    rs_response = request( iv_url     = iv_url
                           iv_method  = 'POST'
                           iv_body    = iv_body
                           it_headers = it_headers ).
  endmethod.


  method request.
    try.
        data(lo_destination) = cl_http_destination_provider=>create_by_url( iv_url ).
        data(lo_client)      = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).

        data(lo_request) = lo_client->get_http_request( ).
        loop at it_headers into data(ls_header).
          lo_request->set_header_field( i_name  = ls_header-name
                                        i_value = ls_header-value ).
        endloop.
        if iv_body is not initial.
          lo_request->set_text( iv_body ).
        endif.

        data(lo_response) = lo_client->execute(
          cond #( when iv_method = 'POST'   then if_web_http_client=>post
                  when iv_method = 'PUT'    then if_web_http_client=>put
                  when iv_method = 'DELETE' then if_web_http_client=>delete
                  when iv_method = 'PATCH'  then if_web_http_client=>patch
                  else                           if_web_http_client=>get ) ).

        data(ls_status) = lo_response->get_status( ).
        rs_response = value #( code   = ls_status-code
                               reason = ls_status-reason
                               body   = lo_response->get_text( ) ).

        lo_client->close( ).

      catch cx_root into data(lx_error).
        zcx_au_error=>raise( text     = lx_error->get_text( )
                             previous = lx_error ).
    endtry.
  endmethod.
endclass.
