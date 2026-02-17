---
name: PR Cleanliness
description: This skill should be used when the user asks to "clean up a PR", "check PR quality", "review PR for unnecessary changes", "simplify a pull request", "make PR easier to review", "reduce PR noise", "minimize diff", or discusses PR hygiene, clean diffs, or making PRs easier for humans to review.
version: 0.1.0
---

## Overview

PR cleanliness is about ensuring every change in a pull request serves the PR's stated purpose. A clean PR contains only the changes necessary to accomplish its goal -- nothing more, nothing less. This skill provides the knowledge base for analyzing and cleaning PRs.

## Why PR Cleanliness Matters

Large, noisy PRs slow teams down. Reviewers lose focus scanning through formatting changes, debug leftovers, and unrelated refactors. Important bugs hide in the noise. Review fatigue leads to rubber-stamping. Clean PRs get reviewed faster, catch more bugs, and merge sooner.

## Issue Categories

### 1. Mixed Concerns

Changes serving multiple unrelated purposes bundled in one PR. A bug fix mixed with a refactor. A new feature mixed with dependency updates. Each distinct purpose should be its own PR.

**Detection signals:**
- Files from unrelated modules or features modified together
- Commit messages describing different types of work (fix + feat + refactor)
- Changes that could be reverted independently without affecting each other

### 2. Debug Artifacts

Code added during development that should not ship. These are the most straightforward issues to detect and fix.

**Common patterns:**
- `console.log`, `console.debug`, `console.warn` (non-production)
- `print()`, `println()`, `fmt.Println()` debug statements
- `debugger`, `binding.pry`, `import pdb; pdb.set_trace()`
- `TODO`, `FIXME`, `HACK`, `XXX` comments added in this PR
- Commented-out code blocks (not documentation comments)
- Temporary test values or hardcoded credentials

### 3. Formatting Noise

Changes that alter appearance without changing behavior. These inflate the diff and obscure real changes.

**Common patterns:**
- Whitespace-only line changes (trailing spaces, tabs vs spaces)
- Import reordering without adding/removing imports
- Line ending changes (CRLF vs LF)
- Brace style reformatting on unchanged code
- Auto-formatter running on entire files when only a few lines changed
- Adding/removing blank lines in unchanged code sections

### 4. Scope Creep

Changes that go beyond the PR's purpose, even if individually reasonable. These should be separate PRs.

**Common patterns:**
- Renaming variables or functions in code not otherwise modified
- Adding type annotations to untouched code
- Refactoring adjacent code "while we're here"
- Upgrading dependencies unrelated to the feature
- Adding error handling to code paths not touched by the PR
- Documentation updates for unrelated features

### 5. PR Size

PRs that are too large to review effectively, even if all changes are related. The threshold depends on context, but general guidelines apply.

**Size signals:**
- More than ~400 lines changed (additions + deletions)
- More than ~15 files modified
- Changes spanning more than 3 distinct directories/modules
- Multiple commits that could stand alone as separate PRs

## Detection Approach

To analyze a PR for cleanliness issues:

1. **Establish context**: Determine the PR's purpose from branch name, commit messages, and (if available) PR description
2. **Get the diff**: Compare current branch against base branch using `git diff <base>...HEAD`
3. **Catalog changes**: List all modified files with change type (added/modified/deleted) and line counts
4. **Scan for artifacts**: Search the diff for debug patterns, formatting noise, and commented-out code
5. **Assess scope**: Determine whether each file's changes serve the PR's stated purpose
6. **Evaluate size**: Check total diff size and file count against thresholds
7. **Report findings**: Group issues by category with file:line references and severity

## Severity Levels

- **Error**: Must fix before merging (debug artifacts, credentials, test-only code)
- **Warning**: Should fix (formatting noise, scope creep, mixed concerns)
- **Info**: Consider fixing (size suggestions, minor improvements)

## Base Branch Detection

To determine the base branch for comparison:

1. Check if a PR exists for the current branch via `gh pr view --json baseRefName`
2. Fall back to common defaults: `main`, `master`, `develop`
3. Use `git merge-base` to find the actual divergence point

## Additional Resources

### Reference Files

For a comprehensive catalog of anti-patterns with language-specific examples and detection regex patterns, consult:

- **`references/anti-patterns.md`** -- Detailed anti-pattern catalog with regex patterns for detection, organized by language and category
