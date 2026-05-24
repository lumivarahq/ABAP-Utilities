# Feature flags — `ZIF_AU_FEATURE_FLAG` / `ZCL_AU_FEATURE_FLAG`

> Decouple **deploy** from **release**: ship code dark and switch it on by
> configuration, not by transport. The tiny `ZIF_FEATURE_FLAG` service the
> *Worst Habits* guide (§9.1) recommends building.

## Objects & dependencies
- `ZIF_AU_FEATURE_FLAG` — the toggle abstraction (`is_enabled`).
- `ZCL_AU_FEATURE_FLAG` — an in-memory implementation you seed from any source.
- Depends on: **nothing** → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `zif_au_feature_flag.intf.abap` + `zcl_au_feature_flag.clas.abap` (+ their
`.xml`) and assign to your TR.

## How to use

```abap
" 1) at the composition root, seed the flag set from your trusted source
"    (TVARVC via ZCL_AU_CONFIG, a Z customizing table, or literals in DEV)
data(lt_enabled) = value string_table( ( `NEW_PRICING` ) ( `BETA_EXPORT` ) ).
data(lo_flags)   = zcl_au_feature_flag=>from_enabled( lt_enabled ).

" 2) inject ZIF_AU_FEATURE_FLAG and branch on it
if lo_flags->is_enabled( `NEW_PRICING` ).
  ... new behaviour (shipped, off until enabled) ...
else.
  ... old behaviour ...
endif.
```

Seed from [`ZCL_AU_CONFIG`](../config/README.md) to toggle per system without a
transport:
```abap
data lt type string_table.
if zcl_au_config=>is_enabled( 'Z_NEW_PRICING' ). append `NEW_PRICING` to lt. endif.
data(lo_flags) = zcl_au_feature_flag=>from_enabled( lt ).
```

In tests, inject an explicit set — no system config needed:
```abap
data(lo_flags) = zcl_au_feature_flag=>from_enabled( value #( ( `NEW_PRICING` ) ) ).
```

## API
| Method | Purpose |
|--------|---------|
| `zcl_au_feature_flag=>from_enabled( it_features )` | build a flag set (case-insensitive) |
| `zif_au_feature_flag~is_enabled( iv_feature )` | is the feature on? |

## Tests
`zcl_au_feature_flag.clas.testclasses.abap` covers enabled/disabled lookups and
case-insensitivity.

## Extending
Add per-user / per-percentage targeting (`is_enabled_for_user`), an expiry date,
or a provider implementation that reads a Z table / the S/4 central business
configuration directly.
