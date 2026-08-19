---
name: verify
description: Check work the way a careful operator would before anyone reviews it: run the repo's own checks, lint shell, dry-run scripts, read logs, exercise the real path end to end, and report what was tested and what was not. Use immediately after any change and before /method:review. Trigger on "verify", "check it", "did that work", "test this", or the moment an edit is finished.
---

# Verify

Version 1.0.0

Doing the task and checking the task are two different jobs. This skill is the second one. It never fixes anything; it reports.

## Step 1. Establish what "verify" means for this repo

Look, do not assume:

- `ls` for `Makefile`, `package.json`, `*.sh` in `scripts/`, `*selftest*`, `.github/workflows/`
- If `sb-selftest.sh` exists, that is the primary check
- If the change touched Apps Script (`.gs`), the real check is the execution log after a manual run, not a local parse
- If the change touched markdown only, the check is that every link and every cited ID resolves

## Step 2. Run the layered checks

In this order, stopping to report rather than pushing past a failure:

1. **Syntax.** `bash -n` every changed `.sh`. `shellcheck` if installed. `python3 -m json.tool` every changed `.json`. `yq` or a parse of any changed frontmatter.
2. **Repo checks.** The selftest, the test suite, the linter, whatever step 1 found.
3. **Dry run.** Any script with a `--dry-run` flag gets run with it. Never run the live path first.
4. **The real path, once.** One real input through the actual pipeline, chosen to be cheap and reversible.
5. **Logs and failure paths.** Read the log the run produced. Then deliberately check one failure case: a missing file, an empty spool, a malformed input.

## Step 3. Report in this shape

```
Verified
- <check> → <result>

Not verified
- <thing> → <why not, and what it would take>

Surprises
- <anything that behaved differently from the plan>

Verdict: safe to review / needs another pass / broken
```

The **Not verified** section is mandatory and must never be empty. If you genuinely verified everything, say "nothing outstanding" explicitly rather than deleting the heading. An absent section reads as complete coverage, and that is the lie that costs the most.

## Never

- Never repair something you find. Report it. The owner decides whether the fix belongs in this pass.
- Never claim a check ran if it errored on startup. A missing binary is a "not verified", not a pass.
- Never verify by re-reading your own diff. Reading the code you just wrote proves nothing about whether it runs.
- Never run a live path against production data to prove a change works when a dry run would do.
