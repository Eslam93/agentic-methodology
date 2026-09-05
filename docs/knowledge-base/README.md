# Knowledge base

**Two warnings, before anything else.**

1. **Nothing here has been raised with anyone but the owner.** Every finding was recorded from
   reading files, running commands, and measuring. Several items would read differently with a
   second adopter's experience behind them. Treat this as input to a decision, not as a verdict.
2. **Everything here is point-in-time.** Every substantial page carries a header saying when the
   facts were gathered, how they were verified, and what was not checked. A figure without a date
   beside it is a bug in the page.

**The absence of a subject here is not evidence about it.** Silence is a gap, not a clean bill of
health.

## Where it lives, and why

This knowledge base is committed **inside the repository**, under `docs/knowledge-base/`. In the
kit's own terms that is shape A. Measured 2026-09-05 with `gh api`: the repository
`Eslam93/agentic-methodology` is public, `main` carries no branch protection, and there is one
maintainer. The three things that rule shape A out, several repositories, a review policy on the
default branch, and findings not fit for everyone who can clone, do not apply.

Because the repository is public, **nothing from the private installations this kit was derived
from is recorded here beyond what their owner chose to generalize.** Their project names, hosts,
paths, and findings stay in their own knowledge bases.

## The rules for writing here

The full rules are in
[`00-orientation/evidence-and-verification-rules.md`](00-orientation/evidence-and-verification-rules.md).
The three that do not bend:

- **Never record a secret value.** Record that a secret exists, where it is referenced, and how it
  is provisioned.
- **Describe the system, not the people.**
- **Keep negative results and contradictions.** A thing that turned out not to be true saves the
  next person the same day.

And the one that keeps this base from quietly going wrong: **never assert a changeable condition in
the present tense.** Write the measurement, with its date and commit.

## Map

Start with [`00-orientation/index.md`](00-orientation/index.md). It routes by what you came for and
names the sections that are empty and why.
