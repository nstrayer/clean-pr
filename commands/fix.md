---
name: fix
description: Auto-clean unnecessary changes from the current branch to simplify the PR
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Task
argument-hint: "[base-branch]"
---

# PR Auto-Clean

Automatically remove unnecessary changes from the current branch to make the PR cleaner and easier to review. Use moderate aggressiveness: remove obvious noise and revert formatting-only changes, but ask before structural changes.

## Workflow

### 1. Determine Base Branch

If an argument is provided, use it as the base branch. Otherwise:

1. Try `gh pr view --json baseRefName -q .baseRefName 2>/dev/null`
2. Fall back to `main` or `master` via `git rev-parse --verify`
3. If neither works, ask the user

### 2. Ensure Clean Working Tree

Run `git status --porcelain`. If there are uncommitted changes, warn the user and ask whether to proceed (changes could be lost) or stop.

### 3. Analyze the Diff

Run `git diff <base>...HEAD` and use the pattern-scanner agent to identify fixable issues.

### 4. Fix Issues by Category

#### Category A: Debug Artifacts (Auto-fix)

Remove without asking:
- `console.log()`, `console.debug()` statements (not `console.error()` or `console.warn()` used for real error handling)
- `debugger` statements
- `print()` / `pprint()` debug statements (in non-Python-script contexts)
- `binding.pry`, `byebug`
- Commented-out code blocks (3+ consecutive lines of commented code keywords)

**Method**: Use the Edit tool to remove the offending lines. If removing a line leaves an empty block, clean up the block.

#### Category B: Formatting Noise (Auto-fix)

Revert without asking:
- Whitespace-only changes in files that have no other meaningful changes
- Import reordering where no imports were added or removed
- Blank line additions/removals in otherwise untouched code

**Method**: For files where ALL changes are formatting-only, use `git checkout <base> -- <file>` to fully revert. For files with mixed real and formatting changes, use the Edit tool to revert only the formatting hunks.

#### Category C: Structural Changes (Ask First)

Present to the user and ask for confirmation before acting:
- Removing TODO/FIXME comments (user may want to keep as reminders)
- Reverting drive-by refactors (renames, type annotations in untouched code)
- Removing new error handling in code not related to the PR's purpose

Present each group of structural changes as a batch:
```
I found N structural changes that may be out of scope:

1. src/utils.ts: Variable rename `x` -> `count` (lines 15-20) -- not related to this PR
2. src/api.ts: Added type annotations (lines 42-50) -- file not otherwise modified
3. src/config.ts: Added null check (line 88) -- unrelated to PR purpose

Remove these changes? [Describe what will happen]
```

### 5. Commit Cleanup

After all fixes are applied:

1. Stage all changes: `git add` the specific modified files
2. Create a commit with message: `chore: clean up PR noise`
3. Show the user a summary of what was cleaned

### 6. Summary Report

Output a summary:

```markdown
# PR Cleanup Complete

## Changes Made
- Removed N debug statements
- Reverted N formatting-only changes
- [Other fixes applied]

## Skipped (User Declined)
- [Any structural changes the user chose to keep]

## Before/After
- Files changed: N -> M
- Lines changed: +X/-Y -> +A/-B
```

### Important Guidelines

- Never remove `console.error()` or `console.warn()` that are part of real error handling
- Never revert changes in files that have both formatting and real changes without being precise about which hunks to revert
- Always show the user what will be changed before making structural fixes
- If the working tree is dirty, do not proceed without user confirmation
- Create a single cleanup commit, not one per fix
- If nothing needs fixing, say so and exit
