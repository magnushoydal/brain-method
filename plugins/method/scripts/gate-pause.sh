#!/usr/bin/env bash
# gate-pause.sh: PreToolUse gate on write tools and Bash.
#
# The second brain has a PAUSE sentinel: a file whose presence means every
# loop stops immediately and writes nothing. Until now that rule lived only in
# prompts, which means a model that never read the prompt carefully could
# ignore it. This makes it structural.
#
# Resolving which root to check is the subtle part. CLAUDE_PROJECT_DIR is the
# directory the session started in, which in a multi-repo session is the parent
# of every repo rather than any one of them. So the primary lookup walks up from
# the file being written, or from cwd, until it finds a .git. That is the repo
# that owns the write, whatever the session was rooted at.
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
    print("\t\t")
    sys.exit(0)
ti = d.get("tool_input") or {}
cmd = (ti.get("command") or "").replace("\n", " ").replace("\t", " ")
path = (ti.get("file_path") or ti.get("path") or ti.get("notebook_path") or "").replace("\t", " ")
print((d.get("tool_name") or "") + "\t" + cmd + "\t" + path)
' 2>/dev/null)"

tool="${fields%%$'\t'*}"
rest="${fields#*$'\t'}"
cmd="${rest%%$'\t'*}"
target_path="${rest#*$'\t'}"

# Walk up from a starting directory to the nearest repository root.
repo_root_of() {
  local d="$1"
  [[ -z "$d" ]] && return 1
  [[ -f "$d" ]] && d="$(dirname "$d")"
  while [[ "$d" != "/" && -n "$d" ]]; do
    if [[ -e "$d/.git" ]]; then
      printf '%s' "$d"
      return 0
    fi
    d="$(dirname "$d")"
  done
  return 1
}

roots=()
# The repo that owns the file being written, if a path was supplied.
if [[ -n "$target_path" ]]; then
  r="$(repo_root_of "$target_path" || true)"
  [[ -n "$r" ]] && roots+=("$r")
fi
# The repo the shell is sitting in.
r="$(repo_root_of "$PWD" || true)"
[[ -n "$r" ]] && roots+=("$r")
# The session root, which may be a repo itself.
[[ -n "${CLAUDE_PROJECT_DIR:-}" ]] && roots+=("$CLAUDE_PROJECT_DIR")
# The ops repo, wherever it lives, since it owns the sentinel for the whole system.
[[ -n "${SB_OPS:-}" ]] && roots+=("$SB_OPS")
for guess in "$PWD/../brain-ops" "${CLAUDE_PROJECT_DIR:-}/brain-ops" "${CLAUDE_PROJECT_DIR:-}/../brain-ops" "$HOME/Developer/brain-ops"; do
  [[ "$guess" == /brain-ops ]] && continue
  roots+=("$guess")
done

found=""
for candidate in "${roots[@]}"; do
  [[ -z "$candidate" ]] && continue
  if [[ -e "$candidate/PAUSE" ]]; then
    found="$candidate/PAUSE"
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
