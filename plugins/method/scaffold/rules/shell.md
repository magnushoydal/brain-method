---
description: Conventions for shell scripts in this repo
paths: ["**/*.sh", "**/*.bash"]
---

# Shell rules

- `#!/usr/bin/env bash` and `set -euo pipefail` at the top. Every script.
- macOS is the target. `date -Iseconds` and `sha256sum` do not exist there. Use
  the shims in `sb-lib.sh` rather than reinventing them.
- Quote every expansion. Filenames contain spaces, parentheses and quotes.
- Iterate with `find -print0` and `while IFS= read -r -d ''`, never `for f in $(ls)`.
- Anything that writes gets a `--dry-run` flag, and the dry run must be the
  documented first step.
- Exit codes are a contract: 0 success, 1 usage error, 2 precondition failed,
  3 partial failure with the input quarantined. Do not invent new ones silently.
- Never `trap ... EXIT` inside a function that is called in a command
  substitution. The trap belongs to the subshell and fires immediately. This
  bug has already cost a day once.
- Log to stderr, data to stdout. A script whose output is parsed must not print
  progress on stdout.
