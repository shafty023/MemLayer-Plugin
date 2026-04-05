# Claude Agent SDK + MemLayer

Build an agent with the Claude Agent SDK that uses MemLayer for persistent learning.

## Prerequisites

```bash
npm install @anthropic-ai/claude-agent-sdk
```

## What This Example Does

1. Creates a Claude agent with MemLayer connected as an MCP server
2. The agent retrieves past context before executing a task
3. After completing work, it logs the outcome for future retrieval

## Run

```bash
npx tsx memlayer_agent.ts
```

On first run, OAuth will open a browser window for sign-in.

## Key Concept

The Agent SDK treats MCP tools as first-class tools. When you attach MemLayer as an MCP server, its tools (`retrieve_context`, `log_episode`, `log_note`, etc.) are available to the agent alongside any other tools. The agent decides when to call them based on its instructions.
