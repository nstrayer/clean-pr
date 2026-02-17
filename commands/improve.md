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

# Plugin Self-Improvement

Analyze the clean-pr plugin's own source files and apply improvements to its detection patterns, commands, and overall capabilities. Combines automated gap analysis with optional user-directed improvements.

## Workflow

### 1. Read Plugin Source

Read all plugin files to understand current capabilities:

- `.claude-plugin/plugin.json` -- manifest
- `skills/pr-cleanliness/SKILL.md` -- core skill
- `skills/pr-cleanliness/references/anti-patterns.md` -- detection patterns
- `skills/pr-cleanliness/references/severity-matrix.md` -- canonical severity policy
- `commands/*.md` -- all commands
- `agents/*.md` -- all agents

### 2. Parse User Input

If an argument was provided, treat it as the user's description of what to improve. Examples:

- `"add Swift patterns"` -- add Swift-specific anti-patterns to the detection catalog
- `"improve the split command's dependency analysis"` -- refine the split command workflow
- `"add detection for Python f-string debugging"` -- add a specific anti-pattern

If no argument was provided, skip to automated analysis.

### 3. Analyze Coverage Gaps

For each area, identify what is missing or could be improved:

**Anti-Pattern Detection**:
- Are there common anti-patterns not covered in `references/anti-patterns.md`?
- Are regex patterns accurate and comprehensive?
- Are there language-specific patterns missing for commonly used languages?
- Are severity levels appropriate and consistent with `skills/pr-cleanliness/references/severity-matrix.md`?

**Command Workflows**:
- Are command instructions clear and complete?
- Are there edge cases not handled?
- Could any workflow steps be more efficient?
- Are the allowed-tools lists minimal and correct?

**Agent Capabilities**:
- Are agent triggering conditions specific enough?
- Is the system prompt comprehensive?
- Are there scenarios the agent should handle but does not?

**Skill Content**:
- Is the SKILL.md lean enough (target: 1,500-2,000 words)?
- Are reference files comprehensive?
- Is the progressive disclosure balance right?

### 4. Build Unified Improvement Plan

Combine user input and automated findings into a prioritized plan.

If the user provided input, list those suggestions first:

```markdown
# Improvement Plan

## From Your Input
1. [User-requested improvement with specific file references]

## From Automated Analysis
### High Priority
1. [Suggestion with specific file and line references]

### Medium Priority
1. [Suggestion]

### Low Priority / Ideas
1. [Suggestion]
```

If no user input was provided, only show the automated analysis sections.

### 5. Propose Changes

For each planned improvement, show a before/after preview of the change.

Classify each change as:

- **Trivial**: Single-line, mechanical change (e.g., fixing a typo in a regex, adding a language label)
- **Non-trivial**: New sections, rewritten content, structural changes, new anti-patterns with complex regexes

For non-trivial changes, ask for explicit confirmation before applying:
```
I have N proposed improvements. The following are non-trivial and need confirmation:

1. anti-patterns.md: Add new Swift detection section (lines 120+)
2. SKILL.md: Rewrite progressive-disclosure section (lines 45-62)

Apply which? (e.g., "1,2", "all", or "none")
```

Trivial changes can be applied after a brief preview, but still require a final confirmation gate (see step 6).

### 6. Apply Confirmed Changes

After confirmation:

1. Apply only the changes the user approved (by number or "all").
2. Use Edit for targeted modifications to existing content.
3. Use Write only when creating new sections or files.
4. Process changes file-by-file.
5. Only modify files within the plugin directory.
6. Before writing any files, show a final summary of what will be changed and ask for a go-ahead. Do not auto-apply without this gate, even for trivial changes.

### 7. Commit

After changes are applied:

1. Stage specific modified files: `git add` only the files that were changed
2. Ask the user to confirm the commit before creating it.
3. Create a single commit with a descriptive conventional-commit message (e.g., `feat: add Swift anti-pattern detection`, `fix: correct regex for Python debug patterns`)
4. If no changes were applied, do not create a commit.

### 8. Summary Report

Output a summary:

```markdown
# Plugin Improvement Complete

## Changes Applied
- [List of changes made with file references]

## Changes Skipped
- [Any changes the user declined]

## Remaining Suggestions
- [Ideas not acted on this run]
```

### Important Guidelines

- Only modify files within the plugin directory.
- Always preview before applying; require confirmation for non-trivial changes.
- Stay within the plugin's PR cleanliness scope -- suggestions should be about PR cleanliness, not general code quality.
- If nothing needs improving and no user input was provided, say so and exit.
- When adding anti-patterns, follow the existing catalog format (regex, language labels, examples).
- Respect `skills/pr-cleanliness/references/severity-matrix.md` as the source of truth for severity levels.
- Create a single commit for all changes, not one per improvement.
