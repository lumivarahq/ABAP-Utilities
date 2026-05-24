# Guard clauses — `ZCL_AU_GUARD`

> Fail-fast precondition checks that make a method's contract explicit and turn
> bad input into a clear error (cf. Guava `Preconditions` / .NET
> `ArgumentException` helpers).

## Objects & dependencies
- `ZCL_AU_GUARD` — stateless utility (`class-methods`).
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module)
  → **ABAP Cloud safe**.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/guard/zcl_au_guard.clas.abap` (+ `.clas.xml`).
3. Assign both objects to your TR.

## How to use

```abap
method post_invoice.
  zcl_au_guard=>not_initial( iv_value = is_invoice-customer iv_name = `customer` ).
  zcl_au_guard=>not_empty(   it_table = it_items            iv_name = `items` ).
  zcl_au_guard=>that( iv_condition = xsdbool( is_invoice-amount > 0 )
                      iv_message   = `amount must be positive` ).
  " ... from here on the inputs are known-good ...
endmethod.
```

## API
| Method | Raises when |
|--------|-------------|
| `that( iv_condition, iv_message )` | condition is `abap_false` |
| `not_initial( iv_value, iv_name )` | value is initial (works for any type) |
| `not_empty( it_table, iv_name )` | table has no rows |

## Tests
`zcl_au_guard.clas.testclasses.abap` checks each guard raises on a violation and
passes otherwise.

## Extending
Add `in_range`, `matches( regex )`, `max_length`, or typed numeric guards. Keep
guards cheap and side-effect free so they're safe to call on every entry.
