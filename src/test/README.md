# Test data — `ZCL_AU_TEST_DATA`

> Random primitives for ABAP Unit tests: ints, strings, dates, booleans.

## Objects & dependencies
- `ZCL_AU_TEST_DATA` — stateless utility (`class-methods`), wraps the released
  `CL_ABAP_RANDOM*`.
- Depends on: **nothing** → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `src/test/zcl_au_test_data.clas.abap` (+ `.clas.xml`, optionally
`.clas.testclasses.abap`) into a class in your package and assign it to your TR.
(Typically you would put this in a test-only package.)

## How to use

```abap
data(lv_i)   = zcl_au_test_data=>random_int( iv_min = 1 iv_max = 100 ).
data(lv_str) = zcl_au_test_data=>random_string( 16 ).
data(lv_dat) = zcl_au_test_data=>random_date( iv_from = '20260101' iv_to = '20261231' ).
data(lv_b)   = zcl_au_test_data=>random_bool( ).

" Build a randomised fixture row
data(ls_customer) = value ty_customer( id   = zcl_au_test_data=>random_int( )
                                       name = zcl_au_test_data=>random_string( 20 ) ).
```

## API
| Method | Returns |
|--------|---------|
| `random_int( iv_min, iv_max )` | `i` in `[min, max]` |
| `random_string( iv_length )` | alphanumeric `string` |
| `random_date( iv_from, iv_to )` | `d` in `[from, to]` |
| `random_bool( )` | `abap_bool` |

## Tests
`zcl_au_test_data.clas.testclasses.abap` asserts that generated values fall
within the requested bounds and lengths.

## Extending
Add domain builders (`random_email`, `random_iban`) or a fluent fixture builder.
For test data sourced from spreadsheets or to mock database reads, use
[mockup_loader](https://github.com/sbcgua/mockup_loader) and the standard
ABAP Unit **test double** framework (`CL_ABAP_TESTDOUBLE`, OSQL/CDS test doubles).
