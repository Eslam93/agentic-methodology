# Escape Log

> The methodology's **own feedback loop.** When a defect slips past a plane that *should* have caught it
> (a production bug, or one found late), record it here and trace it to the plane that missed it. Review
> periodically to tune tiers, checks, and the constitution.
> *(This is the lite self-improvement instrument — the seed of real success metrics.)*

| Date | Defect (1 line) | Tier | Plane that should have caught it | Why it slipped | Fix to the *method* (not just the bug) |
|------|-----------------|------|----------------------------------|----------------|----------------------------------------|
| <YYYY-MM-DD> | *example:* lockout off-by-one | T3 | Machine (mutation gap) | test enshrined the off-by-one; no boundary mutant | add boundary mutant to the T3 gate + add-a-rule |

**Planes:** Builder · Reviewer (judgment) · Machine (tests/CI) · Human-direction.

**The trace is the point.** If the Machine keeps missing what the correlated AI pair also misses, the central bet needs tuning. If tasks that escaped were under-tiered, the dial (or the blast-radius receipt) needs tuning. The log converts the methodology from a principled guess into a measured system.
