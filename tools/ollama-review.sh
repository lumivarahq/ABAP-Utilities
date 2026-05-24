#!/usr/bin/env bash
#
# ollama-review.sh — review a git diff with a LOCAL LLM via Ollama.
#
# Zero cost, fully offline, no API keys, no code leaves your machine.
#
# Usage:
#   tools/ollama-review.sh                 # review staged changes (git diff --staged)
#   tools/ollama-review.sh --working       # review unstaged working-tree changes
#   tools/ollama-review.sh main            # review current branch vs. base ref 'main'
#
# Env overrides:
#   OLLAMA_MODEL   (default: qwen2.5-coder:7b)
#   OLLAMA_URL     (default: http://localhost:11434)
#   MAX_DIFF_CHARS (default: 12000)
#
set -euo pipefail

MODEL="${OLLAMA_MODEL:-qwen2.5-coder:7b}"
URL="${OLLAMA_URL:-http://localhost:11434}"
MAX="${MAX_DIFF_CHARS:-12000}"

arg="${1:-}"
case "$arg" in
  ""|--staged) DIFF="$(git diff --staged)" ;;
  --working)   DIFF="$(git diff)" ;;
  *)           DIFF="$(git diff "${arg}...HEAD")" ;;
esac

if [ -z "${DIFF}" ]; then
  echo "Nothing to review (empty diff)."
  exit 0
fi

# keep the prompt within a sensible size for local models
DIFF="${DIFF:0:$MAX}"

if ! curl -sf "${URL}/api/tags" >/dev/null 2>&1; then
  echo "Cannot reach Ollama at ${URL}. Is 'ollama serve' running?" >&2
  exit 1
fi

read -r -d '' INSTRUCTIONS <<'EOF' || true
You are a senior ABAP / SAP code reviewer for an abapGit project.
Review ONLY the diff below. Be concise and specific. For each finding give:
- file and (if visible) line
- severity: BUG | CLEAN-CORE | PERFORMANCE | STYLE | TEST
- the problem in one sentence
- a concrete fix (a few lines of ABAP)
Prioritise: correctness bugs; non-released API / Clean Core violations;
nested loops or SELECT-in-loop; missing error handling; missing ABAP Unit tests.
If the diff looks good, say so briefly. Do not invent code that is not in the diff.
EOF

export OLLAMA_MODEL_X="$MODEL" OLLAMA_URL_X="$URL" REVIEW_PROMPT="${INSTRUCTIONS}

=== DIFF ===
${DIFF}"

python3 - <<'PY'
import json, os, sys, urllib.request
model = os.environ["OLLAMA_MODEL_X"]
url   = os.environ["OLLAMA_URL_X"].rstrip("/") + "/api/generate"
body  = json.dumps({"model": model, "prompt": os.environ["REVIEW_PROMPT"], "stream": False}).encode()
req   = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"})
try:
    with urllib.request.urlopen(req) as r:
        print(json.load(r).get("response", "").strip())
except Exception as e:
    sys.exit(f"Ollama request failed: {e}")
PY
