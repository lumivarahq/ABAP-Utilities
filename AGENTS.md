# ABAP & RAP Utilities

Plug-and-play, expandable collection of generic ABAP/RAP utility classes (single-class,
mostly dependency-free) for SAP teams: ABAP on-prem, S/4HANA, ABAP Cloud / Clean Core.
Public MIT, distributed via abapGit. Lumivara product line: **SAP**.

## Package manager + commands
npm (`package-lock.json`, devDep `@abaplint/cli` pinned 2.119.24). No app build/test — JS tools only.
- `npm install` / `npm ci` — install pinned abaplint.
- `npm run lint` — **the verify gate** (abaplint, config `abaplint.json`). `npm run lint:fix` to autofix.
- `npm run docs` — regenerate `docs/api/` from ABAP sources (`tools/gen-api-docs.js`). CI fails if `docs/api` is stale, so commit the result.
- `npm run index` — regenerate MCP index (`tools/gen-mcp-index.js`, output in `index/`).
- `npm run changelog` / `npm run metrics` — DORA proxies + Conventional-Commits changelog (`tools/dev-metrics.js`).

## Verification scope (IMPORTANT)
abaplint statically parses/style-checks WITHOUT an SAP backend — it cannot resolve the
standard SAP class library or run ABAP Unit. Activation + ABAP Unit (`*.clas.testclasses.abap`)
must run on a real ABAP system (ADT or abapGit). Don't expect tests to run locally; `npm run lint` is the only local gate.

## Layout
- `src/<tool>/` — one abapGit sub-package per utility (~40: error, string, date, json, logger, rap, alv, http, email, dynsql, fiori, …). Each folder = `zcl_au_<tool>.clas.abap` + `.clas.xml` + per-module `README.md`; objects prefixed `ZCL_AU_`/`ZIF_AU_`/`ZCX_AU_`.
- `src/demo/` — `ZAU_DEMO` report combining several utilities.
- `docs/` — cookbooks/guides (recipes.md = task→tool index; clean-core-*, fiori, rap-cds, anti-patterns, MCP-INTEGRATION, generated `docs/api/`).
- `tools/` — Node helper scripts (api-docs, mcp-index, dev-metrics, ollama-review.sh).
- `index/` — generated MCP search index. `ARCHITECTURE.md` = dependency/cloud policy. `CONTRIBUTING.md` = how to add a utility.

## Install / abapGit
`.abapgit.xml`: STARTING_FOLDER=`/src/`, FOLDER_LOGIC=`PREFIX` — folder `string` → sub-package `ZAU_STRING` under your root package. Cherry-pick a single dependency-free class into a transport, or pull the whole repo. Only cross-dep: most exception-raising tools need the `error` module (`ZCX_AU_ERROR`) first.

## Deploy / CI
No web deploy (it's an ABAP source library). GitHub Actions on every branch+PR: `abaplint.yml` (runs `npm run lint`), `api-docs.yml` (regenerates `docs/api` and fails if out of date, publishes artifact).

## Gotchas
- Cloud-ready column in README: ✅ released APIs only, ⚠️ check release state of a dependency, ❌ SAP GUI/classic (OPEN DATASET, Dynpro) — final proof is ATC `CLOUD_READINESS` on target.
- After touching any `.clas.abap`, run `npm run docs` and commit `docs/api` or api-docs CI breaks.
- This repo prefers referencing mature community projects (abap2xlsx, ajson, ABAP-Logger) over reinventing — see README "Why this repo exists" + `docs/related-projects.md` before adding anything.
