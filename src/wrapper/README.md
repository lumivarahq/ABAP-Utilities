# Released-wrapper generator — `ZCL_AU_WRAP_GEN`

> Scaffold a Clean Core "released wrapper" facade around a non-released API, so
> only one object needs an ATC exemption and callers depend on a stable, released
> signature. (Implements the wrapper pattern from the
> [Clean Core & ATC Cookbook](../../docs/clean-core-atc-cookbook.md) §3.)

## Objects & dependencies
- `ZCL_AU_WRAP_GEN` — generates ABAP source as a string (RTTI-free string build).
- Depends on: **`ZCX_AU_ERROR`** → **ABAP Cloud safe**.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/wrapper/zcl_au_wrap_gen.clas.abap` (+ `.clas.xml`).
3. Assign both to your TR.

## How to use

```abap
data(lv_source) = zcl_au_wrap_gen=>facade(
  iv_class_name  = `ZCL_PRICING_FACADE`
  iv_method_name = `get_price`
  iv_target      = `PRICING_DETERMINE` ).
" -> paste lv_source into a new global class, then adapt the signature and the
"    single call inside the method.
```

Generated skeleton (abbreviated):
```abap
"! Released facade around PRICING_DETERMINE
"! Clean Core wrapper: the only ATC-exempted call ... lives here ...
class ZCL_PRICING_FACADE definition public final create public.
  public section.
    class-methods get_price
      importing !iv_input type string
      returning value(rv_output) type string
      raising   zcx_au_error.
endclass.
class ZCL_PRICING_FACADE implementation.
  method get_price.
    " TODO ... call function 'PRICING_DETERMINE' ...
  endmethod.
endclass.
```

## API
| Method | Purpose |
|--------|---------|
| `facade( iv_class_name, iv_method_name, iv_target, iv_description )` | the wrapper class source |

## Tests
`zcl_au_wrap_gen.clas.testclasses.abap` checks the generated source contains the
class, method, target reference and the single exception type, and that missing
arguments raise.

## Extending
Read the target's real signature via RTTI / function-module metadata
(`FUNCTION_IMPORT_INTERFACE`) and emit a matching `importing`/`exporting` list
instead of the generic `iv_input`/`rv_output`.
