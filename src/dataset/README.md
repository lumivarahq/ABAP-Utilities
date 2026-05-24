# App-server files — `ZCL_AU_DATASET`

> `OPEN DATASET` done right: UTF-8 text and binary read/write on the application
> server, with the encoding/`CLOSE`/error handling taken care of.

## Objects & dependencies
- `ZCL_AU_DATASET` — stateless utility (`class-methods`).
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module).

> ⚠️ **ABAP Cloud:** `OPEN DATASET` is not allowed. For cloud, exchange files via
> the application's OData/HTTP layer or released file APIs. This module targets
> classic / on-premise application-server file handling.
>
> ℹ️ The number-one `OPEN DATASET` bug is wrong/forgotten encoding (garbled
> umlauts). These helpers always use `ENCODING UTF-8 WITH SMART LINEFEED`.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/dataset/zcl_au_dataset.clas.abap` (+ `.clas.xml`).
3. Assign both objects to your TR.

## How to use

```abap
" write / read a UTF-8 text file
zcl_au_dataset=>write_text( iv_path    = '/tmp/orders.csv'
                            iv_content = lv_csv ).
data(lv_text) = zcl_au_dataset=>read_text( '/tmp/orders.csv' ).

" binary (e.g. a PDF you generated)
zcl_au_dataset=>write_binary( iv_path = '/tmp/doc.pdf' iv_content = lv_pdf ).
data(lv_bin) = zcl_au_dataset=>read_binary( '/tmp/doc.pdf' ).

if zcl_au_dataset=>exists( '/tmp/doc.pdf' ).
  zcl_au_dataset=>delete( '/tmp/doc.pdf' ).
endif.
```

## API
| Method | Purpose |
|--------|---------|
| `read_text` / `write_text` | UTF-8 text file as one string |
| `read_binary` / `write_binary` | raw bytes (`xstring`) |
| `exists` / `delete` | existence check / delete |

## Tests
File I/O depends on the server file system and authorizations (`S_DATASET`), so
verify by activation + a real read/write rather than ABAP Unit.

## Extending
For non-UTF-8 files use `OPEN DATASET ... IN LEGACY TEXT MODE CODE PAGE <cp>` (or
`cl_abap_conv_codepage` on a binary read). Add append mode, or directory listing
via `EPS_GET_DIRECTORY_LISTING`.
