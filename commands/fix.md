---
name: fix
description: Clean unnecessary changes from the current branch with patch preview and confirmation for non-trivial edits
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

# PR Assisted Clean

Clean unnecessary changes from the current branch to make the PR cleaner and easier to review. Default to safe mode: suggest patch previews first, and require explicit confirmation for any non-trivial edit before applying.

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

### 4. Build a Cleanup Plan

Analyze findings and group proposed edits by category:

- **Debug artifacts**: `console.log()`, `console.debug()`, `debugger`, temporary `print()` / `pprint()`, `binding.pry`, `byebug`, commented-out code blocks
- **Formatting noise**: whitespace-only changes, import reordering-only, blank-line-only changes
- **Structural scope cleanup**: TODO/FIXME removal, drive-by refactor reverts, unrelated type annotations/renames

Classify each proposed edit as:

- **Trivial edit**: Single-line, mechanical cleanup with very low semantic risk (for example, removing a standalone `debugger` line).
- **Non-trivial edit**: Multi-line change, mixed hunk, or any edit that could affect behavior or intent.

Treat the following as non-trivial by default:

- Removing commented-out code blocks
- Reverting any hunk in a file that also contains real functional changes
- Removing TODO/FIXME comments
- Reverting drive-by refactors or scope-creep changes

### 5. Propose Patch (Default Behavior)

Before applying edits, present grouped patch previews with file paths, line references, and rationale.

For every non-trivial edit group, ask for explicit confirmation:
```
I found N proposed cleanups. The following are non-trivial and need confirmation:

1. src/utils.ts: Remove commented-out code block (lines 15-23)
2. src/api.ts: Revert formatting-only hunk in file with functional changes (lines 42-50)
3. src/config.ts: Revert unrelated rename (lines 88-94)

Apply these patch hunks? [yes/no]
```

### 6. Apply Confirmed Edits

After confirmation:

1. Apply only approved hunks.
2. Prefer hunk-level edits using Edit/Write operations.
3. Do not use whole-file reverts by default.
4. Only use whole-file restore when:
   - Every hunk in the file is verified formatting-only
   - The full file patch preview has been shown
   - The user explicitly confirms reverting the entire file

### 7. Commit Cleanup

After confirmed fixes are applied:

1. Stage all changes: `git add` the specific modified files
2. Create a commit with message: `chore: clean up PR noise`
3. Show the user a summary of what was cleaned

If no changes are applied, do not create a commit.

### 8. Summary Report

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
- Always suggest a patch preview before applying any non-trivial edit
- If the working tree is dirty, do not proceed without user confirmation
- Create a single cleanup commit, not one per fix
- If nothing needs fixing, say so and exit
