#!/usr/bin/env bash

set -euo pipefail

REPO_SLUG="${MEMLAYER_REPO_SLUG:-shafty023/MemLayer-Plugin}"
REPO_REF="${MEMLAYER_REPO_REF:-main}"
MCP_URL="${MEMLAYER_MCP_URL:-https://prociq.ai/mcp}"
TARGET_DIR="${1:-${MEMLAYER_TARGET_DIR:-$PWD}}"
SERVER_NAME="${MEMLAYER_SERVER_NAME:-memlayer}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command '$1' is not installed." >&2
    exit 1
  fi
}

need_cmd git

if [ ! -d "${TARGET_DIR}" ]; then
  echo "Error: target directory does not exist: ${TARGET_DIR}" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

repo_url="https://github.com/${REPO_SLUG}.git"
plugin_dir="${tmp_dir}/plugin"

echo "Cloning ${repo_url}..."
git clone --depth 1 --branch "${REPO_REF}" "${repo_url}" "${plugin_dir}"

if [ ! -d "${plugin_dir}/gemini" ]; then
  echo "Error: checked out ref '${REPO_REF}' does not contain gemini plugin files." >&2
  exit 1
fi

echo "Installing Gemini skill files into ${TARGET_DIR}..."
(
  cd "${TARGET_DIR}"
  bash "${plugin_dir}/gemini/setup.sh"
)

settings_file="${TARGET_DIR}/.gemini/settings.json"
mkdir -p "$(dirname "${settings_file}")"
if [ ! -f "${settings_file}" ]; then
  echo '{}' > "${settings_file}"
fi

echo "Configuring Gemini MCP server '${SERVER_NAME}' in ${settings_file}..."
if command -v python3 >/dev/null 2>&1; then
  SETTINGS_FILE="${settings_file}" SERVER_NAME="${SERVER_NAME}" MCP_URL="${MCP_URL}" python3 <<'PY'
import json
import os
from pathlib import Path

settings_file = Path(os.environ["SETTINGS_FILE"])
server_name = os.environ["SERVER_NAME"]
mcp_url = os.environ["MCP_URL"]

data = {}
try:
    data = json.loads(settings_file.read_text(encoding="utf-8"))
except Exception:
    data = {}

if not isinstance(data, dict):
    data = {}

mcp_servers = data.get("mcpServers")
if not isinstance(mcp_servers, dict):
    mcp_servers = {}

mcp_servers[server_name] = {
    "type": "http",
    "httpUrl": mcp_url,
    "oauth": {"enabled": True},
}
data["mcpServers"] = mcp_servers

settings_file.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
elif command -v jq >/dev/null 2>&1; then
  if ! jq empty "${settings_file}" >/dev/null 2>&1; then
    echo '{}' > "${settings_file}"
  fi
  tmp_settings="$(mktemp)"
  jq --arg server_name "${SERVER_NAME}" --arg mcp_url "${MCP_URL}" '
    (if type == "object" then . else {} end)
    | .mcpServers = (if (.mcpServers | type) == "object" then .mcpServers else {} end)
    | .mcpServers[$server_name] = {
        type: "http",
        httpUrl: $mcp_url,
        oauth: { enabled: true }
      }
  ' "${settings_file}" > "${tmp_settings}"
  mv "${tmp_settings}" "${settings_file}"
else
  echo "Error: required command 'python3' or 'jq' is not installed." >&2
  exit 1
fi

echo "Done. Start Gemini and run: /mcp auth ${SERVER_NAME}"
