---
name: kickoff
description: Set up or adopt a repository as a Claude Code workspace with the standard method files (CLAUDE.md, ROADMAP.md, REVIEW.md, DECISIONS.md, CHANGELOG.md, .claude/rules, .claude/settings.json, specs/). Use this at the very start of any new project, and also when an existing repo has never had the method applied. Trigger on "set this repo up", "new project", "adopt this repo", "give this repo a brain", or any first session in a repo with no CLAUDE.md.
disable-model-invocation: true
---

# Kickoff

Version 1.0.0

Two modes. Decide which one applies before writing anything.

- **fresh** — the repo has no `CLAUDE.md`. Create the full set.
- **adopt** — the repo already has structure and possibly a `CLAUDE.md`. Add only what is missing. Never restructure.

Detect the mode yourself. Do not ask which one unless the answer is genuinely ambiguous.

## Rule that overrides everything else in this skill

**Never move, rename or reorganise an existing file or directory.** Two brains of different shapes use this method. The method is the files listed below and nothing more. If an existing repo puts its docs in `docs/` and its code in `apps/`, that is correct for that repo and none of your business.

## Step 1. Read before writing

1. `ls -a` the repo root, and read any existing `CLAUDE.md`, `README.md`, `ROADMAP.md`, `REVIEW.md`.
2. Check for `common/POLICY.md` (a `brain-common` submodule). If present, it is the authority on agent behaviour and `CLAUDE.md` must import it rather than restate it.
3. Check `git remote -v` and the default branch name.
4. Check for a `PAUSE` file.

## Step 2. Ask exactly four things, once

Only ask for what you cannot infer from step 1:

1. What is this repo for, in one sentence.
2. Who or what consumes its output.
3. The current goal, meaning the next thing that has to be true.
4. The definition of done for that goal, phrased so it can be checked rather than argued about.

If the repo is one of `brain-personal`, `brain-company`, `brain-common` or `brain-ops`, you can answer 1 and 2 yourself from the repo contents. Ask only 3 and 4.

## Step 3. Write the files

Copy from `${CLAUDE_PLUGIN_ROOT}/scaffold/` and fill in the placeholders. In adopt mode, write only files that do not already exist, and for each one that does, report what you left alone.

| Target | From scaffold | Notes |
|---|---|---|
| `CLAUDE.md` | `CLAUDE.md` | Keep under 40 lines. Add the `@common/POLICY.md` import line only if that path exists |
| `ROADMAP.md` | `ROADMAP.md` | The current goal and its done test. One goal, not a wish list |
| `REVIEW.md` | `REVIEW.md` | The standard `/method:review` judges against |
| `DECISIONS.md` | `DECISIONS.md` | Append-only. Seed it with any decision made during this kickoff |
| `CHANGELOG.md` | `CHANGELOG.md` | Only if absent. `brain-common` already has one; do not create a second |
| `.claude/rules/*.md` | `rules/*.md` | Copy only the rules that match languages actually present in the repo |
| `.claude/settings.json` | `settings.json` | If the file exists, merge keys instead of overwriting. Never drop existing keys |
| `specs/.gitkeep` | n/a | Empty directory for tickets |

`.claude/settings.json` is the file that makes the method arrive automatically in cloud sessions, because cloud runs read repo settings rather than the local machine's. Getting this file wrong is the one failure that makes unattended routines run without guardrails, so verify it parses as JSON before you finish.

## Step 4. Report, then stop

Print a table of files created, files skipped and why, and the current goal as written. Then stop. Do not begin work on the goal in the same session. Kickoff sets the desk up; it does not start the job.

## Never

- Never commit. Leave the working tree dirty so the owner reads the diff.
- Never write a `.env`, a token, or any credential into a scaffolded file.
- Never copy `POLICY.md` content into `CLAUDE.md`. Import it or reference it.
- Never create `/customers` or `/demos`. They belong to a product workflow, not this one.
