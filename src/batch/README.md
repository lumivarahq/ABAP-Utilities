# Batch / packaging — `ZCL_AU_BATCH`

> Chunk big sets into packages: the index math for `FOR ALL ENTRIES` drivers,
> commit-every-N, and paging — and a ready chunker for string tables.

## Objects & dependencies
- `ZCL_AU_BATCH` — stateless utility (`class-methods`).
- Depends on: **`ZCX_AU_ERROR`** (invalid size) → **ABAP Cloud safe**.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/batch/zcl_au_batch.clas.abap` (+ `.clas.xml`).
3. Assign both to your TR.

## How to use
```abap
" process 50,000 rows in packages of 1,000 with a COMMIT between packages
loop at zcl_au_batch=>bounds( iv_total = lines( lt_all ) iv_size = 1000 ) into data(ls_pkg).
  data(lt_slice) = value tt_data( for i = ls_pkg-from to ls_pkg-to ( lt_all[ i ] ) ).
  " ... process lt_slice (e.g. FOR ALL ENTRIES, mass update) ...
  commit work.
endloop.

" or chunk a string table directly
data(lt_chunks) = zcl_au_batch=>chunks( it_table = lt_keys iv_size = 500 ).
```

## API
| Method | Purpose |
|--------|---------|
| `bounds( iv_total, iv_size )` | 1-based `(index, from, to)` ranges; last may be smaller |
| `chunks( it_table, iv_size )` | split a `string_table` into ≤`iv_size` slices |

Size `<= 0` raises `ZCX_AU_ERROR`.

## Tests
`zcl_au_batch.clas.testclasses.abap` checks the split (10/3 → 4 ranges, last
`10..10`), the empty case, the bad-size guard, and chunking (5/2 → 3 chunks).

## Extending
Add a generic (RTTI-based) `chunks` for any table type, or a callback-driven
`process( it_table, io_handler )` that calls a `ZIF_AU_RUNNABLE` per package.
