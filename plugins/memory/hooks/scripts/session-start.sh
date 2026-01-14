#!/bin/bash

# Hook: SessionStart
# Purpose: Remind Claude about memory tools at session start

# Return JSON with proper hookSpecificOutput structure per Claude Code docs
cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<prociq-memory-reminder>\nMemory tools available via prociq_mcp:\n- prociq_retrieve_context: Get relevant past experiences before starting a task\n- prociq_log_episode: Record what happened after completing/failing a task\n- prociq_search_episodes: Search past experiences by query\n- prociq_get_memory_stats: Check memory system status\n\nBest practice: Call prociq_retrieve_context at the start of non-trivial tasks.\n</prociq-memory-reminder>"
  }
}
EOF
