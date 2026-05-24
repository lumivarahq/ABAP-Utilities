# ZCL_AU_EMAIL

AU - Email sender (BCS)

_Module: `email` — generated from source by `tools/gen-api-docs.js`; do not edit by hand._

| Method | Description |
|--------|-------------|
| `create` | Fluent e-mail builder over BCS (CL_BCS). Example: |
| `subject` |  |
| `from` | Optional explicit sender (defaults to the current user if omitted). |
| `to` |  |
| `cc` |  |
| `body_text` |  |
| `body_html` |  |
| `attach_text` | Add a text attachment (e.g. CSV, TXT, XML). |
| `attach_binary` | Add a binary attachment (e.g. PDF, XLSX). |
| `send` | Build and send the mail. Returns abap_true if accepted for all recipients. |
