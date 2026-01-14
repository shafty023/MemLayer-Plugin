---
description: Remove specific episodes from memory
argument-hint: "<episode-id> or <search-query>"
---

# Forget Specific Memories

Remove specific episodes from memory.

## Instructions

Delete episodes from memory. This action is irreversible.

If $ARGUMENTS contains episode IDs (format: ep-XXXX):
1. Confirm the episodes exist by searching for them
2. Show what will be deleted (task goal, outcome, importance)
3. Delete using `prociq_forget_episodes`
4. Confirm deletion

If $ARGUMENTS contains a search query instead:
1. Search for matching episodes using `prociq_search_episodes`
2. Show the matching episodes
3. Ask which ones to delete before proceeding

If $ARGUMENTS is empty:
1. Show the 5 oldest, lowest-importance episodes as candidates
2. Ask which ones to delete

Always confirm before deleting and report what was removed.
