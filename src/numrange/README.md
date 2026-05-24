# Number range — `ZCL_AU_NUMRANGE`

> Draw the next number from a number range object without re-typing the
> `NUMBER_GET_NEXT` boilerplate (and its seven exceptions) every time.

## Objects & dependencies
- `ZCL_AU_NUMRANGE` — stateless utility (`class-methods`).
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module) and the
  classic FM **`NUMBER_GET_NEXT`**.

> ⚠️ **ABAP Cloud:** `NUMBER_GET_NEXT` is not released. On ABAP Cloud use the
> released number range API class **`CL_NUMBERRANGE_RUNTIME`** (`=>number_get`);
> the method shape here maps directly onto it.
>
> ℹ️ Define the object + intervals first in transaction **SNRO** / **SNUM**.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/numrange/zcl_au_numrange.clas.abap` (+ `.clas.xml`).
3. Assign both objects to your TR.

## How to use

```abap
" Single number
data(lv_id) = zcl_au_numrange=>next( iv_object = 'ZORDER'
                                     iv_range  = '01' ).

" Year-dependent range with a sub-object
data(lv_doc) = zcl_au_numrange=>next( iv_object    = 'ZINVOICE'
                                      iv_range     = '01'
                                      iv_subobject = conv #( sy-mandt )
                                      iv_toyear    = '2026' ).

" A block of numbers in one round-trip (high-volume inserts)
data lv_first type string.
data lv_count type i.
zcl_au_numrange=>next_block(
  exporting iv_object   = 'ZORDER'
            iv_range    = '01'
            iv_quantity = 100
  importing ev_first_number = lv_first
            ev_quantity     = lv_count ).
```

## API
| Method | Purpose |
|--------|---------|
| `next( iv_object, iv_range, iv_subobject, iv_toyear )` | next single number |
| `next_block( ..., iv_quantity, ev_first_number, ev_quantity )` | reserve a block |

Any failure (interval not found, object not found, overflow, …) is wrapped in a
descriptive `ZCX_AU_ERROR`.

## Tests
Requires a configured number range object, so verify by activation + a real draw
rather than ABAP Unit.

## Extending
Add `current_number` (read without incrementing, FM `NUMBER_RANGE_INTERVAL_LIST`)
or an ABAP-Cloud implementation behind a shared interface.
