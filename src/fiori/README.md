# Fiori scaffolding — `ZCL_AU_FIORI_GEN` (+ `ZCL_AU_FIORI_FROM_ALV`)

> Turn a database table (or an existing ALV) into the **CDS + RAP + service**
> boilerplate for a Fiori Elements app (List Report + Object Page → Launchpad
> tile). The generator emits the source; you paste it into ADT, activate, and
> create the Service Binding.

A runtime ABAP class can't *render* a Fiori UI — Fiori Elements is metadata-driven
(CDS annotations + OData). What it **can** do is remove the tedious, error-prone
part: writing the interface view, the annotated projection, the managed behavior,
the projection behavior and the service definition for every field. That's what
this module generates.

## Objects & dependencies
- `ZCL_AU_FIORI_GEN` — the generator (RTTI + string building). Depends on
  `ZCX_AU_ERROR`. **Cloud-safe** (uses only RTTI).
- `ZCL_AU_FIORI_FROM_ALV` — optional bridge from an LVC field catalog. Depends on
  `ZCL_AU_FIORI_GEN` and the LVC type. **On-premise** (LVC types).

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `zcl_au_fiori_gen.clas.abap` (+ `.clas.xml`). Add
   `zcl_au_fiori_from_alv.clas.*` only if you need the ALV bridge.
3. Assign to your TR.

## How to use

### From a table
```abap
" 1) seed the field list from the table (first field defaulted as key)...
data(lt_fields) = zcl_au_fiori_gen=>fields_from_structure( 'ZTPRODUCT' ).
" 2) ...adjust the real key fields / labels / positions, then generate:
loop at lt_fields assigning field-symbol(<f>) where name = 'product_id'.
  <f>-is_key = abap_true.
endloop.

data(ls) = zcl_au_fiori_gen=>generate( iv_entity      = `Product`
                                       iv_data_source = `ztproduct`
                                       it_fields      = lt_fields ).
" ls-interface_view / projection_view / behavior / projection_behavior /
" service_definition / service_binding  -> paste each into the matching ADT object.
```

### From an existing ALV (migration)
```abap
" reuse the field catalog you already build for REUSE_ALV / SALV
data(lt_fields) = zcl_au_fiori_from_alv=>fields( lt_fcat ).
data(ls)        = zcl_au_fiori_gen=>generate( iv_entity      = `Order`
                                              iv_data_source = `ztorder`
                                              it_fields      = lt_fields ).
```

## What it generates (5 artifacts)
| Artifact | ADT object | Purpose |
|----------|-----------|---------|
| `interface_view` | DDLS `ZI_<entity>` | root view on the table |
| `projection_view` | DDLS `ZC_<entity>` | UI projection with `@UI` (List Report + Object Page) |
| `behavior` | BDEF `ZI_<entity>` | managed create/update/delete |
| `projection_behavior` | BDEF `ZC_<entity>` | projection behavior |
| `service_definition` | SRVD `ZUI_<entity>` | exposes the projection |
| `service_binding` | (steps) | how to publish OData V4 - UI + add the tile |

### Read-only list (display-only ALV ➜ Fiori)
```abap
data(ls) = zcl_au_fiori_gen=>generate( iv_entity        = `Order`
                                       iv_data_source   = `ztorder`
                                       it_fields        = lt_fields
                                       iv_with_behavior = abap_false ).  "no create/update/delete
```

### Value help (search-help replacement)
```abap
data(ls_vh) = zcl_au_fiori_gen=>value_help( iv_entity      = `Currency`
                                            iv_data_source = `ztcurrency`
                                            iv_key_field   = `code`
                                            iv_text_field  = `name` ).
" ls_vh-view       -> a new DDLS (ZI_VH_Currency)
" ls_vh-annotation -> paste on the consuming field in your projection view
```

### Metadata extension (annotations separated from the view)
```abap
data(lv_ddlx) = zcl_au_fiori_gen=>metadata_extension( iv_entity = `Product` it_fields = lt_fields ).
" -> a new DDLX; keep @Metadata.allowExtensions: true on the projection, move @UI here
```

## API
| Method | Purpose |
|--------|---------|
| `fields_from_structure( iv_name )` | default field list from a table/structure (RTTI) |
| `generate( …, iv_with_behavior )` | the artifacts; `iv_with_behavior = abap_false` for a read-only list |
| `value_help( iv_entity, iv_data_source, iv_key_field, iv_text_field )` | value-help view + consumption annotation |
| `metadata_extension( iv_entity, it_fields )` | a DDLX holding the `@UI` annotations |
| `zcl_au_fiori_from_alv=>fields( it_fcat )` | LVC field catalog → field list |

## Tests
`zcl_au_fiori_gen.clas.testclasses.abap` asserts the generated DDL/BDEF/service
contain the expected entities, data source, annotations and operations
(deterministic — pure string generation), and that an empty field list raises.

## Scope & limitations
- It's a **scaffold**: review keys, labels, `@UI` positions, add associations,
  value helps and texts. RTTI can't detect key fields, so you set `is_key`.
- Managed behavior is generated **without draft** to keep it activatable as-is;
  add `with draft;` + a draft table when you want Fiori draft.
- For complex apps use the ADT **RAP Generator** wizard; this is for fast,
  bulk "table → maintenance app" starts. See
  [docs/fiori-conversion-cookbook.md](../../docs/fiori-conversion-cookbook.md).
