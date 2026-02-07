#!/usr/bin/env bash
# Setup script for ProcIQ Gemini Plugin

set -e

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEMINI_SKILLS_DIR="${HOME}/.gemini/skills"

echo "Installing ProcIQ Gemini Plugin..."

# Create the skills directory if it doesn't exist
mkdir -p "${GEMINI_SKILLS_DIR}"

# Symlink the memory-usage skill
if [ -L "${GEMINI_SKILLS_DIR}/memory-usage" ]; then
    rm "${GEMINI_SKILLS_DIR}/memory-usage"
fi

ln -s "${PLUGIN_DIR}/skills/memory-usage" "${GEMINI_SKILLS_DIR}/memory-usage"

echo "✓ Plugin skills symlinked to ${GEMINI_SKILLS_DIR}"
echo ""
echo "Next steps:"
echo "1. Ensure the ProcIQ MCP server is configured in your .gemini/settings.json"
echo "2. Restart your Gemini CLI session."
