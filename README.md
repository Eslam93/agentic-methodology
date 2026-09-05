# Agentic methodology

[![verify](https://github.com/Eslam93/agentic-methodology/actions/workflows/verify.yml/badge.svg)](https://github.com/Eslam93/agentic-methodology/actions/workflows/verify.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![release](https://img.shields.io/badge/release-v2.0.0-informational.svg)](https://github.com/Eslam93/agentic-methodology/releases)

**A Claude Code harness and a knowledge-base format for building software with an AI assistant
doing most of the editing.** Derived from three real installations, not designed on paper. Every
rule in it was paid for by a named failure, every number in it carries the date and the commit it
was measured at, and the kit says plainly which parts are enforced and which are advice.

> The human owns direction. An independent review owns judgment. Deterministic checks own facts.

If you want the kit, start with [Install](#install). If you want to know why it is shaped this
way, start with [Where this came from](#where-this-came-from). Both are short.

## The problem it solves

An assistant with a fresh context knows nothing about your project, and the expensive failure is
that it does not know that it knows nothing. It reads the default branch and reports on code that
was superseded weeks ago. It proposes a fix that was tried and rejected in March. It edits a test so
the suite passes. It writes a confident summary that drops the one caveat that mattered.
Documentation written to prevent this rots within a month, because nobody reads a page that changes
three times a day next to a page that stays true.

This kit answers with two things and one boundary between them:

| | The harness | The knowledge base |
|---|---|---|
| **holds** | how the assistant works on this project | what is true about the project, with evidence |
| **made of** | rules, skills, hooks, tools, settings under `.claude/` | Markdown pages with evidence headers |
| **read by** | the assistant, automatically, at session start or on a trigger | humans and assistants, on demand |
| **the test for inclusion** | would the assistant get this wrong without it? | would this still be worth reading in a year? |

Volatile status, where the last session got to and what to resume, lives in a third folder,
`working/`, which is disposable and never committed. **Durable facts never share a folder with
volatile status.** That boundary is the design.

## What is in the box

Four rules, ten skills, four hooks, six tools. Install is a copy.

| Part | What it does |
|---|---|
| **`standing-orders`** | how to work here: name the destination before acting, say what you did rather than what you intended, confirm before anything irreversible; the risk tier with its hard floor; the stop-list; what counts as done |
| **`writing`** | one register for a mixed audience of developers, analysts, managers, and non-technical readers, most of whom read English as a second language |
| **`working-here`** | the traps that fail silently, each with symptom, mechanism, fix, and the date it was measured. It grows with every incident |
| **`knowledge-base`** | loads only when a knowledge-base file is touched: how a claim is written so it is still true in a year |
| **`/orient`** | where things stand at the start of a session, in five lines. Then it stops and lets you choose |
| **`/work`** | a task from a description, a GitHub issue, or an Azure DevOps item: understand, one yes, an uninterrupted build, a review menu, a hand-back with evidence |
| **`/record`** `/handoff` | durable facts into the knowledge base with evidence and what was not checked; session state into `working/` so it survives a compaction |
| **`/codex-relay`** | an optional second model, read-only, briefed in full, answering verdict first, with pushback allowed only with evidence |
| **`/test-guide`** `/pr` `/board` | plain-English test steps that double as the pull request's "How to test"; a well-formed pull request; a tracker update that proposes and stops |
| **`/explain`** `/summarize` | the real version at a named audience, with a verify mode that re-checks a claim against the current tree; and the short version, without losing the caveats |
| **four hooks** | a secret value is blocked before it is written; a test weakened, skipped, or deleted blocks the turn, measured from the baseline of the task this session carries when there is one, and from `HEAD` otherwise; a destructive-command list that starts empty and grows from incidents; that same task's brief re-read after a compaction |
| **`baseline.sh`** | seals the task's starting point into the agreed brief at the owner's yes, the approval time, the digest of the agreed text, and the commit of every checkout, beside a list of the files that were already dirty; and, when the host gives a session id, binds that brief to the Claude session, so both hooks know which agreement this session is carrying instead of taking the newest file. Unbound, both fall back and say so |
| **`verify.sh`** | the checks that exist here, a canary that must fail, and a hook test suite that proves the guards can go red |

Every hook ships in PowerShell and in Bash. Windows was the first platform, not an afterthought.

## Install

```bash
git clone https://github.com/Eslam93/agentic-methodology kit
bash kit/.claude/tools/install.sh <your-repo> --shape A                    # one repository
bash kit/.claude/tools/install.sh <workspace> --shape B --repos <clones>   # several repositories
```

On Windows without Git Bash: `powershell -File kit\.claude\tools\install.ps1 -Target <dir> -Shape A`.

The installer copies `.claude/` without overwriting anything, writes the hook settings for your
operating system, creates `working/` and the knowledge-base skeleton, adds the ignore and attribute
lines, and ends by running `verify.sh`. Then open Claude Code on the project, **start a new
session**, and say:

> read START-HERE.md in `kit/` and follow it

The assistant asks you the eleven questions it cannot answer from the code, measures the rest,
writes the project rule, and runs the acceptance tests. [START-HERE.md](START-HERE.md) is written
for the assistant; you only have to point at it.

## How a session runs

```
/orient    where things stand, in five lines. Then STOP and let the human choose.
/work      intake, understand, one yes, route, build, the review menu, hand back.
/record    durable findings into the knowledge base, with evidence and what was NOT checked.
99-pending everything noticed and not acted on: one line, same turn.
/handoff   session state to a file in working/, so it survives compaction and Monday.
```

Two boundaries carry the whole design: **orienting and deciding are different jobs, and the second
is the human's**; and **a finding goes to the knowledge base the first time**, never to the
disposable folder.

## The ideas that carry it

1. **Name the destination out loud before you act.** Which repository, which branch it is cut from,
   which branch the pull request targets. The sentence is what catches the mistake, not caution.
2. **One yes, then build uninterrupted.** The assistant asks only the questions whose answers change
   what gets built, gives one summary with a checkable outcome list, and stops once. After the yes
   it pauses only for a short stop-list: a security area touched unexpectedly, a new dependency, a
   migration, data deletion, anything reaching production, two failed attempts at the same thing.
3. **Size the job with a tier, and a hard floor.** Auth, payments, secrets, migrations, public
   contracts, security controls, and cross-module architecture are always the top tier and cannot
   be tiered down.
4. **Evidence settles findings, in a fixed order.** A deterministic failing check, then the
   reviewer's own recompute, then a spec line nobody in the loop wrote, then a builder-produced
   result, then model judgment alone, which settles nothing. A citation never settles a finding by
   itself.
5. **A green counts only if the check can go red.** `verify.sh --canary` must fail. A check that has
   never failed is suspect.
6. **Spend the enforcement budget only where damage is irreversible and silent.** Four hooks. A gate
   people click through ten times a day is not a gate.
7. **Never assert a changeable condition in the present tense.** Write the measurement, with its
   date and commit. "As of 2026-08-31 at `2c617f31`, no test project existed" stays true forever.
8. **Describe the system, not the people.** Knowledge concentration is a property of the code.
9. **Keep negative results.** A thing that turned out not to be true saves the next person a day.
10. **The grader must not be the worker.** A fresh-context review is the default; a second model is
    optional and read-only.

## The knowledge base

Every substantial page opens with a header: what the page settles, when the facts were gathered,
when they were last verified and how, the scope, the confidence and why, **what was not checked**,
and when to re-verify. A page with volatile numbers carries a three-line banner: measured when,
expires when somebody does their job, stays true regardless. Every claim says what kind of sentence
it is, so a reader never mistakes a fact for a measurement, a measurement for an opinion, or an
opinion for a decision. Corrections are swept by code symbol, not by phrase, because one refuted
claim once survived five correction passes across nine documents.

This repository keeps its own knowledge base under [`docs/knowledge-base/`](docs/knowledge-base/),
written under those rules, about itself.

## Where this came from

Version 1 of this methodology was documents a project fills in: a per-task flow, a constitution
built into `AGENTS.md`, design notes, ADRs, a worklog, a resume file, an escape log, a promotion
ledger, a memory system. Complete, and reachable at tag `v1.5.1`. In real use the documents were
filled in and not read. Version 2 keeps the theory and deletes the documents: what survives lives
as rule lines a session loads, skill beats a session runs, and checks a script can fail.

The harness itself was generalized from three installations in daily use during 2026: the owner's
own public site, and two multi-repository consultancy workspaces. Their project content stays
private; what this kit took is the rules, the skills, the hooks, and the measured traps. The
knowledge-base format follows a blueprint written from a nine-repository .NET estate.

The reasoning is all recorded, with what each decision superseded and when to revisit it:

- [`decisions.md`](docs/knowledge-base/decisions.md): every decision in force
- [`evidence-and-verification-rules.md`](docs/knowledge-base/00-orientation/evidence-and-verification-rules.md): how a claim is written
- [`_readings/`](docs/knowledge-base/_readings/): the sources, with what was taken and what was not
- [`what-we-do-not-know.md`](docs/knowledge-base/00-orientation/what-we-do-not-know.md): the gaps, by root cause
- [`_investigations/`](docs/knowledge-base/_investigations/): the commands and commits behind every number, and the acceptance results

## Status and limits

`v2.0.0`, 2026-09-05. Twelve of seventeen acceptance tests passed, three of them live on the Claude
Code desktop app: the secret guard blocked a real write and allowed the false-positive case, and the
Stop hook blocked a weakened test. The remaining five need a session started after the install or a
command only a human types; they are listed with exact steps on the acceptance page. CI runs the
checks, the canary, and the hook tests on Linux on every push.

The limits, stated once: nothing here has been shown by comparison to help. The measurements are one
maintainer's, on Windows and Linux CI, dated in the knowledge base. The hooks see the editing tools
and the two shells, nothing else; a shell redirect or an MCP call passes them untouched. If you
install it, write your own limits down the same way.

## Repository map

```
.claude/            the kit, live on this repository as well
  rules/            standing-orders · writing · working-here · knowledge-base · methodology (this repo's own)
  skills/           orient · work · codex-relay · test-guide · pr · board · record · handoff · explain · summarize
  hooks/            guard-secrets · guard-commands · verify-on-finish · resume-brief, each .ps1 and .sh
  tools/            layout.sh · verify.sh · hooks.test.sh · baseline.sh · install.sh · install.ps1
  settings.json     the hook wiring
docs/knowledge-base/  this repository's knowledge base
working/            disposable; only its README is committed
START-HERE.md       for the assistant
.github/workflows/  verify.sh, its canary, and the hook tests, on every push
```

## Contributing

Issues and pull requests are welcome. A change to a rule, a hook, or a skill should say what failure
it prevents, with the date and the command that showed it. That is the standard every line in the
kit was held to, and it is the only kind of evidence that settles a change here.

## Author and license

Built by Eslam Hamed, from daily use. MIT licensed; see [LICENSE](LICENSE).
