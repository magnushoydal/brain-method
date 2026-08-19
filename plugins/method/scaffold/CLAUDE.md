# {{REPO_NAME}}

{{ONE_SENTENCE_PURPOSE}}

## Authority

{{POLICY_IMPORT}}
@ROADMAP.md
@REVIEW.md

Where this file and POLICY.md disagree, POLICY.md wins. Where this file and a
`.claude/rules/` file disagree, the rules file wins for the paths it covers.

## How to work here

- Plan before building. Use `/method:plan` for anything past a one-line change.
- One ticket at a time. `specs/NNN-*.md` holds the assignment and its done test.
- Verify before review: `/method:verify`, then `/method:review`.
- End sessions with `/method:wrap`. Session state lives in `.claude/SESSION.md`,
  not in anyone's memory.
- Work on `claude/`-prefixed branches. Never commit to `{{DEFAULT_BRANCH}}`.

## Non-negotiable

- Never write outbound text: no email, message, post or draft. Surface the
  situation, the options, and a recommendation. The owner writes the words.
- Never send, publish, share, upload or delete anything.
- Append-only data stays append-only. A correction is a new entry.
- Show a diff and ask before any write touching more than five files.
- If `PAUSE` exists, stop and report that you stopped.

## Commands

{{BUILD_COMMANDS}}

## Running a job unattended

When a task is given as a job rather than a conversation, run it end to end and
report once at the end. Do not ask for confirmation between steps.

Stop and ask only when one of these is true:

- a hook denied something and you believe the denial is wrong
- git reports a conflict, a rejected push, or a detached HEAD
- an instruction in the job contradicts what you find in the repo
- the next step would need a credential, or would touch anything the review
  standard marks as needing human eyes
- you would have to guess at something the owner has an opinion about

Otherwise: create a `claude/`-prefixed branch, do the work, verify it, commit on
the branch, push, open a pull request with `gh pr create --fill`, and report the
URL. Never merge. Merging is the owner's review checkpoint and the reason the
rest of this can run unattended.

Auto mode is safe for these jobs. A `PreToolUse` deny holds in every permission
mode, so the guardrails apply whether or not approvals are switched off.
