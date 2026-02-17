---
name: PR Cleanliness
description: This skill should be used when the user asks to "clean up a PR", "check PR quality", "review PR for unnecessary changes", "simplify a pull request", "make PR easier to review", "reduce PR noise", "minimize diff", "remove debug statements from my PR", "prepare PR for review", "my PR is too big", or discusses PR hygiene, clean diffs, PR size, or making PRs easier for humans to review.
version: 0.1.0
---

## Overview

PR cleanliness is about ensuring every change in a pull request serves the PR's stated purpose. A clean PR contains only the changes necessary to accomplish its goal -- nothing more, nothing less. This skill provides the knowledge base for analyzing and cleaning PRs.

## Why PR Cleanliness Matters

Noisy PRs cause review fatigue, hide bugs, and slow teams down -- clean PRs get reviewed faster and merge sooner.

## Issue Categories

### 1. Mixed Concerns

Changes serving multiple unrelated purposes bundled in one PR. A bug fix mixed with a refactor. A new feature mixed with dependency updates. Each distinct purpose should be its own PR.

**Detection signals:**
- Files from unrelated modules or features modified together
- Commit messages describing different types of work (fix + feat + refactor)
- Changes that could be reverted independently without affecting each other

### 2. Debug Artifacts

Code added during development that should not ship (e.g., `console.log`, `debugger`, `print()`, TODO/FIXME comments, commented-out code blocks). See `references/anti-patterns.md` for the full catalog with language-specific regex patterns.

### 3. Formatting Noise

Changes that alter appearance without changing behavior -- whitespace-only changes, import reordering, blank line additions in untouched code. These inflate the diff and obscure real changes. See `references/anti-patterns.md` for detection approaches.

### 4. Scope Creep

Changes that go beyond the PR's purpose, even if individually reasonable -- renames in untouched files, type annotations added to existing code, drive-by refactors. These should be separate PRs. See `references/anti-patterns.md` for detection signals.

### 5. PR Size

PRs that are too large to review effectively. General thresholds: >400 lines changed or >15 files modified warrants attention. >800 lines or >30 files strongly suggests splitting. See `references/anti-patterns.md` for size guidelines and contextual adjustments.

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

Use `references/severity-matrix.md` as the canonical severity policy. Do not redefine severity mappings in commands or agent prompts.

## Base Branch Detection

To determine the base branch for comparison:

1. Check if a PR exists for the current branch via `gh pr view --json baseRefName`
2. Fall back to common defaults: `main`, `master`, `develop`
3. Use `git merge-base` to find the actual divergence point

## Additional Resources

### Reference Files

For a comprehensive catalog of anti-patterns with language-specific examples and detection regex patterns, consult:

- **`references/anti-patterns.md`** -- Detailed anti-pattern catalog with regex patterns for detection, organized by language and category
- **`references/severity-matrix.md`** -- Canonical severity mapping used by all PR cleanliness commands and agents
