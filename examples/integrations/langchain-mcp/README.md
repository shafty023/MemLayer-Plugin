# LangChain + MemLayer via MCP

Use MemLayer tools inside a LangChain agent through the MCP adapter.

## Prerequisites

```bash
pip install langchain-anthropic langchain-mcp-adapters langgraph
```

## What This Example Does

1. Connects to the MemLayer MCP endpoint
2. Loads MemLayer tools as LangChain tools
3. Creates a ReAct agent that uses MemLayer for persistent memory
4. The agent retrieves context, works, and logs the outcome — all within LangChain's agent loop

## Run

```bash
export ANTHROPIC_API_KEY="your-api-key"
python memlayer_langchain.py
```

## Key Concept

The `langchain-mcp-adapters` package converts MCP tools into LangChain-compatible tools automatically. MemLayer tools work like any other tool in the agent's toolkit — the agent decides when to retrieve context and when to log based on its system prompt.
