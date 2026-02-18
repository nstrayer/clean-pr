# clean-pr

A Claude Code plugin that analyzes and cleans up PRs to be minimal, focused, and easy for humans to review.

## Install

1. In Claude Code, open the plugin menu by typing `/plugin`
2. Select **Marketplaces** and then **Add marketplace**
3. Enter `nstrayer/clean-pr` as the path
4. When prompted, confirm to install the `clean-pr` plugin

The plugin loads automatically every session after this -- no flags or config needed.

## Contributing

Clone the repo anywhere on your machine and add your local checkout as a plugin source:

```bash
# Clone to any directory you prefer -- the path here is just an example
git clone https://github.com/nstrayer/clean-pr.git ~/dev/clean-pr-plugin
```

Then in Claude Code, register your local checkout as a marketplace:

1. Type `/plugin` to open the plugin menu
2. Select **Marketplaces** and then **Add marketplace**
3. Enter the path to your local clone (e.g., `~/dev/clean-pr-plugin`)
4. When prompted, confirm to install the `clean-pr` plugin

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

## Usage

Start with `/clean-pr:check`. It analyzes your branch's diff and produces a report with a **Next Steps** section that tells you what to do:

```
/clean-pr:check              # analyze the current branch
/clean-pr:check develop      # analyze against a specific base branch
```

Based on the findings, check will suggest:

- **`/clean-pr:fix`** -- if there are auto-fixable issues (debug artifacts, formatting noise, scope creep). Fix reads the check report from the conversation, so it must be run after check.
- **`/clean-pr:split`** -- if the PR has mixed concerns or exceeds size thresholds. Produces a decomposition plan (no git changes).
- **Manual review** -- for cross-codebase findings (duplicates, reimplemented utilities, pattern divergence) that require human judgment.

## Commands

| Command | Purpose |
|---------|---------|
| `/clean-pr:check` | Analyze the current branch's diff and produce a cleanliness report with next steps |
| `/clean-pr:fix` | Clean auto-fixable issues found by check, with patch preview and confirmation |
| `/clean-pr:split` | Suggest how to decompose a large PR into smaller focused PRs |
| `/clean-pr:improve` | Analyze and apply improvements to this plugin itself |

`check` and `split` accept an optional `[base-branch]` argument. If omitted, they auto-detect the base from the GitHub PR or fall back to `main`/`master`. `fix` gets its base branch from the check report. `improve` accepts an optional `[what to improve]` argument.

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
│   ├── codebase-analyzer.md                     # Cross-codebase analysis agent
│   └── pattern-scanner.md                       # Diff scanning agent
└── skills/
    └── pr-cleanliness/
        ├── SKILL.md                             # Core PR cleanliness knowledge
        └── references/
            └── anti-patterns.md                 # Detection patterns by language
```
