/**
 * Claude Agent SDK + MemLayer integration.
 *
 * Creates an agent that uses MemLayer for persistent learning across sessions.
 * The agent retrieves context before working and logs outcomes after.
 */

import Anthropic from "@anthropic-ai/sdk";

const client = new Anthropic();

async function main() {
  const response = await client.messages.create({
    model: "claude-sonnet-4-6",
    max_tokens: 4096,
    system: `You are an agent with persistent memory via MemLayer.

Before starting any task:
1. Call retrieve_context with a detailed task description
2. Apply any returned patterns or past solutions

After completing a task:
3. Call log_episode with the outcome and approach taken

This ensures you learn from every session and avoid repeating mistakes.`,
    tools: [
      // MemLayer tools are available via MCP — in production,
      // connect via the MCP server config rather than defining inline.
      // This example shows the tool signatures for reference.
      {
        name: "retrieve_context",
        description:
          "Retrieve relevant past experiences, patterns, and skills before starting work.",
        input_schema: {
          type: "object" as const,
          properties: {
            task_description: {
              type: "string",
              description: "Detailed description of the current task.",
            },
            file_patterns: {
              type: "array",
              items: { type: "string" },
              description: "File path patterns relevant to the task.",
            },
            error_state: {
              type: "string",
              description: "Description of any error encountered.",
            },
          },
          required: ["task_description"],
        },
      },
      {
        name: "log_episode",
        description: "Log the outcome of a completed task for future learning.",
        input_schema: {
          type: "object" as const,
          properties: {
            handle: {
              type: "string",
              description: "Unique handle for this episode.",
            },
            scope: { type: "string", description: "Scope for the episode." },
            outcome: {
              type: "string",
              enum: ["success", "failure", "partial"],
            },
            task_goal: {
              type: "string",
              description: "What the task aimed to accomplish.",
            },
            approach_taken: {
              type: "string",
              description: "How the task was approached.",
            },
          },
          required: ["handle", "scope", "outcome", "task_goal"],
        },
      },
    ],
    messages: [
      {
        role: "user",
        content:
          "Fix the rate limiter — it's allowing 200 req/s instead of the configured 100.",
      },
    ],
  });

  console.log("Agent response:");
  for (const block of response.content) {
    if (block.type === "text") {
      console.log(block.text);
    } else if (block.type === "tool_use") {
      console.log(`\nTool call: ${block.name}`);
      console.log(JSON.stringify(block.input, null, 2));
    }
  }
}

main();
