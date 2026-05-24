# ZCL_AU_MESSAGE

AU - Message handling utilities

_Module: `message` — generated from source by `tools/gen-api-docs.js`; do not edit by hand._

| Method | Description |
|--------|-------------|
| `text_from_t100` | Resolve a message-class (T100) message into its formatted text. |
| `text_from_sy` | Formatted text of the message currently in the sy-msg* fields. |
| `bapiret` | Build a single BAPIRET2 line (incl. the resolved message text). |
| `bapiret_from_sy` | Build a BAPIRET2 line from the current sy-msg* fields. |
| `has_errors` | True if the table contains an error (E), abort (A) or dump (X) row. |
| `concat` | Concatenate all message texts of a BAPIRET2 table. |
