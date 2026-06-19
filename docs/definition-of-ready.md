# Definition of Ready

> A task may enter THE-FLOW (step 1) only when it meets this bar. If it doesn't, run the
> **refinement step** first — the builder drafts the missing pieces, the owner/reviewer
> confirms. We *manufacture* readiness rather than assume well-written issues.

A task is **Ready** when:
- [ ] **Outcome is clear** — what "done" looks like, in a sentence or two.
- [ ] **Acceptance criteria** exist (EARS for Tier 2/3) — testable, not vague.
- [ ] **Area identified** — the files/modules it touches are known (or a spike is scoped to find out).
- [ ] **Dependencies known** — blockers, upstream/downstream, data/services needed.
- [ ] **Tier proposed** (1/2/3), with any Tier-3 hard-floor trigger flagged.
- [ ] **Certainty assessed** (crisp/uncertain/fuzzy) — fuzzy ⇒ direction gate before build.

**Before planning, confirm the change is even needed.** Valid outcomes: **build · ask/refine · no-op** (already satisfied / duplicate / obsolete). Unnecessary AI action is its own defect class — a no-op is a *success*, not a failure.

> Counterpart to `constitution/definition-of-done.md`: **DoR gates entry, DoD gates exit.**
> This is the direct answer to "the methodology assumes good issues" — it doesn't; it makes them ready.
