# Claude Code × Alibaba Token Plan

> Provider-specific guide. See the [repo README](../README.md) for other providers.

## Config File Locations

```
~/.claude/settings.json   # environment variables
~/.claude.json            # requires hasCompletedOnboarding = true
```

---

## Variables

Written into the `env` block of `~/.claude/settings.json`:

```json
{
  "theme": "dark",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-sp-YOUR_KEY",
    "ANTHROPIC_BASE_URL": "https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic",
    "ANTHROPIC_MODEL": "deepseek-v4.1-flash",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4.1-flash",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4.1-flash",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro",
    "CLAUDE_CODE_SUBAGENT_MODEL": "deepseek-v4.1-flash",
    "CLAUDE_CODE_MAX_CONTEXT_TOKENS": "1048576"
  }
}
```

### What each variable does

| Variable | Purpose | Required |
|---|---|---|
| `ANTHROPIC_AUTH_TOKEN` | Token Plan API key (**not** `ANTHROPIC_API_KEY`) | ✅ |
| `ANTHROPIC_BASE_URL` | Model Studio Anthropic-compatible endpoint | ✅ |
| `ANTHROPIC_MODEL` | Primary model | ✅ |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Model used when `/model` selects **haiku** | optional |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Model used when `/model` selects **sonnet** | optional |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Model used when `/model` selects **opus** | optional |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model used for subagents | optional |
| `CLAUDE_CODE_MAX_CONTEXT_TOKENS` | Override context window (default 200K) | optional |

> 💡 Claude Code only knows the names haiku/sonnet/opus, so the `DEFAULT_*_MODEL` vars map them.

---

## Steps

### First-time setup

**Step 1 — Write to keychain**
```bash
security delete-generic-password -s qwen-token-plan -a codex 2>/dev/null
security add-generic-password -s qwen-token-plan -a codex -w "sk-sp-YOUR_KEY"
```

**Step 2 — Configure `~/.claude/settings.json`**

Method A (recommended — reads the key from keychain automatically):
```bash
python3 scripts/setup_claude.py
```

Method B (paste the Variables JSON above manually)

**Step 3 — Skip the official Anthropic login**

Edit `~/.claude.json` and make sure it contains:
```json
{ "hasCompletedOnboarding": true }
```

**Step 4 — Verify**
```bash
claude -p "Reply with exactly: connection ok"
```

### Switching models

```bash
# Method 1: one-off
ANTHROPIC_MODEL=qwen3.8-max claude

# Method 2: edit ANTHROPIC_MODEL in settings.json, then restart

# Method 3: run /model inside Claude Code and pick haiku/sonnet/opus
#           (mapped via DEFAULT_HAIKU/SONNET/OPUS_MODEL)
```

---

## Notes

1. **The `unrecognized_model` warning is harmless**: Claude Code does not know the name "deepseek" but still works.
2. **No `/v1/models`**: the Model Studio Anthropic endpoint only serves `/v1/messages`; model discovery returns 404.
3. **`temperature` range**: `[0, 2)` (Anthropic official is `[0, 1]`).
4. **Always use `ANTHROPIC_AUTH_TOKEN`**, not `ANTHROPIC_API_KEY`.
