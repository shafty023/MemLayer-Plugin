# ProcIQ Memory Layer - Gemini Plugin

A self-learning memory layer for the Gemini CLI. This plugin enables Gemini to automatically retrieve relevant past experiences before starting tasks and log new learnings upon completion, ensuring consistent improvement over time.

## Prerequisites

1.  **Gemini CLI** installed and configured.
2.  **ProcIQ Core** dependencies installed in a Python virtual environment (Python 3.11+).
3.  **MCP Server** access (Local or Supabase-backed).

## Installation

### 1. Install Plugin Skills
Run the provided setup script from your project's root directory to install the plugin's skills into your workspace:

```bash
/path/to/MemLayer-Plugin/gemini/setup.sh
```

This will install the `memory-usage` skill to your local workspace scope (`.gemini/skills/memory-usage`). Installing to the workspace is the recommended way to bypass Gemini CLI sandboxing restrictions that might prevent access to global skills.

### 2. Configure MCP Server
The plugin requires the `prociq` MCP server to be configured. Add the following to your project-local `.gemini/settings.json` (creating it if it doesn't exist):

```json
{
  "mcpServers": {
    "prociq": {
      "command": "/path/to/your/prociq/.venv/bin/python",
      "args": [
        "-m",
        "mcp_server.server"
      ],
      "env": {
        "PROCIQ_ORG_ID": "your-org-id",
        "MCP_TRANSPORT": "stdio"
      }
    }
  }
}
```

**Note:** Replace `/path/to/your/prociq/.venv/bin/python` with the actual absolute path to the Python executable in your ProcIQ virtual environment.

### 3. Environment Variables
The following environment variables are supported in the `env` block of your configuration:

*   `PROCIQ_ORG_ID`: (Required) An identifier to isolate your memory data.
*   `MCP_TRANSPORT`: Set to `stdio` for local child-process execution.
*   `STORAGE_BACKEND`: Set to `chromadb` (local) or `supabase` (cloud).
*   `SUPABASE_URL` / `SUPABASE_SERVICE_KEY`: Required if using the Supabase backend.

## Usage

Once installed and the MCP server is configured, the `memory-usage` skill is automatically available. Gemini will follow this cycle:

1.  **Retrieve**: Call `prociq_retrieve_context` at the start of tasks to find similar past episodes or proven patterns.
2.  **Act**: Implement your request using the retrieved context.
3.  **Log**: Call `prociq_log_episode` at the end of the session to save what worked (or what failed).

### Manual Tools
You can also manually interact with the memory using the ProcIQ tools:
*   `prociq_get_memory_stats`: Check how many episodes and patterns are stored.
*   `prociq_log_note`: Save a static fact or configuration detail permanently.
*   `prociq_search_episodes`: Search through your history with custom filters.

## Plugin Development
*   **Skills**: Defined in `skills/`. The logic for the memory lifecycle is in `skills/memory-usage/SKILL.md`.
*   **System Prompts**: Top-level instructions are in `prompts/system.md`.
*   **Manifest**: Metadata and skill declarations are in `manifest.json`.
