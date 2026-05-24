# Retry — `ZCL_AU_RETRY` / `ZIF_AU_RUNNABLE`

> Retry a transient operation with optional exponential back-off — the resilience
> pattern from Polly (.NET) / resilience4j (Java), in ABAP.

## Objects & dependencies
- `ZIF_AU_RUNNABLE` — a unit of work (`run( )`); raise to fail, return to succeed.
- `ZCL_AU_RETRY` — the retry loop.
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module).

> ⚠️ Uses `WAIT UP TO n SECONDS` for the delay; `WAIT` is restricted in some
> ABAP Cloud contexts. Pass `iv_wait_seconds = 0` to retry without waiting.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `zif_au_runnable.intf.abap` + `zcl_au_retry.clas.abap` (+ their `.xml`).
3. Assign to your TR.

## How to use

```abap
" wrap the flaky operation in a runnable
class lcl_call_api definition.
  public section.
    interfaces zif_au_runnable.
    data mv_response type zcl_au_http=>ty_response.
endclass.
class lcl_call_api implementation.
  method zif_au_runnable~run.
    mv_response = zcl_au_http=>get( `https://api.example.com/things` ).
    if mv_response-code >= 500.
      zcx_au_error=>raise( |server error { mv_response-code }| ).  "-> triggers a retry
    endif.
  endmethod.
endclass.

data(lo_call) = new lcl_call_api( ).
zcl_au_retry=>run( io_action       = lo_call
                   iv_max_attempts = 4
                   iv_wait_seconds = 1 ).   " waits 1s, 2s, 4s between attempts
```

## API
| Parameter | Meaning |
|-----------|---------|
| `io_action` | the `ZIF_AU_RUNNABLE` to execute |
| `iv_max_attempts` | total attempts incl. the first (default 3) |
| `iv_wait_seconds` | initial delay before retrying (default 1; 0 = none) |
| `iv_exponential` | double the delay after each failure (default `X`) |

After the last attempt the original error is re-raised, chained, as `ZCX_AU_ERROR`.

## Tests
`zcl_au_retry.clas.testclasses.abap` uses a flaky stub to prove it retries until
success and gives up after `iv_max_attempts` (with `iv_wait_seconds = 0`).

## Extending
Add a predicate ("retry only these exceptions"), jitter, a max total timeout, or
a circuit-breaker that stops calling a failing dependency for a cool-off period.
