#!/bin/bash

# Hook: UserPromptSubmit
# Purpose: Reinforce memory workflow on each user message

cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "<before-task>\nCall `prociq_retrieve_context` before starting non-trivial work. This surfaces past solutions and prevents repeating mistakes.\n</before-task>\n\n<on-error>\nWhen any error occurs:\n1. STOP - do not retry immediately\n2. LOG - Call `prociq_log_episode(outcome='failure', error_message='...', error_type='...')`\n3. THEN RETRY - only after logging\n</on-error>\n\n<on-success>\nLog with `prociq_log_episode(outcome='success')` only when:\n- Required investigation to find non-obvious cause\n- Chose between multiple valid approaches\n- Established a reusable pattern\n\nSkip logging for: trivial fixes, one-time tasks, routine operations.\n</on-success>"
  }
}
EOF
