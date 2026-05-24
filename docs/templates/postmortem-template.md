# Postmortem: <incident title>

> Blameless incident review (*Worst Habits* §5.8 / §9.6). The goal is that the
> same incident does not recur — not blame. Archive in `docs/postmortems/`.

- **Date / duration:** <when it started → resolved>
- **Severity / impact:** who/what was affected (users, postings, $)
- **Authors:** <names>
- **Status:** Draft | Reviewed

## Summary
2–3 sentences: what happened, in plain language.

## Timeline (system time zone)
- HH:MM — detection (alert / user report)
- HH:MM — investigation / key findings
- HH:MM — mitigation applied
- HH:MM — resolved / verified

## Root cause
The actual technical + process cause(s). Use "5 whys" — go past the proximate
trigger (e.g. not "a bad transport" but "no automated regression on that path").

## What went well / what went poorly
- Well: …
- Poorly: …

## Action items
| Action | Owner | Due | Done |
|--------|-------|-----|:--:|
| Add ABAP Unit test for the failing path | | | ☐ |
| Add ATC/abaplint rule or monitoring | | | ☐ |
