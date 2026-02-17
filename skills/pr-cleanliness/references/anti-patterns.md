# Anti-Pattern Catalog

Comprehensive catalog of patterns to detect when scanning PR diffs for cleanliness issues. Organized by category with regex patterns for detection.

**Convention**: All regex patterns include the `^\+` prefix for matching added lines in unified diff output. Apply these patterns against raw diff output to only flag new/modified code.

## Debug Artifacts

### Console/Print Statements

**JavaScript/TypeScript:**
```
^\+.*console\.(log|debug|warn|error|info|trace|dir|table|time|timeEnd)\(
```

**Python:**
```
^\+.*\bprint\(
^\+.*\bpprint\(
^\+.*\blogging\.(debug|info)\(  # Only when clearly temporary
```

**Go:**
```
^\+.*fmt\.Print(ln|f)?\(
^\+.*log\.Print(ln|f)?\(
```

**Rust:**
```
^\+.*println!\(
^\+.*dbg!\(
^\+.*eprintln!\(
```

**Java/Kotlin:**
```
^\+.*System\.out\.print(ln)?\(
^\+.*System\.err\.print(ln)?\(
```

**Ruby:**
```
^\+.*\bputs\b
^\+.*\bp\b\s
^\+.*\bpp\b\s
```

### Debugger Statements

```
^\+.*\bdebugger\b
^\+.*\bbinding\.(pry|irb)\b
^\+.*import\s+pdb
^\+.*pdb\.set_trace\(\)
^\+.*breakpoint\(\)
^\+.*import\s+ipdb
^\+.*ipdb\.set_trace\(\)
^\+.*__import__\(['"]pdb['"]\)
^\+.*byebug\b
```

### TODO/FIXME Comments (New in PR)

Only flag TODOs that appear in added lines (the `+` prefix in diffs):

```
^\+.*\b(TODO|FIXME|HACK|XXX|TEMP|TEMPORARY)\b
```

**Important**: Distinguish between existing TODOs (context lines) and newly added TODOs (added lines). Only flag newly added ones.

### Commented-Out Code

Detect multi-line commented-out code blocks (not documentation comments):

```
^\+\s*//\s*(if|for|while|return|const|let|var|function|class|import)\b
^\+\s*#\s*(if|for|while|return|def|class|import)\b
^\+\s*/\*[\s\S]*?(if|for|while|return)\b[\s\S]*?\*/
```

**Heuristic**: A comment containing code keywords (if, for, return, function, class) on 3+ consecutive lines is likely commented-out code rather than documentation. To detect this, apply the per-line regex patterns above and then check for 3+ consecutive matching lines in the diff output.

### Temporary/Test Values

```
^\+.*\b(test123|asdf|qwerty|foo|bar|baz)\b  # In non-test files
^\+.*password\s*=\s*["'][^"']+["']
^\+.*api[_-]?key\s*=\s*["'][^"']+["']
^\+.*secret\s*=\s*["'][^"']+["']
^\+.*token\s*=\s*["'][^"']+["']
```

## Formatting Noise

### Whitespace-Only Changes

In a unified diff, lines where the only change is whitespace:

```
# Lines that differ only in leading/trailing whitespace
# Lines that differ only in tab vs space
# Lines that differ only in line endings
```

**Detection approach**: For each modified hunk, compare the `-` and `+` lines after stripping whitespace. If they match, it is a whitespace-only change.

### Import Reordering

Detect when import blocks are reordered without adding or removing imports:

```
# Compare set of imports in old vs new
# If same set, different order -> formatting noise
```

**Detection approach**: Extract all import statements from removed and added lines in a hunk. If the sets are identical, the change is pure reordering.

### Blank Line Changes

```
# Hunks where the only difference is added/removed blank lines
# In code not otherwise modified
```

## Scope Creep

### Unrelated Renames

Detect variable/function renames in files not otherwise meaningfully changed:

**Detection approach**: If a file's diff consists entirely of identifier renames (same structure, different names), and the file is not part of the PR's core changes, flag as scope creep.

### Unrelated Type Annotations

```
^\+.*:\s*(string|number|boolean|int|str|float|bool)\b  # In otherwise unchanged lines
```

**Detection approach**: If added lines only add type annotations to existing code (no behavioral changes), flag in files outside the PR's core scope.

### Drive-By Refactors

**Signals**:
- Function extraction in files not related to the PR
- Pattern changes (callbacks to promises, loops to map/filter) in untouched code
- Style changes (single quotes to double quotes, semicolons) across the codebase

### Unrelated Dependency Changes

```
# Changes in package.json, requirements.txt, go.mod, Cargo.toml
# Where the changed dependency is not used by any file in the PR
```

## Size Thresholds

### Line Count Guidelines

| Size | Lines Changed | Review Difficulty |
|------|--------------|-------------------|
| Small | < 100 | Easy - single reviewer |
| Medium | 100-400 | Moderate - focused review |
| Large | 400-800 | Hard - consider splitting |
| Very Large | > 800 | Split strongly recommended |

### File Count Guidelines

| Files | Assessment |
|-------|------------|
| 1-5 | Focused |
| 6-15 | Moderate |
| 16-30 | Likely needs splitting |
| 30+ | Almost certainly needs splitting |

### Contextual Adjustments

- **Generated code**: Exclude auto-generated files from size counts (migrations, snapshots, lockfiles)
- **Test files**: Weight test changes less heavily (tests supporting a feature are expected)
- **Configuration**: Config file changes are typically low-review-effort
- **Renames/moves**: Git rename detection means pure renames have minimal review cost

## Language-Specific Patterns

### JavaScript/TypeScript

Additional patterns to watch for:
- `any` type annotations added as shortcuts
- `@ts-ignore` or `@ts-expect-error` added
- `eslint-disable` comments added
- `as unknown as` type assertions

### Python

Additional patterns:
- `type: ignore` comments added
- `noqa` comments added
- `pass` statements in non-empty blocks
- `# pragma: no cover` added

### Go

Additional patterns:
- `//nolint` comments added
- Unused imports (will cause build failure)
- `_` variable assignments hiding errors

### Rust

Additional patterns:
- `#[allow(...)]` attributes added
- `unwrap()` calls in non-test code
- `todo!()` or `unimplemented!()` macros
