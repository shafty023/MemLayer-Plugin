#!/usr/bin/env bash
# Setup script for ProcIQ Gemini Plugin

set -e

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="${PLUGIN_DIR}/skills/memory-usage"

echo "Installing ProcIQ Gemini Plugin skills to workspace..."

# We install to the local workspace (.gemini/skills) instead of ~/.gemini/skills
# to ensure compatibility with Gemini CLI's sandboxing, which often restricts
# access to the user's home directory.

if command -v gemini >/dev/null 2>&1; then
    echo "Using 'gemini skills install'..."
    gemini skills install "${SKILL_SRC}" --scope workspace --consent
else
    echo "Gemini CLI not found in PATH. Performing manual installation..."
    TARGET_DIR="./.gemini/skills/memory-usage"
    mkdir -p "$(dirname "${TARGET_DIR}")"
    
    if [ -d "${TARGET_DIR}" ] || [ -L "${TARGET_DIR}" ]; then
        rm -rf "${TARGET_DIR}"
    fi
    
    # Use copy instead of symlink to avoid sandbox boundary issues
    cp -R "${SKILL_SRC}" "${TARGET_DIR}"
    echo "✓ Skill copied to ${TARGET_DIR}"
fi

echo ""
echo "Next steps:"
echo "1. Ensure the ProcIQ MCP server is configured in your local .gemini/settings.json"
echo "2. Restart your Gemini CLI session."
