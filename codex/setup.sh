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
HOOKS_TEMPLATE="${PLUGIN_DIR}/hooks/hooks.json"
SHARED_HOOKS_SCRIPT_DIR="${PLUGIN_DIR}/../plugins/memory/hooks/scripts"
PROJECT_ROOT="$(pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-${HOME}/.codex}"
TARGET_DIR="${PROJECT_ROOT}/.agents/skills/memory-usage"
PROJECT_AGENTS_FILE="${PROJECT_ROOT}/AGENTS.md"
SESSION_START_HOOK_SRC="${SHARED_HOOKS_SCRIPT_DIR}/session-start.sh"
USER_PROMPT_HOOK_SRC="${SHARED_HOOKS_SCRIPT_DIR}/user-prompt.sh"
PROJECT_CODEX_DIR="${PROJECT_ROOT}/.codex"
PROJECT_HOOKS_DIR="${PROJECT_CODEX_DIR}/hooks"
PROJECT_HOOKS_FILE="${PROJECT_CODEX_DIR}/hooks.json"
CODEX_CONFIG_FILE="${CODEX_HOME_DIR}/config.toml"
PROJECT_SESSION_START_HOOK="${PROJECT_HOOKS_DIR}/session-start.sh"
PROJECT_USER_PROMPT_HOOK="${PROJECT_HOOKS_DIR}/user-prompt-submit.sh"

STARTUP_MARKER_BEGIN="# >>> MemLayer startup block >>>"
STARTUP_MARKER_END="# <<< MemLayer startup block <<<"
STARTUP_BLOCK="${STARTUP_MARKER_BEGIN}

## MemLayer Memory Policy

- Use the \`memory-usage\` skill for every non-trivial task.
- For coding, debugging, refactoring, test-fix, and architecture work, \`prociq_retrieve_context\` must be the first non-trivial action.
- When a command, build, or test fails, stop, log the failure, retrieve context for the error, then retry.
- At task end, log reusable outcomes.
- If the \`memory-usage\` skill or ProcIQ tools are unavailable, state that limitation and continue with best-effort execution.
- The detailed Retrieve -> Act -> Log workflow lives in the repo-installed \`memory-usage\` skill under \`.agents/skills\`.

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

ensure_codex_hooks_enabled() {
    local config_file="$1"
    local temp_file

    mkdir -p "$(dirname "${config_file}")"

    if [ ! -f "${config_file}" ]; then
        cat > "${config_file}" <<'EOF'
[features]
codex_hooks = true
EOF
        return
    fi

    temp_file="$(mktemp)"
    awk '
        BEGIN {
            in_features = 0
            features_seen = 0
            hooks_seen = 0
        }

        function emit_codex_hooks() {
            if (!hooks_seen) {
                print "codex_hooks = true"
                hooks_seen = 1
            }
        }

        /^\[features\]$/ {
            features_seen = 1
            in_features = 1
            print
            next
        }

        in_features && /^\[/ {
            emit_codex_hooks()
            in_features = 0
            print
            next
        }

        in_features && /^[[:space:]]*codex_hooks[[:space:]]*=/ {
            print "codex_hooks = true"
            hooks_seen = 1
            next
        }

        {
            print
        }

        END {
            if (in_features) {
                emit_codex_hooks()
            } else if (!features_seen) {
                if (NR > 0) {
                    print ""
                }
                print "[features]"
                print "codex_hooks = true"
            }
        }
    ' "${config_file}" > "${temp_file}"

    mv "${temp_file}" "${config_file}"
}

write_hooks_config() {
    local hooks_file="$1"
    local session_start_hook="$2"
    local user_prompt_hook="$3"

    python3 - "$HOOKS_TEMPLATE" "$hooks_file" "$session_start_hook" "$user_prompt_hook" <<'PY'
import json
import sys

template_path, output_path, session_start_hook, user_prompt_hook = sys.argv[1:]

with open(template_path, "r", encoding="utf-8") as f:
    data = json.load(f)

for event in data.get("hooks", {}).values():
    for matcher in event:
        for hook in matcher.get("hooks", []):
            command = hook.get("command")
            if command == "__SESSION_START_HOOK__":
                hook["command"] = session_start_hook
            elif command == "__USER_PROMPT_HOOK__":
                hook["command"] = user_prompt_hook

with open(output_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
}

echo "Installing ProcIQ Codex skill..."
echo "Source: ${SKILL_SRC}"
echo "Target: ${TARGET_DIR}"

mkdir -p "$(dirname "${TARGET_DIR}")"

if [ -d "${TARGET_DIR}" ] || [ -L "${TARGET_DIR}" ]; then
    rm -rf "${TARGET_DIR}"
fi

cp -R "${SKILL_SRC}" "${TARGET_DIR}"

mkdir -p "${PROJECT_HOOKS_DIR}"
cp "${SESSION_START_HOOK_SRC}" "${PROJECT_SESSION_START_HOOK}"
cp "${USER_PROMPT_HOOK_SRC}" "${PROJECT_USER_PROMPT_HOOK}"
chmod +x "${PROJECT_SESSION_START_HOOK}" "${PROJECT_USER_PROMPT_HOOK}"
write_hooks_config "${PROJECT_HOOKS_FILE}" "${PROJECT_SESSION_START_HOOK}" "${PROJECT_USER_PROMPT_HOOK}"
ensure_codex_hooks_enabled "${CODEX_CONFIG_FILE}"

if [ ! -f "${PROJECT_AGENTS_FILE}" ]; then
    cp "${AGENTS_TEMPLATE}" "${PROJECT_AGENTS_FILE}"
else
    upsert_startup_block "${PROJECT_AGENTS_FILE}"
fi

echo "Done."
echo ""
echo "Next steps:"
echo "1. Codex hooks enabled in ${CODEX_CONFIG_FILE}"
echo "2. Restart Codex if the new skill or hooks are not discovered automatically"
echo "3. Repo skill installed at ${TARGET_DIR}"
echo "4. Repo hooks installed at ${PROJECT_HOOKS_FILE}"
echo "5. MemLayer policy installed or updated in ${PROJECT_AGENTS_FILE}"
