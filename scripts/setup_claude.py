#!/usr/bin/env python3
"""
Configure Claude Code for the Alibaba Cloud Model Studio Token Plan.

- Reads the API key from the macOS keychain (service=qwen-token-plan, account=codex)
- Writes the env block into ~/.claude/settings.json
- Ensures ~/.claude.json has hasCompletedOnboarding = true

Overridable environment variables:
  TP_MODEL        primary model (default: deepseek-v4.1-flash)
  TP_MODEL_OPUS   model for /model opus   (default: deepseek-v4-pro)
  TP_MODEL_HAIKU  model for /model haiku  (default: same as primary)
  TP_BASE_URL     endpoint (default: Singapore Anthropic endpoint)
"""
import json, subprocess, shutil, datetime, pathlib, os, sys

HOME = pathlib.Path.home()
SETTINGS = HOME / ".claude" / "settings.json"
CLAUDE_JSON = HOME / ".claude.json"

MODEL       = os.environ.get("TP_MODEL", "deepseek-v4.1-flash")
MODEL_OPUS  = os.environ.get("TP_MODEL_OPUS", "deepseek-v4-pro")
MODEL_HAIKU = os.environ.get("TP_MODEL_HAIKU", MODEL)
BASE_URL    = os.environ.get(
    "TP_BASE_URL", "https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic"
)

# 1) Read the key from keychain
key = subprocess.run(
    ["/usr/bin/security", "find-generic-password", "-s", "qwen-token-plan", "-a", "codex", "-w"],
    capture_output=True, text=True, timeout=10,
).stdout.strip()
if not key:
    print("ERROR: cannot read keychain key. Run setup_keychain.sh first.", file=sys.stderr)
    sys.exit(1)
print(f"[ok] keychain key ...{key[-4:]}")

# 2) Back up
ts = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
if SETTINGS.exists():
    bak = SETTINGS.with_name(f"settings.json.bak-{ts}")
    shutil.copy2(SETTINGS, bak)
    print(f"[ok] backed up -> {bak.name}")
    cfg = json.loads(SETTINGS.read_text())
else:
    cfg = {}

# 3) Write the env block (preserve other settings)
cfg.setdefault("theme", "dark")
cfg["env"] = {
    "ANTHROPIC_AUTH_TOKEN": key,
    "ANTHROPIC_BASE_URL": BASE_URL,
    "ANTHROPIC_MODEL": MODEL,
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": MODEL_HAIKU,
    "ANTHROPIC_DEFAULT_SONNET_MODEL": MODEL,
    "ANTHROPIC_DEFAULT_OPUS_MODEL": MODEL_OPUS,
    "CLAUDE_CODE_SUBAGENT_MODEL": MODEL,
    "CLAUDE_CODE_MAX_CONTEXT_TOKENS": "1048576",
}
cfg.pop("model", None)   # controlled via env instead

SETTINGS.parent.mkdir(parents=True, exist_ok=True)
SETTINGS.write_text(json.dumps(cfg, indent=2, ensure_ascii=False) + "\n")
print(f"[ok] wrote {SETTINGS}")
print(f"     ANTHROPIC_MODEL = {MODEL}")

# 4) Skip the official login
if CLAUDE_JSON.exists():
    d = json.loads(CLAUDE_JSON.read_text())
    if not d.get("hasCompletedOnboarding"):
        d["hasCompletedOnboarding"] = True
        CLAUDE_JSON.write_text(json.dumps(d, ensure_ascii=False))
        print("[ok] set hasCompletedOnboarding=true")
    else:
        print("[ok] hasCompletedOnboarding already true")
else:
    CLAUDE_JSON.write_text(json.dumps({"hasCompletedOnboarding": True}, indent=2))
    print("[ok] created ~/.claude.json")
