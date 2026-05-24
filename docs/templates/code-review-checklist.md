# ABAP code review checklist

> Push **style/trivia to automation** (Pretty Printer, ABAP Cleaner, abaplint,
> ATC). Reserve human review for the items below — clarity, design, security,
> performance, tests (*Worst Habits* §3.4–§3.5). Aligns with SAP's
> `SAP/styleguides` ABAP Code Review Guideline.

## Correctness & design
- [ ] Single responsibility; method does one thing, named for what it does.
- [ ] No procedural "class-shaped report"; collaborators injected, not `NEW`-ed inside.
- [ ] Programs to interfaces where it aids testing/extension.
- [ ] Error handling: class-based exceptions; `sy-subrc` checked; no swallowed errors.
- [ ] No magic numbers/hardcoded org values (use config / constants).

## Performance (the expensive misses)
- [ ] No `SELECT` inside a `LOOP`; no nested loops over large tables.
- [ ] Field list, not `SELECT *`; aggregation/joins pushed to the DB / CDS.
- [ ] `FOR ALL ENTRIES` guarded against an empty driver table.
- [ ] Sorted/hashed tables or table expressions for lookups.

## Clean Core
- [ ] No direct write to / `SELECT` from SAP tables that have a released CDS/API.
- [ ] No non-released APIs (or isolated behind one released wrapper).
- [ ] No `sy-uname`/`sy-datum` etc. (use `cl_abap_context_info` / `ZCL_AU_CONTEXT`).
- [ ] ATC `CLOUD_READINESS` clean (or exemption justified and logged).

## Security
- [ ] Authorization checks present (in the data-access layer).
- [ ] No SQL/code injection: host variables, `cl_abap_dyn_prg` / `ZCL_AU_DYN_SQL`.
- [ ] No hardcoded secrets; no PII leaked into logs.

## Tests & docs
- [ ] New logic has ABAP Unit tests; they fail if the logic changes.
- [ ] Public methods have ABAP Doc (`"!`).
- [ ] No commented-out code; comments explain *why*, not *what*.
