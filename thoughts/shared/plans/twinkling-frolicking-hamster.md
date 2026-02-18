# Plan: Fix Stale Base Branch Comparison

## Context

The clean-pr plugin compares the current branch against a base branch (e.g., `main`) using `git diff <base>...HEAD`. When the local `main` is stale but the feature branch was rebased onto a newer `origin/main`, the diff includes commits already on the remote -- inflating the PR and producing false positives. GitHub PRs always compare against the remote ref, so the plugin should too.

## Approach

After resolving the base branch name, fetch the remote and use `origin/<base>` instead of `<base>` for all diff/log commands. Fall back to the local ref with a warning if the fetch fails (no network, no remote, etc.).

## Files to Modify (5)

### 1. `skills/pr-cleanliness/SKILL.md`
- **"Base Branch Detection" section (lines 69-75)**: Expand to document the full procedure -- resolve name, fetch remote, use `origin/<base>`, fall back with warning
- **"Detection Approach" section (line 57)**: Change `git diff <base>...HEAD` to `git diff origin/<base>...HEAD`

### 2. `commands/check.md`
- **Step 1 "Determine Base Branch" (lines 19-25)**: Add sub-step to fetch and resolve to remote tracking ref after resolving name
- **Step 2 "Get the Diff" (lines 29-37)**: Use `<ref>` (the resolved ref from step 1) in all git commands
- **Step 5 report header template (line 68)**: Change `-> main` to `-> origin/main` so downstream `fix` command inherits the correct ref
- Handle edge case: if user passes something already prefixed with `origin/`, use as-is

### 3. `commands/split.md`
- **Step 1 "Determine Base Branch" (lines 20-24)**: Same fetch-and-resolve sub-step as check.md
- **Step 2 "Gather Information" (lines 28-43)**: Use resolved `<ref>` in all git commands

### 4. `commands/fix.md`
- **Step 2 "Extract Check Context" (lines 29-34)**: Update to expect `origin/<base>` in the report header
- **Step 4 "Get the Diff" (line 42)**: Use the `origin/<base>` ref from the report; re-fetch before diffing in case the report was generated earlier in the session

### 5. `agents/pattern-scanner.md`
- **Line 53**: Update diff command wording to reference the resolved ref provided by the calling command

## Edge Cases Handled

- **No remote / no network**: Fetch fails silently, falls back to local ref with a warning
- **User passes `origin/main` explicitly**: Detected by prefix, used as-is without redundant fetch
- **Branch only exists locally**: `origin/<base>` won't exist after fetch, falls back to local
- **Backward compat**: `fix` extracts whatever ref the `check` report contains, so old-format reports with just `main` still work

## Verification

1. On a repo where local `main` is behind `origin/main`, run `/clean-pr:check` and confirm the diff matches what `gh pr diff` shows
2. Run `/clean-pr:check` with no network and confirm it falls back gracefully with a warning
3. Run `/clean-pr:check main` (explicit arg) and confirm it resolves to `origin/main`
4. Run `/clean-pr:fix` after a check and confirm it uses the same `origin/<base>` ref from the report
