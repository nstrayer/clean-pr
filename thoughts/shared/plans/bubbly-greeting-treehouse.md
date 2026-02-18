# Plan: Update `/clean-pr:improve` to accept user input and make changes

## Context

The improve command is currently read-only -- it analyzes the plugin's own source and outputs a report of suggestions. The user wants it to:
1. Accept user input describing what they think could be improved
2. Still run automated analysis alongside user input
3. Actually make the changes (with confirmation) rather than just reporting

## Files to modify

- `commands/improve.md` -- rewrite with new frontmatter, workflow, and guidelines
- `README.md` -- update command table (line 43) and "Improving the plugin" section (lines 47-63)

## Changes

### 1. `commands/improve.md` -- rewrite

**Frontmatter updates:**
- Add `argument-hint: "[what to improve]"` for optional free-text user input
- Expand `allowed-tools` to include Bash, Write, Edit, and Task (matching the fix command pattern)
- Update description to reflect write capability

```yaml
---
name: improve
description: Analyze and apply improvements to the clean-pr plugin itself, guided by automated analysis and optional user input
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Task
argument-hint: "[what to improve]"
---
```

**New workflow (8 steps):**

1. **Read Plugin Source** -- same as current (read all plugin files)
2. **Parse User Input** -- if an argument was provided, treat it as the user's description of what to improve. Examples: "add Swift patterns", "improve the split command's dependency analysis"
3. **Analyze Coverage Gaps** -- same automated analysis as current, covering anti-patterns, commands, agents, and skill content
4. **Build Unified Improvement Plan** -- combine user input and automated findings into a prioritized plan. User suggestions listed first under "From Your Input"; automated findings under "From Automated Analysis". If no user input, only show automated findings.
5. **Propose Changes** -- show before/after previews for each planned change. Classify as trivial (single-line, mechanical) or non-trivial (new sections, rewritten content, structural changes). Require explicit confirmation for non-trivial changes.
6. **Apply Confirmed Changes** -- apply only approved changes using Edit/Write. Process file-by-file.
7. **Commit** -- stage specific files, create a single commit with a descriptive conventional-commit message. No commit if nothing changed.
8. **Summary Report** -- list changes applied, changes skipped, and any remaining suggestions.

**Updated guidelines:**
- Only modify files within the plugin directory
- Always preview before applying; require confirmation for non-trivial changes
- Stay within the plugin's PR cleanliness scope
- If nothing needs improving and no user input, say so
- When adding anti-patterns, follow existing catalog format (regex, language labels, examples)
- Respect severity-matrix.md as the source of truth
- Single commit for all changes

### 2. `README.md` -- update two sections

**Line 43** -- update command table entry:
```
| `/clean-pr:improve` | Analyze and apply improvements to this plugin itself |
```

**Lines 45-63** -- update the paragraph about all commands accepting `[base-branch]` and rewrite the "Improving the plugin" section:
- Note that improve accepts `[what to improve]` instead of `[base-branch]`
- Remove "The improve command is read-only" statement
- Update workflow to reflect the new analyze-and-apply behavior

## Verification

1. Run `/clean-pr:improve` with no arguments -- should analyze and offer to apply changes
2. Run `/clean-pr:improve "add a missing pattern"` -- should incorporate user input into the plan
3. Confirm that previews are shown before changes are applied
4. Confirm that declining all changes results in no commit
