#!/usr/bin/env bash
# gate-pause.sh — PreToolUse gate on write tools and Bash.
#
# The second brain has a PAUSE sentinel: a file whose presence means every
# loop stops immediately and writes nothing. Until now that rule lived only in
# prompts, which means a model that never read the prompt carefully could
# ignore it. This makes it structural.
#
# Checks, in order: the project root, then $SB_OPS, then a sibling brain-ops
# beside the project, since a cross-repo session may be started anywhere.
set -uo pipefail

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s}}\n' \
    "$(printf '%s' "$1" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))')"
  exit 0
}

input="$(cat)"

fields="$(printf '%s' "$input" | python3 -c '
import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    print("\t")
    sys.exit(0)
ti = d.get("tool_input") or {}
print((d.get("tool_name") or "") + "\t" + (ti.get("command") or "").replace("\n", " "))
' 2>/dev/null)"

tool="${fields%%$'\t'*}"
cmd="${fields#*$'\t'}"

root="${CLAUDE_PROJECT_DIR:-$PWD}"

found=""
for candidate in "$root/PAUSE" "${SB_OPS:-}/PAUSE" "$root/../brain-ops/PAUSE"; do
  [[ "$candidate" == "/PAUSE" ]] && continue
  if [[ -e "$candidate" ]]; then
    found="$candidate"
    break
  fi
done

[[ -z "$found" ]] && exit 0

reason="The PAUSE sentinel exists at $found, so nothing may be written. This is deliberate, not an error: someone stopped this system on purpose. Report that you stopped because of PAUSE and do nothing else. Removing the sentinel is the owner's decision alone."

# Write tools are blocked outright.
case "$tool" in
  Edit|Write|NotebookEdit) deny "$reason" ;;
esac

# For Bash, block the commands that change state. A read-only command is fine,
# because diagnosing why the system is paused is legitimate work while paused.
if printf '%s' "$cmd" | grep -Eq '(^| )(git +(commit|push|merge|rebase|reset|checkout +-b|switch +-c|tag)|rm|mv|cp|tee|truncate|install|npm +(install|publish)|pip +install|clasp +push)( |$)'; then
  deny "$reason"
fi
if printf '%s' "$cmd" | grep -Eq '(>|>>)[[:space:]]*[^[:space:]&|]'; then
  deny "$reason"
fi

exit 0
