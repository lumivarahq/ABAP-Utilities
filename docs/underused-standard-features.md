# Underused standard ABAP that pays off

Released, standard capabilities that many teams never reach for. All are
cloud-friendly unless noted.

> Sources: [Modern RegEx / PCRE in ABAP (SAP Community)](https://community.sap.com/t5/application-development-and-automation-blog-posts/modern-regular-expressions-in-abap-part-1-introducing-pcre/ba-p/13463483) ·
> [SAP ABAP cheat sheets (SAP-samples)](https://github.com/SAP-samples/abap-cheat-sheets)

## 1. PCRE regular expressions — `CL_ABAP_REGEX` / `CL_ABAP_MATCHER`
Perl-compatible regex in the kernel; far more capable than the old POSIX engine,
and available as SQL functions too.
```abap
data(lo_regex)   = cl_abap_regex=>create_pcre( pattern = `(\d{4})-(\d{2})-(\d{2})` ).
data(lo_matcher) = lo_regex->create_matcher( text = `Due 2026-05-24.` ).
if lo_matcher->match( ).
  data(lv_year) = lo_matcher->get_submatch( 1 ).
endif.
" built-ins: matches( ), replace( ... pcre = ... ), find/count( ... pcre = ... )
" ABAP SQL: like_regexpr, replace_regexpr, occurrences_regexpr
```

## 2. CORRESPONDING with mapping / except
Field-name-based moves with control over mapping, defaults and dropped fields —
replaces dozens of `MOVE-CORRESPONDING` + manual moves.
```abap
data(ls_out) = corresponding ty_out( ls_in mapping id = guid except notes ).
" deep / table mapping, keeping existing values:  ... base ( ls_existing ) ...
```

## 3. Meshes — `TYPES BEGIN OF MESH`
Navigate associations between internal tables without writing the joins.
```abap
types: begin of mesh m_data,
         orders type tt_orders association to_items via [ id = order_id ],
         items  type tt_items,
       end of mesh m_data.
" data(lt_items_for_order) = ls_mesh-orders\to_items[ ls_order ].
```

## 4. Enumerations — `TYPES BEGIN OF ENUM`
Type-safe constants instead of magic chars.
```abap
types: begin of enum status, open, in_process, done, end of enum status.
data(lv) = status-in_process.   " only valid enum values compile
```

## 5. RTTI / RTTC — runtime types & dynamic data
`cl_abap_typedescr=>describe_by_data( )`, `cl_abap_structdescr`, dynamic
`CREATE DATA ... TYPE HANDLE`. (This repo's `ZCL_AU_CSV` uses it to handle *any*
table.) Great for generic serializers, comparators, framework code.

## 6. `cl_abap_conv_codepage` — encoding done right
```abap
data(lv_xstr) = cl_abap_conv_codepage=>create_out( codepage = `UTF-8` )->convert( lv_string ).
data(lv_str)  = cl_abap_conv_codepage=>create_in(  codepage = `UTF-8` )->convert( lv_xstr ).
```

## 7. Simple Transformations — `CALL TRANSFORMATION`
Fast, declarative XML/JSON (de)serialization via ST programs or `id` transform —
no manual parsing.

## 8. ABAP Unit doubles — `CL_ABAP_TESTDOUBLE`, OSQL/CDS test doubles
Mock interfaces and *database access* in tests:
`cl_osql_test_environment` lets you feed fake rows to a `SELECT`, so DB logic is
unit-testable without real data.

## 9. Checkpoint groups, `ASSERT`, `LOG-POINT` (transaction SAAB)
Production-safe assertions and conditional breakpoints/logs you can switch on per
user/system without changing code.

## 10. `CL_DEMO_OUTPUT` / `cl_demo_output=>display( any_data )`
Instant, structured display of any variable/table while developing — beats
`WRITE:` for nested data.

## 11. String templates — formatting options
```abap
|{ lv_amount number = user }|         " user-formatted number
|{ lv_date date = iso }|              " 2026-05-24
|{ lv_ts timestamp = iso timezone = `UTC` }|
|{ lv_text width = 20 pad = '.' align = left }|
```

## 12. XCO (ABAP Cloud) — `xco_cp`, `xco_cp_json`, `xco_cp_time`
The released, fluent standard library for JSON, time, strings, regex,
repository access — the cloud-native toolbox.
