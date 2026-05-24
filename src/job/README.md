# Background jobs — `ZCL_AU_JOB`

> Schedule a report in the background in one call instead of the
> JOB_OPEN → SUBMIT → JOB_CLOSE dance (with its many exceptions).

## Objects & dependencies
- `ZCL_AU_JOB` — stateless utility (`class-methods`).
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module) and the
  job FMs `JOB_OPEN` / `JOB_CLOSE`.

> ⚠️ **ABAP Cloud:** these FMs and dynamic `SUBMIT` are not released. In ABAP
> Cloud schedule work with the released **Application Jobs** framework
> (`CL_APJ_*`, transaction *Application Jobs*) and a job catalog entry.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/job/zcl_au_job.clas.abap` (+ `.clas.xml`).
3. Assign both objects to your TR.

## How to use

```abap
" build the selection just like a variant
data lt_sel type rsparams_tt.
append value #( selname = 'P_BUKRS' kind = 'P' sign = 'I' option = 'EQ' low = '1000' ) to lt_sel.

data(lv_jobcount) = zcl_au_job=>run_report( iv_jobname   = 'ZCLOSE_PERIOD'
                                            iv_report    = 'ZRECONCILE'
                                            it_selection = lt_sel ).
" -> watch it in SM37 (jobname ZCLOSE_PERIOD, count lv_jobcount)
```

## API
| Method | Purpose |
|--------|---------|
| `run_report( iv_jobname, iv_report, it_selection, iv_start_immediately, iv_target_server )` | open + submit + close a background job |

`it_selection` is a standard `RSPARAMS_TT` (the same structure variants use):
`selname`, `kind` (`P`/`S`), `sign`, `option`, `low`, `high`.

## Tests
Scheduling needs batch work processes and authorizations, so verify by
activation + an SM37 check rather than ABAP Unit.

## Extending
Add periodic scheduling (`PRDMINS`/`PRDHOURS` on JOB_CLOSE), start-after-event,
start-after-job, or a status reader (`BP_JOB_STATUS_GET`).
