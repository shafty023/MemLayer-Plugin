"""
MemLayer integration via Python MCP SDK.

Demonstrates the retrieve → work → log pattern using the MCP protocol directly.
"""

import asyncio
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client


MEMLAYER_URL = "https://prociq.ai/mcp"


async def main():
    async with streamablehttp_client(MEMLAYER_URL) as (read, write, _):
        async with ClientSession(read, write) as session:
            await session.initialize()

            # List available tools
            tools = await session.list_tools()
            print(f"Connected. {len(tools.tools)} tools available:")
            for tool in tools.tools:
                print(f"  - {tool.name}")

            # Step 1: Retrieve context before starting work
            print("\n--- Retrieving context ---")
            result = await session.call_tool(
                "prociq_retrieve_context",
                arguments={
                    "task_description": "Optimize database queries in the user service",
                    "file_patterns": ["src/services/user/**/*.ts"],
                },
            )
            print(result.content[0].text[:500])

            # Step 2: Do the work (your agent logic here)
            print("\n--- Doing work ---")
            print("(Agent applies retrieved patterns and completes the task)")

            # Step 3: Log the episode
            print("\n--- Logging episode ---")
            result = await session.call_tool(
                "prociq_log_episode",
                arguments={
                    "handle": "optimize-user-service-queries",
                    "scope": "default",
                    "outcome": "success",
                    "task_goal": "Optimize database queries in the user service",
                    "approach_taken": "Added composite index on (user_id, created_at), "
                    "replaced N+1 queries with batch lookups",
                    "tools_used": ["postgres", "prisma"],
                },
            )
            print(result.content[0].text[:300])


if __name__ == "__main__":
    asyncio.run(main())
