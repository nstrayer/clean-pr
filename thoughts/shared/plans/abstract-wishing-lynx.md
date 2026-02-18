# Plan: Improve duplicate detection in codebase-analyzer agent

## Context

The codebase-analyzer agent's duplicate detection (Phase 2) is name-gated -- it Greps for similar function names, then reads bodies to confirm overlap. If two functions do the same thing but have different names (e.g., `doFoo()` vs `performBar()`), the duplicate is missed entirely. The search never starts because the names don't match.

The agent has Bash, Read, Grep, and Glob available. It's an LLM agent, so it can reason about code semantics -- it just needs broader search instructions.

## Change

**File: `agents/codebase-analyzer.md`** -- Restructure Phase 2 from a single name-based search into a multi-layer search strategy.

Replace the current Phase 2 (lines 57-68):

```markdown
### Phase 2: Duplicate/Similar Function Detection (Severity: Warning)

For each new function or class definition:

1. Use `Grep` to search the codebase (excluding the file being added/modified) for functions with similar names or signatures
2. When candidates are found, use `Read` to compare the function bodies
3. Only report when there is **meaningful overlap**: similar name AND similar logic/behavior, not just name collisions
```

With a multi-layer search that uses four strategies:

```markdown
### Phase 2: Duplicate/Similar Function Detection (Severity: Warning)

For each new function or class definition, first summarize in one sentence what it does. Then search for existing equivalents using these strategies in order. Stop for a given function once you find a strong match.

**Strategy A -- Name search**: Grep for functions with similar names or common synonyms. For example, for `retryWithBackoff`, also search for `retry`, `attempt`, `withRetry`, `executeWithRetry`.

**Strategy B -- Behavioral keyword search**: Extract 3-5 behavioral keywords from the function's logic (not its name) and Grep for those. For example, a retry function might use keywords: `exponential`, `backoff`, `max.*attempts`, `delay.*retry`. A date formatter might use: `relative`, `ago`, `distance`, `fromNow`.

**Strategy C -- Utility directory sweep**: Use Glob to find utility/helper directories (`**/utils/**`, `**/helpers/**`, `**/lib/**`, `**/common/**`, `**/shared/**`). For each directory found, Read the index/barrel file or list files with Glob, then Read promising candidates to check for functional overlap.

**Strategy D -- Import-based search**: Parse what the new function imports or calls. Grep for other files that import the same modules/functions. If multiple files import the same dependency to do similar work, one may already solve the problem.

For each candidate found by any strategy, Read the function body and compare. Only report when there is **meaningful behavioral overlap** -- similar logic and purpose, not just name or keyword collisions.
```

Everything else in the agent stays the same (Phase 1, Phase 3, Phase 4, output format, severity rules, conservative principles).

## Files to modify

1. `agents/codebase-analyzer.md` -- Replace Phase 2 with multi-layer search strategy (~lines 57-68)

## Verification

1. Run `/clean-pr:check` on a branch where a new function duplicates an existing one with a different name
2. Confirm the check report finds the duplicate via behavioral keyword or utility directory search
3. Run on a branch with no duplicates and confirm no false positives are introduced
