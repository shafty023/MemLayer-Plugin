# ProcIQ Memory Layer - Codex Plugin

A self-learning memory layer for Codex. This plugin installs a reusable skill for the detailed ProcIQ workflow and a lightweight `AGENTS.md` policy that tells Codex when to use it.

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

### 2. Install Global Skill And Project Policy
To install the `memory-usage` skill into your Codex home directory and apply the MemLayer repo policy from your project root, run:

```bash
/path/to/MemLayer-Plugin/codex/setup.sh
```

This installs the `memory-usage` skill into `${CODEX_HOME:-~/.codex}/skills` from the canonical source at `plugins/memory/skills/memory-usage` and then:

- creates a minimal `AGENTS.md` if the project does not already have one
- updates the MemLayer startup block inside an existing `AGENTS.md` if one is already present

The detailed ProcIQ behavior stays in the globally installed `memory-usage` skill so the repo policy can stay short and avoid duplicated instructions.

### 3. Install AGENTS.md In A Target Project

`AGENTS.md` is project-local, so install it into each repository where you want memory behavior enforced:

```bash
/path/to/MemLayer-Plugin/codex/install-agents.sh /path/to/target-project
```

If the target already has an `AGENTS.md`, rerun with `--force` as the second argument to overwrite.

### 4. Use The Guarded Launcher (`codex-mem`)

To enforce MemLayer checks before every Codex run in this repository, use:

```bash
/path/to/MemLayer-Plugin/codex/codex-mem.sh [codex args...]
```

What this launcher does:

- verifies `${CODEX_HOME:-~/.codex}/skills/memory-usage` exists
- verifies this repo's `AGENTS.md` contains the MemLayer startup block
- verifies `codex mcp get memlayer` is configured
- auto-runs local setup (`codex/setup.sh`) and `codex mcp add memlayer` when needed
- prints a mandatory preflight checklist (retrieve context, list scopes, resolve default scope)
- checks recent Codex session logs for `prociq_log_episode` usage after the run

Compliance behavior:

- non-trivial runs without `prociq_log_episode` produce a warning
- in strict/non-interactive mode, missing episode logs fail with exit code `42`
- non-zero Codex exits print a failure-logging reminder

Useful toggles:

- `CODEX_MEM_NON_TRIVIAL=0` to skip post-run logging enforcement for trivial runs
- `CODEX_MEM_STRICT=1` to fail on missing post-run episode logs even in interactive runs

## Usage

Once installed via `codex mcp add`, Codex can use MemLayer through MCP. The intended layering is:

1. `${CODEX_HOME:-~/.codex}/skills/memory-usage` provides the reusable global skill.
2. `AGENTS.md` enforces when memory should be used in this repository.
3. The ProcIQ MCP server provides the actual memory tools.

By default, this installer does not modify `${CODEX_HOME:-~/.codex}/AGENTS.md`, because global AGENTS instructions affect every repository you open in Codex.

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
- Installer: `codex/setup.sh`
- AGENTS template: `codex/templates/AGENTS.md`
- AGENTS installer: `codex/install-agents.sh`
- Guard wrapper: `codex/codex-mem.sh`
