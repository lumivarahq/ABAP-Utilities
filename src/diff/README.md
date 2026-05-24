# Diff — `ZCL_AU_DIFF`

> Line diff of two strings / string tables (LCS-based), so unchanged lines line
> up even with insertions/removals. For comparing before/after, config snapshots,
> generated output, or test fixtures.

## Objects & dependencies
- `ZCL_AU_DIFF` — stateless utility (`class-methods`).
- Depends on: **nothing** → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `src/diff/zcl_au_diff.clas.abap` (+ `.clas.xml`, optionally
`.clas.testclasses.abap`) into a class in your package and assign it to your TR.

## How to use
```abap
data(lt_diff) = zcl_au_diff=>tables(
  it_a = value #( ( `line1` ) ( `line2` )         ( `line3` ) )
  it_b = value #( ( `line1` ) ( `line2 changed` ) ( `line3` ) ) ).

write / zcl_au_diff=>to_text( lt_diff ).
"  line1
" -line2
" +line2 changed
"  line3

" quick equality (e.g. in a test):
if zcl_au_diff=>are_equal( it_a = lt_expected it_b = lt_actual ) = abap_false.
  cl_abap_unit_assert=>fail( zcl_au_diff=>to_text( zcl_au_diff=>tables( lt_expected lt_actual ) ) ).
endif.
```

## API
| Method | Purpose |
|--------|---------|
| `tables( it_a, it_b )` | LCS diff → rows of kind `' '`/`'-'`/`'+'` + text |
| `texts( iv_a, iv_b )` | same, splitting both strings at newline |
| `to_text( it_diff )` | render with `' '`/`'-'`/`'+'` prefixes |
| `are_equal( it_a, it_b )` | line-for-line equality |

## Tests
`zcl_au_diff.clas.testclasses.abap` checks a changed line (1×`-`, 1×`+`, 2×` `),
a pure insertion, and equality.

## Extending
Add a side-by-side renderer, word-level diff, or a unified-diff header
(`@@ -a,b +c,d @@`) for patch-style output.
