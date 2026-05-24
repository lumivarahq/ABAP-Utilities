# RAP message factory — `ZCL_AU_RAP_MSG`

> Build `IF_ABAP_BEHV_MESSAGE` instances for the `REPORTED` / `FAILED` tables of
> a RAP behavior implementation, in one line.

## Objects & dependencies
- `ZCL_AU_RAP_MSG` — stateless utility (`class-methods`), wraps
  `CL_ABAP_BEHV=>NEW_MESSAGE` / `NEW_MESSAGE_WITH_TEXT`.
- Depends on: the **RAP runtime** only (ABAP 7.54+ / S/4HANA / ABAP Cloud).
  → **ABAP Cloud / clean core safe**.

## Install (cherry-pick)
Copy `src/rap/zcl_au_rap_msg.clas.abap` (+ `.clas.xml`) into a class in your
package and assign it to your TR.

## How to use

Inside a behavior pool (validation, determination, or action):

```abap
method validate_amount.
  read entities of zi_order in local mode
    entity order fields ( amount ) with corresponding #( keys )
    result data(lt_orders).

  loop at lt_orders into data(ls_order).
    if ls_order-amount <= 0.
      " mark the instance as failed
      append value #( %tky = ls_order-%tky ) to failed-order.
      " attach a message (T100, ERROR severity)
      append value #( %tky = ls_order-%tky
                      %msg = zcl_au_rap_msg=>error( iv_msgid = 'ZORDER'
                                                    iv_msgno = '010'
                                                    iv_v1    = ls_order-order_id ) )
             to reported-order.
    endif.
  endloop.
endmethod.
```

Other severities and free text:

```abap
zcl_au_rap_msg=>warning( iv_msgid = 'ZORDER' iv_msgno = '020' ).
zcl_au_rap_msg=>success( iv_msgid = 'ZORDER' iv_msgno = '000' ).
zcl_au_rap_msg=>text_error( `Amount must be positive` ).
zcl_au_rap_msg=>from_exception( lx_root ).   "wrap a caught exception
```

## API
| Method | Severity |
|--------|----------|
| `error` / `warning` / `info` / `success` | T100 message with that severity |
| `text_error` | free-text error (no message class) |
| `from_exception` | error message from any exception's text |

## Tests
RAP messages can only be meaningfully tested inside a RAP test double scenario
(`cl_abap_behv=>...` / EML in a unit test). Test them as part of your BO tests.

## Extending
Add helpers that also fill `%element` (field-level messages) or that append
directly into typed `reported`/`failed` structures for your specific BO.
