# JSON — `ZCL_AU_JSON`

> Two-line serialize / deserialize convenience over `/UI2/CL_JSON`.

## Objects & dependencies
- `ZCL_AU_JSON` — stateless utility (`class-methods`).
- Depends on: **`/UI2/CL_JSON`** (shipped on most NetWeaver 7.40+ stacks).

> ⚠️ **ABAP Cloud / clean core:** `/UI2/CL_JSON` may not be released in your
> target. Prefer [**ajson**](https://github.com/sbcgua/ajson) (cloud-ready,
> supports a mutable JSON document, filtering and mapping). This wrapper exists
> only to remove boilerplate when `/UI2/CL_JSON` is available; swap the two
> method bodies to delegate to ajson if you standardise on it.

## Install (cherry-pick)
Copy `src/json/zcl_au_json.clas.abap` (+ `.clas.xml`) into a class in your
package and assign it to your TR. Ensure `/UI2/CL_JSON` exists in the system.

## How to use

```abap
types: begin of ty_order,
         order_id type string,
         amount   type decfloat34,
       end of ty_order.
data(ls) = value ty_order( order_id = `4711` amount = '99.90' ).

" ABAP -> JSON (camelCase keys, empty fields dropped)
data(lv_json) = zcl_au_json=>serialize( ls ).
" {"orderId":"4711","amount":99.9}

" JSON -> ABAP
data ls_back type ty_order.
zcl_au_json=>deserialize( exporting iv_json = lv_json
                          changing  cs_data = ls_back ).
```

## API
| Method | Purpose |
|--------|---------|
| `serialize( iv_data, iv_compress, iv_camelcase )` | ABAP ➜ JSON string |
| `deserialize( iv_json, iv_camelcase, cs_data )` | JSON string ➜ ABAP |

## Tests
Not unit-tested here because the output depends on the installed `/UI2/CL_JSON`
version. Add a project test once you pin your JSON implementation.

## Extending
Add `serialize_pretty`, type-name mapping, or date handling. If you need more
than trivial mapping, adopt **ajson** and make this class a thin facade over it.
