# CSV — `ZCL_AU_CSV`

> Convert **any** internal table to/from CSV using RTTI. No DDIC structure, no
> external library, RFC-4180-style quoting.

## Objects & dependencies
- `ZCL_AU_CSV` — stateless utility (`class-methods`).
- Depends on: **nothing**. Pure string + RTTI → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `src/csv/zcl_au_csv.clas.abap` (+ `.clas.xml`, optionally
`.clas.testclasses.abap`) into a class in your package and assign it to your TR.

## How to use

```abap
types: begin of ty_row,
         id   type i,
         name type string,
         city type string,
       end of ty_row.
data lt type standard table of ty_row with default key.

lt = value #( ( id = 1 name = `Doe, John` city = `Berlin` )
              ( id = 2 name = `Ann`       city = `Rome` ) ).

" Table -> CSV (header row of component names, comma separated)
data(lv_csv) = zcl_au_csv=>from_table( lt ).
" id,name,city
" 1,"Doe, John",Berlin
" 2,Ann,Rome

" CSV -> Table (columns matched to components by header name)
data lt_back type standard table of ty_row with default key.
zcl_au_csv=>to_table( exporting iv_csv   = lv_csv
                      changing  ct_table = lt_back ).

" Semicolon separated, no header (columns mapped by position)
data(lv_semi) = zcl_au_csv=>from_table( it_table  = lt
                                        iv_separator = ';'
                                        iv_header = abap_false ).
```

## API
| Method | Purpose |
|--------|---------|
| `from_table( it_table, iv_separator, iv_header )` | internal table ➜ CSV string |
| `to_table( iv_csv, iv_separator, iv_header, ct_table )` | CSV string ➜ internal table |

- Values containing the separator, a quote, CR or LF are wrapped in `"` and inner
  quotes are doubled (RFC 4180). The parser reverses this, including quoted fields
  that contain separators or embedded newlines.
- With `iv_header = abap_true`, columns are matched to components **by name**
  (case-insensitive); unmatched columns are ignored. Without a header they map
  **by position**.
- Field values must be in internal format (dates as `YYYYMMDD`, amounts with `.`).

## Tests
`zcl_au_csv.clas.testclasses.abap` covers the header row, quoting/escaping of
commas and embedded quotes, and full table→CSV→table round-trips with and without
a header.

## Extending
- File I/O is intentionally out of scope (it differs per environment). Pair this
  with `cl_gui_frontend_services` (SAP GUI), an `OPEN DATASET` helper (application
  server), or an HTTP handler (Fiori upload/download).
- For Excel, use [abap2xlsx](https://github.com/abap2xlsx/abap2xlsx) instead.
