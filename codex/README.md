# Codex × Alibaba Token Plan

> Provider-specific guide. See the [repo README](../README.md) for other providers.

## Config File Locations

```
~/.codex/config.toml              # main config (provider + model)
~/.codex/auth.json                # API key (apikey mode)
~/.codex/model-catalog.local.json # available models (incl. context window)
```

---

## Variables

### 1) `~/.codex/config.toml`

```toml
# --- Which model / provider to use ---
model              = "deepseek-v4.1-flash"
model_provider     = "Model_Studio_Token_Plan_Personal"
model_catalog_json = "~/.codex/model-catalog.local.json"

# --- Reasoning effort: low | medium | xhigh ---
model_reasoning_effort = "xhigh"

# --- Provider definition ---
[model_providers.Model_Studio_Token_Plan_Personal]
name     = "Model_Studio_Token_Plan_Personal"
base_url = "https://token-plan.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1"
wire_api = "responses"

# --- Auth: read from macOS keychain ---
[model_providers.Model_Studio_Token_Plan_Personal.auth]
command             = "/usr/bin/security"
args                = ["find-generic-password", "-s", "qwen-token-plan", "-a", "codex", "-w"]
timeout_ms          = 5000
refresh_interval_ms = 0
```

### 2) Keychain Entry

| Attribute | Value |
|---|---|
| Service (`-s`) | `qwen-token-plan` |
| Account (`-a`) | `codex` |
| Password | Your Token Plan Personal Edition API Key (`sk-sp-...`) |

Read command:
```bash
security find-generic-password -s qwen-token-plan -a codex -w
```

---

## Steps

### First-time setup

**Step 1 — Write to keychain**
```bash
security delete-generic-password -s qwen-token-plan -a codex 2>/dev/null
security add-generic-password -s qwen-token-plan -a codex -w "sk-sp-YOUR_KEY"
```

**Step 2 — Create / edit `~/.codex/config.toml`** (paste the Variables block above)

**Step 3 — Create `~/.codex/model-catalog.local.json`** (see below)

**Step 4 — Verify**
```bash
codex --version
# Start a new session and ask something to confirm it responds
```

### Switching models

Edit `model = "..."` in `config.toml`, or:
```bash
codex --model qwen3.8-max
```
(The target model must be defined in `model-catalog.local.json`.)

### After the key expires

```bash
security delete-generic-password -s qwen-token-plan -a codex
security add-generic-password -s qwen-token-plan -a codex -w "sk-sp-NEW_KEY"
# config.toml does NOT need changes (it reads the keychain dynamically)
```

---

## model-catalog.local.json structure

One entry per model. Key fields:

```json
{
  "models": [
    {
      "slug": "deepseek-v4.1-flash",
      "display_name": "deepseek-v4.1-flash",
      "description": "DashScope model: deepseek-v4.1-flash",
      "default_reasoning_level": "xhigh",
      "supported_reasoning_levels": [
        { "effort": "low",    "description": "Fast responses with lighter reasoning" },
        { "effort": "medium", "description": "Greater reasoning depth for complex problems" },
        { "effort": "xhigh",  "description": "Extra high reasoning depth for complex problems" }
      ],
      "context_window": 1048576,
      "effective_context_window_percent": 95,
      "supports_parallel_tool_calls": false,
      "input_modalities": ["text"],
      "shell_type": "default",
      "visibility": "list",
      "supported_in_api": true,
      "truncation_policy": { "mode": "bytes", "limit": 10000 }
    }
  ]
}
```

Available slugs (see [`../reference/models.md`](../reference/models.md)):

| slug | context_window |
|---|---|
| `qwen3.8-max` | 983616 |
| `qwen3.8-flash` | 983616 |
| `qwen3.7-max` | 983616 |
| `qwen3.7-plus` | 983616 |
| `qwen3.6-flash` | 983616 |
| `deepseek-v4.1-flash` | 1048576 |
| `deepseek-v4-pro` | 1048576 |
| `deepseek-v4-flash-0731` | 1048576 |
| `glm-5.2` | 1048576 |
| `glm-5.3` | 1048576 |

---

## Notes

- **`wire_api = "responses"`**: Codex uses the Responses API format, not chat/completions. This is the biggest difference from Claude Code.
- **`model_provider` must exactly match** the `[model_providers.XXX]` section name.
- **The provider name contains `_`**: TOML handles `[model_providers.Model_Studio_Token_Plan_Personal]` fine, but be careful with quoting if you pass it to a shell.
