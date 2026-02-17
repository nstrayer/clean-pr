# Canonical Severity Matrix

This file is the single source of truth for severity assignment across PR cleanliness analysis.

Used by:
- `skills/pr-cleanliness/SKILL.md`
- `commands/check.md`
- `commands/improve.md`
- `agents/pattern-scanner.md`

## Matrix

| Finding Type | Severity | Notes |
|---|---|---|
| Hardcoded credentials/tokens/secrets in added lines | Error | Must be fixed before merge in all file types |
| `debugger` or equivalent breakpoint statements in non-test code | Error | Includes language-specific debugger calls |
| Temporary debug logging/print statements in non-test code | Error | Applies to clearly temporary logging (`console.log`, `print`, `dbg!`, etc.) |
| Commented-out code blocks (3+ consecutive lines) in non-test code | Error | Documentation comments are excluded |
| TODO/FIXME/HACK/XXX comments newly added | Warning | Existing comments outside changed lines are ignored |
| Formatting-only changes (whitespace-only, import reorder-only, blank-line-only) | Warning | Warn when they inflate review cost |
| Scope creep (unrelated refactors, renames, type annotations, dependency changes) | Warning | Changes outside the PR purpose |
| Mixed concerns in one PR | Warning | Multiple independent purposes bundled together |
| PR size above thresholds (>400 lines changed or >15 files) | Warning | Suggest split or decomposition plan |
| Debug artifacts in test files | Info | Unless credentials/secrets are involved |
| Minor cleanliness suggestions | Info | Optional improvements that do not block merge |

## Interpretation Rules

1. If a finding matches multiple rules, use the highest severity that applies.
2. Debug findings in test files are downgraded to Info, except credentials/secrets which remain Error.
3. Legitimate operational logging (for example `console.error`, `console.warn`, structured logging) is not a debug artifact by default.
4. Only evaluate added or modified lines in the PR diff.
