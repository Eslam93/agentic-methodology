---
name: work
description: Take a piece of work from a description, a GitHub issue, or an Azure DevOps work item through understand, one yes, an uninterrupted build, the review menu, and a hand-back with evidence. Use when picking up any task, bug, or feature that should be done end to end.
argument-hint: "[a description, an issue number or URL, or a work item id]"
disable-model-invocation: true
---

# Work

$ARGUMENTS

Seven beats: **intake, understand, agree, route, build, verify, hand back.** One yes, after
Understand. **This is a suggestion, not a process:** if the owner skips a beat, skip it and say
nothing. Match the beats to the size of the job. Nobody writes a plan to rename a variable.

**State the tier in one line the owner can override**, from the standing orders' table. The highest
signal wins: files touched, a new dependency or contract, design ambiguity, a hard-floor area. Tier 1
has no stop. Tier 2 stops once. Tier 3 stops once, adds a decision entry, and gets review.

## 1 · Intake: get the item from wherever it lives

- **A description in their words** is enough. Do not send them away to write a ticket.
- **A GitHub issue or pull request:** `gh issue view <n> --json title,body,labels,comments`, or
  `gh pr view <n>`. If `gh` is missing or not signed in, say so and take the text instead.
- **An Azure DevOps work item:** the REST API, with the organisation, project, and token variable
  named in the project rule. `curl --basic` with the token read from the environment and never
  printed. Read the item's comments too: design links usually sit in the comments, not the
  description.
- **A design link** named in the item: fetch the frame when a design connector is available,
  otherwise ask for an export. Many links point at a whole section, not a screen; drill into the
  child frames. The acceptance criteria without the screen are half the specification.
- **A whole feature or epic:** say so and propose phases (1b). It does not fit one session.

## 2 · Understand: you do the reading, they do the deciding

**Do not write code during this beat.** Nearly every expensive mistake comes from acting on a
half-understood request, not from writing bad code.

| | |
|---|---|
| **The outcome** | what is true when this is done, in a form that can be checked |
| **The trigger** | what is broken or missing, and who it affects. For a bug: how to reproduce it |
| **The boundary** | what is explicitly not in scope |
| **The constraints** | anything non-obvious that must not break |

**You supply the code half.** Find and tell them which files and areas are involved, what the
current behaviour actually is, the pattern that already exists for this kind of change, the library
that already does it before you write a new one, and anything surprising. Then a bottom line of what
you understood, and **only the questions whose answer would change what gets built**, in one
message. If you can answer a question yourself, answer it and state it as an assumption they can
correct. Repeat until satisfied, and say so.

**1a · Who else is in this code.** When a remote exists: `git fetch origin --prune`,
`git log --oneline --since="3 weeks ago" --all -- <the paths you will touch>`,
`git branch -r --sort=-committerdate | head -20`, and the open pull requests on the same
repository. Say what you found before proposing anything, including when you found nothing.

**1b · Bigger than a session: phases.** Split by dependency, not by ticket. Name what each phase
makes possible and put the hardest unknown in its own phase. Each phase gets a brief a fresh session
can execute cold, in `working/<task>/phases/<n>.md`.

## 3 · Agree: one summary, one yes

A bottom line of what you are about to do, then the details, in the house writing style:

- where this sits and why it matters · the problem in their terms · what we have now, honestly
- **the outcome checklist:** one line per acceptance criterion in the shape *given <start>, when
  <trigger>, then <observable result>, verified by <how>*. Three to seven lines for a normal task;
  the full brief when the change touches security, persistent data, a migration, or another system
- the phases · who else is in the code · what needs investigating first · decisions that will be
  needed later, flagged now rather than sprung at hour three · what is out of scope
- **the branch sentence:** which repository, cut from which branch after a fetch, following the
  project rule's branch model; which branch the pull request targets. When the repository does not
  follow the model, put the evidence in front of them and ask one question with the options named
- the tier line

Then stop. **That is the only approval you ask for.** If they change something, fold it in and
restate only what changed. Write the agreed summary and checklist to `working/<task>/brief.md`:
after a compaction the `resume-brief` hook reads it back, so the build continues from the agreement
rather than from a summary. A real fork decided here goes to `decisions.md` through `/record`.

## 4 · Route: design review, or go

Ask: **Codex design review first, or go?** Defaults: Tier 3 review, Tier 2 offer it, Tier 1 go.
If review: `/codex-relay plan` with the full brief, up to the configured rounds. Fold what the
evidence supports, push back only with evidence, then go.

## 5 · Build: uninterrupted

- **Commit a checkpoint first.** Git is the undo; the session's own checkpoints do not track changes
  made through the shell.
- **Set the goal only when the finish condition is machine-decidable:** `/goal` with the verify
  command and the checklist lines a check can prove. When it is not decidable, the brief file is the
  goal. A goal a machine cannot judge sends a loop toward the wrong target.
- **Follow the pattern that already exists.** If two disagree, say which you follow and why.
- **Write the tests as part of the work.** For a bug, the failing test that reproduces it first, and
  check that it fails before the fix. Name the tests that prove each checklist line. If there is no
  test suite, say what replaces it: build it, run it, exercise the path by hand, and write down what
  you exercised and what you saw. A build that compiles proves only that it compiles.
- **Stay inside the boundary.** No refactor, rename, reformat, or tidy the task did not ask for.
  Note it for the hand-back instead.
- **Pause only for the stop-list** in the standing orders. Everything else waits for the hand-back.
  **Two failed attempts at the same thing means the approach is wrong:** say so out loud and re-think.

## 6 · Verify: the menu

Offer these and run what they pick, in any combination:

- **a fresh-context review**: `/code-review` where it exists, otherwise a subagent that never saw the
  reasoning, told to report gaps in correctness or the stated requirements, not style
- **a Codex cold pass**: `/codex-relay code`
- **a local run with a plain-English test guide**: `/test-guide`

Defaults: Tier 1 the local run; Tier 2 the review plus the local run; Tier 3 all three. Pushback on
a finding is evidence-only.

## 7 · Hand back, in this order

a. `git diff --name-only` before reading any content. Did this change something it should not have?
b. Read the test diff before the code diff, then the whole diff for things nobody asked for.
c. Report against the checklist, line by line: built, ran and did the thing, or not verified.
   Evidence, not claims: the command and what it returned.
d. The direction delta, one line: what shipped, in product terms, versus what was asked.
e. What to try themselves: open this, do this, expect that. The test guide carries it.
f. `/pr` when they say so. The test guide becomes the "How to test" section.
g. `/board` proposes the tracker update and stops. Never a tracker write in the same turn.
h. Anything learned goes through `/record`, with evidence and what was not checked. Open threads go
   to `99-pending.md`, never to `working/`. Then `/handoff` if the session is ending.

## What not to do

Ask for approval more than once · narrate every step while building · report partial success as
success · go quiet and try six things · treat the beats as a checklist to be seen completing.
