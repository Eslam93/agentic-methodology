# This repository

The kit's own repository, running the kit on itself: shape A, one maintainer, public.

## The one fact that matters most

`.claude/` here is both the source adopters copy and the live harness. A change to a rule, a hook,
or a skill changes the kit for everyone who installs it next, so every such change runs
`bash .claude/tools/verify.sh --hooks` before it is committed.

## Repository and branches

One repository, `github.com/Eslam93/agentic-methodology`. `main` is the trunk and the only branch;
no environments, nothing deployed, no branch policy (measured 2026-09-05). The v1 documents are at
tag `v1.5.1`. Work lands on `main` in one commit per unit of work.

## Running it

Nothing builds or runs. `bash .claude/tools/verify.sh` is the whole check; `--hooks` fires every
hook by hand; `--canary` must fail. There is no `verify.project.sh` because there is no project
build. CI runs the same three in `.github/workflows/verify.yml`.

## Tracker and posture

GitHub issues, through `gh`, none open at 2026-09-05. Data posture: not applicable; the repository
holds no data. Nothing here is a secret; the guard still runs.

## Terms

kit (what adopters copy) · harness (the `.claude/` folder in use) · knowledge base (`docs/knowledge-base/`)
· `working/` (disposable) · shape A and shape B (one repository, a workspace above several).

## Confirm before

Beyond the standing orders: any push, since nothing has been pushed since 2026-06-23 and the owner
decides how the v1 commits go out; any deletion under `docs/knowledge-base/`.
