# ZCL_AU_VALIDATE

AU - Validation helpers (email/Luhn/IBAN)

_Module: `validate` — generated from source by `tools/gen-api-docs.js`; do not edit by hand._

| Method | Description |
|--------|-------------|
| `is_email` | Pragmatic syntactic e-mail check (not RFC-exhaustive, but catches typos). |
| `luhn_ok` | Luhn checksum (credit-card numbers, some national IDs). Spaces are ignored. |
| `is_iban` | IBAN validation: length + the ISO-7064 mod-97 check. Spaces ignored, |
