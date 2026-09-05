---
title: What the nine benchmarked repositories offer this kit, mechanism by mechanism, with the source path and the cost, and what not to take from them
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Each entry was found by a study agent in the clone named on the methodology page and cited by path and line at that commit; the top five ideas of each report were re-read by an adversarial agent, and twenty further citations were re-opened by the session on 2026-09-05. The grouping and the cost lines are the session's own judgement and are labelled as opinion
scope: Mechanisms transferable to a four-rule, ten-skill, four-hook kit with Claude Code as the primary host and Codex as an optional reviewer. Not a survey of everything each repository does; the landscape page is beside this one
confidence: High that each cited mechanism exists as described. Medium for the cost lines, which are estimates. Nothing was run
known_gaps: The value of any entry is asserted from reading, not measured; the same limit the kit records about itself. Entries cited only from the archived GSD tree may have moved or changed in core
reverify_when: Before building any entry, re-open the cited file at the current default branch; before quoting a cost
---

Opinion, labelled: this page ranks by fit with the decisions in force, not by the source's
popularity. "Fix" means a change to an existing beat or hook; "build" means a new mechanism.

## 1 · The brief, the baseline, and the working tree

These close R1, R6, and R16 from the external-review page: the Stop hook's `HEAD` window, the
unclassified dirty tree, and the unsealed brief. They belong together because one fact, the
baseline commit, serves all three.

| Mechanism | Source | What it does there | Cost here |
|---|---|---|---|
| `baseline_commit` written into the brief's front matter before any edit; the reviewer reads a diff-since-baseline file by path, never a pasted diff | BMAD `src/bmm-skills/ship/bmad-build/step-03-implement.md:21,41`; `step-04-review.md:15` | fixes the review's base and makes "what changed" a file | a line in `/work` step 3; the Stop hook can then diff from it |
| review base recorded before dispatch, never `HEAD~1` | Superpowers `skills/subagent-driven-development/scripts/review-package`; `SKILL.md:248-249, 290` | multi-commit tasks are not truncated | the same baseline field, read by `/codex-relay` |
| pre-work inventory: `git status --untracked-files=all` before the first edit; commits limited to named paths with `git commit -F <file> -- <paths>` | Compound Engineering `skills/ce-work/references/workspace-setup.md:23-25`; `skills/ce-commit/SKILL.md` | pre-existing WIP is never swept into the kit's commit | two lines in `/work` step 5; optionally one `guard-commands` shape for `git add -A` |
| dirty-tree HALT before implementation, as prose | BMAD `step-01:80`; `bmad-build-auto/step-01:74` | the model runs `git status` and stops on surprises | already half-present in `/orient`; move the check to `/work` |
| a hash of the rule and skill files in force, recorded with the task | BMAD `src/scripts/render_skill.py:344-379` (the manifest, without the renderer) | what the model was told is reproducible later | a few lines in `verify.sh` or the checkpoint step |
| working-tree content fingerprint for evidence freshness | gstack `bin/gstack-wtree` | evidence is stamped with the tree it was produced on, not the commit | about 150 lines of bash; medium; later |
| plan-time preapproval with an expiry, a scope, and a use count, consumed under a file lock | claude-code-harness `go/internal/guardrail/plan_preapproval.go:32-50, 96-130`; `templates/schemas/plan-preapproval.v2.json` | one yes at plan time that expires and counts down (default ten uses); the state file is writable by the agent there, which a kit must not repeat | a brief convention now; a hook consumer later |
| write-consent contract: name the files, ask yes or no, wait for a separate message; an answer to a question is never consent | OpenSpec `skills/openspec-explore/SKILL.md:14, 330` | the yes is unambiguous | three lines in `/work` step 3 |
| the tier decided after investigation from three facts: intent gaps, irreversibles, footprint; no interview before looking | BMAD `step-02-plan.md:12-18` | ceremony sized by evidence, not by the request's wording | three lines in `/work` step 2 |
| announce the ceremony class out loud with a one-way ratchet: hidden complexity upgrades, nothing downgrades mid-task | Superpowers `skills/brainstorming/SKILL.md:22-52` | a Tier 1 that turns out to touch auth becomes Tier 3 in the open | a sentence beside the tier line |

## 2 · Tests and verification

| Mechanism | Source | What it does there | Cost here |
|---|---|---|---|
| a one-shot Stop nudge: block the first stop, allow and warn on re-entry | claude-code-harness `go/internal/hookhandler/stop_session_evaluator.go:74-95` | twelve consecutive blocks were measured before this guard existed | a re-entry rule if `verify-on-finish` ever gains a second check |
| a trust store of commands a Stop hook may run, `sha256(cmd)` per repository root, bounded re-entry | gstack `bin/gstack-verify-gate` | the Stop hook can run the project's verify command without running arbitrary text | about 200 lines of bash; the hook that would actually run `verify.sh` |
| a Stop hook that refuses to end until the project's own typecheck, test, and lint exit 0 | `first-fluke/oh-my-agent` (candidate set) | the gate decides on artifacts, not claims | the same mechanism as the row above |
| a catastrophic-shrink guard: deny a whole-file Write that leaves a curated file under 40 percent of its lines | GSD core `hooks/gsd-write-guard.js:4-44, 299, 336` | a compaction-confused model cannot wipe the status file | about 100 lines beside `guard-secrets`, for `99-pending.md` and `decisions.md` |
| every hook declares its own crash policy, fail-open or fail-closed, and a table test fails when one has none | GSD core `hooks/lib/hook-exit.js:30-36`; `tests/hooks-crash-policy.test.cjs` (eleven of thirty hooks declare one there) | a broken guard cannot pass silently | a 30-line helper and one case in `hooks.test.sh` |
| the deny surface fingerprinted at build time; the guard refuses to adjudicate when the live surface is narrower | claude-code-harness `go/internal/policy/selfaudit.go:1-40`; `go/cmd/harness/main.go:590-600` | a weakened guard list is caught by the guard (both sides live in one binary there) | a checksum of the active list pinned in `verify.sh` |
| tests clear owner exemptions before asserting a deny | claude-code-harness `runtimefloor_test.go:10-20`; `tests/validate-plugin.sh:460-473` | a green that depends on inherited environment is a false green | `unset` lines at the top of `hooks.test.sh`; minutes |
| every automated acceptance command carries a stated failing direction: what output means failure | GSD core `gsd-core/references/failing-direction.md:11-27` | a check that cannot fail is visible as such | one sentence in `/test-guide` and the outcome-checklist shape |
| exit codes that separate "nothing in scope" (66) from "could not run" (69) | GSD core `hooks/lib/exit-code-registry.js:31-39` | an empty set never passes as green | two exit codes in `verify.sh`; matches trap 3 in `working-here.md` |
| a timed-out build or test run is inconclusive, never green | GSD legacy `get-shit-done/workflows/execute-phase.md:924-939` | exit 124 keeps the plan in progress | two lines in the standing orders |
| RED evidence, not a RED exit code: zero discovered tests, a fixture crash, or an unrelated assertion is invalid | GSD core `gsd-core/references/execute-mvp-tdd.md:19-24` | "the test failed first" means the right test failed | a rule line beside "check that it fails before the fix" |
| a covering test that exists but did not run counts as missing; never edit the expectation to match the code | BMAD `step-03-implement.md:47` | ties the test map to the run | one line in `/test-guide` |
| a result vocabulary: verified, partial, failed; per check pass, fail, skipped, not run | Spec Kit `extensions/bug/commands/speckit.bug.test.md:61-64, 87-90, 117` | "not run" is a first-class result | a table in `/test-guide` |
| a verifier that may abstain: `PRESENT_BEHAVIOR_UNVERIFIED`, `human_needed`; `passed` invalid while a human item is open | GSD core `references/honest-verifier.md:37-43`; GSD legacy `agents/gsd-verifier.md:92-318` | silence is never a pass | prose in `/test-guide` and the hand-back |
| test-failure ownership triage: in-branch or pre-existing, per failure | gstack `ship/sections/tests.md:217-321` | a pre-existing failure is named, not hidden | prose |
| a drift audit: grep the tree for a stale value outside its declared files | Superpowers `scripts/bump-version.sh:117-151, 215` | the README's "twelve of seventeen" would have failed a check | a small script; would have caught R9 |
| a doc-versus-shipped drift test | Spec Kit `tests/workflows/test_bundled_speckit_workflow.py:45-58` | the documented hook list equals the wired one | a `verify.sh` check per pair |

## 3 · Review

| Mechanism | Source | What it does there | Cost here |
|---|---|---|---|
| a verdict-plus-evidence triage log: high, medium, low, false, maybe-false; the reviewer's severity discarded; one row per finding, never dropped; `false` needs the refutation | BMAD `step-04-review.md:31-43` | the reconcile step is a table, not an argument | a paragraph in the reconcile section of `/codex-relay` |
| routing by layer: intent gap, bad spec, patch, defer; when the spec was wrong, revert, amend, re-derive | BMAD `step-04-review.md:49, 57-60, 64` | the layer that produced the error is named | the review's "which layer" recommendation; small |
| cold ordering: trace the diff first, read the spec's claims last, then try to falsify them; "testimony, not evidence" | BMAD `review-prompts/edge-case-hunter.md:13`; `claims-check.md:5` | the reviewer is not anchored | reorder the cold brief |
| the verification-gap lens: "if this behaviour broke, would any test fail?", and tests that do not count | BMAD `review-prompts/verification-gap.md:3, 13-16, 55` | a review of the tests, not only the code | one reference file |
| reviewer contract clauses: read-only, no nested reviewers, do not trust the report, rationales are claims, the controller may not pre-judge | Superpowers `task-reviewer-prompt.md:52-71`; `SKILL.md:339-345` | closes the two known ways a review gets gamed | a few lines |
| grade absolutely, never "better than last round"; open the artifacts, never trust the builder's report | claude-code-harness `agents/reviewer.md:81-99` | round two cannot pass on improvement alone | zero cost |
| quote-the-line evidence gate with anchored confidence and a pre-existing partition | Compound Engineering `skills/ce-code-review/references/findings-schema.json:72-86` | a finding without a quoted line is demoted, and a P0 keeps its place | prose in the relay contract |
| requirements completeness against the plan, where an explicit gap blocks the verdict | Compound Engineering `references/finish-review.md:123-126, 133` | the direction delta becomes part of the verdict | one section in the review output |
| the orchestrator's own pass never corroborates; same-model agreement never promotes | Compound Engineering `references/dispatch-reviewers.md:11-14` | matches V-10 exactly | prose |
| a cold reviewer lane with `CLAUDE_CODE_DISABLE_CLAUDE_MDS=1` and `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` | GSD core `capabilities/claude/capability.json:143` | the fresh-context review is fresh of the project's rules and memory too | two lines in `/code-review` guidance |
| a pre-emit gate: quote the motivating file and line verbatim or drop the finding | gstack `review/SKILL.md:684-718` | no finding without a location | a paragraph |
| a revision loop capped at three with stall detection; save the attempted change as a patch before reverting | GSD legacy `references/revision-loop.md:12-40`; BMAD `step-04:62` | two failed attempts already stop the build here; this adds the patch | two lines |
| converge as an append-only gap audit: missing, partial, contradicts, unrequested, with a source reference per gap | Spec Kit `templates/commands/converge.md:145-176, 196-226` | the direction delta with a shape; the diff check proves only that nothing was rewritten | a section in the hand-back |

## 4 · The knowledge base

| Mechanism | Source | What it does there | Cost here |
|---|---|---|---|
| the counterfactual inclusion test: if this were lost, would a future engineer plausibly repeat the mistake or redo substantial investigation | Compound Engineering `skills/ce-compound/SKILL.md:20-24` | keeps routine knowledge recoverable from code out | ten lines beside "worth reading in a year" |
| a mechanical citation check: paths exist, commit hashes resolve, links resolve | Compound Engineering `skills/ce-compound/scripts/validate-doc-claims.py` (run only when the model runs it) | broken evidence is found by a script | a `verify.sh` check with its own canary; the first half of the "truth compiler" |
| the admission test "what does it cost when it does not know"; four deletion grounds; "nothing failing lately is not evidence" | BMAD `bmad-project-context/references/best-practices.md` | pruning has a rule | a paragraph in `/record` |
| explicit supersession operations: ADDED, MODIFIED as a full block, REMOVED with reason and migration, RENAMED | OpenSpec `schemas/spec-driven/schema.yaml:73-77`; `src/core/archive.ts:1390-1394` | a change to a durable claim names its kind | a paragraph in the knowledge-base rule |
| `not_observed` is not `absent` | claude-code-harness `docs/spec/workflow-review-and-release.md:67-70` | a timed-out search is unknown, not "no results" | zero cost; matches the volatile-claim rule |
| an audit line that stores a hash and a length, never the command | claude-code-harness `go/internal/auditlog/auditlog.go:17-31, 53-58` | a guard's log can be committed | an hour across the four hooks, if a log is ever wanted |
| a diagnostic envelope: severity, code, message, fix, one per failure | OpenSpec `docs/agent-contract.md:7-25, 45, 92-99` | the model can act on a block without guessing | the shape of the four hooks' stderr |

## 5 · Context, resume, and hand-back

| Mechanism | Source | What it does there | Cost here |
|---|---|---|---|
| an active-task pointer written atomically and removed on every exit path | claude-code-harness `.claude/state/active-task.json` (`skills/harness-work/SKILL.md:375-385`) | the resume reads a pointer, not a modification time | closes R2 and new finding 2; the hook reads it first, falls back to mtime |
| the pointer keyed by session identity rather than one shared file | GSD legacy `get-shit-done/references/workstream-flag.md:8-14` | two sessions on one clone do not fight | the hook input carries `session_id` |
| a safe-resume gate: before re-dispatching a task, grep the git log for its commit scope | GSD core `workflows/execute-phase.md:181-202` | work already committed is not redone | fifteen lines in `/work` |
| the builder's return envelope: four statuses, RED and GREEN evidence fields, under fifteen lines, detail in a file | Superpowers `implementer-prompt.md:128-153`; Compound Engineering `return-to-caller.md:9-30` with the literal `unverified` | the hand-back has a contract | a template |
| session-settled decisions annotated with two provenance classes; the model never settles one itself | Compound Engineering `skills/ce-plan/references/settled-decisions.md:9-15, 30` | a decision the owner made is distinguishable from one the model assumed | a paragraph in the brief |
| a "rulings I made" list at finish, each with what it costs if wrong | Superpowers `subagent-driven-development/SKILL.md:473-481` | the assumptions are on the table at hand-back | one paragraph |
| a spawned subagent asserts its branch namespace and base SHA and exits on mismatch | GSD core `references/worktree-branch-check.md:17-44` | a worker cannot silently edit the wrong branch | one block in any dispatch prompt |

## 6 · Install and update

| Mechanism | Source | What it does there | Cost here |
|---|---|---|---|
| a hash manifest of installed files; an update overwrites only files whose hash still matches | Spec Kit `src/specify_cli/integrations/manifest.py:1-7, 29-48`; `shared_infra.py:461-473` | user-modified files survive an upgrade | the smallest honest update path; closes R7 |
| the same manifest with a backup of modified files before overwrite | GSD core `bin/install.js:9736-9760, 10120-10175` | nothing is lost, nothing is merged by a model | the alternative to the row above |
| a deterministic check after any model-driven merge: the user's added lines must survive | GSD legacy `get-shit-done/bin/verify-reapply-patches.cjs:1-30` | exists because a model lost content once | only if a merge step is ever built |
| canonical hook paths with settings self-heal | gstack `setup:1996-2040`; `bin/gstack-settings-hook` | a moved install does not orphan its hooks | medium; later |

## 7 · Evaluation of the kit itself

| Mechanism | Source | What it does there | Cost here |
|---|---|---|---|
| micro-test a rule's wording against a no-guidance control, five or more reps, read every result, treat variance as a signal | Superpowers `skills/writing-skills/SKILL.md:576-586` | the wording is tested, not admired | API runs per wording change; medium |
| falsifiable acceptance rows graded on artifacts (commit range, log, `git status`); rows that cannot fail are removed | Compound Engineering `tests/skill-eval-cell/scenarios.md:3-9, 98-108`; `grade.ts:241-261` | a deterministic grader, no model judge | a 300-line driver plus fixture repositories; run by hand |
| a vanilla-versus-harness mode switch in one bench script | claude-code-harness `benchmarks/breezing-bench/run.sh:41-53` | with and without, same task | the shape of the first eval |
| one spec built by several kits and the artifacts graded on an evidence rubric | `natea/harness-eval` (candidate set) | the only cross-kit method found | the shape of a real comparison, the gap in root cause B |
| structural pin tests over generated prompts | gstack `test/run-in-background-guidance.test.ts` | an invariant across every prompt is one test | one test per invariant |

## 8 · Commands and safety

| Mechanism | Source | What it does there | Cost here |
|---|---|---|---|
| a high-tier deny limited to catastrophic simple commands, token-based, with a 66-case test file | gstack `careful/bin/check-careful.sh` | no regex over compound commands | the shape of the first `guard-commands` entry, when an incident earns one |
| a blast-radius check before adding a defence layer: strongest layer, narrowest scope, who legitimately reads the path, never close the escape hatch in the same change | claude-code-harness `.claude/rules/defense-layer-blast-radius.md:1-29` | born from two same-day incidents | a rule line beside D-11 |
| advisory results never pre-empt a later deny | claude-code-harness `go/internal/policy/rules.go:607-630` | a convenience approve waits for every rule | minutes, in any multi-check hook |
| secret-file reads denied by a `PreToolUse` hook on Read, Grep, and Bash | GSD core `hooks/gsd-secret-read-guard.js:12-21, 932` | the read side of `guard-secrets` | about 150 lines; a decision, since the kit guards writes only |
| worktree removal refusal: list the untracked files and ask, never `--force` | Superpowers `skills/finishing-a-development-branch/SKILL.md:177-198` | matches "confirm before anything irreversible" | a rule line |
| refuse to merge an agent branch that deletes tracked files; check for unexpected deletions after every commit | GSD legacy `workflows/execute-phase.md:779`; `agents/gsd-executor.md` | matches the `--diff-filter=D` trap already recorded | a few lines in the review step |
| a commit trailer naming the agent, the model, and the autonomy level | Spec Kit `AGENTS.md:513-520` | provenance in the log | trivial |
| question budgets with a recommended option: at most three open markers at spec time, five questions in clarify | Spec Kit `templates/commands/specify.md:128`; `clarify.md:129-138, 154-165` | matches "only the questions whose answer changes what gets built" | a number beside that line |
| surface added scope and pause; mark done only when fully implemented | OpenSpec `skills/openspec-apply-change/SKILL.md:102, 173-174` | the stop-list's "scope growing" line with a shape | two lines |
| re-read the owning file from disk at the acting step; an earlier read does not satisfy it | Compound Engineering `skills/ce-work/SKILL.md:18`; OpenSpec `propose:98` | the compaction trap for path-scoped rules, stated as a rule | one sentence |
| two worktree traps: `refs/stash` is shared across linked worktrees; `git clean` in a fresh worktree deletes | GSD legacy `agents/gsd-executor.md:532-577` | measured incidents | two entries in `working-here.md` |

## What not to take, and why

Each pattern was found in at least one studied tree; the reason is the kit's own rule it would break.

1. **Prose presented as enforcement.** "HARD-GATE", "Iron Law", "frozen", "absolutely
   prohibited", "non-overridable": every one is a request in the tree that carries it. The kit's
   rule is that a claim of protection it does not have is the failure it exists to catch.
2. **A rule that exists in name only.** The harness's R14 returns nil; GSD core registers hooks
   that no-op until a flag is set. Register nothing that is not built.
3. **A guard that fails open** when its engine is missing or its input is unparseable.
4. **Safety that is off until invoked and gone at session end** (gstack's `/careful`, `/freeze`,
   `/guard`). A guard with a switch is advice.
5. **Defaults that strip the host's own permission prompts:** `--yolo` and `--always-approve`
   added by a workflow runner, `bypassPermissions` shipped for teams and pinned in CI, "YOLO
   (Recommended)", `allowed-tools` pre-approving `archive --yes`, a skill whose invocation is
   consent to send the diff to another provider. Each collides with confirm-before.
6. **Auto-commits that sweep the working tree** (`git add .`, `git add -A --no-verify`). The
   opposite of WIP ownership.
7. **Surface sprawl:** 53 to 72 commands, 40 to 48 host adapters, per-host template compilation,
   the same script shipped six times, a 1,100-line preamble before a skill's first step. The
   line budget is the defence, and it is enforced.
8. **A model merging customized files on update**, which then needs a deterministic verifier
   because content was lost. Overwrite with a backup, or skip.
9. **Telemetry on by default (OpenSpec), or a skill that fetches from the maintainer's domain
   (Superpowers' visual companion).**
10. **Persona agents with greetings and menus, and manufactured finding floors** ("if you have
    zero findings, keep thinking"). BMAD's own A/B found persona framing changed nothing; a review
    that must find something cannot report a clean pass.
11. **String-presence tests on rule text as the harness's test suite**, and test suites that
    never run. A test that proves a sentence exists proves nothing about behaviour.
12. **A SessionStart hook that pulls `main` hourly.** Supply-chain exposure on every session.
13. **Unattended tracker writes and push-and-pull-request pipelines.** Every push here publishes.
