# ZIF_AU_LOG

AU - Application log interface

_Module: `logger` — generated from source by `tools/gen-api-docs.js`; do not edit by hand._

| Method | Description |
|--------|-------------|
| `info` |  |
| `success` |  |
| `warning` |  |
| `error` |  |
| `add_exception` | Add an exception together with its full "previous" chain. |
| `add_bapiret` | Add all rows of a BAPIRET2 return table. |
| `add_from_sy` | Add the message currently held in the sy-msg* fields. |
| `save` | Persist the log to the database (BAL). |
| `handle` | The underlying BAL log handle (for advanced/native use). |
