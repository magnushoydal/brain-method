#!/usr/bin/env bash
# post-edit-shellcheck.sh — PostToolUse, after Edit or Write.
#
# Blocks nothing: the edit already happened. Exits 2 when it has something to
# say, because on PostToolUse that is the only exit code whose stderr reaches
# the model. Exit 0 stderr goes to the debug log and is never seen.
set -uo pipefail

input="$(cat)"

path="$(printf '%s' "$input" | python3 -c '
import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    print("")
    sys.exit(0)
ti = d.get("tool_input") or {}
print(ti.get("file_path") or ti.get("path") or "")
' 2>/dev/null)"

[[ -z "$path" || ! -f "$path" ]] && exit 0

case "$path" in
  *.sh) ;;
  *.bash) ;;
  *)
    # Also lint extensionless files with a bash or sh shebang.
    if ! head -n 1 "$path" 2>/dev/null | grep -Eq '^#!.*/(ba)?sh'; then
      exit 0
    fi
    ;;
esac

out=""

# Syntax first. A parse error makes shellcheck output noise, so stop here.
if ! syntax="$(bash -n "$path" 2>&1)"; then
  printf 'bash -n failed on %s:\n%s\n' "$path" "$syntax" >&2
  exit 2
fi

if command -v shellcheck >/dev/null 2>&1; then
  if ! out="$(shellcheck --severity=warning --format=gcc "$path" 2>&1)"; then
    printf 'shellcheck findings in %s (warning and above):\n%s\n' "$path" "$out" >&2
    exit 2
  fi
fi

# Two things shellcheck does not flag but this method cares about.
notes=""
if ! head -n 5 "$path" | grep -q 'set -'; then
  notes+="  - no 'set -euo pipefail' near the top; a failing command will be ignored silently"$'\n'
fi
if grep -Eq 'date -Iseconds|sha256sum' "$path"; then
  notes+="  - uses date -Iseconds or sha256sum, neither of which exists on macOS; use the sb-lib.sh shims"$'\n'
fi

if [[ -n "$notes" ]]; then
  printf 'method notes on %s:\n%s' "$path" "$notes" >&2
  exit 2
fi

exit 0
