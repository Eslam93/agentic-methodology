# Communication layer (optional, on by adoption)

> How the **builder speaks to the human**. Voice only: it changes nothing about what gets built or how it
> is verified. It rides the Claude Code output-style + skills surface and is deliberately kept **out of the
> constitution** (`AGENTS.md`) and **out of `THE-FLOW`**. A Phase-0 provisioning add-on, not a per-task step
> (see [`minimal-core.md`](minimal-core.md)).

## Why it is here
The methodology keeps the human for one job: owning **direction** and approving the **merge** from a
human-readable executive digest. If the builder writes design notes, direction-deltas, and merge digests in
stack jargon the owner cannot follow, that human gate degrades. This layer protects the readability of the
one thing the human is kept for. It is Claude-only (the builder plane); the Codex reviewer keeps its
verdict-first digest and is unaffected.

## Two tiers
- **Baseline (always-on):** a project-scoped Claude Code **output style** (`plain-technical`) that makes
  every builder response lead with the conclusion, explain the real mechanism, and translate stack-specific
  jargon on first use. `keep-coding-instructions: true`, so all engineering behavior is retained: it adds
  voice, it does not replace the coding brain. It lives in the system prompt, so it survives long sessions
  and context compaction.
- **Modes (one-shot overrides):** six skills invoked on command, each shaping **a single response**, after
  which the baseline resumes on its own:

  | Command | For a single answer that is... |
  |---|---|
  | `/explain` | a deep plain explanation of how an unfamiliar implementation works |
  | `/brief` | the smallest useful answer (one or two sentences, at most 50 words, yes/no first) |
  | `/architect` | system structure, boundaries, and tradeoffs, framework jargon stripped |
  | `/peer` | an engineer-to-engineer diagnosis of a specific issue or fix |
  | `/product` | user value, scope, stories, acceptance, and risk |
  | `/normal` | the raw default Claude Code voice, ignoring the baseline for that one turn |

## On / off (per repo)
The baseline is **on by default once a repo adopts the methodology**. Toggle it with `/output-style`: pick
**Plain technical** to turn it on, **Default** to turn it off. Turning it off never deletes the files, so it
is a one-command switch either way. The setting is per repo, remembered in `.claude/settings.json`
(`outputStyle`), and a change takes effect on the next `/clear` or new session (the style is read once at
session start).

## Files
- `.claude/output-styles/plain-technical.md` — the baseline voice.
- `.claude/skills/{explain,brief,architect,product,peer,normal}/SKILL.md` — the one-shot modes
  (`disable-model-invocation: true`, so they never fire unless invoked).

## The boundary (why it is not in the constitution)
Three separate homes, kept separate on purpose:
- **Communication layer** (here) = builder-to-human voice. Claude-only.
- **Constitution** (`AGENTS.md`) = rules about the code, read by both planes, cited by the reviewer.
- **`THE-FLOW`** = the process.

Voice does not belong in `AGENTS.md`: the reviewer never needs it, and the constitution has a size budget to
protect.
