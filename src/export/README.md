# Data export — `ZCL_AU_ANALYTICS_GEN`

> Generate the CDS + service artifacts that expose a report's data to **Power BI
> and other external systems** over **OData** — plus analytical cube and
> data-extraction views for BI/warehouse scenarios.

## Objects & dependencies
- `ZCL_AU_ANALYTICS_GEN` — CDS/SRVD source generator (string building).
- Depends on: **`ZCX_AU_ERROR`** → **ABAP Cloud safe** (generates source; the
  generated objects are the cloud-native target).

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/export/zcl_au_analytics_gen.clas.abap` (+ `.clas.xml`).
3. Assign both to your TR.

## How to use

### Expose data to Power BI / external tools over OData
```abap
data(lt) = value zcl_au_analytics_gen=>tt_field(
  ( name = `region`  is_key = abap_true )
  ( name = `product` is_key = abap_true )
  ( name = `revenue` is_measure = abap_true ) ).

data(ls) = zcl_au_analytics_gen=>odata_export( iv_entity      = `Sales`
                                               iv_data_source = `ztsales`
                                               it_fields      = lt ).
" ls-cds_view           -> DDLS ZC_Sales
" ls-service_definition -> SRVD ZAPI_Sales  (bind as OData V2 - Web API, publish)
" ls-connect_steps      -> how to get the URL and connect Power BI
```
Then in **Power BI Desktop**: *Get Data ➜ OData feed ➜* paste the service URL ➜
authenticate ➜ Load. Push filters to the server with `$filter` / `$select` /
`$top` to keep extracts small.

### Live analytics cube
```abap
data(lv_cube) = zcl_au_analytics_gen=>analytics_cube( iv_entity = `Sales`
                                                      iv_data_source = `ztsales`
                                                      it_fields = lt ).
" @Analytics.dataCategory: #CUBE; measures get @DefaultAggregation: #SUM
```

### Data extraction (SAP Datasphere / BW / warehouse)
```abap
data(lv_extr) = zcl_au_analytics_gen=>extraction_view( iv_entity = `Sales`
                                                       iv_data_source = `ztsales`
                                                       it_fields = lt ).
" @Analytics.dataExtraction.enabled: true (+ delta/CDC where the source supports it)
```

## API
| Method | Output |
|--------|--------|
| `odata_export( iv_entity, iv_data_source, it_fields )` | consumption view + service def + connect steps |
| `analytics_cube( … )` | a `#CUBE` view (dimensions + aggregated measures) |
| `extraction_view( … )` | an extraction-enabled view |

## Tests
`zcl_au_analytics_gen.clas.testclasses.abap` asserts the generated DDL/SRVD carry
the expected entities, annotations (`#CUBE`, `@DefaultAggregation`,
`dataExtraction.enabled`) and connect steps, and that an empty field list raises.

## Choosing an export path
- **Live/interactive in Power BI/Excel** ➜ OData (`odata_export`). Simplest;
  good for moderate volumes; supports server-side filtering.
- **Analytical reporting / aggregations** ➜ `analytics_cube` consumed via the
  analytical OData/InA service.
- **Bulk replication to a warehouse** (Datasphere, BW, third-party) ➜
  `extraction_view` + the extraction/CDC frameworks.

See [docs/data-export-cookbook.md](../../docs/data-export-cookbook.md) for the
end-to-end recipes, authentication options and connector notes.
