#!/usr/bin/env bash
# Setup script for ProcIQ Codex Plugin

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_SKILL_SRC="${PLUGIN_DIR}/skills/memory-usage"
SHARED_SKILL_SRC="${PLUGIN_DIR}/../plugins/memory/skills/memory-usage"
if [ -d "${SHARED_SKILL_SRC}" ]; then
    SKILL_SRC="${SHARED_SKILL_SRC}"
else
    SKILL_SRC="${LOCAL_SKILL_SRC}"
fi
AGENTS_TEMPLATE="${PLUGIN_DIR}/templates/AGENTS.md"
PROJECT_ROOT="$(pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-${HOME}/.codex}"
TARGET_DIR="${CODEX_HOME_DIR}/skills/memory-usage"
PROJECT_AGENTS_FILE="${PROJECT_ROOT}/AGENTS.md"

STARTUP_MARKER_BEGIN="# >>> MemLayer startup block >>>"
STARTUP_MARKER_END="# <<< MemLayer startup block <<<"
STARTUP_BLOCK="${STARTUP_MARKER_BEGIN}

## MemLayer Memory Policy

- Use the \`memory-usage\` skill for every non-trivial task.
- At the start of every Codex session, call \`prociq_retrieve_context\` before the first substantive task.
- For coding, debugging, refactoring, test-fix, and architecture work, \`prociq_retrieve_context\` must be the first non-trivial action.
- Resolve the default scope after the first retrieval and before any scoped memory write. Ask the user only when multiple scopes are authorized and no default is already clear from context.
- When a command, build, or test fails, stop, log the failure, retrieve context for the error, then retry.
- At task end, log the outcome for the task.
- If the \`memory-usage\` skill or ProcIQ tools are unavailable, state that limitation and continue with best-effort execution.
- The detailed Retrieve -> Act -> Log workflow lives in the globally installed \`memory-usage\` skill.

${STARTUP_MARKER_END}"

upsert_startup_block() {
    local target_file="$1"
    local temp_file
    local begin_line
    local end_line
    local total_lines

    if [ ! -f "${target_file}" ]; then
        return
    fi

    temp_file="$(mktemp)"
    begin_line="$(grep -nF "${STARTUP_MARKER_BEGIN}" "${target_file}" | head -n1 | cut -d: -f1 || true)"

    if [ -n "${begin_line}" ]; then
        end_line="$(awk -F: -v start="${begin_line}" -v marker="${STARTUP_MARKER_END}" '$1 >= start && index($2, marker) { print $1; exit }' <(grep -nF "${STARTUP_MARKER_END}" "${target_file}") || true)"
        if [ -z "${end_line}" ]; then
            end_line="$(wc -l < "${target_file}")"
        fi
        total_lines="$(wc -l < "${target_file}")"

        if [ "${begin_line}" -gt 1 ]; then
            sed -n "1,$((begin_line - 1))p" "${target_file}" > "${temp_file}"
            echo "" >> "${temp_file}"
        else
            : > "${temp_file}"
        fi
        echo "${STARTUP_BLOCK}" >> "${temp_file}"

        if [ "${end_line}" -lt "${total_lines}" ]; then
            echo "" >> "${temp_file}"
            sed -n "$((end_line + 1)),\$p" "${target_file}" >> "${temp_file}"
        fi
    else
        cat "${target_file}" > "${temp_file}"
        total_lines="$(wc -l < "${target_file}")"
        if [ "${total_lines}" -gt 0 ]; then
            echo "" >> "${temp_file}"
        fi
        echo "${STARTUP_BLOCK}" >> "${temp_file}"
    fi

    mv "${temp_file}" "${target_file}"
}

echo "Installing ProcIQ Codex skill..."
echo "Source: ${SKILL_SRC}"
echo "Target: ${TARGET_DIR}"

mkdir -p "$(dirname "${TARGET_DIR}")"

if [ -d "${TARGET_DIR}" ] || [ -L "${TARGET_DIR}" ]; then
    rm -rf "${TARGET_DIR}"
fi

cp -R "${SKILL_SRC}" "${TARGET_DIR}"

mkdir -p "${CODEX_HOME_DIR}"

if [ ! -f "${PROJECT_AGENTS_FILE}" ]; then
    cp "${AGENTS_TEMPLATE}" "${PROJECT_AGENTS_FILE}"
else
    upsert_startup_block "${PROJECT_AGENTS_FILE}"
fi

echo "Done."
echo ""
echo "Next steps:"
echo "1. Configure the ProcIQ MCP server in ${CODEX_HOME_DIR}/config.toml"
echo "2. Restart Codex so the new skill is discovered"
echo "3. MemLayer policy installed or updated in ${PROJECT_AGENTS_FILE}"
