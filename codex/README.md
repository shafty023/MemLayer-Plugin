# ProcIQ Memory Layer - Codex Plugin

A self-learning memory layer for Codex. This plugin installs a repo-scoped skill, repo-local hooks, and a lightweight `AGENTS.md` policy so Codex follows the MemLayer workflow consistently.

## Prerequisites

1. Codex CLI installed and authenticated.
2. ProcIQ MCP server configured in Codex.
3. ProcIQ backend credentials available in your environment.

## Installation

### 1. Install via Codex CLI
The recommended way to install MemLayer in Codex is using the built-in MCP command, which handles authentication via OAuth:

```bash
codex mcp add memlayer --url "https://prociq.ai/mcp"
```

### 2. Install Repo Skill, Hooks, And Project Policy
To install the `memory-usage` skill into the current repository and apply the MemLayer repo policy from your project root, run:

```bash
/path/to/MemLayer-Plugin/codex/setup.sh
```

This installs the `memory-usage` skill into `.agents/skills/memory-usage`, installs Codex hooks into `.codex/hooks.json` and `.codex/hooks/`, enables the `codex_hooks` feature in `${CODEX_HOME:-~/.codex}/config.toml`, and then:

- creates a minimal `AGENTS.md` if the project does not already have one
- updates the MemLayer startup block inside an existing `AGENTS.md` if one is already present

The detailed ProcIQ behavior stays in the repo-installed `memory-usage` skill. The repo-local hooks mirror the existing Gemini and Claude integration pattern with `SessionStart` and `UserPromptSubmit`, while `AGENTS.md` keeps the minimal enforcement rules that should remain repo-local.

### 3. Install AGENTS.md In A Target Project

`AGENTS.md` is project-local, so install it into each repository where you want memory behavior enforced:

```bash
/path/to/MemLayer-Plugin/codex/install-agents.sh /path/to/target-project
```

If the target already has an `AGENTS.md`, rerun with `--force` as the second argument to overwrite.

## Usage

Once installed via `codex mcp add`, Codex can use MemLayer through MCP. The intended layering is:

1. `.agents/skills/memory-usage` provides the reusable repo skill.
2. `.codex/hooks.json` plus `.codex/hooks/` reinforces the memory workflow on `SessionStart` and `UserPromptSubmit`.
3. `AGENTS.md` enforces when memory should be used in this repository.
4. The ProcIQ MCP server provides the actual memory tools.

This installer scopes the MemLayer skill to the current repository rather than writing into your personal Codex skill directory.

You can then work naturally, for example:

- "What do we already know about our deploy flow?"
- "Log to memory: use slog with request_id, org_id, and scope on every Go handler log."
- "Forget the note about the legacy webhook retry plan."

Explicit skill or command-style prompts are still fine when you want them, for example:

- "Use memory-usage and audit what we know so far."
- "Teach this lesson to memory: ..."
- "Forget episodes related to ..."

## Plugin Development

- Canonical skill definition: `plugins/memory/skills/memory-usage/SKILL.md`
- Shared hook script source: `plugins/memory/hooks/scripts/`
- Repo install location: `.agents/skills/memory-usage`
- Repo hook config: `.codex/hooks.json`
- Repo hook scripts: `.codex/hooks/`
- Installer: `codex/setup.sh`
- AGENTS template: `codex/templates/AGENTS.md`
- AGENTS installer: `codex/install-agents.sh`
