# Internal Tables Cookbook — remove nested loops, pick the right table kind

Most ATC performance findings ("nested loop over internal table", "linear
search", "READ TABLE without binary search") are fixed by **modern ABAP
expressions** + the **right table kind** — not by helper methods. This is the
copy-paste reference. See also `ZCL_AU_ITAB` for the few truly generic helpers.

> Sources: [SAP performance tips](http://saphelp.ucc.ovgu.de/NW750/EN/b3/573138bb684b128e5067a44af22da8/content.htm) ·
> [FOR loops](https://discoveringabap.com/2021/10/15/abap-7-4-and-beyond-9-for-loop-for-internal-tables/) ·
> [MDP Group performance](https://mdpgroup.com/en/blog/improve-abap-code-performance-practical-techniques-and-examples/)

---

## 1. Choose the right table kind

| Need | Table kind | Access |
|------|-----------|--------|
| Keyed single-row lookups, no order | `HASHED ... UNIQUE KEY` | `itab[ key = ... ]` → O(1) |
| Range/interval reads, sorted output, mostly-unique | `SORTED ... [UNIQUE/NON-UNIQUE] KEY` | binary search → O(log n) |
| Append-heavy, sequential processing | `STANDARD` | append/loop |

You can also add **secondary keys** to a standard table to get fast lookups
without changing the primary processing:

```abap
types: tt_mara type standard table of mara
       with non-unique sorted key by_type components mtart.
" lookup uses the secondary key, O(log n), table stays a standard table:
loop at lt_mara using key by_type where mtart = 'FERT' into data(ls).
```

---

## 2. Nested loop ➜ keyed lookup (the classic ATC finding)

### Before — O(n × m)
```abap
loop at lt_orders into data(ls_order).
  loop at lt_customers into data(ls_cust).
    if ls_cust-id = ls_order-customer_id.
      ls_order-name = ls_cust-name.
      modify lt_orders from ls_order.
      exit.
    endif.
  endloop.
endloop.
```

### After — O(n) with a hashed lookup
```abap
data lt_customers type hashed table of ty_customer with unique key id.
" ... fill lt_customers ...
loop at lt_orders assigning field-symbol(<order>).
  <order>-name = value #( lt_customers[ id = <order>-customer_id ]-name optional ).
endloop.
```
`[ ... ]-field optional` returns the field or its initial value if not found —
no `READ TABLE`, no `sy-subrc`, no inner loop.

---

## 3. READ TABLE ... WITH KEY ➜ table expression

### Before
```abap
read table lt_items into data(ls_item) with key matnr = lv_matnr.
if sy-subrc = 0.
  ... ls_item ...
endif.
```

### After
```abap
if line_exists( lt_items[ matnr = lv_matnr ] ).
  data(ls_item) = lt_items[ matnr = lv_matnr ].
endif.

" or, guard with TRY for the not-found case:
try.
    data(ls_hit) = lt_items[ matnr = lv_matnr ].
  catch cx_sy_itab_line_not_found.
    ...
endtry.

" index of the hit, 0 if none:
data(lv_idx) = line_index( lt_items[ matnr = lv_matnr ] ).
```

---

## 4. LOOP + APPEND ➜ VALUE / FOR

### Before
```abap
data lt_names type string_table.
loop at lt_users into data(ls_user).
  append ls_user-name to lt_names.
endloop.
```

### After
```abap
data(lt_names) = value string_table( for ls_user in lt_users ( ls_user-name ) ).
```

With a filter and a transformation:
```abap
data(lt_active) = value string_table(
  for ls in lt_users where ( active = abap_true ) ( to_upper( ls-name ) ) ).
```

---

## 5. LOOP + IF (subset) ➜ FILTER

`FILTER` needs a sorted or hashed table (or a secondary key) on the filter field.

### Before
```abap
data lt_open type tt_order.
loop at lt_orders into data(ls).
  if ls-status = 'OPEN'.
    append ls to lt_open.
  endif.
endloop.
```

### After
```abap
data(lt_open) = filter #( lt_orders where status = 'OPEN' ).
```

---

## 6. LOOP + accumulate ➜ REDUCE

### Before
```abap
data lv_total type p length 13 decimals 2.
loop at lt_items into data(ls).
  lv_total = lv_total + ls-amount.
endloop.
```

### After
```abap
data(lv_total) = reduce p( init s = 0 for ls in lt_items next s = s + ls-amount ).
```

---

## 7. Manual grouping / COLLECT ➜ LOOP AT ... GROUP BY

### Before
```abap
loop at lt_items into data(ls).
  ls_sum-matnr = ls-matnr.
  ls_sum-qty   = ls-qty.
  collect ls_sum into lt_sum.
endloop.
```

### After
```abap
loop at lt_items into data(ls_item)
     group by ( matnr = ls_item-matnr )
     into data(ls_group).
  data(lv_qty) = reduce i( init q = 0
                           for m in group ls_group
                           next q = q + m-qty ).
  append value #( matnr = ls_group-matnr qty = lv_qty ) to lt_sum.
endloop.
```

---

## 8. CORRESPONDING instead of field-by-field moves

```abap
" move matching fields, map a few, drop the rest:
data(ls_target) = corresponding ty_target( ls_source
                    mapping target_id = source_id
                    except  internal_only ).
```

---

## Rules of thumb (what ATC is really nudging you toward)
- No `SELECT` inside a `LOOP` — read once into a table, then look up in memory.
- No nested loops over large tables — use hashed/sorted keys.
- Prefer table expressions and `line_exists`/`line_index` over `READ TABLE`.
- Prefer `VALUE`/`FOR`/`REDUCE`/`FILTER`/`CORRESPONDING` over manual loops.
- Run `npm run lint` (abaplint) locally — many of these have autofixes.
