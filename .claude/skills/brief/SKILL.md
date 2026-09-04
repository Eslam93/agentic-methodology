---
name: brief
description: Answer in one or two sentences and at most 50 words, with yes or no first when applicable. Applies to one response only. Use only when explicitly invoked.
argument-hint: [question, optional]
disable-model-invocation: true
---

# Purpose
Answer with the smallest useful response.

# Response contract
- If the question is yes or no, begin with exactly "Yes." or "No." when the evidence supports a definite answer.
- Use one or two sentences and no more than 50 words total.
- Give the conclusion first, followed by at most one essential reason or caveat.
- Do not use headings, bullets, preambles, summaries, examples, or follow-up offers.
- Remove technology jargon. If one term is unavoidable, define it in a few plain words.
- Do not explain background unless it changes the answer.
- Do not use em dashes.

If a safe or accurate answer genuinely cannot fit in 50 words, state the conclusion and the single most important limitation. This mode applies to your next single response only; the always-on plain-technical baseline resumes afterward.
