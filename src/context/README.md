# System context — `ZCL_AU_CONTEXT`

> Clean-core-safe replacements for the restricted `sy-uname` / `sy-datum` /
> `sy-uzeit` system fields, wrapping the released `CL_ABAP_CONTEXT_INFO`.

## Objects & dependencies
- `ZCL_AU_CONTEXT` — stateless utility (`class-methods`).
- Depends on: **nothing** (uses released `CL_ABAP_CONTEXT_INFO`)
  → **ABAP Cloud safe**.

## Why
Direct use of `sy-uname` / `sy-datum` is flagged by the Clean Core ATC checks
and is not allowed in ABAP Cloud. Routing through this class (or
`CL_ABAP_CONTEXT_INFO` directly) keeps the code cloud-ready and makes "current
user/date" trivial to stub in unit tests.

## Install (cherry-pick)
Copy `src/context/zcl_au_context.clas.abap` (+ `.clas.xml`) into a class in your
package and assign it to your TR.

## How to use

```abap
data(lv_user)  = zcl_au_context=>user( ).        " instead of sy-uname
data(lv_today) = zcl_au_context=>today( ).        " instead of sy-datum
data(lv_now)   = zcl_au_context=>time_now( ).      " instead of sy-uzeit
data(lv_tz)    = zcl_au_context=>time_zone( ).
```

## API
| Method | Replaces |
|--------|----------|
| `user( )` | `sy-uname` |
| `today( )` | `sy-datum` |
| `time_now( )` | `sy-uzeit` |
| `time_zone( )` | user time zone |

## Tests
Values are system-dependent, so verify by activation rather than ABAP Unit. In
your own tests, wrap this behind an interface (or pass the user/date in) so you
can stub "now".

## Extending
Add `client( )`, language/format helpers, or a small `ZIF_AU_CLOCK` interface so
"current time" can be injected and frozen in tests.
