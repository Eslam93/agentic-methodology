---
name: board
description: Put the tracker straight after a piece of work, on GitHub issues or Azure DevOps work items. It finds what the work belonged to, proposes every change in full, and stops. It never writes in the same turn it is asked, even when told to just do it.
argument-hint: "[nothing for the work just done, or an item id, or a description]"
disable-model-invocation: true
allowed-tools: Bash(gh *) Bash(curl *) Bash(git *) Read Grep Glob Write
---

# Board

$ARGUMENTS

## Read this before any tool call

**You may not write to the tracker in the same turn you were asked to.** Not a field, not a comment,
not a new item. Your turn ends with a proposal and a question.

"Update the board", "log this", "close it", and "create the story" all authorise the **proposal**,
not the write. That reads backwards and it is deliberate: the judgement being reviewed is the
content, which items, what the comment says, how many hours, what gets closed. Writing first and
reporting afterwards removes the only review there is. This rule lost to a direct instruction on the
day it first shipped, which is why it now sits above everything else in this file.

Every one of these is a write and needs approval first: creating an item · changing any field, state,
assignee, iteration, or tag · posting a comment, including "done" · linking a parent or child ·
closing.

**The failure mode is not asking too little, it is asking and then acting anyway.** Do not apply one
change while asking about another. **"Go", "yes", "do it", or an edit to the list is approval.
Silence is not.** A new instruction that does not mention the tracker is not. If you have already
written something before reading this: stop, say exactly what you changed, and do not continue.

Four beats: **find, propose, stop, then apply and verify.** The stop is the point.

## 1 · Find what this work belongs to

Do not start with a title search; it is the signal most likely to produce a confident wrong match.
In order, and say which one you used: what they said when the work started · the branch name · the
commit messages and the pull request · a title or label search, last. **Read the item from the
server**, never from a cached list. If nothing matches with reasonable confidence, say so and
propose a new item; a wrong parent is worse than no parent.

- **GitHub:** `gh issue view <n>`, `gh issue list --search "<terms>"`, `gh pr view`.
- **Azure DevOps:** `wit/workitems/<id>?$expand=all`, or a WIQL query filtered to the project,
  through `curl --basic` with the token variable from the project rule, never printed.

## 2 · Propose, in full, then stop

One list they can approve or argue with. For each item: **which item**, by id and its real title ·
**what changes**, every field from what to what · **the closing comment, written out** · **the
effort and where the number came from** · **anything new**, with its full title and description.

Then end your turn. The last thing you write is a question.

## 3 · What to propose

- **New items are suspended unless they ask.** Work not being done now goes to `99-pending.md`.
- **A task or a bug is decided by who found it,** not by severity: caught by us, a task; caught by
  QA or a user, a bug.
- **A closing comment carries the proof and what was not exercised.** The command that ran and what
  it returned, then plainly: deployed is not exercised, compiling is not working, reasoned is not
  demonstrated. Without that line, "done" degrades into "I wrote a fix".
- **Propose the next state, never the end state,** where the workflow has queues the team uses.
- **Effort is a reconstruction unless somebody kept a log.** Build it from commit timestamps and item
  history, say that is what you did, and show the timeline. Never invent a number to match an
  expectation.
- **Fields, states, and custom fields come from the project rule**, measured from real items, never
  assumed. A tracker with custom bug fields leaves the standard ones dead; filling the standard ones
  writes to fields nobody reads.
- Never bulk update. Never close something because it looks finished.

## 4 · Apply, one item at a time, then verify

Only after they answered. If you cannot point at the message where they approved, you are still in
beat 2.

- **GitHub:** `gh issue comment`, `gh issue edit`, `gh issue close`, one call per change.
- **Azure DevOps:** JSON patch on `wit/workitems/<id>`, `Content-Type: application/json-patch+json`;
  a comment is `POST wit/workItems/<id>/comments`; a parent link is a relation on the child. Write
  each payload with the file tools and post it with `--data-binary @file`: an assignee that
  contains a backslash is eaten by the shell otherwise.

One item at a time, fully. A loop that comments, closes, and sets fields across several items can be
interrupted halfway and leave one commented but open. Then **read every touched item back from the
server** and report state, assignee, iteration, and effort from that read, not from the write
responses. Finish with the ids and links, and anything you proposed that they declined, so it is
visible rather than quietly dropped.
