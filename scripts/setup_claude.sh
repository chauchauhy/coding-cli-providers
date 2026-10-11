#!/bin/bash
# Configure Claude Code for Alibaba Token Plan (writes ~/.claude/settings.json).
# Other providers: see ../opencode-go/README.md
set -euo pipefail

python3 "$(dirname "$0")/setup_claude.py"
