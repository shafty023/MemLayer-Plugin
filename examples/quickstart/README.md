# MemLayer Quickstart

A minimal example demonstrating the MemLayer learning loop: capture, retrieve, and learn.

## Prerequisites

- An MCP-compatible AI coding tool (Claude Code, Cursor, Windsurf, Codex, or Gemini CLI)
- MemLayer connected via MCP (see [config templates](../configs/))

## The Learning Loop in 6 Lines

```
# 1. Retrieve context before starting work
retrieve_context(task_description: "Deploy the Node.js API to production")

# 2. Do your work (agent executes the task)

# 3. Log the outcome
log_episode(
  handle: "deploy-nodejs-api-prod",
  outcome: "success",
  scope: "default",
  task_goal: "Deploy the Node.js API to production",
  approach_taken: "Used GitHub Actions workflow with Docker build and ECS deploy"
)
```

That's it. Retrieve before, log after. MemLayer handles the rest.

## What Happens Next

After logging episodes:

1. **Consolidation** runs automatically (every 15 minutes) and analyzes your episodes
2. **Patterns** emerge from repeated successes and failures
3. **Skills** are generated from mature, validated patterns
4. **Future retrieval** returns increasingly relevant context

## Store Permanent Knowledge

For facts that should persist regardless of task execution:

```
log_note(
  scope: "default",
  slug: "api-port-convention",
  content: "All services run on port 8080 in development, 443 in production",
  tags: ["conventions", "infrastructure"]
)
```

## Full Workflow Example

```
# Start of session — retrieve everything relevant
retrieve_context(
  task_description: "Fix the flaky integration test in user-service",
  file_patterns: ["tests/**/*.test.ts"],
  error_state: "TimeoutError: test exceeded 30s timeout"
)

# MemLayer returns:
# - Past episodes where similar timeout issues were resolved
# - A pattern: "Flaky timeouts in integration tests are usually caused by missing test isolation"
# - A skill: "Always check for shared database state between test cases"

# Agent applies the pattern, fixes the test

# Log the outcome
log_episode(
  handle: "fix-flaky-user-service-test",
  outcome: "success",
  scope: "default",
  task_goal: "Fix flaky integration test timeout in user-service",
  approach_taken: "Added database cleanup in beforeEach hook — tests were sharing state"
)

# Optionally, store a reflection for pattern promotion
store_reflection(
  scope: "default",
  episode_id: "fix-flaky-user-service-test",
  root_cause: "Integration tests sharing database state between runs",
  strategy: "Always add beforeEach cleanup when tests touch the database",
  confidence: 0.9,
  generalizability: "high"
)
```

## Next Steps

- [Full documentation](https://prociq.ai/docs/introduction)
- [API / MCP Reference](https://prociq.ai/docs/apireference)
- [Architecture Overview](https://prociq.ai/docs/architecture)
- [Common Workflows](https://prociq.ai/docs/workflows)
