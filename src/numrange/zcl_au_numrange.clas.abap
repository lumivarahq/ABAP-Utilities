class zcl_au_numrange definition
  public
  final
  create public.

  public section.
    "! Draw the next number from a number range object (transaction SNRO / SNUM).
    "! Wraps NUMBER_GET_NEXT and raises ZCX_AU_ERROR on any failure.
    "! @parameter iv_object    | number range object (SNRO)
    "! @parameter iv_range     | interval number (NRRANGENR)
    "! @parameter iv_subobject | sub-object, if the object is defined with one
    "! @parameter iv_toyear    | year, for year-dependent ranges (YYYY)
    class-methods next
      importing
        !iv_object       type inri-object
        !iv_range        type inri-nrrangenr
        !iv_subobject    type inri-subobject optional
        !iv_toyear       type inri-toyear optional
      returning
        value(rv_number) type string
      raising
        zcx_au_error.

    "! Draw a block of iv_quantity numbers at once; returns the first number
    "! and the count actually returned (ev_quantity).
    class-methods next_block
      importing
        !iv_object       type inri-object
        !iv_range        type inri-nrrangenr
        !iv_quantity     type i
        !iv_subobject    type inri-subobject optional
        !iv_toyear       type inri-toyear optional
      exporting
        !ev_first_number type string
        !ev_quantity     type i
      raising
        zcx_au_error.
endclass.


class zcl_au_numrange implementation.
  method next.
    next_block(
      exporting
        iv_object       = iv_object
        iv_range        = iv_range
        iv_quantity     = 1
        iv_subobject    = iv_subobject
        iv_toyear       = iv_toyear
      importing
        ev_first_number = rv_number ).
  endmethod.


  method next_block.
    data lv_number   type char40.
    data lv_returned type inri-quantity.

    call function 'NUMBER_GET_NEXT'
      exporting
        nr_range_nr             = iv_range
        object                  = iv_object
        quantity                = conv inri-quantity( iv_quantity )
        subobject               = iv_subobject
        toyear                  = iv_toyear
      importing
        number                  = lv_number
        quantity                = lv_returned
      exceptions
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        others                  = 8.

    if sy-subrc <> 0.
      zcx_au_error=>raise(
        |NUMBER_GET_NEXT failed for object { iv_object } range { iv_range } (rc={ sy-subrc })| ) ##NO_TEXT.
    endif.

    ev_first_number = condense( lv_number ).
    ev_quantity     = lv_returned.
  endmethod.
endclass.
