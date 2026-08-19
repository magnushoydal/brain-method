---
name: plan
description: Produce a written plan before touching any file: the files that change, the smallest clean implementation, the user-visible effect, the risks, how it will be verified, and what is deliberately left out. Use this before any change that touches more than one file or more than about twenty lines, and whenever the request is a goal rather than an instruction. Trigger on "plan this", "how would you", "before you start", or any request to build, refactor, migrate or fix something non-trivial.
---

# Plan

Version 1.0.0

Plan mode exists so the assignment gets shaped before the work starts. A plan that arrives after the edits is a report.

## Step 0. Refuse to plan in the dark

Read, in this order, and say so if any is missing:

1. `CLAUDE.md`, and anything it imports
2. `ROADMAP.md`, specifically the current goal
3. `REVIEW.md`
4. The actual files you believe will change, not your memory of them

If the request does not serve the current goal in `ROADMAP.md`, say that plainly in one line before the plan. Do not refuse to plan; the owner may be deliberately going sideways. But name it.

## Step 1. The six sections

Output exactly these, in this order, and nothing else:

1. **Files that change.** Real paths. If you are not sure a file exists, check rather than list it hopefully.
2. **Smallest clean implementation.** The version a reviewer can hold in their head. If you find yourself proposing a framework, you have skipped a step.
3. **What the user or operator experiences.** For an ops repo this is often "a new event type appears in the spool" rather than a screen.
4. **Risks.** Each risk paired with what it would look like when it happens. A risk with no symptom is decoration.
5. **How we verify.** Concrete commands or observations, not "test it". This becomes the input to `/method:verify`.
6. **Deliberately out of scope for this pass.** The most useful section. Name what you are not doing so it cannot be smuggled in later.

## Step 2. Stop

End with a single question asking for approval or changes. Then stop. No edits, no file creation, no `git` writes, not even a scratch file.

## Sizing rule

If the plan lists more than five files, or the implementation section needs more than about fifteen lines to describe, the ticket is too big. Say so and propose the split rather than planning the whole thing. Two clean passes beat one plan nobody can review.

## Failure modes

| Failure | What to do instead |
|---|---|
| Planning from memory of the codebase | Read the files. Every time |
| A risk section listing "bugs" | Name the specific thing that breaks and how it surfaces |
| Verification section saying "run the tests" | Name the command and the expected output |
| Quietly widening scope while planning | Put the extra work in section 6 and leave it there |
| Starting to edit because the plan felt obvious | Obvious plans are the ones that turn out to be wrong. Stop and ask |
