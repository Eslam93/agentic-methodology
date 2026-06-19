# Worklog

> Appended **every session** (newest at top). One entry per working session.
> Format: date · what shipped (with tiers) · merge verdicts · what's next.

<!-- Copy this block to the top each session:

## <YYYY-MM-DD> · <session focus>
- **Shipped:** <task-id (Tier n) — one line>; …
- **Merges:** <task-id PASS · 🔴0 🟡n ⚪n>; …   (Tier-1 batched)
- **Decisions/ADRs:** <ADR-NNNN …>
- **Next:** <what's queued / blocked>
- **Hours:** <n>

-->

## <YYYY-MM-DD> · example entry
- **Shipped:** AUTH-12 (Tier 3) — account lockout after 5 failed logins.
- **Merges:** AUTH-12 PASS · 🔴 0 · 🟡 1 (filed #44) · ⚪ 2.
- **Decisions/ADRs:** ADR-0007 (lockout window = 15 min).
- **Next:** AUTH-13 (session expiry) — blocked on a product call.
- **Hours:** 3.
