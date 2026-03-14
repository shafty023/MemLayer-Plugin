#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-${HOME}/.codex}"
SKILL_DIR="${CODEX_HOME_DIR}/skills/memory-usage"
AGENTS_FILE="${REPO_ROOT}/AGENTS.md"
STARTUP_MARKER_BEGIN="# >>> MemLayer startup block >>>"
STARTUP_MARKER_END="# <<< MemLayer startup block <<<"
MCP_SERVER="${MEMLAYER_SERVER_NAME:-memlayer}"
MCP_URL="${MEMLAYER_MCP_URL:-https://prociq.ai/mcp}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command '$1' is not installed." >&2
    exit 1
  fi
}

is_non_trivial_task() {
  if [[ "${CODEX_MEM_NON_TRIVIAL:-}" == "0" ]]; then
    return 1
  fi
  return 0
}

has_memlayer_startup_block() {
  [[ -f "${AGENTS_FILE}" ]] || return 1
  grep -qF "${STARTUP_MARKER_BEGIN}" "${AGENTS_FILE}" && grep -qF "${STARTUP_MARKER_END}" "${AGENTS_FILE}"
}

ensure_bootstrap() {
  local missing_items=()

  if [[ ! -d "${SKILL_DIR}" ]]; then
    missing_items+=("~/.codex/skills/memory-usage")
  fi

  if ! has_memlayer_startup_block; then
    missing_items+=("repo AGENTS.md MemLayer startup block")
  fi

  if ! codex mcp get "${MCP_SERVER}" >/dev/null 2>&1; then
    missing_items+=("codex mcp server '${MCP_SERVER}'")
  fi

  if (( ${#missing_items[@]} == 0 )); then
    return 0
  fi

  echo "[codex-mem] Missing required setup: ${missing_items[*]}" >&2
  echo "[codex-mem] Running MemLayer setup..." >&2

  (
    cd "${REPO_ROOT}"
    bash "${REPO_ROOT}/codex/setup.sh"
  )

  if ! codex mcp get "${MCP_SERVER}" >/dev/null 2>&1; then
    codex mcp add "${MCP_SERVER}" --url "${MCP_URL}"
  fi

  if ! codex mcp get "${MCP_SERVER}" >/dev/null 2>&1; then
    echo "Error: unable to configure Codex MCP server '${MCP_SERVER}'." >&2
    exit 1
  fi
}

print_preflight() {
  cat >&2 <<'CHECKLIST'
[codex-mem] Mandatory preflight:
- Call `prociq_retrieve_context` before first substantive task action.
- Call `prociq_list_scopes` once per session after first retrieval.
- Resolve and reuse a default scope before any logging operations.
CHECKLIST
}

collect_new_session_logs() {
  local marker_file="$1"
  find "${CODEX_HOME_DIR}/sessions" -type f -name '*.jsonl' -newer "${marker_file}" 2>/dev/null || true
}

has_log_episode_call() {
  local session_logs="$1"

  if [[ -z "${session_logs}" ]]; then
    return 1
  fi

  # Match both direct MCP tool names and simplified names if format changes.
  while IFS= read -r file; do
    [[ -f "${file}" ]] || continue
    if rg -q 'prociq_log_episode|mcp__prociq__prociq_log_episode' "${file}"; then
      return 0
    fi
  done <<< "${session_logs}"

  return 1
}

post_run_compliance_check() {
  local task_exit_code="$1"
  local session_logs="$2"

  if [[ "${task_exit_code}" -ne 0 ]]; then
    echo "[codex-mem] Reminder: command failed. Log failure with prociq_log_episode before retrying." >&2
  fi

  if ! is_non_trivial_task; then
    return 0
  fi

  if has_log_episode_call "${session_logs}"; then
    return 0
  fi

  echo "[codex-mem] Compliance warning: non-trivial task appears to have no prociq_log_episode call." >&2

  if [[ "${CODEX_MEM_STRICT:-0}" == "1" || ! -t 1 ]]; then
    echo "[codex-mem] Failing due to missing episode log (set CODEX_MEM_NON_TRIVIAL=0 to bypass for trivial runs)." >&2
    return 42
  fi

  return 0
}

main() {
  need_cmd codex
  need_cmd rg

  mkdir -p "${CODEX_HOME_DIR}"

  ensure_bootstrap
  print_preflight

  local marker_file
  marker_file="$(mktemp)"
  trap 'rm -f "${marker_file}"' EXIT
  touch "${marker_file}"

  set +e
  codex "$@"
  local codex_exit_code=$?
  set -e

  local session_logs
  session_logs="$(collect_new_session_logs "${marker_file}")"

  set +e
  post_run_compliance_check "${codex_exit_code}" "${session_logs}"
  local compliance_exit_code=$?
  set -e

  if [[ "${codex_exit_code}" -ne 0 ]]; then
    exit "${codex_exit_code}"
  fi

  if [[ "${compliance_exit_code}" -ne 0 ]]; then
    exit "${compliance_exit_code}"
  fi
}

main "$@"
