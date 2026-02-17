# ProcIQ Memory Layer - Codex Plugin

A self-learning memory layer for Codex. This plugin installs a Codex skill that retrieves relevant past experiences before work starts and logs learnings after execution.

## Prerequisites

1. Codex CLI installed and authenticated.
2. ProcIQ MCP server configured in Codex.
3. ProcIQ backend credentials available in your environment.

## Installation

Run the setup script from your project root:

```bash
/path/to/MemLayer-Plugin/codex/setup.sh
```

This installs the `memory-usage` skill into `.codex/skills` in the current project directory.

### Install AGENTS.md in a Target Project

`AGENTS.md` is project-local, so install it into each repository where you want memory behavior enforced:

```bash
/path/to/MemLayer-Plugin/codex/install-agents.sh /path/to/target-project
```

If the target already has an `AGENTS.md`, rerun with `--force` as the second argument to overwrite.

## Configure ProcIQ MCP

Add a ProcIQ MCP server entry to `.codex/config.toml` in your project:

```toml
[mcp_servers.prociq]
url = "http://localhost:8085/mcp"
bearer_token_env_var = "PROCIQ_TOKEN"
```

Set `PROCIQ_TOKEN` in your shell environment before launching Codex.

## Usage

Once installed, Codex can use the `memory-usage` skill to run this cycle:

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
