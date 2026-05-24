# Profiler — `ZCL_AU_PROFILER`

> A simplified, in-code SAT/SE30: wrap named steps (code blocks or SQL), then get
> a report **sorted slowest-first** (count / total / avg / max / %). For finding
> "which part takes the longest" without reading a kernel trace.

## Objects & dependencies
- `ZCL_AU_PROFILER` — instance profiler.
- Depends on: **nothing**. `record`/`report` are pure; `start`/`stop` use
  `GET RUN TIME` (CPU microseconds).

> ⚠️ `start`/`stop` use `GET RUN TIME` (classic). In ABAP Cloud, time each step
> with `CL_ABAP_RUNTIME` / two `GET TIME STAMP`s and feed the delta to `record`
> (which is cloud-safe).

## Install (cherry-pick)
Copy `src/profiler/zcl_au_profiler.clas.abap` (+ `.clas.xml`, optionally
`.clas.testclasses.abap`) into a class in your package and assign it to your TR.

## How to use

```abap
data(lo_prof) = new zcl_au_profiler( ).

lo_prof->start( 'read orders' ).
select * from ztorders into table @data(lt_orders).
lo_prof->stop( 'read orders' ).

loop at lt_orders into data(ls).
  lo_prof->start( 'enrich item' ).
  " ... per-item work / a SELECT ...
  lo_prof->stop( 'enrich item' ).
endloop.

" slowest-first report
write / lo_prof->report_text( ).
" or hand the structured result to an ALV grid for a functional consultant:
data(lt_profile) = lo_prof->report( ).      " sorted slowest-first
" zcl_au_alv=>display( changing ct_table = lt_profile ).
```

`report_text( )` prints, e.g.:
```
Step                                   Count    Total(ms)    Avg(ms)    Max(ms)       %
--------------------------------------------------------------------------------------
read orders                                1       4200.0     4200.0     4200.0    80.8
enrich item                              500       1000.0        2.0       12.0    19.2
```

## API
| Method | Purpose |
|--------|---------|
| `start( iv_step )` / `stop( iv_step )` | time a named block (nesting/repeats supported) |
| `record( iv_step, iv_micros )` | fold in a duration measured elsewhere |
| `report( )` | aggregated table, sorted slowest-first |
| `report_text( )` | readable slowest-first report (ms) |
| `reset( )` | clear measurements |

## Tests
`zcl_au_profiler.clas.testclasses.abap` checks slowest-first ordering,
aggregation (count/total/avg/min/max) and reset — deterministically via
`record( )` (wall-clock values aren't testable).

## When to use the standard tools instead
This profiler needs you to instrument code. For "view the slowest without
touching code" — the functional-consultant path — use the standard transactions
described in [docs/performance-profiling-cookbook.md](../../docs/performance-profiling-cookbook.md)
(ST03N, STAD, SAT/SE30, ST05, SQLM/SWLT).

## Extending
Add nesting indentation in `report_text`, a self-time vs total-time split, or an
auto-flush to [`ZCL_AU_LOGGER`](../logger/README.md) at the end of a run.
