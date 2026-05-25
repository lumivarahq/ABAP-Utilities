# Contributing

Thanks for extending the library! The repository is designed so that each
utility is an independent, cherry-pickable unit. Please keep it that way.

## Before you start — check for prior art

The goal of this repo is **generic helpers that nobody else provides**. Before
writing any new utility:

1. **Query the SAP Docs MCP for standard-library prior art.** This repo wires up
   the [SAP Docs MCP](docs/MCP-INTEGRATION.md) (`docker compose -f
   docker-compose.sap-docs.yml up -d`, then it is available in Claude Code /
   Cursor). Search the **ABAP Keyword Documentation** and released APIs first —
   if SAP already ships a class, CL_/XCO API or statement that does it, don't
   wrap it; link to it from the module README instead.
2. **Search [dotabap.org](https://dotabap.org/) for a community project**
   (see [docs/related-projects.md](docs/related-projects.md)). If a focused,
   maintained project exists, reference it rather than copying code.

Only build something new when **neither** the standard library **nor** a
community project covers it. This keeps the library small and worth depending on.

## Design rules

1. **One utility = one sub-package folder** under `src/`.
2. **Minimise dependencies.** A utility should ideally depend on nothing else in
   this repo. If you must depend on another module, document it in the module
   README and in the catalog table in the root [README](README.md).
3. **Prefer released / standard APIs** so utilities stay usable on ABAP Cloud.
   If you use a classic-only API (e.g. a function module), say so in the README
   and offer the cloud-safe alternative.
4. **Stateless utilities are `class-methods`** on a `final` class. Stateful
   helpers expose an interface (`ZIF_AU_*`) so callers can mock them in tests.
5. **Clean ABAP**: lower-case keywords, 2-space indentation, meaningful names,
   ABAP Doc (`"!`) on every public method.
6. **Naming — house style (deliberate):** this library uses the classic
   parameter/variable prefixes `iv_ / ev_ / cv_ / rv_ / it_ / et_ / rt_ / is_ /
   rs_ / lv_ / lt_ / ls_ / lo_ / mo_ / mt_`. Clean ABAP discourages Hungarian
   notation (see [docs/anti-patterns-playbook.md](docs/anti-patterns-playbook.md)
   §1.13); we keep the prefixes **consistently** because they aid the
   cherry-pick/standalone reading of one class out of context and match the
   still-dominant convention in most customer code. **Pick one rule and be
   consistent** — that is the actual win; if your team drops prefixes, do it
   everywhere, not half-and-half.

## Folder / file layout for a new utility `foo`

```
src/foo/
  package.devc.xml                  # CTEXT only; package name derived on import
  zcl_au_foo.clas.abap              # the implementation
  zcl_au_foo.clas.xml               # abapGit metadata (copy an existing one)
  zcl_au_foo.clas.testclasses.abap  # ABAP Unit tests (strongly encouraged)
  README.md                         # how-to (use the template below)
```

The class metadata XML is identical for every class except `CLSNAME` and
`DESCRIPT` — copy one from an existing module.

## Naming

| Object | Pattern | Example |
|--------|---------|---------|
| Class | `ZCL_AU_<name>` | `ZCL_AU_STRING` |
| Interface | `ZIF_AU_<name>` | `ZIF_AU_LOG` |
| Exception | `ZCX_AU_<name>` | `ZCX_AU_ERROR` |
| Sub-package | `ZAU_<NAME>` (folder = `<name>`) | `ZAU_STRING` / `string` |

Naming is enforced by [`abaplint.json`](abaplint.json).

## Module README template

```markdown
# <Module> — ZCL_AU_<NAME>

> One-line purpose.

## Objects & dependencies
- `ZCL_AU_<NAME>` — <what it is>
- Depends on: <none | object list>

## Install (cherry-pick)
Copy `src/<folder>/zcl_au_<name>.clas.abap` (+ `.clas.xml`) into a class in your
package and assign it to your TR. No other objects required.

## How to use
\`\`\`abap
... runnable example ...
\`\`\`

## API
| Method | Purpose |
|--------|---------|

## Tests
What the shipped ABAP Unit tests cover.

## Extending
Where the natural extension points are.
```

## Before you push

```bash
npm run lint      # must report 0 issues
```

Activate the objects and run the ABAP Unit tests on a real ABAP system.
