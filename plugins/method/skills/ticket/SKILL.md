---
name: ticket
description: Turn a vague intention into one small written assignment with a visible finish line, saved to specs/ as a numbered file. Use whenever work is described loosely ("make X better", "we should fix Y", "add Z"), whenever a plan needs to be split into passes, or before starting any change that will take more than one sitting. Trigger on "write a ticket", "spec this", "break this down", or any request whose finish line is not already stated.
---

# Ticket

Version 1.0.0

One task. One finish line. One reviewable change. A ticket that cannot be finished in a single focused pass is two tickets.

## Step 1. Find the number

`ls specs/` and take the next free three-digit number. Never reuse a number, even for an abandoned ticket. The gap is information.

## Step 2. Write `specs/NNN-short-slug.md`

```markdown
# NNN — <imperative title, under ten words>

- Status: open
- Created: <YYYY-MM-DD>
- Serves: <the ROADMAP goal this advances, or "sideways: <reason>">

## Why now
<Two sentences. What is worse today because this does not exist.>

## Done test
<One check, phrased so the answer is yes or no with no interpretation.
 Not "the sensor works". Rather "a mail event with kind=invoice appears in
 brain-ops/events with amount and due populated from the attachment".>

## In scope
- <bullet>

## Out of scope
- <bullet, and be generous here>

## Verification
<The commands or observations that prove the done test. Feeds /method:verify.>

## Notes
<Anything the next session needs and cannot infer.>
```

## The done test is the whole point

If you cannot phrase the done test as a yes or no check, the ticket is not ready and neither is your understanding of it. Say so and ask one clarifying question rather than writing a soft target like "improve" or "clean up".

## Step 3. Stop

Report the path and the done test. Do not start the work. Do not commit.

## Never

- Never write a ticket with more than one done test. Split it.
- Never put a solution in the ticket. The ticket says what must become true; `/method:plan` decides how.
- Never mark a ticket done yourself. Status changes are the owner's, or `/method:wrap`'s after the owner confirms.
