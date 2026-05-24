# Local AI code review with Ollama (free, offline)

Run an AI reviewer for your ABAP diffs **entirely on your machine** — no API
keys, no cloud, no code leaving the network. This is the local stand-in for
hosted reviewers (codex/gemini) and complements abaplint (which checks syntax &
style; the LLM reasons about intent, Clean Core and tests).

> Sources: [Ollama qwen2.5-coder](https://ollama.com/library/qwen2.5-coder) ·
> [Self-hosted AI code review (SitePoint)](https://www.sitepoint.com/self-hosting-ai-code-review-local-models/) ·
> [Free AI review bot with Ollama (DEV)](https://dev.to/satstack/build-a-free-ai-code-review-bot-in-python-with-ollama-and-git-hooks-4k7b)

## 1. Install Ollama
- **macOS / Windows:** download from <https://ollama.com/download>.
- **Linux:** `curl -fsSL https://ollama.com/install.sh | sh`

Start the server (the app does this automatically; on Linux/servers run):
```bash
ollama serve        # listens on http://localhost:11434
```

## 2. Pull a code model
```bash
ollama pull qwen2.5-coder:7b      # good default on a laptop (~5 GB)
# bigger / better if you have the RAM/VRAM:
# ollama pull qwen2.5-coder:14b
# ollama pull qwen2.5-coder:32b
```
`qwen2.5-coder` is currently the strongest open code model family; the 7B fits
most laptops, 14B/32B get closer to hosted-model quality.

## 3. Review a diff
This repo ships [`tools/ollama-review.sh`](../tools/ollama-review.sh):

```bash
# review what you're about to commit
git add -A
tools/ollama-review.sh

# review unstaged work
tools/ollama-review.sh --working

# review the whole feature branch vs. main
tools/ollama-review.sh main
```

Override the model or endpoint via env vars:
```bash
OLLAMA_MODEL=qwen2.5-coder:14b tools/ollama-review.sh main
OLLAMA_URL=http://my-gpu-box:11434 tools/ollama-review.sh
```

The script sends the diff to Ollama with an **ABAP/Clean-Core-aware prompt** and
prints findings grouped by severity (BUG / CLEAN-CORE / PERFORMANCE / STYLE /
TEST).

## 4. (Optional) run it automatically

### Pre-commit hook
```bash
printf '#!/usr/bin/env bash\nexec tools/ollama-review.sh --staged\n' > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```
> Tip: keep the LLM hook **advisory** (print, don't block) — let abaplint be the
> hard gate, since it's deterministic. The LLM is for judgement, not pass/fail.

### Sanity check the endpoint by hand
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:7b",
  "prompt": "Reply with: ok",
  "stream": false
}'
```

## How this fits the toolchain
| Tool | Catches | Deterministic? | Gate |
|------|---------|:--:|:--:|
| abaplint (`npm run lint`) | syntax, Clean ABAP style, naming | ✅ | hard (CI) |
| ABAP Unit | behaviour / regressions | ✅ | hard (CI) |
| ATC (Cloud ATC) | Clean Core / released-API findings | ✅ | hard |
| Ollama review | intent, design, missed tests, subtle bugs | ❌ | advisory |
