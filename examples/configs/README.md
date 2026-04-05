# MCP Config Templates

Ready-to-use MCP configuration files for connecting MemLayer to your AI coding tool.

## Usage

Copy the config for your client into the appropriate location:

| Client | Config File | Location |
|--------|------------|----------|
| Claude Code | `claude-code.json` | `~/.claude/settings.json` (merge into `mcpServers`) |
| Cursor | `cursor.json` | Settings > MCP > Add Server |
| Windsurf | `windsurf.json` | Settings > MCP Configuration |
| Cline | `cline.json` | Cline settings > MCP Servers |
| VS Code Agent Mode | `vscode-agent-mode.json` | `.vscode/mcp.json` in your workspace |
| Codex CLI | Use installer | `codex mcp add memlayer --url https://prociq.ai/mcp` |
| Gemini CLI | Use installer | `gemini mcp add --transport http memlayer https://prociq.ai/mcp` |

## Authentication

All configs use OAuth. On first connection, your client will open a browser window for sign-in. No API keys to manage.

## After Setup

1. Restart your client after adding the config
2. Run `/audit` to verify the connection
3. Start using MemLayer naturally or with slash commands

See the [full documentation](https://prociq.ai/docs/clientsetup) for detailed setup instructions per client.
