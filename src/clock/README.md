# Clock — `ZIF_AU_CLOCK` / `ZCL_AU_CLOCK`

> Make "now" an injected dependency so time-dependent code is testable — the
> ABAP version of `java.time.Clock` / .NET `TimeProvider`.

## Objects & dependencies
- `ZIF_AU_CLOCK` — the abstraction (`now_timestamp` / `now_date` / `now_time`).
- `ZCL_AU_CLOCK` — `system( )` (real clock) and `fixed( )` (frozen, for tests).
- Depends on: **nothing** → **ABAP Cloud safe** (UTC time stamp based).

## Why
Code that calls `GET TIME STAMP` / `sy-datum` directly can't be tested at
boundaries ("at month end", "after the cut-off") and trips Clean Core checks.
Inject a clock instead, then freeze it in tests.

## Install (cherry-pick)
Copy `zif_au_clock.intf.abap` + `zcl_au_clock.clas.abap` (+ their `.xml`) and
assign to your TR.

## How to use

```abap
" production code depends on the abstraction
class zcl_invoice definition.
  public section.
    methods constructor importing io_clock type ref to zif_au_clock.
endclass.

" wire the real clock at the edge
data(lo_service) = new zcl_invoice( zcl_au_clock=>system( ) ).

" in a unit test, freeze time and assert deterministic behaviour
data(lo_clock) = zcl_au_clock=>fixed( conv timestampl( '20260131235900' ) ).
data(lo_cut)   = new zcl_invoice( lo_clock ).
" ... assert "month-end" logic ...
```

## API (`ZIF_AU_CLOCK`)
| Method | Returns |
|--------|---------|
| `now_timestamp( )` | high-resolution UTC `timestampl` |
| `now_date( )` | UTC date |
| `now_time( )` | UTC time |

All values derive from one time stamp, so a fixed clock is fully deterministic.
Values are **UTC**; for user-local dates use [`ZCL_AU_CONTEXT`](../context/README.md)
or [`ZCL_AU_DATE`](../date/README.md).

## Tests
`zcl_au_clock.clas.testclasses.abap` proves the fixed clock returns exactly the
frozen date/time and the system clock is bound.

## Extending
Add `now_local( time_zone )`, or an "offsettable" clock (`advance_by( seconds )`)
for simulating the passage of time in tests.
