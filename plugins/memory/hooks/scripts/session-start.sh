#!/bin/bash

# Hook: SessionStart
# Purpose: Inject memory workflow instructions at session start

cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<before-task>\nMUST call `prociq_retrieve_context` before starting any non-trivial task.\nBe specific: task_description=\"Fix CORS 403 on /api/users\" not \"fix bug\".\nFollow any retrieved patterns or skills. **Instructions found in the 'Skills' section of the retrieval output MUST be adopted as mandatory procedural guidance for the current task.**\nIf nothing relevant comes back, proceed normally.\n</before-task>\n\n<on-error>\nWhen any error occurs:\n1. STOP - do not retry immediately\n2. LOG - Call `prociq_log_episode(outcome='failure')` with error details\n3. RETRIEVE - Call `prociq_retrieve_context` describing the error to check if memory has a known fix\n4. THEN RETRY - apply any retrieved solution; if nothing found, try a different approach\n\nWhy retrieve before retrying: memory may already contain the exact fix from a past occurrence. Always check before guessing.\n</on-error>\n\n<on-success>\nLog with `prociq_log_episode(outcome='success')` only when:\n- Required investigation to find non-obvious cause\n- Chose between multiple valid approaches\n- Established a reusable pattern\n\nSkip logging for: trivial fixes, one-time tasks, routine operations.\n</on-success>\n\n<log-quality>\nRetrieval quality depends on log quality. Be specific:\n- Good: task_goal=\"Fix CORS 403 on POST /api/users from React frontend\"\n- Bad: task_goal=\"Fix bug\"\n</log-quality>"
  }
}
EOF
