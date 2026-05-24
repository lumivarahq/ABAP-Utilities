# Validation — `ZCL_AU_VALIDATE`

> Common input validators that ship in every other language's stdlib but not
> ABAP's: e-mail syntax, Luhn checksum, IBAN mod-97.

## Objects & dependencies
- `ZCL_AU_VALIDATE` — stateless utility (`class-methods`).
- Depends on: **nothing** → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `src/validate/zcl_au_validate.clas.abap` (+ `.clas.xml`, optionally
`.clas.testclasses.abap`) into a class in your package and assign it to your TR.

## How to use
```abap
zcl_au_validate=>is_email( `jane.doe@example.co.uk` ).   " abap_true
zcl_au_validate=>luhn_ok( `4111 1111 1111 1111` ).        " abap_true (Visa test no.)
zcl_au_validate=>is_iban( `GB82 WEST 1234 5698 7654 32` ).  " abap_true
```

## API
| Method | Checks |
|--------|--------|
| `is_email` | pragmatic e-mail syntax |
| `luhn_ok` | Luhn checksum (cards, some IDs); spaces ignored |
| `is_iban` | IBAN length + ISO-7064 mod-97; spaces ignored, case-insensitive |

## Tests
`zcl_au_validate.clas.testclasses.abap` checks published valid/invalid e-mails,
the Visa Luhn test number, and known-good/known-bad IBANs.

## Extending
Add `is_url`, VAT-number / national-ID checks, or `is_isbn`. Keep them pure
(no DB) so the class stays cloud-safe and unit-testable.
