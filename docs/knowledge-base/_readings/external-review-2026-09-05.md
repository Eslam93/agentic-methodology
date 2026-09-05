---
title: What an external model review said about v2 on 2026-09-05, which of its claims and scores hold at bac12dc, and what it missed
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: The owner pasted a three-turn conversation with another AI model on 2026-09-05. Each of its claims about this repository was re-derived from the tree at bac12dc by a verification agent and by the session, with the file and line read; its seventeen scores were checked against the tiers on the benchmark page by two comparison agents; the public metrics were re-fetched with gh api the same day; the commit the reviewer read was bracketed from git history. Nothing was executed; the hooks were read
scope: The reviewer's claims about this repository, its scores, and its recommendations. Its claims about the other eight repositories are settled on the benchmark page beside this one
confidence: High for every verdict in the claims table, each of which cites a file and line. Medium for the score verdicts, which compare an opinion with two agents' tier placements. Nothing here measures whether any skill helps
known_gaps: The reviewer's transcript could not be re-run, so the exact commit it read is bracketed, not known. Whether the regex matcher Edit|Write fires on MultiEdit and NotebookEdit was not verified. Whether the reviewer's scores were meant absolutely or relative to its set is unknown; the verdicts read them absolutely
reverify_when: When any file cited in the claims table changes, and before quoting any of the reviewer's scores anywhere
---

## What it said

The reviewer had read the rules, the skills, the hooks, the verifier, the installer, and the
knowledge base, after studying eight other repositories in the same category. Its bottom line:
the kit is stronger as a methodology than as a platform; top two or three in its set for
conceptual quality, first for what it called epistemic integrity, middle for execution
infrastructure, last for adoption. It gave seventeen numeric scores out of ten. Under the rules
of this base those are opinions: no benchmark, comparison, or measurement stands behind them, and
the README's own limit line says nothing here has been shown by comparison to help.

Its recommendations, in its own priority order:

- **Five fixes:** seal the approved brief with a hash and a baseline commit; compare test
  integrity from the task baseline, not `HEAD`; classify pre-existing dirty files before the
  checkpoint commit; add an explicit active-task pointer; make Tier 3 require one independent
  review or a recorded waiver.
- **Five builds:** a behavioural eval suite; a knowledge-base linter that checks headers, dates,
  and evidence links; executable `reverify_when` triggers and a "truth diff" per pull request; a
  fresh-context worker mode for Tier 3; a host-adapter layer with an updater.
- **A positioning:** the trust layer for AI-assisted engineering, not another development
  framework.

## Which of its claims hold at bac12dc

Verdicts: holds · partly · refuted · stale (true of the tree it read, false at `bac12dc`) ·
opinion. Layer: (a) what a document says, (b) what a rule or skill instructs, (c) what a hook or
script enforces. Evidence is the file and line at `bac12dc`, read 2026-09-05.

| # | Claim | Verdict | Evidence |
|---|---|---|---|
| R1 | the Stop hook diffs against `HEAD`, so a weakened test that was committed before the turn ends is invisible to it | holds (c) | `verify-on-finish.sh:42` `git diff --name-status HEAD`, `:51` `git show HEAD:$file`; `.ps1:104,114` the same. A scratch probe confirmed the diff is empty after the commit |
| R2 | `resume-brief` restores the newest `brief.md` by modification time; no active-task pointer exists | holds (c) | `resume-brief.sh:17` `find ... -printf '%T@' \| sort -rn \| head -1`; `.ps1:24-25` `Sort-Object LastWriteTime -Descending` |
| R3 | `guard-commands` has no active rule; only its self-test marker blocks | holds (c) | `guard-commands.sh:33-34` "(none yet)"; `decisions.md` D-11 records the choice |
| R4 | step 3 of `/work` says the one yes is the only approval, then step 4 asks "design review first, or go?" | stale | true from `76f4d60` to `9081a79` (2026-09-05, 10:37 to 11:08 +0300); fixed at `59d1a15` (11:19), which folded the route into the agree message. `work/SKILL.md:75-76, 85` |
| R5 | a Tier 3 task can end with no independent review if the owner declines every menu item | holds (b) | `standing-orders.md` review menu; `work/SKILL.md:109` "run what they pick"; D-06 "the owner wanted to choose per task". `/codex-relay` carries `disable-model-invocation`, so the assistant cannot start it on its own, and nothing records that a review ran |
| R6 | `/work` commits a checkpoint without classifying files that were already dirty | holds (b) | `work/SKILL.md:91-92`; the only dirty-tree instructions are in `/orient` (session start), `/pr`, and `/handoff` |
| R7 | the installer never overwrites and there is no upgrade path; settings are merged by hand | holds (c) | `install.sh:38, 69-71`; `install.ps1:31, 57-59`; no `upgrade` or `update` string in the tree |
| R8 | `main` is unprotected with no required checks | holds, measured | `gh api .../branches/main/protection` gave HTTP 404 and `.../rulesets` gave `[]` on 2026-09-05 |
| R9 | twelve of seventeen acceptance tests passed, five not run | stale, and still in the README | `acceptance.md:20-38` at `9081a79` records all seventeen passed; `README.md:157-159` still says twelve, unchanged since `76f4d60` |
| R10 | no stars, no forks | holds, measured | `gh api repos/Eslam93/agentic-methodology` gave 0 and 0 on 2026-09-05 |
| R11 | the cold Codex pass withholds the builder's results; a context pass follows | holds (b) | `codex-relay/SKILL.md:22, 50-52`; V-03 |
| R12 | pushback without evidence is invalid | holds (b) | `standing-orders.md`; `codex-relay/SKILL.md:89` |
| R13 | the seven capability statuses and the weakest-link rule | holds (a) | `.claude/rules/knowledge-base.md:21-22`; `evidence-and-verification-rules.md:88-102` |
| R14 | the hooks see the editing tools and the two shells only | holds (c), with a caveat | `settings.json:4-5, 8, 11`. Caveat under new finding 3 |
| R15 | `reverify_when` is prose | holds (a) | every page header; `verify.sh:127-134` parses no header field |
| R16 | nothing ties `working/<task>/brief.md` to the text that was agreed | holds (b) | `work/SKILL.md:79-81`; no hash, timestamp, or baseline anywhere under `.claude/` |
| R17 | the verifier's checks, the canary, and the hook tests exist as described | holds (c) | `verify.sh:41-155`; `hooks.test.sh` has 15 cases per shell, 30 on Windows, 15 on Linux CI |
| R18 | portability is Claude-centric; Codex is only the reviewer | holds (a, b) | no `AGENTS.md` or `CLAUDE.md`; D-12, D-03; `codex-relay/SKILL.md:62-68` |
| R19 | v2 deleted the v1 document layer | holds | `277486a`: 41 deletions; D-01; tag `v1.5.1` |
| R20 | the seventeen scores | opinion | no benchmark or comparison exists in the tree; `README.md:163` states the limit |

**Which tree it read.** The README count (R9) and the route contradiction (R4) were both true
of the tree between `76f4d60` (10:37 +0300) and `9081a79` (11:08 +0300) on 2026-09-05, so the
review was written in that window or from a copy taken in it. Its star counts for the other
repositories matched `gh api` on the same day to within rounding, so its facts were live; its
reading of this repository was fifty minutes behind.

## Its scores against the tiers

Read absolutely, against the tier each dimension's comparison put the kit in (benchmark page).
The pattern: where it scored high, the tier holds and the number is inflated; where it scored
low, the kit is bottom, not middle.

| Dimension | Its score | Tier found | Verdict | Why |
|---|---|---|---|---|
| epistemic integrity | 9.8, best | top | overstated | best-in-set holds on the rules; no claim field is checked by code, and four stale claims sat in the README and the base at the tag |
| durable project knowledge | 9.6, best | top | overstated | the written format is the most complete; two systems check citations or log learnings in code, which this kit asks for in prose |
| self-verification and limits | 9.5 | top | overstated | the only adopter-side canary and hook tests; the limits page omits the Stop hook's two blind spots, and the README disagreed with the acceptance page at the tag |
| human attention design | 9.2 | top, shared | holds | one yes, the stop-list, propose-and-stop verified live |
| brownfield and multi-repo | 9.3, possibly best | top, shared with the GSDs | holds | the only deployed-state step and trunk-is-not-default rule; GSD has a workspace command |
| independent review design | 8.6 | top, not the best | holds | strongest on what settles a finding; weak on where a finding goes |
| requirements and intent | 8.0 | middle | overstated | below OpenSpec, Spec Kit, BMAD, and Compound Engineering; the brief is unhashed and disposable |
| context resilience | 8.0, GSD stronger | middle | holds | the harness is stronger still; the relay-brief misfire was unknown to it |
| implementation discipline | 7.5, Superpowers stronger | middle | holds | the only blocking test protection; test-first for bugs only; no WIP rule |
| hard runtime enforcement | 6.0 | middle | holds | two default-on blocking hooks, one armed and empty; the harness and GSD core are top |
| extensibility and ecosystem | 5.5 | bottom | overstated | no plugin, no catalog, one contributor |
| large-work orchestration | 5.5 | bottom | overstated | one paragraph on phases, in a disposable folder |
| multi-agent execution | 5.0 | bottom | overstated | the only second agent is a reviewer |
| product, design, visual QA | 5.0 | bottom | overstated | nothing drives a browser or reads a design |
| cross-agent portability | 5.0 | bottom | overstated | one host |
| external battle-testing | 2 | bottom | holds | zero stars, zero forks, one contributor, one machine |
| install and update | not scored | bottom, below every external system | no score to check | a first-install script and nothing after it |
| ceremony cost | not scored | middle | no score to check | 274 lines every session, third heaviest fixed load; light on everything else |

Seven hold, nine are overstated, two were never scored. Its ranking sentence ("top two or
three in conceptual quality, middle in execution, last in adoption") survives as tiers; its
numbers do not.

## What the check found that the reviewer did not

Each was found while re-deriving the claims above. Since then: R1, R6, R16, and findings 1 and 8
below were closed on 2026-09-05 by decision D-17, the sealed task baseline, and R2 with finding 2 by
D-18, the session-scoped active-task pointer; the rows and the findings describe the tree at
`bac12dc`. The rest are in `99-pending.md`.

1. **A staged rename that weakens a test is invisible to the Stop hook.** `git diff --name-status
   HEAD` prints `R091 old new` for a renamed and shrunk test; `verify-on-finish.sh:47-59` and
   `.ps1:112-113` handle only `D*` and `M*`, so the line falls through. Unstaged renames still
   show as `D` and are caught. Not covered by `hooks.test.sh`.
2. **`resume-brief` can restore the Codex relay brief instead of the task brief.** `/codex-relay`
   writes `working/relay/<task>/brief.md` (`codex-relay/SKILL.md:31`); both hook versions match
   it, and newest-by-mtime picks it whenever the relay ran after the agreement, which is the normal
   order. The hook then labels it "agreed with the owner; do not re-plan it".
3. **`guard-secrets` reads three payload fields.** `guard-secrets.sh:23` extracts `content`,
   `file_text`, and `new_string`. A `MultiEdit` (`edits[].new_string`) or `NotebookEdit`
   (`new_source`) payload yields empty text and exits 0 at `:40`, whether or not the `Edit|Write`
   matcher fires for those tools. The README says a secret value is blocked before it is written
   without this qualification.
4. **The test-file and assertion heuristics are JavaScript and C# shaped.** `verify-on-finish.sh:35-36`:
   Go `foo_test.go` and pytest `test_foo.py` outside a `tests/` folder are not test files to the
   hook, and `t.Errorf` never counts as an assertion. Not stated as a limit anywhere.
5. **Stale wording beyond the README count.** `start-here.md:8` "describes a plan until Phases 2
   to 4 land" and `:42` "v2 is being built" beside `:45-46` recording every phase landed;
   `index.md:50` "a risks page is due after Phase 4's acceptance results exist" (they exist);
   `acceptance.md:2` and `index.md:36` titles still say "which could not run".
6. **The hook test count differs by platform and is not stated:** 30 cases on Windows, 15 on
   Linux CI (`hooks.test.sh:17-20`); `acceptance.md:45` records it, the README does not.
7. **The verifier's secret scan excludes `.claude/hooks/` and itself** (`verify.sh:138`), by
   design because those files carry the regexes; the README describes the check without the
   exclusion.
8. **`hooks.test.sh` never commits the weakened test before firing the Stop hook** (`:59-69`), so
   the suite could not have caught R1. Acceptance row 5 was run the same way.
9. **The limit line about hooks reads as a platform fact and is not one.** "No hook sees a
   browser, an MCP call, chat, or a shared folder" is true of this kit's matchers; the hooks
   documentation says a `PreToolUse` matcher can name an MCP tool (`claude-code-docs-2026-09-05.md`).

## Its recommendations against the decisions in force

Opinion, labelled: which recommendations fit the kit as decided, which collide with a
recorded decision, and what would change the view. The decision itself is the owner's.

| Recommendation | Fits or collides | Note |
|---|---|---|
| seal the brief: hash, approval time, baseline commit | fits D-04 and V-02; small | the baseline commit is the same fact R1 needs; one write in `/work` step 3. No studied system does this; BMAD's `baseline_commit` line is the nearest |
| test integrity from the task baseline, not `HEAD` | fits V-05; changes hook semantics | a baseline comparison keeps blocking after the owner has agreed a test was wrong, so it needs a recorded waiver or it becomes the gate people click through (idea 6 of the README) |
| classify dirty files before the checkpoint | fits the three habits; a few lines | `/orient` already says "leave it"; `/work` step 5 does not; Compound Engineering's inventory-then-path-limited-commit rule is the shape |
| an active-task pointer | fits; also closes new finding 2 | a `working/active-task` file the hook reads first, falling back to mtime; the hook input carries `session_id` |
| Tier 3 needs one review or a recorded waiver | collides with D-06 as written; the owner chose the menu | the waiver line keeps the owner's choice and makes the hard floor a contract; a one-line change to `standing-orders.md` if the owner wants it |
| behavioural eval suite | fits V-05 and the acceptance page; costs runs | `claude plugin eval` needs a plugin manifest, which D-03 declined; a `claude -p` script with and without a skill needs no plugin. No studied repository gates CI on one either |
| knowledge-base linter | fits D-10; the cheapest build | header fields, dates, evidence paths at a commit, links; a `verify.sh` check that can go red. Compound Engineering's `validate-doc-claims.py` is the nearest existing code |
| executable `reverify_when` and a truth diff | fits D-10 in spirit; larger | no studied repository has it; the linter is its first half |
| fresh-context worker mode | collides with D-04's one uninterrupted build only in degree | `/work` step 2b already splits phases into cold briefs; dispatching them to a subagent is the next step, not a new design. The comparison rates this axis bottom |
| host adapters and an updater | collides with D-03 (no plugin, install by copy) and V-09 | the updater is the real gap (R7, bottom of the install axis); the adapters are not, while the kit targets Claude Code with Codex as reviewer |
| "ephemeral task guardrails" from the sealed brief | collides with D-11 (rules grow from incidents) | a per-task allow-list is a new kind of rule, not an incident rule; a real fork for `decisions.md` |
| the "trust layer" positioning | not a decision this base can settle | the README already carries the limit line; a positioning claim without an adopter is a CLAIMED status |

## Not checked

Whether any of the five fixes changes behaviour in a live session; nothing was built. Whether
the reviewer's star counts were read from the API or from a cache. Whether the reviewer's scores
were relative to its set, which would soften the "overstated" verdicts on the low end. The
reviewer's claims about the other eight repositories, which the benchmark page settles from their
trees.
