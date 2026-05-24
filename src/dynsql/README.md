# Safe dynamic SQL — `ZCL_AU_DYN_SQL`

> Build dynamic ABAP SQL without opening an injection hole (*Worst Habits* §6.3).
> Wraps `CL_ABAP_DYN_PRG` and adds an allow-list guard.

## Objects & dependencies
- `ZCL_AU_DYN_SQL` — stateless utility (`class-methods`).
- Depends on: **`ZCX_AU_ERROR`** + the released `CL_ABAP_DYN_PRG`
  → **ABAP Cloud safe**.

## The golden rule first
For dynamic **values**, use host variables — no helper needed:
```abap
select * from mara where matnr = @lv_matnr into table @data(lt).   "safe
select * from mara where matnr in @lt_range into table @data(lt2). "safe
```
Reach for this class only when the **column/table name** or a **literal** is
genuinely dynamic (e.g. a user-chosen sort column).

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/dynsql/zcl_au_dyn_sql.clas.abap` (+ `.clas.xml`).
3. Assign both to your TR.

## How to use

```abap
" Dynamic column, validated against an allow-list (best) ...
data(lv_sort) = zcl_au_dyn_sql=>allowed( iv_value   = iv_user_sort
                                         it_allowed = value #( ( `MATNR` ) ( `ERSDA` ) ) ).
select * from mara order by (lv_sort) into table @data(lt).

" ... or validated as a syntactic identifier:
data(lv_col) = zcl_au_dyn_sql=>column( iv_user_column ).

" Dynamic literal value in a WHERE built as a string:
data(lv_where) = |matnr = { zcl_au_dyn_sql=>quote( iv_user_input ) }|.
select * from mara where (lv_where) into table @data(lt2).
```

## API
| Method | Purpose |
|--------|---------|
| `quote( iv_value )` | quote a literal (doubles embedded quotes) — `CL_ABAP_DYN_PRG=>QUOTE` |
| `column( iv_name )` | validate a dynamic column name; raises if not a valid identifier |
| `allowed( iv_value, it_allowed )` | enforce an allow-list for any dynamic token; raises otherwise |

## Tests
`zcl_au_dyn_sql.clas.testclasses.abap` checks quote escaping (`O'Brien` →
`'O''Brien'`), allow-list pass/reject, and a valid column name.

## Extending
Add `table_name( )` (`check_table_or_view_name_str`) and a `where_eq( col, val )`
convenience that validates the column and quotes the value in one call.
