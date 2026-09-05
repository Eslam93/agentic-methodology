---
title: How a copied kit is upgraded without destroying local changes, what the manifest records and deliberately does not, why project-local copy stays canonical now that plugins exist, and the runs behind each state in the update table
status: verified
as_of: 2026-09-05
last_verified: 2026-09-05
verification_method: install.test.sh, 85 checks over the update states, both installers, run on the owner's Windows machine in Git Bash on 2026-09-05 against a fake kit and a real target; both installers run end to end into scratch repositories and their manifests compared byte for byte; one mutation of the classifier run to confirm the central guarantee can go red
scope: The change decided as D-21, which amends D-03: the installation manifest, the update classification, the two installers, install.test.sh, and the documentation of both. Not plugin packaging, not network fetching, not merging, not a migration framework
confidence: High for what the updater does in each state; each is a case that builds files and reads them back. Medium that the states cover what adopters will really meet, because this kit has one installation and no adopter has ever upgraded one
known_gaps: No real adopter has upgraded a real installation, so the states are the ones this suite constructs rather than the ones people meet. Nothing was tested on macOS or Linux. The independent review of 2026-09-06 found four defects here, all fixed and covered; what it did not find is not evidence of absence
reverify_when: On any change to the classification table, the manifest format, or the managed-file inventory; before quoting the check count
---

## The one sentence

Project-local copies stay the source of truth, and the installer may now replace only the files it
can prove the adopter has not changed; everything else is preserved and named.

## What changed, and where

| File | Change |
|---|---|
| `.claude/tools/install.sh` | the managed inventory, the manifest, the classification table, `--update`, `--check` |
| `.claude/tools/install.ps1` | the same, with the same manifest format and byte-identical hashes |
| `.claude/tools/install.test.sh` | new: 85 checks over the update states, against a fake kit, in both shells |
| `.claude/tools/verify.sh` | the suite runs under `--hooks` |
| `.claude/knowledge-drift.conf` | moved out of `.claude/tools/`, which is copied to adopters; it is this repository's list, not theirs |
| `.claude/tools/knowledge-check.sh` | reads the conf at its new path; an empty `decisions.md` is only a broken pattern when something cites a decision |
| `README.md`, `START-HERE.md` | what the manifest is, what an update does to each kind of file, and what it never does |
| `decisions.md` | D-21, amending D-03 |

## The decision, restated honestly

D-03 chose install-by-copy in 2026-08 partly because "the desktop app has no plugin surface". On
2026-09-05 the Claude Code documentation described plugin install and a local marketplace cache
dated 2026-09-02, so that premise is stale and the pending item that recorded it is now answered.

The conclusion did not change, and the reason did. Project-local copy stays canonical because the
rules and hooks that govern a project should be readable in that project, reviewed in its pull
requests, pinned with its history, and changeable locally, and because a global update should not
silently change an engineering control in a repository nobody was looking at. Plugin delivery may
later be an optional transport. It is deferred, not rejected, and nothing here claims plugins are
unsupported or worse.

That choice is what creates the upgrade problem, so the same change pays for it.

## The manifest

`.claude/install-manifest.txt`, at the root of `.claude/` and therefore **not** inside the four
folders the installer copies. Line-oriented, sorted, no dependency beyond a sha256 tool:

```text
# five comment lines saying what this is and that it is not project content
version v2.0.0-14-g753ac95
installed 2026-09-05T19:51:02Z
managed <sha256> .claude/hooks/guard-secrets.sh
managed <sha256> .claude/rules/standing-orders.md
unmanaged .claude/skills/work/EXTRA.md
```

`version` comes from `git describe --tags --always` in the kit, or `unknown` outside a checkout. It
is metadata for diagnostics, not a trigger: nothing branches on it and there is no semver engine.

`managed` records **the last upstream version known for comparison**, which is not the same thing as
what is on disk. That distinction is the whole mechanism, and it is why a locally modified file
keeps its old recorded hash rather than being re-recorded at the adopter's content: a manifest that
hashed the customization as though it were upstream would report it as untouched at the next release
and overwrite it.

`unmanaged` records a path that exists locally and whose basis is not known, so it is never
overwritten and no upstream hash is claimed for it. Writing a hash there is exactly the failure the
line exists to prevent.

## What is managed, and what is never touched

The inventory comes from the kit, by listing `.claude/rules`, `.claude/skills`, `.claude/hooks`, and
`.claude/tools` in the distribution. The target is never scanned for things to manage. An adopter's
own skill, hook, rule, or tool is invisible to the updater, and a case proves it: a
`.claude/skills/company-thing/SKILL.md` created locally survives an update and never appears in the
manifest.

Three files in a target are deliberately outside the managed set. `settings.json` is generated per
operating system rather than copied. `working/README.md` and the knowledge-base skeleton are written
once and belong to the project from then on.

`knowledge-drift.conf` moved for this reason. It sat in `.claude/tools/`, so every adopter received
this repository's curated list of counts about this repository's README, and a fresh install failed
its own `verify.sh` looking for a sentence in somebody else's file. Found by running the installer,
not by reading it.

## The classification table

Three inputs per managed path: the hash in the manifest (**old**), the hash of the file in the
target (**local**), and the hash of the file in the new release (**new**). The decision is one
comparison, `local == old`, and everything else follows from it.

| old | local | new | what happens |
|---|---|---|---|
| A | A | B | with `--update`, replaced with B and the manifest moves to B, reported UPDATED; without it, left alone and reported as older than this release |
| A | A | A | nothing, reported as unchanged |
| A | C | B | **preserved**, manifest keeps A, reported LOCALLY MODIFIED |
| A | C | A | preserved, manifest keeps A, nothing to reconcile from this release |
| absent | absent | B | installed, manifest records B, reported ADDED |
| absent | X | B | preserved, recorded `unmanaged`, reported for review |
| absent | B | B | adopted at B: byte-identical to this release, so nothing is lost |
| A | absent | B | not restored, manifest keeps A, reported DELETED HERE |
| A | A or C | gone | left in place, entry kept, reported UPSTREAM REMOVED |

Two of those rows deserve their reasoning written down.

**A managed file the adopter deleted is not put back.** Restoring it would return a control someone
removed on purpose, which is the same class of harm as overwriting an edit. It is reported instead.

**A file removed upstream is never deleted.** Deletion is more consequential than replacement, and a
file an adopter still depends on is not the installer's to remove on a guess. The entry stays in the
manifest, so the report repeats on every later update rather than the file quietly changing owner.
That is deliberate noise: dropping the entry would transfer ownership without anyone deciding.

## Installations that predate the manifest

Without a recorded hash, "this is the original upstream file" and "this is a customized file" cannot
be told apart, so the updater does not guess. A file byte-identical to the release being installed
is adopted, because adopting it loses nothing. Anything else is recorded `unmanaged`, left exactly
as it is, and listed under "Present but never recorded, left alone" on every update until the owner
reconciles it. The first run says so in one line before the report.

Absence of history is never permission to overwrite. A case proves that a customized file with no
manifest survives an update that changes that file upstream.

## Exit status, and what the output means

`--update` exits 0 when the update completed, **including** when files were preserved: a locally
modified file is a supported state, not a failure. It exits 1 only when the updater could not do its
job, which today means a file it decided to write could not be written; those paths are listed under
`FAILED` and the manifest still records their previous version, so the next run retries them. So
"applied, with your files left alone" and "the updater malfunctioned" are different exit codes and
different words.

`--check` writes nothing at all, prints the same report, and says "check only, nothing was written".
A case asserts the file and the manifest are both untouched after it.

## Ordering, and what a half-finished run leaves

Classify everything, copy the safe changes one at a time, record the result of each, then write the
manifest once through a temporary file and a rename. A copy that fails does not get an updated hash,
so the manifest never claims a file it did not write. There is no transaction and no rollback: a run
that dies halfway leaves the files it already copied and the previous manifest, which reads as "not
yet updated" for those files, and the next run redoes them. That is the smallest honest behaviour.

## Hashing and portability

SHA-256 over file bytes. `sha256sum` or `shasum -a 256` in bash, `Get-FileHash -Algorithm SHA256`
lowercased in PowerShell. Nothing reads a file as text and writes it back, so no newline translation
can move a hash. Both installers were run into scratch repositories on 2026-09-05 and their
manifests compared: the `managed` lines and the `version` line are identical.

## The suite

`bash .claude/tools/install.test.sh`: **85 checks, 0 failed**, and it runs under `verify.sh --hooks`.
Each case builds a fake kit, runs the real installer, and reads the files and the manifest back.

Initial install, and the recorded hash equals the file's own hash · untouched file updated · locally
modified file preserved with the upstream basis kept · locally modified with upstream unchanged, and
the basis does not drift · a new upstream file added · a new upstream path colliding with an
adopter's file, preserved and recorded `unmanaged` with no hash claimed · upstream removal left in
place, and again after a local edit · idempotence, with the manifest byte-stable across two runs ·
a pre-manifest installation, where the differing file is not overwritten and no hash is invented for
it while an identical file is adopted · a file edited after install recognised as modified · check
mode changing nothing · an adopter-created skill never managed · a deleted managed file not restored.

**The guarantee has a real red test.** Changing the classifier so a locally modified file is
overwritten failed five checks, among them "the local version is untouched" and "no destructive
action". Reverting returned it to green.

## What is mechanically guaranteed, and what is not

Guaranteed: a managed file whose content still matches the manifest is the only thing an update
replaces; nothing else is written; an adopter-created path is never managed; nothing is deleted;
nothing is merged; no timestamp is consulted; and a customization is never recorded as an upstream
basis.

Not guaranteed, and left to a person: whether a preserved customization is still compatible with the
new release. The updater says which files diverged and stops there. Nothing merges, and the
documentation avoids saying that a customized file receives future upstream changes, because it does
not until the owner reconciles it.

## A plain re-install must still never replace

The first build shared one code path between install and update, which meant running
`install.sh <target>` a second time silently replaced every untouched managed file with the new
release. Local modifications were still preserved, so no safety invariant broke, but the header of
that same script promises "Never overwrites: an existing file in the target is left alone and
listed", and it no longer did. Found by running a plain re-install rather than by reading the diff.

Replacement is now gated on `--update` being asked for by name. A plain install that finds an
outdated managed file leaves it, lists it, and says which command would take it. Both shells were
checked, and a case covers the whole sequence: plain re-install keeps the old version, then
`--update` takes the new one.

## Limits found on the way

- Running the installer is what found the fresh-install failure caused by the Knowledge Integrity
  work: the skeleton knowledge base carried no page headers, and `decisions.md` with no entries at
  all read as a broken id pattern. Both are fixed, the skeleton pages now ship a `status: draft`
  header, and a fresh install passes its own `verify.sh` at 21 checks. Reading the diff would not
  have found it.
- The PowerShell updater ran end to end and produced an identical manifest, but the per-state cases
  run through bash only. A PowerShell twin of the suite would be the next honest step.
- `--update` syncs managed files and the manifest, and does not revisit `settings.json`, the ignore
  and attribute lines, or the knowledge-base skeleton. A release that adds an ignore line therefore
  needs a note in its release text, and nothing enforces that today.

## What an independent review found, 2026-09-06

Four defects in the updater held against verification, and all four are fixed with cases.

**`--check` without `--update` performed a full install.** The flag was read only inside the update
branch, so the documented preview wrote settings, ignore lines, the knowledge-base skeleton, the
manifest, and on an existing installation replaced an untouched managed file. It was the easiest
typo to make, because the installer's own closing line advertises the flag. `--check` now goes down
the preview path whether or not `--update` was given, and the one thing it can never do is write.

**A plain install swallowed every copy failure and exited 0.** The FAILED list and its non-zero exit
existed only in the update branch, so a first install that could not write a file printed "copied 4
files" for a release of five, wrote a manifest from the partial run, and reported success. Both
installers now list what they could not write and exit 1.

**A file that diverged could never rejoin.** Once the local hash differed, restoring the exact
shipped bytes still left it reported as locally modified for ever, because the comparison was only
against the recorded hash. A local file byte-identical to the new release is now adopted at that
hash: it has converged, and there is nothing left to reconcile.

**`install.ps1` gave Windows adopters a corrupted knowledge base.** The script is UTF-8 with no BOM,
and PowerShell 5.1 decodes a BOM-less script in the system ANSI codepage, so each middle dot in the
skeleton text was read as two characters and written back as different bytes. An adopter following
the documented Windows-without-Git-Bash path got a mangled `99-pending.md` and `decisions.md` and
committed them, while the bash twin wrote the same text correctly. The script now carries a BOM, the
two installers produce byte-identical skeletons, and `verify.sh` fails any PowerShell file that
holds non-ASCII without one, so the class cannot come back. It is also a trap in `working-here.md`
now, because it is exactly the kind that looks fine on the machine that wrote it.

A plain re-install replacing untouched files, found before the review by running the installer
rather than reading it, is recorded in its own section above.

The review also closed a gap this page recorded: the update states now run through `install.ps1` as
well as `install.sh`, and a case asserts the two produce the same managed lines and hashes.
