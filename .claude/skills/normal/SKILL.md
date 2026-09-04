---
name: normal
description: Answer the next single message in default Claude Code voice, ignoring the plain-technical baseline for that one turn. Use only when explicitly invoked.
argument-hint: [question, optional]
disable-model-invocation: true
---

# Purpose
For your next single response only, drop the always-on plain-technical baseline and any mode lens. Answer in Claude Code's default voice and behavior.

This is a one-shot escape hatch: use it when you want the raw, unfiltered default answer for one message. Do not enforce the baseline's jargon translation, audience lens, or conclusion-first structure for this response. Keep the answer direct and technically accurate.

After this single response, the plain-technical baseline resumes automatically on the next turn. If the user included a question with this invocation, answer it in default voice; otherwise acknowledge the one-turn switch in one short sentence.
