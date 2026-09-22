---
title: What the estate checks add (status.sh, preflight.sh, the requires field, the reasoning traps), the failures on the source installation that paid for them, and how each tool was shown to go red
status: verified
as_of: 2026-09-22
last_verified: 2026-09-22
verification_method: The fixture cases in estate.test.sh and the three new cases in knowledge-check.test.sh, run on the owner's Windows machine in Git Bash on 2026-09-22; verify.sh, verify.sh --hooks and verify.sh --canary run on the same tree. The failures cited from the source installation are the owner's own measurements, dated, with the project's identifying detail left out
scope: The change decided as D-22. Not the source installation's status program itself, which stays private and is nine sections and 739 lines of probes against one estate; this kit takes its contract and its rule
confidence: High for what the two tools do, which the suite exercises case by case. Medium for the rule about values in prose, which stays advice: no check can tell a measurement from a claim
known_gaps: No adopter has a status.project.sh with real probes yet; the only one that exists at this date is a stub in the owner's second installation. The proof commands on a capabilities page are run as written, so the page is trusted like any script in the repository, and that trust is stated rather than enforced. The reasoning traps are recorded from five incidents on one installation; nothing says they generalise
reverify_when: The first adopter writes real probes, or a proof command is found to mutate state, or a deadlines line needs a field the line format cannot carry
---

## The gap this closes

The kit asked the right question and left the answer as prose. `/orient` step 4 said "what is
deployed, when the project rule names a way to check", and the project rule template held one line
for it. A knowledge base written under this kit could still say "the licence expires on the 15th"
or "the deployed image is 1.1.606" as a sentence, and nothing would ever compare the sentence with
the system. The source installation measured what that costs.

## What the source installation measured

| Date | What was found | What it taught |
|---|---|---|
| 2026-08-24 | A spot-check of seven written operational claims (a licence milestone, a certificate expiry, a deployed image, a restart count, a parking timer) found five stale or wrong. The knowledge base held about 1,600 hand-written image tags and 2,800 dated claims. Every one of the five was computable from a live system | if it can be read from a system, it is not a document. A program has no memory and cannot be out of date; the only dates worth keeping in a file are the ones no system can answer |
| 2026-08-01 | Runbooks stated their author's access ("cluster admin on all clusters", "the clones live at C:/..."). A required-reviewer gate recorded a non-member's approve vote and left the pull request blocked, so tooling that votes reported success while nothing moved | a runbook states its capabilities, not its author, and each capability carries a read-only proof; a note cannot fail |
| 2026-08-24 | A fix recorded as proven by an offline replay (12 of 77 cases to 44 of 77) had fired zero times in production: the replay supplied an input the running system never produces | a green test on an unreachable path is not evidence; after a deploy, look for the success line the fix emits |
| 2026-08-02 to 2026-08-08 | Three incidents in a week measured the size of a mechanism and reported it as the effect: a migration "revoking 353 entitlements" over a collection with zero documents; "86 of 88 messages dropped" where 52 were correct skips and the rest were the system's own echoes; a dead-token alarm where 1,083 sends had succeeded on the same channels | count what the customer has, not what the code touches; trace one item end to end before trusting an aggregate |
| 2026-09-20 | A service with 26 log lines a day was written down as idle; it carried all console traffic and logged at Warning | a quiet log is a mechanism; the callers are the effect |

The first two rows are the reason for the two tools. The last three are the reason `working-here.md`
gains a section for traps that are about judgement rather than shells.

## What was built

- **`status.sh`** runs `.claude/tools/status.project.sh`, the project's own read-only probes, one
  finding per line (`LEVEL`, section, subject, detail, remedy, tab-separated), and
  `.claude/deadlines.conf`, one declared date per line with a lead time and an owner. It groups the
  findings RED first, exits 1 on any RED, treats a line it cannot parse as a RED of its own, and
  requires a remedy on every RED and AMBER. Its `--canary` injects a RED and a malformed line and
  must fail. `/orient` runs it before anything else and leads the report with the RED lines.
- **`preflight.sh`** reads the capabilities page (one table row per token: blast marker, what it
  grants, a read-only proof command, the expected output, how to obtain it) and runs the proofs for
  the tokens asked for. `UNRESOLVED` in the expected column is reported and does not fail, so an
  admitted gap stays visible instead of being invented around.
- **`knowledge-check.sh`** reads the `requires:` header field and refuses a token the capabilities
  page does not define, and refuses tokens named when no capabilities page exists.
- **The rules:** `knowledge-base.md` gains the estate section (a value the estate can compute is a
  check, a runbook states its capabilities, probes live beside the pages); `standing-orders.md` gains
  the line that a 🔴 token makes a task Tier 3 and the note that the two tools are checks, not hooks;
  `working-here.md` gains the Reasoning section.
- **The skills:** `/orient` step 4 runs `status.sh`; `/work` proves a page's capabilities before the
  one yes.

## How each tool was shown to go red

`estate.test.sh` builds a fixture tree per case and runs the real tool with `--root`. The cases,
each asserting the exit code and a message: an overdue date is RED; a date inside `warn_days` is
AMBER; a date inside a quarter of `warn_days` is RED, capped at 21 days; a bad date, a missing
separator and a file with no lines are each reported rather than skipped; an OK finding passes; a
RED finding fails with its remedy printed; a RED without a remedy is itself reported; a malformed
line and an unknown level are RED; a probe that exits non-zero is RED; a probe that prints nothing is
reported; `--check` catches a script that does not parse and runs no probe; `--canary` fails and
names both injections. For `preflight.sh`: a passing proof, a failing proof, an expected regex
matched and not matched, an escaped pipe inside a proof, an UNRESOLVED token, an undefined token, a
set with one failure, no page (exit 2), a page with no rows (exit 2). Thirty-one cases, thirty-one
passed on 2026-09-22.

`knowledge-check.test.sh` gained three cases: a page requiring a defined token passes; a page
requiring an undefined token fails naming the token; a page requiring any token with no
capabilities page fails naming the missing page.

`verify.sh` gained: the status canary must fail; `status.sh --check` must pass when either input
exists; the capabilities page must parse when it exists; the estate suite runs under `--hooks`.

## Limits, stated once

- Both tools are bash, like every tool in the kit, so a Windows adopter without Git Bash cannot run
  them. The hooks are unaffected.
- The proof commands are executed as written. The page is trusted the way `verify.project.sh` is
  trusted: it is code the repository owns and reviews. The tool says so and does nothing to enforce
  it.
- `status.sh` cannot tell a probe that lies from a probe that is right. It gates on what the probe
  prints. The rule that probes must be read-only is a rule.
- The rule "a value the estate can compute is a check, not a sentence" is advice. D-20's reasoning
  holds: a prose check for version-shaped values would flag correct citations of other systems and
  fail the pages that quote the rule.
