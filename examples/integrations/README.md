# Integration Examples

Working code samples showing how to connect MemLayer to popular agent frameworks via MCP.

MemLayer exposes a single MCP endpoint (`https://prociq.ai/mcp`), so any framework that speaks MCP can integrate directly.

## Examples

| Framework | Language | Directory |
|-----------|----------|-----------|
| MCP Python SDK | Python | [python-mcp/](python-mcp/) |
| Claude Agent SDK | TypeScript | [agent-sdk/](agent-sdk/) |
| LangChain MCP Adapter | Python | [langchain-mcp/](langchain-mcp/) |

## How It Works

All integrations follow the same pattern:

1. **Connect** — Point your MCP client at `https://prociq.ai/mcp`
2. **Authenticate** — OAuth handles auth automatically (browser flow on first connect)
3. **Use tools** — Call `retrieve_context` before work, `log_episode` after

MemLayer tools are available as standard MCP tools in any connected framework. No SDK wrappers, no custom clients.
