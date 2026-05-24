# Hashing — `ZCL_AU_HASH`

> MD5 / SHA-1 / SHA-256 (and any digest the kernel supports) as a lower-case hex
> string. For checksums, idempotency keys and change detection.

## Objects & dependencies
- `ZCL_AU_HASH` — stateless utility (`class-methods`).
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module),
  `CL_ABAP_MESSAGE_DIGEST` + `CL_ABAP_CONV_CODEPAGE`.

> ⚠️ Not a password/security primitive — for HMAC/signatures use `CL_ABAP_HMAC`,
> and on ABAP Cloud prefer `XCO_CP` hashing.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/hash/zcl_au_hash.clas.abap` (+ `.clas.xml`, optionally
   `.clas.testclasses.abap`).
3. Assign both objects to your TR.

## How to use

```abap
zcl_au_hash=>md5( `abc` ).      " 900150983cd24fb0d6963f7d28e17f72
zcl_au_hash=>sha256( `abc` ).   " ba7816bf...20015ad

" change detection: hash a serialized record
data(lv_fingerprint) = zcl_au_hash=>sha256( zcl_au_json=>serialize( ls_record ) ).

" raw bytes / other algorithms
data(lv) = zcl_au_hash=>hash_binary( iv_data = lv_xstring iv_algorithm = 'SHA512' ).
```

## API
| Method | Purpose |
|--------|---------|
| `md5` / `sha1` / `sha256` | hex digest of a string (UTF-8) |
| `hash_binary( iv_data, iv_algorithm )` | hex digest of raw bytes, any algorithm |

Strings are encoded as UTF-8 before hashing, so digests match standard tools
(`echo -n abc \| sha256sum`).

## Tests
`zcl_au_hash.clas.testclasses.abap` checks the published MD5/SHA-1/SHA-256
vectors for `"abc"`.

## Extending
Add HMAC (`CL_ABAP_HMAC`) for signed payloads, or a streaming digest for very
large inputs.
