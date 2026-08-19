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
