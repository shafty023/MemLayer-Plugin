# MemLayer Codex Instructions

## Memory Policy

- Use the `memory-usage` skill for every non-trivial task.
- At the start of every Codex session, call `prociq_retrieve_context` before the first substantive task.
- For coding, debugging, refactoring, test-fix, and architecture work, `prociq_retrieve_context` must be the first non-trivial action.
- Resolve the default scope after the first retrieval and before any scoped memory write. Ask the user only when multiple scopes are authorized and no default is already clear from context.
- When a command, build, or test fails, stop, log the failure, retrieve context for the error, then retry.
- At task end, log the outcome for the task.
- Skip the memory workflow only for purely conversational requests with no execution.
- If the `memory-usage` skill or ProcIQ tools are unavailable, state that limitation and continue with best-effort execution.

## Source Of Truth

The detailed Retrieve -> Act -> Log workflow lives in the globally installed `memory-usage` skill.
