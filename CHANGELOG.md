# Changelog

Newest first. Every entry says what changed and why, in that order.

---

## 2026-08-19: method 1.2.0

Seven fixes, all found by using the method on the four real repos rather than by
reading it. Recording the causes because each one was invisible from the inside.

### kickoff: the POLICY import was left advisory
Adopting `brain-personal` and `brain-company` left their existing `CLAUDE.md`
untouched, correctly by the never-touch rule. But those files refer to
`common/POLICY.md` in prose, and a prose instruction is a request the model may
act on, while an `@` import is loaded by the harness every session regardless.
The outbound prohibition and the append-only rule were therefore sitting in the
weaker of the two categories, in the two repos where they matter most. Kickoff now
adds the single import line to an existing `CLAUDE.md` and changes nothing else.

### kickoff: no CLAUDE.md in a submodule-consumed repo
`brain-common` received its own `CLAUDE.md`, and it is mounted as a submodule in
both vaults. Claude Code discovers nested `CLAUDE.md` files as it reads files
beneath them, so `brain-common`'s roadmap would load into every vault session and
assert a goal unrelated to the task. Such repos now get every method file except
that one.

### gate-pause: resolve the owning repo, not the session root
The gate trusted `CLAUDE_PROJECT_DIR`, which in a session started above several
repos is the parent, not any repo. A PAUSE file in one repo would have been
invisible to a write into that repo from such a session. It now walks up from the
file being written, or from the working directory, to the nearest `.git`, and
still honours an ops-level sentinel as a global stop. Tested across both cases.

### settings: the env deny rule blocked its own template
`Read(**/.env.*)` matched `.env.example`, and a permissions deny always beats a
hook allow, so the hook's explicit exemption for template files never applied.
Narrowed to the three real variants.

### Scaffold CLAUDE.md: an unattended-job contract
Running a job previously meant pasting a forty-line prompt describing when to
stop. That contract now lives in the repo, so a job is one sentence. It names the
five conditions that warrant stopping and states that auto mode is safe, because
a PreToolUse deny holds in every permission mode.

### Hygiene checks eight and nine
Submodule drift, since a vault pointing at an old `brain-common` is following
rules that have since been revised and nothing else would report it. And stale
roadmaps, since `CLAUDE.md` imports `ROADMAP.md` and an out-of-date goal is worse
than no goal, being asserted as current every session.

### README: how to patch this repo
`method` denies commits to `main` in `brain-method` as well, so changing a gate
needs the branch and PR flow. Documented, along with the marketplace-then-plugin
refresh order and the fact that while editing a gate, the gate protecting you is
the last released one.

---

## 2026-08-19: gate-git 1.1.0

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

## 2026-08-19: method 1.0.0

Initial release. Six skills (kickoff, plan, ticket, verify, review, wrap), four
PreToolUse and PostToolUse gates, a repo scaffold, and a weekly hygiene routine.

No `version` field in `plugin.json` on purpose: with a git source, Claude Code
resolves the version from the commit SHA, so a push is a release.
