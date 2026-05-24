# GUID / UUID — `ZCL_AU_GUID`

> One-liners for the three UUID representations you actually use in ABAP.

## Objects & dependencies
- `ZCL_AU_GUID` — stateless utility (`class-methods`), wraps the released
  `CL_SYSTEM_UUID`.
- Depends on: **nothing** in this repo (propagates the standard `CX_UUID_ERROR`)
  → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `src/guid/zcl_au_guid.clas.abap` (+ `.clas.xml`) into a class in your
package and assign it to your TR.

## How to use

```abap
try.
    data(lv_c32) = zcl_au_guid=>c32( ).   "32-char upper-case hex
    data(lv_c22) = zcl_au_guid=>c22( ).   "22-char (base64-like)
    data(lv_x16) = zcl_au_guid=>x16( ).   "RAW16 — for GUID key fields
  catch cx_uuid_error into data(lx).
    " extremely rare; handle or re-raise
endtry.
```

## API
| Method | Returns | Typical use |
|--------|---------|-------------|
| `c32` | `SYSUUID_C32` | external ids, logs, correlation ids |
| `c22` | `SYSUUID_C22` | compact ids |
| `x16` | `SYSUUID_X16` | RAW16 primary keys (e.g. RAP key fields) |

## Tests
Trivial wrappers around a released API — covered implicitly. Add a uniqueness
sanity test if you extend the class.

## Extending
Add formatting helpers (e.g. dashed `8-4-4-4-12` form) or conversion between the
representations using `CL_SYSTEM_UUID` instance methods.
