---
title: The measured harness facts from a prior installation that changed this kit's design
status: verified
as_of: 2026-08-24
last_verified: 2026-09-05
verification_method: The page "harness-standards" in the older of the two private knowledge bases was read on 2026-09-05. Each fact below is the source's own measurement on its estate, dated by the source. None was re-measured on this repository
scope: The facts that shaped decisions D-03, D-09, and D-12. Not the source's project-specific entries, which stay private
confidence: High that the source recorded these. Medium that each still holds on the current Claude Code version; several are version-sensitive and are re-tested in Phase 4
known_gaps: The source's Azure DevOps and NTLM findings were skipped as project-specific. The Anthropic research figures it quotes were not traced to their origin
reverify_when: On a Claude Code version change, and after Phase 4's acceptance results
---

Each line: the fact, the source's date, and what it changed here. Labels are the source's own
verification, as read.

| Fact | Source's evidence | Changed here |
|---|---|---|
| On a desktop-app install there is no `/plugin` command and no `claude` executable on `PATH` | measured 2026-08-14 | plugin packaging is off the table; install is a copy (D-03) |
| A custom output style drops Claude's engineering instructions unless `keep-coding-instructions: true`, and that defaults to false | verified in the docs by the source, 2026-08-24 | the writing rule is a rule, not a style (D-09) |
| A rule present in both a harness source and the installed copy drifts, and bootstrap silently reverts the newer copy | drift found 2026-08-15 by going to look, not by any check | no mirror in any shape (D-02) |
| A hook matching `Bash` alone misses commands that run through PowerShell on Windows | measured on the source's estate, 2026-08 | every guard matches both shells (D-03) |
| Hook `timeout` is in seconds; widely copied recipes set 30000 | same | hook settings are exec-form with small timeouts |
| The first character of a hook's stdout decides parsing: `{` means JSON, anything else plain text; a shell profile that echoes breaks every JSON hook silently | same | hooks keep stdout quiet |
| Normalise path separators in any hook that matches file paths | same | in every hook |
| A `Stop` hook that dies on an ordinary git warning under `$ErrorActionPreference = 'Stop'` ends the turn normally while the status line says the check ran | measured 2026-08 | never redirect native stderr under Stop; test every hook against a known-bad tree |
| `CLAUDE.md` under 200 lines, per the official guidance the source quotes; every rule line is a recurring cost; `@` imports load in full and do not reduce context; a skill's rendered content stays in context for the session | source's reading of the docs, 2026-08 | the 200-line kit budget and the 300-line ratchet (D-03) |
| `/goal <condition>` is a separate evaluator that re-checks after every turn; a `Stop` hook is overridden after eight consecutive blocks and must honour `stop_hook_active` | source's reading of the docs, 2026-08 | `/goal` pairs with the brief file; the Stop hook loop guard |
| Checkpointing does not track files changed by shell commands and does not restore subagent edits; git is the real undo | source's reading of the docs, 2026-08 | commit before any autonomous run, in `/work` |
| A "propose first" rule lost to a direct "log this on the board" instruction on the day it shipped; advice-shaped prose loses that contest | measured 2026-08-15 | tracker writes are a separate propose-and-stop skill; enforcement only where damage is irreversible and silent |
| `disable-model-invocation: true` gives a skill zero idle context cost and makes it structurally incapable of firing unbidden | source's reading of the docs | every side-effecting skill in the kit carries it |
| Claude Code already ships `/code-review`, `/security-review`, `/run`, `/verify`, `/doctor`; do not rebuild them | 2026-08 | `/code-review` and `/run` are referenced, not shipped (D-05) |
| Neither guides nor sensors reliably catch issue misdiagnosis, unnecessary features, or plain instruction misunderstanding; those stay human | the source's closing limit | the human keeps direction and the one yes (D-04) |
