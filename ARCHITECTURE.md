# Architecture & roadmap

## Design in one paragraph
The library is a set of **independent, single-responsibility utilities**, one per
abapGit sub-package (`/src/<tool>`), so a developer can take exactly one tool
into a transport. Cross-package dependencies are kept to a minimum: most
utilities depend on **nothing**; a few depend only on the tiny shared
`ZCX_AU_ERROR`. Each module documents its objects, dependencies and — for
on-premise-only modules — the cloud-released replacement.

## Dependency policy
- A utility should ideally depend on **nothing** in this repo.
- The only sanctioned shared dependency is `ZCX_AU_ERROR` (error module).
- A few small interfaces enable testability: `ZIF_AU_LOG`, `ZIF_AU_CLOCK`,
  `ZIF_AU_RUNNABLE`, `ZIF_AU_ALV_HANDLER`.
- No utility may pull in a *heavier* utility (e.g. CSV must not depend on Logger).

This keeps the cherry-pick promise true: the per-module README's "Depends on"
line is the complete shopping list for a transport.

## Cloud readiness is a first-class axis
Every module is tagged ✅ (released APIs only), ⚠️ (needs a cloud-released
alternative, documented) or ❌ (SAP GUI / classic only). This lets a team adopt
the cloud-safe set today and migrate the on-premise helpers module by module
(each names its `CL_*`/XCO/RAP replacement).

## Verification
- **abaplint** (CI + `npm run lint`) — parses and style-checks every object;
  must stay at **0 issues**.
- **ABAP Unit** tests ship beside pure utilities (string, date, number, csv,
  itab, base64, hash, message, clock, retry, guard, timer, test-data).
- **Internal review**: new and existing code is read for syntax/semantics/
  feasibility before each commit (abaplint can't resolve the SAP standard
  library offline, so human review + activation on a real system remain
  necessary).
- **Local AI review**: `tools/ollama-review.sh` for an offline LLM pass.

## Does it need trimming or splitting?

**Short answer: not yet — but here is the trigger plan.**

The repo is large (≈30 utilities) but the structure scales precisely *because*
each tool is isolated and individually installable; nobody is forced to take the
whole thing. So size alone is not a reason to split.

Recommended structure moves, in priority order:

1. **Keep it as a monorepo of independent packages (now).** It's the best fit for
   "find one tool, transport one tool", and the catalog table is the index.
2. **Group only in documentation, not in code.** The README catalog already
   clusters tools; if it grows further, add sub-headings (Core / Files & Data /
   Integration / UI / RAP-CDS / Dev-experience) — no object moves needed.
3. **Split *if and only if* one of these triggers fires:**
   - **Cloud vs on-premise divergence becomes painful** → publish two abapGit
     "bundles" (a cloud-safe set and a classic set) from the same repo via
     two `.abapgit.xml` folder roots or two branches. Most teams won't need this
     because cherry-picking already lets them avoid the ❌/⚠️ modules.
   - **A module grows its own ecosystem** (e.g. ALV gains many event/handler
     classes, or CSV gains Excel) → promote that module to its own repo and
     reference it (the way we already reference abap2xlsx/ajson).
   - **Release cadence differs** (stable core vs experimental) → tag/branch
     rather than split.
4. **Trim** candidates if you want a leaner core: the thin wrappers
   (`ZCL_AU_JSON` over `/UI2/CL_JSON`) can be dropped in favour of referencing
   ajson/XCO directly. They're kept because they remove boilerplate and document
   the cloud path — but they are the first things to cut for minimalism.

**Recommendation:** stay single-repo, improve grouping in docs as it grows, and
only spin a module out to its own repo when it develops a real sub-ecosystem.

## Roadmap / candidate additions
- `ZIF_AU_CLOCK`-style seams for other ambient inputs (random, sequence).
- A typed `Result`/outcome object (success + messages + payload).
- Currency-aware amount formatting (released currency API).
- App-server directory listing; RFC destination ping/call helper.
- Wire `ZCL_AU_DOCGEN=>for_classes( )` into CI to publish `docs/api/`.
- Merge ABAP Doc short texts into generated Markdown (read class source via ADT
  source APIs).
- Optional: a cloud-bundle `.abapgit.xml` that excludes the ❌/⚠️ modules.

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add a module without breaking
the cherry-pick guarantee.
