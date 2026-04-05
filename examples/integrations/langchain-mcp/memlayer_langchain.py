"""
LangChain + MemLayer integration via the MCP adapter.

Uses langchain-mcp-adapters to load MemLayer tools into a LangChain ReAct agent.
"""

from langchain_anthropic import ChatAnthropic
from langchain_mcp_adapters.client import MultiServerMCPClient
from langgraph.prebuilt import create_react_agent

MEMLAYER_URL = "https://prociq.ai/mcp"

SYSTEM_PROMPT = """You are an agent with persistent memory powered by MemLayer.

Before starting any task:
- Call prociq_retrieve_context with a detailed task description
- Check for relevant patterns, past episodes, and skills
- Apply any solutions found before attempting your own

After completing a task:
- Call prociq_log_episode with the outcome and approach
- Include enough detail for future retrieval

This learning loop ensures you improve across sessions."""


async def main():
    async with MultiServerMCPClient(
        {
            "memlayer": {
                "url": MEMLAYER_URL,
                "transport": "streamable_http",
            }
        }
    ) as client:
        tools = client.get_tools()
        print(f"Loaded {len(tools)} MemLayer tools")

        model = ChatAnthropic(model="claude-sonnet-4-6")
        agent = create_react_agent(model, tools)

        result = await agent.ainvoke(
            {
                "messages": [
                    {
                        "role": "user",
                        "content": (
                            "The CI pipeline is failing on the lint step. "
                            "Check if we've seen this before, fix it, "
                            "and log what you did."
                        ),
                    }
                ],
            },
            config={"configurable": {"system_message": SYSTEM_PROMPT}},
        )

        for msg in result["messages"]:
            print(f"\n[{msg.type}]")
            print(msg.content if isinstance(msg.content, str) else msg.content)


if __name__ == "__main__":
    import asyncio

    asyncio.run(main())
