# clean-pr

A Claude Code plugin that analyzes and cleans up PRs to be minimal, focused, and easy for humans to review.

## Install

Add the plugin marketplace and install:

```
/plugin marketplace add nstrayer/clean-pr
/plugin install clean-pr
```

The plugin loads automatically every session after this -- no flags or config needed.

## Contributing

Clone the repo and add your local checkout as a marketplace:

```bash
git clone https://github.com/nstrayer/clean-pr.git ~/dev/clean-pr-plugin
```

```
/plugin marketplace add ~/dev/clean-pr-plugin
/plugin install clean-pr
```

This points at your local files, so edits are reflected immediately. When you're happy with your changes, push to GitHub and open a PR.

### The `/clean-pr:improve` command

This command is built for contributors. It analyzes the plugin's own source files -- the skill, anti-pattern catalog, commands, and agents -- identifies gaps, and applies improvements directly:

- Missing anti-patterns or languages in the detection catalog
- Gaps in command workflows
- Stale or inaccurate regex patterns
- New feature ideas

You can optionally describe what you want improved (e.g., `/clean-pr:improve "add Swift patterns"`). The command combines your input with its own automated analysis, previews proposed changes, and applies them after confirmation.

### Typical workflow

1. Use the plugin on real PRs for a while
2. Run `/clean-pr:improve` to analyze and apply improvements, or pass a specific request
3. Review the proposed changes and confirm non-trivial edits
4. Test with `/clean-pr:check` on a branch with known issues

## Commands

| Command | Purpose |
|---------|---------|
| `/clean-pr:check` | Analyze the current branch's diff and produce a cleanliness report |
| `/clean-pr:fix` | Auto-remove debug artifacts and formatting noise from the branch |
| `/clean-pr:split` | Suggest how to decompose a large PR into smaller focused PRs |
| `/clean-pr:improve` | Analyze and apply improvements to this plugin itself |

The PR commands (`check`, `fix`, `split`) accept an optional `[base-branch]` argument. If omitted, they auto-detect the base branch from the GitHub PR or fall back to `main`/`master`. The `improve` command accepts an optional `[what to improve]` argument instead.

## Plugin structure

```
clean-pr-plugin/
├── .claude-plugin/
│   ├── plugin.json                              # Manifest
│   └── marketplace.json                         # Marketplace metadata
├── commands/
│   ├── check.md                                 # /clean-pr:check
│   ├── fix.md                                   # /clean-pr:fix
│   ├── split.md                                 # /clean-pr:split
│   └── improve.md                               # /clean-pr:improve
├── agents/
│   └── pattern-scanner.md                       # Diff scanning agent
└── skills/
    └── pr-cleanliness/
        ├── SKILL.md                             # Core PR cleanliness knowledge
        └── references/
            └── anti-patterns.md                 # Detection patterns by language
```
