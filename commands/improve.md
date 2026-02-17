---
name: improve
description: Suggest improvements to the clean-pr plugin itself by analyzing its detection patterns and capabilities
allowed-tools:
  - Read
  - Grep
  - Glob
---

# Plugin Self-Improvement

Analyze the clean-pr plugin's own source files and suggest improvements to its detection patterns, commands, and overall capabilities. This command is for plugin maintainers who have the plugin installed locally and want to iterate on it.

## Workflow

### 1. Read Plugin Source

Read all plugin files to understand current capabilities:

- `.claude-plugin/plugin.json` -- manifest
- `skills/pr-cleanliness/SKILL.md` -- core skill
- `skills/pr-cleanliness/references/anti-patterns.md` -- detection patterns
- `skills/pr-cleanliness/references/severity-matrix.md` -- canonical severity policy
- `commands/*.md` -- all commands
- `agents/*.md` -- all agents

### 2. Analyze Coverage Gaps

For each area, identify what is missing or could be improved:

**Anti-Pattern Detection**:
- Are there common anti-patterns not covered in `references/anti-patterns.md`?
- Are regex patterns accurate and comprehensive?
- Are there language-specific patterns missing for commonly used languages?
- Are severity levels appropriate and consistent with `references/severity-matrix.md`?

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

### 3. Suggest Improvements

Output a structured list of suggestions:

```markdown
# Plugin Improvement Suggestions

## High Priority
1. [Suggestion with specific file and line references]
2. [Suggestion]

## Medium Priority
1. [Suggestion]
2. [Suggestion]

## Ideas for New Features
1. [Feature idea with rationale]
2. [Feature idea]

## Anti-Pattern Gaps
1. [Missing pattern with suggested regex]
2. [Missing pattern]
```

### Important Guidelines

- This is a read-only analysis command. Do not modify any files.
- Be specific: reference exact files and line numbers when suggesting changes.
- Prioritize suggestions by impact on review quality.
- Focus on practical improvements, not theoretical ones.
- Consider the plugin's scope -- suggestions should be about PR cleanliness, not general code quality.
- If the plugin is in good shape, say so. Do not invent suggestions.
