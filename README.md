# coding-cli-providers

Wire **Codex** and **Claude Code** to alternative model providers on macOS.

Currently covered:

- **Alibaba Cloud Model Studio — Token Plan** (Personal Edition)
- **OpenCode Go** (OpenCode's subscription provider)

> ✅ Verified 2026-10-11 on macOS: both clients work against both providers, config-only.

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
