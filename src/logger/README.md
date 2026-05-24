# Logger — `ZIF_AU_LOG` / `ZCL_AU_LOGGER`

> A fluent wrapper over the Application Log (BAL / transactions SLG0 + SLG1).

## Objects & dependencies
- `ZIF_AU_LOG` — the logging abstraction (mock it in unit tests).
- `ZCL_AU_LOGGER` — BAL implementation.
- Depends on: **`ZCX_AU_ERROR`** (the [Error](../error/README.md) module) and the
  classic **BAL** function modules (`BAL_LOG_CREATE`, `BAL_LOG_MSG_ADD*`,
  `BAL_DB_SAVE`).

> ⚠️ **ABAP Cloud:** the classic BAL FMs are not released. On ABAP Cloud use
> `CL_BALI_LOG` / the released Application Log API, or the community
> [ABAP Logger](https://github.com/ABAP-Logger/ABAP-Logger). Keep your code
> typed against `ZIF_AU_LOG` so you can swap the implementation without touching
> callers.

## Install (cherry-pick)
1. Copy the [Error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `zif_au_log.intf.abap` and `zcl_au_logger.clas.abap` (+ their `.xml`).
3. Assign all three objects to your TR.
4. Maintain a log object/subobject in transaction **SLG0** for persistent logs.

## How to use

```abap
" Code against the interface
data(lo_log) = cast zif_au_log(
  zcl_au_logger=>create( iv_object    = 'ZAU'
                         iv_subobject = 'GENERAL'
                         iv_extnumber = |Run { sy-datum }| ) ).

lo_log->info( `Processing started`
     )->warning( `Customer 4711 has no address`
     )->error( `Posting failed` ).

" From other sources
lo_log->add_bapiret( lt_return ).
lo_log->add_from_sy( ).
try.
    ...
  catch cx_root into data(lx).
    lo_log->add_exception( lx ).   "adds the whole previous chain
endtry.

data(lv_lognumber) = lo_log->save( ).   "persist + COMMIT WORK
" View it in transaction SLG1.
```

## API (`ZIF_AU_LOG`)
| Method | Purpose |
|--------|---------|
| `info` / `success` / `warning` / `error` | add a free-text message (chainable) |
| `add_exception` | add an exception and its `previous` chain |
| `add_bapiret` | add every row of a `BAPIRET2_T` |
| `add_from_sy` | add the current `sy-msg*` message |
| `save( iv_commit )` | persist to DB, returns the log number |
| `handle` | the raw `BALLOGHNDL` for advanced/native use |

## Tests
Because `ZCL_AU_LOGGER` talks to BAL, unit-test **callers** by mocking
`ZIF_AU_LOG` (`cl_abap_testdouble=>create( 'ZIF_AU_LOG' )`). The interface was
designed precisely so your business logic stays testable.

## Extending
Add probability class / context / parameters to messages, a "display now"
helper (`BAL_DSP_LOG_DISPLAY`), or a second implementation
(`ZCL_AU_LOGGER_CLOUD`) behind the same `ZIF_AU_LOG`.
