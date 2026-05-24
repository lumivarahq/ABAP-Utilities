class ltcl_message definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods detects_errors  for testing.
    methods no_errors       for testing.
    methods concat_texts    for testing.
endclass.


class ltcl_message implementation.
  method detects_errors.
    data(lt) = value bapiret2_t( ( type = 'S' message = `ok` )
                                 ( type = 'E' message = `boom` ) ).
    cl_abap_unit_assert=>assert_true( zcl_au_message=>has_errors( lt ) ).
  endmethod.

  method no_errors.
    data(lt) = value bapiret2_t( ( type = 'S' message = `ok` )
                                 ( type = 'W' message = `careful` ) ).
    cl_abap_unit_assert=>assert_false( zcl_au_message=>has_errors( lt ) ).
  endmethod.

  method concat_texts.
    data(lt) = value bapiret2_t( ( message = `a` )
                                 ( message = `b` )
                                 ( message = `c` ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = `a / b / c`
      act = zcl_au_message=>concat( lt ) ).
  endmethod.
endclass.
