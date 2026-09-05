---
title: Where every page is, and what each one settles
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Listing of this folder at the commit that introduced it
scope: This knowledge base only
confidence: High. This page is maintained by hand and checked against the folder listing
known_gaps: None for the listing. The empty sections are named below with the reason
reverify_when: Every time a page is added, superseded, or removed
---

## Start with one of these

| If you are | Read |
|---|---|
| New to the project | [`start-here.md`](start-here.md) |
| Wondering why it is built this way | [`../decisions.md`](../decisions.md) |
| About to change the kit | [`what-we-do-not-know.md`](what-we-do-not-know.md), then [`../99-pending.md`](../99-pending.md) |
| About to write here | [`evidence-and-verification-rules.md`](evidence-and-verification-rules.md) |
| Comparing the kit with other harnesses | [`../_readings/harness-benchmark-2026-09-05.md`](../_readings/harness-benchmark-2026-09-05.md), then [`../_readings/harness-benchmark-takeaways-2026-09-05.md`](../_readings/harness-benchmark-takeaways-2026-09-05.md) |

## Every page, and what it settles

| Page | What it settles |
|---|---|
| `README.md` | the two warnings, the shape of this knowledge base, and why it lives inside the repository |
| `00-orientation/start-here.md` | what the project is, what v1 was, what v2 is, where things are |
| `00-orientation/evidence-and-verification-rules.md` | how a claim is written so it is still true in a year: header, banner, labels, the volatile-claim rule, corrections, the claim types |
| `00-orientation/what-we-do-not-know.md` | the gaps, grouped by root cause and ordered by what closing each one would unlock |
| `decisions.md` | every decision in force, what each superseded, and when to revisit it |
| `_readings/evidence-base.md` | the research the v1 thesis cited, with what each item supports and its verification status |
| `_readings/ai-workspace-blueprint-2026-09-02.md` | what the blueprint prescribes, what this kit took from it, what it did not |
| `_readings/harness-standards-2026-08.md` | the measured harness facts from a prior installation that changed this kit's design |
| `_readings/v1-review-from-the-field-2026-08-03.md` | what a working installation said about v1: the two mechanisms worth keeping and the weaknesses v2 addresses |
| `_readings/harness-benchmark-2026-09-05.md` | what nine coding-agent methodology repositories actually enforce, what each can stop, and the tier each sits in beside this kit, measured 2026-09-05 |
| `_readings/harness-benchmark-takeaways-2026-09-05.md` | the mechanisms those nine offer this kit, with source path and cost, and the patterns not to take |
| `_readings/external-review-2026-09-05.md` | what an external model review said about v2, which of its claims and scores hold at `bac12dc`, and what it missed |
| `_readings/claude-code-docs-2026-09-05.md` | the Claude Code documentation facts that bound what a hook, a goal, or a plugin can do for this kit |
| `_investigations/2026-09-05-v2-rewrite/methodology.md` | the commits and commands behind every number on the v2 pages |
| `_investigations/2026-09-05-v2-rewrite/acceptance.md` | how each of the seventeen acceptance tests was run and what it returned; all seventeen passed on 2026-09-05 |
| `_investigations/2026-09-05-benchmark/methodology.md` | the commands, commits, and agent runs behind every number on the benchmark pages, and what the benchmark left unverified |
| `99-pending.md` | everything found and not acted on |

## What is empty, and deliberately

| Section | Why empty |
|---|---|
| `10-access/` | one owner with full access; nothing is blocked by a missing credential |
| `20-system/` | the kit has no runtime system; its map is the directory tree in `START-HERE.md` from Phase 3 |
| `30-infrastructure/` | nothing is deployed |
| `40-operations/` | the operations are `verify.sh`, its canary, and the CI workflow that runs them, all self-describing; a runbook page follows if the release process earns one |
| `50-incidents/` | no incident on this repository yet. Incidents from the source installations stay in their own bases |
| `60-design/` | no design source |
| `80-governance/` | the rules under `.claude/rules/` are the governance; duplicating them here would be the drift v2 exists to remove |
| `90-strategy/` | a risks page is due after Phase 4's acceptance results exist |
| `95-briefings/` | no audience other than the owner yet |
