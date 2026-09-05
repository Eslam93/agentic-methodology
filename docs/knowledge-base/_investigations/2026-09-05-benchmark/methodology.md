---
title: The commands, commits, and agent runs behind every number on the 2026-09-05 benchmark pages, and what the benchmark left unverified
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Every row is a command run on the owner's Windows machine in Git Bash on 2026-09-05, or a read-only agent run whose full report is kept locally; outputs were recorded at the time
scope: The benchmark of nine external repositories and the verification of the external review's claims about this repository. Not the repositories' behaviour when run: nothing was installed or executed
confidence: High for every number, each read from a command's output. The agents' readings of the repositories are as good as their citations, and each citation names a file and line at a fixed commit that anyone can re-open
known_gaps: The full agent reports live in the disposable working/ folder, not in this base; the pages cite the commit and path so each claim can be re-derived without them. No repository was run. The session limit interrupted the first run; a second run finished the rest
reverify_when: Before quoting any star count, release, or line count as current; each is a measurement on 2026-09-05
---

## The clones

Shallow clones of each default branch on 2026-09-05, read only. Two needed `core.longpaths=true`
on Windows because their trees carry paths over 260 characters (OpenSpec, Compound Engineering).

| Repository | Commit studied | Commit date | Tracked files |
|---|---|---|---|
| `obra/superpowers` | `b36e0829` | 2026-08-12 | 195 |
| `github/spec-kit` | `4a7341a9` | 2026-09-04 | 557 |
| `garrytan/gstack` | `0d1bd561` | 2026-09-01 | 1,526 |
| `Fission-AI/OpenSpec` | `e062b957` | 2026-09-03 | 1,162 |
| `bmad-code-org/BMAD-METHOD` | `05bfbd46` | 2026-09-04 | 639 |
| `EveryInc/compound-engineering-plugin` | `57e409e5` | 2026-09-04 | 1,066 |
| `gsd-build/get-shit-done` (archived) | `bdcaab2c` | 2026-05-31 | 1,854 |
| `open-gsd/gsd-core` (default branch `next`) | `e8800287` | 2026-09-05 | 3,461 |
| `Chachamaru127/claude-code-harness` | `dadbfff3` | 2026-08-31 | 1,743 |

`git clone --depth 1 --quiet https://github.com/<owner>/<repo>`; file counts from `git ls-files | wc -l`.

## Public metrics, `gh api repos/<owner>/<repo>`, 2026-09-05

| Repository | Stars | Forks | Archived | Last push (UTC) | License field | Latest release |
|---|---:|---:|---|---|---|---|
| `obra/superpowers` | 281,888 | 25,249 | no | 2026-09-04 23:04 | MIT | v6.3.0, 2026-08-12 |
| `github/spec-kit` | 133,535 | 12,020 | no | 2026-09-04 11:51 | MIT | v1.0.4, 2026-09-02 |
| `garrytan/gstack` | 131,418 | 19,714 | no | 2026-09-04 23:06 | MIT | none on GitHub; `VERSION` 1.79.0.0 |
| `Fission-AI/OpenSpec` | 67,342 | 4,632 | no | 2026-09-04 19:27 | MIT | v1.12.0, 2026-09-03 |
| `bmad-code-org/BMAD-METHOD` | 52,686 | 5,981 | no | 2026-09-05 07:45 | NOASSERTION (MIT text with appended notices) | v6.12.0, 2026-09-04 |
| `EveryInc/compound-engineering-plugin` | 24,848 | 2,050 | no | 2026-09-04 21:20 | MIT | v3.24.0, 2026-08-31 |
| `gsd-build/get-shit-done` | 64,599 | 5,459 | yes | 2026-05-31 17:46 | MIT | v1.42.3, 2026-05-16 |
| `open-gsd/gsd-core` | 9,126 | 660 | no | 2026-09-05 08:17 | MIT | v1.12.0, 2026-08-30 |
| `Chachamaru127/claude-code-harness` | 3,088 | 301 | no | 2026-08-31 08:38 | MIT | v5.14.1, 2026-08-31 |
| `Eslam93/agentic-methodology` | 0 | 0 | no | 2026-09-05 08:20 | MIT | v2.0.0, 2026-09-05 |

Star counts drifted by a few units between calls made minutes apart (281,888 then 281,891 then
281,893 for Superpowers); the table keeps the first reading. `gh search repos` for
`claude-code-harness` and `gh search code HARNESS_RUNTIME_FLOOR_EGRESS` identified the harness
repository the external review named without a link.

## Branch protection, read once for all ten, 2026-09-05

`gh api repos/<o>/<r>/branches/<default>` (`.protected`, `.protection.required_status_checks`)
and `gh api repos/<o>/<r>/rules/branches/<default>`. Required checks: OpenSpec 3 (everyone), GSD
core 7 (non-admins), claude-code-harness 3 (non-admins), gstack 1 through a ruleset; none for
Superpowers, Spec Kit, BMAD, Compound Engineering, GSD legacy, and this repository. Rulesets:
Superpowers and Compound Engineering block deletion and force-push; Spec Kit and Compound
Engineering require a pull request with zero approvals; Spec Kit adds Copilot review and a CodeQL
code-scanning gate. Review requirements need admin scope and were not read.

## The agent runs

Two Workflow runs. The first, `wf_d756442c-357`, launched 24 agents: nine studies (one per
repository, a fixed nineteen-item rubric, the external review's claims embedded as hypotheses),
nine adversarial refutations (one per study, told to overturn every verdict against the clone),
one verification of the review's twenty claims about this repository, one Claude Code
documentation check, one candidate-set search (38 `gh search repos` queries), three dimension
comparisons, and one completeness critic. It completed 14 and lost 10 to the session limit at
12:16 local: 5,432,413 subagent tokens, 907 tool calls, 38 minutes. A resume re-ran finished
agents instead of replaying them and was stopped. The second run, `wf_1e7ab21c-81c`, launched the
eleven missing pieces with the finished summaries handed over as files: the harness study
completed from its own cut-off draft, five refutations, three comparisons, the critic. All eleven
completed: 3,531,516 subagent tokens, 509 tool calls, 43 minutes.

Every agent was read-only outside its report file, forbidden to run any installer or script, and
told to mark each statement by layer: what a document says, what a prompt instructs, what code or
a host hook can enforce. The refutations overturned eleven enforcement classifications and two
claim verdicts across the nine reports; the pages carry the corrected ones. The session re-opened
twenty of the takeaways page's citations itself and found three line ranges off by a few lines,
corrected on the page.

The reports, about 800 KB of Markdown with file-and-line citations, are kept at
`working/benchmark-2026-09-05/reports/` on the owner's machine. They are disposable: every claim
the pages carry cites the commit and path, so it can be re-derived from a fresh clone.

## This repository, verified the same day

| Measurement | Command | Result |
|---|---|---|
| head and tree | `git rev-parse HEAD`; `git status --porcelain` | `bac12dc`, clean, equal to `origin/main` by `git ls-remote` |
| the review's window | `git log --format='%h %ci' -12`; `git show 59d1a15 -- .claude/skills/work/SKILL.md`; `git diff --stat 76f4d60 HEAD -- README.md` | README unchanged since `76f4d60` 10:37 +0300; the route contradiction existed through `9081a79` 11:08 and was gone at `59d1a15` 11:19 |
| the Stop hook's window | scratch repository: commit a weakened test, then `git diff --name-status HEAD` | empty output; a staged rename printed `R091` |
| hook test cases | `hooks.test.sh` case_ calls | 15 per shell; 30 on Windows, 15 on Linux CI |
| always-loaded rule lines | `verify.sh` check 5 | 274 of 400 (methodology 36, standing-orders 89, working-here 73, writing 76) |
| `claude` executable | `which claude` | not on PATH; `codex` 0.144.3 is |
| desktop app plugin surface | `ls ~/.claude/plugins` | `known_marketplaces.json` naming `claude-plugins-official`, last updated 2026-09-02; a cached marketplace of 39 plugin folders |

## What the benchmark left unverified, and what would settle each

From the completeness critic, kept here because each is a limit of the method, not a fact about
a repository.

| Unverified | What would settle it | Cost |
|---|---|---|
| host semantics for a hook exiting non-zero but not 2; an `ask` under `bypassPermissions`; whether `PreCompact` can block; whether an agent-type hook's deny and a plugin-shipped settings file are honoured | one live Claude Code probe session in a scratch project | two to three hours |
| whether the `Edit\|Write` matcher fires on `MultiEdit` and `NotebookEdit` | the same probe session | included above |
| this kit's two Stop-hook blind spots have never been exercised | two cases in `hooks.test.sh`: a committed weakening and a `git mv` with a removed assertion | thirty minutes |
| pull-request review requirements on every default branch | admin-scoped API or the maintainers | not in our hands |
| every headline effect number in the set (Superpowers "twice as fast", BMAD's A/B, GSD's n=27, the harness's ablation on a non-Claude model) | the raw data, which is in no tree | not in our hands |
| what a `claude-code-harness` adopter actually receives; its Codex and Grok wiring, on which its own docs disagree | run `setup-existing-project.sh` and `harness gen` in a scratch clone | two hours, needs Codex CLI |
| the four candidate-set additions and the three repositories the set points at (`bmad-loop`, `superpowers-evals`, `planning-with-files`) | the same study shape, refuted the same way | one day each |
| any token or time cost; every "always loaded" figure is `wc -l` | capture the system prompt with and without the kit on one version | one hour |
| behavioural effect of any harness, this kit included | one with-versus-without run in the shape of Compound Engineering's eval cell: weaken a test, commit over dirty WIP, resume after compaction | half a day, paid runs |
| a second machine, a second operating system, shape B run as B | a Linux or second Windows run of `verify.sh`, `--hooks`, `--canary`, and acceptance rows 3, 5, 7, 15 | two hours plus the machine |
| the issue trackers, the one modality that would show prompt-only enforcement failing in the field | the last fifty closed and top twenty open issues of the five active repositories, coded by cause | three hours, `gh api` only |
