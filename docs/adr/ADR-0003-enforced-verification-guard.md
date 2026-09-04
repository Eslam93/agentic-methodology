# ADR-0003: Enforce verification — CI-gate the methodology guard, and verify the verifier

- **Status:** Accepted
- **Date:** 2026-07-11
- **Task:** methodology upgrade — field lesson from the governed-insight / Elm adoption
- **Tier:** 2

## Context
Two field failures surfaced in the governed-insight adoption:
1. The methodology guard (rebuild `AGENTS.md` from the spine + `lint-methodology.sh`) ran only by
   convention — a local git hook, or "run it inside THE FLOW" — never in CI. It **failed open**: a stale,
   corrupt `AGENTS.md` reached main and was repaired only after the fact. A later retirement of the
   "constitution" framing also never propagated to peripheral docs the guard did not watch.
2. The local test runner produced repeated **false greens** (pytest exiting 0 on failing tests; a shell pipe
   masking a browser-test exit code). Only a redundant fresh-DB CI run caught them.

## Decision
- **CI-gate the guard (required, not optional).** Ship a ready-to-paste CI job
  (`.github/workflows/methodology-guard.yml`) that rebuilds `AGENTS.md`, runs `git diff --exit-code
  AGENTS.md` (fails on a stale rulebook), and runs `lint-methodology.sh`. Wiring it into CI is a **required**
  Phase-0 / adoption step; a by-convention or local-hook guard is explicitly declared insufficient.
- **Verify the verifier.** Add a cross-cutting Definition-of-Done rule: keep a **canary** (a
  deliberately-failing test the runner must report as failed) and run it in every environment; a runner that
  passes the canary is lying, and its greens are void until it is fixed.
- **Semantic cross-reference sweep.** Strengthen the Phase-0 context-rot audit to confirm every doc that
  refers to the rulebook describes it consistently (no doc still calling the guide "the constitution / law"
  after a rename). Kept as the *semantic* audit rather than a brittle lint grep, because the rulebook's own
  generated title legitimately contains "constitution".

## Consequences
- Easier: a stale or corrupt rulebook, and a lying test runner, are caught mechanically instead of by luck or
  after they reach main.
- Harder / accepted: one CI job to maintain and a canary test to keep.
- Revisit if: a project has no CI — then the guarantee is explicitly degraded per Phase-0's degrade rule.

## Alternatives considered
- **Keep the local git hook only:** rejected — proven to fail open (bypassable, and it does not run in CI).
- **A brittle lint grep for "constitution / law" everywhere:** rejected — false-positives on the rulebook's
  own generated title; the semantic context-rot audit is the right home.
