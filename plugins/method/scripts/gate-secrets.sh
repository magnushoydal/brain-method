#!/usr/bin/env bash
# gate-secrets.sh: PreToolUse gate on file tools and Bash.
#
# Denies reads and writes of credential-bearing paths, and Bash commands that
# would cat, grep or copy them. This is the enforcement half of the rule that
# POLICY.md states in prose: "never read credentials, keychains, browser
# profiles". A prose rule is a request; this is a gate.
#
# Allows .env.example and .env.sample, which exist precisely to be read.
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
path = ti.get("file_path") or ti.get("path") or ti.get("notebook_path") or ""
cmd = ti.get("command") or ""
print(path.replace("\t", " ") + "\t" + cmd.replace("\t", " ").replace("\n", " "))
' 2>/dev/null)"

path="${fields%%$'\t'*}"
cmd="${fields#*$'\t'}"

subject="$path $cmd"
[[ -z "${subject// /}" ]] && exit 0

# Explicitly permitted, checked before the deny list.
if printf '%s' "$path" | grep -Eq '\.env\.(example|sample|template)$'; then
  exit 0
fi

patterns=(
  # Left boundary is "start, or any character that cannot be part of a path
  # component", so a bare "cat .env" is caught as well as "/repo/.env".
  '(^|[^A-Za-z0-9._-])\.env($|[^A-Za-z])'
  '(^|[^A-Za-z0-9._-])\.envrc($|[^A-Za-z])'
  '(^|[^A-Za-z0-9._-])\.ssh/'
  '(^|[^A-Za-z0-9._-])id_(rsa|dsa|ecdsa|ed25519)($|[^A-Za-z])'
  '(^|[^A-Za-z0-9._-])\.aws/credentials'
  '(^|[^A-Za-z0-9._-])\.netrc($|[^A-Za-z])'
  '(^|[^A-Za-z0-9._-])\.git-credentials'
  'Library/Keychains/'
  '(^|[^A-Za-z0-9._-])\.config/gh/hosts\.yml'
  '(^|[^A-Za-z0-9._-])\.claude\.json($|[^A-Za-z])'
  '(^|[^A-Za-z0-9._-])restricted/'
  '\.(pem|p12|pfx|key|keystore)($|[^A-Za-z])'
  '(^|[^A-Za-z0-9._-])(client_secret|service[-_]account|credentials|token)[A-Za-z0-9._-]*\.json'
  '(^|[^A-Za-z0-9._-])secrets?\.(ya?ml|json|toml|env)'
)

for p in "${patterns[@]}"; do
  if printf '%s' "$subject" | grep -Eq "$p"; then
    deny "Blocked by the method credential guardrail: this touches a path matching '$p'. Credentials are never read, written or echoed by Claude in this workspace, including while debugging. If a value is needed, put it in an environment variable or a script property yourself and refer to it by name."
  fi
done

# Bash commands that would exfiltrate an environment wholesale.
if printf '%s' "$cmd" | grep -Eq '(^| )(env|printenv|set)( *\||$| +\|)' ; then
  deny "Dumping the whole environment is blocked by the method guardrail, because it prints tokens into the transcript. Read the one variable you need by name instead."
fi

if printf '%s' "$cmd" | grep -Eq 'security +(find-generic-password|find-internet-password|dump-keychain)'; then
  deny "Keychain access is blocked by the method guardrail."
fi

exit 0
