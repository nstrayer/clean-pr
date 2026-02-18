# Plan: Add Cross-Codebase Analysis to `/check`

## Context

The `check` and `fix` commands currently only analyze the git diff -- they never read surrounding code. This means they miss issues like duplicated functions, reimplemented utilities, and pattern divergence that can only be detected by comparing new code against the existing codebase. We're enhancing `check` to perform this cross-codebase analysis.

## Approach: New `codebase-analyzer` Agent

Create a new agent rather than extending `pattern-scanner`, because:
- `fix` depends on `pattern-scanner` staying fast and focused on mechanically fixable issues
- Cross-codebase findings require human judgment and shouldn't be auto-fixable
- The analysis approach is fundamentally different (search codebase vs scan diff lines)

The `check` command will invoke both agents: `pattern-scanner` for diff noise, then `codebase-analyzer` for cross-codebase issues.

## Changes

### 1. New file: `agents/codebase-analyzer.md`

New agent that performs three analyses on the diff:

**Duplicate/similar functions** (Warning) -- For each new function/class definition in the diff, search the codebase for existing functions with similar names or signatures. Use `Grep` to find candidates, `Read` to compare bodies. Only report when there's meaningful overlap (similar name AND similar logic), not just name collisions.

**Reimplemented utilities** (Warning) -- When the diff adds utility-like code (debounce, retry, deep clone, formatDate, etc.), search for existing utility directories (`**/utils/**`, `**/helpers/**`, `**/lib/**`, `**/common/**`, `**/shared/**`) and imported libraries that already provide the functionality.

**Pattern divergence** (Info) -- Compare coding patterns in new code (error handling, async style, naming conventions) against the dominant patterns in the same directory/module. Only report when the codebase has a clear majority (>70%) and the new code diverges.

Key rules:
- Conservative -- false positives are worse than missed findings for judgment-requiring issues
- Skip for trivial PRs (fewer than 3 new definitions)
- Exclude test files, generated files, and vendor directories from search
- Don't flag intentional wrappers around existing utilities

Follows the same frontmatter/body structure as `agents/pattern-scanner.md`.

### 2. Modify: `commands/check.md`

- Rename current Step 3 to "3. Scan for Anti-Patterns" for clarity
- Add new **Step 4: Cross-Codebase Analysis** that invokes `codebase-analyzer` via Task tool
- Current Step 4 (Produce Report) becomes Step 5
- Add "Cross-Codebase Findings" section to the report template with tables for duplicates, reimplemented utilities, and pattern divergence
- Add guideline: skip cross-codebase analysis for greenfield projects (<5 files)

### 3. Modify: `skills/pr-cleanliness/references/severity-matrix.md`

Add three rows to the matrix:

| Finding Type | Severity | Notes |
|---|---|---|
| Duplicated function/class replicating existing codebase functionality | Warning | New definition closely mirrors an existing implementation |
| Reimplemented utility when existing helper or library is available | Warning | Custom implementation of functionality already available in the project |
| Pattern divergence from established codebase conventions | Info | New code uses a different pattern than the codebase majority (>70% threshold) |

Add interpretation rule: "Cross-codebase findings (duplicates, reimplemented utilities, pattern divergence) are never Error severity."

Add `agents/codebase-analyzer.md` to the "Used by" list.

### 4. Modify: `skills/pr-cleanliness/SKILL.md`

- Add new category "### 6. Codebase Integration" describing duplicate detection, utility overlap, and pattern divergence
- Add step to the Detection Approach list: "Check codebase integration"
- Add `agents/codebase-analyzer.md` to Additional Resources

### 5. Modify: `README.md`

Update the plugin structure tree to show the new agent file.

## Files

| File | Action |
|------|--------|
| `agents/codebase-analyzer.md` | Create |
| `commands/check.md` | Modify |
| `skills/pr-cleanliness/references/severity-matrix.md` | Modify |
| `skills/pr-cleanliness/SKILL.md` | Modify |
| `README.md` | Modify |

## What This Does NOT Change

- `fix` command -- remains scoped to `pattern-scanner` findings only. Cross-codebase findings require human judgment and aren't mechanically fixable.
- `pattern-scanner` agent -- unchanged, keeps its diff-only focus.
- `split` command -- unchanged.

## Verification

1. Run `/clean-pr:check` on a branch that has a duplicated function -- verify the report includes a "Potential Duplicates" finding with file:line references to both the new and existing code
2. Run `/clean-pr:check` on a clean branch -- verify it reports no cross-codebase issues (doesn't invent findings)
3. Run `/clean-pr:fix` -- verify it still only acts on pattern-scanner findings, not cross-codebase findings
