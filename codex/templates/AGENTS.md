# MemLayer Codex Instructions

## Memory Policy

- Use the `memory-usage` skill for every non-trivial task.
- For coding, debugging, refactoring, test-fix, and architecture work, `prociq_retrieve_context` must be the first non-trivial action.
- When a command, build, or test fails, stop, log the failure, retrieve context for the error, then retry.
- At task end, log reusable outcomes.
- Skip the memory workflow only for purely conversational requests with no execution.
- If the `memory-usage` skill or ProcIQ tools are unavailable, state that limitation and continue with best-effort execution.

## Source Of Truth

The detailed Retrieve -> Act -> Log workflow lives in the repo-installed `memory-usage` skill under `.agents/skills`.
