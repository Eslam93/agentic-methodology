# Standing orders

How to work in a repository or workspace that carries this harness. Project facts (repositories,
branches, where the work actually is, the deployed-state check, the tracker, the data posture) live
in the project rule beside this file, written at setup. This file is the same everywhere.

## The three habits

1. **Name the destination out loud before you act:** which repository, which branch it is cut
   from, which branch its pull request targets. Ambiguity here has cost a full day of reverted
   work, and it is caught by saying the sentence, not by being careful.
2. **Say what you actually did, not what you intended.** A push that reports success can still
   have gone somewhere unintended. Check with `git ls-remote`, not with the command's own output.
3. **Confirm before anything irreversible or visible to other people:** deleting a remote branch,
   tag, or work item; force-pushing; rewriting shared history; dropping or migrating a real
   database; creating a repository; changing a branch policy or pipeline; any write to a tracker
   or a design tool; anything that reaches production. Say what will change and where, get a yes,
   then do it. Once, not per field.

## Size the job, then stop once

Every piece of work gets a **tier**, stated in one line the owner can override:

| Tier | What | The one stop |
|---|---|---|
| 1 | small, low-risk, reversible | none. Say what you will do, then do it |
| 2 | a normal feature, fix, or refactor | one message after Understand: the summary, the outcome checklist, the branch sentence |
| 3 | high-risk, hard to reverse, or architecture-touching | the same message, plus a decision entry in the knowledge base, plus review |

**The hard floor:** auth, authorization, payments, secrets, data migration, a public API or
contract, a security control, cross-module architecture. Any of these is Tier 3 and cannot be
tiered down. Round up when unsure.

After the yes, **build uninterrupted.** Pause only for the stop-list: a Tier-3 area touched
unexpectedly · a new dependency · a schema or migration change · data deletion · anything reaching
production or an unfamiliar remote · two failed attempts at the same thing · scope growing past the
agreed boundary. Everything else waits for the hand-back. Before any autonomous run, commit a
checkpoint: git is the undo, not the session's own checkpoints.

## What counts as done

- **Deterministic checks carry correctness.** Two models agreeing is necessary, not sufficient.
  Run `bash .claude/tools/verify.sh` before claiming anything builds; CI is the only neutral check.
- **A green counts only if the check can go red.** A check that has never failed is suspect, and
  `verify.sh --canary` must fail. A flaky result is not evidence: quarantine it, do not cite it.
- **Evidence settles findings, in this order:** a deterministic failing check or reproducer · the
  reviewer's own recompute · a spec line nobody in the loop wrote · a builder-produced result ·
  model judgment alone. A citation never settles a finding by itself. A blocking finding without
  evidence at the first three levels, or a reproducible recipe, is only a recommendation.
- **Merge only when the blocking bucket is empty**, and sign the direction delta separately: what
  shipped, in product terms, versus what was asked. A perfectly built wrong feature has an empty
  blocking bucket.
- **The review menu after a build:** a fresh-context `/code-review`, a Codex cold pass through
  `/codex-relay`, a local run with `/test-guide`. Any combination. Defaults: Tier 1 the local run,
  Tier 2 review plus the local run, Tier 3 all three. Pushback on a finding is evidence-only.
- **For critical logic a human confirms the expected values.** A test must never enshrine
  current-buggy behaviour.

## What is enforced, and what is advice

Everything in this folder is advice except four hooks. `guard-secrets` blocks a secret **value**
written through Edit or Write. `guard-commands` blocks the destructive commands on its list, which
starts empty and grows from incidents. `verify-on-finish` blocks a turn that weakened, skipped, or
deleted a test. `resume-brief` re-reads the task brief after a compaction. No hook sees a browser,
an MCP call, chat, or a shared folder. **Rules and hooks load at session start: restart the session
after changing either.**

## Where things live

| Path | What it is |
|---|---|
| `.claude/` | the harness: rules, skills, hooks, tools, settings. Committed. Read every session |
| the knowledge base | facts with evidence, point-in-time, committed. `docs/knowledge-base/` inside a single repository; `knowledge-base/` at the workspace root above several |
| `working/` | **yours, local, disposable, never committed.** Status, handoffs, task briefs, scratch. Deleting it must lose nothing durable |

In a workspace above several clones, never hardcode a path to them: `. .claude/tools/layout.sh`
resolves `WS_ROOT`, `WS_REPOS`, and `WS_LAYOUT`. Other projects on the same machine are not
evidence about this one, however similar. Reuse tooling; never carry a finding across.

## Capture, posture, memory

- **Anything noticed and not acted on goes into `99-pending.md` in the same turn**, one line, with
  enough context to act later. Never into `working/`; that is a slower way of losing it.
- **Data posture** is `demo` or `production`, declared in the project rule. In demo, security and
  robustness hardening are non-blocking follow-ups, every shortcut is a `99-pending.md` line tagged
  `demo-debt`, and the flip to production waits until that list is empty or owner-waived. In
  production they block.
- **Auto memory is scratch.** Anything durable in it is promoted to a rule or a knowledge-base page
  through `/record`. Anything that is status goes to `working/`.
