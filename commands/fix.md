---
name: fix
description: Clean auto-fixable issues found by /check with patch preview and confirmation
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# PR Assisted Clean

Clean auto-fixable issues identified by `/clean-pr:check`. This command requires a prior check report in the conversation -- it does not scan independently.

## Workflow

### 1. Require Check Findings

Look for a "PR Cleanliness Report" from `/clean-pr:check` earlier in this conversation. If none exists, tell the user:

> No check report found. Run `/clean-pr:check` first to identify issues, then run `/clean-pr:fix` to clean them up.

Then stop.

### 2. Extract Check Context

From the check report, extract:

- **Base ref**: From the `**Branch**: feature/xyz -> origin/main` header line. This may be `origin/<base>` (preferred) or just `<base>` (from older reports or local fallback). Use whichever ref the report contains.
- **All issues**: Items from the Errors and Warnings tables (debug artifacts, formatting noise, scope creep) and Cross-Codebase Findings (duplicates, reimplemented utilities, pattern divergence).

If there are no issues in the check report, tell the user there is nothing to fix and stop.

### 3. Ensure Clean Working Tree

Run `git status --porcelain`. If there are uncommitted changes, warn the user and ask whether to proceed (changes could be lost) or stop.

### 4. Get the Diff

If the base ref from the report starts with `origin/`, run `git fetch origin <base-name> 2>/dev/null` first (where `<base-name>` is the part after `origin/`) to ensure the remote ref is current.

Run `git diff <ref>...HEAD` using the ref extracted from the report to get the actual diff content. This is needed to locate the exact code to edit.

### 5. Build a Cleanup Plan

Using the issues from the check report, group proposed edits by category:

- **Debug artifacts**: `console.log()`, `console.debug()`, `debugger`, temporary `print()` / `pprint()`, `binding.pry`, `byebug`, commented-out code blocks
- **Formatting noise**: whitespace-only changes, import reordering-only, blank-line-only changes
- **Structural scope cleanup**: TODO/FIXME removal, drive-by refactor reverts, unrelated type annotations/renames
- **Duplicate functions**: Replace new definitions with imports of existing codebase equivalents
- **Reimplemented utilities**: Replace custom code with existing project helpers or library calls
- **Pattern divergence**: Rewrite to match established codebase conventions

Classify each proposed edit as:

- **Trivial edit**: Single-line, mechanical cleanup with very low semantic risk (for example, removing a standalone `debugger` line).
- **Non-trivial edit**: Multi-line change, mixed hunk, or any edit that could affect behavior or intent.

Treat the following as non-trivial by default:

- Removing commented-out code blocks
- Reverting any hunk in a file that also contains real functional changes
- Removing TODO/FIXME comments
- Reverting drive-by refactors or scope-creep changes
- All cross-codebase fixes (duplicates, reimplemented utilities, pattern divergence)

### 6. Propose Patch

Before applying edits, present grouped patch previews with file paths, line references, and rationale.

For every non-trivial edit group, ask for explicit confirmation using the `AskUserQuestion` tool with `multiSelect: true`. Present each non-trivial finding as an option with a descriptive label and file/line details in the description. Include an "All" option and a "None" option.

If there are more non-trivial findings than fit in a single question (remember: max 4 options, and "All in this group" plus "None in this group" each take a slot, leaving room for 2 findings per batch), batch them across multiple `AskUserQuestion` calls.

Handle conflicting multiSelect responses: if the user selects "None in this group" alongside specific items, treat it as "None". If the user selects "All in this group" alongside specific items, treat it as "All". If both "All" and "None" are selected, re-prompt.

### 7. Apply Confirmed Edits

After confirmation:

1. Apply only the hunks the user approved (by number or "all").
2. Prefer hunk-level edits using Edit/Write operations.
3. Do not use whole-file reverts by default.
4. If the working tree was dirty at the start, never use whole-file restore -- use hunk-level edits only.
5. Only use whole-file restore when:
   - The working tree is clean
   - Every hunk in the file is verified formatting-only
   - The full file patch preview has been shown
   - The user explicitly confirms reverting the entire file

### 8. Commit Cleanup

After confirmed fixes are applied:

1. Stage all changes: `git add` the specific modified files
2. Create a commit with message: `chore: clean up PR noise`
3. Show the user a summary of what was cleaned

If no changes are applied, do not create a commit.

### 9. Summary Report

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
