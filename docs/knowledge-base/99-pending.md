# Pending

Everything found and not acted on. One line each, written in the same turn, grouped by who can
act. `P0` blocks the current goal · `P1` matters soon · `P2` worth doing · `?` needs a decision.
This is the index of what is open, not the evidence for it.

## 1 · Only the owner can answer these

- `?` The standalone `communication-modes` repository still uses persistent-mode wording, and v2 deletes the modes altogether. Delete it, archive it, or leave it. Evidence: `decisions.md` S-08.
- `?` Tier 3 and the review menu: keep D-06 as written, or add "one independent review, or a recorded waiver" to the hard floor so the tier is a contract. Evidence: `_readings/external-review-2026-09-05.md`, R5.
- `?` Whether a per-task allow-list derived from the agreed brief (paths, repositories, the stop-list items) is a kind of rule D-11 admits, or a new decision for `decisions.md`. Evidence: the same page, recommendations table.
- `?` Whether `affaan-m/ECC`, `addyosmani/agent-skills`, `OthmanAdi/planning-with-files`, and `buildermethods/agent-os` join the benchmark set. Evidence: `_readings/harness-benchmark-2026-09-05.md`, the candidate set.
- `?` Whether the large-work and multi-agent axes, rated bottom on 2026-09-05, are declined by design for a solo operator or a gap to close; it decides whether phase briefs in a disposable `working/` folder are a choice or a defect. Evidence: the same page, tiers by dimension.

## 2 · Needs a decision

- `?` Whether `/document` and `/walkthrough` from the fresher installation join the kit. Not shipped in v2.0; add when a real use appears.
- `?` `production-audit` from `ecc` 2.2.1 as an optional review-menu item in production posture. Read, not evaluated.
- `?` D-03 and S-11 rest on "the desktop app has no plugin surface, measured 2026-08". On 2026-09-05 the desktop page documented plugin install and the local marketplace cache was dated 2026-09-02. Re-measure, then decide whether install-by-copy stands on other grounds. Evidence: `_readings/claude-code-docs-2026-09-05.md`.
- `?` Whether `guard-secrets` should read `MultiEdit` and `NotebookEdit` payload fields; first measure whether the `Edit|Write` matcher fires on them. Evidence: `_readings/external-review-2026-09-05.md`, new finding 3.
- `?` Whether a headless `claude -p` evaluation that bills the subscription is acceptable for one with-versus-without measurement of a skill, the gap in root cause B. Evidence: `_readings/harness-benchmark-takeaways-2026-09-05.md`, section 7.

## 3 · We can do these ourselves

- `P2` `explain` and `summarize` carry an `allowed-tools` list that reads as a restriction but only pre-approves those tools, and `Bash(cat *)` pre-approves a `cat >` overwrite. Drop the lists or say what they are for. Evidence: the front matter of `.claude/skills/explain/SKILL.md` and `.claude/skills/summarize/SKILL.md`, 2026-09-05.
- `P1` Promote or prune the auto-memory notes on the owner's other repositories: 84 notes on one project used as a knowledge base, 6 on the public site including two stale status notes. Evidence: the investigation page.
- `P2` Independent re-verification of the v1 research citations, deferred since 2026-06. Evidence: `_readings/evidence-base.md`.
- `P2` Codex now has its own hooks file format, seen in `ecc` 2.2.1. The secret preflight could run on the Codex side too. Not evaluated.
- `P1` `README.md:157-159` still says twelve of seventeen acceptance tests passed; all seventeen passed at `9081a79`. Same class: `00-orientation/start-here.md:8, 42` speak of the v2 plan as unfinished, and `index.md:50` still expects a risks page "after Phase 4". Evidence: `_readings/external-review-2026-09-05.md`, R9 and new finding 5.
- `P1` The Stop hook diffs against `HEAD` and handles `D` and `M` only: a weakening committed before the turn ends, and a staged rename that shrinks a test, both pass, and `hooks.test.sh` has no case for either. Fix from the brief's baseline commit; handle `R*`; add both cases. Evidence: the same page, R1 and new findings 1 and 8.
- `P1` `resume-brief` restores the newest `brief.md` by modification time and matches `working/relay/<task>/brief.md`, so a Codex relay run after the agreement replaces the task brief. Fix: an active-task pointer read first, and the relay folder excluded. Evidence: the same page, R2 and new finding 2.
- `P1` `/work` step 5 commits a checkpoint with no rule for files that were already dirty. Fix: inventory the tree before the first edit and commit only the task's paths. Evidence: the same page, R6; `_readings/harness-benchmark-takeaways-2026-09-05.md`, section 1.
- `P1` The agreed brief carries no approval time, baseline commit, or hash, so nothing shows later that the text built from is the text agreed. Evidence: the same page, R16.
- `P2` The limit line "No hook sees a browser, an MCP call, chat, or a shared folder" in `standing-orders.md`, `README.md`, and `START-HERE.md` is true of this kit's matchers and false of the platform: a `PreToolUse` matcher can name an MCP tool. Reword to "these hooks". Evidence: `_readings/claude-code-docs-2026-09-05.md`.
- `P2` `verify-on-finish` recognises JavaScript and C# test shapes only: a Go `_test.go` or a pytest file outside `tests/` is not a test to it, and `t.Errorf` never counts. State the limit in the README or widen the patterns. Evidence: `_readings/external-review-2026-09-05.md`, new finding 4.
- `P2` The README describes the hook test suite and the secret scan without two qualifications: 30 cases on Windows against 15 on Linux CI, and `.claude/hooks/` excluded from the scan by design. Evidence: the same page, new findings 6 and 7.
- `P2` A knowledge-base citation check in `verify.sh`: every cited path exists, every cited commit resolves, every link resolves; with its own canary. Evidence: `_readings/harness-benchmark-takeaways-2026-09-05.md`, section 4.
- `P2` An update path for adopters: a hash manifest written by `install.sh`, so a later run can overwrite unchanged kit files and skip modified ones. Evidence: the same page, section 6; R7.
- `P2` A drift audit for the counts the README states (rules, skills, hooks, tests passed), which would have caught the stale acceptance count. Evidence: the same page, section 2.
- `P2` The permissions allow and deny lists in settings: the documentation agent found none on the permissions page while a studied harness ships 22 deny entries in a plugin settings file. Read the settings reference directly before building on either. Evidence: `_readings/claude-code-docs-2026-09-05.md`.

## 4 · Worth doing when someone is in that code anyway

- `P2` The blueprint's `make-launch.sh`, which generates the browser-pane launch profile from the resolved layout, was not brought into the kit. Add it if a shape-B project needs `launch.json`.
- `P2` Two worktree traps measured by GSD, for `working-here.md` when the kit first uses a worktree: `refs/stash` is shared across linked worktrees, and `git clean` in a fresh worktree deletes what a linked checkout still needs. Evidence: `_readings/harness-benchmark-takeaways-2026-09-05.md`, section 8.
