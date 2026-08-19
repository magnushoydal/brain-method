#!/usr/bin/env bash
# gate-git.sh — PreToolUse gate on the Bash tool.
#
# Denies: pushing to a protected branch, force pushing, deleting a branch,
# deleting a tag, and hard-resetting a protected branch.
#
# Contract: reads the hook JSON on stdin, prints a permissionDecision of
# "deny" on stdout when it objects, and exits 0 otherwise. Exit 0 is not
# approval; the normal permission flow still runs.
#
# Deliberately does not use the hook `if` filter: that filter fails open when
# a command cannot be parsed, and this gate must see every Bash call.
set -uo pipefail

PROTECTED_RE='^(main|master)$'

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s}}\n' \
    "$(printf '%s' "$1" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))')"
  exit 0
}

input="$(cat)"

# jq is not guaranteed to be installed, so parse with python3, which is.
cmd="$(printf '%s' "$input" | python3 -c '
import json,sys
try:
    d = json.load(sys.stdin)
except Exception:
    print("")
    sys.exit(0)
ti = d.get("tool_input") or {}
print(ti.get("command") or "")
' 2>/dev/null)"

[[ -z "$cmd" ]] && exit 0
case "$cmd" in
  *git*) ;;
  *) exit 0 ;;
esac

# Current branch, if we are inside a work tree at all.
branch=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
fi

# Normalise: collapse whitespace so patterns below stay readable.
flat="$(printf '%s' "$cmd" | tr '\n' ' ' | tr -s ' ')"

# 1. Force push, in any spelling.
if printf '%s' "$flat" | grep -Eq 'git +push[^;&|]*(--force|--force-with-lease|--force-if-includes| -f( |$))'; then
  deny "Force push blocked by the method guardrail. Force pushing rewrites published history, which cannot be recovered from a clone. If this is genuinely needed, run it yourself outside Claude Code."
fi

# 2. Deleting a remote ref, either spelling.
if printf '%s' "$flat" | grep -Eq 'git +push[^;&|]*(--delete| :[A-Za-z0-9._/-]+)'; then
  deny "Deleting a remote ref is blocked by the method guardrail. Do it yourself if you mean it."
fi

# 3. Deleting a branch or tag.
if printf '%s' "$flat" | grep -Eq 'git +branch[^;&|]* -(d|D)( |$)'; then
  deny "Branch deletion is blocked by the method guardrail. Claude does not tidy up branches; a branch you forgot about is cheaper than one you needed."
fi
if printf '%s' "$flat" | grep -Eq 'git +tag[^;&|]* -d( |$)'; then
  deny "Tag deletion is blocked by the method guardrail."
fi

# 4. Pushing to a protected branch, whether named explicitly or implied by HEAD.
if printf '%s' "$flat" | grep -Eq 'git +push'; then
  target=""
  # An explicit refspec: git push origin main, git push origin HEAD:main
  if [[ "$flat" =~ git[[:space:]]+push[^\;\&\|]*[[:space:]]([A-Za-z0-9._/-]+)[[:space:]]+([A-Za-z0-9._/-]*:)?([A-Za-z0-9._/-]+) ]]; then
    target="${BASH_REMATCH[3]}"
  fi
  # "git push -u origin HEAD" pushes the current branch, so HEAD must resolve
  # to it rather than being treated as a branch named HEAD.
  [[ "$target" == "HEAD" || -z "$target" ]] && target="$branch"
  if [[ -n "$target" ]] && printf '%s' "$target" | grep -Eq "$PROTECTED_RE"; then
    deny "Pushing to '$target' is blocked by the method guardrail. Work on a claude/ branch and let the owner merge. If you believe this push is correct, say so and let them run it."
  fi
fi

# 5. Hard reset while on a protected branch.
if printf '%s' "$flat" | grep -Eq 'git +reset[^;&|]*--hard'; then
  if [[ -n "$branch" ]] && printf '%s' "$branch" | grep -Eq "$PROTECTED_RE"; then
    deny "git reset --hard on '$branch' is blocked by the method guardrail. Uncommitted work would be unrecoverable."
  fi
fi

exit 0
