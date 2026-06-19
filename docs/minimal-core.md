# Minimal core + hardening menu

> The methodology preaches *minimal + precise* — so it must apply that to **itself.** Two rounds of review
> were all-additive; this draws the line the method was missing. **Core** = what makes the central bet
> work, run on every task. **Hardening** = optional, switched on by tier or as a project matures. The
> all-required reading is the one that won't survive a busy week — run the marked core, add hardening where
> it earns its place.

## The irreducible core

**Tier 2/3 — every task:**
1. **The two dials** — risk tier (1/2/3, hard-floor triggers) + intent certainty (crisp/uncertain/fuzzy).
2. **The Machine plane** — lint + the full suite vs the real stack + CI, as the correctness backstop.
3. **The cold-diff code review** + the **evidence ladder** (`definition-of-done.md`).
4. **The severity digest** — merge iff 🔴 = 0.
5. **The direction-delta** at merge — what shipped vs what was asked.

**Tier 1 (fast-track)** runs a *reduced* core: state the tier · lint + affected tests · land in the **batched** severity digest · the code relay is **optional unless the blast-radius receipt contradicts Tier 1**. (The dials still apply — that's what classified it Tier 1.)

That's the bet: the dials route, the Machine carries correctness, the cold relay + ladder keep the reviewer honest, the digest gates, the delta catches "built the wrong thing." **Everything below is additive.**

## The hardening menu (switch on by tier / maturity)
| Hardening | Turn it on when |
|---|---|
| Full multi-round **design relay** | Tier-3 · architecture-touching · fuzzy (routine T2 skips it) |
| **Diff-scoped mutation** gate | Tier-3 critical logic, where tooling exists (else degrade) |
| **Human-ratified golden answers** + custody block | Tier-3 critical logic |
| **Pre-mortem** | Tier-3 |
| **Blast-radius receipt** | the risk instrument — use whenever the tier is in doubt |
| **`/clarify` + uncertainty-type** | uncertain/fuzzy intent (crisp skips it) |
| **EARS criteria + test-map** | Tier 2/3 |
| **property / fuzz / coverage** | scale to the value of the logic |
| **linter · context-rot audit · escape log** | project/team maturity (CI-wired) |

## The rule
**Core is non-negotiable; hardening is a dial, not a checklist.** When unsure about a *hardening* item, leave it off for routine work and on for critical — never the reverse. Two axes, one instrument each: **risk** = tier-triggers + blast-radius receipt; **clarity** = uncertainty-type + clarify questions. The 1–10 confidence number is optional color, not a gate (it's gameable). Adding hardening everywhere is how a methodology dies of its own weight.
