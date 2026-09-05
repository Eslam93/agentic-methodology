---
title: How a claim is written here so it is still true in a year
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: Consolidated from the AI Workspace Blueprint section 4, the evidence rules of two working knowledge bases read on 2026-09-05, and the owner's decisions of 2026-09-05 on claim types and the decisions page
scope: Every page in this knowledge base, and the model for any knowledge base the kit installs. The path-scoped rule .claude/rules/knowledge-base.md is the condensed form of this page
confidence: High. These rules were paid for by named failures in the source installations, among them a refuted claim that survived five correction passes and a stale claim quoted as current months after the fix
known_gaps: The claim-type table is new in v2 and has not yet been exercised across a full project
reverify_when: The path-scoped rule and this page must say the same thing; check both when either changes
---

## 1 · The test for inclusion

**Would this still be worth reading a year from now?**

Belongs: how a system works · why a decision was made · a finding with its evidence · a trap that
will bite the next person · a dated measurement · a negative result · a risk with its cause.

Does not belong: what you are doing now · what is next · a resume point · anything you would
rewrite tomorrow. Those go to `working/`, which is disposable. **The knowledge base never links
into `working/`.** Promotion runs one way, inward.

Three destinations. Putting a thing in the wrong one is how a knowledge base stops being trusted:

| It is | It goes to |
|---|---|
| how something actually works, a measurement, a decision and its reasoning, a trap | the knowledge base |
| where we got to, status, next steps, anything stale in a week | `working/` |
| known, understood, and nobody is doing it | `99-pending.md` |

## 2 · Structure

Numbered folders, so the order is the reading order and new sections slot in without renaming:

`00-orientation` · `10-access` · `20-system` · `30-infrastructure` · `40-operations` ·
`50-incidents` · `60-design` · `80-governance` · `90-strategy` · `95-briefings` ·
`_investigations` · `_readings` · `99-pending.md` · `decisions.md`

In shape B, `20-system/<service>/` per service. **Leave a section empty rather than fill it with
speculation, and say in `index.md` that it is empty and why.** An empty section is a gap; a
speculative section is a lie with a heading.

## 3 · The page header

Every substantial page opens with:

```yaml
---
title:                # what this page settles, not what it is about
status:               # draft | verified | partially-verified | superseded
as_of:                # when the facts were gathered, YYYY-MM-DD
last_verified:        # when somebody last confirmed them
verification_method:  # how: the command, the file, the API call. Specific enough to repeat
scope:                # what this page covers, and deliberately does not
confidence:           # High | Medium | Low, and why
known_gaps:           # what was NOT checked. The most valuable line in the header
supersedes:           # the page or claim this replaces, if any
reverify_when:        # the trigger: "when a module is added", "before any production deploy"
---
```

Then, on any page carrying volatile numbers, a three-line banner: **measured when** · **expires
when somebody does their job** · **stays true regardless**. Writing it forces the separation
between the durable finding and the perishable number.

## 4 · What every claim carries

**A confidence label:**

| Label | Means |
|---|---|
| **Verified** | directly observed in a primary source, with the source cited |
| **Strongly inferred** | several independent secondary signals agree |
| **Tentative** | one weak signal; a hypothesis |
| **Unknown** | explicitly not determinable from what is available. Writing this is a result, not a failure |
| **Historical** | verified once; the reverify trigger has since fired |

**The evidence itself:** the command and what it returned, the file and line at a commit, the run
id, the API response. Not "we checked": what was checked and what it said.

**What was not checked.** Deployed is not exercised. Compiling is not working. Reasoned is not
demonstrated. Say which one this is.

Keep confidence separate from what a claim entitles you to conclude. A document can be verified to
exist and to say X while X is pure aspiration. Then the document is verified and the reality is not.

## 5 · Claim status, for capabilities

| Status | Test | Entitles you to say |
|---|---|---|
| **BUILT** | exists in code at a named branch and commit | "we have this" |
| **RUNNING** | observed live in an environment | "this works in production" |
| **SPECIFIED** | a written requirement or design exists | "we know what we want" |
| **PLANNED** | on a roadmap or backlog with a date | "we intend to build this" |
| **EXPLORED** | brainstorm, draft, options paper | "someone thought about this" |
| **CLAIMED** | asserted to someone outside the team | "we told someone this" |
| **REPORTED** | stated in internal status reporting | "management believes this" |

A capability inherits the weakest link in its chain. The gap between two statuses is itself the
finding. Never promote a status without new evidence of that kind: only code makes something BUILT,
and only observation makes it RUNNING.

## 6 · Claim types

So a reader never mistakes one kind of sentence for another:

| Type | Must carry | Tense |
|---|---|---|
| fact about structure or history | evidence pointer, label | present |
| measurement | date, commit or source, the command, label | past, dated |
| decision | the `decisions.md` fields | past, dated |
| opinion or recommendation | marked as such, the reasoning, what would change it | present, labelled |
| trap | symptom, mechanism, fix, date measured | present for the mechanism, dated for the observation |
| negative result | what was tried, what happened, date | past, dated |
| open question | who can answer it, what it blocks | lives in `99-pending.md` |

Dates are ISO days. Add a time only when two measurements on the same day differ, such as branch
heads.

## 7 · The volatile-claim rule

**Never assert a changeable condition in the present tense. Assert the measurement that produced
it, with its date and commit.**

| Do not write | Write |
|---|---|
| "There are no automated tests." | "As of 2026-08-31, on `feature/x@2c617f31`, no test project existed in any of the nine repositories." |
| "The webhook is anonymous." | "Read 2026-08-31 at `PaymentController.cs:17`: the action carries `[AllowAnonymous]`." |
| "958 bugs are open." | "A query on 2026-08-31 returned 958 items of type Bug." |

The test while writing: **could a developer make this sentence false next Tuesday by doing their
job?** If yes, date it and cite the source. If no, plain present tense is correct.

## 8 · The evidence hierarchy for operational truth

1. current live-system observation
2. current deployment manifests and pipeline configuration
3. code on the deployed commit
4. trunk-branch code and configuration, which is not necessarily the default branch
5. tickets, work items, roadmaps: intent, not implementation
6. existing documentation
7. human recollection or chat history

A higher-ranked source does not erase contradictory lower-ranked evidence. Record the conflict. Two
sources disagreeing is a finding.

## 9 · Corrections

**You were wrong:** fix the claim, delete the wrong version, do not narrate the fix. Keep the
evidence line, not the story. Keep a visible correction only when the old claim was load-bearing
for somebody else, or when the correction is about method rather than fact.

**The world changed:** supersede, keep both, date both, link the replacement, say why it changed.
Update the header: `last_verified`, `verification_method`, `known_gaps`, `supersedes`.

**A correction that lives only where it was discovered has not been made.** Sweep by code symbol,
not by prose; a phrase list misses the wording nobody predicted. Then fix the assertion rather
than appending a note beside it; check headings, table cells, bullet leads, and worked examples;
check the pages that cite the corrected page; prefer one authoritative page plus links over a
second copy.

## 10 · The three rules that do not bend

1. **Never record a secret value.** Record that a secret exists, where it is referenced, and how
   it is provisioned. A hook enforces this on the editing tools; it sees only those tools.
2. **Describe the system, not the people.** Never name an individual as the author of a defect,
   never rank contributors. Knowledge concentration is recorded as a property of the code.
3. **Keep negative results and contradictions.**

## 11 · The capture file: `99-pending.md`

Anything noticed and not acted on goes here **in the same turn, one line**, with enough context to
act later. Write to it without asking. Group by who can act: only the project team · needs a
decision · we can do this ourselves · worth doing when someone is in that code anyway. Mark
priority `P0` (blocks the current goal) · `P1` · `P2` · `?` (needs a decision). Link each item to
the page carrying its evidence: this file is the index of what is open, not the evidence for it.
Demo-posture shortcuts are recorded here tagged `demo-debt`; the flip to production is gated on
that list being empty or owner-waived.

## 12 · `index.md` and `what-we-do-not-know.md`

The index has one row per page with a **what it settles** column, a router by reader intent at the
top, and **what is empty, and deliberately** at the end.

The gaps page groups gaps by **root cause**, ordered by how much becomes knowable per unit of
effort, built mechanically from every `known_gaps` header. Each entry names the page whose claim
it limits and roughly what it would cost to close.

## 13 · `decisions.md`

One entry per real fork, newest first within each section. Fields: **decision · options considered
· why · decided by · reversible or not · revisit when · supersedes.** Written from the Agree step
of `/work` whenever there was a fork, and by `/record` otherwise.

## 14 · `_investigations/` and `_readings/`

`_investigations/<date>-<name>/methodology.md` holds the commit hash and the command behind every
number on the pages that cite it. `_readings/` holds notes on external sources: what the source
says, what was taken, what was not, and the source's own verification status.

## 15 · Mechanics

- Commit in the same turn. A finding sitting uncommitted does not exist for anyone else.
- File names in kebab-case that say what the page settles.
- One authoritative page per claim; link, do not copy.
- Pages of 150 to 400 lines; split by subject before that.
- LF line endings. Never round-trip a page through PowerShell `Get-Content` and `Set-Content`; it
  corrupts non-ASCII characters.
- No em dashes anywhere in this base. Commas, colons, and full stops do the work.
