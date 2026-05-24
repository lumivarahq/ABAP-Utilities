# Don't reinvent it — established ABAP open-source projects

Before building (or pulling a utility from here), check whether a mature
community project already solves your problem better. This library deliberately
**references** these instead of duplicating them.

> The canonical index is **[dotabap.org](https://dotabap.org/)** (source:
> [dotabap-list](https://github.com/dotabap/dotabap-list)) — every abapGit-based,
> open-source, GitHub-hosted ABAP project. Also browse
> **[awesome-abap](https://github.com/sbcgua/awesome-abap)** and
> **[abap-florilegium](https://github.com/zenrosadira/abap-florilegium)** (curated,
> categorised). Always search there first.

## Problem ➜ use this project

| Problem | Established project | Notes |
|---------|---------------------|-------|
| Version control / transport of ABAP | **[abapGit](https://github.com/abapGit/abapGit)** | the foundation; this repo is an abapGit repo |
| Excel (XLSX) read/write | **[abap2xlsx](https://github.com/abap2xlsx/abap2xlsx)** | full styling, formulas, charts — far beyond our CSV |
| JSON (mutable doc, mapping, filtering) | **[ajson](https://github.com/sbcgua/ajson)** | cloud-ready; preferred over our thin `ZCL_AU_JSON` |
| Application logging (rich) | **[ABAP Logger](https://github.com/ABAP-Logger/ABAP-Logger)** | mature alternative to our BAL wrapper |
| Test data from spreadsheets / mock DB | **[mockup_loader](https://github.com/sbcgua/mockup_loader)** | pairs with ABAP Unit + OSQL test doubles |
| Static analysis / linting in CI | **[abaplint](https://github.com/abaplint/abaplint)** | used by this repo's CI |
| In-system code checks | **[abapOpenChecks](https://github.com/larshp/abapOpenChecks)** | extra ATC-style checks |
| Build Fiori/UI5 UIs purely in ABAP | **[abap2UI5](https://github.com/abap2UI5/abap2UI5)** | UI without JS/Dynpro |
| Deep generic (de)serialization / RTTI | **[S-RTTI](https://github.com/sandraros/S-RTTI)** | serialize RTTI type descriptions |
| String-keyed maps / dictionaries | **[abap-string-map](https://github.com/sbcgua/abap-string-map)** | the hashmap ABAP lacks natively |
| Learn modern ABAP syntax & APIs | **[SAP abap-cheat-sheets](https://github.com/SAP-samples/abap-cheat-sheets)** | official, runnable examples |

## Where this library still adds value
The generic glue every team re-writes and that isn't worth a whole dependency:
strings, dates, numbers, CSV, GUIDs, messages, BAL wrapper, email, HTTP, number
ranges, locks, jobs, app-server files, hashing, base64, zip, the clock/retry/
guard patterns, the ALV→SALV bridge, the RAP message factory and the doc
generator. Each is one cherry-pickable class — see the [root README](../README.md).

## Rule of thumb
1. **Search [dotabap.org](https://dotabap.org/) first.** If a focused, maintained
   project exists (Excel, JSON, UI5, charts, PDF, JWT, OpenAPI, …), depend on it
   via abapGit (+ `apack`) rather than copying code.
2. Use **this library** for the small generic helpers and patterns that don't
   justify a separate dependency.
3. Only write something new when neither covers it — then consider contributing
   it back so it ends up on dotabap too.

## Things to look up on dotabap (commonly needed, project names vary)
PDF generation, JWT/OAuth tokens, e-mail helpers, OpenAPI/Swagger clients,
Markdown/HTML rendering, CSV/Excel, scheduling, encryption/JWE, and test
frameworks — search the [dotabap list](https://list.dotabap.org/) by keyword to
get the current, maintained project and its exact repository URL.
