class zcl_au_feature_flag definition
  public
  final
  create private.

  public section.
    interfaces zif_au_feature_flag.

    "! Build an in-memory flag set from a list of enabled feature names. Seed it
    "! at the composition root from whatever source you trust - TVARVC via
    "! ZCL_AU_CONFIG, a Z customizing table, or literals in DEV - then inject the
    "! ZIF_AU_FEATURE_FLAG into your code. Matching is case-insensitive.
    class-methods from_enabled
      importing
        !it_features   type string_table
      returning
        value(ro_flag) type ref to zif_au_feature_flag.

  private section.
    " hashed for O(1) lookups; the line itself is the key
    data mt_enabled type hashed table of string with unique key table_line.

    methods constructor
      importing
        !it_features type string_table.
endclass.


class zcl_au_feature_flag implementation.
  method from_enabled.
    ro_flag = new zcl_au_feature_flag( it_features ).
  endmethod.


  method constructor.
    loop at it_features into data(lv_feature).
      " duplicates simply set sy-subrc = 4 on a unique hashed table (no dump)
      insert to_upper( lv_feature ) into table mt_enabled.
    endloop.
  endmethod.


  method zif_au_feature_flag~is_enabled.
    rv_enabled = xsdbool( line_exists( mt_enabled[ table_line = to_upper( iv_feature ) ] ) ).
  endmethod.
endclass.
