# ABAP anti-patterns → remediation playbook

A direct map from the *"Worst Habits & Practices of ABAP Development Teams"*
field guide to a concrete remedy. For each habit: a **tool in this library**, an
**existing project to reuse**, or a **how-to** here.

**Legend** — ✅ plug-and-play tool in this repo · 📘 how-to / cookbook here ·
🔗 use this established project / SAP feature (don't reinvent — see
[related-projects](related-projects.md) / [dotabap.org](https://dotabap.org)).

## Part 1 — line-level
| Habit | Remedy |
|-------|--------|
| 1.1 `SELECT *` / filter in ABAP | 📘 [internal-tables](internal-tables-cookbook.md), [clean-core-atc](clean-core-atc-cookbook.md) · 🔗 abaplint / ATC `SELECT_STAR_USAGE` |
| 1.2 `SELECT` in `LOOP` (N+1) | 📘 [internal-tables](internal-tables-cookbook.md) · 🔗 abaplint / ATC |
| 1.3 `FOR ALL ENTRIES` w/o empty check | 📘 [internal-tables](internal-tables-cookbook.md) · 🔗 abaplint `for_all_entries` |
| 1.4 `DELETE ADJACENT DUPLICATES` unsorted | ✅ [`ZCL_AU_ITAB=>distinct`](../src/itab/README.md) |
| 1.5 Magic numbers / hardcoded org values | ✅ [`ZCL_AU_CONFIG`](../src/config/README.md), [`ZCL_AU_FEATURE_FLAG`](../src/featureflag/README.md) |
| 1.6 `WRITE` lists instead of ALV | ✅ [`ZCL_AU_ALV`](../src/alv/README.md), [`ZCL_AU_FIORI_GEN`](../src/fiori/README.md) · 📘 [fiori-conversion](fiori-conversion-cookbook.md) |
| 1.7 `CHECK`/`EXIT` deep in nesting | ✅ [`ZCL_AU_GUARD`](../src/guard/README.md) |
| 1.8 `sy-subrc` unchecked | 📘 [code-review-checklist](templates/code-review-checklist.md) · 🔗 abaplint |
| 1.9 Commented-out code | 🔗 abaplint `commented_code` |
| 1.10 Comments that lie | 📘 [auto-documentation](auto-documentation.md) · 🔗 Clean ABAP |
| 1.11 Procedural "class-shaped report" | 📘 [cross-language](cross-language-ideas.md) §12 + [checklist](templates/code-review-checklist.md) |
| 1.12 Assertions as runtime checks | ✅ [`ZCL_AU_GUARD`](../src/guard/README.md) (validate input; keep ASSERT for invariants) |
| 1.13 Hungarian notation | 🔗 Clean ABAP / abaplint `object_naming` *(note: this library uses the common prefix style; Clean ABAP discourages it — pick one team rule)* |
| 1.14 Mass `MOVE-CORRESPONDING` | 📘 [underused](underused-standard-features.md) §2 (`CORRESPONDING … MAPPING`) |
| 1.15 Reinventing utilities | ✅ this library · 🔗 [related-projects](related-projects.md) / dotabap |

## Part 2 — architecture
| Habit | Remedy |
|-------|--------|
| 2.1 Modifying standard SAP | 📘 [clean-core-atc](clean-core-atc-cookbook.md) · ✅ [`ZCL_AU_WRAP_GEN`](../src/wrapper/README.md) |
| 2.2 Z-copy of standard | 📘 [clean-core-atc](clean-core-atc-cookbook.md) (fit-to-standard, BAdIs) |
| 2.3 Direct table writes | 📘 [clean-core-atc](clean-core-atc-cookbook.md), [bdc-to-api](bdc-to-api-cookbook.md) |
| 2.4 God includes | 📘 [bdc-to-api](bdc-to-api-cookbook.md) (strangler) · 🔗 Feathers, *Working Effectively with Legacy Code* |
| 2.5 Function groups as god objects | 📘 [cross-language](cross-language-ideas.md) §12 (small classes, packages) |
| 2.6 No layering | 📘 [rap-cds-modernization](rap-cds-modernization.md) |
| 2.7 Reinventing infra (log/jobs) | ✅ [`ZCL_AU_LOGGER`](../src/logger/README.md), [`ZCL_AU_JOB`](../src/job/README.md) · 🔗 ABAP Logger |
| 2.8 Stateful globals / SHARED MEMORY | 📘 [cross-language](cross-language-ideas.md) §5 · ✅ [`ZIF_AU_CLOCK`](../src/clock/README.md) (no hidden time state) |
| 2.9 No dependency injection | ✅ `ZIF_AU_LOG/CLOCK/RUNNABLE/FEATURE_FLAG` (DI examples) · 🔗 `cl_abap_testdouble` |
| 2.10 No interface-based design | 📘 [cross-language](cross-language-ideas.md) §1 |
| 2.11 Copy-tweak reuse | ✅ this library · 🔗 abaplint `duplicates` |
| 2.12 Reports as the universal hammer | ✅ [`ZCL_AU_FIORI_GEN`](../src/fiori/README.md) · 📘 [fiori-conversion](fiori-conversion-cookbook.md) |
| 2.13 Custom code duplicating standard | 📘 [related-projects](related-projects.md) ("is there a standard tx?") |

## Part 3 — version control & workflow
| Habit | Remedy |
|-------|--------|
| 3.1 Transport-as-VCS | 🔗 abapGit / gCTS · 📘 [dev-workflow](dev-workflow.md) |
| 3.2 Shared dev client | 🔗 BTP ABAP env / per-dev systems · 📘 [dev-workflow](dev-workflow.md) |
| 3.3 Class-level locking | 📘 [dev-workflow](dev-workflow.md) (smaller classes, branch per feature) |
| 3.4 No code review | ✅ [checklist](templates/code-review-checklist.md), [`tools/ollama-review.sh`](../tools/ollama-review.sh) · 🔗 SAP `styleguides` |
| 3.5 Reviews on trivia | ✅ [`abaplint.json`](../abaplint.json) + [checklist](templates/code-review-checklist.md) · 🔗 ABAP Cleaner |
| 3.6 No branching strategy | 📘 [dev-workflow](dev-workflow.md) |
| 3.7 Pretty-printer / formatting wars | ✅ abaplint config + ✅ [commit-msg/pre-commit hooks](../tools/git-hooks) · 🔗 ABAP Cleaner |
| 3.8 No CI | ✅ [`abaplint.yml`](../.github/workflows/abaplint.yml) + [`api-docs.yml`](../.github/workflows/api-docs.yml) · 📘 [dev-workflow](dev-workflow.md) |

## Part 4 — testing & quality
| Habit | Remedy |
|-------|--------|
| 4.1 ~0 ABAP Unit adoption | ✅ shipped tests + [`ZCL_AU_TEST_DATA`](../src/test/README.md) + [`ZCL_AU_CLOCK`](../src/clock/README.md) · 🔗 `cl_abap_testdouble`, mockup_loader |
| 4.2 Testing = manual UAT | 📘 [dev-workflow](dev-workflow.md) · 🔗 eCATT / Tricentis |
| 4.3 No test data management | ✅ [`ZCL_AU_TEST_DATA`](../src/test/README.md) · 🔗 mockup_loader, CDS test doubles |
| 4.4 No mutation/property/fuzz | ✅ [`ZCL_AU_TEST_DATA`](../src/test/README.md) (random/property inputs) · 📘 [cross-language](cross-language-ideas.md) |
| 4.5 ATC findings ignored | 📘 [clean-core-atc](clean-core-atc-cookbook.md) (baseline; gate new) |
| 4.6 No performance testing | ✅ [`ZCL_AU_TIMER`](../src/timer/README.md) · 🔗 SAT / ST05 |
| 4.7 No API/RFC regression suite | 📘 [cross-language](cross-language-ideas.md) (contract tests) · 🔗 Pact |

## Part 5 — DevOps & operations
| Habit | Remedy |
|-------|--------|
| 5.1 Manual transport sequencing | 🔗 gCTS / ActiveControl · 📘 [dev-workflow](dev-workflow.md) |
| 5.2 Big-bang quarterly releases | ✅ [`ZCL_AU_FEATURE_FLAG`](../src/featureflag/README.md) · 📘 [dev-workflow](dev-workflow.md) |
| 5.3 No build artifacts / versioning | ✅ Conventional-commit [hooks](../tools/git-hooks) · 📘 [dev-workflow](dev-workflow.md) |
| 5.4 No blue/green / canary | ✅ [`ZCL_AU_FEATURE_FLAG`](../src/featureflag/README.md) |
| 5.5 No observability | ✅ [`ZCL_AU_LOGGER`](../src/logger/README.md) + [`ZCL_AU_GUID`](../src/guid/README.md) (correlation id) + [`ZCL_AU_TIMER`](../src/timer/README.md) · 🔗 Cloud ALM / ELK |
| 5.6 Basis as gatekeeper | 📘 [dev-workflow](dev-workflow.md) |
| 5.7 No infrastructure as code | 🔗 CTS+ / gCTS / BC sets · 📘 [dev-workflow](dev-workflow.md) |
| 5.8 No postmortems | ✅ [postmortem template](templates/postmortem-template.md) |

## Part 6 — security
| Habit | Remedy |
|-------|--------|
| 6.2 Missing authorization checks | 📘 [checklist](templates/code-review-checklist.md) · 🔗 ATC `MISSING_AUTHORITY_CHECK` |
| 6.3 SQL injection | ✅ [`ZCL_AU_DYN_SQL`](../src/dynsql/README.md) · 🔗 ATC `OPEN_SQL_INJECTION` |
| 6.4 Code injection | ✅ [`ZCL_AU_DYN_SQL`](../src/dynsql/README.md) (allow-list) · 🔗 ATC |
| 6.5 Hardcoded secrets | 📘 [checklist](templates/code-review-checklist.md) · 🔗 SSF / STRUST / abaplint |
| 6.6 Authorization by obscurity | 📘 [checklist](templates/code-review-checklist.md) (SU24 + auth check) |
| 6.7 Logs leak PII | ✅ [`ZCL_AU_STRING=>mask`](../src/string/README.md) |
| 6.8 No SAST in pipeline | ✅ abaplint security rules in CI · 🔗 Onapsis / ATC security variant |

## Part 7 — people & culture (mostly process)
| Habit | Remedy |
|-------|--------|
| 7.1 Irreplaceable senior | ✅ [ADR template](templates/adr-template.md) + generated [API docs](api/README.md) + [ollama review](ollama-code-review.md) |
| 7.3 Functional/technical wall | 📘 [dev-workflow](dev-workflow.md) (three-amigos, testable acceptance criteria) |
| 7.4 Resistance to new tech | 📘 this repo is the worked example (ADT/abapGit/CI/RAP/CDS) |
| 7.5 Hero culture | 📘 [dev-workflow](dev-workflow.md) (DORA: track failure rate & MTTR) |
| 7.7 No retros | ✅ [postmortem template](templates/postmortem-template.md) (adapt for retros) |

## Part 8 — end-user pain (symptoms of the above)
| Pain | Root remedy |
|------|-------------|
| 8.1 "3 months to add a column" | ✅ [`ZCL_AU_FIORI_GEN`](../src/fiori/README.md) + 📘 [dev-workflow](dev-workflow.md) |
| 8.2 Reports time out | 📘 [internal-tables](internal-tables-cookbook.md) |
| 8.3 Four reports disagree | 📘 [related-projects](related-projects.md), [clean-core-atc](clean-core-atc-cookbook.md) (inventory) |
| 8.4 "The upgrade broke everything" | 📘 [clean-core-atc](clean-core-atc-cookbook.md) |
| 8.5 Unactionable error messages | ✅ [`ZCX_AU_ERROR`](../src/error/README.md) + [`ZCL_AU_GUID`](../src/guid/README.md) correlation id |
| 8.6 "Call ABAP to change a config value" | ✅ [`ZCL_AU_CONFIG`](../src/config/README.md), [`ZCL_AU_FEATURE_FLAG`](../src/featureflag/README.md) |
| 8.8 Half-built Fiori apps | 📘 [fiori-conversion](fiori-conversion-cookbook.md) (draft, value help, error UX) |

## Part 9 — practices "unheard of" in ABAP teams
| Practice | Status |
|----------|--------|
| 9.1 Feature flags | ✅ [`ZCL_AU_FEATURE_FLAG`](../src/featureflag/README.md) |
| 9.2 Trunk-based dev | 📘 [dev-workflow](dev-workflow.md) |
| 9.3 CI | ✅ [workflows](../.github/workflows) |
| 9.4 Continuous Delivery | 📘 [dev-workflow](dev-workflow.md) · 🔗 gCTS |
| 9.5 DORA metrics | 📘 [dev-workflow](dev-workflow.md) |
| 9.6 Postmortems | ✅ [template](templates/postmortem-template.md) |
| 9.7 ADRs | ✅ [template](templates/adr-template.md) |
| 9.8 Contract testing | 📘 [cross-language](cross-language-ideas.md) · 🔗 Pact |
| 9.9 Property-based testing | ✅ [`ZCL_AU_TEST_DATA`](../src/test/README.md) |
| 9.10 Mutation testing | 📘 [cross-language](cross-language-ideas.md) (concept) |
| 9.11 SonarQube dashboards | 🔗 abaplint + SAP Cloud ALM Custom Code Compliance |
| 9.12 OpenTelemetry / tracing | ✅ correlation id via [`ZCL_AU_GUID`](../src/guid/README.md)+[`ZCL_AU_LOGGER`](../src/logger/README.md) · 🔗 Cloud ALM / Focused Run |
| 9.13 Chaos engineering | ✅ [`ZCL_AU_RETRY`](../src/retry/README.md) (resilience) · 📘 [cross-language](cross-language-ideas.md) |
| 9.14 Pair / mob programming | 📘 culture (no tool) |
| 9.15 Conventional commits | ✅ [commit-msg hook](../tools/git-hooks/commit-msg) |
| 9.16 Semantic versioning | ✅ [hooks](../tools/git-hooks) + 📘 [dev-workflow](dev-workflow.md) |
| 9.17 SBOM | 🔗 Clean Core A–D classification / apack · 📘 [clean-core-readiness](clean-core-readiness.md) |
| 9.18 Pre-commit hooks | ✅ [`tools/git-hooks/pre-commit`](../tools/git-hooks/pre-commit) |
| 9.19 Internal developer platform | 🔗 SAP BTP ABAP environment |
| 9.20 Documentation-as-code | ✅ this repo + [`ZCL_AU_DOCGEN`](../src/docgen/README.md) + [api-docs](api/README.md) |
| 9.21 Coverage as a merge gate | 📘 [dev-workflow](dev-workflow.md) · 🔗 ABAP Unit coverage |
| 9.22 Performance budgets in CI | ✅ [`ZCL_AU_TIMER`](../src/timer/README.md) · 📘 [dev-workflow](dev-workflow.md) |
| 9.23 12-factor config | ✅ [`ZCL_AU_CONFIG`](../src/config/README.md) · 📘 [cross-language](cross-language-ideas.md) §17 |
| 9.24 ChatOps / runbooks-as-code | 📘 (out of scope; document runbooks in-repo) |
| 9.25 InnerSource | 📘 [CONTRIBUTING](../CONTRIBUTING.md) (this repo's model) |
| 9.26 AI assistants beyond autocomplete | ✅ [`tools/ollama-review.sh`](../tools/ollama-review.sh) · 📘 [ollama-code-review](ollama-code-review.md) |

---

## Summary
- **Tools shipped here (✅):** itab/distinct, config, feature-flag, guard, ALV &
  Fiori/export generators, wrapper generator, dyn-sql, logger, job, timer, GUID,
  error, string-mask, test-data, clock, retry, docgen + the CI doc generator,
  git hooks, ADR/postmortem/review templates, Ollama reviewer.
- **Reuse, don't reinvent (🔗):** abapGit, gCTS, abaplint, abapOpenChecks, ABAP
  Cleaner, ABAP Logger, mockup_loader, `cl_abap_testdouble`, Onapsis, ATC, SAP
  Cloud ALM, BTP ABAP environment, Pact. See [related-projects](related-projects.md).
- **Everything else (📘):** the cookbooks and [dev-workflow](dev-workflow.md) +
  [remediation roadmap](#) mirror the field guide's Part 10 phasing.

> Honest scope: tools and how-tos remove friction, but the Part 7 culture items
> (pairing, blameless reviews, dual career ladders) are organizational, not
> something a utility can install.
