#!/bin/bash
# Configure Codex for Alibaba Token Plan (writes the provider block into ~/.codex/config.toml).
# Other providers: see ../opencode-go/README.md
set -euo pipefail

CFG="$HOME/.codex/config.toml"

if [ ! -f "$CFG" ]; then
  echo "[error] $CFG not found (install Codex / run it once first)" >&2
  exit 1
fi

# Backup
cp "$CFG" "$CFG.bak-$(date +%Y%m%d-%H%M%S)"
echo "[ok] Backed up $CFG"

# Check whether the provider is already present
if grep -q "token-plan.ap-southeast-1.maas.aliyuncs.com" "$CFG"; then
  echo "[ok] Token Plan provider already present, nothing to add"
else
  cat >> "$CFG" <<'TOML'

# --- Alibaba Cloud Model Studio Token Plan (Personal Edition) ---
[model_providers.Model_Studio_Token_Plan_Personal]
name     = "Model_Studio_Token_Plan_Personal"
base_url = "https://token-plan.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1"
wire_api = "responses"

[model_providers.Model_Studio_Token_Plan_Personal.auth]
command             = "/usr/bin/security"
args                = ["find-generic-password", "-s", "qwen-token-plan", "-a", "codex", "-w"]
timeout_ms          = 5000
refresh_interval_ms = 0
TOML
  echo "[ok] Added provider config"
fi

# Ensure the top-level model / model_provider are set
if ! grep -q '^model = ' "$CFG"; then
  echo "[warn] config.toml has no model setting; add it manually:"
  echo '       model = "deepseek-v4.1-flash"'
fi

echo "[done] Codex setup complete. Start a new session to verify."
