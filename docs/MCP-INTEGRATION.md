# ABAP & MCP — integration guide

This repository is **source code**: a set of generic, cherry-pickable ABAP/RAP
utility classes. The **Model Context Protocol (MCP)** is the complementary
*agent surface* — it is how an AI coding assistant (Claude Code, Cursor, GitHub
Copilot, …) gets accurate ABAP knowledge and, in some cases, talks to a live SAP
system. This page explains the options, when each applies, and the path we
recommend.

> **TL;DR** — Use **A + B today** (Marian Zeis' open-source ABAP docs MCP, self-
> hosted for this repo's Claude Code, or his hosted endpoint in Eclipse/Copilot).
> **Migrate to C** (SAP's official ABAP MCP Server) when it goes GA in Q2 2026
> for agentic development against a real system. **D** is the in-system add-on
> for teams that want display/create/update tools running *inside* S/4HANA or ECC.

---

## The four options at a glance

| # | Server | Runs where | What it gives you | Best for |
|---|--------|-----------|-------------------|----------|
| **A** | [`marianfoo/mcp-sap-docs`](https://github.com/marianfoo/mcp-sap-docs) (`abap` variant) | Your machine / CI (Docker or Node) | Local, offline-capable search over ABAP & SAP documentation + live SAP Help/Community | **Claude Code / Cursor on this repo** (wired below) |
| **B** | [Marian Zeis' ABAP MCP server](https://blog.zeis.de/posts/2026-02-04-abap-mcp-server/) | Hosted (`mcp-abap.marianzeis.de`) or local | Same engine as A, used from **Eclipse ADT + GitHub Copilot** | Developers coding in Eclipse/ADT **today** |
| **C** | **SAP's official ABAP MCP Server** | In ADT for Eclipse & the VS Code ABAP tooling | Agentic ABAP dev **against a live system** (read + AI-assisted + standard dev ops) | The strategic target once **GA (Q2 2026)** |
| **D** | [Community in-system add-on MCP](https://community.sap.com/t5/technology-blog-posts-by-members/mcp-server-for-sap-ecc-amp-s-4hana-unlimited-abap-add-on-for-display-create/ba-p/14293485) | **Inside** the SAP system (SICF node) | Display/create/update/delete tools exposed at the ABAP layer | Direct-on-system agents on ECC/S4 (down to 7.01) |

> **A and B are the same project family, by the same author.** `marianfoo` on
> GitHub is **Marian Zeis**. Option A is "self-host the `abap` variant of
> `mcp-sap-docs`"; option B is "use his hosted endpoint / the Eclipse + Copilot
> recipe from the blog." Same index and search engine — different deployment.
> We list them separately because the *how you consume it* differs (local Claude
> Code vs. Eclipse/Copilot).

---

## A — `marianfoo/mcp-sap-docs` (`abap` variant) — *wired into this repo*

A self-hosted documentation MCP server. One codebase ships two variants selected
by the `MCP_VARIANT` env var (or a `.mcp-variant` file): `sap-docs` (everything)
and `abap` (ABAP-focused, smaller/faster). It indexes a large **local** corpus —
the ABAP Keyword Documentation (standard *and* cloud), Clean ABAP / DSAG
guidelines, SAPUI5, CAP, Cloud SDK, BTP and more (15+ sources) — and can also
search **SAP Help Portal** and **SAP Community** live.

- **Search:** hybrid **BM25 (SQLite FTS5)** + local semantic embeddings
  (`Xenova/all-MiniLM-L6-v2`), fused with Reciprocal Rank Fusion.
- **Offline / air-gapped:** pass `includeOnline=false` per search, and run the
  container with `--network none` — the local index works with no internet.
- **Ports (upstream defaults):** `sap-docs` streamable HTTP `3122`; **`abap`
  streamable HTTP `3124`**. The HTTP transports expose `/health` and `/status`.

**Why it's the default for this repo:** anyone editing these utilities in Claude
Code / Cursor gets the official ABAP docs + SAP Community search inline, without
leaving the editor — see [Local wiring](#local-wiring-a) below.

Source: [`marianfoo/mcp-sap-docs`](https://github.com/marianfoo/mcp-sap-docs)
(the `abap` variant is also published as
[`marianfoo/abap-mcp-server`](https://github.com/marianfoo/abap-mcp-server)).

## B — Marian Zeis' ABAP MCP server — *use in Eclipse + Copilot today*

The same engine, presented for **Eclipse ADT + GitHub Copilot** (whose Agent
Mode for ADT made AI editing of ABAP practical). It bundles the **ABAP Keyword
Documentation**, **DSAG ABAP Development Guidelines**, the **ABAP Style Guide
(Clean ABAP)** and an **ABAP Feature Matrix**, and reaches out to SAP Community,
SAP Help and Software Heroes for the best answer. Use the hosted endpoint
`https://mcp-abap.marianzeis.de/mcp` or run it locally (Node/Docker).

Source: ["Finally: An MCP Server for ABAP", Marian Zeis, 2026-02-04](https://blog.zeis.de/posts/2026-02-04-abap-mcp-server/).

## C — SAP's official ABAP MCP Server — *the strategic target*

SAP's roadmap commits to an **official ABAP MCP Server**, shipping in **ABAP
Development Tools for Eclipse** and the **ABAP development tooling for VS Code**,
**GA in Q2 2026**. It builds on the ABAP Language Server and exposes ABAP
development capabilities — both AI-assisted and standard dev operations — as MCP
tools that any compatible agent (GitHub Copilot, Amazon Q, …) can discover and
invoke **against a live ABAP system**. This is the difference from A/B: those
serve *documentation*; C drives *the system*.

It is consumption-based via **Joule for Developers + AI Units** (free trial
extended through **September 2026**).

Sources:
[Entering the New Era of Agentic AI for ABAP Development](https://community.sap.com/t5/technology-blog-posts-by-sap/entering-the-new-era-of-agentic-ai-for-abap-development/ba-p/14394643)
·
[ABAP AI — Chapter 3: We go agentic!](https://community.sap.com/t5/technology-blog-posts-by-sap/abap-ai-chapter-3-we-go-agentic/ba-p/14391469).

## D — Community in-system add-on MCP server — *direct on the system*

An ABAP **add-on installed inside the SAP system itself** (S/4HANA or ECC,
releases down to **7.01**), exposing display/create/update/delete tools directly
at the ABAP layer. You onboard Tables, Views and CDS Views through an ABAP view
and each becomes a tool automatically; create/update/delete tools each need one
method for the action and one for metadata — **no OData services required**. The
server is reached via an **SICF node** or the **SAP Cloud Connector**.

Use this when you want agentic access *on* an older or on-premise system without
waiting for C and without an external ADT bridge.

Source: ["MCP Server for SAP ECC & S/4HANA: Unlimited ABAP Add-on for Display, Create…", SAP Community](https://community.sap.com/t5/technology-blog-posts-by-members/mcp-server-for-sap-ecc-amp-s-4hana-unlimited-abap-add-on-for-display-create/ba-p/14293485).

---

## Recommended path

1. **Today, for this repo:** **A** — the self-hosted `abap` variant, wired into
   `.mcp.json` so Claude Code/Cursor have ABAP docs + Community search inline.
2. **Today, in Eclipse/ADT:** **B** — Marian's hosted endpoint or local server
   with GitHub Copilot Agent Mode.
3. **When GA (Q2 2026):** **C** — SAP's official server for *agentic development
   against a live S/4 system*. See [Migration](#migration--when-saps-official-server-ships).
4. **For direct-on-system agents (esp. ECC / older releases):** **D**.

A/B/C/D are not mutually exclusive: a docs MCP (A/B) and a system MCP (C/D) are
complementary — one answers "how do I write this?", the other "do it on the
system."

---

## Local wiring (A) {#local-wiring-a}

Two files in this repo wire the `abap` variant into any MCP client:

- [`docker-compose.sap-docs.yml`](../docker-compose.sap-docs.yml) — builds and
  runs `marianfoo/mcp-sap-docs` in the `abap` variant.
- [`.mcp.json`](../.mcp.json) — points the MCP client at it.

```bash
# start the server (builds the abap variant from upstream on first run)
docker compose -f docker-compose.sap-docs.yml up -d

# Claude Code / Cursor pick up .mcp.json automatically; verify in Claude Code:
#   /mcp        → "sap-docs" should be connected
```

### Note on the config in the original task spec

The wiring here intentionally differs from the snippet circulated in the task,
because that snippet would not connect. The corrections (all verified against
the upstream project):

| Task snippet | Here | Why |
|--------------|------|-----|
| `url: …:3122/sse` | `…:3122/mcp` | `"type":"http"` is the **Streamable HTTP** transport, served at `/mcp`; `/sse` is the deprecated SSE transport. Host port `3122` is kept by mapping it to the container's `abap` port `3124`. |
| `env: {MCP_VARIANT:"abap", …}` on the client | `MCP_VARIANT=abap` in docker-compose | `env` in `.mcp.json` only applies to **stdio** servers Claude Code spawns. For an `http` server the variant must be set on the **server process** (the container). |
| `abapFlavor:"auto"` as connection env | documented as a **search param** | `abapFlavor` (`standard`/`cloud`/`auto`) is a *per-search* parameter the tools accept, not a connection setting. `auto` is the effective default. |

`.mcp.json` is kept as **strict JSON** (no comments) so every MCP client can
parse it; the explanatory comments live in the compose file and here.

### Offline / air-gapped

The local index needs no internet. To force it, run the container with
`--network none` and pass `includeOnline=false` on searches (omits the live SAP
Help/Community calls). See the comments in `docker-compose.sap-docs.yml`.

---

## Migration — when SAP's official server ships

> **Status (2026-Q2):** SAP's official ABAP MCP Server (option **C**) is slated
> for **GA in Q2 2026**. Update this section the moment GA is confirmed.

When C is GA, the recommended split becomes:

- **Documentation / "how do I write this?"** → keep **A** (or **B** in Eclipse).
  Cheap, offline, no system or AI-Unit consumption.
- **Agentic work against a live system / "do it on the system"** → **C**, the
  official server in ADT for Eclipse or the VS Code ABAP tooling, with **Joule
  for Developers + AI Units**.

**This repository remains the source of the utilities; the official MCP is the
agent surface that operates on a running S/4 system.** Importing a utility from
here (cherry-pick → transport, see the [root README](../README.md#install)) is
unchanged; C simply lets an agent perform that import, run ATC, execute ABAP
Unit, etc., on the system on your behalf.

Migration checklist (to fill in at GA):

- [ ] Confirm GA release and the exact ADT / VS Code component + minimum system
      release.
- [ ] Confirm Joule for Developers / AI-Unit prerequisites for your landscape.
- [ ] Add the official server to client config alongside `sap-docs` (docs MCP +
      system MCP are complementary).
- [ ] Re-test the cherry-pick → transport flow driven by an agent.

---

## Machine-readable utility index

`tools/gen-mcp-index.js` (run `npm run index`) extracts each utility class'
ABAPDoc into [`index/abap-utilities.json`](../index/abap-utilities.json) — object
name, module/package, kind, description and public methods with their `"!`
summaries. It reuses the same source parsing as the API-doc generator
(`tools/gen-api-docs.js`).

The intent is that a docs MCP (option A) could serve this repo's utilities as a
first-class source. Proposing it to
[`marianfoo/mcp-sap-docs`](https://github.com/marianfoo/mcp-sap-docs) as an
additional library is a natural next step (not yet done).

---

## Sources

- A: [`marianfoo/mcp-sap-docs`](https://github.com/marianfoo/mcp-sap-docs) · [`marianfoo/abap-mcp-server`](https://github.com/marianfoo/abap-mcp-server) · [`marianfoo/sap-ai-mcp-servers` (index of SAP MCP servers)](https://github.com/marianfoo/sap-ai-mcp-servers)
- B: [Finally: An MCP Server for ABAP — blog.zeis.de, 2026-02-04](https://blog.zeis.de/posts/2026-02-04-abap-mcp-server/)
- C: [Entering the New Era of Agentic AI for ABAP Development — SAP Community](https://community.sap.com/t5/technology-blog-posts-by-sap/entering-the-new-era-of-agentic-ai-for-abap-development/ba-p/14394643) · [ABAP AI — Chapter 3: We go agentic! — SAP Community](https://community.sap.com/t5/technology-blog-posts-by-sap/abap-ai-chapter-3-we-go-agentic/ba-p/14391469)
- D: [MCP Server for SAP ECC & S/4HANA — SAP Community](https://community.sap.com/t5/technology-blog-posts-by-members/mcp-server-for-sap-ecc-amp-s-4hana-unlimited-abap-add-on-for-display-create/ba-p/14293485)
- MCP transports (Streamable HTTP vs. SSE): [modelcontextprotocol.io](https://modelcontextprotocol.io)
</content>
</invoke>
