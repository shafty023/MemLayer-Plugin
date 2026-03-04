#!/usr/bin/env bash

set -euo pipefail

REPO_SLUG="${MEMLAYER_REPO_SLUG:-shafty023/MemLayer-Plugin}"
MCP_URL="${MEMLAYER_MCP_URL:-https://prociq.ai/mcp}"
SERVER_NAME="${MEMLAYER_SERVER_NAME:-memlayer}"
PLUGIN_NAME="${MEMLAYER_PLUGIN_NAME:-memory@ProcIQ}"
MCP_SCOPE="${MEMLAYER_MCP_SCOPE:-local}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command '$1' is not installed." >&2
    exit 1
  fi
}

need_cmd claude

echo "Adding marketplace '${REPO_SLUG}'..."
if ! claude plugin marketplace add "${REPO_SLUG}" >/dev/null 2>&1; then
  echo "Marketplace may already exist. Continuing."
fi

echo "Installing plugin '${PLUGIN_NAME}'..."
if ! claude plugin install "${PLUGIN_NAME}" >/dev/null 2>&1; then
  echo "Plugin may already be installed. Continuing."
fi

echo "Configuring Claude MCP server '${SERVER_NAME}'..."
if claude mcp get "${SERVER_NAME}" >/dev/null 2>&1; then
  echo "MCP server '${SERVER_NAME}' already exists; reusing it."
else
  claude mcp add --transport http --scope "${MCP_SCOPE}" "${SERVER_NAME}" "${MCP_URL}"
fi

echo "Done. If a browser did not open automatically, run /mcp in Claude and authenticate '${SERVER_NAME}'."
