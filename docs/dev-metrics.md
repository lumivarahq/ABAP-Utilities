# Delivery metrics & changelog (`tools/dev-metrics.js`)

Cheap, honest delivery signal from git history — the "rough numbers are better
than nothing" version of DORA + an automated changelog (*Worst Habits* §9.5,
§9.15, §5.3). No SAP system or Solution Manager wiring required.

## Use
```bash
npm run metrics        # print rough delivery proxies
npm run changelog      # (re)write docs/CHANGELOG.md from Conventional Commits
```

## What it reports
- **Changelog** — commits grouped by Conventional-Commit type (`feat`, `fix`,
  `docs`, …). Quality depends on commit discipline → enable the
  [commit-msg hook](../tools/git-hooks/commit-msg) so subjects are conventional.
- **Deployment-frequency proxy** — merge-commit count.
- **Change-failure-rate proxy** — share of `fix`/`revert` commits.
- **Commits/week** over the history span.

## Honest caveats
- These are **proxies**, not audited DORA metrics. Lead time and MTTR need
  PR-merge and incident data (not derivable from git alone) — pull those from
  GitHub/GitLab APIs or your ticketing tool if you want the full four.
- The changelog is only as good as the commit messages. Historic commits made
  before the commit-msg hook land under "Other".
- Not a CI gate (git history changes every commit), so it never blocks a build.

## Scope note
This is a **dev-team** instrument. Org-level delivery health (release cadence
policy, AMS contract incentives, sign-off culture) is systemic — see
[systemic-vs-dev-scope](systemic-vs-dev-scope.md).
