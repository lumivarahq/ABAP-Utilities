# Email — `ZCL_AU_EMAIL`

> A fluent builder over BCS (`CL_BCS`) for the thing everyone re-implements:
> send an HTML/plain mail with attachments, in a few readable lines.

## Objects & dependencies
- `ZCL_AU_EMAIL` — fluent builder.
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module) and the
  classic **BCS** classes (`CL_BCS`, `CL_DOCUMENT_BCS`, `CL_CAM_ADDRESS_BCS`,
  `CL_BCS_CONVERT`).

> ⚠️ **ABAP Cloud:** classic BCS is not released. On ABAP Cloud / S/4HANA Cloud
> use `CL_BCS_MAIL` (the released mail API). The fluent shape here maps almost
> 1:1, so swapping the `send( )` body is straightforward.
>
> ℹ️ Sending requires SMTP/SCOT to be configured (transactions `SCOT`/`SOST`).

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/email/zcl_au_email.clas.abap` (+ `.clas.xml`).
3. Assign both objects to your TR.

## How to use

```abap
data(lv_csv) = zcl_au_csv=>from_table( lt_orders ).   "e.g. reuse the CSV module

zcl_au_email=>create(
  )->subject( |Daily orders { sy-datum date = user }|
  )->from( `noreply@acme.com`           "optional; defaults to current user
  )->to( `ops@acme.com`
  )->cc( `lead@acme.com`
  )->body_html( `<p>Attached are today's orders.</p>`
  )->attach_text( iv_filename = `orders.csv` iv_content = lv_csv iv_type = 'CSV'
  )->send( ).

" Binary attachment (e.g. a PDF you generated as xstring)
zcl_au_email=>create(
  )->subject( `Invoice`
  )->to( `customer@example.com`
  )->body_text( `Please find your invoice attached.`
  )->attach_binary( iv_filename = `invoice.pdf` iv_content = lv_pdf_xstring iv_type = 'PDF'
  )->send( ).
```

## API
| Method | Purpose |
|--------|---------|
| `create` | start a new mail |
| `subject` / `from` / `to` / `cc` | headers & recipients (chainable) |
| `body_text` / `body_html` | set the body (plain or HTML) |
| `attach_text` / `attach_binary` | add attachments |
| `send( iv_commit )` | build & send; returns `abap_true` if accepted for all |

## Tests
Sending needs a configured mail system, so verify by activation + a real send /
SOST check rather than ABAP Unit. Unit-test **callers** by abstracting the send
behind your own interface if you need isolation.

## Extending
Add BCC, importance/sensitivity, read receipts, distribution lists, or recipients
resolved from SAP users (`cl_sapuser_bcs=>create`).
