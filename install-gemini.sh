#!/usr/bin/env bash

set -euo pipefail

REPO_SLUG="${MEMLAYER_REPO_SLUG:-shafty023/MemLayer-Plugin}"
REPO_REF="${MEMLAYER_REPO_REF:-memlayer}"
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
need_cmd node

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
plugin_dir="${tmp_dir}/MemLayer-Plugin"

echo "Cloning ${repo_url}..."
git clone --depth 1 "${repo_url}" "${plugin_dir}"
(
  cd "${plugin_dir}"
  git checkout "${REPO_REF}"
)

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
SETTINGS_FILE="${settings_file}" SERVER_NAME="${SERVER_NAME}" MCP_URL="${MCP_URL}" node <<'NODE'
const fs = require("fs");

const settingsFile = process.env.SETTINGS_FILE;
const serverName = process.env.SERVER_NAME;
const mcpUrl = process.env.MCP_URL;

let data = {};
try {
  data = JSON.parse(fs.readFileSync(settingsFile, "utf8"));
} catch {
  data = {};
}

if (typeof data !== "object" || data === null || Array.isArray(data)) {
  data = {};
}
if (typeof data.mcpServers !== "object" || data.mcpServers === null || Array.isArray(data.mcpServers)) {
  data.mcpServers = {};
}

data.mcpServers[serverName] = {
  type: "http",
  httpUrl: mcpUrl,
  oauth: { enabled: true }
};

fs.writeFileSync(settingsFile, JSON.stringify(data, null, 2) + "\n");
NODE

echo "Done. Start Gemini and run: /mcp auth ${SERVER_NAME}"
