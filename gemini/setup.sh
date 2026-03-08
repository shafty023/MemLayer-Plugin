#!/usr/bin/env bash
# Setup script for ProcIQ Gemini Plugin

set -e

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SKILL_SRC="${PLUGIN_DIR}/skills/memory-usage"
SHARED_SKILL_SRC="${PLUGIN_DIR}/../plugins/memory/skills/memory-usage"
if [ -d "${SHARED_SKILL_SRC}" ]; then
    SKILL_SRC="${SHARED_SKILL_SRC}"
else
    SKILL_SRC="${LOCAL_SKILL_SRC}"
fi

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

echo "Configuring .gemini/settings.json hooks..."
SETTINGS_FILE="./.gemini/settings.json"
HOOKS_DIR="./.gemini/hooks"
SESSION_START_HOOK_SRC="${PLUGIN_DIR}/hooks/session-start.sh"
BEFORE_AGENT_HOOK_SRC="${PLUGIN_DIR}/hooks/before-agent.sh"

if [ -f "${SESSION_START_HOOK_SRC}" ] || [ -f "${BEFORE_AGENT_HOOK_SRC}" ]; then
    mkdir -p "${HOOKS_DIR}"
    
    if [ ! -f "${SETTINGS_FILE}" ]; then
        mkdir -p "$(dirname "${SETTINGS_FILE}")"
        echo '{"mcpServers": {}}' > "${SETTINGS_FILE}"
    fi

    TMP_SETTINGS=$(mktemp)
    cp "${SETTINGS_FILE}" "${TMP_SETTINGS}"

    if [ -f "${SESSION_START_HOOK_SRC}" ]; then
        cp "${SESSION_START_HOOK_SRC}" "${HOOKS_DIR}/session-start.sh"
        chmod +x "${HOOKS_DIR}/session-start.sh"
        echo "✓ SessionStart hook script installed to ${HOOKS_DIR}"
        
        if command -v jq >/dev/null 2>&1; then
            ABS_HOOK_PATH="$(cd "${HOOKS_DIR}" && pwd)/session-start.sh"
            jq --arg hookPath "${ABS_HOOK_PATH}" '
                del(.systemPrompt) | 
                .hooks.SessionStart = [{
                    "hooks": [{
                        "type": "command", 
                        "command": $hookPath,
                        "name": "ProcIQ Memory Reminder",
                        "description": "Auto-loads ProcIQ instructions and reminders"
                    }]
                }]
            ' "${TMP_SETTINGS}" > "${TMP_SETTINGS}.tmp" && mv "${TMP_SETTINGS}.tmp" "${TMP_SETTINGS}"
            echo "✓ settings.json updated with SessionStart hook"
        fi
    fi

    if [ -f "${BEFORE_AGENT_HOOK_SRC}" ]; then
        cp "${BEFORE_AGENT_HOOK_SRC}" "${HOOKS_DIR}/before-agent.sh"
        chmod +x "${HOOKS_DIR}/before-agent.sh"
        echo "✓ BeforeAgent hook script installed to ${HOOKS_DIR}"
        
        if command -v jq >/dev/null 2>&1; then
            ABS_HOOK_PATH="$(cd "${HOOKS_DIR}" && pwd)/before-agent.sh"
            jq --arg hookPath "${ABS_HOOK_PATH}" '
                .hooks.BeforeAgent = [{
                    "hooks": [{
                        "type": "command", 
                        "command": $hookPath,
                        "name": "ProcIQ Memory Cycle",
                        "description": "Injects memory lifecycle into task context"
                    }]
                }]
            ' "${TMP_SETTINGS}" > "${TMP_SETTINGS}.tmp" && mv "${TMP_SETTINGS}.tmp" "${TMP_SETTINGS}"
            echo "✓ settings.json updated with BeforeAgent hook"
        fi
    fi

    mv "${TMP_SETTINGS}" "${SETTINGS_FILE}"
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "Warning: jq not found. Could not automatically update ${SETTINGS_FILE}."
        echo "Please manually configure the hooks in ${SETTINGS_FILE}."
    fi
fi

echo ""
echo "Next steps:"
echo "1. Ensure the 'prociq' MCP server is configured in ${SETTINGS_FILE}"
echo "2. Restart your Gemini CLI session."
