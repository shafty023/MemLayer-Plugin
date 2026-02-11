# MemLayer Codex Instructions

## Default Behavior

- For every non-trivial user task, use the `memory-usage` skill before implementation and follow its Retrieve -> Act -> Log workflow.
- For all coding, debugging, refactoring, test-fix, and architecture tasks, your FIRST action must be `prociq_retrieve_context` before any other tool call or code change.
- Only skip this first-step requirement when the task is purely conversational and no execution is requested.

## Required Memory Sequence

1. At task start, call `prociq_retrieve_context` with a concise task description.
2. During debugging, call `prociq_retrieve_context` again with the current `error_state`.
3. At task end, call `prociq_log_episode` with outcome and approach details.

## Failure Rule

- If any command, build, or test fails, log a failure episode with `prociq_log_episode` before retrying.

## Logging Policy

- Log success only for reusable, non-obvious work.
- Skip logging for trivial/mechanical changes.

## Missing Dependency Fallback

- If `memory-usage` skill or ProcIQ MCP tools are unavailable, explicitly state that limitation and continue with best-effort execution.
