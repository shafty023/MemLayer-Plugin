---
name: memory-usage
description: ProcIQ memory workflow for Codex. Use when starting non-trivial tasks, debugging errors, auditing memory, teaching lessons, or forgetting episodes.
---

# memory-usage

Use ProcIQ in a Retrieve -> Act -> Log cycle.

## Core Workflow

### 1. Retrieve Context First

Before significant work (coding, debugging, refactoring, architecture), call:

- `prociq_retrieve_context` with a concise task description
- include `error_state` when debugging an active failure

If the response includes active skills or constraints, follow them during execution.

### 2. Execute the Task

Implement the user request using retrieved context.

If a new error appears during implementation, call `prociq_retrieve_context` again using the latest error message.

### 3. Log the Outcome

At the end of significant work, call `prociq_log_episode` with:

- `task_goal`
- `approach_taken`
- `outcome`: `success`, `partial`, or `failure`
- `error_message`: required for non-success outcomes
- `tools_used`, `file_patterns`, and `component_types` when known
- `importance_hint`: `0.2` routine to `1.0` critical

## Failure-First Rule

On any command/test/build/runtime error:

1. Stop and capture the exact failure context
2. Log failure with `prociq_log_episode` (`outcome="failure"`)
3. Retry only after the failure is logged

This prevents loss of high-value debugging context.

## Success Logging Policy

Log success episodes when the work is reusable:

- solved a recurring problem class
- required non-obvious investigation or tradeoffs
- established a pattern likely to repeat
- first time performing this workflow in the codebase

Skip success logging for low-signal work:

- trivial typos or missing imports
- routine CRUD/template updates
- one-off mechanical operations with no reusable insight

## Intent Helpers

When the user asks to audit memory, run:

1. `prociq_get_memory_stats`
2. `prociq_search_episodes` for recent activity
3. `prociq_search_patterns` with confidence filtering
4. `prociq_list_skills`

When the user asks to teach a lesson, create a high-importance episode (`importance_hint >= 0.8`) summarizing the lesson and why it matters.

When the user asks to forget episodes, always confirm targets before calling `prociq_forget_episodes`.
