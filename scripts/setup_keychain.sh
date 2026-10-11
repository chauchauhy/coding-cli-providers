#!/bin/bash
# Store the Token Plan API key in the macOS keychain (shared by Codex + Claude Code).
# Usage: ./setup_keychain.sh "sk-sp-xxxxx"
set -euo pipefail

KEY="${1:-}"
SERVICE="qwen-token-plan"
ACCOUNT="codex"

if [ -z "$KEY" ]; then
  echo "Usage: $0 \"sk-sp-YOUR_KEY\"" >&2
  exit 1
fi

if [[ "$KEY" != sk-sp-* ]]; then
  echo "[warn] Key does not look like a Token Plan Personal Edition key (usually starts with sk-sp-)" >&2
fi

# Delete the old entry first (ignore if absent)
security delete-generic-password -s "$SERVICE" -a "$ACCOUNT" >/dev/null 2>&1 || true
# Add the new one
security add-generic-password -s "$SERVICE" -a "$ACCOUNT" -w "$KEY"

echo "[ok] Stored in keychain: service=$SERVICE account=$ACCOUNT"
echo "     last 4 chars: ...${KEY: -4}"
