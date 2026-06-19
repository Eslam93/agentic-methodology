# Lane card — the daily entry point

> One glance, then go. Pick a lane by the two dials, run its column. Anything not listed is *hardening*
> (`minimal-core.md`) — add it by tier, not by habit.

| Lane | Use when | Run |
|---|---|---|
| **T1 Fast** | small · reversible · no trigger | state tier · lint + affected tests · batched digest |
| **T2 Lite** | routine · non-trigger | DoR · EARS + test-map · cold-criteria · build · Machine (suite + CI) · code relay · digest + direction-delta |
| **T2 Full** | ambiguous or broad | T2 Lite **+ full plan relay** |
| **T3 Critical** | trigger / hard-to-reverse / fuzzy | T2 Full **+ ADR · human direction pre-check · mutation / golden-answers · rollback** |

**Lite eligibility (all must hold):** no Tier-3 trigger · no public API / schema / migration / auth / secrets / payments · no unresolved `/clarify` · no new dependency · explainable in one paragraph · test-map covers it · cold-criteria finds no direction divergence. **Any miss → T2 Full.**

**The loop (every lane):** classify → Ready *(or refine / **no-op**)* → criteria + test-map → *(T2/3)* cold-criteria → build → Machine → cold code review → digest + direction-delta → **merge iff 🔴 = 0**.
