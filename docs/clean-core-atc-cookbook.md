# Clean Core & ATC Cookbook — common findings and how to fix them

Real-world problems teams hit when moving custom ABAP toward **Clean Core**, the
ATC finding behind each, and a before/after fix.

> Sources: [ATC recommendations for Clean Core governance (SAP)](https://community.sap.com/t5/technology-blog-posts-by-sap/abap-test-cockpit-atc-recommendations-for-governance-of-clean-core-abap/ba-p/14186130) ·
> [ABAP Extensibility Guide – Clean Core (SAP, 2025)](https://community.sap.com/t5/technology-blog-posts-by-sap/abap-extensibility-guide-clean-core-for-sap-s-4hana-cloud-august-2025/ba-p/14175399) ·
> [Custom Code Migration Guide for S/4HANA (SAP Help)](https://help.sap.com/doc/9dcbc5e47ba54a5cbb509afaa49dd5a1/2025.000/en-US/CustomCodeMigration_EndToEnd.pdf) ·
> [Clean Core in practice (IgniteSAP)](https://ignitesap.com/saps-clean-core-in-practice/)

## How to even see the findings

Run ATC with the SAP-delivered variants:
- **`S4HANA_READINESS`** — legacy ECC patterns, simplification items, obsolete code.
- **`CLOUD_READINESS`** — "Use of released APIs", non–cloud-ready statements.

In ADT every object also shows an **API state** (Released / Not released).
Released-API classification comes from SAP's published object list — the same
data the "Usage of released APIs" check uses. Treat **Level C/D** findings as
must-fix (C = warning: unreleased/internal object; D = error, often blocks the
transport); **Level B** is informational.

---

## 1. Direct write to an SAP DDIC table ➜ released API / BAPI / RAP

`UPDATE`/`MODIFY`/`INSERT`/`DELETE` on an SAP table is **not allowed** in Clean
Core (it bypasses the application logic and breaks on data-model changes).

### Before
```abap
update vbak set ... where vbeln = lv_vbeln.   "ATC: write access to SAP table
```
### After
```abap
" use the released API / BAPI for the business object
call function 'BAPI_SALESORDER_CHANGE' exporting ... .
" or, on a RAP BO, EML:
modify entities of i_salesorder ... .
```

## 2. Read from an SAP table via SELECT ➜ released CDS view

Direct `SELECT` on a physical SAP table is fragile across releases; use the
released CDS interface view (`I_*`) instead.

### Before
```abap
select * from mara into table @data(lt) where mtart = 'FERT'.
```
### After
```abap
select * from i_product where producttype = 'FERT' into table @data(lt).
```

## 3. Non-released function module / class ➜ released wrapper

If you must call a non-released object, Clean Core says: build a **released
wrapper** in your own namespace, get it through ATC once, and call the wrapper
everywhere.

```abap
" Your released facade (Level A), isolating the non-released call:
class zcl_pricing_facade definition public final create public.
  public section.
    class-methods get_price importing iv_matnr type matnr returning value(rv) type ... .
```
Now only one place needs an ATC exemption, and swapping the implementation later
touches one class.

## 4. Native SQL / `EXEC SQL` ➜ ABAP SQL or AMDP

### Before
```abap
exec sql. select ... endexec.            "ATC: native SQL
```
### After — ABAP SQL (preferred) or an AMDP method for HANA-pushdown
```abap
select ... from <cds> into table @data(lt).
" or CLASS ... DEFINITION ... FOR HANA DB AMDP for set-based DB logic
```

## 5. `sy-uname` / `sy-datum` / `sy-mandt` ➜ released context API

System fields are restricted in ABAP Cloud. Use the released class.

### Before
```abap
lv_user = sy-uname.   lv_today = sy-datum.
```
### After
```abap
data(lv_user)  = cl_abap_context_info=>get_user_technical_name( ).
data(lv_today) = cl_abap_context_info=>get_system_date( ).
```

## 6. Classic Dynpro / SAP GUI ALV / call screen ➜ RAP + Fiori (or OData)

Full-screen Dynpro and `CL_GUI_*` are not cloud-enabled. Expose data via a CDS
view + RAP business object + OData service, consumed by a Fiori Elements app.
(For *on-premise* GUI lists, `ZCL_AU_ALV` already modernises REUSE_ALV → SALV.)

## 7. Modification / implicit enhancement ➜ released BAdI / extension point

Replace core modifications and implicit enhancements with **released BAdIs**,
**extension points**, or the **A–D extensibility model** (key user / developer
extensibility). If no extension point exists, request one from SAP.

## 8. Access to internal SAP structures/includes ➜ public contract only

Don't reference internal includes, `TABLES`/work areas of standard programs, or
non-released types. Depend only on released CDS/types/APIs.

---

## Making fixes "automatic"
- **abaplint** (this repo's CI, `npm run lint:fix`) auto-fixes many Clean ABAP
  style findings (inline declarations, `xsdbool`, `is not initial`, etc.).
- **ADT ATC Quick Fixes** resolve a growing set of findings in-place
  (right-click a finding ➜ *Quick Fix*).
- The **Custom Code Migration** app (Cloud ATC / SAP BTP) groups findings, shows
  remediation effort, and links SAP Notes (e.g. 2215424, 2198647, 2431747 cover
  the bulk of conversion findings).
- For the rest, the **released-wrapper pattern** (§3) localises the exemption.
