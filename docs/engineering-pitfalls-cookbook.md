# Engineering pitfalls cookbook (the "hidden runtime" gaps)

Dev-team-solvable engineering traps from *Worst Habits Part 2* §1-§2 — the ones
that are about **how the ABAP runtime really behaves**, not about SAP's
commercials. Each maps to a tool here or a concrete how-to.

## Number ranges as global state (§1.1)
`NUMBER_GET_NEXT` scattered across the code, with ad-hoc buffer sizes, causes
gaps (auditors hate them) and contention.
- **Do:** funnel *all* number-range access through one service. Use
  [`ZCL_AU_NUMRANGE`](../src/numrange/README.md) (or wrap
  `CL_NUMBERRANGE_RUNTIME` on cloud) so buffer policy and error handling live in
  one place. Document tax-jurisdiction "no gaps" requirements next to it.
- **Watch:** monitor objects in **SNRO/SNUM**; size buffers deliberately
  (buffered = fast but gappy; non-buffered = contiguous but a contention point).

## Update task as a hidden execution model (§1.2)
`CALL FUNCTION … IN UPDATE TASK` runs after `COMMIT WORK` in another work
process — failures are silent unless someone watches **SM13**.
- **Do:** treat it as fire-and-forget in a distributed system. Prefer direct,
  synchronous posting (or RAP `COMMIT ENTITIES`) where you need the result.
- **If you must use it:** register an update-termination alert (SM13 backlog),
  log a correlation id ([`ZCL_AU_GUID`](../src/guid/README.md) +
  [`ZCL_AU_LOGGER`](../src/logger/README.md)) before the post so you can trace a
  failed unit, and never assume success.

## Enqueue locks as a global mutex (§1.3)
Coarse, system-wide named locks: two unrelated programs with overlapping lock
arguments serialize.
- **Do:** scope locks to the **business key**, not the whole table. Define a
  domain-specific lock object (SE11) rather than `E_<TABLE>` on a standard table.
  Use [`ZCL_AU_LOCK`](../src/lock/README.md) with the narrowest argument that is
  still correct; always release in `cleanup`.
- **Watch:** SM12 for lock pile-ups under load.

## Background jobs as orphaned cron (§1.4)
Thousands of jobs scheduled by people who left; SM37 is a graveyard.
- **Do:** keep a **job catalog** (a small Z config table or TVARVC via
  [`ZCL_AU_CONFIG`](../src/config/README.md)) with: job name, owner, purpose,
  expected runtime, alert threshold, decommission date. Schedule via
  [`ZCL_AU_JOB`](../src/job/README.md) and stamp the catalog id in the job name.
- **Cull:** review quarterly; cancel jobs with no owner/purpose.

## Customizing as code (§1.8)
SPRO entries change behaviour like code but get far less review.
- **Do:** put critical customizing **table contents under version control** with
  abapGit (`TABU`/table-content serialization for the relevant config tables) and
  review changes the same way as ABAP. Gate them through the same PR flow
  ([dev-workflow](dev-workflow.md)).

## Implicit type conversions (§2.7)
ABAP silently converts `STRING`/`CHAR`/`NUMC`/`INT`/`PACKED` — a classic source
of decimal-precision bugs in financial code.
- **Do:** use `STRICT(2)` syntax checks, explicit `CONV`/`EXACT` casts, and the
  matching abaplint/ATC rules. Use [`ZCL_AU_NUMBER`](../src/number/README.md)'s
  `DECFLOAT34`-based helpers for money math instead of ad-hoc packed arithmetic.

## SY-* fields as global state (§2.8)
`sy-subrc`, `sy-tabix`, `sy-datum`, … are global and mutated by many statements.
- **Do:** capture into a local **immediately** after the statement that set it;
  never read `sy-subrc` more than one statement from its source. Replace
  `sy-uname`/`sy-datum` with [`ZCL_AU_CONTEXT`](../src/context/README.md).

## Forms & interface sprawl (§1.5, §1.6 / Part 17)
Multiple form and integration generations coexist.
- **Do (new build):** one form tech per type (prefer Adobe/Fiori output over new
  SAPscript/Smart Forms); new external integration on **REST/OData** (consume via
  [`ZCL_AU_HTTP`](../src/http/README.md), expose via
  [`ZCL_AU_ANALYTICS_GEN`](../src/export/README.md) / a Service Binding).
- **Do (inventory):** list what exists and its owner before adding more — same
  discipline as dead-code/Z-object inventory.

> These are the parts of Part 2 a dev team controls. The product-strategy,
> licensing, and org items around them are out of scope — see
> [systemic-vs-dev-scope](systemic-vs-dev-scope.md).
