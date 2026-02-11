#!/usr/bin/env bash
# Install MemLayer AGENTS.md into a target project

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="${PLUGIN_DIR}/templates/AGENTS.md"
TARGET_DIR="${1:-$(pwd)}"
TARGET_FILE="${TARGET_DIR}/AGENTS.md"
FORCE="${2:-}"

if [ ! -d "${TARGET_DIR}" ]; then
    echo "Error: target directory does not exist: ${TARGET_DIR}" >&2
    exit 1
fi

if [ -f "${TARGET_FILE}" ] && [ "${FORCE}" != "--force" ]; then
    echo "Error: ${TARGET_FILE} already exists." >&2
    echo "Use --force as second argument to overwrite." >&2
    exit 1
fi

cp "${TEMPLATE}" "${TARGET_FILE}"
echo "Installed ${TARGET_FILE}"
