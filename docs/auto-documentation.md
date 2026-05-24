# Auto-documenting ABAP code

How to get documentation "for free" from the code itself, and keep it honest.

## 1. ABAP Doc — the source of truth

Write structured doc comments with `"!` directly above declarations. ADT renders
them on hover (F2) and code completion; tools can extract them.

```abap
"! <p class="shorttext synchronized">Calculate the net price.</p>
"! Applies the customer discount and rounds commercially.
"! @parameter iv_gross  | gross amount
"! @parameter iv_discount | discount in percent (0..100)
"! @parameter rv_net    | rounded net amount
"! @raising   zcx_au_error | if the discount is out of range
methods net_price
  importing iv_gross    type decfloat34
            iv_discount type decfloat34
  returning value(rv_net) type decfloat34
  raising   zcx_au_error.
```

Conventions used throughout this repo: every **public** method has a `"!` summary
and `@parameter` lines for non-obvious parameters. (Implementation comments are
kept to a minimum — the names carry the "what", comments explain the "why".)

## 2. Enforce it in CI

abaplint can require ABAP Doc and reject empty/January-boilerplate. Add to
`abaplint.json`:

```jsonc
"rules": {
  "abap_doc": {
    "checkLocal": false,
    "classDefinition": true,
    "interfaceDefinition": true
  },
  "documentation": { "classes": true, "interfaces": true }
}
```
Now `npm run lint` fails if a public method is undocumented — documentation can't
rot silently.

## 3. Generate browsable docs

- **abapGit + this repo's per-module `README.md`** is itself the doc site: each
  utility folder documents its API and examples. Keep the README's API table in
  sync (the `documentation` rule helps).
- **Markdown export (in-system)**: [`ZCL_AU_DOCGEN`](../src/docgen/README.md)
  walks a class via RTTI and emits a Markdown API table at runtime.
- **Markdown export (offline / CI)**: `tools/gen-api-docs.js` (run `npm run docs`)
  parses the abapGit sources and writes [`docs/api/`](api/README.md). The
  `api-docs` GitHub Actions workflow regenerates it, **fails the build if it
  drifts** from the committed output, and publishes it as an artifact — so the
  API reference always matches the code.
- **SAP Knowledge Transfer (KT) docs** / object documentation (`SE61`) for
  end-user facing texts.

## 4. Diagrams & overviews
- ADT *UML class diagram* (right-click a class ➜ *Show in ➜ Class Diagram*).
- For dependency overviews, generate a Mermaid graph from the per-module
  dependency table in the root README.

## Rule of thumb
Document the **contract** (what callers rely on) in ABAP Doc; document the
**reasoning** (why this way) in short inline comments; let names document the
**mechanics**. Generated artifacts should be produced from the code, never
hand-maintained in parallel.
