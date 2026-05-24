# Date & Time — `ZCL_AU_DATE`

> Date arithmetic and formatting without classic calendar function modules.

## Objects & dependencies
- `ZCL_AU_DATE` — stateless utility (`class-methods`).
- Depends on: **nothing**. Computed in pure ABAP → **ABAP Cloud safe**.

## Install (cherry-pick)
Copy `src/date/zcl_au_date.clas.abap` (+ `.clas.xml`, optionally
`.clas.testclasses.abap`) into a class in your package and assign it to your TR.

## How to use

```abap
zcl_au_date=>days_between( iv_from = '20260101' iv_to = '20260110' ).  "9
zcl_au_date=>add_months( iv_date = '20260131' iv_months = 1 ).         "20260228 (clamped)
zcl_au_date=>first_day_of_month( '20260215' ).                         "20260201
zcl_au_date=>last_day_of_month(  '20260210' ).                         "20260229
zcl_au_date=>weekday( '20260525' ).                                    "1 (Mon, ISO-8601)
zcl_au_date=>is_weekend( '20260524' ).                                 "abap_true (Sun)
zcl_au_date=>workdays_between( iv_from = '20260525' iv_to = '20260531' ). "5
zcl_au_date=>to_iso( '20260524' ).                                     "2026-05-24
zcl_au_date=>from_iso( `2026-05-24` ).                                 "20260524
zcl_au_date=>age( iv_birthday = '19900101'
                  iv_on       = zcl_au_context=>today( ) ).            "completed years today

data(lv_ts)  = zcl_au_date=>now( ).                                    "UTC timestampl
data(ls_dt)  = zcl_au_date=>timestamp_to_date_time( iv_timestamp = lv_ts
                                                    iv_time_zone = 'UTC' ).
```

## API
| Method | Purpose |
|--------|---------|
| `days_between` / `add_days` / `add_months` | date arithmetic (month add clamps to EOM) |
| `first_day_of_month` / `last_day_of_month` | month boundaries |
| `weekday` / `is_weekend` | ISO-8601 weekday (Mon=1 … Sun=7) |
| `workdays_between` | Mon–Fri count in `[from, to]` |
| `to_iso` / `from_iso` | `YYYY-MM-DD` ⇄ `d` |
| `age` | completed years on a key date |
| `now` / `timestamp_to_date_time` | timestamp helpers |

## Tests
`zcl_au_date.clas.testclasses.abap` covers diffs, end-of-month month addition
(incl. backwards across a year boundary), month bounds, weekday/weekend,
working-day counting, ISO round-trip and age (before/after birthday).

## Extending — public holidays
`workdays_between` counts Mon–Fri only. To honour public holidays, inject a
factory calendar: add an optional `iv_factory_calendar TYPE wfcid` parameter and
skip dates returned as holidays (on-premise: function `DATE_CONVERT_TO_FACTORYDATE`
/ `HOLIDAY_GET`; ABAP Cloud: a released calendar API or a holiday table you own).
Keep the no-calendar path as the default so the class stays dependency-free.
