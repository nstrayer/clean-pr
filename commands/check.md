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

If an argument is provided, use it as the base branch. Otherwise:

1. Try `gh pr view --json baseRefName -q .baseRefName 2>/dev/null` to get the PR's base branch
2. Fall back to detecting the default branch: check if `main` or `master` exists via `git rev-parse --verify`
3. If neither works, ask the user

### 2. Get the Diff

Run these commands to gather PR information:

```bash
git diff <base>...HEAD --stat
git diff <base>...HEAD
git log <base>...HEAD --oneline
```

If the diff is very large (more than 2000 lines), process it file-by-file using `git diff <base>...HEAD -- <file>` for each changed file.

### 3. Analyze for Issues

Use the pattern-scanner agent via the Task tool to scan the diff for anti-patterns. Pass the diff content and ask it to categorize findings.

Also perform high-level analysis:

- **Mixed concerns**: Look at the set of changed files and commit messages. Do they serve a single purpose? Are there commits that could be independent PRs?
- **Size assessment**: Count total lines changed (additions + deletions) and files modified. Compare against thresholds (>400 lines or >15 files = warning).
- **Severity assignment**: Apply severities from `${CLAUDE_PLUGIN_ROOT}/skills/pr-cleanliness/references/severity-matrix.md` without adding command-specific overrides.

### 4. Produce Report

Output a structured markdown report with this format:

```markdown
# PR Cleanliness Report

**Branch**: `feature/xyz` -> `main`
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

## Recommendations

- [Actionable recommendation 1]
- [Actionable recommendation 2]
```

### Severity Rules

Use `${CLAUDE_PLUGIN_ROOT}/skills/pr-cleanliness/references/severity-matrix.md` as the single source of truth.

### Important Guidelines

- Only flag issues in **added or modified** lines (lines with `+` prefix in the diff). Do not flag existing code that was not changed.
- Distinguish between test files and production code. Debug statements in test files are less severe.
- Do not flag legitimate logging (structured logging, error handling) as debug artifacts.
- When flagging mixed concerns, be specific about which changes belong together and which do not.
- If the PR looks clean, say so clearly. Do not invent issues.
