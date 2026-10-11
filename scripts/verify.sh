#!/bin/bash
# Verify that Codex + Claude Code can reach the Token Plan.
set -uo pipefail

BASE_ANTHROPIC="https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic"
BASE_OPENAI="https://token-plan.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1"
MODEL="${MODEL:-deepseek-v4.1-flash}"

KEY=$(/usr/bin/security find-generic-password -s qwen-token-plan -a codex -w 2>/dev/null || true)
if [ -z "$KEY" ]; then
  echo "FAIL: cannot read keychain key (service=qwen-token-plan account=codex)"
  exit 1
fi
echo "KEY: keychain key ...${KEY: -4}"

echo ""
echo "-- 1) Anthropic endpoint (Claude Code) --"
code=$(curl -k -s -o /tmp/_tp_a.json -w "%{http_code}" -m 40 -X POST "$BASE_ANTHROPIC/v1/messages" \
  -H "Content-Type: application/json" -H "x-api-key: $KEY" -H "anthropic-version: 2023-06-01" \
  -d "{\"model\":\"$MODEL\",\"max_tokens\":32,\"messages\":[{\"role\":\"user\",\"content\":\"say hi\"}]}")
if [ "$code" = "200" ]; then echo "OK   HTTP 200 (${MODEL})"; else echo "FAIL HTTP $code"; head -c 300 /tmp/_tp_a.json; echo; fi

echo ""
echo "-- 2) OpenAI endpoint (Codex) --"
code=$(curl -k -s -o /tmp/_tp_o.json -w "%{http_code}" -m 40 -X POST "$BASE_OPENAI/chat/completions" \
  -H "Content-Type: application/json" -H "Authorization: Bearer $KEY" \
  -d "{\"model\":\"$MODEL\",\"max_tokens\":32,\"messages\":[{\"role\":\"user\",\"content\":\"say hi\"}]}")
if [ "$code" = "200" ]; then echo "OK   HTTP 200 (${MODEL})"; else echo "FAIL HTTP $code"; head -c 300 /tmp/_tp_o.json; echo; fi

echo ""
echo "-- 3) Claude Code live run --"
if command -v claude >/dev/null 2>&1; then
  out=$(claude -p "Reply with exactly: connection ok" 2>&1 | tail -1)
  echo "claude says: $out"
else
  echo "(claude CLI not installed)"
fi

echo ""
echo "-- 4) Config snapshot --"
echo "Codex provider:"
grep -A1 "token-plan" "$HOME/.codex/config.toml" 2>/dev/null | head -2 | sed 's/^/  /'
echo "Claude Code env:"
python3 -c "
import json
try:
    e=json.load(open('$HOME/.claude/settings.json')).get('env',{})
    print('  ANTHROPIC_BASE_URL =', e.get('ANTHROPIC_BASE_URL','(not set)'))
    print('  ANTHROPIC_MODEL    =', e.get('ANTHROPIC_MODEL','(not set)'))
except Exception as ex: print('  (unreadable)', ex)
"
