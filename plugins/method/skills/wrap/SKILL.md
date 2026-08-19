---
name: wrap
description: Close a working session properly: update the changelog and version index, mark tickets, append decisions, and write the session state to disk so the next run starts informed instead of guessing. Use at the end of any session that changed files, before you stop for the day, or when a session is about to run out of context. Trigger on "wrap up", "we're done", "before I stop", "write this down", or when context is nearly full.
disable-model-invocation: true
---

# Wrap

Version 1.0.0

Remote sessions are amnesiac. Anything not written to a file is gone, and next week's session will rediscover it slowly and possibly wrongly. This skill is the cost of that fact.

## Step 1. Changelog

Append to `CHANGELOG.md`, newest first. In `brain-common` this file carries a version index table; update the row for every file you touched and bump its version.

Semver as used here:
- **patch** — a bug fixed, no behaviour anyone relied on has changed
- **minor** — new behaviour, existing behaviour intact
- **major** — something that worked before now works differently

Every entry says what changed and **why**, in that order. An entry that only lists files is a `git log` with extra steps.

## Step 2. Tickets and decisions

1. For each ticket worked on, update `Status:` to `open`, `done` or `abandoned`. Do not mark `done` unless the done test was actually observed to pass, and name where it was observed.
2. Append to `DECISIONS.md` any choice made during the session that a future reader would otherwise re-litigate, with the reason. Append only. Never edit or delete an existing decision; a reversal is a new entry that supersedes.

## Step 3. Session state

Write or overwrite `.claude/SESSION.md`:

```markdown
# Session state
Updated: <YYYY-MM-DD HH:MM>

## Where things stand
<Three sentences maximum. What is true now that was not true this morning.>

## In flight
<Work started and not finished, with the file paths and the exact next action.>

## Blocked on
<What needs the owner, a credential, or an external party. Name who or what.>

## Do not do
<Anything a reasonable next session would try that turns out to be wrong,
 and why. This section prevents the most wasted time of any in this file.>

## Next action
<One line. The single thing to do first next time.>
```

This is the only file in the method that is rewritten rather than appended. It describes the present, so history is not useful; the changelog holds that.

## Step 4. Report, do not commit

Show the diff summary and stop. The owner commits. Committing on their behalf removes the one review checkpoint that catches a bad session.

## Never

- Never write outbound text: no email, no message, no post, not even a draft.
- Never mark a ticket done because the work looks finished. Done means the done test was observed.
- Never invent a version number for a file you did not open.
- Never let `SESSION.md` grow into a diary. If it is over 30 lines, the changelog is being neglected.
