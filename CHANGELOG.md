# Changelog

Newest first. Every entry says what changed and why, in that order.

---

## 2026-08-19 — gate-git 1.1.0

### Added: commit to a protected branch is now denied
Found by using the method on its first real repo. Adopting `brain-ops` produced
a commit on `main`, and only the *push* was blocked. The result was work sitting
on a protected branch that then had to be pushed by hand, which is precisely the
state the rule was written to prevent. A guardrail that fires one step too late
converts a clean refusal into a rescue operation.

`gate-git.sh` now denies `git commit` while `HEAD` is on `main` or `master`,
before anything is written. `git add` and `git status` remain allowed, so
staging and inspection are unaffected.

Deliberately not added as a `permissions.deny` rule in the scaffold settings.
`Bash(git commit:*)` cannot express "only on main", so a deny rule would block
every commit everywhere. The hook can read the branch; a static rule cannot.
This is one of the cases where the hook is the only enforcement available, and
the reason hooks exist alongside permissions rather than duplicating them.

## 2026-08-19 — method 1.0.0

Initial release. Six skills (kickoff, plan, ticket, verify, review, wrap), four
PreToolUse and PostToolUse gates, a repo scaffold, and a weekly hygiene routine.

No `version` field in `plugin.json` on purpose: with a git source, Claude Code
resolves the version from the commit SHA, so a push is a release.
