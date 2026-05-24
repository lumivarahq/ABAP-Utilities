# Systemic vs. dev-team scope (Worst Habits, Part 2)

*Worst Habits Part 2* is mostly **systemic** — vendor strategy, licensing, market
economics, project governance, org dysfunction. Those are real, but **a utility
library cannot fix them**; they need leadership, procurement, and contract
changes. This page draws the line: what a **dev team can act on today** (with a
tool/how-to here) vs. what is out of scope.

| Part 2 section | Dev team can act on → | Out of dev-team scope |
|----------------|----------------------|-----------------------|
| §1 Engineering gaps (number ranges, update task, enqueue, jobs, customizing-as-code) | ✅ [engineering-pitfalls](engineering-pitfalls-cookbook.md); `ZCL_AU_NUMRANGE`/`ZCL_AU_LOCK`/`ZCL_AU_JOB`/`ZCL_AU_CONFIG` | — |
| §2 ABAP language: §2.3 deps, §2.7 conversions, §2.8 sy-fields, §2.9 HTTP | ✅ [.apack-manifest](../.apack-manifest.xml) + semver; [pitfalls](engineering-pitfalls-cookbook.md); `ZCL_AU_CONTEXT`/`ZCL_AU_HTTP` | dialect schism, generics, mixed paradigms, runtime design (SAP-owned) |
| §3 Product strategy / alphabet soup | — | ❌ vendor strategy (RAP vs CAP, BTP catalog, rebrands) |
| §4 Licensing (indirect access, RISE, audits) | — | ❌ commercial / procurement |
| §5 Services-market economics (body shop, AMS) | — | ❌ contracting model |
| §6 Project delivery (big-bang, fit-to-standard, sign-off) | ✅ smaller releases via [feature flags](../src/featureflag/README.md); fit-to-standard via [clean-core checks](clean-core-atc-cookbook.md) | ❌ PM methodology, governance ceremonies |
| §7 2027 deadline | ✅ custom-code readiness via [clean-core](clean-core-atc-cookbook.md) + [readiness matrix](clean-core-readiness.md) | ❌ the deadline & commercials |
| §8 Skills pipeline | ✅ AI assist ([ollama](ollama-code-review.md)), docs-as-code, knowledge capture ([ADR](templates/adr-template.md)/[docgen](../src/docgen/README.md)) | ❌ labor market, hiring, salaries |
| §9 Governance ceremony | ✅ automate trivia ([abaplint](../abaplint.json)/[hooks](../tools/git-hooks)); track ATC exemptions ([readiness matrix](clean-core-readiness.md)) | ❌ ChaRM/CAB/SoD policy |
| §10 Documentation pathology (SAP's portals) | ✅ keep **your** docs as code in-repo ([dev-workflow](dev-workflow.md)) | ❌ help.sap.com / SAP Notes sprawl |
| §11 Vendor lock-in | — | ❌ strategic/commercial |
| §12 Org dysfunction | ✅ product-owner discipline for Z-apps (backlog + [ADRs](templates/adr-template.md)) | ❌ CoE design, business ownership |
| §13 Innovation theater | ✅ *operationalize* Clean Core (the tools here turn the slide into code) | ❌ leadership narrative |
| §14 Acquisition integration | — | ❌ platform/M&A |
| §15 Reporting/MDM fragmentation | ✅ single-source via CDS + [data export](../src/export/README.md); inventory "Z fields nobody knows" (RTTI/DDIC how-to) | ❌ MDG/MDM/warehouse strategy |
| §16 Expert moat / bus factor | ✅ ADRs, [generated API docs](api/README.md), knowledge capture; pairing (culture) | ❌ hiring/retention, rates |
| §17 Interfaces & forms archaeology | ✅ new build on REST/OData ([`ZCL_AU_HTTP`](../src/http/README.md)); inventory how-to | ❌ retiring legacy middleware generations |
| §18 Auth model | — | ❌ security/GRC design |
| §19 Compliance lobby | — | ❌ regulatory/audit |

## The honest takeaway (Part 2 §20)
The guide's own conclusion: the engineering anti-patterns are often *rational
responses to systemic incentives*. Tools and how-tos (this repo) remove friction
on the **engineering layer**; they do not change the **systemic layer**
(contracts, governance, staffing). If only the engineering layer changes, the
systemic layer re-asserts itself. So: use these to make the right thing the easy
thing for developers — and treat the systemic items as leadership/procurement
work, not something a Z-class can fix.
