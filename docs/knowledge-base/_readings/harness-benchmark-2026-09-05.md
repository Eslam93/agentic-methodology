---
title: What nine coding-agent methodology repositories actually enforce, what each can stop, and where this kit stands beside them, measured 2026-09-05
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Shallow clones at the commits listed in ../_investigations/2026-09-05-benchmark/methodology.md, each read by one study agent against a nineteen-item rubric and then by an adversarial agent told to overturn every verdict; where the second agent overturned a classification, this page carries the corrected one. Every statement names a path at that commit. Branch protection read with gh api on the public branch and rules endpoints. Nothing was installed or run
scope: The nine repositories the external review named, and this kit at bac12dc: what each is, what each can mechanically stop, the claims the review made about each, and the tier each sits in per dimension. Not effectiveness: no repository was run and no outcome was measured
confidence: High for what each tree contains, each with a citation. Medium for the "can stop" sentences on hosts other than Claude Code, and for any hook shape the current Claude Code was not observed to honour. The tier placements are two agents' judgement from the reports and are labelled as such
known_gaps: Nothing executed; no issue tracker read; no user report read; adopter-side install footprints not measured; pull-request review requirements are not visible without admin scope. Whether the current Claude Code honours every declared hook shape is untested
reverify_when: On the next release of any listed repository, and before citing any count as current
---

## The taxonomy this page uses

Every review of these repositories, including the one this study answers, puts the word
"guardrail" on very different things. This page classifies each mechanism as exactly one of:

| Class | Means |
|---|---|
| instruction | prose in a prompt, rule, or skill; nothing stops the model ignoring it |
| advisory-hook | a host hook that prints or warns and cannot block |
| pre-action-deny | a hook or binary that blocks a tool call before it runs: exit 2, a deny or ask decision, a permission rule |
| post-action-detect | detection after the fact: a Stop hook, a post-tool check, CI that goes red |
| merge-gate | a required status check or ruleset that stops a merge |
| audit-log | a record for later review; no blocking |
| containment | sandbox, read-only mode, worktree isolation, denied paths, egress limits |

"Can stop" below means: on an adopter's machine, in the model's own session, by pre-action-deny,
post-action-detect, or containment. What protects the kit's own repository is listed separately
under the gates table, because it protects the maintainer, not the adopter.

## The set at a glance

Line counts are `wc -l` on the clone. "Always loaded" is what an adopter's every session carries
from the kit (a `CLAUDE.md`, `AGENTS.md`, or injected bootstrap), not what a skill loads on use.

| System | What it is, measured | Always loaded | Skills or commands | Runtime needs |
|---|---|---:|---:|---|
| Superpowers `b36e0829` | 14 Markdown skills (3,377 lines) and one SessionStart injector per host | 69 injected | 14 | bash |
| Spec Kit `4a7341a9` | a Python CLI copying 10 prompt files (2,437 lines) into a project for 41 integrations, with an extension, preset, bundle, and workflow platform (`src/` 55,918 lines, `tests/` 86,232) | 0 | 10 | Python 3.11+ |
| gstack `0d1bd561` | 53 template-generated skills plus a router (37,645 lines, a 430-line preamble in each), a 58 MB compiled Bun and Playwright browser daemon, 82 helper binaries, ten host adapters | 1,010 by its own accounting of skill front matter | 53 | Bun, git, jq in 22 skills, gh |
| OpenSpec `e062b957` | a Node CLI (44,472 TypeScript lines) scaffolding a change folder and rendering 12 prompt-only skills into 40 tools | 0 | 12 | Node 20.19+ |
| BMAD `05bfbd46` | 30 prompt skills plus 20 shims and 5 persona agents, delivered by a 15,887-line installer into 48 tool folders | 25 | 30 | Node 20.12+, uv and Python 3.11+ |
| Compound Engineering `57e409e5` | 33 skills: 2,104 lines of kernels, 30,656 of references, 38,861 of bundled scripts, on 14 hosts through per-host manifests | 0 | 33 | bash, python3, node |
| GSD legacy `bdcaab2c`, archived | 67 commands, 33 agents, about 62,000 lines of prose, an 11,376-line installer | 0 on install, 12 after `new-project` | 67 | Node 22+ |
| GSD core `e8800287` | 72 command and skill wrappers, 35 agents, 41,059 lines of workflow prose converted into 19 runtimes, a 5,071-line CLI, five deny hooks, a 14,153-line installer | 84 and up | 72 | Node 24+ |
| claude-code-harness `dadbfff3` | a Go policy engine (47,810 lines, 51,244 of tests) behind a 625-line `hooks.json` of 71 entries on 27 events, 23 skills, 225 scripts, four 13 MB binaries committed | 411 after setup; 765 on itself | 23 | the Go binary, bash, jq; node and python for scripts |
| this kit `bac12dc` | 4 rules, 10 skills, 4 hooks in two shells, 3 tools | 274 | 10 | bash or PowerShell, git |

## The repositories' own gates, read 2026-09-05

`gh api repos/<o>/<r>/branches/<default>` and `rules/branches/<default>`; review requirements
are not exposed without admin scope and are not stated here.

| Repository | Required status checks | Rulesets on the default branch |
|---|---|---|
| Superpowers | none | deletion and force-push blocked |
| Spec Kit | none | pull request required with zero approvals, squash only, Copilot review, CodeQL as a code-scanning gate |
| gstack | none classic; one through a ruleset (`free-tests`) | required status check |
| OpenSpec | three, enforced on everyone | none |
| BMAD | none | none |
| Compound Engineering | none | pull request required with zero approvals, deletion and force-push blocked |
| GSD core (`next`) | seven, for non-admins | none |
| GSD legacy | none | none |
| claude-code-harness | three, for non-admins | none |
| this kit | none | none |

## What each can stop, and what the review claimed

Claim ids are the external review's statements, listed in full on the external-review page.
Verdicts: holds · partly · refuted; "as instruction" means the text exists and nothing enforces it.

### Superpowers

Can stop: nothing. The only executable code touching a session is the bootstrap injector
(`hooks/session-start`, always exit 0) and three helper scripts; the design-approval "HARD-GATE"
(`skills/brainstorming/SKILL.md:14-20`), the TDD "Iron Law" (`test-driven-development/SKILL.md:33-35`),
the review verdicts, and the no-force-push rule are prose, and `using-superpowers/SKILL.md:63`
lets a user instruction override any of it. No CI workflow exists in the tree. Claims: S1, S2,
S4, S6, S9 hold; S3 and S7 hold as instruction only; S5 partly (nine hosts have adapter files,
four rest on README text); S8 partly (the with-versus-without test exists once in the tree; the
main eval harness is a separate repository and not in CI). Notable: `<SUBAGENT-STOP>` at
`using-superpowers/SKILL.md:6-8` tells every dispatched worker to ignore the bootstrap, so the
agents that edit and commit run outside the one rule the injector delivers. The release notes'
headline numbers have no data in the tree; the "94 percent" rejection rate in `CLAUDE.md:7`
recomputes to 82.5 percent from the API.

### Spec Kit

Can stop: nothing the model does in an adopter's project. The host-hook plumbing in
`src/specify_cli/events.py` ships zero handlers; every phase gate, "Pre-Execution Checks" block,
and constitution check is prose. The CLI confines its own writes and skips user-modified files on
upgrade through a SHA-256 manifest (`integrations/manifest.py:29-48`). Under `specify workflow run`
the CLI adds the host's permission-bypass flag by default for Copilot, Cursor, and Grok
(`copilot/__init__.py:57-66`, `cursor_agent/__init__.py:75-103`, `grok/__init__.py:43-53`), so
its net effect on stopping power there is negative. Claims: K1, K3 (41 integrations), K4 hold; K2
partly (the constitution is versioned and amendable, checked by prompt only); K5 partly (gates
are prose; the OpenSpec comparison is a README assertion).

### gstack

Can stop, on Claude Code only and only after the user turns a guard on for the session: an Edit
or Write outside a frozen directory, a simple `rm -r` of `/` or `~`, a simple force-push to the
default branch, a never-ask `AskUserQuestion`, a turn ending while a trusted verify command fails
(the first stop and three re-entries block, then it yields), and a push whose added lines hold a
high-severity secret, bypassable with `--no-verify`. The `/investigate` route wraps the freeze
script so that a missing script exits 0 silently, the opposite polarity from `/freeze`. The nine
other hosts strip the hooks (`hosts/define-host.ts:95-97`). The Think-Plan-Build-Review-Test-Ship-Reflect
order is not enforced; `/ship` never blocks on a missing plan review. Claims: G2, G3, G4, G6, G7
hold; G1 partly (53 skills plus a router, not 23); G5 partly (completeness over YAGNI is
verbatim, but a YAGNI check also exists at `plan-ceo-review/SKILL.md:1005`, and the conflict with
Superpowers is the review's inference). Notable: a `/ship` invocation loads about 1,100 lines
before its first step (`ship/SKILL.md:445`); a SessionStart hook pulls `main` hourly in team mode;
the quality bar is paid end-to-end runs with a model judge; updates stash local customizations and
discard edits to generated skills; the changelog records the guard hooks erroring on every call on
one Claude Code version (`#1871`).

### OpenSpec

Can stop, only through its own CLI: a malformed or scenario-dropping delta at `openspec validate`
or `openspec archive`, an archive with unchecked tasks unless `--yes`, and CLI writes outside its
root. The generated archive skills bypass that gate with a plain `mv`
(`skills/openspec-archive-change/SKILL.md:143`, `openspec-bulk-archive-change/SKILL.md:206`).
Every skill pre-approves `Bash(openspec:*)`, which covers `archive --yes` and `store remove --yes`.
Claims: O1, O3, O4 hold; O2 partly ("less ceremony than Spec Kit" is unmeasured). O3's
completeness, correctness, and coherence check is a same-session keyword search that runs no tests
and blocks nothing (`openspec-verify-change/SKILL.md:72-74, 155`). Notable: the feedback skill
with its "do not submit without confirmation" line is never generated for any tool; telemetry is on
by default; a non-interactive `init` deletes legacy prompt files under `$HOME` with no prompt.

### BMAD

Can stop: nothing in an adopter's session. No host hook, no settings file, and no git hook ships
(`.npmignore` excludes `.husky/`); `render_skill.py` exits 1 on a broken config only when the
model runs it as `SKILL.md:13` asks. Claims: B2, B3, B5, B7 hold as instruction; B1 and B4 partly
(testing is a lens, not a role; the frozen block is a tag the human edits, `step-02-plan.md:58`);
B6 refuted: the license is MIT text with appended contributor and trademark notices, which is why
GitHub reports NOASSERTION. Notable: `bmad-build/step-04-review.md:49, 57-60` routes each finding
to intent gap, bad spec, patch, or defer, and `:64` reverts, amends the spec, and re-derives;
`step-03-implement.md:21` writes a `baseline_commit` into the brief before any edit; the project's
own A/B found persona framing made no difference to reviewers (`CHANGELOG.md:74`); three test files
run nowhere; the updater overwrites customized files keeping `.bak` and deletes deselected modules
without asking; the external `bmad-loop` hook is a signal relay with no deny.

### Compound Engineering

Can stop: nothing in the adopter's session. The mechanical pieces run only when the model chooses
to run them: read-only sandbox flags for an external cross-model reviewer, isolated worktrees for
external workers, a findings filter that demotes an unquoted finding's confidence rather than
dropping it, and `ce-compound/scripts/validate-doc-claims.py`, whose flags the model adjudicates.
Claims: C1, C2, C3, C7 hold; C4 partly (the WIP rule is verbatim at
`ce-work/references/workspace-setup.md:23-25`, unenforced); C5 and C6 partly. Notable: the
counterfactual inclusion test is at `ce-compound/SKILL.md:20-24`; `tests/skill-eval-cell` grades
real CLI runs on artifacts with no model judge, but compares old prose against new prose rather
than with against without, is not in CI, and bills the user's subscriptions; `peer-job-runner.py`
is shipped six times, 14,790 lines, 38 percent of all bundled script lines; invoking the review
skill is itself the authorization to send the diff to another provider; `STRATEGY.md:36-37` states
"no telemetry, ever".

### GSD, archived and core

The archived repository carries 64,599 stars and one README line pointing at `open-gsd/gsd-core`;
its design (a thin orchestrator, fresh-context subagents, `STATE.md`, `CONTEXT.md`, `RESEARCH.md`,
`PLAN.md` as the substrate) is what core inherited; `context.md` is identical between the two,
`gsd-executor.md` differs in 241 lines. Legacy can stop one thing, a non-Conventional commit
message, only when `hooks.community` is on, only through the Bash tool, and not on Windows without
Bash. Core can stop: a secret-file read through Read, Grep, or Bash, a whole-file Write that
shrinks `ROADMAP.md` or `STATE.md` below 40 percent (`hooks/gsd-write-guard.js`), an absolute-path
edit outside an agent worktree, an unisolated executor dispatch, and with opt-ins a commit-message
or force-add violation. Every phase, verdict, and checkpoint is prose; the default mode is named
"YOLO (Recommended)" (`workflows/new-project.md:494`) and auto mode auto-approves human-verify
checkpoints (`references/checkpoints.md`, rule 5). Claims: D2, D3, L1, L2 hold; D1 partly (the
archive month is not exposed by the API; last push 2026-05-31); D4 partly (the only evidence is
one n=27 verifier experiment). Notable: eleven of thirty hooks declare a crash policy, with a
table test (`hooks/lib/hook-exit.js:30-36`); acceptance commands carry a stated failing direction
(`references/failing-direction.md`); the verifier may abstain (`PRESENT_BEHAVIOR_UNVERIFIED`,
`human_needed`); the exit-code registry separates "nothing in scope" (66) from "could not run"
(69); `/gsd:workspace --new` creates a directory of clones or worktrees of several repositories.

### claude-code-harness

Can stop, with the binary present and Claude Code as host: `sudo`, force-push, `--no-verify`,
`reset --hard` on `main`, staging or writing secret files, writes to `.git/`, hooks, shell rc
files, and its own config, billing CLIs, non-localhost egress unless `HARNESS_RUNTIME_FLOOR_EGRESS=off`,
shell reads of secret files unless allowlisted, publish and deploy commands unless
`runtimefloor.releaseAuto`, `rm -rf` outside the worktree, reviewer-role writes, and agent
self-approval of deferred deletes (`go/internal/runtimefloor/runtimefloor.go`,
`go/internal/policy/rules.go`); a write outside the project root and a push to `main` raise an
ask. The shim exits 0 with empty stdout when the binary is absent and the engine approves on
unparseable stdin, so it fails open. Test tampering is detected by sixteen patterns and never
denied (`policy/tampering.go:119-120`); the TDD rule R14 returns nil (`rules.go:131-133`) and
`[tdd.enforce]` is off by default. Claims: H1 holds; H2 holds in both halves (`README.md:95` "not
by any config, env var, or permission mode" against `runtimefloor.go:177-179`, plus `secretAllow`
and `releaseAuto`, which the repository enables on itself); H3 and H4 partly; H5 holds (3,088
stars, five contributors, one author of 94 percent of commits, 203 releases). Notable:
`policy/selfaudit.go` refuses to adjudicate when the deny surface has been narrowed, though both
sides are compiled into the same binary; plan-time preapprovals carry an expiry and a use count
(default ten) under a file lock, in a state file the agent itself may write; the audit log stores a
SHA-256 of the command, never the command; the spec promises a kill switch that no source file
implements; `bypassPermissions` is the shipped default for team mode and a CI consistency check
fails if it is removed.

## Where this kit stands, as measured facts

Can stop: a secret value written through Edit or Write, reading three payload fields; a turn
ending with a test weakened, skipped, or deleted relative to `HEAD`, for `D` and `M` diff codes;
nothing on the command list, which is empty by decision D-11. CI runs the verifier, the canary,
and the hook tests on every push but is not required to merge. Everything else is instruction.

Present here and in none of the nine: a blocking check on test weakening (the harness detects
and warns; the rest have prose); a verifier canary that must fail, run in CI; a hook test suite
that fires every hook in both shells on the adopter's install; a knowledge base whose every page
carries evidence, confidence, what-was-not-checked, and a re-verification trigger; a deployed-state
step at orientation. GSD's workspace command is the one other multi-repository mechanism found.

Present in most of the nine and absent here: an update path (Spec Kit and both GSDs keep a
SHA-256 manifest and skip or back up user-modified files; this kit is below every external system
on that axis); any behavioural evaluation of the kit's own prompts (four of nine have one, none in
CI); more than one host; an active-task pointer (GSD legacy keys its workstream flag by session;
the harness writes `.claude/state/active-task.json`); any orchestration of a second worker.

## Tiers by dimension

Two agents placed the ten systems from the reports and refutations; this is their judgement, with
the evidence in `working/benchmark-2026-09-05/reports/compare-*.md` on the owner's machine.

| Dimension | Top | Bottom | This kit |
|---|---|---|---|
| epistemic integrity: evidence, confidence, dates, not-checked | this kit, Compound Engineering, gstack, GSD core | Spec Kit, GSD legacy | top; the rules are the most complete, and none is checked by code |
| durable project knowledge | this kit, Compound Engineering, BMAD | Superpowers, Spec Kit | top on the written format; two systems check citations or log learnings in code |
| self-verification and honesty about limits | this kit, gstack, Compound Engineering, GSD core | Spec Kit, BMAD, GSD legacy | top; the only adopter-side canary; the README disagreed with the acceptance page at the tag |
| requirements and intent capture | OpenSpec, Spec Kit, BMAD, Compound Engineering | gstack | middle; the brief is unhashed, unmarked, disposable |
| context resilience | claude-code-harness, GSD core | BMAD, OpenSpec, Spec Kit | middle; the compaction hook is real and puts the brief back; no pointer, no cold workers |
| independent review design | Compound Engineering, BMAD, this kit, claude-code-harness | Spec Kit, OpenSpec | top on evidence-only pushback; weak on where a finding goes |
| implementation discipline | Compound Engineering, Superpowers | gstack, Spec Kit, OpenSpec | middle; the only blocking test protection, test-first for bugs only, no WIP rule |
| hard runtime enforcement | claude-code-harness, GSD core | Compound Engineering, OpenSpec, Spec Kit, BMAD, Superpowers | middle; two default-on blocking hooks, one armed and empty |
| large-work orchestration | GSD core, GSD legacy, BMAD | gstack, this kit | bottom; one paragraph on phases, in a disposable folder |
| multi-agent execution | GSD core, claude-code-harness, GSD legacy, Compound Engineering | Spec Kit, OpenSpec, this kit | bottom; the only second agent is a reviewer |
| human attention and interaction | this kit, OpenSpec, Superpowers | GSD core, GSD legacy, Spec Kit | top, shared |
| brownfield and multi-repository fit | GSD core, GSD legacy, this kit | Spec Kit | top, shared; the only deployed-state step and trunk-is-not-default rule |
| product, design, and visual QA | gstack | this kit, Spec Kit, OpenSpec | bottom; nothing drives a browser or reads a design |
| cross-agent portability | Spec Kit, OpenSpec, BMAD | this kit | bottom; one host |
| extensibility and ecosystem | Spec Kit, OpenSpec, BMAD | this kit | bottom; no plugin, no catalog, one contributor |
| install and update | Spec Kit, GSD core, GSD legacy, BMAD | this kit | bottom, below every external system |
| ceremony cost | Superpowers, OpenSpec (lightest) | gstack, claude-code-harness, GSD (heaviest) | middle; 274 lines every session, ten skills, two disposable files per task |
| evidence it works, in the tree | gstack, Compound Engineering | Spec Kit, BMAD | middle; every acceptance row quoted, one machine, no comparison |
| external use | Superpowers, Spec Kit, gstack | this kit | bottom; zero stars, zero forks, one contributor |

## Findings across the set

1. **Enforcement is rare and narrow.** Six of nine can stop nothing the model does in an
   adopter's session. Three can: the harness (widest, fails open without its binary), GSD core
   (five narrow denies), gstack (opt-in, session-scoped, Claude Code only). "Mandatory",
   "HARD-GATE", "Iron Law", "frozen", "absolutely prohibited", and "non-overridable" each describe
   prose somewhere in the set.
2. **Nobody blocks a weakened test.** The harness warns on sixteen patterns; everyone else asks.
   This kit's Stop hook is the only diff-based check on test content in the ten, and it has two
   blind spots of its own (external-review page, R1 and new finding 1).
3. **Nobody seals approved intent and refuses to proceed on a mismatch.** Partial forms: Compound
   Engineering records a plan digest on its external-worker route (`skills/ce-work/scripts/unit_workspace_lifecycle.py:94, 136`)
   to identify a run, not to stop an edit; gstack's review log may carry a plan hash and `/ship`
   may note "plan changed since review", as prose; the harness's preapprovals expire and count
   down; BMAD writes a `baseline_commit` into the brief. The nearest thing to a sealed brief is that
   last line.
4. **No system checks a claim's date or evidence.** Four check adjacent things: Compound
   Engineering's `validate-doc-claims.py` (paths exist, hashes resolve, links resolve; run only
   when the model runs it), both GSDs' codebase-map drift check, Spec Kit's doc-versus-shipped
   test in CI, Superpowers' version-drift audit.
5. **No eval gates CI.** Superpowers keeps its harness in another repository; Compound
   Engineering's cell compares prose versions; the harness bench is exploratory on a non-Claude
   model; gstack's is paid and model-judged; GSD's is one n=27 run.
6. **The manifest-with-hash update pattern appears three times** (Spec Kit, GSD legacy, GSD
   core) and the overwrite-with-backup pattern twice (BMAD, GSD core). Nothing three-way merges.
7. **Several defaults remove human gates:** Spec Kit's workflow runner adds bypass flags, the
   harness ships `bypassPermissions` for teams and pins it in CI, GSD recommends "YOLO", OpenSpec
   and GSD legacy pre-approve tool scopes in skill front matter, Compound Engineering treats
   invoking a skill as consent to send the diff elsewhere.
8. **WIP ownership is prose where it exists** (Compound Engineering, BMAD) and violated by code
   in two places (Spec Kit's git extension `git add .`; the harness's Cursor path `git add -A`
   with `--no-verify`).
9. **Stars do not track enforcement.** The three most-starred stop nothing (Superpowers), only
   on opt-in (gstack), or nothing in the adopter's project (Spec Kit).
10. **Always-loaded cost** runs from 0 (Spec Kit, OpenSpec, Compound Engineering) through 12 to
    84 (the GSDs) to about 1,000 (gstack, the harness on itself). This kit's 274 sits third
    heaviest on fixed load and light on everything else.

## The candidate set

The review's nine are the right core; the candidate search (38 queries, methodology page) found
four to add and one adjacent niche. Over 5,000 stars and in category: `affaan-m/ECC` (248,859;
23 hook commands across seven events, 286 skills; removed from this machine by D-13 for its
always-loaded cost, still the largest harness in the category), `addyosmani/agent-skills`
(92,326; nine lifecycle commands, "tests are proof"), `OthmanAdi/planning-with-files` (26,635;
plan files re-injected by hooks every turn, SHA-256 attested, a Stop gate; the direct comparator
for the unsealed brief), `buildermethods/agent-os` (5,374; standards extracted from the existing
codebase first). Under 5,000 and close to this kit's niche: `awslabs/aidlc-workflows` (one
harness-neutral core rendered to six hosts), `nizos/tdd-guard` (a hook that blocks edits out of
TDD order), `first-fluke/oh-my-agent` (a Stop hook that refuses to end until typecheck, test, and
lint exit 0), `natea/harness-eval` (builds one spec with four kits and grades the artifacts),
`gmickel/flow-next` (evidence JSON per task), `kenryu42/cc-safety-net` (a destructive-command
guard). No repository found pairs a knowledge base with confidence levels and a
what-was-not-checked field, and none over 500 stars describes itself as multi-repository; GSD's
workspace command is the nearest.

## Not checked

No repository was installed or run, so every "can stop" sentence describes code as read. In
particular: whether the current Claude Code honours a hook exiting non-zero but not 2, an `ask`
under `bypassPermissions`, an agent-type hook's deny, or a plugin-shipped settings file; and the
hooks page's list of blocking events does not include `PreCompact`, so the harness's compaction
block is a doc-unsupported claim. Issue trackers, user reports, token and time costs, and install
footprints were not read or measured. The full list, with what would settle each, is on the
methodology page.
