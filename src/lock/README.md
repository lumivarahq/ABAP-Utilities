# Locking — `ZCL_AU_LOCK`

> Generic `ENQUEUE` / `DEQUEUE` (SAP lock server) without a dedicated lock
> object — for ad-hoc serialization of custom processing.

## Objects & dependencies
- `ZCL_AU_LOCK` — stateless utility (`class-methods`).
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module) and the
  generic enqueue function modules `ENQUEUE` / `DEQUEUE`.

> ⚠️ **ABAP Cloud:** the generic enqueue FMs are not released. In ABAP Cloud use
> a **lock object** (SE11) with its generated `ENQUEUE_*`/`DEQUEUE_*` (released),
> or RAP's locking. This module is for classic/on-premise ad-hoc locks.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/lock/zcl_au_lock.clas.abap` (+ `.clas.xml`).
3. Assign both objects to your TR.

## How to use

```abap
" serialize a critical section keyed by a business key
try.
    zcl_au_lock=>lock( iv_name = 'ZORDER_PROC' iv_key = lv_order_id ).
  catch zcx_au_error into data(lx).
    " someone else holds it -> abort / inform
    message lx->get_text( ) type 'E'.
endtry.

try.
    " ... protected work ...
  cleanup.
    zcl_au_lock=>unlock( iv_name = 'ZORDER_PROC' iv_key = lv_order_id ).
endtry.
```

## API
| Method | Purpose |
|--------|---------|
| `lock( iv_name, iv_key, iv_mode )` | acquire a lock (waits/retries, raises if held) |
| `unlock( iv_name, iv_key, iv_mode )` | release a lock |

Modes are exposed as constants: `mode_exclusive` (`E`, default), `mode_shared`
(`S`), `mode_cumulate` (`X`).

## Tests
Locking needs the enqueue server, so verify by activation + a real lock/unlock
(and an SM12 check) rather than ABAP Unit.

## Extending
Add a non-waiting `try_lock( )` (return a boolean instead of raising), or a
scope/owner parameter. For real persisted business objects, prefer a proper
lock object over the generic enqueue.
