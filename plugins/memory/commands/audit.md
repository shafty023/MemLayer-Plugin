---
description: Audit memory system - show episodes, patterns, and skills
argument-hint: "[episodes|patterns|skills]"
---

# Audit Memory System

Show what the agent knows and the current state of memory.

## Instructions

Provide a comprehensive overview of the memory system's current state.

1. Get memory statistics using `prociq_get_memory_stats`

2. List recent episodes (last 10) using `prociq_search_episodes` to show recent activity

3. List high-confidence patterns using `prociq_search_patterns` with min_confidence=0.7

4. List available skills using `prociq_list_skills`

5. Summarize findings:
   - Total episodes, patterns, and skills
   - Most common error types encountered
   - Most frequently used tools
   - Patterns that are candidates for skill promotion
   - Any patterns with low confidence that might need review

If $ARGUMENTS specifies "episodes", "patterns", or "skills", focus the audit on that category only.
