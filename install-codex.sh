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
need_cmd codex

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

if [ ! -d "${plugin_dir}/codex" ]; then
  echo "Error: checked out ref '${REPO_REF}' does not contain codex plugin files." >&2
  exit 1
fi

echo "Installing Codex skill files into ${TARGET_DIR}..."
(
  cd "${TARGET_DIR}"
  bash "${plugin_dir}/codex/setup.sh"
)

echo "Configuring Codex MCP server '${SERVER_NAME}'..."
if codex mcp get "${SERVER_NAME}" >/dev/null 2>&1; then
  echo "MCP server '${SERVER_NAME}' already exists; reusing it."
else
  codex mcp add "${SERVER_NAME}" --url "${MCP_URL}"
fi

echo "Triggering OAuth login..."
codex mcp login "${SERVER_NAME}"

echo "Done. MemLayer is installed for Codex in ${TARGET_DIR}."
