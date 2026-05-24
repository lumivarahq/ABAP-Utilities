# Exporting ABAP data to Power BI & external systems

How to get data out of a report / table / CDS view into **Power BI**, Excel,
Tableau, a data warehouse, or any external system — the Clean-Core way (OData &
CDS), with [`ZCL_AU_ANALYTICS_GEN`](../src/export/README.md) generating the
boilerplate.

> See also [RAP/CDS/BTP modernization](rap-cds-modernization.md).

## Pick the right channel

| You want… | Use | Volume | Freshness |
|-----------|-----|--------|-----------|
| Interactive reports in Power BI/Excel | **OData service** over a CDS view | low–medium | live (on refresh) |
| Aggregated analytics (sums by dimensions) | **Analytical CDS cube** via OData/InA | medium | live |
| Bulk replication into a warehouse | **CDS data extraction** (Datasphere/BW/CDI) | high | batch / delta (CDC) |
| One-off file hand-off | CSV/Excel ([`ZCL_AU_CSV`](../src/csv/README.md) / abap2xlsx) | small | snapshot |
| Event push to another system | **Event** (RAP business events / AEM) | n/a | real-time |

## Pattern 1 — OData feed for Power BI (the common case)
```abap
data(lt) = value zcl_au_analytics_gen=>tt_field(
  ( name = `region`  is_key = abap_true )
  ( name = `product` is_key = abap_true )
  ( name = `revenue` is_measure = abap_true ) ).
data(ls) = zcl_au_analytics_gen=>odata_export( iv_entity = `Sales`
                                               iv_data_source = `ztsales`
                                               it_fields = lt ).
```
1. Create DDLS `ZC_Sales` and SRVD `ZAPI_Sales` from the generated source; activate.
2. Create a **Service Binding**, type **OData V2 - Web API**, and **Publish**
   (Power BI's OData connector is happiest with V2; V4 also works).
3. Copy the service URL (the `$metadata` URL) from the binding.
4. **Power BI Desktop ➜ Get Data ➜ OData feed ➜** paste the URL ➜ authenticate ➜
   Load. (On-prem you may go through the SAP Gateway / a reverse proxy / the
   on-premises data gateway for scheduled refresh.)
5. **Keep extracts small**: rely on query folding and pass `$select`, `$filter`,
   `$top`; model mandatory filter parameters for very large sources.

> Quick legacy alternative (classic `DEFINE VIEW` only): annotate with
> `@OData.publish: true` to auto-generate a V2 service, then activate it in
> `/IWFND/MAINT_SERVICE` (on-premise).

## Pattern 2 — Analytical cube
```abap
data(lv_cube) = zcl_au_analytics_gen=>analytics_cube( iv_entity = `Sales`
                                                      iv_data_source = `ztsales`
                                                      it_fields = lt ).
```
`@Analytics.dataCategory: #CUBE` + `@DefaultAggregation: #SUM` on measures. Expose
it through an analytical OData/InA service for an Analytical List Page, an SAC
live model, or Power BI over the analytical endpoint.

## Pattern 3 — Bulk extraction to a warehouse
```abap
data(lv_extr) = zcl_au_analytics_gen=>extraction_view( iv_entity = `Sales`
                                                       iv_data_source = `ztsales`
                                                       it_fields = lt ).
```
`@Analytics.dataExtraction.enabled: true` (+ delta/CDC where the source supports
it). Consume from **SAP Datasphere** (replication/remote table), **BW/4HANA**, or
**SAP Data Intelligence / Cloud Integration** connectors. Prefer **delta** over
full loads for large tables.

## Authentication & connectivity (external consumers)
- **On-premise:** the SAP Gateway service URL + Basic/SSO; for scheduled Power BI
  refresh use the **on-premises data gateway**.
- **BTP / cloud:** a **communication arrangement** exposes the OData service;
  authenticate with OAuth2 / certificates / principal propagation. Outbound calls
  *from* ABAP use [`ZCL_AU_HTTP`](../src/http/README.md) + a destination.
- Always apply authorizations in the CDS (`@AccessControl.authorizationCheck` +
  DCL) — the OData service inherits them.

## Anti-patterns to avoid
- Don't build a custom Z-table dump + file drop when an OData service gives live,
  filtered, secured access.
- Don't extract full tables every refresh — use server-side filters or delta.
- Don't bypass authorizations by exposing raw tables; expose a CDS projection.
