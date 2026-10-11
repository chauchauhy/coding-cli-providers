# Adding OpenCode Go to Codex & Claude Code

**Question:** Can the OpenCode **Go** plan be used from Codex or Claude Code?

**Answer:** ✅ Yes — for both. No code changes are needed; it is a config-only change.

> Verified 2026-10-11 on macOS with `claude-cli/2.1.296` and Codex CLI.
> Both clients completed a live round-trip against `https://opencode.ai/zen/go`.

---

## What "OpenCode Go" is

OpenCode Go is a subscription from the OpenCode team giving access to a curated set of
open coding models. Two tiers: **Go ($10/mo)** and **Go Plus ($40/mo)**.

- It is a **provider**, not a client. You sign in at the OpenCode Console, subscribe,
  and copy an API key.
- The key works with **any Anthropic-Messages / OpenAI-compatible client** that the
  OpenCode team has validated.
- The OpenCode docs explicitly list **Claude Code** and **Codex** as *Validated Clients*.

### Endpoints

| Purpose | Base URL | Protocol |
|---|---|---|
| Anthropic-Messages | `https://opencode.ai/zen/go` | Anthropic Messages API |
| OpenAI-compatible | `https://opencode.ai/zen/go/v1` | chat/completions |
| OpenAI-Responses | `https://opencode.ai/zen/go/v1` | responses |

Model list: `GET https://opencode.ai/zen/go/v1/models`

---

## Two hard requirements

These are enforced by the OpenCode Go gateway. Both clients satisfy them automatically.

1. **Session header.** Requests must identify a session so routing/prompt-caching works.
   - Claude Code sends `X-Claude-Code-Session-Id` (native) — recognised as-is.
   - Codex sends its native session header — recognised as-is.
   - A bare `curl` **must** add `x-opencode-session: <id>` or it gets
     `400 MissingSessionID`.
2. **API key via `x-api-key` (Anthropic path).** OpenCode Go rejects
   `Authorization: Bearer` on the Messages endpoint with `401 Missing API key`.

> ⚠️ **This is the single biggest gotcha for Claude Code:** you must use
> `ANTHROPIC_API_KEY` (→ `x-api-key`), **not** `ANTHROPIC_AUTH_TOKEN` (→ `Bearer`).

---

## Variables

### Claude Code → `~/.claude/settings.json`

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-REPLACE_WITH_OPENCODE_GO_KEY",
    "ANTHROPIC_BASE_URL": "https://opencode.ai/zen/go",
    "ANTHROPIC_MODEL": "claude-haiku-5-5",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku-5-5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "qwen3.8-max",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "minimax-m3",
    "CLAUDE_CODE_SUBAGENT_MODEL": "qwen3.8-max"
  }
}
```

Notes:
- `ANTHROPIC_BASE_URL` **must not** end in `/v1` — Claude Code appends `/v1/messages` itself.
- Use only models served on the Anthropic-Messages path:
  `claude-haiku-5-5`, `minimax-m3`, `minimax-m2.7`, `qwen3.8-max`, `qwen3.8-flash`, `qwen3.7-plus`.

### Codex → `~/.codex/config.toml`

```toml
model = "gpt-6-luna"
model_provider = "opencode_go"

[model_providers.opencode_go]
name     = "OpenCode Go"
base_url = "https://opencode.ai/zen/go/v1"
wire_api = "responses"

[model_providers.opencode_go.auth]
command             = "/bin/echo"
args                = ["sk-REPLACE_WITH_OPENCODE_GO_KEY"]
timeout_ms          = 5000
refresh_interval_ms = 0
```

Notes:
- Codex uses the **Responses** API → `base_url` ends in `/v1`.
- Models served on the Responses path: `gpt-6-luna`, `gpt-5.6-luna`, `grok-4.7`, `grok-4.6`, `muse-spark-1.3-contributor`, `muse-spark-1.2-contributor`.
- Add a matching entry to `~/.codex/model-catalog.local.json` to silence the
  `Unknown model ... fallback metadata` warning (cosmetic only).

---

## Steps

### Claude Code

1. Get the key: OpenCode Console → subscribe to Go → copy API key.
2. Store it (keychain preferred):
   ```bash
   security add-generic-password -s opencode-go -a claude -w "sk-YOUR_KEY"
   ```
3. Point `~/.claude/settings.json` at it (see Variables). To avoid hard-coding,
   generate the file with the key injected at runtime.
4. Restart Claude Code and run `/status` to confirm the base URL.

### Codex

1. Store the key (keychain):
   ```bash
   security add-generic-password -s opencode-go -a codex -w "sk-YOUR_KEY"
   ```
2. Add the `opencode_go` provider + set `model_provider` (see Variables).
   Replace the `auth` block with a keychain read if you prefer:
   ```toml
   [model_providers.opencode_go.auth]
   command = "/usr/bin/security"
   args = ["find-generic-password", "-s", "opencode-go", "-a", "codex", "-w"]
   ```
3. Run `codex` and pick the model.

---

## Verified evidence (2026-10-11)

| Check | Result |
|---|---|
| `GET /zen/go/v1/models` | 200 — 38 models listed |
| `POST /zen/go/v1/messages` + `x-api-key` + `X-Claude-Code-Session-Id` | 200 |
| `POST /zen/go/v1/messages` + `Authorization: Bearer` | **401 Missing API key** |
| `POST /zen/go/v1/messages` with no session header | **400 MissingSessionID** |
| Claude Code live (`claude -p`) via `/zen/go` | ✅ answered correctly |
| Codex live (`codex exec`) via `/zen/go/v1` | ✅ answered correctly |

---

## Limitations / risks

1. **No `count_tokens` guarantee.** The Messages endpoint is the only documented surface;
   clients that call auxiliary endpoints (e.g. token counting) may behave differently.
2. **Model-to-endpoint mapping matters.** Each model is served on a specific path.
   Using the wrong path/model pairing can fail even with a valid key.
3. **No `/v1/models` on the Anthropic path.** Model discovery for Anthropic clients will 404.
4. **Not officially guaranteed.** The OpenCode docs say validated clients *"may not
   continue to work in the future."*
5. **Usage limits are monthly dollar amounts** per plan (Go vs Go Plus); see the
   OpenCode Go docs for per-model request estimates.
6. **Traffic is monitored for abuse.** Send typical coding-agent traffic and a stable session id.

---

## Recommendation

- Both integrations work today and need **no code changes** — only `settings.json` /
  `config.toml`.
- If you already run **Alibaba Token Plan**, that path is more battle-tested here
  (see the root README) and provides `count_tokens`. Consider OpenCode Go as an
  **additional** provider, not a replacement, unless its model lineup fits you better.
- Keep the two providers in **separate config profiles** so you can switch without
  editing a single file each time.
