# START HERE

**Written for the assistant, not the human.** The human's whole job is to open Claude Code on
their project and say: *read START-HERE.md in `<the kit folder>` and follow it.* If you are that
assistant, this file tells you what to do, in what order, and what to say before you do it.

**Every step is optional and skipping is normal.** Skipping a step never ends the setup. When a
step is approved, do the whole step; do not confirm file by file. Say the limits once, near the
front, then stop repeating them: this kit enforces exactly four things through hooks, everything
else is advice, and no hook sees a browser, an MCP call, chat, or a shared folder.

**Say this before creating anything:** what will be created (a `.claude/` folder, a knowledge base,
a disposable `working/` folder, a few ignore and attribute lines), that nothing is pushed anywhere,
and that a session restart follows the install because rules and hooks load at session start.

## 0 · What you are installing

Two things with one boundary between them.

| | The harness | The knowledge base |
|---|---|---|
| holds | how the assistant works on this project | what is true about it, with evidence |
| made of | rules, skills, hooks, tools, settings under `.claude/` | Markdown pages with evidence headers |
| read by | the assistant, automatically, at session start or on a trigger | humans and assistants, on demand |
| test for inclusion | would the assistant get this wrong without it? | would this still be worth reading in a year? |

Volatile status lives in a third folder, `working/`, disposable and never committed. Durable facts
never share a folder with volatile status; that boundary is the design.

## 1 · Ask, in one message, with your best guess stated for each

Most of these cannot be read from the code. Guessing wrong makes everything downstream wrong.

| Question | Why it matters | If unanswered |
|---|---|---|
| **One repository, or several?** One means shape A: `.claude/` and `docs/knowledge-base/` committed inside it. Several, a solution or a platform, means shape B: a workspace folder above the clones holding `.claude/`, `knowledge-base/`, and `working/`, committed as its own repository | decides where everything lives | do not create anything; install locally only and say so |
| **Is this under version control?** | git log is the worklog; the diff checks and the Stop hook need it | offer `git init` with no remote; if declined, ask where to log and write the answer into the project rule |
| **Which branch is the real work on, per repository?** | the default branch is frequently not the trunk | measure it, section 2, and state what you measured |
| **Which branch does each environment run?** | decides whether a finding is a live incident or a reading | mark every severity "depends on reachability, not checked" |
| **Where is the tracker, and can you read it?** GitHub through `gh`, or Azure DevOps through its REST API with a token in an environment variable you name | `/work` reads items from it, `/board` proposes writes to it | note the gap; work from pasted text |
| **Is there a design source of truth?** | designs carry states the tickets never mention | note it as an unsurveyed source |
| **Is there a test suite, and does it run?** | if not, "the tests pass" is never available as evidence | check for test projects and say what you found |
| **Is there a way to see what is deployed?** a health endpoint reporting the commit, a tag, a file on the host | `/orient` step 4 | say git does not know what is on the server |
| **Who reads what the assistant writes, and in which languages?** | the reader paragraph in `writing.md` | keep the default: a mixed audience, English as a working second language |
| **Data posture: demo or production?** | in demo, hardening is a follow-up recorded as `demo-debt`; in production it blocks | assume production |
| **What is out of scope, and who else works in this code right now?** | other products on the same machine are not evidence about this one; two people building the same thing is the most expensive failure | draw the boundary narrowly; read three weeks of commits |

Then, if the human has questions about trackers and connectors: prefer a CLI or a REST API wrapped
in a skill over an MCP server. Tool schemas load into every session whether used or not; a stateless
request does not need a server.

## 2 · Measure before writing a word

Run these and record what they returned, with the date and the commit hash. They become the first
real content of the knowledge base, in `_investigations/<date>-setup/methodology.md`.

```bash
# every repository: is the default branch where the work is?
git fetch origin --prune
git for-each-ref --sort=-committerdate --format='%(refname:short)  %(committerdate:short)' refs/remotes/origin | head -10
git rev-list --count origin/<default>..origin/<busiest-branch>
git log --oneline --since="3 weeks ago" --all | wc -l          # who is active
git shortlog -sn --since="3 months ago" --all | head           # concentration, as a property of the code
git ls-files --cached --others --exclude-standard | grep -Ei '(\.test\.|\.spec\.|Tests?\.(cs|java|py|ts)$|/__tests__/|/tests?/)' | head
git ls-files | grep -Ei 'appsettings.*\.json|\.env$|\.pem|\.pfx|\.p12|\.key$'   # committed that should not be
```

Reconnaissance, without reading every file: the package manifests (`package.json`, `*.csproj`,
`go.mod`, `pyproject.toml`, `pom.xml`); framework fingerprints; entry points (`main.*`, `Program.cs`,
`index.*`, `cmd/`); the top two levels of the tree; tooling and CI configs (`.github/workflows/`,
`azure-pipelines*.yml`, lint and format configs, `Dockerfile`); the build command and how long it
takes; the test command and what it reports.

## 3 · Install

From the kit folder, into the project or the workspace root:

```bash
bash <kit>/.claude/tools/install.sh <target> --shape A
bash <kit>/.claude/tools/install.sh <target> --shape B --repos <folder containing the clones>
```

Or on Windows without Git Bash: `powershell -File <kit>\.claude\tools\install.ps1 -Target <dir> -Shape A`.

The installer copies `.claude/` without overwriting anything, writes `settings.json` with hook
commands for this operating system (or `settings.kit.json` beside an existing one, to merge by
hand), creates `working/README.md`, the knowledge-base skeleton, the ignore and attribute lines,
and for shape B the `.workspace` marker. It ends by running `verify.sh`.

**Then tell the human to start a new session.** Rules and hooks load at session start. On one
build they were observed to hot-load; do not rely on it.

## 4 · Write the project rule

`.claude/rules/<project>.md`, always loaded, under 100 lines. It carries the facts a fresh session
would otherwise get wrong, dated and re-checkable by command:

- **The one fact that matters most.** Usually where the work actually is, or which branch is live.
- **Repositories and branches:** the branch model, the trunk per repository, what each environment
  runs, the pull request target, what is gated by policy and what is not.
- **Running it:** the build command, the start command, the test command, and how long each takes.
- **Verify:** what `.claude/tools/verify.project.sh` runs; write that script from the commands
  above, so `verify.sh --full` runs the project's own checks.
- **Deployed-state check:** the command or endpoint, and what it returns.
- **Tracker:** kind, organisation and project, the token variable name (never the value), and the
  fields, states, and custom fields measured from real items.
- **Data posture** and any project additions to the confirm-before list.
- **Terms:** one name per concept, from the code.

Then replace the reader paragraph in `writing.md`; copy `codex-relay.json.example` to
`.claude/codex-relay.json` if the codex CLI is present; and as traps appear, append them to
`working-here.md` with symptom, mechanism, fix, and date.

## 5 · The first knowledge-base pages

From the measurements in section 2, write `00-orientation/start-here.md` with a proper header and
the five facts that save the most confusion; fill `index.md` with a row per page and the sections
that are empty and why; seed `99-pending.md` with everything already noticed; write
`what-we-do-not-know.md` from the `known_gaps` headers. Leave a section empty rather than
speculative. Everything written here follows `.claude/rules/knowledge-base.md`.

## 6 · Prove the guards can go red

```bash
bash .claude/tools/verify.sh            # all green
bash .claude/tools/verify.sh --hooks    # every hook fired by hand, both shells
bash .claude/tools/verify.sh --canary   # must FAIL; a runner that passes it is lying
```

Copy `.github/workflows/verify.yml` from the kit into the project's workflows if it uses GitHub
Actions, so a stale or broken harness cannot merge.

## 7 · Acceptance tests

Run these and report the results honestly. Do not report a pass you did not observe.

| # | Test | Passes when |
|---|---|---|
| 1 | in a fresh session, ask a question the always-loaded rules answer, without letting the assistant read a file first | it answers from context. If it goes and looks, the rules are not loading |
| 2 | touch a file under the knowledge base | the path-scoped rule's content becomes available; before touching, it was not |
| 3 | try to write a fake but well-formed token through the editing tool | blocked, exit 2, message naming the kind and not the value |
| 4 | try to write `const password = process.argv[2]` | not blocked |
| 5 | delete an assertion from a test file and end a turn | the Stop hook blocks and names the file |
| 6 | `verify.sh` on a healthy tree | all pass, exit 0 |
| 7 | break one thing on purpose: remove a hook file, add rule lines past the baseline | the matching check fails and the message says what to do |
| 8 | run `verify.sh` from a different directory and from `/` | same result; no confident failures about a workspace that is fine |
| 9 | shape B: move the clones and update `.workspace` | everything still resolves |
| 10 | pick three knowledge-base claims at random and re-derive them from the cited evidence | all three check out, or are corrected on the spot |
| 11 | grep the knowledge base for a corrected claim, by symbol | no survivors |
| 12 | read any page's `known_gaps` | it names something real that was not checked |
| 13 | `git check-ignore -q working/probe`, and look for `working/.git` | ignored, and either no repository of its own or one with no remote. In shape A a plain `git -C working remote -v` shows the enclosing repository's remote, which is not a failure |
| 14 | read the knowledge-base README | it names the shape that was chosen, and why |
| 15 | after a compaction, continue a task with a brief in `working/<task>/brief.md` | the brief is back in context without anyone re-planning |
| 16 | `/goal` with the verify command as the condition | the session keeps checking after each turn until it passes |
| 17 | `/board` told to "just close it" | it proposes and stops; nothing is written that turn |

## 8 · How a session runs from here

```
/orient    where things stand, in five lines. Then STOP and let the human choose.
/work      intake, understand, one yes, route, build, the review menu, hand back.
/record    durable findings into the knowledge base, with evidence and what was NOT checked.
99-pending everything noticed and not acted on: one line, same turn.
/handoff   session state to a file in working/, so it survives compaction and Monday.
```

## 9 · The limits, once

The hooks see the editing tools and the two shells, nothing else. Nothing here has been shown by
comparison to help; the measurements behind the kit are one maintainer's, on Windows, and are dated
in its knowledge base. A harness that claims more protection than it has is the exact failure it
exists to catch, so write your own limits down the same way, in the project's `99-pending.md`.
