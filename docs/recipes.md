# Start here — recipes ("I want to… → use…")

A fast index from a task to the right utility. Each is one cherry-pickable class
(see its module README for the exact objects + dependencies). Full catalog and
cloud-readiness in the [root README](../README.md).

## Strings, numbers, dates
| I want to… | Use |
|------------|-----|
| split/join, mask, case-convert, pad, ALPHA | [`ZCL_AU_STRING`](../src/string/README.md) |
| add months/days, weekday, working days, ISO dates, age | [`ZCL_AU_DATE`](../src/date/README.md) |
| round, clamp, %, grouped formatting | [`ZCL_AU_NUMBER`](../src/number/README.md) |
| validate e-mail / card (Luhn) / IBAN | [`ZCL_AU_VALIDATE`](../src/validate/README.md) |
| a UUID/GUID | [`ZCL_AU_GUID`](../src/guid/README.md) |

## Data & tables
| I want to… | Use |
|------------|-----|
| internal table ⇄ CSV | [`ZCL_AU_CSV`](../src/csv/README.md) |
| dedupe / count distinct | [`ZCL_AU_ITAB`](../src/itab/README.md) |
| diff two texts/tables (before/after) | [`ZCL_AU_DIFF`](../src/diff/README.md) |
| process in packages / chunk | [`ZCL_AU_BATCH`](../src/batch/README.md) |
| serialize/deserialize JSON | [`ZCL_AU_JSON`](../src/json/README.md) |
| base64 / hash (MD5/SHA) / zip | [`ZCL_AU_BASE64`](../src/base64/README.md) · [`ZCL_AU_HASH`](../src/hash/README.md) · [`ZCL_AU_ZIP`](../src/zip/README.md) |

## Integration & output
| I want to… | Use |
|------------|-----|
| call a REST/OData API | [`ZCL_AU_HTTP`](../src/http/README.md) |
| send an e-mail (with attachments) | [`ZCL_AU_EMAIL`](../src/email/README.md) |
| read/write an app-server file | [`ZCL_AU_DATASET`](../src/dataset/README.md) |
| show a grid (modern ALV) | [`ZCL_AU_ALV`](../src/alv/README.md) |
| expose data to Power BI / export | [`ZCL_AU_ANALYTICS_GEN`](../src/export/README.md) |

## Errors, logging, messages
| I want to… | Use |
|------------|-----|
| raise a clean exception (text or T100) | [`ZCX_AU_ERROR`](../src/error/README.md) |
| guard method inputs (fail fast) | [`ZCL_AU_GUARD`](../src/guard/README.md) |
| write an application log (BAL) | [`ZCL_AU_LOGGER`](../src/logger/README.md) |
| build/inspect BAPIRET2 / message text | [`ZCL_AU_MESSAGE`](../src/message/README.md) |
| RAP `reported`/`failed` messages | [`ZCL_AU_RAP_MSG`](../src/rap/README.md) |

## Runtime, config, resilience
| I want to… | Use |
|------------|-----|
| time/profile what's slow | [`ZCL_AU_PROFILER`](../src/profiler/README.md) · [`ZCL_AU_TIMER`](../src/timer/README.md) |
| testable "now" | [`ZCL_AU_CLOCK`](../src/clock/README.md) |
| current user/date (clean-core) | [`ZCL_AU_CONTEXT`](../src/context/README.md) |
| feature toggle / config | [`ZCL_AU_FEATURE_FLAG`](../src/featureflag/README.md) · [`ZCL_AU_CONFIG`](../src/config/README.md) |
| retry a flaky call | [`ZCL_AU_RETRY`](../src/retry/README.md) |
| lock / number range / background job | [`ZCL_AU_LOCK`](../src/lock/README.md) · [`ZCL_AU_NUMRANGE`](../src/numrange/README.md) · [`ZCL_AU_JOB`](../src/job/README.md) |
| safe dynamic SQL | [`ZCL_AU_DYN_SQL`](../src/dynsql/README.md) |

## Code generation & dev tooling
| I want to… | Use |
|------------|-----|
| scaffold a Fiori app from a table | [`ZCL_AU_FIORI_GEN`](../src/fiori/README.md) |
| scaffold a Clean-Core released wrapper | [`ZCL_AU_WRAP_GEN`](../src/wrapper/README.md) |
| generate Markdown API docs | [`ZCL_AU_DOCGEN`](../src/docgen/README.md) |
| compare versions | [`ZCL_AU_SEMVER`](../src/semver/README.md) |
| random test data | [`ZCL_AU_TEST_DATA`](../src/test/README.md) |

## See it run
[`ZAU_DEMO`](../src/demo/README.md) wires several of these together in one report.

## Fixing bad habits?
Start at the [anti-patterns playbook](anti-patterns-playbook.md), then the
relevant cookbook (internal tables, clean-core/ATC, performance, …).
