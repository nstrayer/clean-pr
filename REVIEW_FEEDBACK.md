# PR Cleanliness Plugin Review Feedback

Date: 2026-02-17

## Findings (Highest Severity First)

1. [P1] `fix` can accidentally discard intended code via whole-file checkout
   - Reference: `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/commands/fix.md:57`
   - Risk: `git checkout <base> -- <file>` is all-or-nothing. If a file is misclassified as formatting-only, real behavior changes can be silently removed.

2. [P1] Severity model is inconsistent across core docs
   - References:
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/agents/pattern-scanner.md:67`
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/commands/check.md:92`
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/skills/pr-cleanliness/SKILL.md:56`
   - Risk: The same issue type can be reported as `error` in one workflow and `warning` in another, reducing trust and making automation harder.

3. [P2] Logging guidance conflicts with regex catalog
   - References:
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/skills/pr-cleanliness/references/anti-patterns.md:13`
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/agents/pattern-scanner.md:100`
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/commands/fix.md:107`
   - Risk: The catalog flags `console.warn/error`, while scanner/fix rules say these are often legitimate. This increases false positives and potential over-cleaning.

4. [P2] Base branch fallback logic is inconsistent/incomplete
   - References:
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/skills/pr-cleanliness/SKILL.md:65`
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/commands/check.md:24`
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/commands/fix.md:26`
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/commands/split.md:24`
   - Risk: Repos using `develop` or `trunk` may fail fallback in commands even though the skill implies broader support.

5. [P2] `split` says "full diff" but collects only file status
   - Reference: `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/commands/split.md:39`
   - Risk: `git diff <base>...HEAD --name-status` is not a full diff, so split recommendations may miss line-level coupling and be less accurate.

6. [P3] Missing regression harness for pattern quality
   - References:
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/skills/pr-cleanliness/references/anti-patterns.md:1`
     - `/Users/nicholasstrayer/dev/ai/clean-pr-plugin/agents/pattern-scanner.md:41`
   - Risk: The plugin is pattern-heavy, but there is no fixture/evaluation layer to catch false positives/negatives over time.

## Open Questions

- Should `fix` default to "suggest patch and ask for confirmation" for any non-trivial edit?
- Should there be one canonical severity matrix shared by `SKILL.md`, `check`, and `pattern-scanner` to remove drift?

## Suggested Next Steps

1. Replace full-file checkout in `fix` with hunk-level revert and mandatory preview before apply.
2. Define a single severity mapping table and reference it from all command and agent docs.
3. Align logging patterns with policy (separate debug logging from intentional operational logging).
4. Standardize base branch detection into one reusable procedure used by `check`, `fix`, and `split`.
5. Add diff fixtures (clean vs noisy) and a simple pass/fail evaluation script for pattern regression checks.
