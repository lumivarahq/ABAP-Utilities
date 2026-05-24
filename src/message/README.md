# Message — `ZCL_AU_MESSAGE`

> Turn T100 / `sy-msg*` messages into text and `BAPIRET2`, and inspect return
> tables.

## Objects & dependencies
- `ZCL_AU_MESSAGE` — stateless utility (`class-methods`).
- Depends on: **nothing** → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `src/message/zcl_au_message.clas.abap` (+ `.clas.xml`) into a class in your
package and assign it to your TR.

## How to use

```abap
" Resolve a message-class message to text
data(lv) = zcl_au_message=>text_from_t100( iv_msgid = 'ZFOO' iv_msgno = '001'
                                           iv_v1 = lv_id ).

" After a classic call that sets sy-msg*
data(lv2) = zcl_au_message=>text_from_sy( ).

" Build BAPIRET2 (with resolved text) for a return table
append zcl_au_message=>bapiret( iv_type  = 'E'
                                iv_msgid = 'ZFOO'
                                iv_msgno = '002'
                                iv_v1    = lv_id ) to lt_return.
append zcl_au_message=>bapiret_from_sy( ) to lt_return.

" Inspect a return table
if zcl_au_message=>has_errors( lt_return ) = abap_true.
  data(lv_all) = zcl_au_message=>concat( lt_return ).   "a / b / c
endif.
```

## API
| Method | Purpose |
|--------|---------|
| `text_from_t100` / `text_from_sy` | resolve a message to its formatted text |
| `bapiret` / `bapiret_from_sy` | build a `BAPIRET2` line (with text) |
| `has_errors` | does a `BAPIRET2_T` contain `E`/`A`/`X`? |
| `concat` | join all message texts of a return table |

## Tests
Add tests against your own message class (texts are system-specific).

## Extending
Add converters to/from `SYMSG`, `T100`, or RAP messages
([`ZCL_AU_RAP_MSG`](../rap/README.md)). For persistent logging route the same
data into [`ZCL_AU_LOGGER`](../logger/README.md) via `add_bapiret`.
