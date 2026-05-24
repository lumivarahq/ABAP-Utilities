# Modern ABAP dev workflow (this repo's setup)

The engineering-discipline practices from the *Worst Habits* guide (Parts 3, 5,
9), wired up here so you can copy them into your own abapGit repo.

## Git hooks (one command to enable)
```bash
git config core.hooksPath tools/git-hooks
```
- **pre-commit** ([`tools/git-hooks/pre-commit`](../tools/git-hooks/pre-commit)) —
  runs abaplint and regenerates `docs/api`, staging it if it drifted (§9.18,
  §9.21-ish: keeps generated docs in sync).
- **commit-msg** ([`tools/git-hooks/commit-msg`](../tools/git-hooks/commit-msg)) —
  enforces **Conventional Commits** so history is machine-readable for changelogs
  and semantic versioning (§9.15, §9.16).

## CI gates (GitHub Actions)
- **abaplint** (`.github/workflows/abaplint.yml`) — parse + Clean ABAP style on
  every push/PR (§3.8, §4.5, §9.3).
- **api-docs** (`.github/workflows/api-docs.yml`) — regenerate `docs/api`, fail on
  drift, publish as an artifact (§9.20 docs-as-code).
- Add to these on a real system: **remote ATC** (`CLOUD_READINESS` +
  `S4HANA_READINESS`) and **ABAP Unit** runs (§4.1, §4.5).

## Local commands
```bash
npm run lint        # abaplint
npm run lint:fix    # abaplint --fix (autofix style)
npm run docs        # regenerate docs/api from the ABAP sources
tools/ollama-review.sh   # offline AI review of your diff (see docs/ollama-code-review.md)
```

## Branch & review flow (§3)
1. Branch per task off `main` (short-lived — hours/days, not weeks; §9.2).
2. abapGit pulls your branch into a (ideally per-developer) dev system.
3. Open a PR; CI gates run; a human reviews **design/security/perf**, not trivia
   (use [code-review-checklist.md](templates/code-review-checklist.md), §3.5).
4. Merge to `main` only when green; deploy via gCTS/transport (§9.4).

## Templates (docs-as-code, §9.7, §5.8)
- [ADR template](templates/adr-template.md) — record *why* next to the code.
- [Postmortem template](templates/postmortem-template.md) — blameless incident review.
- [Code review checklist](templates/code-review-checklist.md).

## Versioning & changelog (§9.15-§9.16)
Conventional commits (`feat`/`fix`/…) + tags enable an auto-generated changelog
and semantic versioning of the package. Tag releases in Git; the version of a
package becomes a real, queryable thing instead of "whatever is in PRD".
