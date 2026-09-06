---
title: Which knowledge-base rules became executable checks, which stayed conventions and why, the measurement that decided where the line falls, and the drift the new checks found on arrival
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: knowledge-check.sh and its 71 fixture cases run on the owner's Windows machine in Git Bash on 2026-09-05 and 2026-09-06, with the outputs quoted below; the ambiguity measurement was taken by a script over all 21 pages of this base at b4b254f; three deliberate mutations of the validator were run to confirm the canary and the suite go red
scope: The change decided as D-20: knowledge-check.sh, its conf and its case suite, the three new verify.sh checks, the canary extension, and the text that describes them. Not semantic evidence validation, not automatic confidence, not executable reverify_when, not truth diff, not contradiction detection, not network validation
confidence: High for what the tool does and what it refuses to do; each is a command and its output. Medium that the `repo:` and `commit:` convention will be used, since nothing in the base uses it yet and it is proved only by fixtures
known_gaps: The validator has never run on macOS or on a second machine. Bare backticked paths and bare hex strings are not checked at all, which is most of the evidence in this base, and nothing here decides whether a claim is true. This change shipped unreviewed on 2026-09-05 and was reviewed on 2026-09-06, which found five defects in this layer, all fixed and covered; shape B was reasoned about on the first day and is exercised by the suite since that review
reverify_when: On any change to knowledge-check.sh, its conf, or the header the rules require; before quoting the case count or the reference count
---

## The one sentence

The cheap, objective parts of this base's discipline are now executable: `verify.sh` refuses a tree
whose durable pages are missing the header the rules require, whose checked references do not
resolve, or whose README states a count the tree contradicts. It decides structure, never truth.

## What changed, and where

| File | Change |
|---|---|
| `.claude/tools/knowledge-check.sh` | new: the validator, three sections, human output or `--porcelain` |
| `.claude/tools/knowledge-drift.conf` | new: the curated count list for this repository, with the exclusions and their reasons |
| `.claude/tools/knowledge-check.test.sh` | new: 71 cases, each building a tree and running the real validator |
| `.claude/tools/verify.sh` | three new checks in the normal run; the suite under `--hooks`; the canary now breaks a record and watches it go red |
| `README.md` | the tool named; the acceptance sentence corrected; the tool count corrected |
| `00-orientation/evidence-and-verification-rules.md`, `.claude/rules/knowledge-base.md` | which parts of the header are now mechanically checked, and which are still only asked for |
| `.claude/rules/standing-orders.md`, `START-HERE.md` | the enforcement list gains a deterministic check that is not a hook |
| `decisions.md` | D-20 |

## The line, and the measurement that put it there

The boundary is not a matter of taste. **Only evidence with mechanically identifiable syntax is
checked**, and a script measured which syntax qualifies before any check was written.

Over all 21 pages at `b4b254f`:

| Form | Occurrences | Resolve as a path or commit here |
|---|---|---|
| backticked span containing a slash | 469 | 60 |
| backticked pure hex, 7 to 40 characters | 50 | 30 |
| Markdown link to a local target | 17 | 17 |
| backticked span beginning `../` or `./` | 15 | 15 |

The two bare forms are useless as checks, and the reason is not sloppiness in the base: this
knowledge base **deliberately cites other trees**. `_readings/harness-benchmark-2026-09-05.md` cites
paths and commits inside nine benchmarked clones; `_investigations/2026-09-05-task-baseline/`
cites `8b2946d` in a scratch repository built for one test; `decisions.md` cites
`.claude/state/active-task.json`, a design that was considered and rejected. A checker that treated
every backticked slash as a path in this repository would have raised 409 findings, nearly all of
them correct citations of somewhere else. That is the noisy heuristic the owner ruled out, and the
measurement is why it is ruled out rather than merely disliked.

So the reference checks take the two unambiguous existing forms, and a small explicit convention was
added for the evidence that must be mechanically checkable from now on.

## The evidence-reference convention

Two forms, neither of which existed before, both backward compatible because nothing in the base
used them and no page had to change:

```text
`repo:.claude/hooks/verify-on-finish.sh`   a path from the project root
`commit:7f8620b`                            a commit in this project's checkout
```

`repo:` means the same thing in both shapes: a path from the root that holds `.claude/`, which is
the repository in shape A and the workspace root in shape B. A page that wants to point at a file in
one clone of a workspace writes the clone into the path, as it would to reach it from that root.

Migration cost is zero and adoption is voluntary. The existing 469 bare citations keep working as
prose and are not checked. That is a real gap, recorded below and in `99-pending.md`, not a solved
problem.

## What is checked

**Structure**, on every durable page. All nine fields the rules require in section 3 must be present
and non-empty: `title`, `status`, `as_of`, `last_verified`, `verification_method`, `scope`,
`confidence`, `known_gaps`, `reverify_when`. `supersedes` is optional, because the rules say "if
any", and no page in this base carries one.

**Values with an objective shape.** `status` must be one of the four the rules name: `draft`,
`verified`, `partially-verified`, `superseded`. `confidence` must begin with `High`, `Medium`, or
`Low`, which is the vocabulary the rules give it; the sentence after it is free text and is not
read. `as_of` and `last_verified` must be calendar days in `YYYY-MM-DD`, so `2026-13-01` and
`2026-02-30` fail and `2024-02-29` passes, and `last_verified` may not fall before `as_of`.

The confidence label table in section 4, verified through historical, describes claims inside a
page, not the header field, and is not checked. Nothing counts words, judges a `scope`, or decides
whether a `known_gaps` line names anything real.

**References**, on every page including the two exempt from the header:

| Form | Checked how | Count today |
|---|---|---|
| a local Markdown link, `[text](<target>)` | resolved from the page's own folder; anchors dropped, `%20` decoded | 17 |
| a backticked `../<target>` or `./<target>` | resolved from the page's own folder | 19 |
| `repo:<path>` | resolved from the project root | 0 |
| `commit:<sha>` | `git cat-file -e <sha>^{commit}` in each checkout | 0 |
| `D-`, `V-`, `S-` and two digits | must be defined in `decisions.md` | 176, over 44 distinct codes |

`http` and `https` targets are never fetched. A page going offline is not a fact about this tree,
and a check that needs the network fails on an aeroplane. Fenced code blocks are stripped first, so
the rules page can print the header template without the template's placeholders being read as
references. A span holding `<`, `>`, or `*` is a template, not a reference.

**Supersession**, referential integrity only. A `supersedes` header naming a page must name one that
exists, and may not name its own page. A decision may not supersede itself. Every decision code
cited anywhere in the base must be defined in `decisions.md`. Whether one page deserves to replace
another is not a machine's question.

**Drift**, six curated counts, listed with their reasons in `knowledge-drift.conf`. The tree is
authoritative, the README repeats a value derived from it, and the check proves they agree: skills,
hooks, tools, acceptance rows, acceptance rows that passed, acceptance rows run live.

Two exclusions were deliberate. **The rule count** is not checkable: the README's "four rules" means
the kit's rules, this repository carries a fifth that is its own project rule, and every install has
one under its own name, so the tree cannot tell them apart. **`decisions.md`** is excluded entirely,
because D-03's heading says "4 rules, 10 skills, 4 hooks, 3 tools" and that is a dated record of what
was decided, not a claim about today. A decision entry is history and must not be rewritten to agree
with the current tree.

## The page class, and the two exemptions

Every Markdown page in the base is subject to the header schema except `99-pending.md` and the
base's `README.md`, both at the root. This is a document class rather than a suppression list: the
rules give each of those two its own shape, section 11 for the capture file and the README as the
front door, and neither is a durable knowledge page. Both are still subject to every reference
check. A page added anywhere else is in scope the moment it is written, which a case proves.

No page was grandfathered. All 19 durable pages then in the base passed the schema on the first
run, including
`_readings/evidence-base.md` and `_readings/v1-review-from-the-field-2026-08-03.md`, whose
`status: partially-verified` and older dates are valid and stay valid.

The 150-to-400-line rule in section 15 is **not** enforced, and this is a real gap rather than an
oversight: 12 of the 21 durable pages are below 150 lines today, so a check would be red on arrival
for a rule the base has never followed. Recorded in `99-pending.md` as a decision for the owner:
enforce it and split the pages, or change the rule to match the practice.

## What a green result does not mean

A page can carry every field, every date, and every resolving reference, and be wrong. Four cases
that pass and should:

- `confidence: High` written by an author who had one weak signal. Nothing weighs it.
- a `commit:` that exists and does not support the sentence beside it.
- a `repo:` path that exists and holds code irrelevant to the claim.
- a `last_verified` of 2026-09-05 on a fact that stopped being true on 2026-09-06. No check decides
  staleness from time passing, deliberately: an audit that reddens with no change in the repository
  is a check nobody can act on.

The honest sentence is the one the tool prints: **structurally valid, and every checked reference
resolves.** Not "the knowledge base is correct".

## The canary, and what it actually proves

`verify.sh --canary` now builds a page that is invalid three ways, missing `known_gaps`, carrying
`last_verified: not-a-date`, and holding a dead link, runs the real validator against it, and
reports a failure if the validator passed it. The canary still fails unconditionally afterwards, so
a green canary run stays impossible.

Two mutations were run to see what the canary is worth. Replacing the validator with `exit 0`:

```
  FAIL  knowledge integrity goes red on a broken record
        it passed a page missing a required field, carrying a malformed date, and holding a dead
        link; the knowledge checks prove nothing
```

and the normal run caught the same mutation separately, with "knowledge-check.sh produced no output,
so it checked nothing".

Removing `known_gaps` from the required list: **the canary passed.** Its fixture breaks three things
at once, so losing one requirement leaves two failures and the canary still sees red. That is the
canary's honest limit. It proves the layer is wired and can report a broken record; it does not
prove each invariant survives. The 53 fixture cases are what prove that, and the same mutation makes
two of them fail:

```
  FAIL  missing required field: known_gaps       expected exit 1 got 0
  FAIL  a required field present but empty       expected exit 1 got 0
  2 of the cases FAILED
```

A third mutation, deleting the local-link check, failed three cases: the broken link, the broken
link carrying an anchor, and the real link written beside a quoted example. All three mutations were
reverted and the suite returned to green.

## Shape A and shape B

The base is found at `docs/knowledge-base/` or at `knowledge-base/`, as `verify.sh` already did.
`repo:` resolves from the project root in both. `commit:` is resolved against every checkout
`layout.sh` reports, so a citation in a workspace resolves if any clone holds it; **which** clone was
meant is not decidable from `commit:<sha>` alone, and the tool does not claim it. Shape B was
reasoned about and not run: no case in the suite builds a workspace, which is the same gap D-17 and
D-18 recorded.

## What it found on arrival

The structure and reference sections were green on the first run against all 21 pages, which is
worth stating plainly: nothing in this base had to be fixed to make the new checks pass. The drift
section found two stale numbers in the README, both in one sentence:

- "Twelve of seventeen acceptance tests passed", against 17 rows recording a pass. This is the exact
  drift the 2026-09-05 benchmark named, still present three commits later.
- "three of them live", against 7 rows recording a live run. The benchmark did not name this one.

Both are corrected in this change. The tool count moved from six to eight in the same edit, because
this change adds two scripts, and the check caught that too before the README was touched.

## The suite, and the cost

`bash .claude/tools/knowledge-check.test.sh`: **71 cases, 0 failed**. Each builds a project root,
mutates one thing, runs the real validator, and asserts the exit code **and** a substring of the
message, so a check that fails for the wrong reason does not count as a pass. Nothing in the suite
greps the validator's source.

Classes covered: a valid base; the two exemptions, and a page added elsewhere still being in scope;
each of the nine required fields missing, one case each; a field present but empty; no front matter
at all; each of the four `status` values accepted and a fifth rejected; a bad `confidence` word; five
date cases including both leap-year directions; `last_verified` before `as_of`; a broken link, a
broken link with an anchor, a broken page-relative reference; a template in each citation form and a
bare backticked path left alone; a link inside a fence and a link inside backticks left alone, with
a real link on the same page still counted; `repo:` present and absent; `commit:` resolving, not
resolving, and not hexadecimal; a bare hex string left alone; a `supersedes` target missing, present,
and self-pointing; an undefined decision code; a self-superseding decision; a drift count agreeing,
disagreeing, a pattern matching nothing, an unknown quantity, a missing source, and no conf at all;
no knowledge base; a base with no pages.

Timing on the owner's Windows machine: the validator **4.9 seconds** over 20 pages, `verify.sh`
**8.0 seconds** for 21 checks, the case suite **81 seconds**, and `--hooks` end to end a little over
three minutes, of which `hooks.test.sh` is most.

The first build took **67 seconds** for the validator alone, because it ran a subprocess for every
field of every page. It was rewritten to two awk passes per page with every existence test as a
shell builtin. Recorded because 67 seconds is exactly the cost at which somebody starts skipping a
check, and the check that gets skipped protects nothing.

## The page that documents the syntax trips on it

The first run against this page failed six times, and none of them were bugs in this base: the
table above prints `repo:` and `commit:` examples inline, and the validator read its own
documentation as evidence. Two things came out of it.

The fix that is not a workaround: **a citation holding `<`, `>`, or `*` is a template in every
form**, not only in the page-relative form where that filter already existed. Angle brackets are
this base's placeholder convention everywhere, in `working/<task>/brief.md` and
`baseline_commit.<checkout>`, so reading them as a placeholder is the consistent rule rather than an
exemption carved for one page. Three cases cover it.

The part that was this page's own fault: an example written `[text](target)`, with no placeholder
marks, is indistinguishable from a real link, and the checker was right to fail it. It is written
with the placeholder now. A fenced block would also have worked, which is how the rules page prints
the header template.

Recorded because a validator whose own documentation cannot be written under it is a validator with
a design fault, and because the first instinct, adding the page to an exemption list, would have
been the wrong repair.

## Limits found on the way

- The 469 bare citations are the majority of the evidence in this base and none of them are checked.
  The convention that would fix that is opt-in and unused. This is the largest gap in the change.
- A drift pattern that stops matching fails loudly rather than passing quietly, which is right, but
  the message says the pattern is broken without saying whether the tree or the wording moved.
- `test -e` is case-insensitive on Windows, so a link whose case is wrong passes here and fails on
  Linux. CI runs on `ubuntu-latest`, so the case is caught, but one commit later than it should be.
- The tool is bash only, like every other file in `.claude/tools/` except the installer. The hooks
  ship in both shells because the host launches whichever it runs on; a verification tool is
  started by `verify.sh`, which is bash, so a PowerShell twin would have no caller.

## What an independent review found, 2026-09-06

The change above was reviewed the next day by six independent readers, each running the validator
rather than reading it, and each finding verified by a second reader who tried to refute it. Five
defects in this layer held, and all five are fixed with a case each.

**A page whose header is never closed passed, and requiring the fence was not the fix.** The parser
opened the front matter at line 1 and closed it only on a bare `---`; with no closing fence the whole
document was read as header, so prose further down could supply a valid `status:` after an invalid
one and three separate red cases were defeated at once.

The first repair required a closing fence, and the verifier showed that this was the insufficient
half: an ordinary Markdown horizontal rule later in the body sets the fence, so the page looks well
formed while the prose above it has already overwritten the header. The hole was **last-wins**, not
the missing fence. The parser now reads the first value of each key and reports a repeat, which
closes both shapes, and a page with a duplicated key inside a correctly closed fence fails as well.
Recorded because the obvious fix was tested and found to be half of one; three cases cover it.

**A hyphenated number was read as its last word.** The curated patterns anchor on `[a-z]+`, so
"twenty-one hooks" matched as the fragment "one hooks" and was read as 1. A README claiming
twenty-one agreed with a tree holding one, silently, which is the exact drift this section exists to
catch. `numword` now reads the tens-and-units forms.

**CRLF pages were treated differently on the two platforms.** The field parser stripped the carriage
return and the fence test did not, so the same bytes reported "no page header" on Linux and passed
on Windows. The fence lines are stripped too now.

**A curated list that produced no comparison reported PASS.** Removing `.claude/knowledge-drift.conf`
turned six checks into zero and `verify.sh` still printed a positively worded green, which is the
empty-set trap this repository records against itself in `working-here.md`. A missing list is now a
note rather than a pass, a list that yields nothing is a failure, and a conf whose last line has no
trailing newline no longer loses that line in silence.

**Deleting the validator removed three checks with no complaint.** `verify.sh` now fails when a
knowledge base exists and `knowledge-check.sh` does not, because a green run over an unchecked base
is worse than a red one.

Two documented numbers were also wrong and are corrected above: the case count, and 18 local
Markdown links where there are 17.
