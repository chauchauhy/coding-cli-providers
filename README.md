# coding-cli-providers

Wire **Codex** and **Claude Code** to alternative model providers on **macOS & Windows**.

Currently covered:

- **Alibaba Cloud Model Studio — Token Plan** (Personal Edition)
- **OpenCode Go** (OpenCode's subscription provider)

> ✅ Verified 2026-10-11 on macOS: both clients work against both providers, config-only.
> See [Windows](#windows) for the platform differences.

---

## Contents

| Path | Description |
|---|---|
| [`codex/README.md`](codex/README.md) | Codex CLI setup for Alibaba Token Plan (variables + steps) |
| [`claude-code/README.md`](claude-code/README.md) | Claude Code setup for Alibaba Token Plan (variables + steps) |
| [`opencode-go/README.md`](opencode-go/README.md) | Using the OpenCode Go plan from Codex & Claude Code |
| [`scripts/`](scripts/) | Reusable setup scripts |
| [`reference/models.md`](reference/models.md) | Supported models, endpoints, limits |
| [`reference/troubleshooting.md`](reference/troubleshooting.md) | Error reference table |
| [Windows](#windows) | Path mapping and `env_key` setup for Windows |

---

## Providers at a glance

| | Alibaba Token Plan | OpenCode Go |
|---|---|---|
| Anthropic (Claude Code) | `https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic` | `https://opencode.ai/zen/go` |
| Responses (Codex) | `https://token-plan.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1` | `https://opencode.ai/zen/go/v1` |
| Auth header (Anthropic path) | `Bearer` **or** `x-api-key` | **`x-api-key` only** |
| Claude Code env var | `ANTHROPIC_AUTH_TOKEN` | `ANTHROPIC_API_KEY` |
| Codex `wire_api` | `responses` | `responses` |
| Token counting endpoint | ✅ present | ❌ not documented |
| Guide | this README + [`codex/`](codex/) · [`claude-code/`](claude-code/) | [`opencode-go/`](opencode-go/) |

---

## Architecture

```
                        ┌───────────────────────────────────────────────┐
                        │   Model providers                             │
                        │   ┌───────────────────────────────────────┐   │
                        │   │ Alibaba Token Plan (Personal)         │   │
                        │   │   purchase region: Beijing            │   │
                        │   │   key: keychain qwen-token-plan       │   │
                        │   └───────────────────────────────────────┘   │
                        │   ┌───────────────────────────────────────┐   │
                        │   │ OpenCode Go                           │   │
                        │   │   key: OpenCode Console               │   │
                        │   └───────────────────────────────────────┘   │
                        └───────────────┬───────────────────────────────┘
                                        │
                 ┌──────────────────────┴──────────────────────┐
                 │                                             │
    ┌────────────▼────────────┐              ┌─────────────────▼──────────────┐
    │  Codex                  │              │  Claude Code                   │
    │  wire_api = responses   │              │  Anthropic Messages API        │
    │  ~/.codex/config.toml   │              │  ~/.claude/settings.json       │
    └─────────────────────────┘              └────────────────────────────────┘
```

**In one line**: one config file per client, one provider block per provider, one keychain
entry per key.

---

## Quick Start

### Alibaba Token Plan

```bash
# 1) Store the API key in keychain (once)
./scripts/setup_keychain.sh "sk-sp-xxxxx"

# 2) Configure Codex
./scripts/setup_codex.sh

# 3) Configure Claude Code
./scripts/setup_claude.sh

# 4) Verify
./scripts/verify.sh
```

### OpenCode Go

See [`opencode-go/README.md`](opencode-go/README.md) — config-only, no scripts required.

---

## Core variables (Alibaba Token Plan)

| Purpose | Codex | Claude Code |
|---|---|---|
| Auth | keychain command (inside `config.toml`) | `ANTHROPIC_AUTH_TOKEN` (env) |
| Endpoint | `.../compatible-mode/v1` | `.../apps/anthropic` |
| Protocol | `wire_api = "responses"` | Anthropic Messages API |
| Primary model | `model = "deepseek-v4.1-flash"` | `ANTHROPIC_MODEL` |
| Context | `context_window` (catalog) | `CLAUDE_CODE_MAX_CONTEXT_TOKENS` |
| Config file | `~/.codex/config.toml` | `~/.claude/settings.json` |

---

## Windows

Everything above is macOS-specific. On Windows the endpoints, model IDs, config file
formats, and auth-header rules are identical — only the **paths** and the **secret
storage** change.

### Path mapping

| macOS | Windows |
|---|---|
| `~/.codex/config.toml` | `C:\Users\<user>\.codex\config.toml` |
| `~/.codex/auth.json` | `C:\Users\<user>\.codex\auth.json` |
| `~/.codex/model-catalog.local.json` | `C:\Users\<user>\.codex\model-catalog.local.json` |
| `~/.claude/settings.json` | `C:\Users\<user>\.claude\settings.json` |
| `~/.claude.json` | `C:\Users\<user>\.claude.json` |
| `*.sh` scripts | PowerShell (`*.ps1`) |
| `./scripts/verify.sh` | `.\scripts\verify.ps1` |

### Secret storage: keychain → `env_key`

Windows has no `/usr/bin/security` command, so the macOS keychain block does not
work. Codex officially supports `env_key`, which is the recommended Windows approach.
(`cmdkey` / PowerShell `CredentialManager` can substitute, but `env_key` is simpler.)

**Codex — `config.toml`**

```toml
model = "deepseek-v4.1-flash"
model_provider = "Model_Studio_Token_Plan_Personal"

[model_providers.Model_Studio_Token_Plan_Personal]
name     = "Model_Studio_Token_Plan_Personal"
base_url = "https://token-plan.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1"
wire_api = "responses"
env_key  = "ALIBABA_TOKEN_PLAN_KEY"
```

```powershell
# Persistent (new terminals pick it up)
setx ALIBABA_TOKEN_PLAN_KEY "sk-sp-YOUR_KEY"
```

**Claude Code — `settings.json`**

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-sp-YOUR_KEY",
    "ANTHROPIC_BASE_URL": "https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic",
    "ANTHROPIC_MODEL": "deepseek-v4.1-flash"
  }
}
```

> ⚠️ On Windows, `ANTHROPIC_AUTH_TOKEN` (→ `Bearer`) works for Alibaba Token Plan,
> but OpenCode Go requires `ANTHROPIC_API_KEY` (→ `x-api-key`). See
> [`opencode-go/README.md`](opencode-go/README.md).

### Client support

| Client | Windows support |
|---|---|
| Claude Code | Requires **WSL** or **Git for Windows** (run from WSL / Git Bash) |
| Codex | Native **Windows desktop app**, Windows sandbox, or WSL |
| OpenCode | Native Windows support |

---

## Key Facts

1. **Token Plan subscriptions can only be purchased in China North 2 (Beijing)**, but the API is reachable via the Singapore endpoint (lower latency).
2. **The keychain is the single source of truth for the key.** A key hard-coded in a shell rc file will silently expire.
3. **The Anthropic endpoint has no `/v1/models`**: only `/v1/messages`, so model discovery returns 404.
4. **`temperature` range differs**: Model Studio uses `[0, 2)`, Anthropic uses `[0, 1]`.
5. **Night discount** (22:00–08:00): qwen3.8-max / qwen3.8-flash are **60% off**; the deepseek family is **50% off**.
6. **Auth header is provider-specific**: Token Plan accepts `Bearer`; OpenCode Go requires `x-api-key`.

---

## License

Personal setup notes. Use freely.
