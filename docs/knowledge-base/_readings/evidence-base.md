---
title: The research the v1 thesis cited, what each item supports, and how far it was verified
status: partially-verified
as_of: 2026-06-19
last_verified: 2026-07-11
verification_method: Migrated from the evidence base in DECISIONS.md at tag v1.5.1. The v1 record states that two external reviewers re-verified the two arXiv items in 2026-06; the owner's own web check was deferred then and remains deferred
scope: Sources cited for the methodology's design. Not a literature review
confidence: Medium. The items exist as cited in v1; their applicability varies by model class, task, and harness, as v1 itself noted
known_gaps: No item on this page was re-read for this page. The Meta, Anthropic, and PRP items were demoted in v1 as over-strong cites and are listed here as context only
reverify_when: Before any public claim that rests on one of these numbers
---

| Source | What it says, as cited in v1 | What it supports in v2 | Verification status |
|---|---|---|---|
| Gloaguen et al., `arXiv:2602.11988` | repository context files tend to reduce task success and raise cost by more than 20 percent; harm concentrates in LLM-generated files; human-written files give about plus 4 percent at about plus 19 percent cost; architecture overviews do not earn their place; every context file adds steps | subtractive rules, the line budgets, deleting the architecture map | re-verified by two external reviewers in 2026-06 per the v1 record; not by the owner |
| TDAD, `arXiv:2603.17973` | procedural "do TDD" prompting raised regressions to 9.94 percent; a targeted test map cut them by about 70 percent | "name the tests that prove it" instead of a TDD ritual | same as above |
| METR, 2026-03 | many pull requests that pass SWE-bench would not actually be merged | "a passing check is not done"; the direction delta | cited in v1, not re-read |
| "Coding Agents Don't Know When to Act", `arXiv:2605.07769` | agents act when they should not, and vice versa | the no-op outcome (V-08) | cited in v1, not re-read |
| "Configuration Smells in AGENTS.md", `arXiv:2606.15828` | recurring defects in agent instruction files | the v1 linter's config-smell checks; in v2, the rule budgets | cited in v1, not re-read; the linter is deleted |
| "Nine Judges, Two Effective Votes" | correlated errors across model reviewers; cross-family overlap is close to same-family | deterministic checks carry correctness (V-05); the reviewer's value is authorship decorrelation (V-10) | cited in v1, not re-read |
| judge-calibration studies | AI reviewers run a true-positive rate above 96 percent and a true-negative rate below 25 percent: they wave correct code through and catch under a quarter of real defects | V-05 | demoted in v1 as an over-strong cite |
| Self-Correction Bench | about 64.5 percent own-error blindness on non-reasoning models; deliberation cuts it by about 89 percent | cold-first review (V-03) | cited in v1 with the model-class caveat |
| sycophancy-under-rebuttal studies | challenged reviewers cave 13 to 80 percent of the time; citation rebuttals are the most regressive; about 78.5 percent persistence | evidence-only rebuttals, side-by-side adjudication (V-03) | cited in v1, not re-read |
| Meta RADAR | risk-tiered review; revert one third, incident one in fifty | the tier dial (V-02) | demoted in v1 as an over-strong cite |
| Anthropic "Autonomy times Risk" | risk-proportional autonomy | the tier dial | demoted in v1 |
| GitHub Spec-Kit, Amazon Kiro, PRP | constitution files, EARS criteria, validation loops, confidence scores | v1 borrowed from all three; v2 keeps none of the forms | context only |
| Anthropic, as quoted in the harness-standards page | in an unmodified scaffold the model sabotaged detection 12 percent of the time; agents confidently praise their own work | the grader must not be the worker (D-05) | quoted second-hand; see `harness-standards-2026-08.md` |
