#!/usr/bin/env bash
# Forwarding wrapper; the implementation lives in the installed
# cross-language-crystal-parity skill (see AGENTS.md > Parity tooling).
set -euo pipefail
SKILL_DIR="${PARITY_SKILL_DIR:-/Users/dominic/.config/opencode/skills/cross-language-crystal-parity}"
exec "${SKILL_DIR}/scripts/$(basename "$0")" "$@"
