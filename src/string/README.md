# String — `ZCL_AU_STRING`

> Everyday string helpers that don't ship with ABAP: case conversion,
> padding, masking, ALPHA conversion, split/join, truncation.

## Objects & dependencies
- `ZCL_AU_STRING` — stateless utility (`class-methods`).
- Depends on: **nothing**. Pure string processing → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `src/string/zcl_au_string.clas.abap` (+ `.clas.xml`, and optionally
`.clas.testclasses.abap`) into a class in your package and assign it to your TR.

## How to use

```abap
data(lt) = zcl_au_string=>split_to_table( iv_string = `a,b,c` ).
data(lv) = zcl_au_string=>join( it_table = lt iv_separator = `;` ).  "a;b;c

zcl_au_string=>mask( `4111111111111111` ).            "************1111
zcl_au_string=>to_snake_case( `SalesOrderItem` ).     "sales_order_item
zcl_au_string=>to_camel_case( `sales_order_item` ).   "salesOrderItem
zcl_au_string=>to_pascal_case( `sales order item` ).  "SalesOrderItem
zcl_au_string=>lpad( iv_string = `42` iv_length = 5 iv_pad = '0' ). "00042
zcl_au_string=>alpha_in( '42' ).                      "0000000042
zcl_au_string=>alpha_out( '0000000042' ).             "42
zcl_au_string=>truncate( iv_string = `Hello World` iv_length = 8 ). "Hello...
zcl_au_string=>is_numeric( `12345` ).                 "abap_true
```

## API
| Method | Purpose |
|--------|---------|
| `split_to_table` / `join` | string ⇄ `string_table` |
| `mask` | keep only last *n* chars readable |
| `replace_all` | replace every occurrence |
| `is_numeric` | digits-only check |
| `to_snake_case` / `to_camel_case` / `to_pascal_case` | identifier case conversion |
| `lpad` / `rpad` | pad to length with a single char |
| `alpha_in` / `alpha_out` | add / remove leading zeros (ALPHA) |
| `truncate` | shorten with an ellipsis |

## Tests
`zcl_au_string.clas.testclasses.abap` covers split/join, masking, all three case
conversions, padding, ALPHA, numeric check and truncation.

## Extending
Add helpers like `slugify`, `pad_center`, or regex utilities. Keep methods pure
(no DB / system access) so the class stays cloud-safe.
