---
description: This skill should be used when working with the prociq memory system, logging episodes, retrieving context, or managing patterns and skills. Triggers include debugging errors, starting complex tasks, or when the user asks about past experiences.
---

# ProcIQ Memory System Usage

Guide for using the self-learning memory system effectively.

## Core Tools

| Tool | When to Use |
|------|-------------|
| `prociq_list_scopes` | Before the first memory operation to initialize scope |
| `prociq_retrieve_context` | Before starting any non-trivial task |
| `prociq_log_episode` | After completing or failing a task |
| `prociq_search_episodes` | When looking for specific past experiences |
| `prociq_get_memory_stats` | To check system health |
| `prociq_trigger_consolidation` | To process accumulated episodes into patterns |

## Scopes and Authorization (Mandatory Initialization)

Before the first memory operation in a session, you **MUST** ensure the scope is clear:
1. Call `prociq_list_scopes` to see authorized scopes.
2. **PROMPT**: If multiple scopes exist or if the intended scope is unclear, ask the user to specify which scope should be used as the default for the current session.

## Logging Episodes

Always log episodes after completing significant work:

```python
prociq_log_episode(
    task_goal="What you were trying to accomplish",
    approach_taken="How you approached it and what worked/failed",
    outcome="success" | "partial" | "failure",
    error_message="Details if failed",
    scope="your-session-scope",  # Ensure this matches your initialized scope
    tools_used=["Read", "Edit", "Bash"],
    file_patterns=["*.py", "src/**/*.ts"],
    component_types=["api", "database", "ui"],
    importance_hint=0.8  # Higher for important discoveries
)
```

### Importance Hints

| Situation | Hint Value |
|-----------|------------|
| Normal success | 0.2-0.3 |
| First-time task type | 0.5-0.6 |
| Learned something new | 0.7-0.8 |
| Critical discovery/failure | 0.9-1.0 |

## Retrieving Context

Before starting complex tasks, retrieve relevant past experiences:

```python
prociq_retrieve_context(
    task_description="Specific description of what you're about to do",
    error_state="Current error message if debugging",
    tools=["Read", "Edit"]  # Tools you're likely to use
)
```

The system returns:
- **Episodes**: Past experiences with similar tasks
- **Patterns**: Derived strategies from multiple experiences
- **Skills**: Dynamic procedural guidance

**CRITICAL**: You MUST adopt instructions found in the 'Skills' section of the retrieval output as mandatory procedural guidance for the current task.

## Reflection and Patterns

For failures, use `/reflect` to analyze and store learnings:
1. Identifies root cause
2. Proposes strategy for next time
3. Stores as pattern candidate

For manual knowledge, use `/teach`:
- Injects knowledge directly
- Higher importance than regular episodes
- Fast-tracks to pattern status

## Consolidation

Run `/consolidate` periodically to:
- Cluster similar episodes
- Extract patterns
- Decay old, low-value episodes
- Promote patterns to skills

Auto-consolidation triggers every 10 episodes and at session end.
