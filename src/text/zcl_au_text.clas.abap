class zcl_au_text definition
  public
  final
  create public.

  public section.
    "! Read an SAPscript long text (STXH/STXL) as one string. A one-call wrapper
    "! around READ_TEXT that hides the TLINE table and the 8 exceptions, and
    "! returns an empty string when the text simply does not exist.
    class-methods read
      importing
        !iv_id         type thead-tdid
        !iv_name       type thead-tdname
        !iv_object     type thead-tdobject
        !iv_language   type thead-tdspras default sy-langu
      returning
        value(rv_text) type string
      raising
        zcx_au_error.

    "! Save (create or replace) an SAPscript long text from a string. Lines are
    "! split at newline; each line becomes a new paragraph ('*').
    class-methods save
      importing
        !iv_id       type thead-tdid
        !iv_name     type thead-tdname
        !iv_object   type thead-tdobject
        !iv_text     type string
        !iv_language type thead-tdspras default sy-langu
        !iv_commit   type abap_bool default abap_true
      raising
        zcx_au_error.
endclass.


class zcl_au_text implementation.
  method read.
    data lt_lines type standard table of tline.

    call function 'READ_TEXT'
      exporting
        id                      = iv_id
        language                = iv_language
        name                    = iv_name
        object                  = iv_object
      tables
        lines                   = lt_lines
      exceptions
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        others                  = 8.

    if sy-subrc = 4.
      return.                            " no such text -> empty string
    elseif sy-subrc <> 0.
      zcx_au_error=>raise( |READ_TEXT failed for { iv_object } { iv_id } { iv_name } (rc={ sy-subrc })| ) ##NO_TEXT.
    endif.

    loop at lt_lines into data(ls_line).
      rv_text = cond #( when rv_text is initial
                        then conv string( ls_line-tdline )
                        else rv_text && cl_abap_char_utilities=>newline && ls_line-tdline ).
    endloop.
  endmethod.


  method save.
    data lt_lines type standard table of tline.

    split iv_text at cl_abap_char_utilities=>newline into table data(lt_strings).
    loop at lt_strings into data(lv_string).
      append value tline( tdformat = '*'
                          tdline   = lv_string ) to lt_lines.
    endloop.

    data(ls_header) = value thead( tdid     = iv_id
                                   tdname   = iv_name
                                   tdobject = iv_object
                                   tdspras  = iv_language ).

    call function 'SAVE_TEXT'
      exporting
        header          = ls_header
        savemode_direct = abap_true
      tables
        lines           = lt_lines
      exceptions
        id              = 1
        language        = 2
        name            = 3
        object          = 4
        others          = 5.

    if sy-subrc <> 0.
      zcx_au_error=>raise( |SAVE_TEXT failed for { iv_object } { iv_id } { iv_name } (rc={ sy-subrc })| ) ##NO_TEXT.
    endif.

    if iv_commit = abap_true.
      commit work.
    endif.
  endmethod.
endclass.
