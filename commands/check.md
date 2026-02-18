---
name: check
description: Analyze the current branch's PR diff for issues that make human review harder
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Task
argument-hint: "[base-branch]"
---

# PR Cleanliness Check

Analyze the current branch's diff against the base branch and produce a structured report of issues that make the PR harder to review.

## Workflow

### 1. Determine Base Branch

If an argument is provided, use it as the base branch name. Otherwise:

1. Try `gh pr view --json baseRefName -q .baseRefName 2>/dev/null` to get the PR's base branch
2. Fall back to detecting the default branch: check if `main` or `master` exists via `git rev-parse --verify`
3. If neither works, ask the user

Then resolve the base branch to its remote tracking ref following the **Base Branch Detection** procedure in `${CLAUDE_PLUGIN_ROOT}/skills/pr-cleanliness/SKILL.md`. Use the resolved `<ref>` (typically `origin/<base>`) for all subsequent git commands.

### 2. Get the Diff

Run these commands to gather PR information, using `<ref>` (the resolved ref from step 1):

```bash
git diff <ref>...HEAD --stat
git diff <ref>...HEAD
git log <ref>...HEAD --oneline
```

If the diff is very large (more than 2000 lines), process it file-by-file using `git diff <ref>...HEAD -- <file>` for each changed file.

### 3. Scan for Anti-Patterns

Use the pattern-scanner agent via the Task tool to scan the diff for anti-patterns. Pass the diff content and ask it to categorize findings.

Also perform high-level analysis:

- **Mixed concerns**: Look at the set of changed files and commit messages. Do they serve a single purpose? Are there commits that could be independent PRs?
- **Size assessment**: Count total lines changed (additions + deletions) and files modified. Compare against thresholds (>400 lines or >15 files = warning).
- **Severity assignment**: Apply severities from `${CLAUDE_PLUGIN_ROOT}/skills/pr-cleanliness/references/severity-matrix.md` without adding command-specific overrides.

### 4. Cross-Codebase Analysis

Skip this step for greenfield projects (fewer than 5 non-test, non-config source files in the repository).

Use the codebase-analyzer agent via the Task tool to compare new code against the existing codebase. Pass the diff content and ask it to check for:

- **Duplicate functions**: New definitions that closely mirror existing codebase functionality
- **Reimplemented utilities**: Custom implementations of functionality already available via project helpers or libraries
- **Pattern divergence**: New code that uses different conventions than the established codebase majority

Cross-codebase findings are always classified as non-trivial by the `fix` command and require explicit user confirmation before changes are applied.

### 5. Produce Report

Output a structured markdown report with this format:

```markdown
# PR Cleanliness Report

**Branch**: `feature/xyz` -> `origin/main`
**Files changed**: N | **Lines changed**: +X / -Y
**Overall**: [CLEAN | NEEDS ATTENTION | NEEDS WORK]

## Summary

[1-2 sentence summary of findings]

## Issues Found

### Errors (N)

[Issues that must be fixed]

| File | Line | Issue | Description |
|------|------|-------|-------------|
| src/foo.ts | 42 | Debug artifact | `console.log("debug")` |

### Warnings (N)

[Issues that should be fixed]

| File | Line | Issue | Description |
|------|------|-------|-------------|

### Info (N)

[Suggestions to consider]

## Cross-Codebase Findings

### Potential Duplicates (N)

| New Definition | Existing Match | Overlap |
|----------------|----------------|---------|
| `src/utils/retry.ts:15` `retryWithBackoff()` | `src/lib/http.ts:82` `retryRequest()` | Both implement exponential backoff retry |

### Reimplemented Utilities (N)

| New Utility | Existing Alternative | Details |
|-------------|---------------------|---------|
| `src/helpers/date.ts:5` `formatRelativeDate()` | `date-fns` `formatDistanceToNow()` | Already in package.json |

### Pattern Divergence (N)

| File | Pattern | Codebase Convention | New Code |
|------|---------|-------------------|----------|
| `src/api/users.ts:20-45` | Error handling | async/await + try/catch (8/10 files) | Callback-style |

_Cross-codebase findings are non-trivial -- `/clean-pr:fix` will preview proposed changes and require your confirmation before applying._

## Next Steps

[Include only the items that apply based on findings above. If the PR is clean, say "This PR looks clean -- no action needed." and stop here.]

- **Run `/clean-pr:fix`** -- [N] issues found. This will preview proposed cleanups and apply only what you confirm.
- **Run `/clean-pr:split`** -- This PR has mixed concerns / exceeds size thresholds. Get a decomposition plan with landing order.
```

### Next Steps Rules

Include each suggestion only when the corresponding findings exist:

- **`/clean-pr:fix`**: Include when there are any issues in the Errors/Warnings tables or any Cross-Codebase Findings. Replace `[N]` with the total count.
- **`/clean-pr:split`**: Include when there are Warnings for mixed concerns or PR size (>400 lines or >15 files).
- If none of these apply, the PR is clean -- output only the "no action needed" message.

### Severity Rules

Use `${CLAUDE_PLUGIN_ROOT}/skills/pr-cleanliness/references/severity-matrix.md` as the single source of truth.

### Important Guidelines

- Only flag issues in **added or modified** lines (lines with `+` prefix in the diff). Do not flag existing code that was not changed.
- Distinguish between test files and production code. Debug statements in test files are less severe.
- Do not flag legitimate logging (structured logging, error handling) as debug artifacts.
- When flagging mixed concerns, be specific about which changes belong together and which do not.
- If the PR looks clean, say so clearly. Do not invent issues.
