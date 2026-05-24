# Modernizing toward BTP / RAP / CDS

How to move classic custom ABAP (reports, module pools, direct table access)
toward the **Clean Core target picture**: CDS data models, RAP behavior, OData
services and Fiori — runnable on SAP S/4HANA and the SAP BTP ABAP environment.

> Sources: [ABAP RESTful Application Programming Model (SAP)](https://pages.community.sap.com/topics/abap/rap) ·
> [ABAP Extensibility Guide – Clean Core (SAP, 2025)](https://community.sap.com/t5/technology-blog-posts-by-sap/abap-extensibility-guide-clean-core-for-sap-s-4hana-cloud-august-2025/ba-p/14175399) ·
> [Custom Code Migration Guide (SAP Help)](https://help.sap.com/doc/9dcbc5e47ba54a5cbb509afaa49dd5a1/2025.000/en-US/CustomCodeMigration_EndToEnd.pdf)

## The target stack (and why each layer exists)

```
Database tables  (SAP standard or your custom tables)
      │  released CDS interface views  (I_*)        ← stable contract, VDM
      ▼
CDS data model   basic → composite → consumption (C_*)
      │  + UI annotations, associations, parameters, access control (DCL)
      ▼
RAP behavior     managed | unmanaged | abstract     ← transactional logic, EML
      │  determinations, validations, actions, draft
      ▼
Service def + binding  (OData V4 / V2)              ← the API
      ▼
Fiori Elements / custom UI / external consumers
```

- **CDS over `SELECT *` on tables:** survives data-model changes, pushes logic to
  HANA, is reusable and analytics-ready.
- **RAP over module pools / function modules:** one transactional model that
  serves OData, EML and Fiori; cloud-ready; testable.
- **Service binding over hand-built gateway:** declarative, versioned API.

## Migration path from a classic report

### Before — report with direct table access
```abap
report z_open_items.
select * from bsid into table @data(lt) where bukrs = p_bukrs.   "ATC: SAP table
loop at lt into data(ls). write: / ls-belnr, ls-wrbtr. endloop.
```

### After — CDS consumption view (+ optional Fiori, no ABAP UI code)
```abap
@AccessControl.authorizationCheck: #CHECK
define view entity ZC_OpenItem
  as select from I_OperationalAcctgDocItem   -- released interface view
{
  key AccountingDocument,
      CompanyCode,
      AmountInCompanyCodeCurrency as Amount,
      _CompanyCode.CompanyCodeName            -- via association
}
where IsOpenItem = 'X'
```
Expose it with a **service definition** + **service binding (OData V4)**; a Fiori
Elements List Report needs zero ABAP UI code, just annotations.

## Transactional apps — RAP in one page

**Managed** (framework owns persistence — most new apps):
```abap
managed implementation in class zbp_i_travel unique;
define behavior for ZI_Travel alias Travel
persistent table ztravel
lock master
authorization master ( instance )
{
  field ( readonly ) TravelID;
  create; update; delete;
  validation validateDates on save { field BeginDate, EndDate; }
  determination setStatus on modify { create; }
  action ( features : instance ) acceptTravel result [1] $self;
}
```
**Unmanaged** when you must reuse existing logic/BAPIs (Clean-Core wrapper).
**Draft** (`with draft;`) for Fiori draft-enabled apps.

Behavior implementations use **EML** to read/modify business objects in a
type-safe way; raise messages with [`ZCL_AU_RAP_MSG`](../src/rap/README.md).

## CDS good practice (VDM)
- **Layering & naming:** basic/interface views `I_*` (reusable contract),
  consumption views `C_*`/`ZC_*` (UI/annotations). Don't put UI annotations on
  interface views.
- **Associations** instead of joins where you navigate (`_CompanyCode`).
- **Parameters** for reusable filters; **DCL** (`@AccessControl`) for row-level
  authorizations.
- **Extend, don't modify:** `extend view entity` / metadata extensions.
- **Annotations** drive Fiori (`@UI`), analytics (`@Analytics`), search
  (`@Search`) — declarative instead of code.

## ATC / language version for the cloud
- Set the package **ABAP language version** to *ABAP for Cloud Development* — the
  compiler then only allows released APIs.
- Run **`CLOUD_READINESS`** + **`S4HANA_READINESS`** ATC variants.
- Replace the patterns in the [Clean Core & ATC Cookbook](clean-core-atc-cookbook.md)
  and use released replacements from the [API Usage Cookbook](api-usage-cookbook.md).

## BTP ABAP environment (Steampunk) specifics
- Development is **ADT-only** (no SAP GUI), Git-based (abapGit / gCTS).
- Everything is ABAP for Cloud: only released APIs, CDS, RAP, no Dynpro/`OPEN
  DATASET`/classic BCS.
- Integrate via **communication arrangements / destinations** (see
  [`ZCL_AU_HTTP`](../src/http/README.md)), events (AEM), and OData.

## How this library helps the journey
| Need on the way to RAP/CDS | Utility |
|----------------------------|---------|
| Stop using `sy-uname`/`sy-datum` | [`ZCL_AU_CONTEXT`](../src/context/README.md) |
| RAP messages for `reported`/`failed` | [`ZCL_AU_RAP_MSG`](../src/rap/README.md) |
| Call external/released services | [`ZCL_AU_HTTP`](../src/http/README.md) |
| Cloud-safe JSON | [`ZCL_AU_JSON`](../src/json/README.md) (→ ajson/XCO) |
| Testable time, retries, guards | [clock](../src/clock/README.md) · [retry](../src/retry/README.md) · [guard](../src/guard/README.md) |
| Generate API docs from RTTI | [`ZCL_AU_DOCGEN`](../src/docgen/README.md) |

The on-premise utilities (ALV, OPEN DATASET, BAL, BCS, jobs, locks) each name
their **cloud-released replacement** in their README, so you can migrate module
by module rather than all at once.
