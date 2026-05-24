# Semantic versioning — `ZCL_AU_SEMVER`

> Parse and compare `MAJOR.MINOR.PATCH` versions — the comparison logic behind
> the [APACK manifest](../../.apack-manifest.xml) and any "needs at least vX"
> dependency check (*Worst Habits* §9.16).

## Objects & dependencies
- `ZCL_AU_SEMVER` — stateless utility (`class-methods`).
- Depends on: **`ZCX_AU_ERROR`** (invalid version) → **ABAP Cloud safe**.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/semver/zcl_au_semver.clas.abap` (+ `.clas.xml`).
3. Assign both to your TR.

## How to use
```abap
data(ls) = zcl_au_semver=>parse( `1.4.2-beta.1` ).   " major=1 minor=4 patch=2

zcl_au_semver=>compare( iv_a = `1.2.0` iv_b = `1.10.0` ).   " -1 (1.2 < 1.10)

if zcl_au_semver=>at_least( iv_version = lv_installed iv_minimum = `1.2.0` ) = abap_false.
  zcx_au_error=>raise( |Needs ZCL_AU at >= 1.2.0, found { lv_installed }| ).
endif.
```

## API
| Method | Purpose |
|--------|---------|
| `parse( iv_version )` | → `(major, minor, patch)`; pre-release/build suffix ignored |
| `compare( iv_a, iv_b )` | `-1` / `0` / `1` |
| `at_least( iv_version, iv_minimum )` | `iv_version >= iv_minimum` |

Non-numeric segments raise `ZCX_AU_ERROR`.

## Tests
`zcl_au_semver.clas.testclasses.abap` covers full/partial parsing, suffix
stripping, all three comparison outcomes (incl. `1.2 < 1.10`), `at_least`, and the
invalid-version guard.

## Extending
Add pre-release ordering (`1.0.0-alpha < 1.0.0`), caret/tilde ranges (`^1.2.0`),
or wire it into a startup check that validates declared dependency versions.
