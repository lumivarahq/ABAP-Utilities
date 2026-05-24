# Base64 — `ZCL_AU_BASE64`

> Base64 encode/decode for bytes and strings, using released APIs.

## Objects & dependencies
- `ZCL_AU_BASE64` — stateless utility (`class-methods`).
- Depends on: **nothing** in this repo (uses `CL_WEB_HTTP_UTILITY` +
  `CL_ABAP_CONV_CODEPAGE`) → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `src/base64/zcl_au_base64.clas.abap` (+ `.clas.xml`, optionally
`.clas.testclasses.abap`) into a class in your package and assign it to your TR.

## How to use

```abap
zcl_au_base64=>encode_string( `abc` ).            " YWJj
zcl_au_base64=>decode_to_string( `SGVsbG8=` ).    " Hello

" raw bytes (e.g. a PDF xstring for an email/HTTP payload)
data(lv_b64) = zcl_au_base64=>encode( lv_pdf_xstring ).
data(lv_pdf) = zcl_au_base64=>decode( lv_b64 ).
```

## API
| Method | Purpose |
|--------|---------|
| `encode` / `decode` | `xstring` ⇄ base64 string |
| `encode_string` / `decode_to_string` | UTF-8 string ⇄ base64 string |

## Tests
`zcl_au_base64.clas.testclasses.abap` checks known vectors (`abc`→`YWJj`,
`Hello`→`SGVsbG8=`), a Unicode string round-trip and a binary round-trip.

## Extending
Add URL-safe base64 (`-`/`_`) or chunked/line-wrapped output if you need MIME
formatting.
