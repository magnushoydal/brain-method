# brain-method

A Claude Code plugin marketplace with one plugin, `method`: a single repeatable
way of building and maintaining projects, so every repo and every session starts
from the same instructions instead of the same explanation.

Public on purpose. It contains no secrets, which is what lets repositories under
two different GitHub accounts consume it without credential juggling, and lets
cloud routine sessions resolve it with no authentication at all.

## Install

```
/plugin marketplace add magnushoydal/brain-method
/plugin install method@magnus-method
```

Per repository, the method arrives automatically once `.claude/settings.json`
declares it. `/method:kickoff` writes that file. This matters because cloud
sessions do not read your local settings; they read the repo.

## The six skills

| Skill | Job |
|---|---|
| `/method:kickoff` | Scaffold a new repo, or adopt an existing one without restructuring it |
| `/method:plan` | Six-section plan before any edit: files, implementation, effect, risks, verification, out of scope |
| `/method:ticket` | One assignment in `specs/NNN-*.md` with a yes-or-no done test |
| `/method:verify` | Syntax, repo checks, dry run, one real path, logs and a failure case |
| `/method:review` | Must fix, should fix, okay to ship, against `REVIEW.md` |
| `/method:wrap` | Changelog, ticket status, decisions, and session state onto disk |

`kickoff` and `wrap` are marked `disable-model-invocation`, so only you trigger
them. They have side effects; the other four do not.

## The four gates

Hooks, not instructions. A `PreToolUse` gate that denies cannot be reasoned
around, and holds in every permission mode.

| Script | Denies |
|---|---|
| `gate-git.sh` | push to main or master, force push, remote ref deletion, branch or tag deletion, hard reset on a protected branch |
| `gate-secrets.sh` | reads and writes of credential paths, environment dumps, keychain access. Allows `.env.example` |
| `gate-pause.sh` | every write, and every state-changing shell command, while a `PAUSE` sentinel exists |
| `post-edit-shellcheck.sh` | nothing. Reports `bash -n`, shellcheck and two macOS portability traps back into context after a shell edit |

Test a gate by hand before trusting it:

```bash
printf '{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}' \
  | plugins/method/scripts/gate-git.sh
```

A `deny` decision on stdout means the gate is live. Silence means it allowed the
call, which is not the same as approving it.

## What this deliberately does not do

No `/customers` or `/demos` directories, no browser preview loop, no product
workflow. Those belong to shipping a SaaS product, which is not what these repos
are. No copies of `POLICY.md`: the scaffolded `CLAUDE.md` imports it.

## Layout

```
.claude-plugin/marketplace.json     the catalog
plugins/method/
  .claude-plugin/plugin.json        the manifest, deliberately with no version
  skills/<name>/SKILL.md            six skills
  hooks/hooks.json                  four gates
  scripts/*.sh                      the gate implementations
  scaffold/                         files kickoff copies into a repo
routines/weekly-hygiene.md          the routine prompt to paste into claude.ai
```

`plugin.json` has no `version` field on purpose. With a git source and no
declared version, Claude Code uses the resolved commit SHA, so a push is a
release and there is no version field to forget to bump.

## Patching this repo

`method` now denies commits to `main`, and it applies to this repository too. So
changing a gate follows the same flow as any other change, which is the point:

```bash
cd ~/Developer/brain-method
git checkout -b claude/<what-changed>
# edit, then let Claude commit and push the branch and open the PR
gh pr merge <n> --squash --delete-branch
```

Then refresh the installed copy, in this order, because the plugin is served from
the marketplace's local clone rather than fetched separately:

```
/plugin marketplace update magnus-method
/plugin update method@magnus-method
```

Verify the new version is the one running:

```bash
ls ~/.claude/plugins/cache/*/method/
```

The directory name is the commit SHA. If it is not the SHA you just merged, the
refresh did not land and the old gates are still the live ones. Old version
directories are left behind on purpose and are harmless.

One consequence worth stating plainly: while you are editing a gate on a branch,
the gate protecting you is the last released one, not the one in your working
tree. Test a gate by piping fake hook JSON into the script directly rather than
by trying to trigger it through Claude.
