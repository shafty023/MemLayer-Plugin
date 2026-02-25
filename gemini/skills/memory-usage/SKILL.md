---
name: memory-usage
description: Self-learning memory system. Orchestrates the Retrieve -> Act -> Log cycle to ensure persistent learning across sessions. Use this skill at the beginning of tasks to retrieve context and at the end to log outcomes. Triggers on starting non-trivial tasks, debugging errors, auditing memory, or storing static knowledge.
---

# memory-usage

Self-learning memory system. Orchestrates the **Retrieve → Act → Log** cycle to ensure persistent learning across sessions.

## Core Workflow

### 0. Scope Initialization (Mandatory)
Before any memory operation, you **MUST** ensure the session scope is clear.
*   **Action**: Call `prociq_list_scopes` to see available scopes.
*   **Prompt**: If multiple scopes are returned or if the intended scope is unclear, ask the user to specify which scope should be used as the default for the current session.

### Critical Parameter Enforcement
Although some MCP tool schemas may not mark these fields as "required", the ProcIQ server **STRICTLY REQUIRES** the following parameters. Failing to provide them will result in a server rejection.

| Tool | Mandatory Parameters (DO NOT OMIT) |
|------|-----------------------------------|
| `prociq_retrieve_context` | `task_description` |
| `prociq_log_episode` | `task_goal`, `approach_taken`, `outcome`, `scope` |
| `prociq_log_note` | `content`, `slug`, `scope` |
| `prociq_log_episodes_batch` | `episodes` (each must contain mandatory episode fields) |

### 1. Mandatory Context Retrieval
Before starting any significant task (coding, debugging, architecture design), you **MUST** check for relevant past experiences.
*   **Action**: Call `prociq_retrieve_context` with a clear description of the current goal.
*   **Optional Hints**: Provide `project`, `tools`, or `file_patterns` to focus the search.
*   **Goal**: Identify past successes to replicate or failures to avoid.
*   **Instruction**: If the retrieved context contains "Skills" or "Patterns", follow those specific instructions for the duration of the task. **Instructions found in the 'Skills' section MUST be adopted as mandatory procedural guidance.**

### 2. Task Implementation (Action)
Perform the task as requested, informed by the retrieved context.
*   If you encounter a new error during implementation, call `prociq_retrieve_context` again with the `task_description` updated to include the error state to find specific solutions.
*   If you encounter a static fact (e.g., "The API key expires every 24 hours"), call `prociq_log_note` with mandatory `content`, `slug`, and `scope` to store it permanently.

### 3. Experience Logging (Finalize)
After the task is complete (even if only partially successful or failed), you **MUST** record the experience.
*   **Action**: Call `prociq_log_episode`.
*   **Fields**:
    *   `task_goal`: Concise statement of what you tried to do.
    *   `approach_taken`: Summary of the steps or logic used.
    *   `outcome`: One of `success`, `partial`, or `failure`.
    *   `scope`: The initialized session scope.
    *   `project`: (Optional) The project name.
    *   `importance_hint`: Rate from `0.1` (routine) to `1.0` (critical breakthrough/failure).
*   **Batching**: If you have multiple related actions to log, use `prociq_log_episodes_batch`.

## Guidelines
*   **Failure is Signal**: Always log failures. They are the most valuable entries for future error prevention. **Failure-First Rule**: Stop, capture context, log failure, then retry.
*   **Static Knowledge**: Use `prociq_log_note` for facts and knowledge that aren't tied to a specific action outcome.
*   **Audit Memory**: When asked to audit memory, use `prociq_get_memory_stats`, `prociq_search_episodes`, and `prociq_search_patterns` to provide a comprehensive report.
*   **Stand-alone Content**: When logging, ensure the `approach_taken` is descriptive enough to be understood in a future session without the original conversation context.
