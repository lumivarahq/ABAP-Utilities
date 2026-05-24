# ABAP & RAP Utilities

A **plug-and-play, expandable** collection of generic ABAP / RAP utilities for
modern SAP development teams (ABAP on-premise, S/4HANA, and — where noted —
ABAP Cloud / clean core).

Every utility is:

- **Self-contained** – almost all utilities are a single class with **zero
  project dependencies**, so you can grab just the one you need.
- **Cherry-pickable into a transport** – the repository is split into one
  abapGit sub-package per utility. You can pull (or copy) only the folder you
  want and assign only those objects to your transport request — you never have
  to take the whole repository. See [Install](#install).
- **Documented** – each module folder has its own `README.md` with a how-to and
  copy-paste examples.
- **Tested** – core utilities ship with ABAP Unit tests, and the whole tree is
  verified with [abaplint](https://abaplint.org) in CI.

---

## Why this repo exists (and what it deliberately does *not* reinvent)

Some problems are already solved extremely well by mature community projects.
This library **references** those instead of duplicating them, and focuses on
the small, generic helpers that every team otherwise rewrites from scratch.

| Need | Use this established project instead | 
|------|--------------------------------------|
| Excel (XLSX) generation / parsing | [abap2xlsx](https://github.com/abap2xlsx/abap2xlsx) |
| Full-featured JSON (cloud-ready, mutable document) | [ajson](https://github.com/sbcgua/ajson) |
| Rich application logging UI / framework | [ABAP Logger](https://github.com/ABAP-Logger/ABAP-Logger) |
| Test data from spreadsheets / mocking DB | [mockup_loader](https://github.com/sbcgua/mockup_loader) |
| Git client inside the system | [abapGit](https://github.com/abapGit/abapGit) |
| Curated index of open-source ABAP | [dotabap.org](https://dotabap.org) · [awesome-abap](https://github.com/sbcgua/awesome-abap) · [abap-florilegium](https://github.com/zenrosadira/abap-florilegium) |

The thin wrappers here (e.g. `ZCL_AU_JSON`, `ZCL_AU_LOGGER`) are convenience
layers — the per-module READMEs tell you when to graduate to the full library.

**Before building anything, search [dotabap.org](https://dotabap.org/).** See
[docs/related-projects.md](docs/related-projects.md) for a problem ➜ project map
(Excel, JSON, UI5, RTTI, maps, linting, …) so you reuse instead of reinvent.

---

## Utility catalog

| Module | Package / folder | Object(s) | Depends on | Cloud-ready* |
|--------|------------------|-----------|------------|:---:|
| [Error](src/error/README.md)     | `ZAU_ERROR` `/src/error`     | `ZCX_AU_ERROR` | – | ✅ |
| [String](src/string/README.md)   | `ZAU_STRING` `/src/string`   | `ZCL_AU_STRING` | – | ✅ |
| [Date](src/date/README.md)       | `ZAU_DATE` `/src/date`       | `ZCL_AU_DATE` | – | ✅ |
| [Number](src/number/README.md)   | `ZAU_NUMBER` `/src/number`   | `ZCL_AU_NUMBER` | – | ✅ |
| [GUID](src/guid/README.md)       | `ZAU_GUID` `/src/guid`       | `ZCL_AU_GUID` | – | ✅ |
| [CSV](src/csv/README.md)         | `ZAU_CSV` `/src/csv`         | `ZCL_AU_CSV` | – | ✅ |
| [Internal tables](src/itab/README.md) | `ZAU_ITAB` `/src/itab`  | `ZCL_AU_ITAB` | – | ✅ |
| [Message](src/message/README.md) | `ZAU_MESSAGE` `/src/message` | `ZCL_AU_MESSAGE` | – | ✅ |
| [JSON](src/json/README.md)       | `ZAU_JSON` `/src/json`       | `ZCL_AU_JSON` | `/UI2/CL_JSON` | ⚠️ |
| [Logger](src/logger/README.md)   | `ZAU_LOGGER` `/src/logger`   | `ZIF_AU_LOG`, `ZCL_AU_LOGGER` | `ZCX_AU_ERROR`, BAL | ⚠️ |
| [RAP](src/rap/README.md)         | `ZAU_RAP` `/src/rap`         | `ZCL_AU_RAP_MSG` | RAP runtime | ✅ |
| [ALV (SALV)](src/alv/README.md)  | `ZAU_ALV` `/src/alv`         | `ZCL_AU_ALV` (+ `ZIF_AU_ALV_HANDLER`, `ZCL_AU_ALV_EVENTS` for events) | – | ❌ |
| [SAPscript text](src/text/README.md) | `ZAU_TEXT` `/src/text`   | `ZCL_AU_TEXT` | `ZCX_AU_ERROR`, READ_TEXT | ⚠️ |
| [Email](src/email/README.md)     | `ZAU_EMAIL` `/src/email`     | `ZCL_AU_EMAIL` | `ZCX_AU_ERROR`, BCS | ⚠️ |
| [HTTP/REST](src/http/README.md)  | `ZAU_HTTP` `/src/http`       | `ZCL_AU_HTTP` | `ZCX_AU_ERROR` | ✅ |
| [Number range](src/numrange/README.md) | `ZAU_NUMRANGE` `/src/numrange` | `ZCL_AU_NUMRANGE` | `ZCX_AU_ERROR` | ⚠️ |
| [Context](src/context/README.md) | `ZAU_CONTEXT` `/src/context` | `ZCL_AU_CONTEXT` | – | ✅ |
| [Base64](src/base64/README.md)   | `ZAU_BASE64` `/src/base64`   | `ZCL_AU_BASE64` | – | ✅ |
| [Hash](src/hash/README.md)       | `ZAU_HASH` `/src/hash`       | `ZCL_AU_HASH` | `ZCX_AU_ERROR` | ⚠️ |
| [Zip](src/zip/README.md)         | `ZAU_ZIP` `/src/zip`         | `ZCL_AU_ZIP` | `ZCX_AU_ERROR` | ⚠️ |
| [Stopwatch](src/timer/README.md) | `ZAU_TIMER` `/src/timer`     | `ZCL_AU_TIMER` | – | ⚠️ |
| [Config/toggles](src/config/README.md) | `ZAU_CONFIG` `/src/config` | `ZCL_AU_CONFIG` | TVARVC | ⚠️ |
| [Feature flags](src/featureflag/README.md) | `ZAU_FEATUREFLAG` `/src/featureflag` | `ZIF_AU_FEATURE_FLAG`, `ZCL_AU_FEATURE_FLAG` | – | ✅ |
| [Safe dynamic SQL](src/dynsql/README.md) | `ZAU_DYNSQL` `/src/dynsql` | `ZCL_AU_DYN_SQL` | `ZCX_AU_ERROR` | ✅ |
| [App-server files](src/dataset/README.md) | `ZAU_DATASET` `/src/dataset` | `ZCL_AU_DATASET` | `ZCX_AU_ERROR`, OPEN DATASET | ❌ |
| [Locking](src/lock/README.md)    | `ZAU_LOCK` `/src/lock`       | `ZCL_AU_LOCK` | `ZCX_AU_ERROR`, ENQUEUE | ⚠️ |
| [Background jobs](src/job/README.md) | `ZAU_JOB` `/src/job`     | `ZCL_AU_JOB` | `ZCX_AU_ERROR`, JOB FMs | ⚠️ |
| [Doc generator](src/docgen/README.md) | `ZAU_DOCGEN` `/src/docgen` | `ZCL_AU_DOCGEN` (+ report `ZAU_DOCGEN`) | `ZCX_AU_ERROR` | ✅ |
| [Fiori scaffolding](src/fiori/README.md) | `ZAU_FIORI` `/src/fiori` | `ZCL_AU_FIORI_GEN` (+ `ZCL_AU_FIORI_FROM_ALV`) | `ZCX_AU_ERROR` | ✅ |
| [Released-wrapper gen](src/wrapper/README.md) | `ZAU_WRAPPER` `/src/wrapper` | `ZCL_AU_WRAP_GEN` | `ZCX_AU_ERROR` | ✅ |
| [Data export gen](src/export/README.md) | `ZAU_EXPORT` `/src/export` | `ZCL_AU_ANALYTICS_GEN` | `ZCX_AU_ERROR` | ✅ |
| [Clock](src/clock/README.md)     | `ZAU_CLOCK` `/src/clock`     | `ZIF_AU_CLOCK`, `ZCL_AU_CLOCK` | – | ✅ |
| [Retry](src/retry/README.md)     | `ZAU_RETRY` `/src/retry`     | `ZIF_AU_RUNNABLE`, `ZCL_AU_RETRY` | `ZCX_AU_ERROR` | ⚠️ |
| [Guard](src/guard/README.md)     | `ZAU_GUARD` `/src/guard`     | `ZCL_AU_GUARD` | `ZCX_AU_ERROR` | ✅ |
| [Test data](src/test/README.md)  | `ZAU_TEST` `/src/test`       | `ZCL_AU_TEST_DATA` | – | ✅ |

\* **Cloud-ready** = is this object usable in *ABAP for Cloud Development* (Clean
Core)? ✅ = uses only released APIs / cloud-enabled language to the best of our
knowledge. ⚠️ = depends on a class/framework whose release state must be checked
(the module README names the released alternative). ❌ = SAP GUI / classic Dynpro
or statements (`OPEN DATASET`, dynamic `SUBMIT`, …) with no cloud equivalent.
**Final proof is always ATC `CLOUD_READINESS` on your target** — see the
[Clean Core readiness matrix](docs/clean-core-readiness.md) for the per-object
audit (which exact API blocks each ⚠️/❌ and its replacement).

---

## Install

### Prerequisites

- [abapGit](https://docs.abapgit.org) installed in your system.
- A Z/Y customer package to import into.

### Option A — Whole library (online repository)

1. abapGit ➜ *New Online* ➜ this repository URL.
2. Target package e.g. `ZAU` (a package you own).
3. *Pull*. abapGit recreates the sub-packages using **your** package as the
   prefix (folder `string` ➜ sub-package `ZAU_STRING`, etc.) thanks to
   `FOLDER_LOGIC = PREFIX` in [`.abapgit.xml`](.abapgit.xml).
4. Assign the objects to your transport when prompted.

### Option B — Cherry-pick a single utility into your transport ⭐

Because each utility lives in its own folder and is dependency-free, you can take
*only* what you need:

1. Open the module folder you want, e.g. [`src/string`](src/string).
2. In your system, create (or reuse) one class with the source of
   `*.clas.abap` — for `ZCL_AU_STRING` that is one global class, no includes
   except the optional test include.
3. Activate and assign **only that class** to your transport request.

> The per-module README lists the **exact object list** and any dependency, so
> you know precisely what goes into your TR — never the whole repo.

For the two modules that have a dependency (`Logger` ➜ `ZCX_AU_ERROR`), grab the
`Error` module first; everything else is standalone.

### Naming / namespace

Objects use the prefix `ZCL_AU_` / `ZIF_AU_` / `ZCX_AU_`. If your team uses a
different prefix or a reserved namespace, rename on import (find & replace in the
sources, or use abapGit's repo-level rename) — the utilities have no hard-coded
references to their own names.

---

## Verify / build

The whole source tree is linted with abaplint:

```bash
npm install      # installs @abaplint/cli
npm run lint     # abaplint, configured by abaplint.json
```

ABAP Unit tests live next to each class (`*.clas.testclasses.abap`). Run them in
ADT (*Run As ➜ ABAP Unit Test*) or via `abapGit` ➜ the system's unit runner once
the objects are activated in a real system.

> **Note on verification scope:** abaplint statically parses and style-checks the
> code without an SAP backend, so it cannot resolve the standard SAP class
> library or execute ABAP Unit. Activation and the unit tests must be run on a
> real ABAP system. Every utility was written against released/standard APIs and
> documents its dependencies.

---

## Cookbooks & guides (`docs/`)

Guidance for the things that are *patterns*, not classes — each with copy-paste
before/after ABAP:

| Guide | What it covers |
|-------|----------------|
| [Anti-patterns → remediation playbook](docs/anti-patterns-playbook.md) | **start here** — every common ABAP bad habit mapped to a tool here, an external project, or a how-to |
| [Dev workflow](docs/dev-workflow.md) | git hooks, Conventional Commits, CI gates, branch/PR flow, ADR/postmortem/review templates |
| [Clean Core & ATC Cookbook](docs/clean-core-atc-cookbook.md) | top ATC findings (SAP-table writes, unreleased APIs, native SQL, sy-fields, Dynpro) with fixes |
| [RAP / CDS / BTP Modernization](docs/rap-cds-modernization.md) | the target stack, migrating reports to CDS+RAP+Fiori, VDM, managed/unmanaged RAP, BTP specifics |
| [Fiori Conversion Cookbook](docs/fiori-conversion-cookbook.md) | turn table maintenance (SM30), ALV reports and selection-screen reports into Fiori tiles (with `ZCL_AU_FIORI_GEN`) |
| [Data Export Cookbook](docs/data-export-cookbook.md) | export reports/CDS to Power BI & external systems via OData / analytics / extraction (with `ZCL_AU_ANALYTICS_GEN`) |
| [BDC → BAPI/RAP Cookbook](docs/bdc-to-api-cookbook.md) | replace `CALL TRANSACTION` / batch input with released BAPIs, RAP (EML) or OData |
| [Generated API reference](docs/api/README.md) | auto-generated method reference for every class/interface (`npm run docs`; published in CI) |
| [Internal Tables Cookbook](docs/internal-tables-cookbook.md) | remove nested loops, sorted vs hashed, table expressions, `FOR`/`REDUCE`/`FILTER`/`GROUP BY` |
| [Parallel Processing Cookbook](docs/parallel-processing-cookbook.md) | aRFC & SPTA patterns, throttling, LUW rules, the cloud alternative |
| [API Usage Cookbook](docs/api-usage-cookbook.md) | released replacements cheat-sheet + the released-wrapper pattern |
| [Auto-documentation](docs/auto-documentation.md) | ABAP Doc, enforcing it in CI, generating docs |
| [Underused standard features](docs/underused-standard-features.md) | PCRE regex, meshes, enums, RTTI, XCO, codepage, test doubles, … |
| [Cross-language ideas](docs/cross-language-ideas.md) | DI, TDD, CI linting, fluent APIs, result objects, feature toggles |
| [Clean Core readiness matrix](docs/clean-core-readiness.md) | per-object audit: cloud-safe set, the API blocking each ⚠️/❌, and its released replacement |
| [Related projects](docs/related-projects.md) | "use this instead" map to established dotabap projects (don't reinvent) |
| [Local AI review with Ollama](docs/ollama-code-review.md) | free, offline LLM reviewer for your diffs (`tools/ollama-review.sh`) |

## Architecture, scaling & "does it need splitting?"

See [ARCHITECTURE.md](ARCHITECTURE.md) for the dependency policy, the cloud-vs-
on-premise strategy, the verification approach, and a concrete answer to whether
the repo should be trimmed or split (short version: stay single-repo of
independent packages; group in docs as it grows; only spin a module into its own
repo when it develops a real sub-ecosystem).

## Expanding the library

Adding a new utility is intentionally mechanical — see
[CONTRIBUTING.md](CONTRIBUTING.md). In short:

1. `mkdir src/<your-tool>` and add a `package.devc.xml`.
2. Add `zcl_au_<your_tool>.clas.abap` + `.clas.xml` (+ optional
   `.clas.testclasses.abap`).
3. Add a `README.md` for the module following the standard template.
4. Add a row to the catalog table above.
5. `npm run lint` must stay green.

---

## License

[MIT](LICENSE) — use it, ship it, change it.
