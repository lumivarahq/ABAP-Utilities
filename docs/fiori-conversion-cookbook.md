# Converting small apps (ALV, SM30, reports) to Fiori

The modern, Clean-Core way to give a classic app a Fiori tile is **not** to
"render" UI from ABAP — it's to expose the data as **CDS → RAP → OData (Service
Binding) → Fiori Elements**, which produces a List Report / Object Page with
*zero* UI code. [`ZCL_AU_FIORI_GEN`](../src/fiori/README.md) generates the
boilerplate; this cookbook shows the patterns and the end-to-end steps.

> Source: [ABAP RESTful Application Programming Model (SAP)](https://pages.community.sap.com/topics/abap/rap) ·
> see also [RAP/CDS/BTP modernization](rap-cds-modernization.md).

## The target in one picture
```
table  ──►  ZI_<e> (interface view)  ──►  ZC_<e> (projection + @UI)  ──►  service binding (OData V4 UI)  ──►  Fiori Elements tile
                     ▲ behavior (managed: C/U/D)        ▲ projection behavior
```

## Pattern 1 — Table maintenance (SM30 / `SE16` editing) ➜ "Manage <X>" app
This is the sweet spot. Generate a **managed** RAP app over the table:
```abap
data(lt) = zcl_au_fiori_gen=>fields_from_structure( 'ZTPRODUCT' ).
" set the real key field(s):
modify lt from value #( is_key = abap_true ) transporting is_key where name = 'product_id'.
data(ls) = zcl_au_fiori_gen=>generate( iv_entity = `Product` iv_data_source = `ztproduct` it_fields = lt ).
```
Paste `ls-interface_view`, `ls-projection_view`, `ls-behavior`,
`ls-projection_behavior`, `ls-service_definition` into new ADT objects, activate,
then follow `ls-service_binding`. Result: a Fiori list with create/edit/delete —
the SM30 replacement, transportable and authorization-aware.

## Pattern 2 — ALV report ➜ Fiori List Report
Reuse the field catalog you already build:
```abap
data(lt) = zcl_au_fiori_from_alv=>fields( lt_fcat ).   "hidden/tech columns dropped, key & labels mapped
data(ls) = zcl_au_fiori_gen=>generate( iv_entity = `Order` iv_data_source = `ztorder` it_fields = lt ).
```
If the ALV is read-only, you can drop the behavior objects and expose only the
projection (delete `create/update/delete` from the generated BDEF or skip the
BDEFs entirely for a display-only list).

## Pattern 3 — Selection-screen report ➜ Fiori with filter bar
- Map each `SELECT-OPTION`/`PARAMETER` to a `@UI.selectionField` (the generator
  adds `selectionField` positions you can keep/trim).
- Move the report's logic into the CDS (filters, calculations, associations) or a
  RAP query implementation; the Fiori filter bar replaces the selection screen.

## End-to-end steps (ADT)
1. Create the DDLS / BDEF / SRVD objects from the generated source; **activate**.
2. Create a **Service Binding** on `ZUI_<entity>`, binding type **OData V4 - UI**;
   **Publish**.
3. **Preview** from the binding (instant Fiori Elements preview), or
4. Add a **tile**: Launchpad content / target mapping to the published service
   (Fiori Launchpad Designer on-prem, or the Launchpad service on BTP).

## Draft, value help, and polish
- **Draft** (recommended for edit apps): add `with draft;` to the behavior plus a
  draft table, and `draft;` operations. The generator omits draft by default so
  the output activates without an extra object.
- **Value helps**: add `@Consumption.valueHelpDefinition` / foreign-key
  associations on the relevant fields.
- **Texts & units**: associate text views (`@ObjectModel.text.element`) and
  currency/unit references (`@Semantics.amount.currencyCode`).
- **Authorizations**: replace `authorization master ( global )` with instance
  authorization + a CDS access control (DCL) for row-level checks.

## Cloud notes
- `ZCL_AU_FIORI_GEN` is cloud-safe (RTTI only). `ZCL_AU_FIORI_FROM_ALV` references
  LVC types (on-premise) — on cloud, seed fields with `fields_from_structure`.
- The generated CDS/RAP/SRVD artifacts are the cloud-native target themselves.

## When to use the ADT RAP Generator instead
For a guided, full-featured app (incl. draft, generated draft table, projection,
service, and a sample UI), use the ADT **"Generate ABAP Repository Objects"**
(RAP Generator) wizard. Use `ZCL_AU_FIORI_GEN` when you want a **fast, scriptable,
bulk** start (e.g. many tables) or to fold an existing **ALV field catalog** into
the model.
