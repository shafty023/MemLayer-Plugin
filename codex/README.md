# ProcIQ Memory Layer - Codex Plugin

A self-learning memory layer for Codex. This plugin installs a Codex skill that retrieves relevant past experiences before work starts and logs learnings after execution.

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

### 2. Install Plugin Skills (Optional)
To install the `memory-usage` skill for specialized context retrieval and logging logic, run the setup script from your project root:

```bash
/path/to/MemLayer-Plugin/codex/setup.sh
```

This installs the `memory-usage` skill into `.codex/skills` in the current project directory.

### 3. Install AGENTS.md in a Target Project

`AGENTS.md` is project-local, so install it into each repository where you want memory behavior enforced:

```bash
/path/to/MemLayer-Plugin/codex/install-agents.sh /path/to/target-project
```

If the target already has an `AGENTS.md`, rerun with `--force` as the second argument to overwrite.

## Usage

Once installed via `codex mcp add`, Codex will automatically handle authentication. You can then use the `memory-usage` skill to run this cycle:

1. Retrieve context with `prociq_retrieve_context`
2. Implement the requested task
3. Log the outcome with `prociq_log_episode`

You can also explicitly request memory operations in natural language, for example:

- "Use memory-usage and audit what we know so far."
- "Teach this lesson to memory: ... "
- "Forget episodes related to ... "

## Plugin Development

- Skill definition: `codex/skills/memory-usage/SKILL.md`
- Installer: `codex/setup.sh`
- AGENTS template: `codex/templates/AGENTS.md`
- AGENTS installer: `codex/install-agents.sh`
