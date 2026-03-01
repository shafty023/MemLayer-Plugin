# MemLayer Codex Instructions

## Default Behavior

- For every non-trivial user task, use the `memory-usage` skill before implementation and follow its Retrieve -> Act -> Log workflow.
- For all coding, debugging, refactoring, test-fix, and architecture tasks, your FIRST action must be `prociq_retrieve_context` before any other tool call or code change.
- Only skip this first-step requirement when the task is purely conversational and no execution is requested.
- At the start of EVERY new Codex session, perform a memory bootstrap by calling `prociq_retrieve_context` before handling the first substantive user request.

## Startup Bootstrap (Aggressive)

1. Immediately activate `memory-usage` for the session.
2. Call `prociq_retrieve_context` with `task_description` set to a session bootstrap summary (recent work, active risks, and reusable patterns).
3. If ProcIQ tools are unavailable, explicitly state this limitation before proceeding.
4. On the first non-trivial user task, run `prociq_retrieve_context` again with the concrete task description.

## Required Memory Sequence

1. At task start, call `prociq_retrieve_context` with a concise task description.
2. Immediately after the first retrieval, call `prociq_list_scopes` to resolve default scope.
3. If multiple scopes are authorized, ask the user which scope should be the default before scoped operations.
4. During debugging, call `prociq_retrieve_context` again with the current `error_state`.
5. At task end, call `prociq_log_episode` with outcome and approach details.

## Failure Rule

- If any command, build, or test fails, log a failure episode with `prociq_log_episode` before retrying.

## Logging Policy

- Log success only for reusable, non-obvious work.
- Skip logging for trivial/mechanical changes.

## Missing Dependency Fallback

- If `memory-usage` skill or ProcIQ MCP tools are unavailable, explicitly state that limitation and continue with best-effort execution.
