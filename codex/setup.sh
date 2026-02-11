#!/usr/bin/env bash
# Setup script for ProcIQ Codex Plugin

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="${PLUGIN_DIR}/skills/memory-usage"
CODEX_HOME_DIR="${CODEX_HOME:-${HOME}/.codex}"
TARGET_DIR="${CODEX_HOME_DIR}/skills/memory-usage"

echo "Installing ProcIQ Codex skill..."
echo "Source: ${SKILL_SRC}"
echo "Target: ${TARGET_DIR}"

mkdir -p "$(dirname "${TARGET_DIR}")"

if [ -d "${TARGET_DIR}" ] || [ -L "${TARGET_DIR}" ]; then
    rm -rf "${TARGET_DIR}"
fi

cp -R "${SKILL_SRC}" "${TARGET_DIR}"

echo "Done."
echo ""
echo "Next steps:"
echo "1. Configure the ProcIQ MCP server in ${CODEX_HOME_DIR}/config.toml"
echo "2. Restart Codex so the new skill is discovered"
