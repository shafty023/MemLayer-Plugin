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

echo "Configuring .gemini/settings.json..."
SETTINGS_FILE="./.gemini/settings.json"
SYSTEM_PROMPT_FILE="${PLUGIN_DIR}/prompts/system.md"

if [ -f "${SYSTEM_PROMPT_FILE}" ]; then
    SYSTEM_PROMPT=$(cat "${SYSTEM_PROMPT_FILE}")
    
    if [ ! -f "${SETTINGS_FILE}" ]; then
        mkdir -p "$(dirname "${SETTINGS_FILE}")"
        echo '{"mcpServers": {}}' > "${SETTINGS_FILE}"
    fi
    
    if command -v jq >/dev/null 2>&1; then
        # Use jq to safely update the JSON file
        TMP_SETTINGS=$(mktemp)
        jq --arg prompt "${SYSTEM_PROMPT}" '.systemPrompt = $prompt' "${SETTINGS_FILE}" > "${TMP_SETTINGS}"
        mv "${TMP_SETTINGS}" "${SETTINGS_FILE}"
        echo "✓ systemPrompt updated in ${SETTINGS_FILE}"
    else
        echo "Warning: jq not found. Could not automatically update ${SETTINGS_FILE}."
        echo "Please manually add the contents of ${SYSTEM_PROMPT_FILE} to the 'systemPrompt' field in ${SETTINGS_FILE}."
    fi
fi

echo ""
echo "Next steps:"
echo "1. Ensure the 'prociq' MCP server is configured in ${SETTINGS_FILE}"
echo "2. Restart your Gemini CLI session."
