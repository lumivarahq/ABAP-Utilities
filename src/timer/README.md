# Stopwatch — `ZCL_AU_TIMER`

> Measure elapsed runtime with a high-resolution timer, without juggling
> `GET RUN TIME` yourself.

## Objects & dependencies
- `ZCL_AU_TIMER` — instance stopwatch, built on the released `CL_ABAP_RUNTIME`.
- Depends on: **nothing** → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `src/timer/zcl_au_timer.clas.abap` (+ `.clas.xml`, optionally
`.clas.testclasses.abap`) into a class in your package and assign it to your TR.

## How to use

```abap
data(lo_timer) = zcl_au_timer=>start( ).
" ... do work ...
write: / |Done in { lo_timer->elapsed_text( ) }|.        " "1234.567 ms"

data(lv_us)  = lo_timer->elapsed_microseconds( ).         " integer microseconds
data(lv_sec) = lo_timer->elapsed_seconds( ).              " decfloat seconds
```

## API
| Method | Purpose |
|--------|---------|
| `start( )` | begin timing (returns the stopwatch) |
| `elapsed_microseconds( )` | total µs since start (monotonic) |
| `elapsed_seconds( )` | total seconds since start |
| `elapsed_text( )` | formatted, e.g. `"1234.567 ms"` |

The `elapsed_*` methods are monotonic — calling them repeatedly always reports
the time since `start( )`.

## Tests
`zcl_au_timer.clas.testclasses.abap` checks that elapsed time is non-negative
after some work (wall-clock values aren't deterministic).

## Extending
Add `lap( )` / named checkpoints, or a `measure( io_block )` that times a code
block passed as an object.
