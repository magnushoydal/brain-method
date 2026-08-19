---
name: review
description: Review the current changes against the repo's REVIEW.md and sort every finding into must fix, should fix, or okay to ship, flagging anything that needs human eyes. Use after /method:verify and before anything is committed or merged, and whenever asked to look over a diff, a pull request or a finished change. Trigger on "review this", "look over", "is this ready", "check my work", or any request for a second opinion on a change.
---

# Review

Version 1.0.0

When building gets fast, judgement becomes the bottleneck. This skill is the judgement step, and it is deliberately unkind to its own earlier work.

## Step 1. Read the standard, then the diff

1. Read `REVIEW.md`. It is the standard. If the repo has none, say so and review against `CLAUDE.md` plus the sections below, then recommend running `/method:kickoff` to create one.
2. `git status` and `git diff` for uncommitted work, or `git diff main...HEAD` on a branch.
3. Read the full current version of every changed file, not only the diff. Most real defects live in the interaction between the new lines and the old ones, which a diff hides by construction.

## Step 2. Sort every finding

Exactly three buckets. No fourth bucket, no "nitpick" escape hatch.

- **Must fix**: it is wrong, unsafe, loses data, breaks a documented contract, or violates `POLICY.md`.
- **Should fix**: it works but will cost someone later: unclear naming, a silent failure path, a missing log line, duplicated logic.
- **Okay to ship**: noted and deliberately accepted. Say why it is acceptable.

Each finding gets a file path and a line reference. A finding without a location is an opinion.

## Step 3. Flag for human eyes

State explicitly whether the change touches any of these, and stop short of approving if it does:

- Credentials, tokens, or anything under a `restricted` classification
- Anything that sends, publishes, deletes or writes outside the repo
- Append-only data: evidence logs, the event spool, the manifest
- Money, deadlines, or a public body's correspondence
- Production data, or a live path with no dry run

## Step 4. Verdict

One line: ready for human review, needs another pass, or do not ship. Then the counts per bucket.

## Failure modes

| Failure | What to do instead |
|---|---|
| Reviewing your own work generously | Assume the author was in a hurry, because they were |
| Style opinions in "must fix" | Style belongs in should fix, or in a rules file so it stops being an opinion |
| Approving because the tests passed | Tests prove the paths someone thought of. Read the ones nobody did |
| Silence on the append-only rule | Any diff that edits an existing evidence entry is a must fix, always |
| A long list with no verdict | Sort, count, and commit to a verdict. An unsorted list is work handed back |
