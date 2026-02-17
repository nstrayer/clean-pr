# clean-pr

A Claude Code plugin that analyzes and cleans up PRs to be minimal, focused, and easy for humans to review.

## Setup

### Install locally

Clone the repo and load the plugin with `--plugin-dir`:

```bash
git clone <repo-url> ~/dev/clean-pr-plugin
claude --plugin-dir ~/dev/clean-pr-plugin
```

This loads the plugin for the current session. You'll need to pass `--plugin-dir` each time you start a new session.

### Enable for a project

Add the plugin to a project's `.claude/settings.json` so it loads automatically when working in that repo:

```json
{
  "enabledPlugins": {
    "clean-pr@local": true
  }
}
```

You'll still need to use `--plugin-dir` to point Claude Code to the plugin directory.

### Enable globally

Add the same entry to `~/.claude/settings.json` to enable across all projects.

## Commands

| Command | Purpose |
|---------|---------|
| `/clean-pr:check` | Analyze the current branch's diff and produce a cleanliness report |
| `/clean-pr:fix` | Auto-remove debug artifacts and formatting noise from the branch |
| `/clean-pr:split` | Suggest how to decompose a large PR into smaller focused PRs |
| `/clean-pr:improve` | Suggest improvements to this plugin itself |

All PR commands accept an optional `[base-branch]` argument. If omitted, they auto-detect the base branch from the GitHub PR or fall back to `main`/`master`.

## Improving the plugin

The `/clean-pr:improve` command is for contributors working on this plugin. It reads the plugin's own source files -- the skill, anti-pattern catalog, commands, and agent -- and suggests concrete improvements:

- Missing anti-patterns or languages in the detection catalog
- Gaps in command workflows
- Stale or inaccurate regex patterns
- New feature ideas

### Workflow

1. Use the plugin on real PRs for a while
2. Run `/clean-pr:improve` to get a prioritized list of suggestions
3. Pick a suggestion and implement it
4. Test with `/clean-pr:check` on a branch with known issues

The improve command is read-only -- it never modifies files, just reports what could be better.


## Plugin structure

```
clean-pr-plugin/
├── .claude-plugin/
│   └── plugin.json                           # Manifest
├── commands/
│   ├── check.md                              # /clean-pr:check
│   ├── fix.md                                # /clean-pr:fix
│   ├── split.md                              # /clean-pr:split
│   └── improve.md                            # /clean-pr:improve
├── agents/
│   └── pattern-scanner.md                    # Diff scanning agent
└── skills/
    └── pr-cleanliness/
        ├── SKILL.md                          # Core PR cleanliness knowledge
        └── references/
            └── anti-patterns.md              # Detection patterns by language
```
