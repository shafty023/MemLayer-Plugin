#!/usr/bin/env bash
# Setup script for ProcIQ Codex Plugin

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="${PLUGIN_DIR}/skills/memory-usage"
AGENTS_TEMPLATE="${PLUGIN_DIR}/templates/AGENTS.md"
PROJECT_ROOT="$(pwd)"
CODEX_HOME_DIR="${PROJECT_ROOT}/.codex"
TARGET_DIR="${CODEX_HOME_DIR}/skills/memory-usage"
PROJECT_AGENTS_FILE="${PROJECT_ROOT}/AGENTS.md"

STARTUP_MARKER_BEGIN="# >>> MemLayer startup block >>>"
STARTUP_MARKER_END="# <<< MemLayer startup block <<<"
STARTUP_BLOCK="${STARTUP_MARKER_BEGIN}

## MemLayer Startup Enforcement

- For every non-trivial user task, use the \`memory-usage\` skill before implementation and follow Retrieve -> Act -> Log.
- At the start of EVERY Codex session, call \`prociq_retrieve_context\` for a session bootstrap before the first substantive task.
- For coding, debugging, refactoring, test-fix, and architecture tasks, first call \`prociq_retrieve_context\` with the concrete task details.
- At task end, call \`prociq_log_episode\` for reusable outcomes.
- On command/test/build failure, log a failure episode before retrying.

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
fi
upsert_startup_block "${PROJECT_AGENTS_FILE}"

echo "Done."
echo ""
echo "Next steps:"
echo "1. Configure the ProcIQ MCP server in ${PROJECT_ROOT}/.codex/config.toml"
echo "2. Restart Codex so the new skill is discovered"
echo "3. Startup memory enforcement installed in ${PROJECT_AGENTS_FILE}"
