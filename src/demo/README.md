# Demo — `ZAU_DEMO`

> A small report that wires several AU utilities together, so you can *see* the
> library work end-to-end in one place.

## What it shows
GUID correlation id, string case/mask, ISO date + working-day count, grouped
number formatting, e-mail/Luhn validation, a before/after diff, and a profiler
report — all rendered with `CL_DEMO_OUTPUT`.

## Dependencies
Uses (and therefore needs) these modules: `guid`, `string`, `date`, `number`,
`validate`, `diff`, `profiler`. It is **on-premise / SAP GUI** (it is a report and
uses `CL_DEMO_OUTPUT`).

## Run it
Activate the report and the modules above, then run `ZAU_DEMO` in SE38 / ADT.

> This is a learning aid, not a utility — you would not transport it into a
> productive package. For the task→tool index see
> [docs/recipes.md](../../docs/recipes.md).
