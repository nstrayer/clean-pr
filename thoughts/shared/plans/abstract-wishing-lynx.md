# Plan: Improve duplicate detection in codebase-analyzer agent

## Context

The codebase-analyzer agent's duplicate detection (Phase 2) is name-gated -- it Greps for similar function names, then reads bodies to confirm overlap. If two functions do the same thing but have different names (e.g., `doFoo()` vs `performBar()`), the duplicate is missed entirely.

Industry best practice for duplicate detection is two-phase: cheap heuristic candidate generation, then smart comparison. Our architecture (Grep/Glob to find candidates, LLM to confirm) is correct -- the gap is that our candidate generation only uses names. Traditional tools like PMD CPD use token normalization with `--ignore-identifiers` to catch renamed clones, and no traditional tool detects Type 4 (semantic) clones at all -- that's where LLMs have an advantage, but only if candidates are surfaced in the first place.

## Change

**File: `agents/codebase-analyzer.md`** -- Replace the current Phase 2 (lines 57-68) with a multi-strategy candidate generation approach, ordered from cheapest to most expensive.

Replace:
```markdown
For each new function or class definition:

1. Use `Grep` to search the codebase (excluding the file being added/modified) for functions with similar names or signatures
2. When candidates are found, use `Read` to compare the function bodies
3. Only report when there is **meaningful overlap**: similar name AND similar logic/behavior, not just name collisions
```

With:
```markdown
For each new function or class definition, first summarize in one sentence what it does (without using its name). Then search for existing equivalents using these strategies in order. Stop for a given function once you find a strong match.

**Strategy A -- Name search**: Grep for functions with similar names or common synonyms. For example, for `retryWithBackoff`, also search for `retry`, `attempt`, `withRetry`, `executeWithRetry`.

**Strategy B -- API call fingerprinting**: Identify the key function calls and operations inside the new function (e.g., `setTimeout`, `clearTimeout`, `Promise`, `fetch`, `JSON.parse`). Grep for other functions in the codebase that call the same combination. Functions using the same building blocks often implement the same behavior, regardless of naming.

**Strategy C -- Utility directory sweep**: Use Glob to find utility/helper directories (`**/utils/**`, `**/helpers/**`, `**/lib/**`, `**/common/**`, `**/shared/**`). For each directory found, Read the index/barrel file or list files with Glob, then Read promising candidates to check for functional overlap.

**Strategy D -- Import-based search**: Parse what the new function imports or calls. Grep for other files that import the same modules/functions. If multiple files import the same dependency to do similar work, one may already solve the problem.

For each candidate found by any strategy, Read the function body and compare. Only report when there is **meaningful behavioral overlap** -- similar logic and purpose, not just name or API call collisions.
```

## Files to modify

1. `agents/codebase-analyzer.md` -- Replace Phase 2 with multi-strategy search (~lines 57-68)

## Verification

1. Run `/clean-pr:check` on a branch where a new function duplicates an existing one with a different name
2. Confirm the check report finds the duplicate via API call fingerprinting or utility directory search
3. Run on a branch with no duplicates and confirm no false positives are introduced
