# Error — `ZCX_AU_ERROR`

> A small, reusable exception class that can carry either a **free text** or a
> **message-class (T100)** message, with full exception chaining.

## Objects & dependencies
- `ZCX_AU_ERROR` — exception class, inherits `CX_STATIC_CHECK`, implements
  `IF_T100_MESSAGE`.
- Depends on: **nothing**.

This is the only shared dependency in the library (used by `ZCL_AU_LOGGER`).

## Install (cherry-pick)
Copy `src/error/zcx_au_error.clas.abap` (+ `.clas.xml`) into an exception class
in your package and assign it to your TR.

## How to use

```abap
" 1) Raise with free text
zcx_au_error=>raise( `Customer & could not be created` ).

" 2) Raise from a message class (T100)
zcx_au_error=>raise_t100( msgid = 'ZFOO' msgno = '001'
                          v1    = lv_customer ).

" 3) Re-raise the current sy-msg* fields after a classic call
call function 'SOME_FM' exceptions error = 1 others = 2.
if sy-subrc <> 0.
  zcx_au_error=>raise_from_sy( ).
endif.

" 4) Wrap a caught exception (keeps the chain)
try.
    ...
  catch cx_sy_conversion_no_number into data(lx).
    zcx_au_error=>raise( text = `Bad number` previous = lx ).
endtry.

" Consume
try.
    ...
  catch zcx_au_error into data(lx_err).
    write: / lx_err->get_text( ).        "short text (<=200 chars)
    write: / lx_err->get_full_text( ).   "full untruncated text
endtry.
```

## API
| Method | Purpose |
|--------|---------|
| `raise( text, previous )` | raise with free text |
| `raise_t100( msgid, msgno, v1..v4, previous )` | raise from a message class |
| `raise_from_sy( )` | raise from the current `sy-msg*` fields |
| `get_full_text( )` | full text, untruncated |

Free text up to 200 characters is shown as the short text (via message `00(398)`
placeholders); the complete text is always available via `get_full_text( )` and
the read-only attribute `mv_text`.

## Tests
The class is exercised indirectly by the consumers' tests. Add dedicated tests if
you extend its behaviour.

## Extending
Add typed factory methods for your own recurring errors, or override
`get_longtext` if you want rich long texts.
