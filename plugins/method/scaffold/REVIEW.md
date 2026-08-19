# Review standard

This is what `/method:review` judges against. Keep it short enough to be read
every time.

## Must fix

- Loses data, or makes existing data unrecoverable
- Writes outbound text, or sends, publishes, uploads or deletes anything
- Edits an append-only record instead of appending a superseding entry
- Touches credentials, tokens, or `restricted` content
- Breaks a documented contract: the event schema, a script's exit codes, a
  file format another component parses
- Fails silently. A failure nobody sees is worse than a crash
- Commits to the default branch, or force pushes
- Hard-codes a path, account or token that differs between personal and company

## Should fix

- Duplicated logic that will drift, particularly across the two brains
- A name that will read as wrong in six months
- Missing log line at a decision point
- No dry-run path for something that writes
- Error handling that catches everything and reports nothing
- A magic number with no comment explaining where it came from

## Okay to ship

- Cosmetic inconsistency that a rules file will catch later
- A `TODO` with a name and a reason
- Verbose but clear code

## Always needs human eyes

Money, deadlines, correspondence from a public body, anything in a vault's
append-only directories, and any change to the guardrail scripts themselves.

## The question that decides borderline cases

If this fails at 03:10 with nobody watching, how would I find out, and what
would it have cost by then? If the answer is "I would not find out", it is a
must fix regardless of which bucket it looks like.
