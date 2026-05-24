# SAPscript text — `ZCL_AU_TEXT`

> The classic `READ_TEXT` / `SAVE_TEXT` pattern (TLINE tables, 8 exceptions,
> header structures) collapsed into two readable calls. A worked example of
> *"simplify complicated SAP standard code behind a small facade"*.

## Objects & dependencies
- `ZCL_AU_TEXT` — stateless utility (`class-methods`).
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module) and the
  classic FMs **`READ_TEXT` / `SAVE_TEXT`** (STXH/STXL).

> ⚠️ **ABAP Cloud:** these FMs are not released. There is no 1:1 released
> replacement for arbitrary SAPscript texts; model long texts as your own
> persistent entity, or use a released text API where one exists for your object.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/text/zcl_au_text.clas.abap` (+ `.clas.xml`).
3. Assign both objects to your TR.

## Before / after

### Before (classic)
```abap
data lt_lines type table of tline.
call function 'READ_TEXT'
  exporting id = '0001' language = sy-langu name = lv_name object = 'VBBK'
  tables    lines = lt_lines
  exceptions id = 1 language = 2 name = 3 not_found = 4 object = 5
             reference_check = 6 wrong_access_to_archive = 7 others = 8.
if sy-subrc = 0.
  loop at lt_lines into data(ls). lv_text = lv_text && ls-tdline. endloop.
endif.
```

### After
```abap
data(lv_text) = zcl_au_text=>read( iv_id     = '0001'
                                   iv_name   = lv_name
                                   iv_object = 'VBBK' ).

zcl_au_text=>save( iv_id     = '0001'
                   iv_name   = lv_name
                   iv_object = 'VBBK'
                   iv_text   = |Line 1{ cl_abap_char_utilities=>newline }Line 2| ).
```

## API
| Method | Purpose |
|--------|---------|
| `read( iv_id, iv_name, iv_object, iv_language )` | text as a single string ("" if missing) |
| `save( ..., iv_text, iv_commit )` | create/replace the text from a string |

## Tests
Requires text master data, so verify by activation + a real read/write rather
than ABAP Unit.

## Extending
Add `exists( )`, `delete( )` (FM `DELETE_TEXT`), or paragraph/format-aware
read/write if you need the SAPscript formatting preserved.
