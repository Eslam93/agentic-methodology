---
title: What the AI Workspace Blueprint prescribes, what this kit took from it, and what it did not
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: The document, 1,675 lines, was read in full on 2026-09-05 from the owner's local copy. Its own claims about failures are the source's measurements on a nine-repository .NET estate and were not re-measured here
scope: The blueprint as a source. Not the estate it came from
confidence: High that the document says what this page says. Medium that its failure-derived rules transfer to a single-repository project; that is what Phases 2 to 4 test
known_gaps: The estate it describes was not inspected; only its generalized rules were
reverify_when: If the owner revises the blueprint
---

## The source

"Blueprint: building a harness and a knowledge base for an existing software project", written
2026-09-02 by the kit's owner, derived from a working installation on a nine-repository .NET
estate. It is a specification to hand to an assistant opened on an existing codebase, not content
to copy. Its six rules for the assistant: verify every claim, measure before writing, build a thin
slice first, ask the human the shape question before creating anything, nothing is enforced except
hooks, adapt the shape and keep the discipline.

## What it prescribes

- **Two things with one boundary.** The knowledge base holds what is true about the system, with
  evidence, and outlives the engagement. The harness holds how the assistant works on the system
  and is versioned like code. Volatile status lives in a third, disposable folder that is never
  published. Mixing them is the failure that kills these systems.
- **Four directories at a workspace root:** `.claude/`, a harness source, a knowledge base,
  `working/`, with the code clones anywhere and a layout resolver instead of a hardcoded path.
- **Four repository shapes**, A inside the product repository through D local-only, with the
  argument that a convention recorded in the repository is read and one recorded outside it rots.
- **The knowledge base specification:** numbered folders, the page header, the banner, confidence
  labels, capability status, the volatile-claim rule, the evidence hierarchy, corrections by fix or
  supersede with a symbol sweep, the three non-negotiables, `99-pending.md`, the index, the gaps
  page, repository configuration, the README's two warnings.
- **The harness specification:** the escalation ladder from rule to skill to hook to subagent,
  always-loaded and path-scoped rules with a 200-line budget and a ratchet, five skills first
  (orient, work, record, handoff, verify), two hooks (a secret guard and a test-weakening Stop
  hook) with their design notes, three tools (layout resolver, verification manifest, launch
  generator), settings, packaging and bootstrap for shapes B and C, and two onboarding documents.
- **How a session runs, the traps rule, the failure modes, a build order, fourteen acceptance
  tests, a file manifest, and the installation it came from** with its honest limits.

## What the kit took

Nearly all of the knowledge base specification, verbatim in spirit: see
`00-orientation/evidence-and-verification-rules.md`. The harness instruments: rules with the
budget and ratchet, the five first skills, both hooks with their design notes, the layout resolver,
the verification manifest with its six traps, and the acceptance tests as the kit's own Phase 4.
The `/orient` five steps and the `/work` four beats. The two boundaries: orienting is not
deciding, and durable facts never share a folder with volatile status.

## What the kit did not take, and why

- **A harness source repository with a mirror under `plugins/`, a drift check, `/update`, and a
  bootstrap script.** The kit's shapes A and B commit `.claude/` directly, so there is no copy to
  drift. See `decisions.md` D-02 and D-03.
- **`HANDOVER.md` for a human.** The kit has a two-door README and `START-HERE.md` for the
  assistant.
- **Shape C and shape D** as first-class options. C is an exception a team can still build; D is
  the state before setup.
- **The `10-access`, `60-design`, and `95-briefings` sections as defaults.** They remain in the
  numbering for projects that need them.
- **The blueprint's silence on a review step and on tiering.** The kit adds the methodology's
  tier dial, stop-list, evidence calculus, and reviewer menu inside `/work`.
