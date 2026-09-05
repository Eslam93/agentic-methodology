---
title: The Claude Code documentation facts, read 2026-09-05, that bound what a hook, a goal, or a plugin can do for this kit
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: The hooks reference and the goal page at code.claude.com were fetched on 2026-09-05 and the quoted sentences read by the session; the desktop, worktrees, and permissions pages were read by a documentation agent the same day and its answers are marked as such and corroborated locally where they could be. The local machine was checked with which and ls
scope: The facts that decide whether a recommendation from the 2026-09-05 external review is buildable on this platform. Not a summary of the hooks system
confidence: High for the quoted sentences. Medium for the agent-read pages. These facts are version-sensitive: the goal page itself cites behaviour changes at v2.1.234, v2.1.236, v2.1.239, and v2.1.246
known_gaps: Nothing here was exercised; each fact is a documentation claim. The plugin eval command is described only in an early-access reference, not on a public page. MultiEdit and NotebookEdit payload shapes are not on the hooks page. The agent's reading of the permissions page conflicts with a studied repository that ships permission deny lists; that item is marked unsettled
reverify_when: On a Claude Code version change, and before wiring any new hook event
---

## Hooks, from the hooks reference

- **Thirty-three hook events exist**, among them `SessionStart`, `UserPromptSubmit`, `PreToolUse`,
  `PermissionRequest`, `PostToolUse`, `PostToolBatch`, `SubagentStart`, `SubagentStop`,
  `TaskCreated`, `TaskCompleted`, `Stop`, `StopFailure`, `PreCompact`, `PostCompact`,
  `WorktreeCreate`, `WorktreeRemove`, `FileChanged`, `ConfigChange`, `SessionEnd`. This kit wires
  four: `PreToolUse` twice, `Stop`, and `SessionStart` on `compact`.
- **Eleven can block**, by exit code 2 or a JSON decision: `PreToolUse`, `UserPromptSubmit`,
  `UserPromptExpansion`, `Stop`, `SubagentStop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`,
  `ConfigChange`, `PostToolBatch`, `PreModelSwitch`. `PostToolUse`, `PermissionRequest`,
  `SessionStart`, `SessionEnd`, and `Notification` cannot, and `PreCompact` is not on the blocking
  list, which bears on one studied harness that claims to block compaction.
- **A `PreToolUse` matcher can name an MCP tool.** Quoted: "MCP tools follow the naming pattern
  `mcp__<server>__<tool>`" and "MCP server tools appear as regular tools in tool events
  (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`), so
  you can match them the same way you match any other tool name." The kit's limit line, "No hook
  sees a browser, an MCP call, chat, or a shared folder", is true of this kit's matchers
  (`Edit|Write`, `Bash|PowerShell`) and false as a statement about the platform. Recorded in
  `99-pending.md`.
- **Every hook receives `session_id`** in its input JSON. An active-task pointer keyed by session
  is therefore possible from inside a hook.
- **`once: true`** removes a hook after its first successful run, honoured only for hooks declared
  in skill front matter; a skill's hooks run for the rest of the session once the skill is invoked.
- The hooks page does not name `MultiEdit` or `NotebookEdit` or their input fields. Whether the
  `Edit|Write` matcher fires on them, and what `guard-secrets` would read if it did, stays open
  (external-review page, new finding 3).

## The goal evaluator, from the goal page

- Quoted: "The evaluator judges your condition against what Claude has surfaced in the
  conversation. It doesn't run commands or read files independently" and "It does not call tools,
  so it can only judge what Claude has already surfaced in the conversation." `/goal` is "a wrapper
  around a session-scoped prompt-based Stop hook"; after each turn the condition and the
  conversation go to the configured small fast model, which returns not yet met, met, or impossible
  with a reason.
- This settles acceptance row 16's open line: the evaluator read the transcript's quotation of
  `verify.sh`; it did not run it. A goal is therefore only as honest as what the session prints,
  and a deterministic Stop hook remains the only check that runs a command itself.
- Other facts from the same page: one goal per session; a goal does not change the permission
  mode; the loop stops with a warning after several turns without tool use; background work
  defers evaluation with check-ins at 30 minutes, doubling, at most three idle check-ins per goal;
  `/goal` works in the desktop app and non-interactively with `-p`.

## Plugins, evals, worktrees, permissions

Read by the documentation agent on 2026-09-05; the local checks are the session's own.

- **The desktop app has a plugin surface now.** The desktop page describes installing plugins from
  the official marketplace through the prompt's plus menu. Locally, `~/.claude/plugins/known_marketplaces.json`
  names `claude-plugins-official`, last updated 2026-09-02, and a cached marketplace of 39 plugin
  folders. Decision D-03 and superseded entry S-11 rest on "the desktop app has no plugin surface,
  measured 2026-08"; that measurement is no longer current. Recorded in `99-pending.md`.
- **No `claude` executable on this machine**: `which claude` found nothing on 2026-09-05;
  `codex` 0.144.3 is on PATH. The desktop page says the app is the interface and the CLI is
  installed separately.
- **`claude plugin eval`** is described only in an early-access reference: cases as
  `evals/<case>/prompt.md` with graders (regex, tool used, model, baseline arm with and without a
  skill), results as JSON and an HTML report, and it needs a plugin manifest
  (`.claude-plugin/plugin.json`); it cannot point at a repository's `.claude/skills/` directly.
- **Worktree isolation** for a subagent is `isolation: worktree` in agent front matter, plus a
  `--worktree` flag and an `EnterWorktree` tool; the worktrees page documents the front-matter form.
- **Permission allow and deny lists in settings:** the agent found no central list on the
  permissions page, while the studied `claude-code-harness` ships 22 `permissions.deny` and 15
  `permissions.ask` entries in a plugin settings file. Unsettled; one of the two is wrong or the
  page has moved. Do not build on either until the settings reference is read directly.
- **No public page on harness engineering or a size limit for `CLAUDE.md`** was found.
