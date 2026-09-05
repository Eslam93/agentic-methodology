---
title: The commits and commands behind every number cited by the v2 pages
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Each row is a command run on the owner's Windows machine in Git Bash on 2026-09-04 or 2026-09-05, with its output recorded at the time
scope: Measurements taken for the v2 rewrite. Private repositories are described by counts only
confidence: High. Every number was read from a command's output, not estimated
known_gaps: Nothing was measured on a second machine. The Claude Code documentation facts were read by a research subagent, not exercised
reverify_when: Before any of these numbers is quoted as current
---

## This repository

| Measurement | Command | Result | Commit |
|---|---|---|---|
| tracked files | `git ls-files \| wc -l` | 48 | `43638ba` |
| Markdown lines | `git ls-files '*.md' \| xargs wc -l` | 1,841 | `43638ba` |
| v1 lint | `sh lint-methodology.sh` | 0 errors, 1 expected warning | `43638ba` |
| remote, visibility, protection | `git remote -v`; `gh api repos/Eslam93/agentic-methodology`; `gh api .../branches/main/protection` | public, default branch `main`, 0 stars, last push 2026-06-23, `main` not protected (HTTP 404) | 2026-09-05 |
| v1 baseline commits made this session | `git log --oneline` | `40ff017` v1.4 and v1.5; `9fed62d` v1.5.1 drift fixes; `43638ba` resume update | 2026-09-04 |

## The three source installations (private; counts only)

| Installation | Read on | Rules | Skills | Hooks | Tools | Knowledge base |
|---|---|---|---|---|---|---|
| owner's public site, shape A, daily use since 2026-08 | 2026-09-04 | 4 files, 329 lines always loaded | 6 (orient 89 lines, record 82, handoff 50, deploy 88, explain 59, summarize 65) | 1 (secret guard, PowerShell) | `verify.sh` 212 lines, 17 checks | 4 pages, 473 lines; `working/` gitignored; no `CLAUDE.md` or `AGENTS.md` |
| older consultancy workspace, shape C, backup dated 2026-08 | 2026-09-05 | 4 files (writing 106, knowledge-base 80) | 13 (work 176, record 128) | 4 (guard-commands, guard-mirror, guard-secrets, verify-on-finish) | verify skill | about 100 pages including a 431-line harness-standards page and a 179-line reading of v1 |
| fresher consultancy workspace, shape C, backup dated 2026-09 | 2026-09-05 | 8 files, 830 lines (standing-orders 105, writing 107, working-here 166, knowledge-base 117, repos 86, backend 81, frontend 90, shell-and-hosts 78) | 12, 1,449 lines (work 274, record 159, ado 148, update-board 219) | 2 (guard-secrets 109, verify-on-finish 182) | layout 114, verify 490, make-launch 150, launch-profiles 74; bootstrap 682 | 27 pages |

Both consultancy `writing.md` files carry the clause that most readers use English as a working
second language. A search of the owner's global configuration and the three installations for a
non-native-speaker clause on 2026-09-05 found it in those two files only.

## The global ECC install, measured before removal

| Measurement | Result |
|---|---|
| origin | Everything Claude Code plugin 1.10.0 by Affaan Mustafa; file dates 2026-04-08 |
| rules | 5,390 lines in 78 files; 1,068 always loaded (`common/` 534 and `web/` 534, the latter lacking a `paths:` block); 4,211 path-scoped |
| hooks | 28 entries in `~/.claude/settings.json` across PreToolUse, PostToolUse, PostToolUseFailure, PreCompact, SessionStart, Stop, SessionEnd |
| agents, skills, commands | 38 agent files (47 including Anthropic's own); 75 skills (62 ECC, 13 symlinks to a Cloudflare pack dated 2026-08-16); 81 commands (79 ECC, 2 authored by the owner) |
| logs | `bash-commands.log` 12.1 MB, `cost-tracker.log` 12.6 MB |
| removal | 2026-09-05: backup of 383 files, 3.6 MB, to `~/.claude/backups/ecc-2026-09-05`; ECC directories, logs, and the hooks block removed; the owner's two commands and the Cloudflare links kept |

## Memory systems

| System | Measurement |
|---|---|
| ECC continuous learning store | `~/.claude/homunculus/projects`: 27 project folders, 0 files, 8 KB total, after hooks ran on every tool call since 2026-04-08 |
| Claude auto memory, owner's site | 6 notes; 2 of them status notes marked "SHIPPED" |
| Claude auto memory, one other project | 84 notes with priorities and live status, used as a knowledge base |
| Claude auto memory, this repository | 0 notes |

## The current `ecc` repository

Shallow clone of `github.com/affaan-m/ecc` on 2026-09-05: head `e04ea0b` dated 2026-09-03,
`VERSION` 2.2.1, 286 skills, 68 agents, 94 commands, 23 rule directories, 4 hook files, plus
runtime directories. Its connector policy of 2026-06 retired six default MCP servers in favour of
skills wrapping CLIs and REST APIs.

## Hook behaviour on the desktop app, measured

| Measurement | Result |
|---|---|
| `guard-secrets.ps1` wired as a `PreToolUse` hook on `Edit\|Write` in this repository's `.claude/settings.json`, written during the session on 2026-09-05 | fired on the next Write without a session restart, exit 2, stderr shown to the assistant as the tool error. The blocked write targeted a file outside the repository, so the hook applies to every Write in the session, not only to project files |
| what it caught | a test-script line carrying a connection string with a server field and a password field on one line. The false-positive cases, a `const password = process.argv[2]` line and a token-shape description, were not blocked |
| a false positive it produced | prose describing those two field names on one line, in a knowledge-base edit. Fixed the same day by excluding whitespace and backticks from the password value class; a real connection-string password has neither |

Skills hot-load on this build as well: the `record` skill, written to `.claude/skills/record/`
during the session on 2026-09-05, appeared in the session's available-skills list on the next turn
without a restart. Skills marked `disable-model-invocation: true` did not appear in that list,
which is the documented behaviour for them.

A negative result from the same session: the source installations set `MSYS_NO_PATHCONV=1` in
`settings.json` to stop MSYS rewriting `gh api /repos/...` and `cmd /c`. With it set, measured
2026-09-05 in Git Bash: `git -C /d/SourceCode/methodology log -1` fails with "cannot change to:
No such file or directory" while `git -C D:/SourceCode/methodology` succeeds; without it, both
work and `gh api repos/...` without the leading slash works. The variable was removed from the kit.

The "hooks do not hot-reload" advice from other installations did not hold for a project
`settings.json` created mid-session on this build (Claude Code desktop app, Windows, 2026-09-05).
Restarting after a hook change remains the safe instruction. This row records that the reload
happened, not that it is guaranteed.

## Claude Code documentation facts

Read from the official documentation by a research subagent on 2026-09-05; none exercised here:

- auto memory is on by default, scoped per repository, stored under `~/.claude/projects/<slug>/memory/`, machine-local; the first 200 lines of its index load each session; `autoMemoryEnabled` and `autoMemoryDirectory` are the settings
- a skill can invoke another skill through the Skill tool when `allowed-tools` includes `Skill(<name>)`
- `/goal [condition|clear]` is a documented command
- `SessionStart` hooks accept a `compact` matcher; `PreToolUse` exit 2 blocks with stderr shown to the assistant; `Stop` hooks receive `stop_hook_active`
- the desktop app and the CLI share the hook model on Windows
