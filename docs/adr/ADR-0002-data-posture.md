# ADR-0002: Data posture (demo vs production) with a gated promotion ledger

- **Status:** Accepted
- **Date:** 2026-07-11
- **Task:** methodology upgrade — field lesson from the governed-insight / Elm adoption
- **Tier:** 3   <!-- changes the DoD bar and the review scope; a governance-shaped decision -->

## Context
A real 3.5-week adoption (governed-insight) took a deliberate "demo-first, correctness-only" rigor cut for a
synthetic-data POC. The cut itself was disciplined (controls switched off behind fail-closed flags, not
deleted), but the *debts* it created — controls off, plus two routing bypasses left open — ended up smeared
across five documents with no single owner or checklist, and the "restore the security floor later" path was
hand-wavy and incomplete. The methodology had no first-class notion of "this is a demo, hold the rigor, but
track what you owe to become production."

## Decision
Introduce a declared **data posture** — `demo` (synthetic / illustrative data only) or `production` (real or
regulated data) — set at Phase 0 and stated in the constitution/guide so **both** builder and reviewer scope
to it. The Definition of Done flexes by posture: in `demo`, security / robustness / edge hardening are
non-blocking follow-ups unless they break a real demo answer; in `production` they are blocking. Two rules
keep this a posture, not a loophole:
1. Every "because demo" shortcut is logged in a **required** promotion ledger (`docs/promotion-ledger.md`).
2. Crossing `demo` to `production` is **gated**: posture cannot flip until the ledger is empty, or each open
   row is owner-waived with a reason.

Posture lives in the Definition-of-Done spine (cited by both planes), not in `THE-FLOW` — it is a bar, not a
new per-task step.

## Consequences
- Easier: a demo can move fast without pretending it is production, and the debt has one home and a clear
  gate — no more "followed the restore steps but a bypass was still open".
- Harder / accepted: `demo` posture now *requires* the ledger (a small always-on artifact), and the
  promotion gate is a real checkpoint someone must run.
- Boundary: the reviewer is told the posture, so it does not waste rounds raising out-of-scope hardening in
  `demo` (a real cost governed-insight hit before it rewrote its review persona) and *does* raise it as
  blocking in `production`.
- Revisit if: projects routinely need more than two postures (e.g. a staging tier).

## Alternatives considered
- **Leave it to each project (status quo):** rejected — governed-insight proved the debt scatters and the
  restore path becomes unreliable without a required ledger and a gate.
- **Model posture as a third per-task dial:** rejected — posture is a project/phase-level declaration, not a
  per-task choice; a dial would wrongly imply it changes task to task.
