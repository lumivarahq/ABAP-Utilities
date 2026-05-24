# Ideas worth stealing from other ecosystems

Practices that are normal in Java/C#/JS/Go/Python teams and translate well to
modern ABAP. Each has a concrete ABAP landing.

## 1. Dependency injection + program-to-interfaces
Depend on `ZIF_*` interfaces, inject implementations via the constructor. Makes
code testable and swappable (exactly how `ZIF_AU_LOG` is built here).
```abap
methods constructor importing io_log type ref to zif_au_log.
" tests inject cl_abap_testdouble=>create( 'ZIF_AU_LOG' )
```

## 2. Unit tests & TDD as a default
ABAP Unit + test doubles + OSQL/CDS test environments give you fast, isolated
tests. Treat a class without tests as unfinished. Gate merges on green tests.

## 3. CI/CD with linting & formatting
What ESLint/Prettier/SpotBugs do elsewhere, **abaplint** does for ABAP (this repo
runs it in GitHub Actions). Add ABAP Unit + ATC (Cloud ATC / abapGit CI) to the
pipeline. Fail the build on findings, not in code review.

## 4. Map / filter / reduce (functional collection ops)
`VALUE … FOR`, `FILTER`, `REDUCE`, table comprehensions — write *what* you want,
not *how* to loop. See the [Internal Tables Cookbook](internal-tables-cookbook.md).

## 5. Immutability & pure functions
Prefer `class-methods` with `importing`/`returning` and no side effects for
calculations (all of `ZCL_AU_STRING/DATE/NUMBER` are pure). Pure functions are
trivially testable and thread-safe.

## 6. Fluent / builder APIs
Method chaining for readable construction (`ZCL_AU_EMAIL`, `ZIF_AU_LOG`):
```abap
zcl_au_email=>create( )->subject( … )->to( … )->body_html( … )->send( ).
```

## 7. Result objects instead of exceptions for expected outcomes
For "expected" failures, return a small result structure (`success`, `message`,
`payload`) rather than throwing — exceptions stay for the truly exceptional.
(Borrowed from Rust's `Result` / Go's error returns / functional `Either`.)

## 8. Package & dependency management
abapGit (+ `apack`/`.apack-manifest.xml`) is your npm/Maven: declare dependencies
on libraries like `abap2xlsx`, `ajson`, pin versions, reuse instead of copy.

## 9. Feature toggles
Gate new behaviour behind a switch (a config table / TVARVC / released toggle
service) so you can deploy dark and release independently — standard in web teams.

## 10. Structured logging & correlation ids
Attach a correlation id (a UUID from `ZCL_AU_GUID`) to every log entry of a run
(`ZCL_AU_LOGGER`) so you can trace one transaction end-to-end, like distributed
tracing.

## 11. Code review culture (PRs)
Small, reviewed pull requests with CI gates — exactly the workflow this repo
uses. Pairs naturally with abapGit branches + GitHub/GitLab.

## 12. "Composition over inheritance" & small classes
Many small, single-responsibility classes wired together (this repo's
one-utility-per-class layout) beats deep class hierarchies — easier to test,
reuse and cherry-pick.

## 13. Static analysis-driven refactoring
Treat abaplint/ATC findings as a backlog with autofixes (`npm run lint:fix`,
ADT Quick Fixes) — the same "fix the linter, then the warnings" discipline other
languages use to keep code bases modern.
