# ZCL_AU_STRING

AU - String utilities

_Module: `string` — generated from source by `tools/gen-api-docs.js`; do not edit by hand._

| Method | Description |
|--------|-------------|
| `split_to_table` | Split a string into a table of lines at a separator. |
| `join` | Join a table of strings into a single string with a separator. |
| `mask` | Mask a string, leaving only the last iv_visible characters readable. |
| `replace_all` | Replace every occurrence of iv_what with iv_with. |
| `is_numeric` | True if the string contains digits only (no sign, no decimals). |
| `to_snake_case` | "OrderItem" / "order item" / "order-item" -> "order_item". |
| `to_camel_case` | "order_item" / "order item" -> "orderItem". |
| `to_pascal_case` | "order_item" / "order item" -> "OrderItem". |
| `lpad` | Pad on the left up to iv_length using a single pad character. |
| `rpad` | Pad on the right up to iv_length using a single pad character. |
| `alpha_in` | ALPHA conversion - add leading zeros ("42" -> "0000000042"). |
| `alpha_out` | ALPHA conversion - remove leading zeros ("0000000042" -> "42"). |
| `truncate` | Truncate a string and append an ellipsis when it is too long. |
