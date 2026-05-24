# From BDC / CALL TRANSACTION to BAPI / RAP

Batch-input and `CALL TRANSACTION` automate the **UI** of a transaction — they
replay keystrokes against dynpros. That makes them brittle (any screen change
breaks them), slow, hard to error-handle, and **not available in ABAP Cloud**.
The modern, Clean-Core path is to call the **business logic** directly: a
released BAPI/API, RAP (EML), or OData.

> See also [Clean Core & ATC Cookbook](clean-core-atc-cookbook.md) ·
> [API Usage Cookbook](api-usage-cookbook.md).

## Decision tree
1. **Released BAPI / API** for the object? → use it (e.g. `BAPI_*`, a released
   class, or a released function module).
2. **RAP business object** for the object? → use **EML** (`MODIFY ENTITIES …`).
3. **OData service** only? → call it via [`ZCL_AU_HTTP`](../src/http/README.md).
4. **Nothing released?** → keep the legacy call **behind a released wrapper**
   ([`ZCL_AU_WRAP_GEN`](../src/wrapper/README.md)) and plan its replacement.
   Never spread `CALL TRANSACTION` across the code base.

## Before / after

### Before — CALL TRANSACTION with batch input
```abap
data lt_bdc type table of bdcdata.
perform fill_bdc using 'SAPMV45A' '0101' 'X'.
perform fill_bdc using 'VBAK-AUART' 'OR'.
" ...dozens of screen/field rows...
call transaction 'VA01' using lt_bdc mode 'N' update 'S'
  messages into lt_messages.            "breaks when the screen changes
```

### After — released BAPI (with proper error handling)
```abap
data lt_return type bapiret2_t.
call function 'BAPI_SALESORDER_CREATEFROMDAT2'
  exporting order_header_in = ls_header
  importing salesdocument   = data(lv_vbeln)
  tables    order_items_in  = lt_items
            return          = lt_return.

if zcl_au_message=>has_errors( lt_return ).
  rollback work.                         "BAPIs need explicit commit/rollback
  zcl_au_error=>raise( zcl_au_message=>concat( lt_return ) ).
else.
  call function 'BAPI_TRANSACTION_COMMIT' exporting wait = abap_true.
endif.
```

### After — RAP (EML), the cloud-native option
```abap
modify entities of zi_salesorder
  entity salesorder
  create fields ( ordertype ) with value #( ( %cid = 'c1' ordertype = 'OR' ) )
  reported data(reported)
  failed   data(failed)
  mapped   data(mapped).
if failed is initial.
  commit entities responses failed data(commit_failed).
endif.
```

## Mapping checklist (BDC ➜ API)
- **Screen fields ➜ parameters/structures**: map each `BDC-FNAM/FVAL` to a BAPI
  structure field or RAP entity field. Drop UI-only steps (OK-codes, tabs).
- **Messages**: the BDC `messages` table becomes `BAPIRET2` — inspect with
  [`ZCL_AU_MESSAGE`](../src/message/README.md) and persist with
  [`ZCL_AU_LOGGER`](../src/logger/README.md).
- **Commit**: BAPIs require `BAPI_TRANSACTION_COMMIT` (or `COMMIT WORK`); RAP uses
  `COMMIT ENTITIES`. Don't rely on the transaction's implicit commit.
- **Mass runs**: replace "loop + CALL TRANSACTION" with a single bulk API call or
  package processing; wrap transient failures with
  [`ZCL_AU_RETRY`](../src/retry/README.md).

## When BDC truly can't be avoided (yet)
Some old transactions have no API. Then:
- Isolate the `CALL TRANSACTION` in **one** released wrapper class
  (`ZCL_AU_WRAP_GEN`) with a clean, typed signature.
- Return `BAPIRET2`/raise `ZCX_AU_ERROR`; never surface raw screen messages.
- Track it as technical debt and revisit when SAP releases an API.

## ABAP Cloud
`CALL TRANSACTION` / batch input / `BDC_*` are **not released**. There is no
cloud equivalent — you must move to released APIs or RAP. Use this cookbook's
"after" patterns directly.
