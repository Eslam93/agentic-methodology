# Promotion ledger — the demo to production debt list

> **Required in `demo` posture** (see [`constitution/definition-of-done.md`](constitution/definition-of-done.md)).
> One row per shortcut taken *because* the project is a demo: every control switched off, corner cut, or
> known bypass left open. This is the single checklist to clear before a project or phase may flip its
> posture to `production`. It is the specialized cousin of the escape log — escape log = defects that
> slipped; promotion ledger = debts deliberately owed.

## The rule
- **Log on the way down.** The moment you switch a control off or cut a corner "because it is only the
  demo", add a row here in the *same* change. An unlogged demo shortcut is a defect.
- **Empty-or-waived to promote.** Posture cannot flip to `production` until every row is **Closed**, or the
  owner has explicitly **Waived** it with a reason and a date. No silent promotion.
- **One home.** Do not scatter this across ADRs, design notes, and a north-star doc — link them from here.

## Ledger
| # | What is off / cut / bypassed | Why (demo) | Real-data risk if shipped as-is | Exact step to close | Owner | Status |
|---|---|---|---|---|---|---|
| 1 | *example:* row-level disclosure suppression switched off | it blocked demo exploration | a user could read another tenant's aggregates | unset the demo bypass flag, restore entitlements, run the governance suite green on a fresh DB | @owner | Open |

**Status values:** Open · Closed · Waived (with reason + date).

> **Promotion gate:** before flipping posture to `production`, this table must have **no Open rows**. Every
> Waived row must carry the owner, the reason, and the date. Record the flip in the worklog and an ADR.
