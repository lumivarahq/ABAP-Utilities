# Markdown doc generator — `ZCL_AU_DOCGEN` (+ report `ZAU_DOCGEN`)

> Generate a Markdown API reference for a class/interface straight from its RTTI
> signature — no manual table maintenance, never out of date with the code.

## Objects & dependencies
- `ZCL_AU_DOCGEN` — generator engine (`class-methods`).
- `ZAU_DOCGEN` — executable report wrapping the engine (optional).
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module). Uses RTTI
  (`CL_ABAP_TYPEDESCR`) → **ABAP Cloud safe** (the class; the report uses
  `CL_DEMO_OUTPUT`, classic UI).

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/docgen/zcl_au_docgen.clas.abap` (+ `.clas.xml`). The report
   (`zau_docgen.prog.*`) is optional.
3. Assign the objects to your TR.

## How to use

```abap
" one class
data(lv_md) = zcl_au_docgen=>for_class( 'ZCL_AU_STRING' ).

" several at once (e.g. a whole package), then write to a file / repo
data(lv_all) = zcl_au_docgen=>for_classes(
  value #( ( `ZCL_AU_STRING` ) ( `ZCL_AU_DATE` ) ( `ZCL_AU_CSV` ) ) ).
zcl_au_dataset=>write_text( iv_path = '/tmp/api.md' iv_content = lv_all ).   "on-prem
```

Or just run report **`ZAU_DOCGEN`** (SE38 / ADT), enter a class name, and the
Markdown is shown via `CL_DEMO_OUTPUT`.

### Example output
```
# ZCL_AU_STRING

_Generated from RTTI._

| Method | Visibility | Parameters |
|--------|------------|------------|
| `split_to_table` | public | `iv_string` _importing_<br>`iv_separator` _importing_<br>`rt_table` _returning_<br> |
| ...
```

## API
| Method | Purpose |
|--------|---------|
| `for_class( iv_name, iv_only_public )` | Markdown for one class/interface |
| `for_classes( it_names )` | Markdown for several, concatenated |

## Tests
Output depends on the loaded class metadata; verify by running against a known
class. (The RTTI calls themselves are standard.)

## Extending
- **Merge in the ABAP Doc text** (`"!` summaries): read the class source with the
  ADT/`cl_oo_*` source APIs and map comment blocks to methods.
- Emit parameter **types** (resolve via `cl_abap_objectdescr->get_method_parameter_type`).
- Wire `for_classes( )` into CI to regenerate `docs/api/*.md` on every build (see
  [auto-documentation](../../docs/auto-documentation.md)).
