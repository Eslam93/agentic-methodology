# Pending

Everything found and not acted on. One line each, written in the same turn, grouped by who can
act. `P0` blocks the current goal · `P1` matters soon · `P2` worth doing · `?` needs a decision.
This is the index of what is open, not the evidence for it.

## 1 · Only the owner can answer these

- `?` The v1 commits from v1.2 through v1.5.1 were never pushed: the remote's last push was 2026-06-23, measured 2026-09-05 with `gh api`. Push before or with v2? Evidence: `_investigations/2026-09-05-v2-rewrite/methodology.md`.
- `?` The standalone `communication-modes` repository still uses persistent-mode wording, and v2 deletes the modes altogether. Delete it, archive it, or leave it. Evidence: `decisions.md` S-08.

## 2 · Needs a decision

- `?` Whether `/document` and `/walkthrough` from the fresher installation join the kit. Not shipped in v2.0; add when a real use appears.
- `?` `production-audit` from `ecc` 2.2.1 as an optional review-menu item in production posture. Read, not evaluated.

## 3 · We can do these ourselves

- `P1` Promote or prune the auto-memory notes on the owner's other repositories: 84 notes on one project used as a knowledge base, 6 on the public site including two stale status notes. Evidence: the investigation page.
- `P2` Independent re-verification of the v1 research citations, deferred since 2026-06. Evidence: `_readings/evidence-base.md`.
- `P2` Codex now has its own hooks file format, seen in `ecc` 2.2.1. The secret preflight could run on the Codex side too. Not evaluated.

## 4 · Worth doing when someone is in that code anyway

- `P2` The blueprint's `make-launch.sh`, which generates the browser-pane launch profile from the resolved layout, was not brought into the kit. Add it if a shape-B project needs `launch.json`.
