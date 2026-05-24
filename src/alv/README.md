# ALV (SALV) — `ZCL_AU_ALV`

> A drop-in, modern replacement for `REUSE_ALV_GRID_DISPLAY`, plus a bridge that
> **reuses your existing classic field catalog** on a SALV grid.

## Objects & dependencies
- `ZCL_AU_ALV` — stateless utility (`class-methods`), built on `CL_SALV_TABLE`.
- Depends on: **nothing** in this repo (propagates the standard `CX_SALV_MSG`).

> ⚠️ **Classic Dynpro / SAP GUI only.** `CL_SALV_TABLE` full-screen display is
> not available in ABAP Cloud. For Fiori/OData, expose the data via a CDS view +
> RAP/OData service instead.

## Install (cherry-pick)
Copy `src/alv/zcl_au_alv.clas.abap` (+ `.clas.xml`) into a class in your package
and assign it to your TR. No other objects required.

## Migrating REUSE_ALV ➜ SALV

### Before (classic)
```abap
call function 'REUSE_ALV_GRID_DISPLAY'
  exporting i_callback_program = sy-repid
            it_fieldcat        = lt_fcat
  tables    t_outtab           = lt_data
  exceptions others            = 1.
```

### After — simplest case (no field catalog needed)
```abap
zcl_au_alv=>display( changing ct_table = lt_data ).
```

### After — reuse the field catalog you already build
```abap
data(lo_alv) = zcl_au_alv=>factory( changing ct_table = lt_data ).
zcl_au_alv=>apply_lvc_fieldcat( io_alv = lo_alv it_fcat = lt_fcat ).
lo_alv->display( ).
```
`apply_lvc_fieldcat` maps the classic LVC catalog to SALV:

| LVC field | SALV effect |
|-----------|-------------|
| `no_out` / `tech` | column hidden |
| `scrtext_l` / `scrtext_m` / `scrtext_s` | column titles |
| `reptext` | long title (fallback) |
| `hotspot` | cell type = hotspot |

> Migrating from the **SLIS** catalog (`slis_t_fieldcat_alv`)? Convert it to LVC
> first with the standard FM `LVC_FIELDCATALOG_MERGE` (or
> `LVC_TRANSFER_FROM_SLIS`), then call `apply_lvc_fieldcat`.

## API
| Method | Purpose |
|--------|---------|
| `display( ct_table, iv_title )` | one-call full-screen grid |
| `factory( ct_table, iv_title )` | configured `CL_SALV_TABLE` for further tweaks |
| `apply_lvc_fieldcat( io_alv, it_fcat )` | reuse a classic LVC field catalog |
| `set_column_title( io_alv, iv_column, iv_title )` | set all three column titles |
| `hide_column( io_alv, iv_column )` | hide a column |

## Event handling (optional)

Add the two extra objects `ZIF_AU_ALV_HANDLER` + `ZCL_AU_ALV_EVENTS` to react to
double-click / hotspot without writing SALV event boilerplate:

```abap
class lcl_report definition.
  public section.
    interfaces zif_au_alv_handler.
    methods run.
endclass.

class lcl_report implementation.
  method run.
    data(lo_alv) = zcl_au_alv=>factory( changing ct_table = mt_data ).
    " make a column clickable, then register the handler (this object)
    lo_alv->get_columns( )->get_column( 'MATNR' ) ?? "...set hotspot via apply_lvc_fieldcat or set_cell_type
    new zcl_au_alv_events( io_alv = lo_alv io_handler = me ).
    lo_alv->display( ).
  endmethod.

  method zif_au_alv_handler~on_double_click.
    message |Row { iv_row } column { iv_column }| type 'I'.
  endmethod.

  method zif_au_alv_handler~on_link_click.
    " hotspot clicked
  endmethod.
endclass.
```

You don't need to keep the `ZCL_AU_ALV_EVENTS` instance — the SALV registration
holds a reference. (Link-click only fires for columns whose cell type is hotspot,
which `apply_lvc_fieldcat` sets from `fcat-hotspot`.)

## Tests
SALV requires a GUI session, so this module is verified by activation + manual
run rather than ABAP Unit. The event adapter is thin (it just forwards to your
handler), so unit-test your handler logic directly.

## Extending
Add helpers for events (double-click/hotspot via `get_event( )`), top-of-page
headers (`set_top_of_list`), aggregations (`get_aggregations`), or embedding into
a container (`cl_salv_table=>factory( r_container = ... )`).
