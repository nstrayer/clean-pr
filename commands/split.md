---
name: split
description: Suggest how to decompose a large or unfocused PR into smaller, focused PRs
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Task
argument-hint: "[base-branch]"
---

# PR Split Recommendation

Analyze the current branch's changes and recommend how to decompose them into smaller, focused PRs. This command produces a plan only -- it does not modify git history or create branches.

## Workflow

### 1. Determine Base Branch

If an argument is provided, use it as the base branch name. Otherwise:

1. Try `gh pr view --json baseRefName -q .baseRefName 2>/dev/null`
2. Fall back to `main` or `master` via `git rev-parse --verify`
3. If neither works, ask the user

Then resolve the base branch to its remote tracking ref following the **Base Branch Detection** procedure in `${CLAUDE_PLUGIN_ROOT}/skills/pr-cleanliness/SKILL.md`. Use the resolved `<ref>` (typically `origin/<base>`) for all subsequent git commands.

### 2. Gather Information

Run these commands, using `<ref>` (the resolved ref from step 1):

```bash
# List of commits on this branch
git log <ref>...HEAD --oneline --no-merges

# Changed files with stats
git diff <ref>...HEAD --stat

# Full diff for analysis
git diff <ref>...HEAD --name-status

# Commit details to understand groupings
git log <ref>...HEAD --format="%h %s" --no-merges
```

### 3. Analyze Change Groupings

Identify logical groupings by examining:

1. **By commit message**: Group commits with related messages (e.g., all "fix:" commits, all "feat:" commits, all "refactor:" commits)
2. **By directory/module**: Group files by their parent directory or module
3. **By dependency**: Determine which changes depend on other changes (e.g., a utility function that a feature uses)
4. **By type**: Separate infrastructure/config changes from feature code from tests

### 4. Propose Split Plan

Output a structured recommendation:

```markdown
# PR Split Recommendation

**Current PR**: N files, +X/-Y lines, M commits
**Recommendation**: Split into K PRs

## Proposed PRs

### PR 1: [Title] (land first)
**Purpose**: [What this PR accomplishes]
**Files**:
- `path/to/file1.ts` (lines relevant to this concern)
- `path/to/file2.ts`

**Commits that map here**:
- `abc1234` - commit message
- `def5678` - commit message

**Dependencies**: None (base PR)

---

### PR 2: [Title] (land after PR 1)
**Purpose**: [What this PR accomplishes]
**Files**:
- `path/to/file3.ts`
- `path/to/file4.ts`

**Commits that map here**:
- `111aaaa` - commit message

**Dependencies**: PR 1 (uses utility added there)

---

### PR 3: [Title] (independent)
**Purpose**: [What this PR accomplishes]
**Files**:
- `path/to/file5.ts`

**Commits that map here**:
- `222bbbb` - commit message

**Dependencies**: None (can land independently)

## Landing Order

1. PR 1 - [Title] (no dependencies)
2. PR 3 - [Title] (no dependencies, can land in parallel with PR 1)
3. PR 2 - [Title] (depends on PR 1)

## Notes

- [Any caveats about the split]
- [Files that touch multiple concerns and may need careful splitting]
```

### 5. Handling Edge Cases

- **Already focused PR**: If the PR is already well-scoped (single concern, reasonable size), say so. Do not force a split.
- **Tightly coupled changes**: If changes cannot be meaningfully separated (every file depends on every other), note this and suggest the PR is already as small as it can be.
- **Single large file**: If most changes are in one file, the split may need to be by logical section rather than by file. Note this.
- **Shared dependencies**: When two proposed PRs both need a utility, recommend putting the utility in the first PR.

### Important Guidelines

- This command ONLY produces a recommendation. Do not create branches, cherry-pick commits, or modify git state.
- Be practical -- a split that creates 10 tiny PRs is worse than 2-3 focused ones.
- Consider review burden: each PR should be reviewable in one sitting.
- Account for CI/test dependencies: each proposed PR should be independently testable.
- If commits are well-organized, the split may map cleanly to commit boundaries. If commits are messy (multiple concerns per commit), note that interactive rebase may be needed.
