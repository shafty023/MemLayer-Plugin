---
name: memory-usage
description: Self-learning memory system. Orchestrates the Retrieve -> Act -> Log cycle to ensure persistent learning across sessions. Use this skill at the beginning of tasks to retrieve context and at the end to log outcomes. Triggers on starting non-trivial tasks, debugging errors, auditing memory, or storing static knowledge.
---

# memory-usage

Self-learning memory system. Orchestrates the **Retrieve -> Act -> Log** cycle to ensure persistent learning across sessions.

## Core Workflow

### 1. Mandatory Context Retrieval
Before starting any significant task (coding, debugging, architecture design), you **MUST** check for relevant past experiences.
*   **Action**: Call `prociq_retrieve_context` with a clear description of the current goal.
*   **Optional Hints**: Provide `error_state`, `tools`, `file_patterns`, or `limit` to focus the search.
*   **Goal**: Identify past successes to replicate or failures to avoid.
*   **Instruction**: If the retrieved context contains "Skills" or "Patterns", follow those specific instructions for the duration of the task.
*   **Ordering Rule**: If AGENTS/session policy requires `prociq_retrieve_context` as the first non-trivial action, do not call `prociq_list_scopes` before this first retrieval.

### 1.5 Scope Resolution (Immediately After First Retrieval)
After the first `prociq_retrieve_context` call in a task/session:
*   **Action**: Call `prociq_list_scopes` to discover authorized scopes.
*   **Context-First Rule**: Before asking the user, check whether current context already specifies a preferred scope (for example: user instruction in this thread, AGENTS/session policy, or a previously confirmed scope for this session).
*   If exactly one authorized scope is available, use it as the default scope for this task/session.
*   If multiple scopes are available and context provides a single unambiguous scope, use it as the default scope for this task/session.
*   If multiple scopes are available and context is missing or ambiguous, ask the user to choose the default scope **once**.
*   **Session Stickiness Rule**: After scope is resolved, reuse the same default scope for the rest of the session unless the user explicitly changes it.
*   Before any scoped operations (`prociq_log_episode`, `prociq_log_note`, `prociq_log_episodes_batch`, etc.), ensure default scope is resolved.
*   If a memory call fails with a scope-related error, stop and resolve default scope selection before retrying.

### 2. Task Implementation (Action)
Perform the task as requested, informed by the retrieved context.
*   If you encounter a new error during implementation, call `prociq_retrieve_context` again with `error_state` populated (and an updated `task_description`) to find specific solutions.
*   If you encounter a static fact (e.g., "The API key expires every 24 hours"), call `prociq_log_note` with the resolved default scope to store it permanently.

### 3. Experience Logging (Finalize)
After the task is complete (even if only partially successful or failed), you **MUST** record the experience.
*   **Action**: Call `prociq_log_episode`.
*   **Fields**:
    *   `task_goal`: Concise statement of what you tried to do.
    *   `approach_taken`: Summary of the steps or logic used.
    *   `outcome`: One of `success`, `partial`, or `failure`.
    *   `scope`: The resolved default memory scope used for this task.
*   **Important**: Do not include unsupported fields like `project` or `importance_hint` in `prociq_log_episode`.
*   **Importance Model**: Importance is computed by the ProcIQ system and cannot be directly set via MCP parameters.
*   **Batching**: If you have multiple related actions to log, use `prociq_log_episodes_batch`.

## Guidelines
*   **Failure is Signal**: Always log failures. They are the most valuable entries for future error prevention. **Failure-First Rule**: Stop, capture context, log failure, then retry.
*   **Static Knowledge**: Use `prociq_log_note` for facts and knowledge that are not tied to a specific action outcome.
*   **Audit Memory**: When asked to audit memory, use `prociq_get_memory_stats`, `prociq_search_episodes`, and `prociq_search_patterns` to provide a comprehensive report.
*   **Stand-alone Content**: When logging, ensure `approach_taken` is descriptive enough to be understood in a future session without the original conversation context.
