# memory-usage

Self-learning memory system. Orchestrates the **Retrieve → Act → Log** cycle to ensure persistent learning across sessions.

## Procedure

### 1. Mandatory Context Retrieval
Before starting any significant task (coding, debugging, architecture design), you **MUST** check for relevant past experiences.
*   **Action**: Call `prociq_retrieve_context` with a clear description of the current goal.
*   **Goal**: Identify past successes to replicate or failures to avoid.
*   **Instruction**: If the retrieved context contains "Active Skills", you must follow those specific instructions for the duration of the task.

### 2. Task Implementation (Action)
Perform the task as requested, informed by the retrieved context.
*   If you encounter a new error during implementation, call `prociq_retrieve_context` again with the `error_state` field populated to find specific solutions.

### 3. Experience Logging (Finalize)
After the task is complete (even if only partially successful or failed), you **MUST** record the experience.
*   **Action**: Call `prociq_log_episode`.
*   **Fields**:
    *   `task_goal`: Concise statement of what you tried to do.
    *   `approach_taken`: Summary of the steps or logic used.
    *   `outcome`: One of `success`, `partial`, or `failure`.
    *   `error_message`: Include the full error if the outcome was not `success`.
    *   `importance_hint`: Rate from `0.1` (routine) to `1.0` (critical breakthrough/failure).

## Guidelines
*   **Failure is Signal**: Always log failures. They are the most valuable entries for future error prevention.
*   **Stand-alone Content**: When logging, ensure the `approach_taken` is descriptive enough to be understood in a future session without the original conversation context.
