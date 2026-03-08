# >>> MemLayer startup block >>>

## MemLayer Startup Enforcement

- For every non-trivial user task, use the `memory-usage` skill before implementation and follow its Retrieve -> Act -> Log workflow.
- At the start of EVERY Codex session, call `prociq_retrieve_context` for a session bootstrap before the first substantive task.
- For coding, debugging, refactoring, test-fix, and architecture tasks, first call `prociq_retrieve_context` with the concrete task details.
- Immediately after first retrieval, call `prociq_list_scopes` to resolve default scope.
- If more than one scope is authorized, ask the user to choose the default scope before any scoped memory write or logging operation.
- At task end, call `prociq_log_episode` with outcome and approach details.
- On command/test/build failure, log a failure episode before retrying.

# <<< MemLayer startup block <<<
