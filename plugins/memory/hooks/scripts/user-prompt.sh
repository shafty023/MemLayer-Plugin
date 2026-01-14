#!/bin/bash

# Hook: UserPromptSubmit
# Purpose: Inject memory workflow instructions into Claude's context

# Return JSON with proper hookSpecificOutput structure per Claude Code docs
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "<prociq-memory>\n## REQUIRED: Create TodoWrite with Memory Tasks\n\nYour FIRST action must be calling TodoWrite with these items at the TOP of your list:\n\n1. \"Check prociq memory for relevant context\" (status: in_progress)\n2. [Your actual task items here...]\n3. \"Log episode outcome\" (status: pending) - ALWAYS include this as the LAST item\n\n## Memory Task Details\n\n**Check memory** - Call `prociq_retrieve_context` with:\n- Task description (what you're doing)\n- Error message (if debugging)\n- This surfaces past solutions and prevents repeating mistakes\n\n## When to Log SUCCESS Episodes\n\nLog with `prociq_log_episode` outcome='success' ONLY when:\n- Solved a recurring problem type (config, debugging, integration)\n- Required investigation to find non-obvious cause\n- Approach wasn't obvious (chose between multiple solutions)\n- Established a pattern for future work\n- First time doing X in this codebase\n\nDO NOT log success when:\n- One-time task (migration, rename) - won't recur\n- Trivial fix (typo, missing import) - no learning\n- Just following explicit instructions - no decision-making\n- Pure research/reading - no action taken\n- Routine CRUD operations - template work\n\nTEST: \"If I encounter a similar situation, would knowing what I did help?\" No = skip.\n\n## CRITICAL: On ANY Error or Failure\n\n**STOP before retrying.** When a command fails or produces an error:\n\n1. **STOP** - Do not immediately retry\n2. **LOG THE FAILURE** - Call `prociq_log_episode` with outcome='failure', error_message, and error_type\n3. **THEN RETRY** - Only after logging, try the corrected approach\n\nThis applies to:\n- Command errors (exit code != 0)\n- Module not found / import errors\n- Test failures\n- Build failures\n- Any error that causes you to change approach\n\n**Why this matters**: Logging failures BEFORE retrying captures the exact error context. If you retry first, you lose the original error details.\n\n## When to Log FAILURE Episodes\n\nALWAYS log failures - they prevent repeating mistakes:\n- User says \"still broken\", \"doesn't work\", \"same error\"\n- Your code/command produces errors\n- Tests/build fail after your changes\n- You pivot approaches (log failed attempt BEFORE trying new one)\n- You abandon/give up on an approach\n\nInclude error_message and error_type for failures.\n</prociq-memory>"
  }
}
EOF
