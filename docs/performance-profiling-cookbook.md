# Finding what's slow: profiling ABAP & SQL

Two paths to "which program / query takes the longest": **instrument** the code
(developer) or **trace/observe** it with standard transactions (functional
consultant, no code changes).

## Path A — instrument with `ZCL_AU_PROFILER` (developer)
A simplified SE30/SAT you control: wrap named steps, get a slowest-first report.
```abap
data(lo) = new zcl_au_profiler( ).
lo->start( 'select headers' ).
select * from ztorders into table @data(lt).
lo->stop( 'select headers' ).
" ... more steps ...
write / lo->report_text( ).            " slowest-first; or feed report( ) to an ALV
```
Best when you already suspect a routine and want a quick, repeatable breakdown,
or to hand a functional user a readable table (via [`ZCL_AU_ALV`](../src/alv/README.md)).
See [the module README](../src/profiler/README.md).

## Path B — standard transactions (functional consultant, no instrumentation)

| Tool | Use it to see | "Longest" view |
|------|---------------|----------------|
| **ST03N** (Workload Monitor) | response/CPU/DB time **aggregated by program/transaction** over a period | sort the profile by *Total Response Time* or *Avg* — the top rows are your worst offenders |
| **STAD** (Business Transaction Analysis) | the step-by-step breakdown of **one** dialog step / job (ABAP vs DB vs wait time) | shows where a single slow run spent its time |
| **SAT** (Runtime Analysis, replaces SE30) | trace **one execution**: the *Hit List* of methods/statements with gross/net time | sort the Hit List by *Gross* time → the longest call paths |
| **ST05** (SQL/Performance Trace) | every SQL statement of a traced run, with **duration** and records | sort by *Duration* → the slowest statements; check for identical-SELECT-in-loop |
| **SQLM + SWLT** (SQL Monitor + Code Inspector worklist) | **production** SQL aggregated by call site, with executions & total time | the SQL Monitor list sorted by total DB time → expensive statements to optimise |

### A practical "find the slowest" recipe
1. **ST03N** → last week → *Transaction/Program profile* → sort by total response
   time. This names the worst programs without any tracing.
2. For a named program: run it and capture with **SAT** (ABAP-heavy?) and/or
   **ST05** (DB-heavy?). The split tells you whether to fix the code (Path A,
   [internal-tables cookbook](internal-tables-cookbook.md)) or the SQL.
3. For systemic SQL hotspots across production, turn on **SQLM** for a few days,
   then review in **SWLT** — it ranks SQL by total time and flags the call site.

## Reading the result (what "longest" usually means)
- **High DB time / many executions** → `SELECT` in a `LOOP`, missing index, no
  field list, `FOR ALL ENTRIES` on a huge driver → see
  [internal-tables cookbook](internal-tables-cookbook.md).
- **High ABAP/CPU time** → nested loops, sort/dedup on big tables, string work in
  loops → table expressions / hashed tables.
- **High wait time** → enqueue contention or update-task backlog → see
  [engineering-pitfalls](engineering-pitfalls-cookbook.md).

## Make it a gate (optional)
Capture a baseline with `ZCL_AU_PROFILER` (or [`ZCL_AU_TIMER`](../src/timer/README.md))
in a test and assert a step stays under a budget — a lightweight "performance
budget in CI" (§9.22). For full SQL budgets, script ST05/SQLM in a pre-prod run.

> Scope: this is the **dev-team** performance toolkit. Capacity planning, HANA
> sizing, and infrastructure tuning are Basis/infra concerns, not covered here.
