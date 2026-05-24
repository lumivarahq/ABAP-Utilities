# Internal tables — `ZCL_AU_ITAB`

> A few generic table helpers. For the real transformations (removing nested
> loops, choosing sorted vs hashed, `GROUP BY`, `FILTER`, `REDUCE`) see the
> [Internal Tables Cookbook](../../docs/internal-tables-cookbook.md) — those are
> best written as inline modern-ABAP expressions, not helper calls.

## Objects & dependencies
- `ZCL_AU_ITAB` — stateless utility (`class-methods`).
- Depends on: **nothing** → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `src/itab/zcl_au_itab.clas.abap` (+ `.clas.xml`, optionally
`.clas.testclasses.abap`) into a class in your package and assign it to your TR.

## How to use

```abap
" Remove duplicates in place (generic, any standard table)
zcl_au_itab=>distinct( changing ct_table = lt_any ).

" Count distinct rows without touching the source
data(lv_n) = zcl_au_itab=>count_distinct( lt_any ).

" Reads well in fluent code
if zcl_au_itab=>has_rows( lt_any ).
  ...
endif.
```

## API
| Method | Purpose |
|--------|---------|
| `distinct( ct_table )` | remove duplicate rows in place (sort + adjacent dedup) |
| `count_distinct( it_table )` | number of distinct rows, non-destructive |
| `has_rows( it_table )` | `abap_bool` — table is not empty |

## Tests
`zcl_au_itab.clas.testclasses.abap` covers in-place dedup, non-destructive
counting and the emptiness check.

## Extending
Resist adding "loop wrappers". The modern, ATC-friendly answers live in the
cookbook: `VALUE`/`FOR`, `REDUCE`, `FILTER`, `CORRESPONDING`, table expressions
`itab[ key = ... ]`, `line_exists( )`, `line_index( )`, and `GROUP BY`.
