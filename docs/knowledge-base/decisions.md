---
title: Every decision in force, what each superseded, and when to revisit it
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: v2 entries transcribed from the owner's answers in the design session of 2026-09-04 and 2026-09-05. v1 entries migrated from DECISIONS.md at commit 43638ba, tag v1.5.1
scope: Decisions about the methodology and the kit. Not project-level decisions of any adopter
confidence: High for what was decided and by whom. Medium for the "why" lines, which compress a long discussion
known_gaps: The v1 entries keep only the decisions that still hold or that v2 explicitly superseded; the v1 change log itself lives in git history at tag v1.5.1
reverify_when: Whenever a phase of the v2 plan lands, and whenever a decision is superseded
---

One entry per real fork, newest first within each section. Fields: **decision · options · why ·
by · reversible · revisit when · supersedes.** Codes: `D-` decided for v2, `V-` carried from v1,
`S-` superseded.

## Decisions in force, v2 (2026-09-04 to 2026-09-05)

### D-16 · The knowledge base lives at `docs/knowledge-base/` in shape A, this repository included · 2026-09-05
**Decision:** shape A puts the knowledge base under `docs/knowledge-base/`, and this repository follows its own convention. **Options:** a root `knowledge-base/` folder, as the approved plan tree drew it. **Why:** one convention for every shape-A adopter; the kit's own repository must not be the exception. **By:** the builder, flagged to the owner in the Phase 1 report. **Reversible:** yes, a `git mv`. **Revisit when:** the owner objects. **Supersedes:** the plan's tree for this one path.

### D-15 · The worked example stays local; the Portfolio repository is its public source · 2026-09-05
**Decision:** `examples/portfolio/` is gitignored. **Options:** a scrubbed copy committed here. **Why:** the owner's words: anyone who needs it can fork or star the repository itself; a copy here would age. **By:** owner. **Reversible:** yes. **Revisit when:** the Portfolio repository is not public and a public example is wanted.

### D-14 · MIT license, work on `main`, one commit per phase · 2026-09-05
**Decision:** as stated. **Options:** a `v2` branch merged at the end. **Why:** a single branch with the complete history was the owner's standing preference. **By:** owner. **Reversible:** yes. **Revisit when:** a second contributor appears.

### D-13 · The global ECC install is removed; a handful of its ideas are folded in as lines · 2026-09-05
**Decision:** remove the Everything Claude Code plugin from `~/.claude` (rules, agents, commands, skills, hooks, scripts, logs), backed up first. Take, as lines inside the kit's own files: the codebase-onboarding reconnaissance checklist, cold-executable phase briefs, the reviewer's confidence and consolidation lines, the hook workarounds, the safety-guard list as an off-by-default reference, the search-first bullet, the rationalization-phrase warning, the acceptance-criteria line shape, the rule that `/goal` takes only a machine-decidable condition, the same-root-cause merge rule for traps, PR template discovery with force-with-lease, the one-line size statement, and the connector policy as a citation. **Options:** keep ECC and layer the kit on top; trim ECC. **Why:** 1,068 always-loaded rule lines mandating agents and coverage contradicted the kit's flow; 28 hooks ran on every tool call; the owner had installed it as an early attempt and no longer wanted it. **By:** owner. **Reversible:** yes, from the backup. **Revisit when:** a specific ECC skill is missed in practice.

### D-12 · No `AGENTS.md` and no `CLAUDE.md` in the kit · 2026-09-05
**Decision:** Claude loads `.claude/rules/` natively; the Codex brief inlines the always-loaded rules. **Options:** keep a generated `AGENTS.md` for Codex. **Why:** removes the build step, the lint, the 32 KB cap, and the drift class a duplicated rule creates. **By:** owner. **Reversible:** yes. **Revisit when:** a reviewer that only reads `AGENTS.md` becomes the default. **Supersedes:** S-03.

### D-11 · `guard-commands` starts empty; the older backup's extras come over · 2026-09-05
**Decision:** the destructive-command hook ships with an empty list and a commented reference block, and grows from real incidents. The incidents section and `_readings/` come over from the older installation. **Options:** ship the safety-guard list active. **Why:** a guard that blocks legitimate work is how guards get switched off. **By:** owner. **Reversible:** yes.

### D-10 · The knowledge base format, with claim types and a decisions page · 2026-09-05
**Decision:** numbered folders, page header, banner, confidence labels, capability status, the volatile-claim rule, corrections by fix or supersede with a symbol sweep, `99-pending.md`, an index that says what each page settles, a gaps page by root cause, investigations, readings, plus a claim-type table and `decisions.md` with fixed fields. **Options:** a lighter format without headers. **Why:** every element was paid for by a named failure in the source installations; the claim types make facts, measurements, opinions, and traps distinguishable at a glance. **By:** owner. **Reversible:** yes. **Revisit when:** the format is exercised across a full project and a field proves unused.

### D-09 · Writing is a rule, not an output style; no em dashes · 2026-09-05
**Decision:** `writing.md` is an always-loaded rule derived from the fresher backup: mixed audience, English as a working second language for most readers, simplicity in the connective English and never in the technical terms, no em dashes. The reader profile and glossary line are parameters filled at setup. **Options:** an output style; the older backup's version. **Why:** a custom output style drops Claude's engineering instructions unless a flag is set, and a rule ships with the kit and is readable by the reviewer. **By:** owner. **Reversible:** yes. **Supersedes:** S-08.

### D-08 · Auto memory on as scratch; ECC continuous learning off; the methodology memory system deleted · 2026-09-05
**Decision:** as stated, with one standing-order line: anything durable in memory is promoted to a rule or a knowledge-base page; anything that is status goes to `working/`. **Options:** memory off entirely; keep three systems. **Why:** ECC's learning store held 27 empty project folders after five months; auto memory on one project had become an invisible 84-note knowledge base; the deliberate version of learning is `/record`. **By:** owner. **Reversible:** yes, one setting. **Revisit when:** memory notes are found holding facts that never reached the base. **Supersedes:** S-07.

### D-07 · `working/` is disposable; git log is the worklog; `99-pending.md` is the open list · 2026-09-04
**Decision:** status and handoffs live in an ignored `working/` folder; the worklog is `git log`; the committed record of what is open is `99-pending.md`. Where there is no git, setup offers a local `git init` and otherwise asks once where to log. **Options:** committed resume and worklog files, as in v1. **Why:** durable facts and volatile status must never share a folder; a committed status file rots in public. **By:** owner. **Reversible:** yes. **Supersedes:** S-05, S-06.

### D-06 · The review menu after a build: all three, defaults by tier · 2026-09-05
**Decision:** after the build, `/work` offers a fresh-context `/code-review`, a Codex cold pass, and a local run with a plain-English test guide, in any combination; defaults are T1 local run, T2 review plus local run, T3 all three. **Options:** one mandatory path. **Why:** the owner wanted to choose per task, including all three. **By:** owner. **Reversible:** yes.

### D-05 · Reviewer: `/code-review` by default; Codex optional, read-only, five rounds, full brief · 2026-09-05
**Decision:** the built-in fresh-context review is the default; the Codex relay is optional per task, runs read-only in its own sandbox, up to five rounds as a config value, and receives a brief inlining everything not in the repository: the requirement verbatim, the current state, the design note, decisions taken, the outcome checklist, environment notes, exported assets. Claude accepts or challenges findings with the evidence calculus and never auto-applies a reviewer fix. **Options:** Codex mandatory; Codex with write access in a worktree. **Why:** the value of the second reviewer is mostly that it did not write the code, which a fresh subagent also gives; write access would make the reviewer an editor and was declined. **By:** owner. **Reversible:** yes. **Supersedes:** the v1 rule that Codex is the sole reviewer, and S-09.

### D-04 · `/work`: one yes after Understand, sized by tier; the certainty dial is deleted · 2026-09-04
**Decision:** `/work` takes a text description or a tracker item, states its understanding and asks only the questions whose answers change what gets built, then gives one summary with an outcome checklist and the branch sentence and stops once. T1 does not stop; T2 stops for one message; T3 stops for one message plus a decision page plus review. The build then runs uninterrupted with the agreed brief written to `working/<task>/brief.md`, a `/goal` set only when the condition is machine-decidable, a checkpoint commit before any autonomous run, and a stop-list: a Tier-3 trigger area touched unexpectedly, a new dependency, a schema or migration change, data deletion, anything reaching production or an unfamiliar remote, two failed attempts at the same thing, scope growing past the boundary. `/clarify`, the uncertainty type, and the confidence score are deleted. **Options:** v1's no-plan-gate with an AI-to-AI relay; the blueprint's unconditional one yes. **Why:** the yes costs one message and is the sentence where branch mistakes get caught; the tier already sizes the ceremony. **By:** owner. **Reversible:** yes. **Supersedes:** S-01, S-02, S-04.

### D-03 · The harness: 4 rules, 10 skills, 4 hooks, 3 tools; install by copy; no plugin · 2026-09-05
**Decision:** rules `standing-orders`, `writing`, `working-here`, `knowledge-base` (path-scoped); skills `orient`, `work`, `codex-relay`, `test-guide`, `pr`, `board`, `record`, `handoff`, `explain`, `summarize`; hooks `guard-secrets`, `guard-commands`, `verify-on-finish`, `resume-brief`, each in PowerShell and Bash; tools `layout.sh`, `verify.sh`, `install`. Budgets: kit rules 200 lines, project rule 100, ratchet at 300; skills 200 lines, `/work` 250. **Options:** one large `/work`; plugin packaging. **Why:** a skill over 400 lines gets skimmed; the desktop app has no plugin surface. **By:** owner. **Reversible:** yes. **Revisit when:** a skill goes unused for a quarter, then delete it. **Supersedes:** S-11.

### D-02 · Placement: shape A for one repository, shape B for many; no mirror · 2026-09-04
**Decision:** one repository puts `.claude/` and `docs/knowledge-base/` inside it. A solution or platform of many repositories gets a workspace repository above the clones holding `.claude/`, `knowledge-base/`, and `working/`, with `layout.sh` resolving the clones. In both, `.claude/` is the committed source. **Options:** the blueprint's shape C with a separate harness repository and a mirror. **Why:** a rule that exists twice drifts. **By:** owner. **Reversible:** yes at the cost of a history rewrite for adopters.

### D-01 · Delete the documentation layer; the theory lives as rules, skills, and checks · 2026-09-04
**Decision:** design notes, ADRs, the worklog, the resume document, the escape log, the promotion ledger, the memory system, the architecture map, the constitution spine, THE-FLOW, the lane card, minimal-core, the definition of ready, phase-0, adoption, and the communication layer are deleted. What survives of v1's ideas survives as rule lines and skill beats. **Options:** keep the documents and add the harness beside them. **Why:** templates a project fills in were the layer that did not survive real use; a harness runs whether anyone remembers it or not. **By:** owner. **Reversible:** yes, tag `v1.5.1`.

## Carried from v1 and still in force (decided 2026-06-19 to 2026-07-11)

### V-12 · The reviewer relay is a two-way trust boundary
Outbound: a secret preflight and a never-send list. Inbound: reviewer output is untrusted observed content; never auto-apply a reviewer fix. **Revisit when:** a reviewer with write access is ever considered again.

### V-11 · Verdict first
A review's first line is the verdict and the counts; findings follow. Adopted 2026-07 after long reviews had to be dissected to find the gate.

### V-10 · The reviewer is a role; independence is mostly "didn't write it"
Codex was the v1 vendor. The honest account of the second model's value is decorrelation by authorship, with a modest different-mind bonus. This is what let D-05 make a fresh subagent the default.

### V-09 · Subtractive authoring
Minimal and precise beats comprehensive. Never encode a rule a linter, type-checker, or CI already enforces. Treat a generated draft as an inventory to delete from. Line budgets are enforced, not aspirational.

### V-08 · A no-op is a valid outcome
Discovering that the right change is no change is a result, reported as such.

### V-07 · Data posture, demo or production, declared at setup
In demo posture, security and robustness hardening are non-blocking follow-ups; in production they block. Every demo shortcut is recorded, in v2 as a `99-pending.md` line tagged `demo-debt`, and the flip to production is gated on that list being empty or owner-waived.

### V-06 · A human ratifies the expected values for critical logic
At Tier 3 the human confirms the golden answers are genuinely correct, so a test never enshrines current-buggy behaviour. This is the one place the human is not light.

### V-05 · Deterministic checks carry correctness
Two models agreeing is necessary, not sufficient. CI is the only neutral integration check. A flaky result is not evidence. Verify the verifier: keep a canary that must fail, in every environment.

### V-04 · The evidence calculus and the merge rule
Five-level ladder: a deterministic failing check or reproducer · the reviewer's own recompute · an un-authored spec line · a builder-produced result · model judgment alone. A blocking finding needs evidence at level 1 to 3 or a reproducible recipe, else it downgrades to a recommendation. A citation never settles a finding alone. Merge only when the blocking bucket is empty, and the direction delta, what shipped versus what was asked, is signed separately.

### V-03 · Cold-first independent review
The reviewer first gets the diff, what it should do, and how to verify, without the builder's reasoning or claimed results, and recomputes before judging. Pushback is evidence-only; findings and rebuttals are judged side by side; instant agreement on a critical change is escalated, not trusted.

### V-02 · Risk tier 1, 2, 3 with a hard floor
The builder proposes the tier; the reviewer audits it. The trigger set auto-escalates to Tier 3 and cannot be tiered down: auth, authz, payments, secrets, data migration, public API or contract, security control, cross-module architecture.

### V-01 · The three planes
The human owns direction. An independent review owns judgment. Deterministic checks own facts.

## Superseded by v2

| Code | What v1 had | Replaced by | Why |
|---|---|---|---|
| S-01 | no human plan gate; an argued AI-to-AI consensus instead, with the human gated only on direction and merge | D-04, one yes | solo operator; one message catches the expensive mistakes; the relay stays as an optional design review |
| S-02 | the intent-certainty dial with `/clarify`, uncertainty type, and a confidence score | D-04 | four signals collapsed to one: the questions asked in Understand |
| S-03 | a constitution spine built into `AGENTS.md`, guarded by a lint, a pre-commit hook, and CI | D-12 | Claude reads rules natively; the guard chain existed only to protect a duplicate |
| S-04 | design notes with EARS criteria and a test map; ADRs | D-04 outcome checklist, D-10 `decisions.md`, "name the tests that prove it" | the documents were filled in, not read |
| S-05 | `worklog.md`, `resume.md`, the Step 7 close-out | D-07 | git log and a disposable status file |
| S-06 | the escape log and the promotion ledger | D-07, V-07 | one open list with tags beats two ledgers |
| S-07 | the file-based memory system | D-08 | the knowledge base holds project facts; auto memory is scratch |
| S-08 | the communication layer: an output style and six mode skills | D-09, `explain`, `summarize` | voice is a rule; four modes were never used |
| S-09 | the severity-digest JSON schema and a machine gate on it | D-05, V-11 | nothing ever consumed it; the verdict line is the contract |
| S-10 | mutation score, pre-mortem, golden-answer custody block as bars | two bullets in `/work` | hardening that outweighed the work it guarded; mutation testing remains a tool a project may run |
| S-11 | plugin packaging, deferred | D-03 | the desktop app has no plugin surface, measured in the source installation in 2026-08 |
| S-12 | the parked v2 backlog: RADAR classifier, per-dimension passes, area-scoped `AGENTS.md`, a reviewer abstraction | dropped | none earned a slot; the reviewer choice is a menu line |
