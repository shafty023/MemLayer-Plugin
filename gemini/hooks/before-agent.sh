#!/bin/bash

# Hook: BeforeAgent
# Purpose: Inject memory workflow instructions into Gemini's context

CONTEXT="<prociq-memory>
## Memory Workflow Mandate

For every non-trivial task (coding, debugging, refactoring, architecture), you must follow the Retrieve -> Act -> Log cycle.

1. **Check Memory FIRST**: Before any implementation, call \`prociq_retrieve_context\` with a clear task description.
2. **Handle Errors**: If a command or test fails, stop and call \`prociq_retrieve_context\` with the error message to find solutions.
3. **Log Outcome**: After finishing the task, call \`prociq_log_episode\` with the results.

## When to Log SUCCESS Episodes

Log with \`prociq_log_episode\` outcome='success' ONLY when:
- Solved a recurring problem type (config, debugging, integration)
- Required investigation to find non-obvious cause
- Approach wasn't obvious (chose between multiple solutions)
- Established a pattern for future work
- First time doing X in this codebase

DO NOT log success when:
- One-time task (migration, rename) - won't recur
- Trivial fix (typo, missing import) - no learning
- Just following explicit instructions - no decision-making
- Routine CRUD operations - template work

## CRITICAL: On ANY Error or Failure

**STOP before retrying.** When a command fails or produces an error:

1. **STOP** - Do not immediately retry
2. **LOG THE FAILURE** - Call \`prociq_log_episode\` with outcome='failure', error_message, and error_type
3. **THEN RETRY** - Only after logging, try the corrected approach

This applies to:
- Command errors (exit code != 0)
- Module not found / import errors
- Test failures
- Build failures
- Any error that causes you to change approach

**Why this matters**: Logging failures BEFORE retrying captures the exact error context. If you retry first, you lose the original error details.

## When to Log FAILURE Episodes

ALWAYS log failures - they prevent repeating mistakes:
- User says \"still broken\", \"doesn't work\", \"same error\"
- Your code/command produces errors
- Tests/build fail after your changes
- You pivot approaches (log failed attempt BEFORE trying new one)
- You abandon/give up on an approach

Include error_message and error_type for failures.
</prociq-memory>"

jq -n --arg context "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "BeforeAgent",
    "additionalContext": $context
  }
}'
