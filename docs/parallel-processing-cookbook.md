# Parallel processing in ABAP (aRFC & SPTA)

When a job is embarrassingly parallel (process N independent packages), ABAP can
fan the work out across dialog work processes. There is **no safe *generic*
wrapper** (the framework needs a real RFC-enabled function module as the unit of
work and careful resource limits), so this is a pattern guide rather than a
shipped class.

## Decide first: do you even need it?
- A single set-based `SELECT` / CDS / AMDP usually beats hand-rolled parallelism.
- Parallelise only **CPU/RFC-bound, independent** packages, and only when one
  process is demonstrably too slow.
- Always cap parallelism to a **server group** (transaction `RZ12`) so you don't
  starve dialog users.

## Option A — `SPTA` framework (recommended)
SAP's package-parallelization framework. You implement three callbacks; SPTA
handles work-process management, RFC, and result collection.
- `SPTA_PARA_PROCESS_START_2` — drive the run.
- Your "before RFC", "in RFC" (the unit of work, an RFC-enabled FM) and "after
  RFC" callbacks.
Pros: robust, throttled, retries. Use this for production batch.

## Option B — asynchronous RFC (`CALL FUNCTION ... STARTING NEW TASK`)
Lower-level; you manage tasks and the receive logic yourself.

```abap
data: lv_taskname type num4,
      lv_in_flight type i.
constants c_max type i value 5.            " never exceed the server group

loop at lt_packages into data(ls_pkg).
  lv_taskname = lv_taskname + 1.

  " throttle: wait until a slot is free
  while lv_in_flight >= c_max.
    wait until lv_in_flight < c_max.
  endwhile.

  call function 'Z_PROCESS_PACKAGE'        " must be RFC-enabled
    starting new task |{ lv_taskname }|
    destination in group default
    calling on_return on end of task
    exporting iv_package = ls_pkg.
  if sy-subrc = 0.
    lv_in_flight = lv_in_flight + 1.
  endif.
endloop.

wait until lv_in_flight = 0.               " join

" callback (form / method): RECEIVE the results and decrement the counter
" form on_return using p_task.
"   receive results from function 'Z_PROCESS_PACKAGE' importing ev_result = ...
"                exceptions communication_failure = 1 system_failure = 2.
"   lv_in_flight = lv_in_flight - 1.
```

### Rules that bite people
- The work FM **must be RFC-enabled** and self-contained (no shared screen/state).
- `DESTINATION IN GROUP` + `RZ12` server group — never spawn unbounded tasks.
- Each task runs in its **own LUW**: pass everything in, return everything out,
  `COMMIT WORK` inside the task; the caller can't share an open transaction.
- Watch `RESOURCE_FAILURE` (no free WP) — back off and retry, don't busy-spin.
- Aggregate results only in the callback; the main program continues meanwhile.

## ABAP Cloud
Classic aRFC/SPTA are not available. Use the released **Application Jobs** /
background processing framework (`CL_APJ_*`) to schedule independent jobs, or
push set-based work into **CDS/AMDP** (HANA does the parallelism for you).

## See also
- [`ZCL_AU_JOB`](../src/job/README.md) — schedule the packages as separate
  background jobs (a simpler "parallelism" when packages are coarse-grained).
- [Internal Tables Cookbook](internal-tables-cookbook.md) — often the real fix is
  set-based code, not parallelism.
