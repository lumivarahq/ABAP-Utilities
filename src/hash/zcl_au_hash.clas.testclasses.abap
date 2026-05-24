class ltcl_hash definition final
  for testing
  duration short
  risk level harmless.

  private section.
    methods md5_abc    for testing.
    methods sha1_abc   for testing.
    methods sha256_abc for testing.
endclass.


class ltcl_hash implementation.
  method md5_abc.
    cl_abap_unit_assert=>assert_equals(
      exp = `900150983cd24fb0d6963f7d28e17f72`
      act = zcl_au_hash=>md5( `abc` ) ).
  endmethod.

  method sha1_abc.
    cl_abap_unit_assert=>assert_equals(
      exp = `a9993e364706816aba3e25717850c26c9cd0d89d`
      act = zcl_au_hash=>sha1( `abc` ) ).
  endmethod.

  method sha256_abc.
    cl_abap_unit_assert=>assert_equals(
      exp = `ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad`
      act = zcl_au_hash=>sha256( `abc` ) ).
  endmethod.
endclass.
