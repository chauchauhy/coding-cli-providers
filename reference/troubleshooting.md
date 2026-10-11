# Troubleshooting — Common Error Reference

## HTTP Status Codes

| HTTP | code / message | Meaning | Fix |
|---|---|---|---|
| **401** | `InvalidApiKey` | Wrong key, or key does not match the region | Confirm the key matches the region; use the keychain key |
| **403** | `AccessDenied.Unpurchased` | Key is valid but has **no subscription** / model not covered | Use the key that has the subscription; confirm the model is in your plan |
| **404** | (model list) | Anthropic endpoint has no `/v1/models` | Expected behavior, not a bug |
| **400** | `InvalidParameter` | e.g. `temperature` outside `[0, 2)` | Adjust the parameter |
| **429** | quota / rate | Credits exhausted or rate limit | Wait for the next cycle / buy a top-up pack |

### Example: `AccessDenied.Unpurchased`

```
{"code":"AccessDenied.Unpurchased",
 "message":"Access to model denied. Please make sure you are eligible for using the model."}
```

**Most common causes**:
- Using a key that has **no subscription** (e.g. an old key hard-coded in a shell rc file)
- Using the right key but calling a model **not included in the plan**

**Diagnose**:
```bash
# Control test: hit several models with the same key to see which work
KEY=$(security find-generic-password -s qwen-token-plan -a codex -w)
curl -s -X POST "https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic/v1/messages" \
  -H "x-api-key: $KEY" -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{"model":"deepseek-v4.1-flash","max_tokens":8,"messages":[{"role":"user","content":"hi"}]}'
```

---

## Symptom → Cause → Fix

| Symptom | Cause | Fix |
|---|---|---|
| Codex / Claude does not respond | Key expired | Update keychain; re-run the setup script |
| `InvalidApiKey` | Endpoint region and key region mismatch | Align both to the same region |
| Claude Code shows `unrecognized_model` | It does not know the name "deepseek" | **Harmless, safe to ignore** |
| Claude Code still asks you to log in | `hasCompletedOnboarding` not set | Set `~/.claude.json` to `true` |
| Only the haiku model works | `ANTHROPIC_DEFAULT_*_MODEL` not set | Fill in all three mappings |
| Context is only 200K | `CLAUDE_CODE_MAX_CONTEXT_TOKENS` not set | Set it to `1048576` |
| Shell rc key suddenly stops working | Subscription renewed → key changes | Switch to reading from keychain |

---

## Diagnostic Commands

```bash
# 1) Show the last 4 chars of the keychain key (to confirm which key it is)
security find-generic-password -s qwen-token-plan -a codex -w | tail -c 5

# 2) Show the env Claude Code actually uses
python3 -c "import json;print(json.load(open('$HOME/.claude/settings.json'))['env'])"

# 3) Show the Codex provider config
sed -n '/\[model_providers/,/^$/p' ~/.codex/config.toml

# 4) Check status inside Claude Code
#    (run inside claude) /status
```

---

## The Two-Key Trap ⚠️

This machine once had **two** keys at the same time:

| Source | Status |
|---|---|
| `~/.zshrc` hard-coded `QWEN_TOKEN_PLAN_API_KEY` | ❌ expired (403) |
| keychain `qwen-token-plan`/`codex` | ✅ valid (200) |

→ **Always trust the keychain.** `~/.zshrc` has been changed to read from the keychain dynamically.
