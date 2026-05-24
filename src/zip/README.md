# ZIP — `ZCL_AU_ZIP`

> Create and read `.zip` archives in memory — a thin, fluent face over
> `CL_ABAP_ZIP`.

## Objects & dependencies
- `ZCL_AU_ZIP` — instance builder/reader.
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module) and
  `CL_ABAP_ZIP`.

> ⚠️ **ABAP Cloud:** `CL_ABAP_ZIP` may not be released; use `XCO_CP` archive
> handling there. The shape below ports directly.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/zip/zcl_au_zip.clas.abap` (+ `.clas.xml`).
3. Assign both objects to your TR.

## How to use

```abap
" build an archive (bytes in, zip xstring out) - pair with ZCL_AU_BASE64 / email
data(lv_zip) = new zcl_au_zip( )->add( iv_name = 'orders.csv'  iv_content = lv_csv_x
                              )->add( iv_name = 'invoice.pdf' iv_content = lv_pdf_x
                              )->save( ).

" read an archive
data(lo_zip)  = zcl_au_zip=>load( lv_zip ).
data(lt_names) = lo_zip->names( ).            " ( orders.csv ) ( invoice.pdf )
data(lv_csv)   = lo_zip->get( 'orders.csv' ).
```

## API
| Method | Purpose |
|--------|---------|
| `add( iv_name, iv_content )` | add an entry (chainable) |
| `save( )` | serialize to a `.zip` xstring |
| `load( iv_zip )` | open an existing archive |
| `get( iv_name )` | extract one entry |
| `names( )` | list entry names |

Content is raw bytes (`xstring`). For text, convert with `cl_abap_conv_codepage`
or [`ZCL_AU_BASE64`](../base64/README.md) helpers.

## Tests
Round-trips are unit-testable on systems where `CL_ABAP_ZIP` is available; the
shipped module relies on activation verification.

## Extending
Add `add_string( name, text )` / `get_string( name )` convenience overloads, or
streaming for very large archives.
