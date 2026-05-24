# ZCL_AU_PROFILER

AU - Lightweight runtime profiler

_Module: `profiler` — generated from source by `tools/gen-api-docs.js`; do not edit by hand._

| Method | Description |
|--------|-------------|
| `start` | Start timing a named step (wrap a code block or a SELECT). |
| `stop` | Stop the most recent matching start and accumulate the elapsed time. |
| `record` | Record a measurement directly (microseconds). Use it to fold in a duration |
| `report` | Aggregated results, sorted slowest-first (total time descending) - the |
| `report_text` | Human-readable, slowest-first report (for a log, the console, or an ALV |
| `reset` | Clear all measurements (e.g. between runs). |
