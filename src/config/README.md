# Config & feature toggles — `ZCL_AU_CONFIG`

> Read parameters, select-option ranges and feature flags from **TVARVC**
> (transaction `STVARV`) — externalised config without a custom Z-table.

## Objects & dependencies
- `ZCL_AU_CONFIG` — stateless utility (`class-methods`).
- Depends on: **nothing** in this repo (reads the standard table `TVARVC`).

> ⚠️ **ABAP Cloud:** a direct `SELECT` on `TVARVC` is not released. In ABAP
> Cloud model configuration as your own released CDS view / custom entity, or use
> the Maintenance/Configuration apps. The API shape here ports directly.

## Install (cherry-pick)
Copy `src/config/zcl_au_config.clas.abap` (+ `.clas.xml`) into a class in your
package and assign it to your TR. Maintain values in transaction **STVARV**.

## How to use

```abap
" a single parameter (STVARV type "Parameter")
data(lv_threshold) = zcl_au_config=>get_value( 'Z_BATCH_SIZE' ).

" a feature toggle - deploy dark, switch on without a transport
if zcl_au_config=>is_enabled( 'Z_FEATURE_NEW_PRICING' ).
  ... new behaviour ...
endif.

" a select-option range (STVARV type "Selection option") used directly in SQL
data(lt_bukrs) = zcl_au_config=>get_range( 'Z_RELEVANT_BUKRS' ).
select * from i_companycode where companycode in @lt_bukrs into table @data(lt).
```

## API
| Method | Purpose |
|--------|---------|
| `get_value( iv_name )` | single parameter value (`""` if unknown) |
| `get_range( iv_name )` | `SIGN/OPTION/LOW/HIGH` ranges for a WHERE … IN |
| `is_enabled( iv_name )` | toggle: true for `X` / `TRUE` / `1` / `YES` / `ON` |

## Tests
Values are environment data, so verify against your STVARV entries. To unit-test
callers, hide this behind an interface and inject fake values.

## Extending
Add typed getters (`get_int`, `get_date`), a small in-session cache, or a
write/maintenance method (`get_range` already returns a range usable in SQL).
