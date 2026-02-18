# Project Guidelines

A Claude Code plugin that analyzes PRs for noise (debug artifacts, formatting changes, scope creep, mixed concerns) and helps clean them up. Not a traditional codebase -- all logic lives in markdown files that orchestrate Claude's tools.

## Architecture

```
commands/       Entry points for user-facing slash commands (/check, /fix, /split, /improve)
agents/         Task-delegated sub-agents invoked via Task tool from commands
skills/         Domain knowledge base (SKILL.md + reference files)
thoughts/       Planning docs -- committed alongside implementation
.claude-plugin/ Plugin manifest (plugin.json) and marketplace metadata
```

**Data flow**: User runs command -> command orchestrates git/grep/read -> delegates to agents via Task tool -> agents scan diff and codebase -> command formats report.

## File Conventions

- All commands/agents use YAML frontmatter (`name`, `description`, `allowed-tools`, optionally `model`, `color`, `argument-hint`)
- `${CLAUDE_PLUGIN_ROOT}` resolves to the plugin directory at runtime -- use it in all cross-references
- Commands handle user interaction (AskUserQuestion, confirmation gates); agents do analysis and return structured findings
- Only `fix` and `improve` have write access (Edit/Write in their tool lists); `check` and `split` are read-only

## Sources of Truth

- **Severity**: `skills/pr-cleanliness/references/severity-matrix.md` is the single canonical severity mapping. Never define severity locally in commands or agents.
- **Anti-patterns**: `skills/pr-cleanliness/references/anti-patterns.md` is the detection catalog. Add new patterns here, not inline in agents.
- **Base branch detection**: Procedure defined in `skills/pr-cleanliness/SKILL.md` under "Base Branch Detection". All commands reference this.

## Key Rules

- Always diff against `origin/<base>` (not local `<base>`) to match what GitHub sees
- Only flag added/modified lines (`+` prefix in diffs) -- never flag existing unchanged code
- Debug artifacts in test files are Info, not Error (except credentials)
- `console.error`/`console.warn` are legitimate logging -- not debug artifacts
- Cross-codebase findings (duplicates, reimplemented utilities, pattern divergence) are never Error severity and always require user confirmation before fixing

## Workflow

- Commit plan files (in `thoughts/`) alongside their corresponding implementation commits
- After making plugin changes, run `./update-version.sh [patch|minor|major]` to bump the version in plugin.json (required for cache invalidation in other sessions)
- When adding anti-patterns, follow the existing catalog format: regex with `^\+` prefix, language labels, examples
- Keep SKILL.md lean (target 1,500-2,000 words) -- put detail in reference files
