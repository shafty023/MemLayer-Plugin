# Ticket: Default Scope Misapplied Instead of `memlayer-plugin`

## Summary
When multiple ProcIQ scopes are authorized, memory writes can still be logged to `default` instead of the user-selected scope (`memlayer-plugin`), causing misplaced episodes and notes.

## Problem
- Expected: Once the user selects `memlayer-plugin`, all scoped memory writes for the active thread use `memlayer-plugin`.
- Actual: A failure episode was logged to `default` before scope confirmation was applied consistently.

## Impact
- Memory records are split across scopes.
- Retrieval relevance drops for plugin-specific work.
- Manual cleanup is required (archive/re-log).

## Reproduction
1. Start a non-trivial task with multiple authorized scopes.
2. Call `prociq_retrieve_context`.
3. Call `prociq_list_scopes`.
4. Perform a command that fails before explicit scope confirmation handling is enforced.
5. Observe `prociq_log_episode` written to `default` instead of `memlayer-plugin`.

## Acceptance Criteria
- Scoped memory writes (`prociq_log_episode`, `prociq_log_note`, `prociq_log_episodes_batch`) are blocked until explicit default scope selection is resolved when multiple scopes exist.
- After selection, all memory writes use the selected scope for the rest of the thread unless changed explicitly.
- On command/test/build failure, the first failure log uses the selected scope.
- Regression check: no new episode for this flow is written to `default`.

## Proposed Fix
- Persist a per-thread resolved scope after user confirmation.
- Add a pre-write guard that fails closed if scope is unresolved.
- Update memory workflow docs and skill instructions to require resolved scope before any scoped write.

## Notes
- Affected incident was corrected by archiving the `default` scoped episode and re-logging it in `memlayer-plugin`.
